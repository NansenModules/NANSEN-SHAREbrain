function [bucketInfo, cloneFolder] = findBucketInfo(filePath)
%findBucketInfo - The EBRAINS bucket of a cloned dataset that contains a file
%   [bucketInfo, cloneFolder] = nansen.module.sharebrain.ebrains.findBucketInfo(filePath)
%   looks for .ebrains-bucket.json in the folder of filePath and in each
%   folder above it, and reads the first one it finds. bucketInfo is a
%   struct with the fields bucket, prefix and datasetVersionId, and
%   cloneFolder is the folder that holds the file.
%
%   Both outputs are empty when no folder above filePath has the file.
%
%   See also nansen.module.sharebrain.ebrains.writeBucketInfo

    arguments
        filePath (1,1) string
    end

    bucketInfo = struct.empty;
    cloneFolder = "";

    folderPath = fileparts(filePath);
    while strlength(folderPath) > 0
        infoFilePath = fullfile(folderPath, nansen.module.sharebrain.constants.BucketInfoFilename);
        if isfile(infoFilePath)
            bucketInfo = jsondecode(fileread(infoFilePath));
            cloneFolder = folderPath;
            return
        end

        parentFolder = fileparts(folderPath);
        if parentFolder == folderPath % The root of the file system
            return
        end
        folderPath = parentFolder;
    end
end
