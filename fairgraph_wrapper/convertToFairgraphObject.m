function fairgraphObject = convertToFairgraphObject(openMindsObject, fgClient)
    
    arguments
        openMindsObject openminds.abstract.Schema
        fgClient py.fairgraph.client.KGClient
    end

    fgType = getFairgraphType( class(openMindsObject) );

    [~, fairgraphObject] = evalc(fgType);

    propNames = properties(openMindsObject);

    if isa(openMindsObject, 'openminds.abstract.ControlledTerm')
        fairgraphObject = fairgraphObject.by_name( openMindsObject.name, fgClient );
    else
        if startsWith(openMindsObject.id, "https://kg.ebrains.eu/api/instances")
            uuid = extractAfter(openMindsObject.id, "https://kg.ebrains.eu/api/instances/");
            fairgraphObject = fairgraphObject.from_id( uuid, fgClient, scope="in progress" );
            return
        end

        for iProp = 1:numel(propNames)
            
            propName = propNames{iProp};
            propValue = openMindsObject.(propName);
    
            fgPropName = generatePythonName(propName);
            fgPropName = validateFgPropName(fgPropName, fairgraphObject);
            
            if isempty(propValue); continue; end

            fgPropValues = cell(size(propValue));
            for jPropValue = 1:numel(propValue)

                if isa(propValue(jPropValue), 'openminds.abstract.Schema')
                    fgPropValues{jPropValue} = convertToFairgraphObject(propValue(jPropValue), fgClient);
                
                elseif isa(propValue, 'mixedtype') % Todo...
                    error('Not implemented yet')
                else
                    fgPropValues{jPropValue} = propValue(jPropValue); % Pass value directly.
                end
            end

            if numel(fgPropValues) > 1
                fairgraphObject.(fgPropName) = py.list( fgPropValues );
            else
                fairgraphObject.(fgPropName) = fgPropValues{1};
            end
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
