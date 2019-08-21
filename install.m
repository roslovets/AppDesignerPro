function install
% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
dev = AppDesignerProDev;
dev.test('', false);
% Post-install commands
cd('..');
ext = AppDesignerProExtender;
ext.doc;
% Add your post-install commands below