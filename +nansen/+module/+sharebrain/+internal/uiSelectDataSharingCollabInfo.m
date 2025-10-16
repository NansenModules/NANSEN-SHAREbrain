function collabInfo = uiSelectDataSharingCollabInfo()
    arguments
        %options.Logger % Todo
    end
    
    collab_info = nansen.module.sharebrain.internal.dsc.listDatasetCollabs();

    % Parse description:
    expression = '(?<=Dataset working title: ).+?(?=\n)';
    datasetTitles = regexp([collab_info.description], expression, 'match', 'once')';

    selection = uim.dialog.searchSelectDlg(cellstr(datasetTitles), 'Select a Dataset');
    
    if isempty(selection)
        error('Aborted') % Todo: Add error id and detailed error message
    end

    isSelection = strcmp(datasetTitles, selection);
    collabInfo = collab_info(isSelection);

    filePath = nansen.module.sharebrain.internal.getCollabInfoFilepath();
    utility.filewrite(filePath, jsonencode(collabInfo))
end
