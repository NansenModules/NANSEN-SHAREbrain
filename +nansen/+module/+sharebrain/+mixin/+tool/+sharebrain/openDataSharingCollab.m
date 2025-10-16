function openDataSharingCollab()

    filePath = nansen.module.sharebrain.internal.getCollabInfoFilepath();

    if ~isfile(filePath)
        nansen.module.sharebrain.internal.uiGetBucketId()
    end
    collabInfo = jsondecode( fileread(filePath));

    baseUrl = ebrains.common.constant.CollabBaseUrl();
    collabUrl = baseUrl + "/" + collabInfo.link;

    web(collabUrl, '-browser')
end
