classdef FileAdapterTest < matlab.unittest.TestCase
%FileAdapterTest - Tests for the file adapters of the module
%
%   Each test writes a small file of the format and loads it with the
%   adapter: DelimitedText, JSON, XML, NIfTI, NWB, and NeoPickle and
%   NeoNix, whose files are written with Neo in Python. ABF and IgorPro
%   are not tested here: MATLAB cannot write either format.
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

        function testDelimitedTextKeepsCommentHeader(testCase)
            filePath = fullfile(testCase.Folder, "trace_ch5_578.dat");
            writelines(["#"; "# DATE#17/09/2015 (5)"; "# STIMULUSDEF##" + char(9) + "Name" + char(9) + "Units"; ...
                "0" + char(9) + "2.25e-08"; "0.2" + char(9) + "2.875e-08"], filePath)

            data = nansen.module.sharebrain.fileadapter.DelimitedText(char(filePath)).load();

            testCase.verifyEqual(width(data), 2)
            testCase.verifyEqual(data{:, 2}, [2.25e-08; 2.875e-08])
            testCase.verifyTrue(contains(data.Properties.Description, "DATE#17/09/2015"))
        end

        function testDelimitedTextSkipsCommentLinesAfterData(testCase)
            filePath = fullfile(testCase.Folder, "positions.csv");
            writelines(["x,y"; "1,2"; "# pause"; "3,4"], filePath)

            data = nansen.module.sharebrain.fileadapter.DelimitedText(char(filePath)).load();

            testCase.verifyEqual(data.Properties.VariableNames, {'x', 'y'})
            testCase.verifyEqual(data.y, [2; 4])
        end

        function testDelimitedTextReadsCsv(testCase)
            filePath = fullfile(testCase.Folder, "positions.csv");
            writelines(["x,y"; "1,2"; "3,4"], filePath)

            data = nansen.module.sharebrain.fileadapter.DelimitedText(char(filePath)).load();

            testCase.verifyEqual(data.y, [2; 4])
        end

        function testJSONReturnsDecodedContent(testCase)
            filePath = fullfile(testCase.Folder, "sidecar.json");
            writelines('{"RepetitionTime": 2.0, "SliceTiming": [0, 1]}', filePath)

            data = nansen.module.sharebrain.fileadapter.JSON(char(filePath)).load();

            testCase.verifyEqual(data.RepetitionTime, 2)
            testCase.verifyEqual(data.SliceTiming, [0; 1])
        end

        function testXMLReturnsElementsAndAttributes(testCase)
            filePath = fullfile(testCase.Folder, "spatial_data.xml");
            writelines('<registration version="2"><scale unit="um">0.5</scale></registration>', filePath)

            data = nansen.module.sharebrain.fileadapter.XML(char(filePath)).load();

            testCase.verifyEqual(data.versionAttribute, 2)
            testCase.verifyEqual(data.scale.Text, 0.5)
            testCase.verifyEqual(data.scale.unitAttribute, "um")
        end

        function testNIfTIReadsCompressedVolume(testCase)
            testCase.assumeEqual(exist('niftiwrite', 'file'), 2, 'The Image Processing Toolbox is not installed.')
            volume = reshape(single(1:24), 2, 3, 4);
            niftiwrite(volume, char(fullfile(testCase.Folder, "run.nii")), 'Compressed', true)

            data = nansen.module.sharebrain.fileadapter.NIfTI( ...
                char(fullfile(testCase.Folder, "run.nii.gz"))).load();

            testCase.verifyEqual(data.Data, volume)
            testCase.verifyEqual(data.Header.ImageSize, [2, 3, 4])
        end

        function testNeoPickleReturnsSignalsAndSpikes(testCase)
            filePath = testCase.writeNeoBlock("block.pkl", "pickle");

            block = nansen.module.sharebrain.fileadapter.NeoPickle(char(filePath)).load();

            testCase.verifyNeoBlock(block)
        end

        function testNeoPickleKeepsListsAsCellArrays(testCase)
            % An empty segment, event labels, a channel annotation with a
            % missing value, and two annotation keys that give the same
            % MATLAB field name
            filePath = testCase.writeNeoBlock("lists.pkl", "pickle", [
                "block = neo.Block(name='lists', **{'a-b': 1, 'a_b': 2})"
                "segment = neo.Segment(name='trial 1')"
                "segment.analogsignals.append(neo.AnalogSignal(np.zeros((3, 2)), units='mV', sampling_rate=1 * pq.kHz,"
                "    array_annotations={'note': np.array([None, 'x'], dtype=object)}))"
                "segment.events.append(neo.Event([1, 2] * pq.s, labels=np.array(['start', 'stop'])))"
                "block.segments.extend([segment, neo.Segment(name='empty')])"]);

            block = nansen.module.sharebrain.fileadapter.NeoPickle(char(filePath)).load();

            testCase.verifySize(block.segments, [1, 2])
            testCase.verifyClass(block.segments{2}.analogsignals, 'cell')
            testCase.verifyEmpty(block.segments{2}.analogsignals)
            testCase.verifyEqual(block.segments{1}.events{1}.labels, {'start', 'stop'})
            testCase.verifyEqual(block.segments{1}.analogsignals{1}.array_annotations.note, {'', 'x'})
            % Python integers arrive as int64
            testCase.verifyEqual(double([block.annotations.a_b, block.annotations.a_b_2]), [1, 2])
        end

        function testNeoNixReturnsSignalsAndSpikes(testCase)
            filePath = testCase.writeNeoBlock("block.nio", "nix");

            block = nansen.module.sharebrain.fileadapter.NeoNix(char(filePath)).load();

            testCase.verifyNeoBlock(block)
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

    methods (Access = private)
        function filePath = writeNeoBlock(testCase, fileName, fileFormat, blockLines)
            % Writes the block that blockLines build in Python. The default
            % is a block with one segment that holds a 2-channel signal of
            % 100 samples at 1 kHz in mV, and a spike train at 0.1 and 0.5 s
            if nargin < 4
                blockLines = [
                    "block = neo.Block(name='test block')"
                    "segment = neo.Segment(name='trial 1')"
                    "segment.analogsignals.append(neo.AnalogSignal(np.arange(200).reshape(100, 2) * 1.0,"
                    "    units='mV', sampling_rate=1 * pq.kHz, name='vm'))"
                    "segment.spiketrains.append(neo.SpikeTrain([0.1, 0.5] * pq.s, t_stop=1 * pq.s, name='unit 1'))"
                    "block.segments.append(segment)"];
            end
            python = string(pyenv().Executable);
            testCase.assumeNotEmpty(char(python), 'No Python is set up for MATLAB.')
            [status, ~] = system(sprintf('"%s" -c "import neo, quantities"', python));
            testCase.assumeEqual(status, 0, 'Neo is not installed in the Python for MATLAB.')

            filePath = fullfile(testCase.Folder, fileName);
            scriptPath = fullfile(testCase.Folder, "write_block.py");
            writelines([
                "import pickle, sys"
                "import numpy as np, quantities as pq, neo"
                blockLines
                "path, file_format = sys.argv[1], sys.argv[2]"
                "if file_format == 'pickle':"
                "    pickle.dump(block, open(path, 'wb'))"
                "else:"
                "    writer = neo.io.NixIO(path, mode='ow')"
                "    writer.write_block(block)"
                "    writer.close()"], scriptPath)
            [status, output] = system(sprintf('"%s" "%s" "%s" %s', python, scriptPath, filePath, fileFormat));
            testCase.assumeEqual(status, 0, "Writing the test block failed: " + output)
        end

        function verifyNeoBlock(testCase, block)
            segment = block.segments{1};
            signal = segment.analogsignals{1};
            testCase.verifyEqual(size(signal.data), [100, 2])
            testCase.verifyEqual(signal.sampling_rate, 1000)
            testCase.verifyEqual(strtrim(string(signal.units)), "mV")
            testCase.verifyEqual(double(segment.spiketrains{1}.times(:))', [0.1, 0.5], 'AbsTol', 1e-12)
        end
    end
end
