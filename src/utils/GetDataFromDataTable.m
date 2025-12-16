function dataStruct = GetDataFromDataTable(DataTableData)
% Retrieve data from DataTable
% - stdDev = 0 preserved
% - weights = 1/stdDev^2
% - Inf / 0 regularised here (1e-6 / 1e6)
% - compatibility preserving

    % ---------------------------------------------------------------------
    % Retrieve numeric data
    % ---------------------------------------------------------------------
    x = str2double(DataTableData(:, 1)); % Dose
    y = str2double(DataTableData(:, 2)); % Survival Fraction

    % ---------------------------------------------------------------------
    % Validate x and y
    % ---------------------------------------------------------------------
    if any(isnan(x)) || any(isnan(y))
        error('Invalid data in Dose (x) or Survival Fraction (y). Ensure they are numeric.');
    end

    if any(isinf(x)) || any(isinf(y))
        error('Infinite data in Dose (x) or Survival Fraction (y) detected.');
    end

    % ---------------------------------------------------------------------
    % Retrieve stdDev (if present)
    % ---------------------------------------------------------------------
    stdDev = [];
    if size(DataTableData, 2) >= 3
        stdDev = str2double(DataTableData(:, 3));
    end

    % ---------------------------------------------------------------------
    % Compute weights (theoretical)
    % ---------------------------------------------------------------------
    if isempty(stdDev)
        % No std dev column → uniform weights
        w = ones(size(x));
    else
        % Pure definition (0 -> Inf)
        w = 1 ./ (stdDev.^2);

        % -----------------------------------------------------------------
        % Regularisation (NUMERICAL, not semantic)
        % -----------------------------------------------------------------
        % stdDev == 0  -> very large weight
        w(isinf(w)) = 1 / (1e-6)^2;

        % very large stdDev or explicit zeros in weight -> very small weight
        w(w == 0) = 1 / (1e6)^2;
    end

    % ---------------------------------------------------------------------
    % Final validation
    % ---------------------------------------------------------------------
    if any(isnan(w))
        error('Invalid weights (NaN) detected after processing.');
    end

    % ---------------------------------------------------------------------
    % Output struct
    % ---------------------------------------------------------------------
    dataStruct.x = x;
    dataStruct.y = y;
    dataStruct.w = w;
end
