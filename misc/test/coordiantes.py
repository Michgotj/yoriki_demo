from PIL import Image
import cv2

image_path = '/misc/test/test.png'
#reply is in Coordinates: 857 1270
img = cv2.imread(image_path)
#.resize((720, 1516))
def get_coordinates(event, x, y, flags, param):
    if event == cv2.EVENT_LBUTTONDOWN:  # Check for left mouse click
        print("Coordinates:", x, y)

cv2.namedWindow('image')  # Create a window to display the image
cv2.setMouseCallback('image', get_coordinates)

cv2.imshow('image', img)
cv2.waitKey(0)
cv2.destroyAllWindows()