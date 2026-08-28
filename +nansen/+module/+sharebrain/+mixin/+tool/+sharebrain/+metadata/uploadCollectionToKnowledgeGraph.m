function uploadCollectionToKnowledgeGraph(collection, options)
%uploadCollectionToKnowledgeGraph - Save a collection to the KG
%   uploadCollectionToKnowledgeGraph() saves every locally created
%   instance of the current project's openMINDS collection to the
%   Knowledge Graph space of the linked collab, then saves the
%   collection to disk. Instances that only reference an openMINDS
%   vocabulary term are skipped.
%
%   uploadCollectionToKnowledgeGraph(COLLECTION) uploads COLLECTION
%   instead of the current project's collection.
%
%   uploadCollectionToKnowledgeGraph(..., UpdateIfExists=TF) controls
%   whether instances already in the Knowledge Graph are written again.
%   The default is true.
%
%   uploadCollectionToKnowledgeGraph(..., KGSpace=SPACE) writes to SPACE
%   rather than the space of the linked collab.
%
%   See also syncSubjectsToKnowledgeGraph,
%   nansen.module.sharebrain.metadata.getOpenMINDSCollection

    arguments
        collection = []
        options.UpdateIfExists (1,1) logical = true
        options.KGSpace (1,1) string = nansen.module.sharebrain.metadata.getKGCollabSpace()
    end
    if isempty(collection)
        collection = nansen.module.sharebrain.metadata.getOpenMINDSCollection();
    end
    
    instances = collection.getAll();
    ids = cellfun(@(c) c.id, instances);

    toRemove = startsWith(ids, "https://openminds.ebrains.eu") | startsWith(ids, "https://openminds.om-i.org");
    instances(toRemove) = [];

    % Todo: more robust. Sort places all local instances first, ensuring
    % local instances are saved first. Not robust, will not work for nested
    % instances.
    ids = cellfun(@(c) c.id, instances);
    [sortedIds, sortIdx] = sort(ids);
    instances = instances(sortIdx);

    
    for i = 1:numel(instances)
        if startsWith(instances{i}.id, 'https://openminds.ebrains.eu')
            continue
        end
        if startsWith(instances{i}.id, 'https://')
            if options.UpdateIfExists
                try
                    kgsave(instances{i}, "space", options.KGSpace)
                catch
                    keyboard
                end
            else
                continue
            end
        else
            kgsave(instances{i}, "space", options.KGSpace, "SaveMode", "Skip")
        end
    end
    collection.save()


    % dsvUuid = regexprep(nansen.module.sharebrain.internal.getCollabIdFromProject(project), '^d-', '');
    % dsv = kgpull(dsvUuid);
    % sg = collection.list("SubjectGroup")
    % dsv.studiedSpecimen = [num2cell(collection.list("Subject")), num2cell(sg(1:4))];
    % kgsave(dsv)
    % collection.add(dsv)
end
