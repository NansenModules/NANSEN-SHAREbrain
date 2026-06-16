function space = getKGCollabSpace()
% getKGCollabSpace - Get name of KG space associated with data sharing collab
    project = nansen.getCurrentProject();
    dsvUuid = nansen.module.sharebrain.internal.getCollabIdFromProject(project);
    space = sprintf('collab-%s', dsvUuid);
end
