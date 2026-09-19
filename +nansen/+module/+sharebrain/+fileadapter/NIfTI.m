classdef NIfTI < nansen.dataio.FileAdapter
%NIfTI - File adapter for NIfTI images (.nii and .nii.gz)
%
%   sessionObject.loadData(variableName) returns a struct with the fields
%       Data   - The image, as niftiread reads it: x-y-z for a volume and
%                x-y-z-t for a series of volumes
%       Header - The header, as niftiinfo reads it, with the voxel size
%                (PixelDimensions), units (SpaceUnits, TimeUnits) and the
%                transform to scanner space (Transform)
%
%   Reading needs the Image Processing Toolbox (niftiread, niftiinfo).

    properties (Constant)
        DataType = 'struct'
    end

    properties (Constant, Hidden, Access = protected)
        SUPPORTED_FILE_TYPES = {'nii', 'nii.gz'}
    end

    methods (Access = protected)
        function data = readData(obj, varargin)
            header = niftiinfo(obj.Filename);
            data = struct('Data', niftiread(header), 'Header', header);
        end
    end
end
