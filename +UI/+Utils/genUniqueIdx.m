function [idx, newitem] = genUniqueIdx(items, defname)
% Generate unique idx from text items
if nargin < 2
    defname = "Item";
end
items = string(items);
ns = regexp(items, '\d+', 'match');
ns = vertcat(ns{:});
nmax = max(double(string(ns)));
if isempty(nmax)
    nmax = 0;
end
idx = nmax + 1;
if nargout > 1
    if nargin > 1 || isempty(items)
        itemname = defname;
    else
        if ~isempty(ns)
            itemstxt = strtrim(erase(items, ns));
        else
            itemstxt = items;
        end
        itemname = string(mode(categorical(itemstxt)));
    end
    newitem = itemname + " " + idx;
end