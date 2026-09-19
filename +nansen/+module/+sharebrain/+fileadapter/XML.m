classdef XML < nansen.dataio.FileAdapter
%XML - File adapter for XML files
%
%   sessionObject.loadData(variableName) returns the content of the file
%   as a struct, read with readstruct: elements become fields, and the
%   attributes of an element become fields whose names end in Attribute.

    properties (Constant)
        DataType = 'struct'
    end

    properties (Constant, Hidden, Access = protected)
        SUPPORTED_FILE_TYPES = {'xml'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            data = readstruct(obj.Filename, 'FileType', 'xml');
        end
    end
end
