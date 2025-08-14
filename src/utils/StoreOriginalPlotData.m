function plotData = StoreOriginalPlotData(axesHandle)
    [allData, ~] = GetPlotData(axesHandle);

    if isempty(allData) || ~isstruct(allData)
        plotData = struct([]);
        return;
    end

    supportedTypes = {'Line', 'ErrorBar'};
    plotData = allData(ismember({allData.Type}, supportedTypes));
end