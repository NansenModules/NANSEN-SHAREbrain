function openDataSharingCollab()

    collabInfo = nansen.module.sharebrain.internal.ensureCollabInfo();

    baseUrl = ebrains.common.constant.CollabBaseUrl();
    collabUrl = baseUrl + "/" + collabInfo.link;

    web(collabUrl, '-browser')
end
