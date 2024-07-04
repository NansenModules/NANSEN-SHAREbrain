function uploadFileToBucket(filePath, relativeFilePath, bucketName)
    
    if strncmp(char(relativeFilePath), filesep, 1)
        relativeFilePath = char(relativeFilePath);
        relativeFilePath = relativeFilePath(2:end);
    end

    BASE_API_URL = nansen.module.sharebrain.constant.DataProxyBaseUrl;
    endpointPath = sprintf("buckets/%s/data/%s", bucketName, relativeFilePath);

    apiURL = BASE_API_URL + endpointPath;

    finished = false;
    while ~finished
        try
            uploadURL = getUploadUrl(apiURL);
            finished = true;
        catch ME
            % Reset access token and try again
            setenv('EBRAINS_ACCESS_TOKEN', '');
        end
    end

    [wasSuccess, response] = uploadFile(filePath, uploadURL, ShowFilename=true);
end

function uploadURL = getUploadUrl(apiURL)

    accessToken = getToken();

    header = matlab.net.http.HeaderField(...
        "accept", "application/json", ...
        "Authorization", "Bearer " + accessToken);

    warning('off', 'MATLAB:http:BodyExpectedFor')
    method = matlab.net.http.RequestMethod.PUT;
    req = matlab.net.http.RequestMessage(method, header, []);
    [resp, ~, ~] = req.send(apiURL);
    warning('on', 'MATLAB:http:BodyExpectedFor')
    
    if resp.StatusCode ~= matlab.net.http.StatusCode.OK
        error(string(resp.StatusLine))
    else
        uploadURL = resp.Body.Data.url;
    end
end

function accessToken = getToken()
    authClient = ebrains.iam.AuthenticationClient.instance();    
    accessToken = authClient.AccessToken;
    return
    
    accessToken = getenv('EBRAINS_ACCESS_TOKEN');
    if isempty(accessToken)
        accessToken = nansen.module.sharebrain.services.ebrains.uiGetToken();
    end
end