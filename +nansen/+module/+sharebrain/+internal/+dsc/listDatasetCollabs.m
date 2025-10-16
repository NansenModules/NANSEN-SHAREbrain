function collab_info = listDatasetCollabs(options)
% listDatasetCollabs - List dataset collabs

    arguments
        options.Verbose (1,1) logical = true
    end

    SEARCH_TERM = 'Dataset working title';

    if options.Verbose
        fprintf('Please wait, fetching dataset collabs...\n')
    end

    collabClient = ebrains.collaboratory.api.Collab();
    [~, result, ~] = collabClient.searchCollab(...
        'search', SEARCH_TERM, ...
        'limit', 1000, ...
        'visibility', 'private');
    
    [~, isSelection] = sort([result.createDate], 'descend');
    collab_info = result(isSelection);

    if isempty(collab_info)
        error('SHAREbrain:UISelectDatasetCollab:NoCollabsFound', ...
            ['Could not find any data sharing collabs. You might not be a ', ...
            'member of any data sharing collabs. Please verify access ', ...
            'permissions with your curator'])
    end
end
