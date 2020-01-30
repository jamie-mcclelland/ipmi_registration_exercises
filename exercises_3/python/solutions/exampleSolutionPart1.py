import skimage.io
import numpy as np
import utils
import matplotlib.pyplot as plt

img1 = skimage.io.imread('cine_MR_1.png')
img2 = skimage.io.imread('cine_MR_2.png')

img1 = (np.flipud(np.double(img1))).T
img2 = (np.flipud(np.double(img2))).T


plt.figure(1)
utils.dispImage(img1)
plt.figure(2)
utils.dispImage(img2)
plt.figure(3)
utils.dispColourOverlayImage(img1, img2)