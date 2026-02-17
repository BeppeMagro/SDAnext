function yq = InterpMonotoneSafe(x, y, xq)
    % Sort by x and remove duplicates for interp1 stability
    x = x(:); y = y(:);
    [xs, idx] = sort(x, 'ascend');
    ys = y(idx);

    % Remove duplicates in xs (keep first occurrence)
    [xsU, ia] = unique(xs, 'stable');
    ysU = ys(ia);

    if numel(xsU) < 2
        yq = NaN(size(xq));
        return;
    end

    yq = interp1(xsU, ysU, xq, 'pchip', NaN);
end