function uploadFileToBucket(localFilePath, bucketFilePath, bucketName, options)
%uploadFileToBucket - Upload one file to an EBRAINS data proxy bucket
%   uploadFileToBucket(localFilePath, bucketFilePath, bucketName) uploads the local
%   file at localFilePath into the bucket named bucketName, storing it
%   at bucketFilePath. bucketFilePath is relative to the bucket's data
%   folder, so the same path round-trips through downloadFileFromBucket.
%
%   uploadFileToBucket(..., ShowWaitbar=TF) reports progress in a dialog
%   box rather than the command window.
%
%   See also downloadFileFromBucket,
%   nansen.module.sharebrain.constant.DataProxyBaseUrl

    arguments
        localFilePath
        bucketFilePath
        bucketName
        options.ShowWaitbar (1,1) logical = false
    end

    if strncmp(char(bucketFilePath), filesep, 1)
        bucketFilePath = char(bucketFilePath);
        bucketFilePath = bucketFilePath(2:end);
    end

    BASE_API_URL = nansen.module.sharebrain.constant.DataProxyBaseUrl;
    endpointPath = sprintf("buckets/%s/data/%s", bucketName, bucketFilePath);

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

    if options.ShowWaitbar
        displayMode = 'Dialog Box';
    else
        displayMode = 'Command Window';
    end

    [wasSuccess, response] = uploadFile(localFilePath, uploadURL, ShowFilename=true, DisplayMode=displayMode);

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
