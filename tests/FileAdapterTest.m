classdef FileAdapterTest < matlab.unittest.TestCase
%FileAdapterTest - Tests for the NWB and DelimitedText file adapters of the module
%
%   Each test writes a small file of the format and loads it with the
%   adapter. The ABF adapter needs a recorded ABF file, which there is no
%   way to write, and is tested on files downloaded from EBRAINS instead.
%
%   Run tests:
%       runtests('FileAdapterTest')

    properties
        Folder string
    end

    methods (TestMethodSetup)
        function createFolder(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.Folder = string(testCase.applyFixture(TemporaryFolderFixture).Folder);
        end
    end

    methods (Test)
        function testDelimitedTextReadsTabSeparatedColumns(testCase)
            filePath = fullfile(testCase.Folder, "trace.txt");
            writelines(["time" + char(9) + "voltage"; "0" + char(9) + "-65.5"; "0.1" + char(9) + "-64.25"], filePath)

            data = nansen.module.sharebrain.fileadapter.DelimitedText(char(filePath)).load();

            testCase.verifyClass(data, 'table')
            testCase.verifyEqual(data.Properties.VariableNames, {'time', 'voltage'})
            testCase.verifyEqual(data.voltage, [-65.5; -64.25])
        end

        function testDelimitedTextReadsCsv(testCase)
            filePath = fullfile(testCase.Folder, "positions.csv");
            writelines(["x,y"; "1,2"; "3,4"], filePath)

            data = nansen.module.sharebrain.fileadapter.DelimitedText(char(filePath)).load();

            testCase.verifyEqual(data.y, [2; 4])
        end

        function testNWBReturnsNwbFile(testCase)
            testCase.assumeEqual(exist('nwbRead', 'file'), 2, 'MatNWB is not on the path.')
            filePath = fullfile(testCase.Folder, "session.nwb");
            nwb = NwbFile( ...
                'session_description', 'A test session', ...
                'identifier', 'test-session', ...
                'session_start_time', datetime(2024, 1, 2, 3, 4, 5, 'TimeZone', 'UTC'));
            nwbExport(nwb, char(filePath))

            data = nansen.module.sharebrain.fileadapter.NWB(char(filePath)).load();

            testCase.verifyClass(data, 'NwbFile')
            testCase.verifyEqual(string(data.identifier), "test-session")
        end
    end
end
