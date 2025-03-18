function dose = InvertFitObject(FitObject, sf)
% Invert FitObject to find Dose for a given SF
try
    dose = fzero(@(dose) feval(FitObject, dose) - sf, 0); % Solve for dose
catch
    error('Unable to invert FitObject for SF value: %f', sf);
end
end