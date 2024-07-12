function openDataSharingCollab()

    project = nansen.getCurrentProject();
    configFolder = project.getConfigurationFolder();
    filePath = fullfile(configFolder, 'ebrains_collab_info.json');
    if ~isfile(filePath)
        nansen.module.sharebrain.internal.uiGetBucketId()
    end
    collabInfo = jsondecode( fileread(filePath));

    baseUrl = ebrains.common.constant.CollabBaseUrl();
    collabUrl = baseUrl + "/" + collabInfo.link;

    web(collabUrl, '-browser')
end
