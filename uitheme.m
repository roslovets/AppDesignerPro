function [color, fontcolor] = uitheme(theme)
%% Get theme colors
theme = lower(theme);
switch theme
    case 'none'
        color = [0.94 0.94 0.94];
        fontcolor = [0 0 0];
    case 'dark'
        color = [0.149 0.149 0.149];
        fontcolor = [1 1 1];
    case 'light'
        color = [1 1 1];
        fontcolor = [0.149 0.149 0.149];
    case 'success'
        color = [0.8314 0.9294 0.8549];
        fontcolor = [0.0824 0.3412 0.1412];
    case 'info'
        color = [0.8196 0.9255 0.9451];
        fontcolor = [0.0471 0.3294 0.3765];
    case 'warning'
        color = [1.0000 0.9529 0.8039];
        fontcolor = [0.5216 0.3922 0.0157];
    case 'danger'
        color = [0.9725 0.8431 0.8549];
        fontcolor = [0.4471 0.1098 0.1412];
    otherwise
        error('Unknown theme: %s. Use one of the: none|dark|light|success|info|warning|danger', theme);
end

