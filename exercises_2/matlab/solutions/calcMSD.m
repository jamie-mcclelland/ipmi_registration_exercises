function NMSD = calcMSD(A, B)
%function to calculate the  mean of squared differences between
%two images
%
%INPUTS:    A: an image stored as a 2D matrix
%           B: an image stored as a 2D matrix. B must the the same size as
%               A
%
%OUTPUTS:   MSD: the value of the  mean of squared differences
%
%NOTE: if either of the images contain NaN values these pixels should be
%ignored when calculating the SSD.

%use nanmean function to find meean of squared differences ignoring NaNs.
NMSD = nanmean((A - B).^2,'all');


