This annotation tool is for annotating the object's bounding box and the object parts' bounding boxes.
It can also assign a pose to the object. All the annotation information is stored in an XML file, adopting
PASCAL VOC challenge's setting. And actually it is a GUI wrapper for the PASCAL VOC's annotation implementation.

What can be customized?

-- The category list. Click the 'Edit List' button to edit the category list.
-- The category's parts. After you click 'Edit List' button, a new window will show up, and you can edit the parts
by selecting a category and clicking 'Edit Parts'.
-- The pose list. Click the 'Edit Poses' button to edit the possible poses you want.

How to start?

Firstly, you have to select the folder where the training images are stored. You also have to choose a folder for 
the corresponding XML files to be stored.

Then, click the 'Start' button to start the annotation. You need to follow the order of labelling obejct first and 
then labelling the parts (you don't have to label the parts if you don't need part annotation). When you click the 
'Label Object' or 'Label Part' button, a cross cursor will show up for you to circle the object/part out. When one object is 
finished, please click 'Part Finish' to proceed to the next object. When all the object(s) is/are finished in the image, click 
'Next image' to process the next image, and the corresponding XML file will be generated in the designated folder. 

Please notice that, you can select if the object is 'truncated' or 'difficult', and you can also select the pose for
the object. For the part, you can choose if it is 'occluded'. If you have wrong annotation, you can use the 'Delete Object' 
and 'Delete Part' button to delete the wrongly annotated object/part and re-annotate it again.

Contact : 
Please feel free to contact panly099@gmail.com, if any trouble is encoutered or any suggestion is handy.


