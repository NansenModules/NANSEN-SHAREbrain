function linkCollabToProject(collabName)
% linkCollabToProject - Saves the metadata of a collab to current NANSEN project
% 
% Syntax:
%   nansen.module.sharebrain.internal.linkCollabToProject(collabName)
%
% Input Arguments:
%   collabName (1,1) string - The name of the collab to be fetched and saved.

    arguments
        collabName (1,1) string {nansen.module.sharebrain.internal.validator.mustBeDataSharingCollabName}
    end

    % Fetch collab metadata from EBRAINS Collaboratory
    collabInfo = nansen.module.sharebrain.internal.dsc.fetchCollabInfo(collabName);

    % Get filepath in current project to save collab metadata to
    project = nansen.getCurrentProject();
    filePath = nansen.module.sharebrain.internal.getCollabInfoFilepath(project);
    
    % Save collab metadata to current project
    fid = fopen(filePath, "wt");
    fileCleanup = onCleanup(@() fclose(fid));
    fwrite(fid, jsonencode(collabInfo))
end
