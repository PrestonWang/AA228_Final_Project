% Helper function to get closest grid point
function [px, py] = closestNeighbor(x, y, stepSize, xLims, yLims)
x1 = fix(x/stepSize);
x2 = x1 + 1;
y1 = fix(y/stepSize);
y2 = y1 + 1;
% Validation to deal with storm running off the grid
if x >= xLims(2)
    x1 = fix(xLims(2)/stepSize);
    x2 = fix(xLims(2)/stepSize);
elseif x < xLims(1)
    x1 = fix(xLims(1)/stepSize);
    x2 = fix(xLims(1)/stepSize);
end
if y >= yLims(2)
    y1 = fix(yLims(2)/stepSize);
    y2 = fix(yLims(2)/stepSize);
elseif y < yLims(1)
    y1 = fix(yLims(1)/stepSize);
    y2 = fix(yLims(1)/stepSize);
end
neighborList = [x1, x1, x2, x2; y1, y2, y1, y2];
dist = zeros(4,1);
for i = 1:4
    dist(i) = sqrt((x-neighborList(1,i)*stepSize)^2 + (y-neighborList(2,i)*stepSize)^2);
end
[minDist, index] = min(dist);
px = neighborList(1,index);
py = neighborList(2,index);
end