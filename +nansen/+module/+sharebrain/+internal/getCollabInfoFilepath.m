function filePath = getCollabInfoFilepath(project)
% getCollabInfoFilepath - Retrieve the file path for the collab information.
%
% Syntax:
%   filePath = getCollabInfoFilepath(project) retrieves the path to the 
%   file containing collab metadata associated with the specified project.
%
% Input Arguments:
%   project (optional) - An instance of nansen.config.project.Project.
%                        If not provided, the current project is used.
%
% Output Arguments:
%   filePath - A string representing the file path to the collab metadata file.

    arguments
        project (1,1) nansen.config.project.Project = nansen.getCurrentProject()
    end

    parentFolder = project.getConfigurationFolder();

    fileName = nansen.module.sharebrain.constants.CollabInfoFilename;
    filePath = fullfile(parentFolder, fileName);
end
