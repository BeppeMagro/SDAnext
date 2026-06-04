function Output = ComputeFitCovariance(FitObject, GOF, Output, fitOptions)
% ComputeFitCovariance
% -------------------------------------------------------------------------
% Attach covariance-aware uncertainty diagnostics to a MATLAB fit Output
% structure.
%
% The function is intentionally defensive and GUI-friendly:
%   - covariance-related fields are always created;
%   - unavailable quantities are represented by NaN arrays;
%   - diagnostic state is stored in Output.CovarianceStatus and
%     Output.CovarianceMessage;
%   - optional command-window printing is controlled by fitOptions.Debug or
%     fitOptions.VerboseCovariance.
%
% Added/updated Output fields
%   Output.CoefficientNames
%   Output.CovarianceMatrix
%   Output.CorrelationMatrix
%   Output.CoefficientSigma
%   Output.CovarianceStatus       'ok' | 'warning' | 'unavailable'
%   Output.CovarianceMessage
%   Output.CovarianceMSE
%   Output.JacobianRank
%   Output.JacobianCondition
%   Output.CovarianceMinEigenvalue
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Optional arguments
% -------------------------------------------------------------------------
if nargin < 4 || isempty(fitOptions)
    fitOptions = struct();
end

% -------------------------------------------------------------------------
% Coefficient names and default output initialization
% -------------------------------------------------------------------------
try
    coeffNames = coeffnames(FitObject);
catch
    coeffNames = {};
end

nCoeff = numel(coeffNames);

Output.CoefficientNames = coeffNames;
Output.CovarianceMatrix = NaN(nCoeff, nCoeff);
Output.CorrelationMatrix = NaN(nCoeff, nCoeff);
Output.CoefficientSigma = NaN(nCoeff, 1);
Output.CovarianceStatus = 'unavailable';
Output.CovarianceMessage = 'Covariance matrix not computed.';
Output.CovarianceMSE = NaN;
Output.JacobianRank = NaN;
Output.JacobianCondition = NaN;
Output.CovarianceMinEigenvalue = NaN;

verbose = localGetLogicalOption(fitOptions, 'VerboseCovariance', false) || ...
          localGetLogicalOption(fitOptions, 'Debug', false);

messages = {};
status = 'ok';

% -------------------------------------------------------------------------
% Basic availability checks
% -------------------------------------------------------------------------
if nCoeff == 0
    Output.CovarianceMessage = 'Coefficient names are unavailable.';
    localVerbosePrint(Output, verbose);
    return;
end

if ~isfield(Output, 'Jacobian') || isempty(Output.Jacobian)
    Output.CovarianceMessage = 'Jacobian is missing or empty.';
    localVerbosePrint(Output, verbose);
    return;
end

if ~isfield(GOF, 'dfe') || isempty(GOF.dfe) || ~isfinite(GOF.dfe) || GOF.dfe <= 0
    Output.CovarianceMessage = 'GOF.dfe is unavailable or <= 0.';
    localVerbosePrint(Output, verbose);
    return;
end

if ~isfield(GOF, 'sse') || isempty(GOF.sse) || ~isfinite(GOF.sse) || GOF.sse < 0
    Output.CovarianceMessage = 'GOF.sse is unavailable, non-finite, or negative.';
    localVerbosePrint(Output, verbose);
    return;
end

% -------------------------------------------------------------------------
% Jacobian checks
% -------------------------------------------------------------------------
J = Output.Jacobian;

if size(J, 2) ~= nCoeff
    Output.CovarianceMessage = sprintf( ...
        'Jacobian column count (%d) does not match number of coefficients (%d).', ...
        size(J, 2), nCoeff);
    localVerbosePrint(Output, verbose);
    return;
end

if any(~isfinite(J(:)))
    Output.CovarianceMessage = 'Jacobian contains non-finite values.';
    localVerbosePrint(Output, verbose);
    return;
end

JTJ = J' * J;
Output.JacobianRank = rank(J);

try
    Output.JacobianCondition = cond(JTJ);
catch
    Output.JacobianCondition = Inf;
end

if Output.JacobianRank < nCoeff
    status = 'warning';
    messages{end+1} = 'Jacobian is rank-deficient; covariance estimates may be unreliable.'; 
end

if ~isfinite(Output.JacobianCondition) || Output.JacobianCondition > 1e12
    status = 'warning';
    messages{end+1} = 'Jacobian normal matrix is ill-conditioned; covariance estimates may be unstable.'; 
end

% -------------------------------------------------------------------------
% Compute covariance matrix
% -------------------------------------------------------------------------
MSE = GOF.sse / GOF.dfe;
Output.CovarianceMSE = MSE;

