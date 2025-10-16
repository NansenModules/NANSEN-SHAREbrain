function fetchCollabInfo(collabId)
% fetchCollabInfo - Fetch info / metadata for a Data Sharing Collab
    arguments
        collabId (1,1) string {nansen.module.sharebrain.internal.validator.mustBeDataSharingCollabName}
    end

    collabClient = ebrains.collaboratory.api.Collab();
    [status, collabInfo] = collabClient.getCollab(collabId);
    if status ~= matlab.net.http.StatusCode.OK
        errorInfo = jsondecode(collabInfo);
        error('SHAREBRAIN:FetchCollab:FailedToGetCollab', ...
            'Something went wrong when fetching collab. Reason: \n%s', ...
            sprintf("%s: %s", status, errorInfo.description))
    end
end
