classdef ABF < nansen.dataio.FileAdapter
%ABF - File adapter for Axon Binary Files (ABF versions 1 and 2) recorded with pCLAMP
%
%   sessionObject.loadData(variableName) reads every channel and sweep of
%   the file and returns a struct with the fields
%       Data         - The samples. Episodic recordings give a
%                      samples x channels x sweeps array, gap-free
%                      recordings a samples x channels array, and
%                      event-driven variable-length recordings a cell array
%                      with one element per sweep.
%       SamplingRate - Samples per second of each channel
%       ChannelNames - 1 x channels string with the names of the channels
%       ChannelUnits - 1 x channels string with the units of the channels
%       Header       - The header struct returned by abfload
%
%   The file is read by abfload, written by Harald Hentschke and Forrest
%   Collman, which is in the private folder with its BSD licence.

    properties (Constant)
        DataType = 'struct'
    end

    properties (Constant, Hidden, Access = protected)
        SUPPORTED_FILE_TYPES = {'abf'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            [samples, samplingIntervalMicroseconds, header] = abfload(obj.Filename, ...
                'channels', 'a', 'sweeps', 'a', 'doDispInfo', false);

            % abfload gives channel names and units as a cell array for
            % ABF 2 files and as a padded char matrix for ABF 1 files
            data = struct( ...
                'Data', samples, ...
                'SamplingRate', 1e6 / samplingIntervalMicroseconds, ...
                'ChannelNames', reshape(strtrim(string(header.recChNames)), 1, []), ...
                'ChannelUnits', reshape(strtrim(string(header.recChUnits)), 1, []), ...
                'Header', header);
        end
    end
end
