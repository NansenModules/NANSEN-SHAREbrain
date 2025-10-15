function collabInfo = uiSelectDataSharingCollabInfo(options)
    arguments
        options.TargetFolder (1,:) string {mustBeFolder}
        %options.Logger % Todo
    end
    
    myClient = ebrains.collaboratory.api.Collab();
    fprintf('Please wait, fetching datasets...\n')
    [~,result,~] = myClient.searchCollab('search', 'Dataset working title', 'limit', 1000, 'visibility', 'private');
    
    [~, isSelection] = sort([result.createDate], 'descend');
    collab_info = result(isSelection);

    if isempty(collab_info)
        error('SHAREbrain:UISelectDatasetCollab:NoCollabsFound', ...
            ['Could not find any data sharing collabs. You might not be a ', ...
            'member of any data sharing collabs. Please verify access ', ...
            'permissions with your curator'])
    end

    % parse description:
    expression = '(?<=Dataset working title: ).+?(?=\n)';
    datasetTitles = regexp([collab_info.description], expression, 'match', 'once')';

    selection = uim.dialog.searchSelectDlg(cellstr(datasetTitles), 'Select a Dataset');
    
    if isempty(selection)
        error('Aborted')
    end

    isSelection = strcmp(datasetTitles, selection);
    collabInfo = collab_info(isSelection);

    if isfield(options, "TargetFolder") && ~isempty(options.TargetFolder)
        filePath = fullfile(options.TargetFolder, 'ebrains_collab_info.json');
        utility.filewrite(filePath, jsonencode(collabInfo))
    end
end
