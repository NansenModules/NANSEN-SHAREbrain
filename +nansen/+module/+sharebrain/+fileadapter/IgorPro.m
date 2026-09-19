classdef IgorPro < nansen.dataio.FileAdapter
%IgorPro - File adapter for Igor Pro binary waves (.ibw) and packed experiments (.pxp)
%
%   sessionObject.loadData(variableName) returns the file as a Neo block
%   struct, in the form described in NeoPickle; the waves are the analog
%   signals of its segment.
%
%   The file is read by Python with the packages Neo and igor2 (see
%   readWithNeo).

    properties (Constant)
        DataType = 'struct'
    end

    properties (Constant, Hidden, Access = protected)
        SUPPORTED_FILE_TYPES = {'ibw', 'pxp'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            data = readWithNeo(obj.Filename, "igor");
        end
    end
end
