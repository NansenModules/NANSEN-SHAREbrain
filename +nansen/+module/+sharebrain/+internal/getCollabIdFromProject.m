function collabId = getCollabIdFromProject(project)

    filePath = nansen.module.sharebrain.internal.getCollabInfoFilepath(project);

    if ~isfile(filePath)
        nansen.module.sharebrain.internal.uiGetBucketId()
    end
    collabInfo = jsondecode( fileread(filePath));
    collabId = collabInfo.name;
end