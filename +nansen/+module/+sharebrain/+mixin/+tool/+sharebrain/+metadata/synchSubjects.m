function synchSubjects()
    
    project = nansen.getCurrentProject();
    projectFolder = project.FolderPath;

    openmindsFolder = fullfile(projectFolder, 'metadata', 'openminds');
    if ~isfolder(openmindsFolder); mkdir(openmindsFolder); end

    % Open openMINDS collection
    col = openminds.Collection( );
    %col.load( openmindsFolder )

    % Open subject metatable
    metaTable = project.MetaTableCatalog.getMasterMetaTable('Subject');
    subjectTable = metaTable.entries;
    subjectIds = string( metaTable.members );

    ignore = startsWith(subjectIds, "aq");
    subjectTable = subjectTable(~ignore, :);
    subjectIds = subjectIds(~ignore);

    sessionMetaTable = project.MetaTableCatalog.getMetaTable('Shareable');
    sessionTable = sessionMetaTable.entries;
    sessionIds = string( sessionMetaTable.members );


    for i = 1:numel(subjectIds)
        subjectInfo = table2struct( subjectTable(i, :) );

        omSubject = openminds.core.Subject(...
            'biologicalSex', toCamelCase(subjectInfo.BiologicalSex), ...
            'internalIdentifier', string(subjectInfo.SubjectID), ...
            'lookupLabel', sprintf('%s-%s', project.Name, string(subjectInfo.SubjectID)), ...
            'species', toCamelCase(subjectInfo.Species) );

        col.add(omSubject);

        subjectSessions = sessionTable(string(sessionTable.subjectID) == string(subjectInfo.SubjectID), :);

        for j = 1:height(subjectSessions)
            sessionInfo = table2struct( subjectSessions(j, :) );
    
            omSubjectState = openminds.core.SubjectState();
            omSubjectState.internalIdentifier = sessionInfo.sessionID;
            omSubjectState.lookupLabel = sprintf('%s-%s-%s', ...
                                                    project.Name, ...
                                                    string(sessionInfo.subjectID), ...
                                                    string(sessionInfo.sessionID) );
            
            age = sessionInfo.Date - subjectInfo.DateOfBirth;
            numWeeks = round( days(age) / 7);
            if ~isnan(numWeeks)
                omSubjectState.age = openminds.core.QuantitativeValue(...
                    'value', numWeeks, 'unit', 'week');
            end
            omSubjectState.additionalRemarks = sessionInfo.VesselType;
            omSubject.studiedState(end+1) = omSubjectState;
        end
    end

    % Create KG / FG client
    space = sprintf('collab-%s', nansen.module.sharebrain.internal.getCollabIdFromProject(project));
    kgcol = KgCollection('Space', space, 'OpenMINDSCollection', col);

    % Synch subjects...
    kgInstances = kgcol.synch(...
        'Type', 'Subject', ...
        'IdentityProp', 'internalIdentifier');
    
    % Add subjects to DatasetVersion
    dsvUuid = strrep(space, 'collab-d-', '');
    dsv = kgcol.getFromId(dsvUuid, 'openminds.core.products.DatasetVersion');
    dsv.studied_specimens = py.list(kgInstances);
    kgcol.updateInstance(dsv)

    disp('Finished synching')
end

function value = toCamelCase(value)
    if iscell(value)
        value = string(value);
    end

    value = strrep(value, ' ', '_');
    value = utility.string.snake2camel(char(value));
    value = string(value);
end