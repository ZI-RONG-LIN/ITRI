import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('C:/Users/user/Downloads/test-opencv-master/test-opencv-master/PG1.jpg')
img1 = img.copy()
imgray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
blurred = cv2.GaussianBlur(imgray, (5, 5), 4)
ret3, th3 = cv2.threshold(blurred, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)

# edges = cv2.Canny(blurred, 150, 200)

def nothing(x):
    pass
# img = cv2.imread('test27.jpg', 0)
# cv2.imshow('image1',img)
edges = cv2.Canny(img, 60, 160)
cv2.namedWindow('image')
cv2.createTrackbar('minval','image',0,255,nothing)
cv2.createTrackbar('maxval','image',0,255,nothing)

while(1):
    cv2.imshow('image',edges)
    k=cv2.waitKey(1)&0xFF
    if k==27:
        break
    minval=cv2.getTrackbarPos('minval','image')
    maxval=cv2.getTrackbarPos('maxval','image')
    edges = cv2.Canny(img,57, 159)
cv2.destroyAllWindows()

contours, hierarchy = cv2.findContours(edges, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
# print(len(contours))
draw = cv2.drawContours(img1, contours, -1, (0, 255, 0), 5)

plt.subplot(131), plt.imshow(cv2.cvtColor(img,cv2.COLOR_BGR2RGB)), plt.title('Original Image')
plt.subplot(132), plt.imshow(edges,cmap='gray'), plt.title('Edge Image')
plt.subplot(133), plt.imshow(cv2.cvtColor(draw,cv2.COLOR_BGR2RGB)), plt.title('contour Image')
# plt.subplot(144), plt.imshow(cv2.cvtColor(image,cv2.COLOR_BGR2RGB)), plt.title('contour Image')

plt.show()

