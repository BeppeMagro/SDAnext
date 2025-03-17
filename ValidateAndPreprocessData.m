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
                data = [data; lineData]; % Append to data matrix
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
        dataStruct.message = [dataStruct.message, sprintf('\nData successfully validated and sorted.\nDose values: %s\nSurvival fractions: %s\n', ...
            mat2str(dataStruct.dose), mat2str(dataStruct.survivalFraction))];
        if ~isempty(dataStruct.stdDev)
            dataStruct.message = [dataStruct.message, sprintf('Standard deviations: %s\nWeights: %s', mat2str(dataStruct.stdDev), mat2str(dataStruct.weights))];
        end
    end
    
catch ME
    % Handle errors in reading the file
    dataStruct.message = sprintf('Error reading the file: %s', ME.message);
end
end