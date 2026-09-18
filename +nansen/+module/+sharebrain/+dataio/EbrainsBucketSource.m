classdef EbrainsBucketSource < nansen.dataio.RemoteFileSource
%EbrainsBucketSource - Source of the files of a dataset cloned from an EBRAINS bucket
%
%   A dataset cloned with sharebrain.cloneKGDataset has an empty file for
%   every object of its EBRAINS Data Proxy bucket, and names the bucket in
%   the file .ebrains-bucket.json in the root folder of the clone. This
%   source counts an empty file below such a folder as stored online, and
%   downloads it with ebrains.bucket.downloadFile. The name of the object
%   is the path of the file relative to the root folder of the clone,
%   because the clone keeps the folder of a shared bucket in its paths.
%
%   Make it the source of online files of the current project:
%       project = nansen.getCurrentProject();
%       project.setRemoteFileSource("nansen.module.sharebrain.dataio.EbrainsBucketSource")
%
%   source = EbrainsBucketSource(rootPath, Downloader=FCN) downloads with
%   FCN(bucketName, objectName, targetFile) instead.
%
%   See also nansen.dataio.RemoteFileSource,
%   nansen.module.sharebrain.ebrains.writeBucketInfo

    properties (SetAccess = private)
        % Downloader - Function that downloads an object, called as
        % Downloader(bucketName, objectName, targetFile)
        Downloader function_handle
    end

    methods
        function obj = EbrainsBucketSource(rootPath, options)
            arguments
                rootPath (1,1) string
                options.Downloader (1,1) function_handle = @downloadWithProgressInCommandWindow
            end
            obj@nansen.dataio.RemoteFileSource(rootPath)
            obj.Downloader = options.Downloader;
        end

        function tf = isOnlineOnly(~, filePath)
            fileInfo = dir(filePath);
            tf = isscalar(fileInfo) && fileInfo.bytes == 0 ...
                && ~isempty(nansen.module.sharebrain.ebrains.findBucketInfo(filePath));
        end

        function download(obj, filePath)
            [bucketInfo, cloneFolder] = nansen.module.sharebrain.ebrains.findBucketInfo(filePath);
            if isempty(bucketInfo)
                error('SHAREbrain:EbrainsBucketSource:NotInClone', ...
                    ['No folder above "%s" has the file %s, so the bucket of the file is not known. ', ...
                     'Clone the dataset with sharebrain.cloneKGDataset, or record its bucket with ', ...
                     'nansen.module.sharebrain.ebrains.writeBucketInfo.'], ...
                    filePath, nansen.module.sharebrain.constants.BucketInfoFilename)
            end

            relativePath = extractAfter(string(filePath), strlength(cloneFolder) + 1);
            objectName = replace(relativePath, filesep, "/");
            obj.Downloader(string(bucketInfo.bucket), objectName, string(filePath))
        end
    end
end

function downloadWithProgressInCommandWindow(bucketName, objectName, targetFile)
% A dialog box would need a display, which a batch session or an agent
% does not have
    ebrains.bucket.downloadFile(bucketName, objectName, targetFile, DisplayMode="Command Window")
end
