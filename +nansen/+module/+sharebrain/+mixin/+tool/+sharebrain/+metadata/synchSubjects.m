function synchSubjects(options)

    arguments
        options.SubjectIgnorePattern (1,1) string = missing
    end

    import nansen.module.sharebrain.internal.toCamelCase
    
    project = nansen.getCurrentProject();
    projectFolder = project.FolderPath;

    openmindsFolder = fullfile(projectFolder, 'metadata', 'openminds');
    if ~isfolder(openmindsFolder); mkdir(openmindsFolder); end

    % Open openMINDS collection
    collection = openminds.Collection( );

    % Open subject metatable
    metaTable = project.MetaTableCatalog.getMasterMetaTable('Subject');
    subjectTable = metaTable.entries;
    subjectIds = string( metaTable.members );

    if ~ismissing(options.SubjectIgnorePattern)
        ignore = regexp(subjectIds, options.SubjectIgnorePattern);
        ignore = ~cellfun(@isempty, ignore);
    else
        ignore = false(height(subjectTable), 1);
    end
    
    subjectTable = subjectTable(~ignore, :);
    subjectIds = subjectIds(~ignore);

    sessionMetaTable = project.MetaTableCatalog.getMetaTable('Session');
    sessionTable = sessionMetaTable.entries;
    % sessionIds = string( sessionMetaTable.members ); Currently not used

    for i = 1:numel(subjectIds)
        subjectInfo = table2struct( subjectTable(i, :) );

        omSubject = openminds.core.Subject(...
            'biologicalSex', toCamelCase(subjectInfo.BiologicalSex), ...
            'internalIdentifier', string(subjectInfo.SubjectID), ...
            'lookupLabel', sprintf('%s-%s', project.Name, string(subjectInfo.SubjectID)), ...
            'species', toCamelCase(subjectInfo.Species) );

        collection.add(omSubject);

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
    kgcol = KgCollection('Space', space, 'OpenMINDSCollection', collection);

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
