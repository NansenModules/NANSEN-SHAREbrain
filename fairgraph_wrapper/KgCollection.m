classdef KgCollection < matlab.mixin.SetGet

    % Purpose:
    % Proxy to an openMINDS collection where all the instances are
    % synched to KG
    
    properties
        Scope = "in progress"
        Space = ''
        Server (1,1) string {mustBeMember(Server, ["prod", "preprod"])} = "prod";
    end

    properties (SetAccess = private)
        InstanceCount
        InstanceMap
    end

    properties (Access = private)
        FairgraphClient
        KGClient
        OpenMINDSCollection
    end

    methods
        function obj = KgCollection(propValues)
            arguments
                propValues.?KgCollection
                propValues.OpenMINDSCollection = openminds.Collection.empty

            end
            obj.set(propValues)

            obj.initializeFairgraphClient()
            
            obj.updateInstanceMap()
        end
    end

    methods
        function kgInstances = synch(obj, options)
            arguments
                obj
                options.Type (1,1) string
                options.IdentityProp (1,1) string
            end

            % Find all instances of type in collection.
            omInstances = obj.OpenMINDSCollection.list(options.Type);
            %omIdentityValues = [omInstances.(options.IdentityProp)];

            % kgInstances = obj.listType(class(omInstances));
            % for i = 1:numel(kgInstances)
            %     kgInstances{i}.delete(obj.FairgraphClient);
            % end


            %fgPropName = generatePythonName(options.IdentityProp);
            %fgPropName = validateFgPropName(fgPropName, kgInstances{1});
            %kgIdentityValues = cellfun(@(c) string( c.(fgPropName) ), kgInstances);
            
            % Detect deleted subject
            %[~, delIa] = setdiff(kgIdentityValues, omIdentityValues);
            % TODO

            % Detect added subjects
            %[~, addIa] = setdiff(omIdentityValues, kgIdentityValues);
            addIa=[];
            for i = 1:numel(omInstances)
                fprintf('Synching %s... (%d/%d)\n', options.Type, i, numel(omInstances))
                omInstance = omInstances(i);
                fairgraphObject = convertToFairgraphObject(omInstance, obj.FairgraphClient);

                if true % ismember(i, addIa)
                    fairgraphObject.save(obj.FairgraphClient, space=obj.Space)
                else % Detect changes---
                    isMatch = kgIdentityValues == omIdentityValues(i);
                    thisKgInstance = kgInstances{isMatch};

                    wasModified = false;

                    propNames = properties(omInstance);
                    for j = 1:numel(propNames)
                        fgPropName = generatePythonName(propNames{j});
                        fgPropName = validateFgPropName(fgPropName, thisKgInstance);

                        oldValue = thisKgInstance.(fgPropName);
                        newValue = fairgraphObject.(fgPropName);
                        
                        if isa(oldValue, 'py.fairgraph.kgproxy.KGProxy')
                            try
                                isEqual = strcmp(string(oldValue.id), string(newValue.id));
                            catch
                                isEqual = true; % If newValue is NoneType..
                            end
                        elseif isa(oldValue, 'py.fairgraph.kgquery.KGQuery')
                            isEqual = true;
                            warning('todo')
                        elseif isa(oldValue, 'py.list')
                            warning('todo')
                        else
                            isEqual = isequal(oldValue, newValue);
                        end

                        if ~isEqual
                            thisKgInstance.(fgPropName) = fairgraphObject.(fgPropName);
                            wasModified = true;
                        end
                    end
                    if wasModified
                        thisKgInstance.save(obj.FairgraphClient, space=obj.Space)
                    end
                end
            end
            
            kgInstances = obj.listType(class(omInstances));
        end
    
        function instance = getFromId(obj, instanceId, openMindsClassName)

            fairgraphClassName = getFairgraphType(openMindsClassName);
            [~, fgInstance] = evalc(fairgraphClassName);

            instance = fgInstance.from_id(instanceId, obj.FairgraphClient, scope="in progress");
        end

        function updateInstance(obj, kgInstance)
            kgInstance.save(obj.FairgraphClient, space=obj.Space);
        end

        function instances = list(obj, openMindsClassName)
            instances = obj.listType(openMindsClassName);
        end

        function kgInstance = convertOpenMINDSInstance(obj, instance)
            kgInstance = convertToFairgraphObject(instance, obj.FairgraphClient);
        end

        function fgInstance = getInstance(obj, instanceUuid)
            scopes = ["released", "in progress"];

            fullUri = obj.FairgraphClient.uri_from_uuid(instanceUuid);

            instance = obj.FairgraphClient.instance_from_full_uri(fullUri, scope='any', use_cache=false);

            % get fairgraph instance...
            type = string( instance.get('@type') );

            pathSegments = strsplit(type, '/');
            fairgraphType = sprintf('py.fairgraph.openminds.%s.%s', pathSegments{end-1:end});

            [~, fgInstance] = evalc(fairgraphType); %#ok<ASGLU>
            [~, fgInstance] = evalc(sprintf('fgInstance.from_id("%s", obj.FairgraphClient, scope="any")', instanceUuid));
        end
    
        function omInstance = getOpenMindsInstance(obj, instanceUuid, resolve)

            if nargin < 3; resolve = true; end
            
            if ~startsWith(instanceUuid, 'https')
                fullUri = obj.FairgraphClient.uri_from_uuid(instanceUuid);
            else
                fullUri = instanceUuid;
            end
            instance = obj.FairgraphClient.instance_from_full_uri(fullUri, scope='any', use_cache=false);

            keys = string( py.list( instance.keys ) );
            propNames = strrep(keys, 'https://openminds.ebrains.eu/vocab/', '');

            % get fairgraph instance...
            type = string( instance.get('@type') );

            omClassName = openminds.internal.utility.string.type2class(type);
            if contains(omClassName, 'controlledterms')
                omInstance = feval(omClassName); resolve = true;
            else
                if ~resolve
                    state = 'unresolved';
                else
                    state = '';
                end
                omInstance = feval(omClassName, 'id', string(instance.get('@id')));
            end

            if resolve
                omPropNames = properties(omInstance);
    
                for i = 1:numel(omPropNames)
                    isMatch = strcmp(omPropNames{i}, propNames);
    
                    if any(isMatch)
                        iPropName = omPropNames{i};
                        iPropValue = instance.get(keys(isMatch));
                        if isa(iPropValue, 'py.dict')
                            propKeys = string( py.list( iPropValue.keys ) );
                            if any( strcmp(propKeys, '@id') )
                                iPropValue = obj.getOpenMindsInstance(string(iPropValue.get('@id')), false);
                                omInstance.(iPropName) =  iPropValue ;
                            end
                        elseif isa(iPropValue, 'py.list')
                            iPropValueCell = cell(iPropValue);
                            for j=1:numel(iPropValueCell)
                                if isa(iPropValueCell{j}, 'py.dict')
                                    propKeys = string( py.list( iPropValueCell{j}.keys ) );
                                    if any( strcmp(propKeys, '@id') )
                                        iPropValueCell{j} = obj.getOpenMindsInstance(string(iPropValueCell{j}.get('@id')), false);
                                    end
                                elseif isa(iPropValueCell{j}, 'py.str')
                                    iPropValueCell = string(iPropValueCell);
                                end
                            end
                            omInstance.(iPropName) = [iPropValueCell{:}];
    
                        elseif isa(iPropValue, 'py.str')
                            omInstance.(iPropName) = string( iPropValue );
                        else
                            omInstance.(iPropName) =  iPropValue ;
                        end
                    end
                end
            end
        end
        function typeNames = listTypesInSpace(obj)
            %res = obj.KGClient.types.list(space=obj.Space, stage="IN_PROGRESS");
            res = obj.KGClient.types.list(space=obj.Space);
            data = cell( res.data );
            warnState = warning('off', 'MATLAB:structOnObject');
            typeNames = cellfun(@(c) string(struct(c).identifier), data );
            warning(warnState)
        end
    end

    methods
        function set.Server(obj, newValue)
            obj.Server = newValue;
            obj.initializeFairgraphClient()
        end

        function set.Space(obj, newValue)
            obj.Space = newValue;
            obj.updateInstanceMap()
        end
    end

    methods (Access = private)

        function instances = listType(obj, openMindsClassName)
            % Todo: Need separate routine for controlled terms.

            fairgraphClassName = getFairgraphType(openMindsClassName);

            [~, fgInstance] = evalc(fairgraphClassName);
            instances = fgInstance.list(obj.FairgraphClient, space=obj.Space, scope=obj.Scope);
            instances = cell(instances);
        end

        function downloadInstance()
            % dsv = py.fairgraph.openminds.core.DatasetVersion().from_id('2b5e1b5d-68ac-49c2-9189-33277dd471ec', fg_client, scope="in progress");
            % cust = dsv.authors.resolve(fg_client, scope="in progress")
        end

        function downloadControlledTerm()

        end

        function updateInstanceMap(obj)
                
            obj.InstanceCount = dictionary();

            if ~isempty(obj.KGClient) && ~isempty(obj.Space)
                res = obj.KGClient.types.list(space=obj.Space, stage="IN_PROGRESS");
                data = cell( res.data );

                for i = 1:numel(data)
                    typeInfo = data{i};
                    id = string( typeInfo.identifier );
                    id = strrep(id, 'https://openminds.ebrains.eu/', '');
                    count = uint32( typeInfo.occurrences.real );
                    obj.InstanceCount(id) = count;
                end

                % warnState = warning('off', 'MATLAB:structOnObject');
                % typeNames = cellfun(@(c) string(struct(c).identifier), data );
                % warning(warnState)
                % 
                % end
            end
        end
    end

    methods (Access = private)
        function initializeFairgraphClient(obj)
            tokenManager = ebrains.getTokenManager();
            bearerToken = tokenManager.AccessToken;
            switch obj.Server
                case 'prod'
                    hostName = "core.kg.ebrains.eu";
                case 'preprod'
                    hostName = "core.kg-ppd.ebrains.eu";
            end
            obj.FairgraphClient = py.fairgraph.KGClient(bearerToken, host=hostName);
            obj.KGClient = py.kg_core.kg.kg(hostName).with_token(bearerToken).build();
        end
    end

    methods (Static, Access = private)
        function installFairgraph()
            args = py.list({string(py.sys.executable), "-m", "pip", "install", "fairgraph"});
            py.subprocess.check_call(args);
        end
    end
end

function fgType = getFairgraphType(omType)
    type = strsplit( omType, '.');

    if numel(type) == 3
        type = strjoin(type, '.');
    elseif numel(type) == 4
        type = strjoin(type([1,2,4]), '.');
    else
        error('Type conversion not handled')
    end

    fgType = sprintf('py.fairgraph.%s', type);
end
