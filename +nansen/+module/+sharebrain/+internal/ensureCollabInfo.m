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
%   A warning is issued when the collab's name and title differ, since
%   this module addresses both the bucket and the Knowledge Graph space
%   by the name.
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
    warnIfNameAndTitleDiffer(collabInfo)
end

function warnIfNameAndTitleDiffer(collabInfo)
%warnIfNameAndTitleDiffer Flag a collab whose name and title have drifted
%   These are expected to hold the same value. Both the data proxy bucket
%   and the Knowledge Graph space are addressed by the name, so a title
%   that deviates usually means the collab was created differently than
%   this module assumes and the bucket may not be where it expects.

    if ~strcmp(collabInfo.name, collabInfo.title)
        warning("SHAREbrain:CollabInfo:NameTitleMismatch", ...
            "Collab name ('%s') and title ('%s') differ. This module " + ...
            "addresses the bucket and the Knowledge Graph space by the " + ...
            "name. Verify that '%s' is the intended bucket for this " + ...
            "dataset.", ...
            collabInfo.name, collabInfo.title, collabInfo.name)
    end
end
