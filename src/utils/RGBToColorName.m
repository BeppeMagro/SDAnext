function colorName = RGBToColorName(rgb)
    % RGBToColorName - Finds the closest named color for an RGB triplet.

    [colorNames, colorValues] = GetColorMap();

    % Compute the Euclidean distance between input RGB and all stored colors
    distances = sqrt(sum((colorValues - rgb).^2, 2));

    % Find the closest matching color
    [~, idx] = min(distances);
    colorName = colorNames{idx};
end
