clear
close all

%load lung MRI image and convert from uint8 to double so that limited 
%precision does not cause errors when processing
I = double(imread('lung_MRI_slice.png'));

%change image from 'matlab orientation' (y-axis 1st dim, 0 at top) to
%'standard orientation' (y-axis 2nd dim, 0 at bottom)
I = flip(I',2);


%display image
dispImage(I)


%create matrix representing translation by tx = 10 ty = 20
T = [1 0 10
    0 1 20
    0 0 1];

%calculate deformation field from translation matrix
def_field = defFieldFromAffineMatrix(T, size(I, 1), size(I, 2));

I_T_1 = resampImageWithDefField(I, def_field);
figure
dispImage(I_T_1);

I_T_2 = resampImageWithDefField(I, def_field, 'nearest');
I_T_3 = resampImageWithDefField(I, def_field, 'cubic');
figure
dispImage(I_T_2);
figure
dispImage(I_T_3);
figure
dispImage(I_T_1 - I_T_2);
figure
dispImage(I_T_1 - I_T_3);


T = [1 0 10.5
    0 1 20.5
    0 0 1];

%calculate deformation field from translation matrix
def_field = defFieldFromAffineMatrix(T, size(I, 1), size(I, 2));

I_T_1 = resampImageWithDefField(I, def_field);
figure
dispImage(I_T_1, [min(I(:)) max(I(:))]);

I_T_2 = resampImageWithDefField(I, def_field, 'nearest');
I_T_3 = resampImageWithDefField(I, def_field, 'cubic');
figure
dispImage(I_T_2, [min(I(:)) max(I(:))]);
figure
dispImage(I_T_3, [min(I(:)) max(I(:))]);
figure
dispImage(I_T_1 - I_T_2);
figure
dispImage(I_T_1 - I_T_3);


close all

R = affineMatrixForRotationAboutPoint(5, [127.5 127.5]);
def_field = defFieldFromAffineMatrix(R, size(I, 1), size(I, 2));

I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field);
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end

I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field);
    I_R(isnan(I_R)) = 0;
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end

I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field, 'nearest');
    I_R(isnan(I_R)) = 0;
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end

I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field, 'cubic');
    I_R(isnan(I_R)) = 0;
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end


close all

R = affineMatrixForRotationAboutPoint(1, [127.5 127.5]);
def_field = defFieldFromAffineMatrix(R, size(I, 1), size(I, 2));
I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field);
    I_R(isnan(I_R)) = 0;
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end

I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field, 'nearest');
    I_R(isnan(I_R)) = 0;
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end

I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field, 'cubic');
    I_R(isnan(I_R)) = 0;
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end


close all

R = affineMatrixForRotationAboutPoint(-10, [100 100]);
def_field = defFieldFromAffineMatrix(R, size(I, 1), size(I, 2));
I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field);
    I_R(isnan(I_R)) = 0;
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end

I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field, 'nearest');
    I_R(isnan(I_R)) = 0;
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end

I_R = I;
figure
for n = 1:72
    I_R = resampImageWithDefField(I_R, def_field, 'cubic');
    I_R(isnan(I_R)) = 0;
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end


close all

R_comp = eye(3);
figure
for n = 1:72
    R_comp = R_comp * R;
    def_field = defFieldFromAffineMatrix(R_comp, size(I, 1), size(I, 2));
    I_R = resampImageWithDefField(I, def_field, 'linear');
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end

R_comp = eye(3);
figure
for n = 1:72
    R_comp = R_comp * R;
    def_field = defFieldFromAffineMatrix(R_comp, size(I, 1), size(I, 2));
    I_R = resampImageWithDefField(I, def_field, 'nearest');
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end

R_comp = eye(3);
figure
for n = 1:72
    R_comp = R_comp * R;
    def_field = defFieldFromAffineMatrix(R_comp, size(I, 1), size(I, 2));
    I_R = resampImageWithDefField(I, def_field, 'cubic');
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
end


close all

R = affineMatrixForRotationAboutPoint(-30, [150 150]);
def_field = defFieldFromAffineMatrix(R, size(I, 1), size(I, 2));
I_R_push = resampImageWithDefFieldPushInterp(I ,def_field);
figure
dispImage(I_R_push, [min(I(:)) max(I(:))]);

R_inv = inv(R);
def_field_inv = defFieldFromAffineMatrix(R_inv, size(I, 1), size(I, 2));
I_R_pull = resampImageWithDefField(I ,def_field_inv);
figure
dispImage(I_R_pull, [min(I(:)) max(I(:))]);

figure
dispImage(I_R_pull - I_R_push);


R = affineMatrixForRotationAboutPoint(-10, [100 100]);
R_comp = eye(3);
figure
for n = 1:72
    R_comp = R_comp * R;
    def_field = defFieldFromAffineMatrix(R_comp, size(I, 1), size(I, 2));
    I_R = resampImageWithDefFieldPushInterp(I, def_field);
    dispImage(I_R, [min(I(:)) max(I(:))]);
    drawnow;
    disp(n)
end