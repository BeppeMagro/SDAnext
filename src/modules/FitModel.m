function [FitObject, GOF, Output] = FitModel(dataStruct, modelStruct, fitOptions)
% Ensure required fields exist in the dataStruct and modelStruct
if ~isfield(dataStruct, 'x') || ~isfield(dataStruct, 'y') || ~isfield(dataStruct, 'w')
    error('dataStruct must contain x, y, and w fields.');
end

if ~isfield(modelStruct, 'FitFunction') || ~isfield(modelStruct, 'Coefficients')
    error('modelStruct must contain FitFunction and Coefficients.');
end

% Extract data from the dataStruct
x = dataStruct.x; % Dose (x values)
y = dataStruct.y; % Survival Fraction (y values)
w = dataStruct.w; % Weights (w values)

% Extract model parameters from the modelStruct
FitFunction = modelStruct.FitFunction;
Coefficients = modelStruct.Coefficients;

% Define the fit type using the provided fit function
FitType = fittype(FitFunction, 'independent', {'x'}, 'dependent', {'y'}, 'coefficients', Coefficients);

% Set up fit options
FitOptions = fitoptions(FitType);
FitOptions.StartPoint = fitOptions.StartPoint;
FitOptions.Lower = fitOptions.Lower;
FitOptions.Upper = fitOptions.Upper;
FitOptions.Algorithm = fitOptions.Algorithm;
FitOptions.Display = 'notify';
FitOptions.Robust = fitOptions.Robust;
FitOptions.Weights = w;

% Reason the solver stopped, returned as an integer.
% 1 : Function converged to a solution x.
% 2 : Change in x is less than the specified tolerance, or Jacobian at x is undefined.
% 3 : Change in the residual is less than the specified tolerance.
% 4 : Relative magnitude of search direction is smaller than the step tolerance.
% 0 : Number of iterations exceeds options.MaxIterations or number of function evaluations exceeded options.MaxFunctionEvaluations.
% -1 : A plot function or output function stopped the solver.
% -2 : No feasible point found. The bounds lb and ub are inconsistent, or the solver stopped at an infeasible point.

% Perform the fitting
try
    % https://it.mathworks.com/help/curvefit/evaluating-goodness-of-fit.html#bs1cn8o
    [FitObject, GOF, Output] = fit(x, y, FitType, FitOptions);

catch ME
    % Handle fitting errors
    error('Error occurred during fitting: %s', ME.message);

end

end
