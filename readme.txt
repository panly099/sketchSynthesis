#1. This is the linux implementation of deformable stroke model (DSM) and its relevent tools.

2. The folder structure :
------------------------------------------------------------------------------------
scripts : the training, testing and user study scripts. 

data : training and testing data.

functions : the functions invovled for DSM training and testing.

libs : the dependant 3rd-party libraries.

GUIs : this folder includes 3 apps :
       * [synGUI] the GUI for synthesizing a sketch after giving an input image.
       * [AnnoGUI] the GUI for annotating object bounding boxes for testing. It can also be used for part-based model supervision.
       * [UserStudyGUI] the GUI we use to do the perceptual studies in the paper.
         
results : the pre-trained DSMs and synthesized sketches, organized by category. They should be downloaded from https://github.com/panly099/sketchSynthesisResults. And please make the "results" folder by yourself to accommodate them.
------------------------------------------------------------------------------------

3. How to start?
It is recommended to try our sketch synthesis app first. In the folder of GUIs/synGUI, execute the 
image2sketch.m. When the app is launched, 
a) choose an image from data/images folder, e.g.,data/images/duck_img/161062752_cda17c415b.jpg; 
b) please choose the correct category in the category list and assign if this image is a flipped pose (the default pose is left-oriented, so for a right-oriented pose, you have to tick the 'Flip' radiobox); 
c) please click the Bbox button which will launch a selecting cursor for you to select the bounding box of the object (when using the cursor, once you click down the left button, please do not release the button until you finish selecting the bounding box). 
Right after you select the bounding box, the synthesizing process will begin and your result will be available 
in about 5 mins.

After tasting the synthesis app, you can explore into scripts/training and scripts/testing folders.
In scripts/training folder, you can execute the DSMtrainingScript.m file to train DSMs for the selected
category. The category is selected by a parameter called cateId, and more details can be found in the file
of DSMtrainingScript.m

For the imageSynScript.m in folder scripts/testing, you can execute it directly to synthesize sketches for 
the testing images using our pre-trained DSMs. Or alternatively, you can train your own DSMs first and then
execute this file.

Contact : 
If you have any problem, please feel free to contact 
panly099@gmail.com.










