function value = GetFieldSafely(structData, fieldName, defaultValue)
% Helper function to safely retrieve a field with a default value
    if isfield(structData, fieldName) && ~isempty(structData.(fieldName))
        value = structData.(fieldName);
    else
        value = defaultValue;
    end
end