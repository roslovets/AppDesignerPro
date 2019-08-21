classdef AppDesignerProUpdater < handle
    % Control version of installed toolbox and update it from GitHub
    % By Pavel Roslovets, ETMC Exponenta
    % https://github.com/ETMC-Exponenta/ToolboxExtender
    
    properties
        ext % Toolbox Extender
        vr % latest remote version form internet (GitHub)
        isupd % update is available
        relsum % release notes summary
        rel % release notes
        bin % Toolbox binary
    end
    
    properties (Hidden)
        res % GitHub resources
    end
    
    methods
        function obj = AppDesignerProUpdater(extender)
            % Init
            if nargin < 1
                obj.ext = AppDesignerProExtender;
            else
                obj.ext = extender;
            end
        end
        
        function [res, err] = fetch(obj)
            % Fetch resources from GitHub
            url = obj.ext.getlatesturl();
            res = '';
            try
                res = webread(url);
                err = [];
                obj.res = res;
                obj.vr = erase(res.tag_name, 'v');
                obj.rel = res.body;
                % Extract release summary
                sum = '';
                if contains(obj.rel, '# Summary')
                    sum = extractAfter(obj.rel, '# Summary');
                    if contains(sum, '#')
                        sum = extractBefore(sum, '#');
                    end
                end
                sum = char(strtrim(sum));
                obj.relsum = sum;
                % Extract update is available
                obj.isupd = ~isempty(obj.vr) & ~isequal(obj.ext.vc, obj.vr);
                % Get binary information
                assets = struct2table(obj.res.assets, 'AsArray', 1);
                assets = assets(endsWith(assets.name, '.mltbx'), :);
                if ~isempty(assets)
                    obj.bin = table2struct(assets(1, :));
                else
                    obj.bin = [];
                end
            catch err
            end
        end
        
        function vr = gvr(obj)
            % Get remote version from GitHub
            if isempty(obj.vr)
                obj.fetch();
            end
            vr = obj.vr;
        end
        
        function rel = getrel(obj)
            % Get release notes
            if isempty(obj.res)
                obj.fetch();
            end
            rel = obj.rel;
        end
        
        function sum = getrelsum(obj)
            % Get release notes summary
            if isempty(obj.res)
                obj.fetch();
            end
            sum = obj.relsum;
        end
        
        function webrel(obj)
            % Open GitHub releases webpage
            obj.ext.webrel();
        end
        
        function [vc, vr] = ver(obj)
            % Check curent installed and remote versions
            vc = obj.ext.gvc();
            if nargout == 0
                if isempty(vc)
                    fprintf('%s is not installed\n', obj.ext.name);
                else
                    fprintf('Installed version: %s\n', vc);
                end
            end
            % Check remote version
            vr = obj.gvr();
            if nargout == 0
                if ~isempty(vr)
                    fprintf('Latest version: %s\n', vr);
                    if isequal(vc, vr)
                        fprintf('You use the latest version\n');
                    else
                        fprintf('* Update is available: %s->%s *\n', vc, vr);
                        fprintf("To update call 'update' method of " + mfilename + "\n");
                    end
                else
                    fprintf('No remote version is available\n');
                end
            end
        end
        
        function yes = isonline(~)
            % Check connection to internet is available
            try
                java.net.InetAddress.getByName('google.com');
                yes = true;
            catch
                yes = false;
            end
        end
        
        function isupd = isupdate(obj, cbfun, delay)
            % Check that update is available
            if obj.isonline()
                vc = obj.ext.gvc();
                if nargin < 2
                    obj.fetch();
                    isupd = obj.isupd;
                else
                    if nargin < 3
                        delay = 1;
                    end
                    isupd = false;
                    obj.run_task(@(~, ~) obj.isupd_async(cbfun, vc), delay);
                end
            else
                isupd = false;
            end
        end
        
        function installweb(obj, dpath)
            % Download and install latest version from remote (GitHub)
            if nargin < 2
                dpath = tempname;
                mkdir(dpath);
            end
            if isempty(obj.res)
                obj.gvr();
            end
            if ~isempty(obj.vr)
                fprintf('* Installation of %s is started *\n', obj.ext.name);
                fprintf('Installing the latest version: v%s...\n', obj.vr);
                if isempty(obj.bin)
                    error('No toolbox file were found on GitHub. Contact toolbox author');
                end
                fpath = fullfile(dpath, obj.bin.name);
                websave(fpath, obj.bin.browser_download_url);
                r = obj.ext.install(fpath);
                fprintf('%s v%s has been installed\n', r.Name{1}, r.Version{1});
                delete(fpath);
            end
        end
        
        function update(obj, delay, cbpre, varargin)
            % Update installed version to the latest from remote (GitHub)
            if obj.isupdate()
                if nargin < 2
                    delay = 1;
                end
                dpath = tempname;
                mkdir(dpath);
                TE = feval(obj.ext.getselfname());
                TE.root = dpath;
                TE.name = 'Temp';
                vname = obj.ext.getvalidname();
                if vname == "ToolboxExtender"
                    vname = "Toolbox";
                end
                TE.cloneclass('Extender', obj.ext.root, vname);
                cname = TE.cloneclass('Updater', obj.ext.root, vname);
                copyfile(fullfile(obj.ext.root, obj.ext.config), dpath);
                if nargin > 2 && ~isempty(cbpre)
                    cbpre();
                end
                taskfcn = @(~, ~) obj.installweb_async(dpath, cname, varargin{:});
                obj.run_task(taskfcn, delay);
            end
        end
        
        function run_task(obj, fcn, delay)
            %% Run delayed asynchronous task
            tmr = timer('ExecutionMode', 'singleShot', 'StartDelay', delay,...
                'TimerFcn', fcn, 'StopFcn', @(tmr,~,~) delete(tmr),...
                'Name', obj.ext.name + " task");
            start(tmr);
        end
        
    end
    
    methods (Hidden)
        
        function isupd_async(obj, cbfun, vc)
            % Task for async ver timer
            obj.fetch();
            cbfun(obj.isupd);
        end
        
        function installweb_async(obj, dpath, cname, cbpost)
            % Task for update timer
            p0 = cd(dpath);
            TU = eval(cname);
            TU.installweb(dpath);
            cd(p0);
            if nargin > 3
                cbpost();
            end
        end
        
    end
    
end

