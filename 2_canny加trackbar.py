
import cv2
import numpy as np
# The function attached to the trackbar.
def nothing(x):
    pass
img = cv2.imread('C:/Users/user/Downloads/test-opencv-master/test-opencv-master/PG1.jpg', 0)
img1 = cv2.resize(img, (400, 400))
cv2.imshow('image1',img1)
edges = cv2.Canny(img1, 50, 150)
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
    edges = cv2.Canny(img1,minval, maxval)
cv2.destroyAllWindows()