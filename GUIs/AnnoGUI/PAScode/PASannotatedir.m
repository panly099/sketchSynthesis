function PASannotatedir
  classfilename='PASclasses.txt';
  DataPath='/homes/yl303/Documents/MATLAB/Sketchlet/Data/Sketches/';
  ResultPath = '/homes/yl303/Documents/MATLAB/Sketchlet/Results/';
  IMGdir='car (sedan)/';
  PNGdir=[DataPath,IMGdir];
  ANNdir=[ResultPath,'Annotations/',IMGdir];
  
  d=dir([PNGdir,'/*.png']);
  for i=1:length(d),
    img=imread([PNGdir,d(i).name]);
    fprintf('-- Now annotating %s --\n',d(i).name);
    record=PASannotateimg(img,classfilename);
 
    [path,name,ext]=fileparts(d(i).name);
    annfile=[ANNdir,name,'.xml'];
    VOCwritexml(record,annfile);
  end;
return