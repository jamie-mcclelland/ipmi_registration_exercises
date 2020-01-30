clear;
close all;

%load lung MR images
cine_MR_1 = imread('cine_MR_1.png');
cine_MR_2 = imread('cine_MR_2.png');

%convert to double and change to 'standard orientation'
cine_MR_1 = flip(double(cine_MR_1'), 2);
cine_MR_2 = flip(double(cine_MR_2'), 2);

%display images
figure
dispImage(cine_MR_1);
figure
dispImage(cine_MR_2);
figure
dispColourOverlayImage(cine_MR_1, cine_MR_2);