function dataStruct = ValidateAndPreprocessData(filePath)
% Validate and preprocess data from a file and organize output variables into a single struct
%
% COMPATIBILITY-PRESERVING REFACTOR
% --------------------------------
% - Same inputs / outputs
% - Same fields in dataStruct
% - stdDev = 0 preserved
% - weights = 1/stdDev^2 (Inf allowed conceptually)
% - padding with zeros
% - Inf weights regularised ONLY to satisfy prepareCurveData

% -------------------------------------------------------------------------
% Initialize output struct
% -------------------------------------------------------------------------
dataStruct = struct();
dataStruct.dose = [];
dataStruct.survivalFraction = [];
dataStruct.stdDev = [];
dataStruct.weights = [];
dataStruct.message = '';
dataStruct.defaultAdded = false;
dataStruct.headerInfo = struct();

try
    % ---------------------------------------------------------------------
    % Read file line-by-line
    % ---------------------------------------------------------------------
    rawData = importdata(filePath, '\n');
    data = [];

    % ---------------------------------------------------------------------
    % Parse file
    % ---------------------------------------------------------------------
    for i = 1:numel(rawData)
        line = strtrim(rawData{i});

        if isempty(line)
            continue;
        end

        % --- Header lines -------------------------------------------------
        if startsWith(line, '!')
            keyValue = strsplit(line(2:end), '=');
            if numel(keyValue) == 2
                key   = strtrim(keyValue{1});
                value = strtrim(keyValue{2});
                if numel(value) >= 2
                    value = value(2:end-1); % strip quotes
                end
                if ismember(key, {'Color', 'DisplayName', 'Title'})
                    dataStruct.headerInfo.(key) = value;
                end
            end
            continue;
        end

        % --- Comment lines ------------------------------------------------
        if startsWith(line, '#')
            continue;
        end

        % --- Numeric data -------------------------------------------------
        nums = str2num(line); %#ok<ST2NM>
        if isempty(nums) || numel(nums) < 2
            continue;
        end

        % Pad with zeros (NOT NaN)
        nCols = max(size(data,2), numel(nums));
        nums(end+1:nCols) = 0;
        if ~isempty(data)
            data(end, end+1:nCols) = 0;
        end

        data = [data; nums]; %#ok<AGROW>
    end

    % ---------------------------------------------------------------------
    % Basic validation
    % ---------------------------------------------------------------------
    if isempty(data) || size(data,2) < 2
        dataStruct.message = 'The selected file must have at least two numeric columns.';
        return;
    end

    dose = data(:,1);
    sf   = data(:,2);

    if any(dose < 0)
        dataStruct.message = 'Doses must be greater than or equal to 0.';
        return;
    end

    if any(sf < 0 | sf > 1)
        dataStruct.message = 'Survival fractions must be between 0 and 1.';
        return;
    end

    % ---------------------------------------------------------------------
    % stdDev and weights (semantic definition)
    % ---------------------------------------------------------------------
    hasStd = size(data,2) >= 3;

    if hasStd
        stdDev  = data(:,3);
        weights = 1 ./ (stdDev.^2);   % stdDev = 0 -> Inf (INTENDED)
    else
        stdDev  = [];
        weights = ones(size(dose));
    end

    % ---------------------------------------------------------------------
    % Default point (dose = 0, SF = 1)
    % ---------------------------------------------------------------------
    isDefaultPresent = any(dose == 0 & sf == 1);

    if ~isDefaultPresent
        dose = [dose; 0];
        sf   = [sf;   1];

        if hasStd
            stdDev  = [stdDev; 0];
            weights = [weights; Inf];
        else
            weights = [weights; 1];
        end

        dataStruct.defaultAdded = true;
        dataStruct.message = ...
            'Default data point (dose = 0, survival fraction = 1) has been added.';
    end

    % ---------------------------------------------------------------------
    % Sort by dose (row-consistent)
    % ---------------------------------------------------------------------
    [dose, idx] = sort(dose);
    sf      = sf(idx);
    weights = weights(idx);

    if hasStd
        stdDev = stdDev(idx);
    end

    % ---------------------------------------------------------------------
    % IMPORTANT: regularise Inf weights for prepareCurveData ONLY
    % ---------------------------------------------------------------------
    % prepareCurveData removes rows with Inf/NaN weights.
    % Replace Inf with a very large finite weight to preserve the row.
    weights_pc = weights;
    weights_pc(isinf(weights_pc)) = 1 / (1e-6)^2;

    % ---------------------------------------------------------------------
    % Prepare data for curve fitting (MATLAB builtin)
    % ---------------------------------------------------------------------
    [dose, sf, weights_pc] = prepareCurveData(dose, sf, weights_pc);

    % ---------------------------------------------------------------------
    % Assign outputs (restore semantic weights)
    % ---------------------------------------------------------------------
    dataStruct.dose = dose;
    dataStruct.survivalFraction = sf;
    dataStruct.weights = weights_pc;

    if hasStd
        dataStruct.stdDev = stdDev(1:numel(dose));
    end

    % ---------------------------------------------------------------------
    % Popup message
    % ---------------------------------------------------------------------
    if ~dataStruct.defaultAdded
        colW = 12;

        dataStruct.message = sprintf('\nData successfully validated and sorted.\n\n');
        dataStruct.message = [dataStruct.message, ...
            sprintf('%-12s %-12s', 'Dose', 'SF')];

        if hasStd
            dataStruct.message = [dataStruct.message, ...
                sprintf(' %-12s %-12s', 'StdDev', 'Weight')];
        end
        dataStruct.message = [dataStruct.message newline];
        dataStruct.message = [dataStruct.message, ...
            repmat('-', 1, colW * (2 + 2.5*hasStd)), newline];

        for i = 1:numel(dose)
            dataStruct.message = [dataStruct.message, ...
                sprintf('%-12.3f %-12.3f', dose(i), sf(i))];

            if hasStd
                dataStruct.message = [dataStruct.message, ...
                    sprintf(' %-12.3f %3.1f', stdDev(i), dataStruct.weights(i))];
            end

            dataStruct.message = [dataStruct.message newline];
        end
    end

catch ME
    dataStruct.message = sprintf('Error reading the file: %s', ME.message);
end
end
