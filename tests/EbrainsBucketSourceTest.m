classdef EbrainsBucketSourceTest < matlab.unittest.TestCase
%EbrainsBucketSourceTest - Tests for EbrainsBucketSource and the bucket info file of a clone
%
%   Each test makes a clone folder with a .ebrains-bucket.json and empty
%   placeholder files, as sharebrain.cloneKGDataset leaves them. The
%   downloader is a fake that writes the bucket and object name it is
%   given into the target file, so no test connects to EBRAINS.
%
%   Run tests:
%       runtests('EbrainsBucketSourceTest')

    properties
        CloneFolder string
        OutsideFolder string
    end

    methods (TestMethodSetup)
        function createClone(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.CloneFolder = string(testCase.applyFixture(TemporaryFolderFixture).Folder);
            testCase.OutsideFolder = string(testCase.applyFixture(TemporaryFolderFixture).Folder);

            nansen.module.sharebrain.ebrains.writeBucketInfo(testCase.CloneFolder, "my-bucket", ...
                Prefix="shared-folder/", DatasetVersionId="0b4a1f5e-0000-4000-8000-000000000000");

            mkdir(fullfile(testCase.CloneFolder, "shared-folder", "sub"))
            createFile(fullfile(testCase.CloneFolder, "shared-folder", "sub", "cell_1a.abf"), "")
            createFile(fullfile(testCase.CloneFolder, "shared-folder", "downloaded.txt"), "content")
            createFile(fullfile(testCase.OutsideFolder, "empty.abf"), "")
        end
    end

    methods (Test)
        function testFindBucketInfoReadsFileAboveFile(testCase)
            [bucketInfo, cloneFolder] = nansen.module.sharebrain.ebrains.findBucketInfo( ...
                fullfile(testCase.CloneFolder, "shared-folder", "sub", "cell_1a.abf"));

            testCase.verifyEqual(string(bucketInfo.bucket), "my-bucket")
            testCase.verifyEqual(string(bucketInfo.prefix), "shared-folder/")
            testCase.verifyEqual(cloneFolder, testCase.CloneFolder)
        end

        function testFindBucketInfoOutsideCloneIsEmpty(testCase)
            bucketInfo = nansen.module.sharebrain.ebrains.findBucketInfo( ...
                fullfile(testCase.OutsideFolder, "empty.abf"));

            testCase.verifyEmpty(bucketInfo)
        end

        function testEmptyFileInCloneIsOnlineOnly(testCase)
            source = testCase.createSource();

            testCase.verifyTrue(source.isOnlineOnly( ...
                fullfile(testCase.CloneFolder, "shared-folder", "sub", "cell_1a.abf")))
        end

        function testFileWithContentIsNotOnlineOnly(testCase)
            source = testCase.createSource();

            testCase.verifyFalse(source.isOnlineOnly( ...
                fullfile(testCase.CloneFolder, "shared-folder", "downloaded.txt")))
        end

        function testEmptyFileOutsideCloneIsNotOnlineOnly(testCase)
            source = testCase.createSource();

            testCase.verifyFalse(source.isOnlineOnly(fullfile(testCase.OutsideFolder, "empty.abf")))
        end

        function testDownloadRequestsObjectAtPathInClone(testCase)
            % The clone keeps the folder of a shared bucket in its paths, so
            % the object name is the path relative to the clone folder
            source = testCase.createSource();
            filePath = fullfile(testCase.CloneFolder, "shared-folder", "sub", "cell_1a.abf");

            source.download(filePath)

            testCase.verifyEqual(strtrim(string(fileread(filePath))), ...
                "my-bucket shared-folder/sub/cell_1a.abf")
        end

        function testDownloadOutsideCloneErrors(testCase)
            source = testCase.createSource();

            testCase.verifyError(@() source.download(fullfile(testCase.OutsideFolder, "empty.abf")), ...
                'SHAREbrain:EbrainsBucketSource:NotInClone')
        end
    end

    methods (Access = private)
        function source = createSource(testCase)
            source = nansen.module.sharebrain.dataio.EbrainsBucketSource(testCase.CloneFolder, ...
                Downloader=@writeRequestIntoTarget);
        end
    end
end

function writeRequestIntoTarget(bucketName, objectName, targetFile)
    writelines(bucketName + " " + objectName, targetFile)
end

function createFile(filePath, content)
    fileID = fopen(filePath, "w");
    fprintf(fileID, "%s", content);
    fclose(fileID);
end
