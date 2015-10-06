function record = PASannotateimg(img,classfilename)
  global numobjects boolwaitingforlabel % For the UIMenu

  % Create Label Menu
  classes=textread(classfilename,'%s\n');
  callbackstr='PASlabelobjfunc(get(gcbo,''UserData''));';
  menuh=uimenu('Label','Label');
  for i=1:length(classes),
    class=char(classes(i));
    uimenu(menuh,'Label',class,'UserData',class,'Callback',callbackstr);
  end;
  
  % Define keyboard accelerators for 9 commonly used classes as lookup
  % indices into the variable "classes"
  accelerated(1)=1;  % PASaeroplaneSide
  accelerated(2)=3;  % PASbackground
  accelerated(3)=4;  % PASbicycle
  accelerated(4)=17; % PAScar
  accelerated(5)=20; % PAScarRear
  accelerated(6)=21; % PAScarSide
  accelerated(7)=53; % PASmotorbikeSide
  accelerated(8)=60; % PASperson
  accelerated(9)=63; % PASpersonWalking
  
  [Y X N]=size(img);
  record=PASemptyrecord;
  record.annotation.size.width=X;
  record.annotation.size.height=Y;
  record.annotation.size.depth=N
  imagesc(img);set(gca,'Units','pixels');
  colormap('gray');
  handles=[];
  numobjects=0;
  boolmoreobjects=1;
  boolwaitingforlabel=0;
  while (boolmoreobjects==1),
    [x,y,but]=ginput(1);
    switch lower(char(but)),
        case {1,2,3},
            if (~boolwaitingforlabel),
                numobjects=numobjects+1;
                fprintf('Define bounding box for object %d ...',numobjects);
                p1=get(gca,'CurrentPoint');
                rbbox;
                p2=get(gca,'CurrentPoint');
                p=round([p1;p2]);
                xmin=min(p(:,1));xmax=max(p(:,1));
                ymin=min(p(:,2));ymax=max(p(:,2));
                record.annotation.objects(numobjects)=PASemptyobject;
                record.annotation.objects(numobjects).bndbox.xmin=xmin;
                record.annotation.objects(numobjects).bndbox.ymin=ymin;
                record.annotation.objects(numobjects).bndbox.xmax=xmax;
                record.annotation.objects(numobjects).bndbox.ymax=ymax;
                handles(numobjects)=drawbox(record.annotation.objects(numobjects).bndbox);
                fprintf('\nChoose label for object %d: ',numobjects);
                boolwaitingforlabel=1;
            else
                fprintf('\nWaiting for label for object %d: ',numobjects);
            end;
            
        case {'1','2','3','4','5','6','7','8','9'},
            PASlabelobjfunc(char(classes(accelerated(but+1-double('1')))));
            
        case 27,
            if (numobjects>0),
                fprintf('Erasing annotations for object %d ("%s")\n',...
                    numobjects,record.annotation.objects(numobjects).label);
                set(handles(numobjects),'Visible','off');
                numobjects=numobjects-1;
            end;
            
        case 32,
            if (~boolwaitingforlabel), boolmoreobjects=0; else
                fprintf('\nWaiting for label for object %d: ',numobjects);
            end;
            
        case 'k', keyboard;
    end;
  end;  
  record.annotation.objects=record.annotation.objects(1:numobjects);
return

function h=drawbox(pts)
  pts = [pts.xmin pts.ymin pts.xmax pts.ymax];
  h=line(pts([1 3 3 1 1]),pts([2 2 4 4 2]),'Color',[1 0 0],'LineWidth',1);
return