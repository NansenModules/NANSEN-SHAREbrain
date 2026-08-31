function collabName = getCollabNameFromProject(project)
%getCollabNameFromProject - Name of the collab a project is linked to
%   collabName = getCollabNameFromProject() returns the name of the
%   EBRAINS data sharing collab that the current NANSEN project is linked
%   to. The name addresses both the data proxy bucket and the Knowledge
%   Graph space.
%
%   collabName = getCollabNameFromProject(PROJECT) returns it for PROJECT
%   instead of the current project.
%
%   A project is linked interactively on first use, so this may open a
%   selection dialog and block on user input.
%
%   See also ensureCollabInfo, getDatasetVersionUuid

    arguments
        project = nansen.getCurrentProject()
    end

    collabInfo = nansen.module.sharebrain.internal.ensureCollabInfo(project);
    collabName = collabInfo.name;
end
