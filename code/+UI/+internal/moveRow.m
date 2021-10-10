function [data, idx1, idx2] = moveRow(data, idx1, dir)
% Move row in data from idx1 for step
if ~isempty(data)
    n = size(data, 1);
    if islogical(idx1)
        idx1 = find(idx1);
    end
    idx1 = idx1(:);
    if all(diff(idx1) == 1)
        idx2 = idx1 + sign(dir);
        idx2(idx2 < 1) = idx2(idx2 < 1) + n;
        idx2(idx2 > n) = idx2(idx2 > n) - n;
        if dir < 0
            if any((idx1-idx2) < 0)
                data = data([(idx1(end)+1 : end)'; idx1], :);
            else
                data([idx2; idx1(end)], :) = data([idx1; idx2(1)], :);
            end
        elseif dir > 0
            if any((idx2-idx1) < 0)
                data = data([idx1; (1 : idx1(1)-1)'], :);
            else
                data([idx2; idx1(1)], :) = data([idx1; idx2(end)], :);
            end
        end
    else
        warning("Items moving works only with sequencies");
    end
end