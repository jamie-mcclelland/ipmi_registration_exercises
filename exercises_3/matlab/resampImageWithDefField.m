function resamp_img = resampImageWithDefField(source_img, def_field, interp_method)
%function to resample a 2D image with a 2D deformation field
%
%INPUTS:    source_img: the source image to be resampled, as a 2D matrix
%           def_field: the deformation field, as a 3D matrix
%           inter_method: any of the interpolation methods accepted by
%               interpn function [default = 'linear']
%OUTPUTS:   resamp_img: the resampled image
%
%NOTES: the deformation field should be a 3D matrix, where the size of the
%first two dimensions is the size of the resampled image, and the size of
%the 3rd dimension is 2. def_field(:,:,1) contains the x coordinates of the
%transformed pixels, def_field(:,:,2) contains the y coordinates of the
%transformed pixels.
%the origin of the source image is assumed to be the bottom left pixel

%check if interp method set - if not set to linear
if ~exist('interp_method','var') || isempty(interp_method)
    interp_method = 'linear';
end

%calculate coordinates of source image
x_coords = 0:size(source_img,1) - 1;
y_coords = 0:size(source_img,2) - 1;

%resample image using interpn function
resamp_img = interpn(x_coords, y_coords, source_img, def_field(:,:,1), def_field(:,:,2), interp_method);