function aff_mat = affineMatrixForRotationAboutPoint(theta, p_coords)
%function to calculate the affine matrix corresponding to an anticlockwise
%rotation about a point
%
%INPUTS:    theta: the angle of the rotation, specified in degrees
%           p_coords: the 2D coordinates of the point that is the centre of
%               rotation. p_coords(1) is the x coordinate, p_coords(2) is
%               the y coordinate
%
%OUTPUTS:   aff_mat: a 3 x 3 affine matrix

%convert theta to radians
theta = pi * theta / 180;

%form matrices for translations and rotation
T1 = [1 0 -p_coords(1)
    0 1 -p_coords(2)
    0 0 1];
T2 = [1 0 p_coords(1)
    0 1 p_coords(2)
    0 0 1];
R = [cos(theta) -sin(theta) 0
    sin(theta) cos(theta) 0
    0 0 1];

%compose matrices
aff_mat = T2 * R * T1;