#!/usr/bin/env python3

"""
opencv based annotation of image types.
(c) Philipp Tschandl, 2018
You may re-use this code under the CC BY-NC 4.0 license.

Instructions:
- Start the script with "python classify_annotation.py"
- All images should be within the subfolder "images/"
- Click on the Image Window to focus it
- Annotate the image:
    - Enter image type: 'd', 'c', 'm' or 'p'
    - Delete image type annotation: return
    - Save and proceed: spacebar or enter
    - Exit annotation at current stage: esc

Output:
- .csv file with the following format: IMAGE_NAME,ANNOTATION,TIMESTAMP

"""

import pandas as pd
import cv2
import time
import os
import glob
from datetime import datetime

# Load dataframe with intermittent results if present
if os.path.isfile("./annotations.csv"):
    print("Previous annotation CSV found: loading...")
    df = pd.read_csv("./annotations.csv", index_col=0)
else:
    print("No annotation CSV found: creating list of JPEG files from image-folder...")
    paths = glob.glob("./images/*.jpg")
    df = pd.DataFrame(index=paths, columns=["impath","rating_type", "rating_date"])
    df.impath = paths
    df.rating_type = ""
    df.rating_date = ""

current_index, current_path, current_type, current_date = "", "", "", ""

# Get the first empty case and return False if there is none
def get_next_case():
    global current_index, current_date, current_path, current_type
    emptyindices = df.loc[(df.rating_type == "") | (df.rating_type.isnull())].index
    if len(emptyindices) > 0:
        current_path, current_type, current_date = df.loc[emptyindices[0]]
        current_index = emptyindices[0]
        return True
    else:
        return False


img=[]
# Rectangle variables for live annotation monitoring
x, y, h, w = (10, 10, 125, 125)

def load_new_image():
    global img
    # load a new image
    print("Current Image:", current_path)
    img = cv2.imread(current_path) # load a dummy image
    img = cv2.resize(img, (1000, 680))
    # draw an empty rectangle (placeholder for type indicator)
    cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), -1)
    # display the saved (current) image type indicator
    frame = cv2.putText(img, "" if type(current_type)!=str else current_type, (50,95),
                        cv2.FONT_HERSHEY_SIMPLEX, 2, 5, thickness=5)


if get_next_case():
    df.to_csv("./annotations.csv")
    load_new_image()
    while(1):
        cv2.imshow('img', img)
        k = cv2.waitKey(33)

        # Stop annotation (Esc)
        if k == 27:
            print("Exiting...")
            break
        elif k == 255:
            continue

        # Dermatoscopic ("d")
        elif k == 100:
            cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), -1)
            frame = cv2.putText(img, "D", (50,95), cv2.FONT_HERSHEY_SIMPLEX, 2, 5, thickness=5)
            current_type = "d"
            print("d", end='\r')

        # Clinic ("c")
        elif k == 99:
            cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), -1)
            frame = cv2.putText(img, "C", (50,95), cv2.FONT_HERSHEY_SIMPLEX, 2, 5, thickness=5)
            current_type = "c"
            print("c", end='\r')

        # Macro ("m")
        elif k == 109:
            cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), -1)
            frame = cv2.putText(img, "M", (50,95), cv2.FONT_HERSHEY_SIMPLEX, 2, 5, thickness=5)
            current_type = "m"
            print("m", end='\r')

        # Other ("p")
        elif k == 112:
            cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), -1)
            frame = cv2.putText(img, "P", (50,95), cv2.FONT_HERSHEY_SIMPLEX, 2, 5, thickness=5)
            current_type = "p"
            print("p", end='\r')

        # Remove (Return)
        elif k == 127:
            cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), -1)
            frame = cv2.putText(img, "", (60,85), cv2.FONT_HERSHEY_SIMPLEX, 2, 5, thickness=5)
            current_type = ""
            print("deleted", end='\r')

        # Save (Enter or spacebar)
        elif (k == 13) | (k==32):
            frame = cv2.putText(img, "Saving...", (200,200), cv2.FONT_HERSHEY_SIMPLEX, 1, 5, thickness=5)
            print("Saving value...", end='\r')
            df.loc[current_index, "rating_date"] = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
            df.loc[current_index, "rating_type"] = current_type

            # Optional timeout to avoid inadvertent annotation of next case.
            time.sleep(0.1)
            print("Getting new case...", end='\r')

            if get_next_case():
                load_new_image()
            else:
                print("All done!")
                break

            continue


print("Saving variables to file...")
df.to_csv("./annotations.csv")
