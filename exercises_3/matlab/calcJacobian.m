function [J, J_Mat] = calcJacobian(def_field)
%a function to calculate the Jacobian from a deformation field
%
%INPUTS:    def_field: the deformation field as a 3D array
%
%OUTPUTS:   J: the Jacobian determinant for each pixel in the deformation
%               field
%           J_Mat: the full Jacobian matrix for each pixel in the
%               deformation field

%calculate gradient of x component of deformation field
%Note - matlab's gradient function returns the gradient along the 1st
%dimension (x) as the 2nd output, and the gradient along the 2nd dimension
%(y) as the 1st output.
[grad_x_y, grad_x_x] = gradient(def_field(:,:,1));
%calculate gradient of y component of deformation field
[grad_y_y, grad_y_x] = gradient(def_field(:,:,2));

%initlaise outputs as 0s
J = zeros(size(grad_x_x));
J_Mat = zeros([size(grad_x_x) 2 2]);

%loop over pixels in the deformation field
for x = 1:size(grad_x_x,1)
    for y = 1:size(grad_x_x,2)
        
        %form the Jacobian matrix for this pixel
        J_Mat_this_pix = [grad_x_x(x,y) grad_x_y(x,y) ; grad_y_x(x,y) grad_y_y(x,y)];
        %calculate and store the determinant
        J(x,y) = det(J_Mat_this_pix);
        %and store the full matrix
        J_Mat(x,y,:,:) = J_Mat_this_pix;
        
        %note - more efficient to calculate determinant from matrix in
        %temporary variable rather than directly from values in J_Mat as
        %the matrix values for a pixel are not stored contiguously in
        %memory in J_Mat
        
    end
end