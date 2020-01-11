%script to load lung MRI image and prepare it for further processing

%name of file containing lung MRI image
lung_mri_file_name = 'lung_MRI_slice.png';

%load lung MRI image
lung_mri_image = imread(lung_mri_file_name);

%convert from uint8 to double so that limited precision does not cause
%errors when processing
lung_mri_image = double(lung_mri_image);

%change image from 'matlab orientation' (y-axis 1st dim, 0 at top) to
%'standard orientation' (y-axis 2nd dim, 0 at bottom)
lung_mri_image = flip(lung_mri_image',2);
