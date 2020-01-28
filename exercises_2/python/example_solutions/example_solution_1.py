# import required functions and packages
import skimage.io
import numpy as np
import utils
import matplotlib.pyplot as plt

# load images
ct_slice_int8 = skimage.io.imread('ct_slice_int8.png')
ct_slice_int16 = skimage.io.imread('ct_slice_int16.png')
mr_slice_int16 = skimage.io.imread('mr_slice_int16.png')

# convert img to double and reorientate
ct_slice_int8 = np.double(ct_slice_int8)
ct_slice_int16 = np.double(ct_slice_int16)
mr_slice_int16 = np.double(mr_slice_int16)

ct_slice_int8 = (np.flipud(ct_slice_int8)).T
ct_slice_int16 = (np.flipud(ct_slice_int16)).T
mr_slice_int16 = (np.flipud(mr_slice_int16)).T

# display images
plt.figure(1)
utils.dispImage(ct_slice_int8)
plt.figure(2)
utils.dispImage(ct_slice_int16)
plt.figure(3)
utils.dispImage(mr_slice_int16)
plt.pause(1) # found need pause of at least 1 s for figs to draw

# wait for user to push enter then close figs
input("Press Enter to continue...")
plt.close('all')

# rotate each of the images from -90:90 degrees about the point 10,10
# calculate the SSD between:
# original 16 bit CT and rotated 16 bit CT
# original 16 bit CT and rotated 8 bit CT
# original 16 bit CT and rotated MR
# original 8 bit CT and rotated 8 bit CT
theta = np.arange(-90, 91, 1)
SSDs = np.empty((181, 4))
SSDs[:] = np.nan
plt.figure(4)
for n in range(theta.size):

    # create affine matrix and corresponding deformation field
    A = utils.affineMatrixForRotationAboutPoint(theta[n], [10, 10])
    def_field = utils.defFieldFromAffineMatrix(A, ct_slice_int16.shape[0], ct_slice_int16.shape[1])

    # transform images
    trans_ct_16 = utils.resampImageWithDefField(ct_slice_int16, def_field)
    trans_ct_8 = utils.resampImageWithDefField(ct_slice_int8, def_field)
    trans_mr_16 = utils.resampImageWithDefField(mr_slice_int16, def_field)

    # calculate SSD values
    SSDs[n, 0] = utils.calcSSD(ct_slice_int16, trans_ct_16)
    SSDs[n, 1] = utils.calcSSD(ct_slice_int16, trans_ct_8)
    SSDs[n, 2] = utils.calcSSD(ct_slice_int16, trans_mr_16)
    SSDs[n, 3] = utils.calcSSD(ct_slice_int8, trans_ct_8)

    # display results
    # note - clearing figure and creating new axes seems to run much faster
    # than updating axes
    plt.clf()
    plt.subplot(131)
    utils.dispImage(trans_ct_16 - ct_slice_int16)
    plt.subplot(232)
    plt.plot(theta, SSDs[:, 0])
    plt.xlim(theta[0], theta[-1])
    plt.subplot(233)
    plt.plot(theta, SSDs[:, 1])
    plt.xlim(theta[0], theta[-1])
    plt.subplot(235)
    plt.plot(theta, SSDs[:, 2])
    plt.xlim(theta[0], theta[-1])
    plt.subplot(236)
    plt.plot(theta, SSDs[:, 3])
    plt.xlim(theta[0], theta[-1])

    plt.pause(0.05)


