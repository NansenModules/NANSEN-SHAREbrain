function block = readWithNeo(filePath, fileFormat)
%readWithNeo - Read a file with the Python package Neo and return its block as a struct
%   block = readWithNeo(filePath, fileFormat) runs neo_to_mat.py, in this
%   folder, with the Python interpreter that pyenv names, and loads the
%   .mat file that it writes. fileFormat is "pickle", "nix" or "igor".
%
%   Python runs as a separate process rather than inside MATLAB: reading
%   NIX files loads h5py, whose HDF5 library can conflict with the one
%   MATLAB uses.
%
%   The Python environment needs neo, quantities and scipy, and nixio for
%   NIX files and igor2 for Igor files.

    arguments
        filePath (1,1) string {mustBeFile}
        fileFormat (1,1) string {mustBeMember(fileFormat, ["pickle", "nix", "igor"])}
    end

    pythonExecutable = string(pyenv().Executable);
    if strlength(pythonExecutable) == 0
        error('SHAREbrain:ReadWithNeo:NoPython', ...
            ['No Python interpreter is set up for MATLAB. Set one with pyenv, for example ', ...
             'pyenv(Version="/path/to/python3"), with the packages neo, quantities and scipy.'])
    end

    helperScript = fullfile(fileparts(mfilename('fullpath')), 'neo_to_mat.py');
    matFile = string(tempname) + ".mat";
    cleanup = onCleanup(@() deleteIfFile(matFile));

    command = sprintf('"%s" "%s" "%s" %s "%s"', pythonExecutable, helperScript, ...
        filePath, fileFormat, matFile);
    [status, output] = system(command);
    if status ~= 0
        error('SHAREbrain:ReadWithNeo:ReadFailed', ...
            'Neo could not read "%s" as a %s file:\n%s', filePath, fileFormat, strtrim(output))
    end

    S = load(matFile);
    block = S.block;
end

function deleteIfFile(filePath)
    if isfile(filePath)
        delete(filePath)
    end
end
