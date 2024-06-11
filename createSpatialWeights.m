function ws = createSpatialWeights(y, h)
    y_f = imfilter(y, h,'replicate');
    ws = y_f ./ y;
    ws(y == 0) = 1;
end

