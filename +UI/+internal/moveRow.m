function [data, idx1, idx2] = moveRow(data, idx1, step)
% Move row in data from idx1 for step
n = size(data, 1);
if islogical(idx1)
    idx1 = find(idx1);
end
idx1 = idx1(1);
idx2 = idx1 + step;
if idx2 < 1
    idx2 = n;
elseif idx2 > n
    idx2 = 1;
end
if idx1 == 1 && idx2 == n
    data = data([2 : end, 1], :);
elseif idx1 == n && idx2 == 1
    data = data([end, 1 : end-1], :);
else
    data([idx1 idx2], :) = data([idx2 idx1], :);
end