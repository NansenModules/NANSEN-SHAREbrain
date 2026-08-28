function uuid = getDatasetVersionUuid(project)
%getDatasetVersionUuid - Uuid of the dataset version linked to a project
%   UUID = getDatasetVersionUuid() returns the uuid of the EBRAINS dataset
%   version that the current NANSEN project is linked to.
%
%   UUID = getDatasetVersionUuid(PROJECT) returns it for PROJECT instead
%   of the current project.
%
%   A data sharing collab is named after its dataset version, prefixed
%   with "d-", so the uuid is that name with the prefix removed.
%
%   See also getCollabNameFromProject, ensureCollabInfo

    arguments
        project = nansen.getCurrentProject()
    end

    collabName = nansen.module.sharebrain.internal.getCollabNameFromProject(project);
    uuid = regexprep(collabName, '^d-', '');
end
