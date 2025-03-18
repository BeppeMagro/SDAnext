function rgb = ColorNameToRGB(colorName)
    % ColorNameToRGB - Converts a color name to its RGB triplet
    
    [colorNames, colorValues] = GetColorMap();

    % Convert the input color name to lowercase for case-insensitive matching
    colorName = lower(colorName);

    % Match the color name
    index = find(strcmpi(colorNames, colorName), 1);
    
    if ~isempty(index)
        rgb = colorValues(index, :);
    else
        error('Color "%s" is not recognized. Please provide a valid color name.', colorName);
    end
end
