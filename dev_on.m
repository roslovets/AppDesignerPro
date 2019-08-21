% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
clear all
dev = AppDesignerProDev
fprintf('   Dev: %s v%s (%s)\n\n', dev.ext.name, dev.vp, dev.ext.root)
% to deploy run: dev.deploy(v) i.e. dev.deploy('0.1.1')
% to build run dev.build or dev.build(v)
% to push new version to GitHub: dev.push
% to tag new release: dev.tag