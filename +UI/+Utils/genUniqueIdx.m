function [idx, newitem] = genUniqueIdx(items)
% Generate unique idx from text items
items = string(items);
ns = regexp(items, '\d+', 'match');
ns = vertcat(ns{:});
nmax = max(double(string(ns)));
if isempty(nmax)
    nmax = 0;
end
idx = nmax + 1;
if nargout > 1
    if isempty(items)
        itemstxt = "Item";
    else
        if ~isempty(ns)
            itemstxt = strtrim(erase(items, ns));
        else
            itemstxt = items;
        end
    end
    newitem = string(mode(categorical(itemstxt))) + " " + idx;
end