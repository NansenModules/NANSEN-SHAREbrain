function initializeFileRepo()
    
    % Todo : 
    %  - Structure pattern
    %  - hostedBy

    project = nansen.getCurrentProject();
    
    collabId = nansen.module.sharebrain.internal.getCollabIdFromProject(project);
    space = sprintf('collab-%s', collabId);
    
    kgcol = KgCollection('Space', space);

    dsvUuid = collabId(3:end);
    tic
    fgdsv = kgcol.getInstance(dsvUuid);
    toc
    tic
    dsv = kgcol.getOpenMindsInstance(dsvUuid);
    toc

    %dsv = kgcol.getFromId(dsvUuid, 'openminds.core.products.DatasetVersion');


    if isa(dsv.repository, 'py.NoneType')

        repo = kgcol.list(class(openminds.core.FileRepository));
           
        if isempty( repo )
            repo = openminds.core.FileRepository();
            repo.name = sprintf('bucket/%s', collabId);
            repo.IRI = sprintf("https://data-proxy.ebrains.eu/api/v1/buckets/%s", collabId);
            repo.type = "Swift";
            dsv.repository = kgcol.convertOpenMINDSInstance(repo);
        else
            dsv.repository = repo;
        end

        kgcol.updateInstance(dsv)
    end
end