function bucketId = uiGetBucketId()
    
    myClient = ebrains.collaboratory.api.Collab();
    [~,result,~] = myClient.searchCollab('search', 'Dataset working title', 'limit', 1000, 'visibility', 'private');
    
    [~, isSelection] = sort([result.createDate], 'descend');
    collab_info = result(isSelection);

    % parse description:
    expression = '(?<=Dataset working title: ).+?(?=\n)';
    datasetTitles = regexp([collab_info.description], expression, 'match', 'once')';

    selection = uim.dialog.searchSelectDlg(cellstr(datasetTitles), 'Select a Dataset');

    isSelection = strcmp(datasetTitles, selection);
    bucketId = collab_info(isSelection).title;

    project = nansen.getCurrentProject();
    configFolder = project.getConfigurationFolder();
    
    % Save to project configuration
    S = collab_info(isSelection);
    filePath = fullfile(configFolder, 'ebrains_collab_info.json');
    utility.filewrite(filePath, jsonencode(S))
end

% %     BASE_URL = "https://wiki.ebrains.eu/rest/";
% % 
% %     bucketId = inputdlg('Please enter your bucket ID');
% % 
% %     webOpts = weboptions;
% %     webOpts.HeaderFields = ["Authorization", sprintf("Bearer %s", myClient.bearerToken)];
% %     webOpts.HeaderFields = ["Authorization", sprintf("Bearer %s", token)];
% %     collabResp = webread(BASE_URL+"v1/collabs", 'limit', 300, 'search', 'd-','visibility', 'private', webOpts);
% % 
% %     [~, idx] = sort([collabResp.createDate]);
% %     collab_info = collabResp(idx);
% % 
% %     timestamp = [collab_info.createDate] / 1000; % Convert milliseconds to seconds
% %     datetimeObj = num2cell( datetime(timestamp, 'ConvertFrom', 'posixtime') );
% %     [collab_info(:).createDate] = deal(datetimeObj{:});
% %     struct2table(collab_info)
% % end