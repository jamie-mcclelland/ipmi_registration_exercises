import skimage.io
import numpy as np
import utils
import matplotlib.pyplot as plt
import demons

img1 = skimage.io.imread('cine_MR_1.png')
img2 = skimage.io.imread('cine_MR_2.png')
img3 = skimage.io.imread('cine_MR_3.png')

img1 = (np.flipud(np.double(img1))).T
img2 = (np.flipud(np.double(img2))).T
img3 = (np.flipud(np.double(img3))).T

"""
plt.figure(1)
utils.dispImage(img1)
plt.figure(2)
utils.dispImage(img2)
plt.figure(3)
utils.dispImage(img3)
"""

plt.close('all')
reg_img, def_field = demons.runRegistration(img1, img2)
plt.close('all')
plt.figure()
utils.dispImage(img1)
plt.figure()
utils.dispImage(img2)
plt.figure()
utils.dispImage(reg_img)
plt.figure()
utils.dispImage(img1 - reg_img)
plt.figure()
utils.dispDefField(def_field, spacing=2)