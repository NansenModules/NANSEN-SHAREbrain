function collection = getOpenMINDSCollection()
% getOpenMINDSCollection - Get openMINDS metadata collection for current project
    
    % Ensure correct openMINDS version
    nansen.module.sharebrain.metadata.setOpenMINDSVersion()
    
    currentProject = nansen.getCurrentProject();

    openMINDSFolder = fullfile(currentProject.getMetadataFolder, 'openminds');
    openMINDSCollectionFile = fullfile(openMINDSFolder, 'instances.jsonld');
    
    localStore = openminds.internal.FileMetadataStore(openMINDSCollectionFile);

    collection = openminds.Collection("MetadataStore", localStore);
end
