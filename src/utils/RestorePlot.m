% Function to restore the plot from saved data
function RestorePlot(axesHandle, plotData, titleText, isMultiSession)
% Clear existing plot, set the title and hold on to add multiple plots

if ~isMultiSession
    cla(axesHandle);  % Clear the existing plot only in single-session mode
    title(axesHandle, titleText); % Update title only in single-session mode
end

hold(axesHandle, 'on');

% Define labels to exclude from the legend
excludeLabels = GetModelsMap();

% Initialize min/max values
if isMultiSession
    % Get all existing line and errorbar plots in the axes
    existingPlots = findall(axesHandle, 'Type', 'line', '-or', 'Type', 'errorbar');

    % Extract XData and YData safely
    allXData = get(existingPlots, 'XData');
    allYData = get(existingPlots, 'YData');

    % Ensure data is always in cell array form
    if ~iscell(allXData), allXData = {allXData}; end
    if ~iscell(allYData), allYData = {allYData}; end

    % Remove empty entries
    allXData = allXData(~cellfun(@isempty, allXData));
    allYData = allYData(~cellfun(@isempty, allYData));

    % Convert all data to column vectors
    allXData = cellfun(@(x) x(:), allXData, 'UniformOutput', false);
    allYData = cellfun(@(y) y(:), allYData, 'UniformOutput', false);

    % Concatenate all extracted data
    if ~isempty(allXData)
        allXData = vertcat(allXData{:});
        xMax = max(allXData, [], 'omitnan');
    else
        xMax = -Inf;  % Default if no data exists
    end
    if ~isempty(allYData)
        allYData = vertcat(allYData{:});
        yMin = min(allYData, [], 'omitnan');
    else
        yMin = Inf;  % Default if no data exists
    end
else
    % If single session, reset xMax and yMin for this session
    xMax = -Inf;
    yMin = Inf;
end

% Recreate each plot object based on saved data
for i = 1:numel(plotData)
    switch plotData(i).Type
        case 'Line'
            % Recreate a line plot
            plotObj = plot(axesHandle, plotData(i).XData, plotData(i).YData, ...
                'Color', [plotData(i).Color 0.3], ...
                'LineStyle', plotData(i).LineStyle, ...
                'LineWidth', plotData(i).LineWidth, ...
                'Marker', plotData(i).Marker, ...
                'MarkerSize', plotData(i).MarkerSize, ...
                'MarkerFaceColor', plotData(i).MarkerFaceColor, ...
                'Tag', plotData(i).Tag);

            % Set DisplayName if it exists
            if isfield(plotData, 'DisplayName')
                plotObj.DisplayName = plotData(i).DisplayName;

                if isMultiSession && any(strcmp(plotData(i).DisplayName, excludeLabels))
                    plotObj.Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
            end

            % Update global min/max values for X and Y
            xMax = max(xMax, max(plotData(i).XData));
            yMin = min(yMin, min(plotData(i).YData));

        case 'ErrorBar'
            % Recreate an error bar plot
            plotObj = errorbar(axesHandle, plotData(i).XData, plotData(i).YData, ...
                plotData(i).YNegativeDelta, plotData(i).YPositiveDelta, ...
                plotData(i).XNegativeDelta, plotData(i).XPositiveDelta, ...
                'Color', [plotData(i).Color], ...
                'LineStyle', plotData(i).LineStyle, ...
                'LineWidth', plotData(i).LineWidth, ...
                'Marker', plotData(i).Marker, ...
                'MarkerSize', plotData(i).MarkerSize, ...
                'MarkerFaceColor', plotData(i).MarkerFaceColor, ...
                'CapSize', plotData(i).CapSize, ...
                'Tag', plotData(i).Tag);

            % Set DisplayName if it exists
            if isfield(plotData, 'DisplayName')
                plotObj.DisplayName = plotData(i).DisplayName;

                if isMultiSession && any(strcmp(plotData(i).DisplayName, excludeLabels))
                    plotObj.Annotation.LegendInformation.IconDisplayStyle = 'off';
                end
            end

            % Update global min/max values for X and Y
            xMax = max(xMax, max(plotData(i).XData));
            yMin = min(yMin, min(plotData(i).YData));

        case 'Text'
            % Recreate a watermark
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

% Set the X and Y limits based on the global min/max values
axesHandle.XLim = [0, xMax * 1.05]; % 5% padding on the right
axesHandle.YLim = [yMin * 0.8, 1]; % 80% padding on the bottom

% Customize the axes
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

% Add legend in the top-right corner with the box off
leg = legend(axesHandle, 'Location', 'northeast','FontSize', 14);
leg.Box = 'off';

end
