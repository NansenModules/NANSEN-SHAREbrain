function uploadFileToBucket(filePath, relativeFilePath, bucketName)
    
    if strncmp(char(relativeFilePath), filesep, 1)
        relativeFilePath = char(relativeFilePath);
        relativeFilePath = relativeFilePath(2:end);
    end

    BASE_API_URL = nansen.module.sharebrain.constant.DataProxyBaseUrl;
    endpointPath = sprintf("buckets/%s/data/%s", bucketName, relativeFilePath);

    apiURL = BASE_API_URL + endpointPath;

    for i = 1:5
        try
            uploadURL = getUploadUrl(apiURL);
        catch exception
            % Todo: proper error handling. may fail for other reasons
            % Reset access token and try again
            setenv('EBRAINS_ACCESS_TOKEN', '');
            if i == 5
                rethrow(exception)
            end
        end
    end

    [wasSuccess, response] = uploadFile(filePath, uploadURL, ShowFilename=true);

    if ~wasSuccess
        % Handle the upload failure
        warning('Failed to upload file: %s', uploadURL);
        % Todo: improve error handling, parse response and provide more
        % detailed diagnostics
    end
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
    tokenManager = ebrains.getTokenManager();
    accessToken = tokenManager.AccessToken;
end
