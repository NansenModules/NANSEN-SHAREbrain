function registerBucketAsFileRepository()
%registerBucketAsFileRepository - Record the collab bucket in the KG
%   registerBucketAsFileRepository() sets the data proxy bucket of
%   the collab linked to the current project as the FileRepository
%   of the dataset version in the Knowledge Graph, and saves both to
%   the collab's KG space. Nothing is created in the bucket itself.
%
%   A dataset version that already has a repository is left
%   untouched.
%
%   See also syncSubjectsToKnowledgeGraph,
%   nansen.module.sharebrain.metadata.getKGCollabSpace
    
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
        
        % Save repository and dataset version
        kgsave(repo, "space", space)
        kgsave(dsv, "space", space)
    else
        disp('This Dataset version already has a repository.')
        %repoRef = dsv.repository.resolve();
    end
end
