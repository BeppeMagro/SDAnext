function dataStruct = GetDataFromDataTable(DataTableData)
    % Retrieve data from DataTable
    x = str2double(DataTableData(:, 1)); % Dose (x values)
    y = str2double(DataTableData(:, 2)); % Survival Fraction (y values)
    stdDev = str2double(DataTableData(:, 3)); % Standard Deviation (for weights)

    % Check for NaN or infinite values in x and y
    if any(isnan(x)) || any(isnan(y))
        error('Invalid data in Dose (x) or Survival Fraction (y). Ensure they are numeric.');
    end

    if any(isinf(x)) || any(isinf(y))
        error('Infinite data in Dose (x) or Survival Fraction (y) detected. Ensure they are finite.');
    end

    % Handle stdDev (weights)
    if all(isnan(stdDev)) || isempty(stdDev) % Handle the case where the third column is empty or invalid
        w = ones(size(x)); % Use default weights of 1
    else
        % Replace zeros and infinities in stdDev with appropriate values
        stdDev(stdDev == 0) = 1e-6; % Replace zeros with a very small number
        stdDev(isinf(stdDev)) = 1e6; % Replace infinities with a very large number

        % Calculate weights (inverse of squared standard deviation)
        w = 1 ./ (stdDev .^ 2);
    end

    % Validate weights to ensure no remaining invalid values
    if any(isnan(w)) || any(isinf(w))
        error('Invalid weights (NaN or Inf) detected after processing.');
    end

    % Create the dataStruct
    dataStruct.x = x;
    dataStruct.y = y;
    dataStruct.w = w;
end
