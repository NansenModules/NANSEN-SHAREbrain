function uploadProjectData(options)
%uploadProjectData - Upload a whole data location to the EBRAINS bucket
%   uploadProjectData() uploads every file under the Processed data
%   location of the current project to the data proxy bucket of the
%   EBRAINS collab the project is linked to. Files already present in
%   the bucket are skipped, and spaces in file names are replaced with
%   underscores.
%
%   uploadProjectData(DataLocationName=NAME) uploads the data location
%   NAME instead of Processed.
%
%   See also nansen.module.sharebrain.services.ebrains.uploadFileToBucket,
%   nansen.module.sharebrain.internal.ensureCollabInfo

%   Todo:
%   [ ] Consider whether source data location can also be retrieved from 
%       Project settings / preferences. Relevant if passing argument is
%       unpractical

    arguments
        options.Waitbar = []
        options.DataLocationName (1,1) string = "Processed"
    end

    import nansen.module.sharebrain.services.ebrains.uploadFileToBucket

    % Find the bucket name
    collabInfo = nansen.module.sharebrain.internal.ensureCollabInfo();
    bucketName = collabInfo.name;

    % List all files in the Data Location
    dlm = nansen.DataLocationModel;
    dataLocation = dlm.getDataLocation(options.DataLocationName);

    rootDataFolder = dataLocation.RootPath.Value;
    localFiles = recursiveDir(rootDataFolder, ...
        'Type', 'file', ...
        'OutputType', 'RelativeFilePath');

    % Check if files already exists in bucket
    bucketManifest = ebrains.bucket.listBucketObjects(bucketName);
    if isempty(bucketManifest)
        existingBucketFiles = string.empty;
    else
        existingBucketFiles = string({bucketManifest.name})';
    end
    expectedBucketFilenames = fullfile("data", strrep(localFiles, " ", "_"));   % NB: data is prepended in uploadFileToBucket
    [~, diffIndices] = setdiff(expectedBucketFilenames, existingBucketFiles, 'stable');
    
    filesToUpload = localFiles(diffIndices);

    if isempty(filesToUpload)
        fprintf('No new files to upload.\n')
        return
    end

    % Start upload
    h = waitbar(0, sprintf('Uploading %d files...', numel(filesToUpload)), ...
        'Name', 'Uploading files...'); % Todo, get from options.

    for i = 1:numel(filesToUpload)
        currentFilePath = filesToUpload{i};
        absoluteLocalPath = fullfile(rootDataFolder, currentFilePath);
        filenameForBucket = strrep(currentFilePath, ' ', '_');
        
        uploadFileToBucket(absoluteLocalPath, filenameForBucket, bucketName)
        waitbar(i/numel(filesToUpload), h, sprintf('Uploaded %d/%d files', i, numel(filesToUpload)))
    end

    delete(h)
end
