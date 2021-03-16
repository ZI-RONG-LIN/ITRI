import cv2
import numpy as np
from matplotlib import pyplot as plt
#先設定一個空的xy LIST
pts1 = np.float32([[0,0],[0,0],[0,0],[0,0]])
i=0
#建立一個函數，點擊兩下滑鼠左鍵，則紀錄xy點位並返回到pts1
def savexy(event,x,y,flags,param):
    global pts1
    global i
    if event==cv2.EVENT_LBUTTONDBLCLK:
        print(x,y)
        pts1[i]=[x,y]
        i+=1
#讀圖檔
img=cv2.imread('C:/Users/user/Downloads/test-opencv-master/test-opencv-master/A.jpg')
rows,cols,ch=img.shape
#目標轉乘的點位(順時針，如果要其他順序的話在調整xy點位)
pts2 = np.float32([[0,0],[300,0],[300,300],[0,300]])
#呈現的視窗名稱
cv2.namedWindow('image')
#返還函式的數據到視窗中
cv2.setMouseCallback('image',savexy)
#當按按鍵之後再關閉視窗
while(1):
    cv2.imshow('image',img)
    #當i>3，也就是點了4個點之後就break這個迴圈
    if cv2.waitKey(20)&0xFF==27 or i>3:
        break
cv2.destroyAllWindows()
#視角轉換
M=cv2.getPerspectiveTransform(pts1,pts2)
#轉換成幾成幾的圖，前面為x軸長度，後面為y軸長度
dst=cv2.warpPerspective(img,M,(300,300))
#調整BGR到RGB
dst1 = cv2.cvtColor(dst,cv2.COLOR_BGR2RGB)
img1 = cv2.cvtColor(img,cv2.COLOR_BGR2RGB)
cv2.imwrite('PG1.jpg',dst)
#印出子圖
plt.subplot(121), plt.imshow(img1), plt.title('Input')
plt.subplot(122), plt.imshow(dst1), plt.title('Output')
plt.show()
