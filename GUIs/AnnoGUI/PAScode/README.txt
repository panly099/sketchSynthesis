A brief description of the MATLAB functions in this directory:

[1] PASannotatedir.m  
  Wrapper for PASannotateimg to annotate all images in a database
  directory 

[2] PASannotateimg.m
  GUI tool to mark the bounding boxes for all the objects of interest
  in an image and produce an annotation record

[3] PASclasses.txt
  List of PASCAL class labels

[4] PAScmprecords.m
  Function to compare two annotation records. Mainly used for testing
  during the early development days.

[5] PASemptyobject.m 
  Function to create an empty object array in an annotation record

[6] PASemptyrecord.m
  Function to create an empty annotation record

[7] PASerrmsg.m
  Unsophisticated function to print an error message and provide
  keyboard control

[8] PASlabelobjfunc.m
  Nasty GUI hack to handle menu labelling

[9] PASreadrecord.m 
  Read annotation record from disk file

[10] PASviewannotation.m
  Display annotation record

[11] PASwriterecord.m
  Write annotation record to disk
----------------------------------------------------------------------
Using the GUI annotation tool implemented in PASannotatedir one can:

[1] Draw a rubber banding box with any of the mouse keys to mark a
rectangle around the object of interest

[2] Select a class label for the object via either a pull down menu or 
by pressing 1-9 on the keyboard (see source code to figure out which key
refers to what class)

[3] Press space bar to move on to the next image

[4] Press Escape to Undo one level.

[5] Press k or K to interrupt the program and inspect/change variables 
and annotations manually. "dbcont" will then resume the program.

Given the basic structure it is relatively straight forward to
implement other features -- such as Redo last Undo, carry over the
previous image's annotations, etc. The code is initially setup to
annotate the cars in the Caltech database but this can easily be
changed by modifying the DATdir and IMGdir variables.
----------------------------------------------------------------------
The file "datafilelist.txt.gz" shows how I have organised the databases
(png images, ground truth annotations, segmentation masks, etc)
relative to the directory in which the MATLAB code resides. There is
no obligation for you to untar the data using this directory structure
but then be prepared to modify directory variables in the code --
otherwise things should hopefully work straight out of the box. The
warning is particularly relevant if you're thinking about using the
development code which was used to generate the web page and gather
statistics, etc. Caveat emptor!
