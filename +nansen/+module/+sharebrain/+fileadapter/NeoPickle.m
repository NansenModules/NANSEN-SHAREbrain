classdef NeoPickle < nansen.dataio.FileAdapter
%NeoPickle - File adapter for Python pickle files that hold a Neo block
%
%   sessionObject.loadData(variableName) returns the block as a struct with
%   the fields name, description, file_origin, rec_datetime, annotations
%   and segments. Each segment holds its analogsignals,
%   irregularlysampledsignals, spiketrains, events and epochs; times are in
%   seconds, sampling rates in Hz, and each signal gives its units as text.
%
%   The file is unpickled by Python with the package Neo (see
%   readWithNeo). A pickle runs code of the classes it holds when it is
%   read, so load only files from a source you trust, such as a published
%   dataset.

    properties (Constant)
        DataType = 'struct'
    end

    properties (Constant, Hidden, Access = protected)
        SUPPORTED_FILE_TYPES = {'pkl'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            data = readWithNeo(obj.Filename, "pickle");
        end
    end
end
