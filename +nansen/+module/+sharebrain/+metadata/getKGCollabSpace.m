function space = getKGCollabSpace()
%getKGCollabSpace - Name of the KG space of the linked data sharing collab
%   SPACE = getKGCollabSpace() returns the name of the Knowledge Graph
%   space belonging to the EBRAINS collab that the current NANSEN project
%   is linked to. The space is the collab name prefixed with "collab-".
%
%   See also nansen.module.sharebrain.internal.getCollabNameFromProject,
%   nansen.module.sharebrain.internal.getDatasetVersionUuid

    collabName = nansen.module.sharebrain.internal.getCollabNameFromProject();
    space = sprintf('collab-%s', collabName);
end
