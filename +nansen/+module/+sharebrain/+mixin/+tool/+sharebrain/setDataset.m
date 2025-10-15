function setDataset()
% setDataset - (Interactively) Link a NANSEN project to a Dataset Collab
%
% This function allows the user to link the current NANSEN project to a
% data-sharing collab (Dataset Collab). It first checks whether a collab is
% already linked to the project. If one exists, the user is prompted to
% confirm whether they want to link a different dataset. If no dataset is
% linked—or if the user chooses to re-link—a dialog is opened that allows
% selection among accessible Dataset Collabs. The selected collab’s name
% and metadata are then saved to the project’s configuration folder.

    project = nansen.getCurrentProject();
    configFolder = project.getConfigurationFolder();

    filePath = fullfile(configFolder, 'ebrains_collab_info.json');

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
