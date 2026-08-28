function downloadFileFromBucket(localFilePath, bucketFilePath, bucketName, progressDisplay)
%downloadFileFromBucket - Download one file from an EBRAINS bucket
%   downloadFileFromBucket(localFilePath, bucketFilePath, bucketName) downloads the
%   file stored at bucketFilePath in the Swift object storage bucket
%   named bucketName and writes it to localFilePath. bucketFilePath is
%   relative to the bucket's data folder, matching uploadFileToBucket,
%   so the same path round-trips through both functions.
%
%   When the transfer fails, a local file whose size does not match the
%   size reported by the server is deleted and replaced with an empty
%   file before the original error is rethrown.
%
%   See also uploadFileToBucket,
%   nansen.module.sharebrain.constant.DataProxyBaseUrl
    
    if strncmp(char(bucketFilePath), filesep, 1)
        bucketFilePath = char(bucketFilePath);
        bucketFilePath = bucketFilePath(2:end);
    end

    BASE_API_URL = nansen.module.sharebrain.constant.DataProxyBaseUrl;
    endpointPath = sprintf("buckets/%s/data/%s", bucketName, bucketFilePath);

    apiURL = BASE_API_URL + endpointPath;

    disp('starting download')

    % finished = false;
    % while ~finished
    %try
        %downloadURL = getDownloadUrl(apiURL, useToken=false);

        try
            webFileSize = nansen.module.sharebrain.internal.fileio.getWebFileSize(apiURL);
            [localFilePath] = downloadFile(localFilePath, apiURL, ShowFilename=true);
        catch ME
            fileSize = nansen.module.sharebrain.internal.fileio.getLocalFileSize(localFilePath);
            if fileSize ~= webFileSize
                delete(localFilePath)
                localFilePath = strrep(localFilePath, ' ', '\ ');
                [status, msg] = system( sprintf('touch %s', localFilePath ));
            end
            rethrow(ME)
        end


        %task.concrete.downloadFile(localFilePath, apiURL, 'ProgressDisplay', progressDisplay)
        finished = true;
    %catch ME
        % Reset access token and try again
        setenv('EBRAINS_ACCESS_TOKEN', '');
    %end
    % end

    %[localFilePath] = downloadFile(localFilePath, downloadURL, ShowFilename=true);
end

function downloadURL = getDownloadUrl(apiURL, options)
    arguments
        apiURL (1,1) string
        options.useToken (1,1) logical = false
    end

    if options.useToken
        accessToken = getToken();
    
        header = matlab.net.http.HeaderField(...
            "accept", "application/json", ...
            "Authorization", "Bearer " + accessToken);
    else
        header=[];
    end

    warning('off', 'MATLAB:http:BodyExpectedFor')
    method = matlab.net.http.RequestMethod.GET;
    req = matlab.net.http.RequestMessage(method, header, []);
    [resp, ~, ~] = req.send(apiURL);
    warning('on', 'MATLAB:http:BodyExpectedFor')
    
    if resp.StatusCode ~= matlab.net.http.StatusCode.OK
        error(string(resp.StatusLine))
    else
        downloadURL = resp.Body.Data.url;
    end
end

function accessToken = getToken()   
    accessToken = getenv('EBRAINS_ACCESS_TOKEN');
    if isempty(accessToken)
        accessToken = nansen.module.sharebrain.services.ebrains.uiGetToken();
    end
end