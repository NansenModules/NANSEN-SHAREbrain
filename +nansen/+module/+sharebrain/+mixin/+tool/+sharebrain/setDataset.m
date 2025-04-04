function setDataset()
    project = nansen.getCurrentProject();
    configFolder = project.getConfigurationFolder();
    
    filePath = fullfile(configFolder, 'ebrains_collab_info.json');

    if isfile(filePath)
        answer = questdlg('EBRAINS Dataset is already configured. Do you want to change this dataset?', 'Reset dataset?', 'Yes', 'No', 'Cancel', 'No');
        if strcmp(answer, 'Yes')
            %pass
        else
            return
        end
    end

    nansen.module.sharebrain.internal.uiSelectDataSharingCollabInfo(...
        "TargetFolder", configFolder)
end
