function writeBucketInfo(cloneFolder, bucketName, options)
%writeBucketInfo - Record which EBRAINS bucket a cloned dataset comes from
%   nansen.module.sharebrain.ebrains.writeBucketInfo(cloneFolder, bucketName)
%   writes the file .ebrains-bucket.json in cloneFolder. The file names the
%   Data Proxy bucket whose objects the empty files below cloneFolder stand
%   for, so that EbrainsBucketSource can download them.
%
%   writeBucketInfo(..., Prefix=PREFIX) records the folder of a bucket that
%   is shared with other datasets.
%
%   writeBucketInfo(..., DatasetVersionId=UUID) records the dataset version
%   in the EBRAINS Knowledge Graph that the files belong to.
%
%   The file holds a JSON object with the fields bucket, prefix and
%   datasetVersionId.
%
%   See also nansen.module.sharebrain.ebrains.findBucketInfo,
%   nansen.module.sharebrain.dataio.EbrainsBucketSource

    arguments
        cloneFolder (1,1) string {mustBeFolder}
        bucketName (1,1) string {mustBeNonzeroLengthText}
        options.Prefix (1,1) string = ""
        options.DatasetVersionId (1,1) string = ""
    end

    bucketInfo = struct( ...
        'bucket', bucketName, ...
        'prefix', options.Prefix, ...
        'datasetVersionId', options.DatasetVersionId);

    filePath = fullfile(cloneFolder, nansen.module.sharebrain.constants.BucketInfoFilename);
    writelines(jsonencode(bucketInfo, PrettyPrint=true), filePath)
end
