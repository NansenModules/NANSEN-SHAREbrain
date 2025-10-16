function fileSizeBytes = getLocalFileSize(filepath)
%getLocalFileSize Get file size of a file on the local file system
%
%   fileSizeBytes = getLocalFileSize(filepath) returns the filesize in
%   bytes for a file at the specified filepath.

    L = dir(filepath);
    if isempty(L)
        error('SHAREBRAIN:FileNotFound', ...
            'File not found: %s', filepath);
    elseif numel(L) > 1
        error('Multiple files/folders matched the given filepath')
    else
        fileSizeBytes = L.bytes;
    end
end