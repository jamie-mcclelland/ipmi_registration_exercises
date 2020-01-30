from skimage.transform import rescale
from scipy.ndimage.filters import gaussian_filter
import matplotlib.pyplot as plt
import numpy as np
import utils


def runRegistration(target, source, sigma_elastic=1, sigma_fluid=1, use_target_grad=False,
                    num_lev=1, max_it=1000, df_thresh=0.001, check_MSD=True, disp_freq=5,
                    disp_spacing=2, scale_update_for_display=10, disp_method_df='grid',
                    disp_method_up='arrows'):

    # loop over resolution levels
    target_full = target
    source_full = source
    for lev in range(1, num_lev + 1):

        # resample images if not final level
        if lev != num_lev:
            resamp_factor = np.power(2, num_lev - lev)
            target = rescale(target_full, 1.0 / resamp_factor, mode='reflect',
                             preserve_range=True, multichannel=False, order=3, anti_aliasing=True)
            source = rescale(source_full, 1.0 / resamp_factor, mode='reflect',
                             preserve_range=True, multichannel=False, order=3, anti_aliasing=True)
        else:
            target = target_full
            source = source_full

        # if first level initialise def_field and disp_field
        if lev == 1:
            X, Y = np.mgrid[0:target.shape[0], 0:target.shape[1]]
            def_field = np.zeros((X.shape[0], X.shape[1], 2))
            def_field[:, :, 0] = X
            def_field[:, :, 1] = Y
            disp_field_x = np.zeros(target.shape)
            disp_field_y = np.zeros(target.shape)


        else:
            # otherwise upsample disp_field from previous level
            disp_field_x = 2 * rescale(disp_field_x, 2, mode='reflect', preserve_range=True,
                                       multichannel=False, order=3)
            disp_field_y = 2 * rescale(disp_field_y, 2, mode='reflect', preserve_range=True,
                                       multichannel=False, order=3)
            # recalculate def_field for this level from disp_field
            X, Y = np.mgrid[0:target.shape[0], 0:target.shape[1]]
            def_field = np.zeros((X.shape[0], X.shape[1], 2))  # clear def_field from previous level
            def_field[:, :, 0] = X + disp_field_x
            def_field[:, :, 1] = Y + disp_field_y

        #initialise updates
        update_x = np.zeros(target.shape)
        update_y = np.zeros(target.shape)
        update_def_field = np.zeros(def_field.shape)

        # calculate the transformed image at the start of this level
        trans_image = utils.resampImageWithDefField(source, def_field)
        
        # store the current def_field and MSD value to check for improvements at 
        # end of iteration 
        def_field_prev = def_field.copy()
        prev_MSD = utils.calcMSD(target, trans_image)
        
        # pre-calculate the image gradients. only one of source or target
        # gradients needs to be calculated, as indicated by use_target_grad
        if use_target_grad:
            [target_gradient_x, target_gradient_y] = np.gradient(target)
        else:
            [source_gradient_x, source_gradient_y] = np.gradient(source)
        
        # DISPLAY RESULTS
        # figure 1 - source image (does not change during registration)
        # figure 2 - target image (does not change during registration)
        # figure 3 - source image transformed by current deformation field
        # figure 4 - deformation field
        # figure 5 - update
        plt.figure(1, figsize=[3, 3])
        plt.clf()
        utils.dispImage(source)
        plt.figure(2, figsize=[3, 3])
        plt.clf()
        utils.dispImage(target)
        plt.figure(3, figsize=[3, 3])
        plt.clf()
        utils.dispImage(trans_image)
        plt.figure(4, figsize=[3, 3])
        plt.clf()
        utils.dispDefField(def_field, spacing=disp_spacing, disptype=disp_method_df)
        plt.figure(5, figsize=[3, 3])
        plt.clf()
        update_x_tmp = np.expand_dims(update_x, update_x.ndim)
        update_y_tmp = np.expand_dims(update_y, update_y.ndim)
        up_field_to_display = scale_update_for_display * np.concatenate((update_x_tmp, update_y_tmp), axis=-1)
        up_field_to_display += np.dstack((X, Y))
        utils.dispDefField(up_field_to_display, spacing=disp_spacing, disptype=disp_method_up)
        plt.pause(1)

        # if first level pause so user can position figure
        if lev == 1:
            input("Arrange figures and push enter to continue...")

        # main iterative loop - repeat until max number of iterations reached
        for it in range(max_it):

            # calculate update from demons forces
            #
            # if using target image graident use as is
            if use_target_grad:
                img_grad_x = target_gradient_x
                img_grad_y = target_gradient_y
            else:
                # but if using source image gradient need to transform with
                # current deformation field
                img_grad_x = utils.resampImageWithDefField(source_gradient_x, def_field)
                img_grad_y = utils.resampImageWithDefField(source_gradient_y, def_field)
                
            # calculate difference image
            diff = target - trans_image
            # calculate denominator of demons forces
            denom = np.power(img_grad_x, 2) + np.power(img_grad_y, 2) + np.power(diff, 2)
            # calculate x and y components of numerator of demons forces
            numer_x = diff * img_grad_x
            numer_y = diff * img_grad_y
            # calculate the x and y components of the update
            update_x = numer_x / denom
            update_y = numer_y / denom
            # set nan values to 0
            update_x[np.isnan(update_x)] = 0
            update_y[np.isnan(update_y)] = 0
            
            # if fluid like regularisation used smooth the update
            if sigma_fluid > 0:
                update_x = gaussian_filter(update_x, sigma_fluid, mode='nearest')
                update_y = gaussian_filter(update_y, sigma_fluid, mode='nearest')
            
            # add the update to the current displacement field
            # disp_field_x = disp_field_x + update_x
            # disp_field_y = disp_field_y + update_y

            # calculate a deformation field from the update
            update_def_field[:, :, 0] = update_x + X
            update_def_field[:, :, 1] = update_y + Y
            # use this to resample the current deformation field
            def_field[:, :, 0] = utils.resampImageWithDefField(def_field[:, :, 0], update_def_field)
            def_field[:, :, 1] = utils.resampImageWithDefField(def_field[:, :, 1], update_def_field)
            # calculate the displacement field from the composed deformation field
            disp_field_x = def_field[:, :, 0] - X
            disp_field_y = def_field[:, :, 1] - Y
            # replace nans in disp field with 0s
            disp_field_x[np.isnan(disp_field_x)] = 0
            disp_field_y[np.isnan(disp_field_y)] = 0

            # if elastic like regularisation used smooth the displacement field
            if sigma_elastic > 0:
                disp_field_x = gaussian_filter(disp_field_x, sigma_elastic, mode='nearest')
                disp_field_y = gaussian_filter(disp_field_y, sigma_elastic, mode='nearest')
            
            # update deformation field from disp field
            def_field[:, :, 0] = disp_field_x + X
            def_field[:, :, 1] = disp_field_y + Y
            
            # transform the image using the updated deformation field
            trans_image = utils.resampImageWithDefField(source, def_field)

            # update images if required for this iteration
            if it % disp_freq == 0:
                plt.figure(3)
                plt.clf()
                utils.dispImage(trans_image)
                plt.figure(4)
                plt.clf()
                utils.dispDefField(def_field, spacing=disp_spacing, disptype=disp_method_df)
                plt.figure(5)
                plt.clf()
                update_x_tmp = np.expand_dims(update_x, update_x.ndim)
                update_y_tmp = np.expand_dims(update_y, update_y.ndim)
                up_field_to_display = scale_update_for_display * np.concatenate((update_x_tmp, update_y_tmp), axis=-1)
                up_field_to_display += np.dstack((X, Y))
                utils.dispDefField(up_field_to_display, spacing=disp_spacing, disptype=disp_method_up)
                plt.pause(0.05)
            
            # calculate MSD between target and transformed image
            MSD = utils.calcMSD(target, trans_image)

            # calculate max difference between previous and current def_field
            max_df = np.max(np.abs(def_field - def_field_prev))

            # display numerical results
            print('Iteration {0:d}: MSD = {1:e}, Max. change in def field = {2:0.3f}\n'.format(it, MSD, max_df))
            
            # check if max change in def field below threshhold
            if max_df < df_thresh:
                print('max df < df_thresh')
                break
            
            # check for improvement in MSD if required
            if check_MSD and MSD > prev_MSD:
                # restore previous results and finish level
                def_field = def_field_prev
                MSD = prev_MSD
                trans_image = utils.resampImageWithDefField(source, def_field)
                print('No improvement in MSD')
                break
            
            # update previous values of def_field and MSD
            def_field_prev = def_field.copy()
            prev_MSD = MSD.copy()
            def_field = def_field

    # return the transformed image and the deformation field
    return trans_image, def_field

