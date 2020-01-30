%close any open figures
close all

%the target and source images
target_full = cine_MR_1;
source_full = cine_MR_2;

%the amount of elastic and fluid regularistion to apply. this is the
%standard deviation of the Gaussian used to smooth the update or
%displacement field
%a value of 0 means no smoothing is applied
sigma_elastic = 0.5;
sigma_fluid = 1;

%if use_target_grad set to 1 (true) the target image gradient will be used
%when calculating the demons forces as in the original demons paper. if it
%is set to 0 (false) the transformed source image gradient will be used
%when calculating the demons forces
use_target_grad = 0;

%the number of levels to use in the multi-resolution scheme
num_lev = 3;

%the maximum number of iterations to use at each level
max_it = 1000;

%the threshhold for changes to the deformation field at each iteration. if
%the maximum absolute change in any of the deformation field values is less
%than this threshhold for any iteration the registration will stop running
%in the current level and move to the next level, or finish if this is the
%last level
df_thresh = 0.001;

%if check_msg is set to 1 (true) the mean squared difference (MSD) will be
%evaluated at each iteration, and if it has not improved the registration
%will be stopped at this level and proceed to the next levl / finish. if it
%is set to 0 (false) the registration will keep running regardless of
%whether the MSD has improved or not.
check_MSD = 1;

%the frequency with which update the displayed images. the images will be
%updated every disp_freq iterations
disp_freq = 5;

%the spacing between the grid lines or arrows when displaying the
%deformation field and update
disp_spacing = 2;

%the factor used to scale the udapte field for displaying
scale_update_for_display = 10;

%the display method for the deformation field (can be grid or arrows)
disp_method_df = 'grid';

%the display method for the update (can be grid or arrows)
disp_method_up = 'arrows';


