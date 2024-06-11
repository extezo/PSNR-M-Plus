function [wp, y_roi, x_roi] = createPeriphericalWeights(y, ROI)

[x,y ] = meshgrid(1:size(y,2),1:size(y,1));

x_roi = x(ROI);
y_roi = y(ROI);
x_roi = mean(x_roi);
y_roi = mean(y_roi);

x = x - x_roi;
y = y - y_roi;
a = atan(pi * sqrt(x.^2 + y.^2) / 10800);
wp = nColbs(a);