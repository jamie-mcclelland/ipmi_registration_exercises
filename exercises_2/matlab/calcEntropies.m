function [H_AB, H_A, H_B] = calcEntropies(A, B, num_bins)
%function to calculate the joint and marginal entropies for two images
%
%INPUTS:    A: an image stored as a 2D matrix
%           B: an image stored as a 2D matrix. B must the the same size as
%               A
%           num_bins: a 2 element vector specifying the number of bins to
%               in the joint histogram for each image [default = 32, 32]
%
%OUTPUTS:   H_AB: the joint entropy between A and B
%           H_A: the marginal entropy in A
%           H_B the marginal entropy in B
%
%NOTE: if either of the images contain NaN values these pixels should be
%ignored when calculating the SSD.

if ~exist('num_bins','var') || isempty (num_bins)
    num_bins = [32 32];
end

%use histcounts2 function to generate joint histogram, an convert to
%probabilities
joint_hist = histcounts2(A, B, num_bins);
probs_AB = joint_hist / sum(joint_hist,'all');

%calculate marginal probability distributions for A and B
probs_A = sum(probs_AB,2);
probs_B = sum(probs_AB,1);

%calculate joint entropy and marginal entropies
%note, when taking sums must check for nan values as
%0 * log(0) = nan
H_AB = -nansum(probs_AB .* log(probs_AB), 'all');
H_A = -nansum(sum(probs_A,2) .* log(sum(probs_A,2)), 'all');
H_B = -nansum(sum(probs_B,1) .* log(sum(probs_B,1)), 'all');
