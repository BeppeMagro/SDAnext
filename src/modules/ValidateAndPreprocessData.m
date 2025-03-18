function dataStruct = ValidateAndPreprocessData(filePath)
% Validate and preprocess data from a file and organize output variables into a single struct

% Initialize output struct
dataStruct = struct();
dataStruct.dose = [];
dataStruct.survivalFraction = [];
dataStruct.stdDev = [];
dataStruct.weights = [];
dataStruct.message = '';
dataStruct.defaultAdded = false; % Flag to indicate if default data was added
dataStruct.headerInfo = struct(); % Initialize struct to store header information

try
    % Read raw data from the file
    rawData = importdata(filePath, '\n');

    % Initialize variables for storing processed data
    data = [];

    % Process each line to handle headers and comments
    for i = 1:length(rawData)
        line = strtrim(rawData{i});

        % Skip empty lines
        if isempty(line)
            continue;
        end

        % Handle header lines (starting with '!')
        if startsWith(line, '!')
            % Extract key-value pairs from header lines
            keyValue = strsplit(line(2:end), '=');
            if length(keyValue) == 2
                key = strtrim(keyValue{1});
                value = strtrim(keyValue{2});
                value = value(2:end-1); % Remove surrounding single quotes

                % Store only allowed fields
                if ismember(key, {'Color', 'DisplayName', 'Title'})
                    dataStruct.headerInfo.(key) = value;
                end
            end
            continue;
        end

        % Skip comment lines (starting with '#')
        if startsWith(line, '#')
            continue;
        end

        % Convert valid data line to numeric array and append to data
        try
            lineData = str2num(line); %#ok<ST2NM> % Convert line to numeric
            if ~isempty(lineData) && ismatrix(lineData) && size(lineData, 2) >= 2
                data = [data; lineData]; %#ok<AGROW> % Append to data matrix
            end
        catch
            % If conversion fails, report it
            dataStruct.message = sprintf('Error converting line to numeric data: %s', line);
            return;
        end
    end

    % Check if data has at least two columns
    if size(data, 2) < 2
        dataStruct.message = 'The selected file must have at least two columns.';
        return; % Exit the function if there are not enough columns
    end

    % Extract columns
    dataStruct.dose = data(:, 1); % First column: Dose in Gy
    dataStruct.survivalFraction = data(:, 2); % Second column: Survival Fraction

    % Validate doses
    if any(dataStruct.dose < 0)
        dataStruct.message = 'Doses must be greater than or equal to 0.';
        return; % Exit the function if doses are invalid
    end

    % Validate survival fraction values
    if any(dataStruct.survivalFraction < 0 | dataStruct.survivalFraction > 1)
        dataStruct.message = 'Survival fractions must be between 0 and 1.';
        return; % Exit the function if survival fractions are invalid
    end

    % Extract standard deviation if it exists
    if size(data, 2) == 3
        dataStruct.stdDev = data(:, 3); % Third column: Standard Deviation
        dataStruct.weights = 1 ./ (dataStruct.stdDev .^ 2); % Compute weights for curve fitting
    else
        dataStruct.stdDev = []; % No standard deviation column
        dataStruct.weights = ones(size(dataStruct.dose)); % Uniform weights if stdDev is missing
    end

    % Check if (dose = 0, survivalFraction = 1) is present
    isDefaultPresent = any(dataStruct.dose == 0 & dataStruct.survivalFraction == 1);

    if ~isDefaultPresent
        % Add default data point
        dataStruct.dose = [dataStruct.dose; 0];
        dataStruct.survivalFraction = [dataStruct.survivalFraction; 1];
        if ~isempty(dataStruct.stdDev)
            dataStruct.stdDev = [dataStruct.stdDev; 0];
            dataStruct.weights = [dataStruct.weights; Inf]; % Add weight for the default point (1/0^2)
        else
            dataStruct.weights = [dataStruct.weights; 1]; % Add uniform weight for the default point
        end
        dataStruct.defaultAdded = true; % Indicate default data was added
        dataStruct.message = 'Default data point (dose = 0, survival fraction = 1) has been added.';
    end

    % Reorder data according to increasing dose
    [dataStruct.dose, sortIdx] = sort(dataStruct.dose); % Sort doses and get sort indices
    dataStruct.survivalFraction = dataStruct.survivalFraction(sortIdx); % Reorder survival fractions
    dataStruct.weights = dataStruct.weights(sortIdx); % Reorder weights
    if ~isempty(dataStruct.stdDev)
        dataStruct.stdDev = dataStruct.stdDev(sortIdx); % Reorder standard deviations if present
    end

    % Prepare data for curve fitting
    [dataStruct.dose, dataStruct.survivalFraction, dataStruct.weights] = ...
        prepareCurveData(dataStruct.dose, dataStruct.survivalFraction, dataStruct.weights);

    % Confirm that data is processed correctly
    if ~dataStruct.defaultAdded
        % Define the column width for alignment
        colWidth = 12; % Adjust as needed for better readability
        formatSpec = ['%' num2str(colWidth) '.3f']; % Example: '%12.3f'

        % Number of data points
        numPoints = numel(dataStruct.dose);

        % Header row
        dataStruct.message = sprintf('\nData successfully validated and sorted.\n\n');
        dataStruct.message = [dataStruct.message, sprintf('%-12s %-12s', 'Dose', 'SF')];

        % Include Standard Deviation and Weights if available
        if ~isempty(dataStruct.stdDev)
            dataStruct.message = [dataStruct.message, sprintf(' %-12s %-12s', 'StdDev', 'Weights')];
        end
        dataStruct.message = [dataStruct.message, newline];

        % Separator row
        dataStruct.message = [dataStruct.message, repmat('-', 1, colWidth * (2 + 2 * ~isempty(dataStruct.stdDev) * 2)), newline];

        % Print each row of values aligned in columns
        for i = 1:numPoints
            dataStruct.message = [dataStruct.message, ...
                sprintf(formatSpec, dataStruct.dose(i)), ' ', ...
                sprintf(formatSpec, dataStruct.survivalFraction(i))];

            % Print Std Dev and Weights if available
            if ~isempty(dataStruct.stdDev)
                dataStruct.message = [dataStruct.message, ' ', ...
                    sprintf(formatSpec, dataStruct.stdDev(i)), ' ', ...
                    sprintf(formatSpec, dataStruct.weights(i))];
            end
            dataStruct.message = [dataStruct.message, newline];
        end
    end


catch ME
    % Handle errors in reading the file
    dataStruct.message = sprintf('Error reading the file: %s', ME.message);
end
end