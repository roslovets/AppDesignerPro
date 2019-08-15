function pos = uialign(objects, refobj, horalign, vertalign, ischild, offset)
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

if nargin < 4
    vertalign = '';
end
if nargin < 5
    ischild = false;
end
if nargin < 6
    offset = [];
end
if isgraphics(refobj)
    refpos = get(refobj, 'Position');
else
    refpos = refobj;
end
if ischild
    refpos = [0 0 refpos([3 4])];
end
if ~isempty(objects) & all(ishghandle(objects)) %#ok<AND2>
    setpos = true;
    pos = get(objects, {'Position'});
else
    setpos = false;
    pos = objects;
end
if iscell(pos)
    pos = vertcat(pos{:});
end
hpos = calcPos(pos, refpos, 1, horalign);
vpos = calcPos(pos, refpos, 2, vertalign);
pos = [hpos(:,1) vpos(:,2) hpos(:,3) vpos(:,4)];
if ~isempty(offset)
    pos([1 2]) = pos([1 2]) + offset;
end
if setpos
    set(objects, {'Position'}, num2cell(pos, 2));
end


function pos = calcPos(pos, refpos, dim, alignment)
%% Calculate aligned positions
alignment = lower(char(alignment));
alignlist = ["left" "center" "right" "fill"
             "bottom" "center" "top" "fill"];
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