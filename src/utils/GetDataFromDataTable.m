function dataStruct = GetDataFromDataTable(DataTableData)
% GetDataFromDataTable
%
% Extracts dose (x), survival fraction (y), and weights (w)
% from the App Designer DataTable.
%
% RIGOROUS BEHAVIOR:
% - If no SD column is provided -> uniform weights (w = 1).
% - If an SD column is provided:
%     * All entries must be numeric.
%     * No empty or non-numeric cells are allowed.
%     * All SD values must be strictly positive.
% - Weights are defined as w = 1 / SD^2.
% - Only numerical regularisation of Inf/0 is performed.
%
% This avoids silent propagation of NaN weights.

    % ---------------------------------------------------------------------
    % Extract Dose (x) and Survival Fraction (y)
    % ---------------------------------------------------------------------
    x = str2double(string(DataTableData(:, 1)));  % Dose [Gy]
    y = str2double(string(DataTableData(:, 2)));  % Survival Fraction

    % ---------------------------------------------------------------------
    % Validate x and y
    % ---------------------------------------------------------------------
    if any(isnan(x)) || any(isnan(y))
        error('Invalid data in Dose (x) or Survival Fraction (y). Ensure they are numeric.');
    end

    if any(isinf(x)) || any(isinf(y))
        error('Infinite values detected in Dose (x) or Survival Fraction (y).');
    end

    % ---------------------------------------------------------------------
    % Handle standard deviation column (optional)
    % ---------------------------------------------------------------------
    stdDev = [];

    if size(DataTableData, 2) >= 3

        % Convert SD column to numeric
        stdDevRaw = string(DataTableData(:, 3));
        stdDevNum = str2double(stdDevRaw);

        % Case 1: Entire column empty or non-numeric → treat as no SD
        if all(isnan(stdDevNum))
            stdDev = [];

        % Case 2: Partially invalid column → explicit error
        elseif any(isnan(stdDevNum))
            error(['Standard deviation column contains empty or non-numeric values. ' ...
                   'Either provide all SD values or leave the entire column empty.']);

        else
            stdDev = stdDevNum;
        end
    end

    % ---------------------------------------------------------------------
    % Compute weights
    % ---------------------------------------------------------------------
    if isempty(stdDev)

        % No SD provided → uniform weights
        w = ones(size(x));

    else

        % Strict validation: SD must be strictly positive
        if any(stdDev <= 0)
            error('Standard deviation values must be strictly positive.');
        end

        % Theoretical definition
        w = 1 ./ (stdDev.^2);

        % -----------------------------------------------------------------
        % Numerical regularisation (only for extreme values)
        % -----------------------------------------------------------------
        % Protect against extremely small SD → huge weights
        w(isinf(w)) = 1 / (1e-6)^2;

        % Protect against extremely large SD → near-zero weights
        w(w == 0) = 1 / (1e6)^2;
    end

    % ---------------------------------------------------------------------
    % Final safety check
    % ---------------------------------------------------------------------
    if any(isnan(w)) || any(~isfinite(w))
        error('Invalid weights detected after processing.');
    end

    % ---------------------------------------------------------------------
    % Output structure
    % ---------------------------------------------------------------------
    dataStruct.x = x;
    dataStruct.y = y;
    dataStruct.w = w;

end
