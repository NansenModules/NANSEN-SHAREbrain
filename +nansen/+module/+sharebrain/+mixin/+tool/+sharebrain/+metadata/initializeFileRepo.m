function initializeFileRepo()
    
    % Todo : 
    %  - Structure pattern
    %  - hostedBy

    project = nansen.getCurrentProject();
    
    collabId = nansen.module.sharebrain.internal.getCollabIdFromProject(project);
    space = sprintf('collab-%s', collabId);

    dsvUuid = collabId(3:end);
    dsv = kgpull(dsvUuid);

    if isempty(dsv.repository)
        repo = openminds.core.FileRepository();
        repo.name = sprintf('bucket/%s', collabId);
        repo.IRI = sprintf("https://data-proxy.ebrains.eu/api/v1/buckets/%s", collabId);
        repo.type = "Swift";
        dsv.repository = repo;
        
        kgsave(dsv, "space", space)
    else
        disp('This Dataset version already has a repository.')
        %repoRef = dsv.repository.resolve();
    end
end
