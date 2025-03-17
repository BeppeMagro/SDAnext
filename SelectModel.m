function modelStruct = SelectModel(modelName)
% Select the appropriate model based on the input modelName and organize
% output variables into a single struct

switch modelName
    case 'L'
        modelStruct.Coefficients = {'alpha'};
        modelStruct.StartPoint = 0.1;
        modelStruct.Lower = 0;
        modelStruct.Upper = 10;
        modelStruct.DisplayName = 'L';
        modelStruct.ModelName = 'Linear (L)';
        modelStruct.FitFunction = @(alpha, x) RadiationModel.Lmodel(x, alpha);

    case 'Q'
        modelStruct.Coefficients = {'beta'};
        modelStruct.StartPoint = 0.05;
        modelStruct.Lower = 0;
        modelStruct.Upper = 10;
        modelStruct.DisplayName = 'Q';
        modelStruct.ModelName = 'Quadratic (Q)';
        modelStruct.FitFunction = @(beta, x) RadiationModel.Qmodel(x, beta);

    case 'LQ'
        modelStruct.Coefficients = {'alpha', 'beta'};
        modelStruct.StartPoint = [0.1, 0.05];
        modelStruct.Lower = [0, 0];
        modelStruct.Upper = [10, 10];
        modelStruct.DisplayName = 'LQ';
        modelStruct.ModelName = 'Linear-Quadratic (LQ)';
        modelStruct.FitFunction = @(alpha, beta, x) RadiationModel.LQmodel(x, alpha, beta);

    case 'LQC'
        modelStruct.Coefficients = {'alpha', 'beta', 'gamma'};
        modelStruct.StartPoint = [0.1, 0.05, 0.001];
        modelStruct.Lower = [0, 0, 0];
        modelStruct.Upper = [10, 10, 100];
        modelStruct.DisplayName = 'LQC';
        modelStruct.ModelName = 'Linear-Quadratic-Cubic (LQC)';
        modelStruct.FitFunction = @(alpha, beta, gamma, x) RadiationModel.LQCmodel(x, alpha, beta, gamma);

    case 'LQL'
        modelStruct.Coefficients = {'alpha', 'beta', 'doseTh'};
        modelStruct.StartPoint = [0.1, 0.05, 0];
        modelStruct.Lower = [0, 0, 0];
        modelStruct.Upper = [10, 10, 50];
        modelStruct.DisplayName = 'LQL';
        modelStruct.ModelName = 'Linear-Quadratic-Linear (LQL)';
        modelStruct.FitFunction = @(alpha, beta, doseTh, x) RadiationModel.LQLmodel(x, alpha, beta, doseTh);

    otherwise
        error('Invalid model name');
end
end