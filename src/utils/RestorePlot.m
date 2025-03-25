function RestorePlot(axesHandle, plotData, titleText, isMultiSession)
% RestorePlot - Recreates saved plot elements with full style control.

    if ~isMultiSession
        cla(axesHandle);  % Clear only in single-session mode
        title(axesHandle, titleText);
    end

    hold(axesHandle, 'on');
    excludeLabels = GetModelsMap();

    if isMultiSession
        existingPlots = findall(axesHandle, 'Type', 'line', '-or', 'Type', 'errorbar');
        allXData = get(existingPlots, 'XData');
        allYData = get(existingPlots, 'YData');

        if ~iscell(allXData), allXData = {allXData}; end
        if ~iscell(allYData), allYData = {allYData}; end

        allXData = allXData(~cellfun(@isempty, allXData));
        allYData = allYData(~cellfun(@isempty, allYData));

        allXData = cellfun(@(x) x(:), allXData, 'UniformOutput', false);
        allYData = cellfun(@(y) y(:), allYData, 'UniformOutput', false);

        xMax = -Inf; yMin = Inf;
        if ~isempty(allXData)
            xMax = max(vertcat(allXData{:}), [], 'omitnan');
        end
        if ~isempty(allYData)
            yMin = min(vertcat(allYData{:}), [], 'omitnan');
        end
    else
        xMax = -Inf; yMin = Inf;
    end

    for i = 1:numel(plotData)
        switch plotData(i).Type
            case 'Line'
                % Use safe fallback getters
                lineStyle = GetFieldSafely(plotData(i), 'LineStyle', '-');
                marker = GetFieldSafely(plotData(i), 'Marker', 'o');

                plotObj = plot(axesHandle, plotData(i).XData, plotData(i).YData, ...
                    'Color', [plotData(i).Color 0.3], ...
                    'LineStyle', lineStyle, ...
                    'LineWidth', plotData(i).LineWidth, ...
                    'Marker', marker, ...
                    'MarkerSize', plotData(i).MarkerSize, ...
                    'MarkerFaceColor', plotData(i).MarkerFaceColor, ...
                    'Tag', plotData(i).Tag);

                if isfield(plotData, 'DisplayName')
                    plotObj.DisplayName = plotData(i).DisplayName;
                    if isMultiSession && any(strcmp(plotData(i).DisplayName, excludeLabels))
                        plotObj.Annotation.LegendInformation.IconDisplayStyle = 'off';
                    end
                end

                xMax = max(xMax, max(plotData(i).XData));
                yMin = min(yMin, min(plotData(i).YData));

            case 'ErrorBar'
                lineStyle = GetFieldSafely(plotData(i), 'LineStyle', '-');
                marker = GetFieldSafely(plotData(i), 'Marker', 'o');

                plotObj = errorbar(axesHandle, plotData(i).XData, plotData(i).YData, ...
                    plotData(i).YNegativeDelta, plotData(i).YPositiveDelta, ...
                    plotData(i).XNegativeDelta, plotData(i).XPositiveDelta, ...
                    'Color', plotData(i).Color, ...
                    'LineStyle', lineStyle, ...
                    'LineWidth', plotData(i).LineWidth, ...
                    'Marker', marker, ...
                    'MarkerSize', plotData(i).MarkerSize, ...
                    'MarkerFaceColor', plotData(i).MarkerFaceColor, ...
                    'CapSize', plotData(i).CapSize, ...
                    'Tag', plotData(i).Tag);

                if isfield(plotData, 'DisplayName')
                    plotObj.DisplayName = plotData(i).DisplayName;
                    if isMultiSession && any(strcmp(plotData(i).DisplayName, excludeLabels))
                        plotObj.Annotation.LegendInformation.IconDisplayStyle = 'off';
                    end
                end

                xMax = max(xMax, max(plotData(i).XData));
                yMin = min(yMin, min(plotData(i).YData));

            case 'Text'
                text(axesHandle, ...
                    0.5, 0.5, ...
                    plotData(i).String, ...
                    'Units', plotData(i).Units, ...
                    'HorizontalAlignment', plotData(i).HorizontalAlignment, ...
                    'VerticalAlignment', plotData(i).VerticalAlignment, ...
                    'FontName', plotData(i).FontName, ...
                    'FontSize', plotData(i).FontSize, ...
                    'FontWeight', plotData(i).FontWeight, ...
                    'Color', [plotData(i).Color 0.3], ...
                    'Rotation', plotData(i).Rotation, ...
                    'Tag', 'Watermark');

            otherwise
                fprintf('Unsupported plot type: %s\n', plotData(i).Type);
        end
    end

    axesHandle.XLim = [0, xMax * 1.05];
    axesHandle.YLim = [yMin * 0.8, 1];

    axesHandle.YAxis.Scale = 'log';
    axesHandle.YAxis.TickLabelFormat = '%3.1f';
    axesHandle.YAxis.TickValues = 0.1:0.1:1;
    axesHandle.XLabel.String = 'Dose [Gy]';
    axesHandle.YLabel.String = 'Survival fraction';
    axesHandle.FontName = 'Franklin Gothic Book';
    axesHandle.FontWeight = 'bold';
    axesHandle.XMinorTick = 'on';
    axesHandle.YMinorTick = 'on';
    axesHandle.XAxis.LineWidth = 1.5;
    axesHandle.YAxis.LineWidth = 1.5;

    leg = legend(axesHandle, 'Location', 'northeast', 'FontSize', 14);
    leg.Box = 'off';
end
