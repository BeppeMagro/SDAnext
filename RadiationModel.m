classdef RadiationModel
    methods(Static)
        % Linear model
        function SF = Lmodel(dose, alpha)
            d = dose;
            A = alpha;
            SF = exp(-A * d);
        end
        
        % Quadratic model
        function SF = Qmodel(dose, beta)
            d = dose;
            B = beta;
            SF = exp(-B * (d .^ 2));
        end
        
        % Linear-Quadratic model
        function SF = LQmodel(dose, alpha, beta)
            d = dose;
            A = alpha;
            B = beta;
            SF = exp(-A * d - B * (d .^ 2));
        end
        
        % Linear-Quadratic-Cubic model
        function SF = LQCmodel(dose, alpha, beta, gamma)
            d = dose;
            A = alpha;
            B = beta;
            C = gamma;
            SF = exp(-A * d - B * (d .^ 2) + C * (d .^ 3));
        end
        
        % Linear-Quadratic-Linear model with a dose threshold
        function SF = LQLmodel(dose, alpha, beta, doseTh)
            d = dose;
            A = alpha;
            B = beta;
            DT = doseTh;
            SF = zeros(size(d));
            idx_low = d < DT;
            idx_high = ~idx_low;
            SF(idx_low) = exp(-A * d(idx_low) - B * (d(idx_low) .^ 2));
            SF(idx_high) = exp(-A * DT - B * (DT ^ 2) - (A + 2 * B * DT) * (d(idx_high) - DT));
        end
    end
end