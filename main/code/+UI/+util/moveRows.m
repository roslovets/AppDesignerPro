function [data, idx, idxNew] = moveRows(data, idx, dir)
%% Move rows in data in specified direction
arguments
    data % Data to process
    idx double % Roms indices
    dir double {mustBeMember(dir,[-1,1])} = 1 % Direction: 1 - down, -1 - up
end
if ~isempty(data)
    n = height(data);
    idx = idx(:);
    idxNew = idx + sign(dir);
    idxNew(idxNew < 1) = idxNew(idxNew < 1) + n;
    idxNew(idxNew > n) = idxNew(idxNew > n) - n;
    if dir > 0
        [~, iSort] = sort(idx, 1, "descend");
    else
        [~, iSort] = sort(idx, 1, "ascend");
    end
    idxSort = idx(iSort);
    idxNewSort = idxNew(iSort);
    for i = 1 : length(idxSort)
        idxi = idxSort(i);
        idxNewi = idxNewSort(i);
        if dir < 0
            if idxNewi <= idxi
                data([idxi; idxNewi], :) = data([idxNewi; idxi], :);
            else
                data = data([(idxi+1 : end)'; idxi], :);
                break;
            end
        elseif dir > 0
            if idxi <= idxNewi
                data([idxi; idxNewi], :) = data([idxNewi; idxi], :);
            else
                data = data([idxi; (1 : idxi-1)'], :);
                break;
            end
        end
    end
end
