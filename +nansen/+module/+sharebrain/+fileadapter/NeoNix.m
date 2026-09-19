classdef NeoNix < nansen.dataio.FileAdapter
%NeoNix - File adapter for NIX files written by Neo (.nio, .nix)
%
%   sessionObject.loadData(variableName) returns the first block of the
%   file as a struct, in the form described in NeoPickle.
%
%   The file is read by Python with the packages Neo and nixio (see
%   readWithNeo).

    properties (Constant)
        DataType = 'struct'
    end

    properties (Constant, Hidden, Access = protected)
        SUPPORTED_FILE_TYPES = {'nio', 'nix'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            data = readWithNeo(obj.Filename, "nix");
        end
    end
end
