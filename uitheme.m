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
        color = '#d4edda';
        fontcolor = '#155724';
    case 'info'
        color = '#d1ecf1';
        fontcolor = '#0c5460';
    case 'warning'
        color = '#fff3cd';
        fontcolor = '#856404';
    case 'danger'
        color = '#f8d7da';
        fontcolor = '#721c24';
    otherwise
        error('Unknown theme: %s. Use one of the: none|dark|light|success|info|warning|danger', theme);
end

