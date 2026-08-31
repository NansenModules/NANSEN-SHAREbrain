function linkDataset()
%linkDataset - Link a NANSEN project to an EBRAINS dataset collab
%   linkDataset() links the current NANSEN project to a data sharing
%   collab and saves the selected collab's metadata to the project's
%   configuration folder.
%
%   When the project is already linked, the user is asked to confirm
%   before a different dataset is chosen. Otherwise a dialog opens for
%   selection among the accessible dataset collabs.
%
%   See also openDataSharingCollab,
%   nansen.module.sharebrain.internal.ensureCollabInfo

    project = nansen.getCurrentProject();
    configFolder = project.getConfigurationFolder();

    filePath = nansen.module.sharebrain.internal.getCollabInfoFilePath(configFolder);

    if isfile(filePath)
        title = 'Reset dataset?';
        question = 'EBRAINS Dataset is already configured. Do you want to change this dataset?';
        options = {'Yes', 'No', 'Cancel'};

        answer = questdlg(question, title, options{:}, options{2});
        if strcmp(answer, 'Yes')
            % pass
        else
            return
        end
    end

    nansen.module.sharebrain.internal.uiSelectDataSharingCollabInfo(...
        "TargetFolder", configFolder)
end
