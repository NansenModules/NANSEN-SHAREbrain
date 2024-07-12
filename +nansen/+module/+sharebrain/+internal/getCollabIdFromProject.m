function collabId = getCollabIdFromProject(project)

    configFolder = project.getConfigurationFolder();
    filePath = fullfile(configFolder, 'ebrains_collab_info.json');
    if ~isfile(filePath)
        nansen.module.sharebrain.internal.uiGetBucketId()
    end
    collabInfo = jsondecode( fileread(filePath));
    collabId = collabInfo.name;
end