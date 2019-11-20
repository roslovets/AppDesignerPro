function pos = uialign(objects, refobj, horalign, varargin)
%UIALIGN Align uicontrols and uifigures.
%
%   UIALIGN(HandleList, HandleRef, HorAlignment)
%   UIALIGN(HandleList, HandleRef, HorAlignment, VertAlignment)
%   UIALIGN(__, isChild)
%   UIALIGN(__, isChild, offset)
%   UIALIGN(__, Name, Value)
%   Positions = UIALIGN(__)
%   Positions = UIALIGN(CurPositions, RefPosition, __)
%
%   UIALIGN(HandleList, HandleRef, HorAlignment, VertAlignment) will
%   align the objects in the handle list to the reference object.
%
%   Positions = UIALIGN(HandleList, HandleRef, HorAlignment, VertAlignment)
%   will also return new positions of HandleList objects
%
%   Also you can pass positions insted of object handles just for
%   calculation of new positions
%   Positions = UIALIGN(CurPositions, RefPosition, HorAlignment, VertAlignment)
%
%   Possible values for HorAlignment are:
%     '', 'left', 'center', 'right', 'same'
%
%   Possible values for VertAlignment are:
%     '', 'bottom', 'center', 'top', 'same'
%
%   If you specify isChild (default: false) as true objects will be positioned inside
%   reference object
%   UIALIGN(__, true)
%
%   Uptionally you can shift calculated positions for offset (default: [0 0]), i.e.
%   UIALIGN(__, true, [5 10])
%
%   If you want to distribute objects horizontally use 'HorDist' parameter,
%   if you want to distribute objects vertically use 'VertDist' parameter
%   Valid values for 'HorDist' and 'VertDist':
%       pixels (numeric scalar), 'auto', 'none' (defalut)
%
%   If you want to distribute objects in scrollable parent specify
%   'Scrollable' parameter as true
%
%   Author: Pavel Roslovets, ETMC Exponenta
%           https://roslovets.github.io
%
%   Example:
%       f=figure;
%       u1 = uicontrol('Style','push', 'parent', f,'pos',...
%           [20 100 100 100],'string','button1');
%       u2 = uicontrol('Style','push', 'parent', f,'pos',...
%           [150 250 100 100],'string','button2');
%       u3 = uicontrol('Style','push', 'parent', f,'pos',...
%           [250 100 100 100],'string','button3');
%       uialign([u1 u2], u3, '', 'bottom');
%       uialign([u1 u2], u3, '', 'bottom', false, [50 0]);
%       uialign([u1 u2 u3], f, 'center', 'center', true, 'HorDist', 5);
%       uialign([u1 u2 u3], f, 'center', 'bottom', true, 'HorDist', 'auto');
%
%   Example app: uialignExample

p = inputParser();
p.addRequired('objects');
p.addRequired('refobj');
p.addRequired('horalign');
p.addOptional('vertalign', '', @(x)ischar(x)||isstring(x));
p.addOptional('ischild', false);
p.addOptional('offset', [0 0]);
p.addParameter('HorDist', 'none');
p.addParameter('VertDist', 'none');
p.addParameter('Scrollable', false);
p.parse(objects, refobj, horalign, varargin{:});
args = p.Results;

scrollable = args.Scrollable;
if isgraphics(args.refobj)
    refpos = get(args.refobj, 'Position');
    if isprop(args.refobj, 'Scrollable') && ismember('Scrollable', p.UsingDefaults)
        scrollable = get(args.refobj, 'Scrollable') == "on";
    end
else
    refpos = args.refobj;
end
if args.ischild
    refpos = [0 0 refpos([3 4])];
end
if ~isempty(args.objects) & all(ishghandle(args.objects)) %#ok<AND2>
    setpos = true;
    pos = get(args.objects, {'Position'});
else
    setpos = false;
    pos = args.objects;
end
if iscell(pos)
    pos = vertcat(pos{:});
end
[hpos, isdist] = calcDist(pos, refpos, 1, args);
if ~isdist
    hpos = calcPos(pos, refpos, 1, args.horalign);
end
[vpos, isdist] = calcDist(pos, refpos, 2, args);
if ~isdist
    vpos = calcPos(pos, refpos, 2, args.vertalign);
end
pos = [hpos(:,1) vpos(:,2) hpos(:,3) vpos(:,4)];
pos(:, [1 2]) = pos(:, [1 2]) + args.offset;
if args.ischild && scrollable && size(pos, 1) > 1
    if pos(1, 1) < 0
        pos(:, 1) = pos(:, 1) - pos(1, 1) + 1;
    end
    if pos(1, 2) < 0
        pos(:, 2) = pos(:, 2) - pos(1, 2) + 1;
    end
end
if setpos
    set(args.objects, {'Position'}, num2cell(pos, 2));
end

function [pos, isdist] = calcDist(pos, refpos, dim, args)
%% Calculate distribution
if size(pos, 1) > 1
    isdist = true;
else
    isdist = false;
end
if isdist
    if dim == 1
        dist = args.HorDist;
    elseif dim == 2
        dist = args.VertDist;
    end
    if ~isnumeric(dist)
        switch dist
            case "none"
                isdist = false;
            case "auto"
                dist = floor((refpos(dim+2) - sum(pos(:, dim+2))) / (size(pos, 1)-1));
        end
    end
    if isdist
        ps = [0; pos(1:end-1, dim+2) + dist];
        pos(:, dim) = refpos(dim) + cumsum(ps);
        gpos = [pos(1, [1 2]), pos(end, [1 2]) + pos(end, [3 4]) - pos(1, [1 2])];
        gpos1 = uialign(gpos, refpos, args.horalign, args.vertalign, true);
        posd = gpos1 - gpos;
        pos(:, [1 2]) = pos(:, [1 2]) + posd([1 2]);
    end
end

function pos = calcPos(pos, refpos, dim, alignment)
%% Calculate aligned positions
alignment = lower(char(alignment));
alignlist = ["left" "center" "right" "same"
             "bottom" "center" "top" "same"];
dimlist = ["Horizontal" "Vertical"];
if ~isempty(alignment)
    alnum = find(alignlist(dim, :) == alignment);
    if isempty(alnum)
        error('MATLAB:uialign:UnsupportedAlign',...
            '%s align is unsupported: %s. Use one of the: %s',...
            dimlist(dim), alignment, join(alignlist(dim, :), '|'));
    else
        switch alnum
            case 1
                pos(:,dim) = refpos(1,dim);
            case 2
                pos(:,dim) = refpos(1,dim) + (refpos(1,dim+2) - pos(:,dim+2))/2;
            case 3
                pos(:,dim) = refpos(1,dim) + (refpos(1,dim+2) - pos(:,dim+2));
            case 4
                pos(:, dim+[0 2]) = repmat(refpos(:, dim+[0 2]), size(pos, 1), 1);
        end
    end
end