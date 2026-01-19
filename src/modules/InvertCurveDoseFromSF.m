function doseIso = InvertCurveDoseFromSF(doseVec, sfVec, sfQuery)
    % Given a curve (doseVec, sfVec), return isoeffective dose for sfQuery.
    % Works even if sfVec is decreasing by sorting on SF.

    % Require SF within (0,1] typically; out of range -> NaN
    doseVec = doseVec(:);
    sfVec   = sfVec(:);

    % Sort by SF ascending for interp1 stability
    [sfSorted, idx] = sort(sfVec, 'ascend');
    doseSorted = doseVec(idx);

    doseIso = InterpMonotoneSafe(sfSorted, doseSorted, sfQuery);
end