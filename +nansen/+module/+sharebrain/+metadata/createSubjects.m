function createSubjects(collection)

    import nansen.module.sharebrain.internal.toCamelCase

    if ~nargin
        collection = nansen.module.sharebrain.metadata.getOpenMINDSCollection();
    end
        
    project = nansen.getCurrentProject();
    metaTable = project.MetaTableCatalog.getMasterMetaTable('Subject');
    subjectTable = metaTable.entries;

    for i = 1:height(subjectTable)
        
        subjectInfo = table2struct( subjectTable(i, :) );

        subjectId = subjectInfo.SubjectID;

        % Find subject from collection
        subject = collection.list('Subject', 'lookupLabel', subjectId);
        if ~isempty(subject)
            continue
        end

        omSubject = openminds.core.Subject(...
            'biologicalSex', toCamelCase(subjectInfo.BiologicalSex), ...
            'internalIdentifier', string(subjectInfo.InternalIdentifier), ...
            'lookupLabel', string(subjectInfo.SubjectID));

        if isfield(subjectInfo, 'Strain')
            strain = collection.list("Strain", "name", subjectInfo.Strain);
            if isempty(strain)
                error('Strain %s does not exist in metadata collection.', subjectInfo.Strain)
            end

            omSubject.species = strain;
        else
            omSubject.species = toCamelCase(subjectInfo.Species);
        end

        if isfield(subjectInfo, 'SubjectGroup') && ~isempty(subjectInfo.SubjectGroup)
            key = subjectInfo.SubjectGroup;
            sg = collection.list("SubjectGroup", "lookupLabel", key);
            if ~isempty(sg)
                omSubject.isPartOf = sg;
                sg.numberOfSubjects = sg.numberOfSubjects + 1;
            end
        end
        collection.add(omSubject);
    end

    % Update subject group counts
    % % sgKeys = sgCount.keys();
    % % for i = 1:numel(sgKeys)
    % %     currentKey = sgKeys{i};
    % %     currentCount = sgCount(currentKey);
    % %     sg = collection.list("SubjectGroup", "lookupLabel", currentKey);
    % %     sg.numberOfSubjects = currentCount;
    % % end

    % dsvUuid = regexprep(nansen.module.sharebrain.internal.getCollabIdFromProject(project), '^d-', '');
    % dsv = kgpull(dsvUuid);
    % dsv.studiedSpecimen = [num2cell(collection.list("Subject")), num2cell(collection.list("SubjectGroup"))];
    % kgsave(dsv)
    %collection.add(dsv)
    
    collection.save()
end

