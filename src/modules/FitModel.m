function [FitObject, GOF, Output] = FitModel(dataStruct, modelStruct, fitOptions)
% FitModel
% -------------------------------------------------------------------------
% Perform constrained nonlinear fitting for an SDAnext survival model.
%
% Inputs
%   dataStruct.x              Dose values
%   dataStruct.y              Survival fraction values
%   dataStruct.w              Fitting weights
%
%   modelStruct.FitFunction   Model function handle
%   modelStruct.Coefficients  Coefficient names
%
%   fitOptions.StartPoint     Initial parameter values
%   fitOptions.Lower          Lower parameter bounds
%   fitOptions.Upper          Upper parameter bounds
%   fitOptions.Algorithm      Fitting algorithm
%   fitOptions.Robust         Robust fitting option
%
% Output
%   FitObject                 MATLAB cfit object
%   GOF                       Goodness-of-fit structure returned by fit
%   Output                    Solver output enriched with covariance fields
%
% Notes
%   Covariance-related quantities are computed by ComputeFitCovariance.m
%   and are always attached to Output using stable field names:
%       Output.CovarianceMatrix
%       Output.CorrelationMatrix
%       Output.CoefficientSigma
%       Output.CoefficientNames
%       Output.CovarianceStatus
%       Output.CovarianceMessage
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Validate required input fields
% -------------------------------------------------------------------------
if ~isfield(dataStruct, 'x') || ~isfield(dataStruct, 'y') || ~isfield(dataStruct, 'w')
    error('dataStruct must contain x, y, and w fields.');
end

if ~isfield(modelStruct, 'FitFunction') || ~isfield(modelStruct, 'Coefficients')
    error('modelStruct must contain FitFunction and Coefficients.');
end

requiredFitOptionFields = {'StartPoint', 'Lower', 'Upper', 'Algorithm', 'Robust'};
for iField = 1:numel(requiredFitOptionFields)
    thisField = requiredFitOptionFields{iField};
    if ~isfield(fitOptions, thisField)
        error('fitOptions must contain the field ''%s''.', thisField);
    end
end

% -------------------------------------------------------------------------
% Extract data
% -------------------------------------------------------------------------
x = dataStruct.x;    % Dose
y = dataStruct.y;    % Survival fraction
w = dataStruct.w;    % Weights

% -------------------------------------------------------------------------
% Extract model definition
% -------------------------------------------------------------------------
FitFunction = modelStruct.FitFunction;
Coefficients = modelStruct.Coefficients;

% -------------------------------------------------------------------------
% Define fit type
% -------------------------------------------------------------------------
FitType = fittype( ...
    FitFunction, ...
    'independent', {'x'}, ...
    'dependent', {'y'}, ...
    'coefficients', Coefficients);

% -------------------------------------------------------------------------
% Set fit options
% -------------------------------------------------------------------------
FitOptions = fitoptions(FitType);
FitOptions.StartPoint = fitOptions.StartPoint;
FitOptions.Lower = fitOptions.Lower;
FitOptions.Upper = fitOptions.Upper;
FitOptions.Algorithm = fitOptions.Algorithm;
FitOptions.Display = 'notify';
FitOptions.Robust = fitOptions.Robust;
FitOptions.Weights = w;

% Solver exit flags returned by MATLAB fit output:
%   1  Function converged to a solution.
%   2  Change in x is less than tolerance, or Jacobian at x is undefined.
%   3  Change in residual is less than tolerance.
%   4  Relative magnitude of search direction is smaller than step tolerance.
%   0  Maximum iterations or function evaluations exceeded.
%  -1  Plot function or output function stopped the solver.
%  -2  No feasible point found or inconsistent bounds.

% -------------------------------------------------------------------------
% Perform fit and attach covariance diagnostics
% -------------------------------------------------------------------------
try
    % https://it.mathworks.com/help/curvefit/evaluating-goodness-of-fit.html
    [FitObject, GOF, Output] = fit(x, y, FitType, FitOptions);

    % Compute and attach covariance/correlation/sigma fields in a single
    % repo-aligned module. Fields are always initialized, even when the
    % covariance matrix is unavailable.
    Output = ComputeFitCovariance(FitObject, GOF, Output, fitOptions);

catch ME
    error('Error occurred during fitting: %s', ME.message);
end

end
