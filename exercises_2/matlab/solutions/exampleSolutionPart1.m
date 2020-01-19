clear;
close all;

%load MR and CT images
ct_image_8bit = imread('ct_slice_int8.png');
ct_image_16bit = imread('ct_slice_int16.png');
mr_image = imread('mr_slice_int16.png');

%convert to double and change to 'standard orientation'
ct_image_8bit = flip(double(ct_image_8bit'), 2);
ct_image_16bit = flip(double(ct_image_16bit'), 2);
mr_image = flip(double(mr_image'), 2);


%display images
figure
dispImage(ct_image_16bit);
figure
dispImage(ct_image_8bit);
figure
dispImage(mr_image);

%%
%rotate each of the images from -90:90 degress about the point 10,10
%calculate the SSD between:
%original 16 bit CT and rotated 16 bit CT
%original 16 bit CT and rotated 8 bit CT
%original 16 bit CT and rotated MR
%original 8 bit CT and rotated 8 bit CT
labels{1} = 'CT (16-bit) - CT (16-bit)';
labels{2} = 'CT (16-bit) - CT (8-bit)';
labels{3} = 'CT (16-bit) - MR';
labels{4} = 'CT (8-bit) - CT (8-bit)';
theta = -90:90;
SSDs = nan(length(theta),4);
figure;
for n = 1:length(theta) 
    
    %create affine matrix and corresponding deformation field
    A = affineMatrixForRotationAboutPoint(theta(n), [10 10]);
    def_field = defFieldFromAffineMatrix(A, size(ct_image_16bit,1), size(ct_image_16bit,2));
    
    %transform images
    trans_ct_16 = resampImageWithDefField(ct_image_16bit, def_field);
    trans_ct_8 = resampImageWithDefField(ct_image_8bit, def_field);
    trans_mr = resampImageWithDefField(mr_image, def_field);
    
    %calculate SSD values
    SSDs(n,1) = calcSSD(ct_image_16bit, trans_ct_16);
    SSDs(n,2) = calcSSD(ct_image_16bit, trans_ct_8);
    SSDs(n,3) = calcSSD(ct_image_16bit, trans_mr);
    SSDs(n,4) = calcSSD(ct_image_8bit, trans_ct_8);
    
    %display results
    subplot(1,3,1);
    dispImage(trans_ct_16 - ct_image_16bit);
    subplot(2,3,2);
    plot(theta,SSDs(:,1));
    title(labels{1});
    subplot(2,3,3);
    plot(theta,SSDs(:,2));
    title(labels{2});
    subplot(2,3,5);
    plot(theta,SSDs(:,3));
    title(labels{3});
    subplot(2,3,6);
    plot(theta,SSDs(:,4));
    title(labels{4});
    drawnow;
    
end

%%
%repeat above for MSD 
MSDs = nan(length(theta),4);
for n = 1:length(theta) 
    
    %create affine matrix and corresponding deformation field
    A = affineMatrixForRotationAboutPoint(theta(n), [10 10]);
    def_field = defFieldFromAffineMatrix(A, size(ct_image_16bit,1), size(ct_image_16bit,2));
    
    %transform images
    trans_ct_16 = resampImageWithDefField(ct_image_16bit, def_field);
    trans_ct_8 = resampImageWithDefField(ct_image_8bit, def_field);
    trans_mr = resampImageWithDefField(mr_image, def_field);
    
    %calculate MSD and NMSD values
    MSDs(n,1) = calcMSD(ct_image_16bit, trans_ct_16);
    MSDs(n,2) = calcMSD(ct_image_16bit, trans_ct_8);
    MSDs(n,3) = calcMSD(ct_image_16bit, trans_mr);
    MSDs(n,4) = calcMSD(ct_image_8bit, trans_ct_8);
    
end

%display results for SSD and MSD in seperate figures
figure('name','SSD')
for n = 1:4
    subplot(2,2,n);
    plot(theta, SSDs(:,n));
    title(labels{n});
end
figure('name','MSD')
for n = 1:4
    subplot(2,2,n);
    plot(theta, MSDs(:,n));
    title(labels{n});
end

%%
%now repeat for NCC joint entropy, MI, and NMI
NCCs = nan(length(theta),4);
H_ABs = nan(length(theta),4);
H_As = nan(length(theta),4);
H_Bs = nan(length(theta),4);
for n = 1:length(theta) 
    
    %create affine matrix and corresponding deformation field
    A = affineMatrixForRotationAboutPoint(theta(n), [10 10]);
    def_field = defFieldFromAffineMatrix(A, size(ct_image_16bit,1), size(ct_image_16bit,2));
    
    %transform images
    trans_ct_16 = resampImageWithDefField(ct_image_16bit, def_field);
    trans_ct_8 = resampImageWithDefField(ct_image_8bit, def_field);
    trans_mr = resampImageWithDefField(mr_image, def_field);
    
    %calculate NCC value
    NCCs(n,1) = calcNCC(ct_image_16bit, trans_ct_16);
    NCCs(n,2) = calcNCC(ct_image_16bit, trans_ct_8);
    NCCs(n,3) = calcNCC(ct_image_16bit, trans_mr);
    NCCs(n,4) = calcNCC(ct_image_8bit, trans_ct_8);    
    
    %calculate entropy values, and use these to calculate MI and NMI
    [H_ABs(n,1), H_As(n,1), H_Bs(n,1)] = calcEntropies(ct_image_16bit, trans_ct_16);
    [H_ABs(n,2), H_As(n,2), H_Bs(n,2)] = calcEntropies(ct_image_16bit, trans_ct_8);
    [H_ABs(n,3), H_As(n,3), H_Bs(n,3)] = calcEntropies(ct_image_16bit, trans_mr);
    [H_ABs(n,4), H_As(n,4), H_Bs(n,4)] = calcEntropies(ct_image_8bit, trans_ct_8);
    
end

MIs = H_As + H_Bs - H_ABs;
NMIs = (H_As + H_Bs) ./ H_ABs;

%display results for NCC, Joint entropy, MI, and NMI in seperate figures
figure('name','NCC')
for n = 1:4
    subplot(2,2,n);
    plot(theta, NCCs(:,n));
    title(labels{n});
end
figure('name','Joint Entropy')
for n = 1:4
    subplot(2,2,n);
    plot(theta, H_ABs(:,n));
    title(labels{n});
end
figure('name','MI')
for n = 1:4
    subplot(2,2,n);
    plot(theta, MIs(:,n));
    title(labels{n});
end
figure('name','NMI')
for n = 1:4
    subplot(2,2,n);
    plot(theta, NMIs(:,n));
    title(labels{n});
end