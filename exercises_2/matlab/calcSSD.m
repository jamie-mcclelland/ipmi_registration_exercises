function SSD = calcSSD(A, B)
%function to calculate the sum of squared differences between
%two images
%
%INPUTS:    A: an image stored as a 2D matrix
%           B: an image stored as a 2D matrix. B must the the same size as
%               A
%
%OUTPUTS:   SSD: the value of the sum of squared differences
%
%NOTE: if either of the images contain NaN values these pixels should be
%ignored when calculating the SSD.

%use nansum function to find sum of squared differences ignoring NaNs.
SSD = nansum((A - B).^2,'all');
