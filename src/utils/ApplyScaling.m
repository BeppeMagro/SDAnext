function ApplyScaling(axesHandle, plotData, scaleFactor)
    if isempty(plotData)
        return;
    end
    ax = axesHandle;
    for i = 1:numel(plotData)
        pd = plotData(i);
        obj = findobj(ax, 'DisplayName', pd.DisplayName, 'Type', pd.Type);
        if isempty(obj), continue; end
        if isprop(obj, 'LineWidth')
            obj.LineWidth = pd.LineWidth * scaleFactor;
        end
        if isprop(obj, 'MarkerSize')
            obj.MarkerSize = pd.MarkerSize * scaleFactor;
        end
    end
end