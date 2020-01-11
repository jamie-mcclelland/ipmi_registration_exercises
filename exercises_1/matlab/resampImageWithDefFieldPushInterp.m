function resamp_img = resampImageWithDefFieldPushInterp(source_img, def_field, interp_method)
%function to resample a 2D image with a 2D deformation field using push
%interpolation
%
%INPUTS:    source_img: the source image to be resampled, as a 2D matrix
%           def_field: the deformation field, as a 3D matrix
%           inter_method: 'linear' or 'nearest' [default = 'linear']
%OUTPUTS:   resamp_img: the resampled image
%
%NOTES: the deformation field should be a 3D matrix, where the size of the
%first two dimensions is the same as the source image, and the size of
%the 3rd dimension is 2. def_field(:,:,1) contains the x coordinates of the
%transformed pixels, def_field(:,:,2) contains the y coordinates of the
%transformed pixels.
%the resampled image will be the same size as the source image, and the
%origin is assumed to be the bottom left pixel

%check if interp method set - if not set to linear
if ~exist('interp_method','var') || isempty(interp_method)
    interp_method = 'linear';
end

%form matrices containing the pixel coordinates of the resmapled image
[X, Y] = ndgrid(0:size(source_img,1) - 1, 0:size(source_img,2) - 1);

%use griddatan function to interpolate the irregular points in the
%deformation field onto a regular grid
%resamp_img = griddatan(def_field_reformed, source_img(:), pix_coords, interp_method);
def_field_x = def_field(:,:,1);
def_field_y = def_field(:,:,2);
resamp_img = griddata(def_field_x(:), def_field_y(:), source_img(:), X(:), Y(:), interp_method);

%reshape resampled image to have same size and shape as source image
resamp_img = reshape(resamp_img, size(source_img));