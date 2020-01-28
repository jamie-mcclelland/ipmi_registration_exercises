function def_field = defFieldFromAffineMatrix(aff_mat, num_pix_x, num_pix_y)
%function to create a 2D deformation field from an affine matrix
%
%INPUTS:   aff_mat: a 3 x 3 matrix representing the 2D affine 
%                transformation in homogeneous coordinates
%          num_pix_x: number of pixels in the deformation field along the x
%                dimension
%          num_pix_y: number of pixels in the deformation field along the y
%                dimension
%
%OUTPUTS:  def_field: the 2D deformation field
%
%NOTE: the function calculates the pixel coordinates of the deformation
%field as:
%x = 0:num_pix_x - 1
%y = 0:num_pix_y - 1

%form 2D matrices containing all the pixel coordinates
[X, Y] = ndgrid(0:num_pix_x - 1, 0:num_pix_y - 1);

%reshape and combine coordinate matrices into a 3 x N matrix, where N is
%the total number of pixels (num_pix_x x num_pix_y). The first row contains
%the x coordinates, the second row the y coordinates, and the third row is
%all set to 1 (i.e. using homogeneous coordinates)
total_pix = num_pix_x * num_pix_y;
pix_coords = [reshape(X, 1, total_pix) ; reshape(Y, 1, total_pix); ones(1, total_pix)];

%apply transformation to pixel coordinates
trans_coords = aff_mat * pix_coords;

%reshape into deformation field
def_field(:,:,1) = reshape(trans_coords(1,:), num_pix_x, num_pix_y);
def_field(:,:,2) = reshape(trans_coords(2,:), num_pix_x, num_pix_y);