%loop over resolution levels
for lev = 1:num_lev
    
    %resample images if needed
    if lev == num_lev
        target = target_full;
        source = source_full;
    else
        resamp_factor = 2^(num_lev - lev);
        target = imresize(target_full, 1/resamp_factor);
        source = imresize(source_full, 1/resamp_factor);
    end
    
    %if first level initialise def_field, disp_field
    if lev == 1
        [X, Y] = ndgrid(0:size(target,1)-1,0:size(target,2)-1);
        def_field = [];%clear def field from previous registration
        def_field(:,:,1) = X;
        def_field(:,:,2) = Y;
        disp_field_x = zeros(size(target));
        disp_field_y = zeros(size(target));
    else
        %otherwise upsample disp_field from previous level
        disp_field_x = 2 * imresize(disp_field_x, 2);
        disp_field_y = 2 * imresize(disp_field_y, 2);
        %recalculate def_field for this level from disp_field
        [X, Y] = ndgrid(0:size(target,1)-1,0:size(target,2)-1);
        def_field = [];%clear def field from previous level
        def_field(:,:,1) = X + disp_field_x;
        def_field(:,:,2) = Y + disp_field_y;
    end
    %initialise updates
    update_x = zeros(size(target));
    update_y = zeros(size(target));
    
    %calculate the transformed image at the start of this level
    trans_image = resampImageWithDefField(source, def_field);
    
    %store the current def field and MSD value to check for improvements at
    %end of iteration
    def_field_prev = def_field;
    prev_MSD = calcMSD(target, trans_image);
    
    %initialise 2D Gaussian filters for the elastic and fluid
    %regularisations
    elastic_filter = [];
    if sigma_elastic > 0
        normal_dist = makedist('normal','sigma',sigma_elastic);
        elastic_filter = pdf(normal_dist, floor(-3*sigma_elastic):ceil(3*sigma_elastic));
        elastic_filter = elastic_filter / sum(elastic_filter);
    end
    fluid_filter = [];
    if sigma_fluid > 0
        normal_dist = makedist('normal','sigma',sigma_fluid);
        fluid_filter = pdf(normal_dist, floor(-3*sigma_fluid):ceil(3*sigma_fluid));
        fluid_filter = fluid_filter / sum(fluid_filter);
    end
    
    %pre-calculate the image gradients. only one of source or target
    %gradients needs to be calculated, as indicated by use_target_grad
    if use_target_grad
        [target_gradient_y, target_gradient_x] = gradient(target);
    else
        [source_gradient_y, source_gradient_x] = gradient(source);
    end
    
    %display current results:
    %figure 1 - source image (does not change during registration)
    %figure 2 - target image (does not change during registration)
    %figure 3 - source image transformed by current deformation field
    %figure 4 - deformation field
    %figure 5 - update
    figure(1)
    dispImage(source);
    figure(2)
    dispImage(target);
    figure(3);
    dispImage(trans_image);
    figure(4);
    dispDefField(def_field, disp_spacing, disp_method_df);
    figure(5);
    up_field_to_display = scale_update_for_display * cat(3, update_x, update_y);
    up_field_to_display = up_field_to_display + cat(3, X, Y);
    dispDefField(up_field_to_display, disp_spacing, disp_method_up);
    
    %if first level pause so that user can position figure as desired
    if lev == 1
        pause;
    end
    
    %main iterative loop - repeat until max number of iterations reached
    for it = 1:max_it
        
        %calculate update from demons forces
        %
        %if using target image gradient use as is
        if use_target_grad
            img_grad_x = target_gradient_x;
            img_grad_y = target_gradient_y;
        else
            %but if using source image gradient need to transform with
            %current deformation field
            img_grad_x = resampImageWithDefField(source_gradient_x, def_field);
            img_grad_y = resampImageWithDefField(source_gradient_y, def_field);
        end
        %calculate difference image
        diff = target - trans_image;
        %calculate denominator of demons forces
        denom = img_grad_x.^2 + img_grad_y.^2 + diff.^2;
        %calculate x and y components of numerator of demons forces
        numer_x = diff .* img_grad_x;
        numer_y = diff .* img_grad_y;
        %calculate the x and y components of the update
        update_x = numer_x ./ denom;
        update_y = numer_y ./ denom;
        %set nan values to 0
        update_x(isnan(update_x)) = 0;
        update_y(isnan(update_y)) = 0;
        
        
        %if fluid like regularisation used smooth the update
        if ~isempty(fluid_filter)
            update_x = conv2(fluid_filter', fluid_filter, padarray(update_x, ceil(3*sigma_fluid)*[1 1], 'replicate'), 'valid');
            update_y = conv2(fluid_filter', fluid_filter, padarray(update_y, ceil(3*sigma_fluid)*[1 1], 'replicate'), 'valid');
        end
        
        
        %add the update to the current displacement field
        disp_field_x = disp_field_x + update_x;
        disp_field_y = disp_field_y + update_y;

                
        
        %if elastic like regularisation used smooth the displacement field
        if ~isempty(elastic_filter)
            disp_field_x = conv2(elastic_filter', elastic_filter, padarray(disp_field_x, ceil(3*sigma_elastic)*[1 1], 'replicate'), 'valid');
            disp_field_y = conv2(elastic_filter', elastic_filter, padarray(disp_field_y, ceil(3*sigma_elastic)*[1 1], 'replicate'), 'valid');
        end
        
        %update deformation field from disp field
        def_field(:,:,1) = disp_field_x + X;
        def_field(:,:,2) = disp_field_y + Y;
            
        %transform the image using the updated deformation field
        trans_image = resampImageWithDefField(source, def_field);
        
        %display current results (no need to update figures 1 and 2)
        if rem(it, disp_freq) == 0
            figure(3);
            dispImage(trans_image);
            figure(4);
            dispDefField(def_field, disp_spacing, disp_method_df);
            figure(5)
            up_field_to_display = scale_update_for_display * cat(3, update_x, update_y);
            up_field_to_display = up_field_to_display + cat(3, X, Y);
            dispDefField(up_field_to_display, disp_spacing, disp_method_up);
        end
        
        %calculate NMSD between target and transformed image
        MSD =  calcMSD(target, trans_image);
        
        %calculate max difference between previous and current def_field 
        max_df = max(abs(def_field - def_field_prev),[],'all');
        
        %display numerical results
        fprintf('Iteration %d: MSD = %e, Max. change in def field = %0.3f\n', it, MSD, max_df);
        
        %check if max change in def field below threshhold
        if max_df < df_thresh
            break;
        end
        
        %check for improvement in MSD if required
        if check_MSD && MSD > prev_MSD
            %restore previous results and finish level
            def_field = def_field_prev;
            MSD = prev_MSD;
            trans_image = resampImageWithDefField(source, def_field);
            break;
        end
        
        %update previous values of def_field and MSD
        def_field_prev = def_field;
        prev_MSD = MSD;
        
    end
    
end

%display final result
figure(3);
dispImage(trans_image);
figure(4);
dispDefField(def_field, disp_spacing, disp_method_df);
figure(5)
up_field_to_display = scale_update_for_display * cat(3, update_x, update_y);
up_field_to_display = up_field_to_display + cat(3, X, Y);
dispDefField(up_field_to_display, disp_spacing, disp_method_up);