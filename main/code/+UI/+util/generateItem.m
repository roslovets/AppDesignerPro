function [newItem, idx] = generateItem(items, defaultItemName)
% Generate unique idx from text items
arguments
    items (:,1) string
    defaultItemName (1,1) string = "Item"
end
ns = regexp(items, '\d+', 'match', 'once');
nmax = max(str2double(ns));
if isempty(nmax) || ismissing(nmax)
    nmax = 0;
end
idx = nmax + 1;
if nargout > 1
    if nargin > 1 || isempty(items)
        itemName = defaultItemName;
    else
        if ~isempty(ns)
            itemsTxt = strtrim(erase(items, ns));
        else
            itemsTxt = items;
        end
        itemName = string(mode(categorical(itemsTxt)));
    end
    newItem = itemName + " " + idx;
end
