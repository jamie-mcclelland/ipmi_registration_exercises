function dispColourOverlayImage(img1, img2)
%function to display two grey-scale images using a red-cyan colour overlay
%expects images to be in 'standard orientation' with y-axis on the 2nd
%dimension and 0 at the bottom
%
%  INPUTS:   img1, img2: images to be displayed

%take transpose of images and scale so between 0 and 1
img1 = (img1' - nanmin(img1(:))) / (nanmax(img1(:)) - nanmin(img1(:)));
img2 = (img2' - nanmin(img2(:))) / (nanmax(img2(:)) - nanmin(img2(:)));

%create rgb image with red channel set to img1 and green and blues channels
%set to img2
img_rgb = zeros([size(img1) 3]);
img_rgb(:,:,1) = img1;
img_rgb(:,:,2) = img2;
img_rgb(:,:,3) = img2;

%display image
image(0, 0, img_rgb);

%set axis to be scaled equally (assumes isotropic pixel dimensions), tight
%around the image
axis equal
axis tight

%set axis so 0 at bottom of y axis
axis xy