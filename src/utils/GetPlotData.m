function [plotData, titleText] = GetPlotData(axesHandle)
% Retrieve the title text
titleText = axesHandle.Title.String;

% Get all children of the axes
children = axesHandle.Children;

% Initialize storage for plot data
plotData = struct();

% Iterate over all child objects (e.g., lines, scatter, etc.)
for i = 1:numel(children)
    child = children(i);
    if isa(child, 'matlab.graphics.chart.primitive.Line')
        plotData(i).Type = 'Line';
        plotData(i).DisplayName = child.DisplayName;
        plotData(i).Color = child.Color;
        plotData(i).LineStyle = child.LineStyle;
        plotData(i).LineWidth = child.LineWidth;
        plotData(i).Marker = child.Marker;
        plotData(i).MarkerSize = child.MarkerSize;
        plotData(i).MarkerFaceColor = child.MarkerFaceColor;
        plotData(i).XData = child.XData;
        plotData(i).YData = child.YData;
        plotData(i).Source = titleText;
        plotData(i).Tag = strcat(titleText, child.DisplayName);
    elseif isa(child, 'matlab.graphics.chart.primitive.ErrorBar')
        plotData(i).Type = 'ErrorBar';
        plotData(i).DisplayName = child.DisplayName;
        plotData(i).Color = child.Color;
        plotData(i).LineStyle = child.LineStyle;
        plotData(i).LineWidth = child.LineWidth;
        plotData(i).Marker = child.Marker;
        plotData(i).MarkerSize = child.MarkerSize;
        plotData(i).MarkerFaceColor = child.MarkerFaceColor;
        plotData(i).XData = child.XData;
        plotData(i).YData = child.YData;
        plotData(i).XNegativeDelta = child.XNegativeDelta;
        plotData(i).XPositiveDelta = child.XPositiveDelta;
        plotData(i).YNegativeDelta = child.YNegativeDelta;
        plotData(i).YPositiveDelta = child.YPositiveDelta;
        plotData(i).CapSize = child.CapSize;
        plotData(i).Source = titleText;
        plotData(i).Tag = strcat(titleText, child.DisplayName);
    elseif isa(child, 'matlab.graphics.primitive.Text')
        plotData(i).Type = 'Text';
        plotData(i).String = child.String;
        plotData(i).FontSize = child.FontSize;
        plotData(i).FontWeight = child.FontWeight;
        plotData(i).FontName = child.FontName;
        plotData(i).Color = child.Color;
        plotData(i).HorizontalAlignment = child.HorizontalAlignment;
        plotData(i).VerticalAlignment = child.VerticalAlignment;
        plotData(i).Position = child.Position;
        plotData(i).Units = child.Units;
        plotData(i).Rotation = child.Rotation;
    else
        plotData(i).Type = 'Unsupported';
    end
end

end