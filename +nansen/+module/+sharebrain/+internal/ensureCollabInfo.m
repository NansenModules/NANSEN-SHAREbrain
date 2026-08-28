function collabInfo = ensureCollabInfo(project)
%ensureCollabInfo - Get the EBRAINS collab a project is linked to
%   collabInfo = ensureCollabInfo() returns the data sharing collab info
%   that is linked to the current NANSEN project. If the project is not
%   linked to a collab yet, a modal dialog opens for the user to select
%   one and the selection is saved to the project's configuration folder.
%   The function throws if the user cancels the selection.
%
%   collabInfo = ensureCollabInfo(PROJECT) returns the collab info for
%   PROJECT instead of the current project.
%
%   See also uiSelectDataSharingCollabInfo, getCollabIdFromProject,
%   nansen.getCurrentProject

    arguments
        project = nansen.getCurrentProject()
    end

    configFolder = project.getConfigurationFolder();
    filePath = nansen.module.sharebrain.internal.getCollabInfoFilePath(configFolder);

    if ~isfile(filePath)
        nansen.module.sharebrain.internal.uiSelectDataSharingCollabInfo(...
            "TargetFolder", configFolder)
    end

    collabInfo = jsondecode( fileread(filePath) );
end
