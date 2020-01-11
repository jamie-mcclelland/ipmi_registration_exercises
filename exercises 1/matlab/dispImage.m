function dispImage(img, int_lims)
%function to display a grey-scale image that is stored in 'standard
%orientation' with y-axis on the 2nd dimension and 0 at the bottom
%
% INPUTS:   img: image to be displayed
%           int_lims: the intensity limits to use when displaying the
%               image, int_lims(1) = min intensity to display, int_lims(2)
%               = max intensity to display [default min and max intensity
%               of image]

%check if intensity limits have been provided, and if not set to min and
%max of image
if ~exist('int_lims','var') || isempty(int_lims)
    int_lims = [min(img(:)) max(img(:))];
    %check if min and max are same (i.e. all values in img are equal)
    if int_lims(1) == int_lims(2)
        %add one to int_lims(2) and subtract one from int_lims(1), so that
        %int_lims(2) is larger than int_lims(1) as required by imagesc
        %function
        int_lims(1) = int_lims(1) - 1;
        int_lims(2) = int_lims(2) + 1;
    end
end

%take transpose of image to switch x and y dimensions and display with
%first pixel having coordinates 0,0
imagesc(0, 0, img', int_lims);

%set axis to be scaled equally (assumes isotropic pixel dimensions), tight
%around the image
axis equal
axis tight

%set axis so 0 at bottom of y axis
axis xy

%set to grey-scale
colormap(gray);