CovMatrix = MSE * pinv(JTJ);
CovMatrix = (CovMatrix + CovMatrix') / 2; % enforce numerical symmetry

if any(~isfinite(CovMatrix(:)))
    Output.CovarianceMessage = 'Computed covariance matrix contains non-finite values.';
    localVerbosePrint(Output, verbose);
    return;
end

Output.CovarianceMatrix = CovMatrix;

% -------------------------------------------------------------------------
% Positive-semidefinite and diagonal checks
% -------------------------------------------------------------------------
try
    eigVals = eig(CovMatrix);
    minEig = min(real(eigVals));
catch
    eigVals = NaN; %#ok<NASGU>
    minEig = NaN;
end

Output.CovarianceMinEigenvalue = minEig;

covScale = max(1, max(abs(CovMatrix(:))));
tolCov = 1e-12 * covScale;

if isfinite(minEig) && minEig < -tolCov
    status = 'warning';
    messages{end+1} = 'Covariance matrix has a negative eigenvalue beyond numerical tolerance.'; 
end

diagCov = diag(CovMatrix);
diagScale = max(1, max(abs(diagCov)));
tolDiag = 1e-12 * diagScale;

if any(diagCov < -tolDiag)
    status = 'warning';
    messages{end+1} = 'Covariance diagonal contains negative values; coefficient sigma is unavailable.'; 
    Output.CoefficientSigma = NaN(nCoeff, 1);
    Output.CorrelationMatrix = NaN(nCoeff, nCoeff);
    Output.CovarianceStatus = status;
    Output.CovarianceMessage = localJoinMessages(messages, ...
        'Covariance matrix computed, but coefficient sigma/correlation are unavailable.');
    localVerbosePrint(Output, verbose);
    return;
end

% Clamp tiny negative values to zero, treating them as numerical noise.
diagCov(diagCov < 0 & diagCov >= -tolDiag) = 0;

CoeffSigma = sqrt(diagCov);
Output.CoefficientSigma = CoeffSigma(:);

if any(~isfinite(CoeffSigma)) || any(CoeffSigma < 0)
    status = 'warning';
    messages{end+1} = 'Coefficient sigma contains invalid values.'; 
    Output.CorrelationMatrix = NaN(nCoeff, nCoeff);
elseif any(CoeffSigma == 0)
    status = 'warning';
    messages{end+1} = 'At least one coefficient sigma is zero; correlation matrix is unavailable.'; 
    Output.CorrelationMatrix = NaN(nCoeff, nCoeff);
else
    CorrMatrix = CovMatrix ./ (CoeffSigma * CoeffSigma');
    CorrMatrix = (CorrMatrix + CorrMatrix') / 2;

    % Remove tiny numerical excursions outside [-1, 1]. Larger excursions
    % are preserved but flagged.
    corrTol = 1e-10;
    if any(CorrMatrix(:) > 1 + corrTol) || any(CorrMatrix(:) < -1 - corrTol)
        status = 'warning';
        messages{end+1} = 'Correlation matrix contains values outside [-1, 1] beyond numerical tolerance.'; 
    end
    CorrMatrix(CorrMatrix > 1 & CorrMatrix <= 1 + corrTol) = 1;
    CorrMatrix(CorrMatrix < -1 & CorrMatrix >= -1 - corrTol) = -1;

    Output.CorrelationMatrix = CorrMatrix;
end

% -------------------------------------------------------------------------
% Robust-fit diagnostic note
% -------------------------------------------------------------------------
if isfield(fitOptions, 'Robust')
    robustOption = fitOptions.Robust;
    if ischar(robustOption) || isstring(robustOption)
        if ~strcmpi(char(robustOption), 'off')
            status = 'warning';
            messages{end+1} = 'Robust fitting is enabled; covariance estimates should be interpreted as approximate.'; 
        end
    end
end

% -------------------------------------------------------------------------
% Final status/message
% -------------------------------------------------------------------------
Output.CovarianceStatus = status;
Output.CovarianceMessage = localJoinMessages(messages, ...
    'Covariance matrix computed from fit Jacobian.');

localVerbosePrint(Output, verbose);

end

% =========================================================================
% Local helper functions
% =========================================================================

function value = localGetLogicalOption(optionsStruct, fieldName, defaultValue)
value = defaultValue;
if isstruct(optionsStruct) && isfield(optionsStruct, fieldName)
    rawValue = optionsStruct.(fieldName);
    if islogical(rawValue) && isscalar(rawValue)
        value = rawValue;
    elseif isnumeric(rawValue) && isscalar(rawValue)
        value = rawValue ~= 0;
    elseif ischar(rawValue) || isstring(rawValue)
        value = any(strcmpi(char(rawValue), {'true', 'on', 'yes', '1'}));
    end
end
end

function message = localJoinMessages(messages, defaultMessage)
if isempty(messages)
    message = defaultMessage;
else
    message = strjoin(messages, ' ');
end
end

function localVerbosePrint(Output, verbose)
if ~verbose
    return;
end

fprintf('\n=== Fit covariance diagnostics ===\n');
fprintf('Status: %s\n', Output.CovarianceStatus);
fprintf('Message: %s\n', Output.CovarianceMessage);

coeffNames = Output.CoefficientNames;
if isempty(coeffNames)
    return;
end

try
    fprintf('\n=== Fit coefficient covariance matrix ===\n');
    disp(array2table(Output.CovarianceMatrix, ...
        'VariableNames', coeffNames, ...
        'RowNames', coeffNames));

    fprintf('\n=== Fit coefficient correlation matrix ===\n');
    disp(array2table(Output.CorrelationMatrix, ...
        'VariableNames', coeffNames, ...
        'RowNames', coeffNames));

    fprintf('\n=== Fit coefficient sigma from covariance matrix ===\n');
    disp(array2table(Output.CoefficientSigma(:)', ...
        'VariableNames', coeffNames));
catch
    fprintf('Unable to print covariance tables.\n');
end
end
