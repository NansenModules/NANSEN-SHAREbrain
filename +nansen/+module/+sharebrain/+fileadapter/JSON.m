classdef JSON < nansen.dataio.FileAdapter
%JSON - File adapter for JSON files
%
%   sessionObject.loadData(variableName) returns the content of the file
%   decoded with jsondecode: objects become structs and arrays become
%   arrays or cell arrays.

    properties (Constant)
        DataType = 'struct'
    end

    properties (Constant, Hidden, Access = protected)
        SUPPORTED_FILE_TYPES = {'json'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            data = jsondecode(fileread(obj.Filename));
        end
    end
end
