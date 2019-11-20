classdef AppDesignerProDev < handle
    % Helps you to build toolbox and deploy it to GitHub
    % By Pavel Roslovets, ETMC Exponenta
    % https://github.com/ETMC-Exponenta/ToolboxExtender
    
    properties
        ext % Toolbox Extender
        vp % project version
        vp_fcn % get version callback function
    end
    
    methods
        function obj = AppDesignerProDev(extender)
            % Init
            if nargin < 1
                obj.ext = AppDesignerProExtender;
            else
                if ischar(extender) || isStringScalar(extender)
                    obj.ext = AppDesignerProExtender(extender);
                else
                    obj.ext = extender;
                end
            end
            if ~strcmp(obj.ext.root, pwd)
                warning("Project root folder does not math with current folder." +...
                    newline + "Consider to change folder, delete installed toolbox or restart MATLAB")
            end
            obj.gvp();
        end
        
        function vp = gvp(obj)
            % Get project version
            if ~isempty(obj.vp_fcn)
                vp = obj.vp_fcn();
            else
                ppath = obj.ext.getppath();
                if isfile(ppath)
                    if obj.ext.type == "toolbox"
                        vp = matlab.addons.toolbox.toolboxVersion(ppath);
                    else
                        txt = obj.ext.readtxt(ppath);
                        vp = char(regexp(txt, '(?<=(<param.version>))(.*?)(?=(</param.version>))', 'match'));
                    end
                else
                    vp = '';
                end
            end
            obj.vp = vp;
        end
        
        function build(obj, vp, gendoc)
            % Build toolbox for specified version
            ppath = obj.ext.getppath();
            if nargin < 3 || gendoc
                obj.gendoc();
            end
            if nargin > 1 && ~isempty(vp)
                obj.setver(vp);
            else
                vp = obj.vp;
            end
            [~, bname] = fileparts(obj.ext.pname);
            bpath = fullfile(obj.ext.root, bname);
            if obj.ext.type == "toolbox"
                obj.updateroot();
                obj.seticons();
                matlab.addons.toolbox.packageToolbox(ppath, bname);
            else
                matlab.apputil.package(ppath);
                movefile(fullfile(obj.ext.root, obj.ext.name + ".mlappinstall"), bpath + ".mlappinstall",'f');
            end
            obj.ext.echo("v" + vp + " has been built");
        end
        
        function test(obj, varargin)
            % Build and install
            obj.build(varargin{:});
            obj.ext.install();
        end
        
        function untag(obj, v)
            % Delete tag from local and remote
            untagcmd1 = sprintf('git push --delete origin v%s', v);
            untagcmd2 = sprintf('git tag -d v%s', v);
            system(untagcmd1);
            system(untagcmd2);
            system('git push --tags');
            obj.ext.echo('has been untagged');
        end
        
        function release(obj, vp)
            % Build toolbox, push and tag version
            if nargin > 1
                obj.vp = vp;
            else
                vp = '';
            end
            if ~isempty(obj.ext.pname)
                obj.build(vp, true);
            end
            obj.push();
            obj.tag();
            obj.ext.echo('has been deployed');
            if ~isempty(obj.ext.pname)
                clipboard('copy', ['"' char(obj.ext.getbinpath) '"'])
                disp("Binary path was copied to clipboard")
            end
            disp("* Now create release on GitHub *");
            chapters = ["Summary" "Upgrade Steps" "Breaking Changes"...
                "New Features" "Bug Fixes" "Improvements" "Other Changes"];
            chapters = join("# " + chapters, newline);
            fprintf("Release notes hint: fill\n%s\n", chapters);
            disp("! Don't forget to attach binary from clipboard !");
            pause(1)
            web(obj.ext.remote + "/releases/edit/v" + obj.vp, '-browser')
        end
        
        function gendoc(obj, format, docdir, options)
            % Generate html, pdf or md (beta) from mlx
            arguments
                obj
                format = "html"
                docdir = fullfile(obj.ext.root, 'doc')
                options.TargetDir = docdir
                options.AddCredentials = false
            end
            format = string(format);
            docdir = strip(docdir, '/');
            [fs, ~] = obj.ext.dir(fullfile(docdir, '*.mlx'));
            for i = 1 : height(fs)
                [~, fname] = fileparts(fs.name(i));
                respath = char(fullfile(options.TargetDir, fname + "." + format));
                resinfo = obj.ext.dir(respath);
                convert = isempty(resinfo);
                if ~convert
                    convert = fs.date(i) >= resinfo.date(1);
                end
                if convert
                    fprintf('Converting %s.mlx...\n', fname);
                    if format == "md"
                        obj.mlx2md(char(fs.path(i)), char(respath), options.AddCredentials);
                    else
                        matlab.internal.liveeditor.openAndConvert(char(fs.path(i)), char(respath));
                    end
                end
            end
            disp('Docs have been generated');
        end
        
        function setver(obj, vp)
            % Set version
            ppath = obj.ext.getppath();
            if obj.ext.type == "toolbox"
                matlab.addons.toolbox.toolboxVersion(ppath, vp);
            else
                txt = obj.ext.readtxt(ppath);
                txt = regexprep(txt, '(?<=(<param.version>))(.*?)(?=(</param.version>))', vp);
                txt = strrep(txt, '<param.version />', '');
                obj.ext.writetxt(txt, ppath);
            end
            obj.gvp();
        end
        
        function webrel(obj)
            % Open GitHub releases webpage
            obj.ext.webrel();
        end
        
        function check(obj)
            % Check deployed release
            upd = AppDesignerProUpdater(obj.ext);
            upd.fetch();
            disp("Latest release: v" + upd.vr);
            if isempty(upd.rel)
                fprintf('[X] Release notes\n');
            end
            if isempty(upd.relsum)
                fprintf('[X] Release notes summary\n');
            end
            if isempty(upd.bin)
                fprintf('[X] Toolbox binary\n');
            end
        end
        
        function [com, url] = webinstaller(obj)
            % Get web installer command
            url = obj.shorturl(obj.ext.getrawurl('installweb.m'));
            com = sprintf("eval(webread('%s'))", url);
        end
        
    end
    
    
    methods (Hidden)
        
        function updateroot(obj)
            % Update project root
            service = com.mathworks.toolbox_packaging.services.ToolboxPackagingService;
            pr = service.openProject(obj.ext.getppath());
            service.removeToolboxRoot(pr);
            service.setToolboxRoot(pr, obj.ext.root);
            service.closeProject(pr);
        end
        
        function seticons(obj)
            % Set icons of app in toolbox
            xmlfile = 'DesktopToolset.xml';
            oldtxt = '<icon filename="matlab_app_generic_icon_' + string([16; 24]) + '"/>';
            newtxt = '<icon path="./" filename="icon_' + string([16; 24]) + '.png"/>';
            if isfile(xmlfile) && isfolder('resources')
                if all(isfile("resources/icon_" + [16 24] + ".png"))
                    txt = obj.ext.readtxt(xmlfile);
                    if contains(txt, oldtxt)
                        txt = replace(txt, oldtxt, newtxt);
                        obj.ext.writetxt(txt, xmlfile);
                    end
                end
            end
        end
        
        function push(obj)
            % Commit and push project to GitHub
            commitcmd = sprintf('git commit -m v%s', obj.vp);
            system('git add .');
            system(commitcmd);
            system('git push');
            obj.ext.echo('has been pushed');
        end
        
        function tag(obj, vp)
            % Tag git project and push tag
            if nargin < 2
                vp = obj.vp;
            end
            tagcmd = sprintf('git tag -a v%s -m v%s', vp, vp);
            system(tagcmd);
            system('git push --tags');
            obj.ext.echo('has been tagged');
        end
        
        function url = shorturl(obj, url)
            % Shorten URL by git.io
            host = "https://git.io/";
            url = webwrite(host + "create", 'url', url);
            url = host + url;
        end
        
    end

    
    methods (Hidden = true)
        
        function mlx2md(obj, fpath, htmlpath, addcred)
            % Convert mlx-script to markdown md-file (beta)
            if nargin < 4
                addcred = false;
            end
            [~, fname] = fileparts(fpath);
            tempf = "_temp_" + fname + ".m";
            matlab.internal.liveeditor.openAndConvert(fpath, char(tempf));
            txt = string(split(fileread(tempf), newline));
            delete(tempf);
            txt = erase(txt, char(13));
            % Convert code
            code = find(~startsWith(txt, '%') & txt ~= "");
            txt2 = strings();
            for i = 1 : length(txt)
                if ismember(i, code)
                    if ~ismember(i-1, code)
                        txt2 = txt2 + "``` MATLAB" + newline;
                    end
                    txt2 = txt2 + txt(i) + newline;
                    if ~ismember(i+1, code)
                        txt2 = txt2 + "```" + newline;
                    end
                else
                    txt2 = txt2 + txt(i) + newline;
                end
            end
            txt = string(split(txt2, newline));
            % Convert first title
            if startsWith(txt(1), '%% ')
                txt(1) = replace(txt(1), '%% ', '# ');
            end
            % Convert other titles
            titles = startsWith(txt, '%% ') & txt ~= "%% ";
            txt(titles) = replace(txt(titles), '%% ', '## ');
            % Convert lists
            lists = find(startsWith(txt, '% * '));
            txt(lists) = extractAfter(txt(lists), '% ');
            lists = find(startsWith(txt, '% # '));
            txt(lists) = replace(txt(lists), '% # ', '* ');
            % Convert text
            text = find(startsWith(txt, '% '));
            txt2 = strings();
            for i = 1 : length(txt)
                if ismember(i, text)
                    str = char(txt(i));
                    str = replace(str, '|', '`');
                    %str = replace(str, '*', '**');
                    txt2 = txt2 + str(3:end);
                    if ~ismember(i+1, text)
                        txt2 = txt2 + newline;
                    end
                else
                    txt2 = txt2 + txt(i) + newline;
                end
            end
            txt = string(split(txt2, newline));
            br = txt == "%% ";
            txt(br) = "";
            % Convert links
            links = extractBetween(join(txt, newline), '<', '>');
            urls = extractBefore(links, ' ');
            names = extractAfter(links, ' ');
            txt = replace(txt, "<" + links + ">", "[" + names + "](" + urls + ")");
            if addcred
                txt(end+1) = sprintf("***\n*Generated from %s.mlx with [Toolbox Extender](%s)*",...
                    fname, 'https://github.com/ETMC-Exponenta/ToolboxExtender');
            end
            obj.ext.writetxt(join(txt, newline), htmlpath, 'utf-8');
        end
        
    end
    
    
    methods (Static)
        
        function exclude(ppath, fmask)
            if isfile(ppath)
                try
                    % Exclude file or folder from Toolbox Project
                    service = com.mathworks.toolbox_packaging.services.ToolboxPackagingService;
                    pr = service.openProject(ppath);
                    ex = service.getExcludeFilter(pr);
                    ex = split(string(ex), newline);
                    fmask = string(fmask);
                    for i = 1 : length(fmask)
                        if ~ismember(fmask(i), ex)
                            ex = [ex; fmask(i)];
                            service.setExcludeFilter(pr, join(ex, newline));
                        end
                    end
                    service.closeProject(pr);
                catch
                end
            end
        end

    end
    
    
end