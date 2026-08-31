function collection = getOpenMINDSCollection()
%getOpenMINDSCollection - Open the project's openMINDS collection
%   COLLECTION = getOpenMINDSCollection() returns the openMINDS metadata
%   collection of the current NANSEN project, backed by a file store at
%   metadata/openminds/instances.jsonld inside the project folder.
%
%   This also pins the openMINDS version, because the collection has to
%   match the version the Knowledge Graph accepts. That is a process-wide
%   setting, so it affects openMINDS code outside this module too.
%
%   See also setOpenMINDSVersion, getKGCollabSpace

    % Ensure correct openMINDS version
    nansen.module.sharebrain.metadata.setOpenMINDSVersion()

    currentProject = nansen.getCurrentProject();

    openMINDSFolder = fullfile(currentProject.getMetadataFolder, 'openminds');
    openMINDSCollectionFile = fullfile(openMINDSFolder, 'instances.jsonld');

    localStore = openminds.internal.FileMetadataStore(openMINDSCollectionFile);

    collection = openminds.Collection("MetadataStore", localStore);
end
