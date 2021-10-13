function uiicons()
% Open Icons App or helps to download Icons Toolbox
w = which('IconsApp');
if ~isempty(w)
    IconsApp;
else
    fprintf('  <a href="matlab:eval(webread(''https://git.io/fjKjK''))">Click here</a> to download and install <a href="https://github.com/roslovets/Icons-for-MATLAB">Icons Toolbox</a>\n');
end