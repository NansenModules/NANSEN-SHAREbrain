function collabId = getCollabIdFromProject(project)

    filePath = nansen.module.sharebrain.internal.getCollabInfoFilepath(project);

    if ~isfile(filePath)
        nansen.module.sharebrain.internal.uiSelectDatasetCollab()
    end
    
    collabInfo = jsondecode( fileread(filePath));
    collabId = collabInfo.name;
end