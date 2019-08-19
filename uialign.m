function pos = uialign(objects, refobj, horalign, varargin)
%ALIGN Align uicontrols and axes.
%   ALIGN(HandleList,HorizontalAlignment,VerticalAlignment) will
%   align the objects in the handle list. Adding a left hand argument
%   will cause the updated positions of the objects to be returned while
%   the position of the objects on the figure does not change.
%   Calling the alignment tool with
%   Positions=ALIGN(CurPositions,HorizontalAlignment,VerticalAlignment)
%   will return the updated position matrix from the initial position
%   matrix.
%
%   Possible values for HorizontalAlignment are:
%     None, Left, Center, Right, Distribute, Fixed
%
%   Possible values for VerticalAlignment are:
%     None, Top, Middle, Bottom, Distribute, Fixed
%
%   All alignment options will align the objects within the
%   bounding box that encloses the objects.  Distribute and Fixed
%   will align objects to the bottom left of the bounding box. Distribute,
%   evenly distributes the objects, while Fixed distributes the objects
%   with a fixed distance (in points) between them.
%
%   If Fixed is used for HorizontalAlignment or VerticalAlignment, then
%   the distance must be passed in as an extra argument:
%   
%   ALIGN(HandleList,'Fixed',Distance,VerticalAlignment)
%   ALIGN(HandleList,HorizontalAlignment,'Fixed',Distance)
%   ALIGN(HandleList,'Fixed',HorizontalDistance,'Fixed',VerticalDistance)
%
%   Example:
%       f=figure;
%       u1 = uicontrol('Style','push', 'parent', f,'pos',...
%           [20 100 100 100],'string','button1');
%       u2 = uicontrol('Style','push', 'parent', f,'pos',...
%           [150 250 100 100],'string','button2');
%       u3 = uicontrol('Style','push', 'parent', f,'pos',...
%           [250 100 100 100],'string','button3');
%       hlist2 = [u1 u2 u3];   
%       align(hlist2,'distribute','bottom');

p = inputParser();
p.addRequired('objects');
p.addRequired('refobj');
p.addRequired('horalign');
p.addOptional('vertalign', '', @(x)ischar(x)||isstring(x));
p.addOptional('ischild', false);
p.addOptional('offset', [0 0]);
p.addParameter('HorDist', 'none');
p.addParameter('VertDist', 'none');
p.parse(objects, refobj, horalign, varargin{:});
args = p.Results;

if isgraphics(args.refobj)
    refpos = get(args.refobj, 'Position');
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
alignlist = ["left" "center" "right" "same" "fill"
             "bottom" "center" "top" "same" "fill"];
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
            case 5
                sumpos = sum(pos(:, 3));
                num = size(pos, 1);
                if num > 1
                    gap = floor((refpos(3) - sumpos) / (num-1));
                else
                    gap = 0;
                end
                ws = [0; pos(1:end-1, 3) + gap];
                pos(:, 1) = refpos(1) + cumsum(ws);
        end
    end
end