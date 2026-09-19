classdef DelimitedText < nansen.dataio.FileAdapter
%DelimitedText - File adapter for text files with columns separated by a delimiter
%
%   sessionObject.loadData(variableName) returns the file as a table, read
%   with readtable. readtable detects the delimiter, the number of header
%   lines and whether the first line holds column names.
%
%   Lines that start with # are comments. The comment lines at the top of
%   a file, such as the protocol, stimulus and units that the derived
%   traces of several HBP datasets start with, are joined in the table's
%   Properties.Description.

    properties (Constant)
        DataType = 'table'
    end

    properties (Constant, Hidden, Access = protected)
        % Not .dat, which is binary in some datasets; a project assigns
        % this adapter to .dat files of text by name
        SUPPORTED_FILE_TYPES = {'txt', 'csv', 'tsv'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            data = readtable(obj.Filename, 'CommentStyle', '#');
            header = readCommentHeader(obj.Filename);
            if ~isempty(header)
                data.Properties.Description = strjoin(header, newline);
            end
        end
    end
end

function header = readCommentHeader(filePath)
%readCommentHeader - The lines that start with # at the top of a file
    header = strings(0, 1);
    fileID = fopen(filePath, 'r');
    closeFile = onCleanup(@() fclose(fileID));
    line = fgetl(fileID);
    while ischar(line) && startsWith(strtrim(line), "#")
        header(end+1, 1) = string(line); %#ok<AGROW>
        line = fgetl(fileID);
    end
end
