function install
% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
open('AppDesignerProProject.prj');
dev_on
dev.test('', false);
% Post-install commands
close(currentProject);
cd('..');
uidoc
% Add your post-install commands below