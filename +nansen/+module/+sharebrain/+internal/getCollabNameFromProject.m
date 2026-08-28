function collabId = getCollabIdFromProject(project)

    collabInfo = nansen.module.sharebrain.internal.ensureCollabInfo(project);
    collabId = collabInfo.name;
end
