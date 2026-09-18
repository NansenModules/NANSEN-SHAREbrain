classdef NWB < nansen.dataio.FileAdapter
%NWB - File adapter for Neurodata Without Borders (NWB) files
%
%   sessionObject.loadData(variableName) returns the NwbFile object that
%   nwbRead of MatNWB creates for the file. The object reads datasets
%   lazily, so loading is fast and the data of a dataset is read when it
%   is indexed or loaded with its load method.
%
%   MatNWB must be on the MATLAB path. nwbRead generates the type classes
%   from the schema stored in the file, so files written with different
%   NWB versions can be read.

    properties (Constant)
        DataType = 'NwbFile'
    end

    properties (Constant, Hidden, Access = protected)
        SUPPORTED_FILE_TYPES = {'nwb'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            data = nwbRead(obj.Filename);
        end
    end
end
