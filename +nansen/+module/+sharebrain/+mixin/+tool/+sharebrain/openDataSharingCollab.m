function openDataSharingCollab()

    filePath = nansen.module.sharebrain.internal.getCollabInfoFilepath();

    if ~isfile(filePath)
        error(...
            ['This project is not associated with any dataset collabs. ', ...
            'Please link to a dataset collab using the "Set Dataset" method']) % Todo: add error id, improve error message
    end
    collabInfo = jsondecode( fileread(filePath));

    baseUrl = ebrains.common.constant.CollabBaseUrl();
    collabUrl = baseUrl + "/" + collabInfo.link;

    web(collabUrl, '-browser')
end
