function filePath = getCollabInfoFilePath(folderPath)
%getCollabInfoFilePath - Path of the file holding a project's collab info
%   filePath = getCollabInfoFilePath(folderPath) returns the path of the
%   JSON file in folderPath that records which EBRAINS data sharing
%   collab a NANSEN project is linked to. folderPath is normally a
%   project's configuration folder.
%
%   This function only builds the path. The file it names does not
%   necessarily exist, and neither the file nor folderPath is created.
%
%   See also ensureCollabInfo, uiSelectDataSharingCollabInfo

    arguments
        folderPath (1,1) string
    end

    filePath = fullfile(folderPath, "ebrains_collab_info.json");
end
