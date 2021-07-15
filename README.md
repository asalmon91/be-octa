# be-octa
## Acquire scans on a Bioptigen OCT, making sure that "Save OCU" is selected
- For the thirteen-lined ground squirrel, a suggested scan pattern is: 5x5mm rectangular volume with 450A/B, 450B/C, 4 frames/B.
- For other animals, you'll have to play around with scan patterns, but a pixel size of ~1.5µm/px is suggested for capillary imaging
## Set up your folders with a "Raw" and "Calibration folder at the same level
- Copy the .OCU files (the .OCT and .BMP files are okay too), into the "Raw" folder
- Copy the engine.ini and user.ini files into the "Calibration" folder
  - (Once you find these the first time, you can just copy them into any new sessions)
## Run batch_octa.m
1. Select the .OCU files to process
2. A window will pop up with the middle frame of the first .OCU, drag a rectangle over the sample of interest to optimize dispersion (you will not have to repeat this for the other scans in the batch)
3. When the script finishes, there should be angiographic volumes as .avi files in a "Processed" folder at the same level as "Raw" and "Calibration"
## Segment the volumes with your favorite segmentation software to obtain OCT-A en face images
- Mine is OCT_Volume_Viewer, contact for details on how to acquire this software
