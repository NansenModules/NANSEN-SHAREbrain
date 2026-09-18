classdef DelimitedText < nansen.dataio.FileAdapter
%DelimitedText - File adapter for text files with columns separated by a delimiter
%
%   sessionObject.loadData(variableName) returns the file as a table, read
%   with readtable. readtable detects the delimiter, the number of header
%   lines and whether the first line holds column names.

    properties (Constant)
        DataType = 'table'
    end

    properties (Constant, Hidden, Access = protected)
        SUPPORTED_FILE_TYPES = {'txt', 'csv', 'tsv'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            data = readtable(obj.Filename);
        end
    end
end
