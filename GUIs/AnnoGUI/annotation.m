function varargout = annotation(varargin)
% ANNOTATION MATLAB code for annotation.fig
%      ANNOTATION, by itself, creates a new ANNOTATION or raises the existing
%      singleton*.
%
%      H = ANNOTATION returns the handle to a new ANNOTATION or the handle to
%      the existing singleton*.
%
%      ANNOTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATION.M with the given input arguments.
%
%      ANNOTATION('Property','Value',...) creates a new ANNOTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before annotation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to annotation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help annotation

% Last Modified by GUIDE v2.5 28-Apr-2015 11:30:10

% Begin initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%% Important variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% image index stored in the 'UserData' in button 'Next Image'
% object number stored in the 'UserData' in button 'Label Object'
% part number stored in the 'UserData' in button 'Label Part'
% image name stored in the 'UserData' in button 'Start'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('PAScode');
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @annotation_OpeningFcn, ...
                   'gui_OutputFcn',  @annotation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before annotation is made visible.
function annotation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to annotation (see VARARGIN)

% Choose default command line output for annotation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes annotation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = annotation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
index_selected = get(hObject,'Value');
list = get(hObject,'String');
item_selected = list{index_selected}; 
if exist('Data/catePartList.mat', 'file')
    load('Data/catePartList.mat');
    parts = a{index_selected,2};
    set(handles.listbox2,'Value',1);
    set(handles.listbox2,'string',parts);
end
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
if exist('Data/catePartList.mat', 'file')
    load('Data/catePartList.mat');
    list = a(:,1);
    set(hObject,'Value',1);
    set(hObject,'string',list);
end

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if exist('Data/catePartList.mat', 'file')
    load('Data/catePartList.mat');
    list = a{1,2};
    set(hObject,'Value',1);
    set(hObject,'string',list);
end
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in labelObjButton.
function labelObjButton_Callback(hObject, eventdata, handles)
objectNum = get(hObject,'UserData');
objectNum = objectNum + 1;
dim = get(handles.axes,'UserData');

global record
[x,y,but]=ginput(1);
if lower(char(but)) == 1 || lower(char(but)) == 2 || lower(char(but)) == 3
    p1=get(gca,'CurrentPoint');
    rbbox;
    p2=get(gca,'CurrentPoint');
    p=round([p1;p2]);
    xmin=min(p(:,1));xmax=max(p(:,1));
    ymin=min(p(:,2));ymax=max(p(:,2));
    
    if xmin < 1
        xmin = 1;
    end
    if ymin < 1;
        ymin = 1;
    end
    if xmax > dim(2)
        xmax = dim(2);
    end
    if ymax > dim(1)
        ymax = dim(1);
    end
    
    record.annotation.object(objectNum)=PASemptyobject;
    name = get(handles.listbox1,'string');
    index = get(handles.listbox1,'Value');
    name = name{index};
    record.annotation.object(objectNum).name =name;
    pose = get(handles.listboxPose, 'String');
    value = get(handles.listboxPose,'Value');
    record.annotation.object(objectNum).pose =pose{value};
    record.annotation.object(objectNum).bndbox.xmin=xmin;
    record.annotation.object(objectNum).bndbox.ymin=ymin;
    record.annotation.object(objectNum).bndbox.xmax=xmax;
    record.annotation.object(objectNum).bndbox.ymax=ymax;
    drawbox(record.annotation.object(objectNum).bndbox,[1 0 0]);
    set(hObject,'UserData',objectNum);
    set(hObject,'Enable','Off');
    set(handles.labelPartButton,'Enable','On');
    set(handles.partFinishButton,'Enable','On');
    set(handles.nextImgButton,'Enable','Off');
    partNum = 0;
    set(handles.labelPartButton, 'UserData', partNum); %initialize part number
    
    %set the labeled object list
    objNames = cell(objectNum,1);
    for i = 1 : objectNum
        objNames{i} = record.annotation.object(i).name;
    end
    set(handles.listbox3,'Value',objectNum);
    set(handles.listbox3,'string',objNames);
    set(handles.listbox4,'String','');
    set(handles.delObjButton,'Enable','Off');
    set(handles.checkbox2,'Enable','On');
    set(handles.checkbox3,'Enable','On');
    set(handles.checkbox2,'Value',record.annotation.object(objectNum).truncated);
    set(handles.checkbox3,'Value',record.annotation.object(objectNum).difficult);
end
% hObject    handle to labelObjButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in labelPartButton.
function labelPartButton_Callback(hObject, eventdata, handles)
objectNum = get(handles.labelObjButton,'UserData');
partNum = get(hObject,'UserData');
partNum = partNum + 1;
global record
[x,y,but]=ginput(1);
if lower(char(but)) == 1 || lower(char(but)) == 2 || lower(char(but)) == 3
    p1=get(gca,'CurrentPoint');
    rbbox;
    p2=get(gca,'CurrentPoint');
    p=round([p1;p2]);
    xmin=min(p(:,1));xmax=max(p(:,1));
    ymin=min(p(:,2));ymax=max(p(:,2));
    record.annotation.object(objectNum).part(partNum)=PASemptypart;
    name = get(handles.listbox2,'string');
    index = get(handles.listbox2,'Value');
    name = name{index};
    record.annotation.object(objectNum).part(partNum).name =name;
    record.annotation.object(objectNum).part(partNum).bndbox.xmin=xmin;
    record.annotation.object(objectNum).part(partNum).bndbox.ymin=ymin;
    record.annotation.object(objectNum).part(partNum).bndbox.xmax=xmax;
    record.annotation.object(objectNum).part(partNum).bndbox.ymax=ymax;
    drawbox(record.annotation.object(objectNum).part(partNum).bndbox,[0 0 1]);
    set(hObject,'UserData',partNum);
    
    % set labeled parts listbox
    set(handles.listbox4,'Value',partNum);
    partNames = cell(partNum,1);
    for i = 1 : partNum
        partNames{i} = record.annotation.object(objectNum).part(i).name;
    end
    
    set(handles.listbox4,'String',partNames);
    set(handles.delPartButton,'Enable','On');
    set(handles.checkbox1,'Enable','On');
    set(handles.checkbox1,'Value',record.annotation.object(objectNum).part(partNum).occluded);
    
    %roll to next part
    string = get(handles.listbox2,'String');
    numStr = numel(string);
    value = get(handles.listbox2,'Value');
    if value~= numStr
        set(handles.listbox2,'Value',value+1);
    else
        set(handles.listbox2,'Value',1);
    end
end
% hObject    handle to labelPartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in partFinishButton.
function partFinishButton_Callback(hObject, eventdata, handles)
set(handles.labelObjButton,'Enable','On');
set(handles.labelPartButton,'Enable','Off');
set(hObject,'Enable','Off');
set(handles.nextImgButton,'Enable','On');
set(handles.delObjButton,'Enable','On');
set(handles.delPartButton,'Enable','On');
set(handles.checkbox1,'Enable','On');
set(handles.checkbox2,'Enable','On');
set(handles.checkbox3,'Enable','On');
% hObject    handle to partFinishButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in imgPathButton.
function imgPathButton_Callback(hObject, eventdata, handles)
fold_name = uigetdir;
if fold_name~=0
    set(handles.edit2,'string',fold_name);
    set(handles.edit2,'UserData',fold_name);
end
% hObject    handle to imgPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in xmlPathButton.
function xmlPathButton_Callback(hObject, eventdata, handles)
fold_name = uigetdir;
if fold_name~=0
    set(handles.edit3,'string',fold_name);
    set(handles.edit3,'UserData',fold_name);
end
% hObject    handle to xmlPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nextImgButton.
function nextImgButton_Callback(hObject, eventdata, handles)
% write current image into xml
global record
if size(record.annotation.object.bndbox.xmin) ~= 0
    folder_name = get(handles.edit3,'string');
    name = get(handles.startButton,'UserData');
    VOCwritexml(record, [folder_name,'/',name,'.xml']);
end
 record =PASemptyrecord;

% load next image
folder_name = get(handles.edit2,'string');
imgList = dir(folder_name);
num = numel(imgList);
index = get(hObject,'UserData');
if index == num
    set(hObject,'Enable','Off');
    set(handles.listbox3,'String','');
    set(handles.listbox4,'String','');
    set(handles.delObjButton,'Enable','Off');
    set(handles.checkbox2,'Enable','Off');
    set(handles.checkbox3,'Enable','Off');
    set(handles.delPartButton,'Enable','Off');
    set(handles.checkbox1,'Enable','Off');
    set(handles.labelObjButton,'Enable','Off');
    msgbox('Well done!!! This folder is finished!!!');
    return;
end

index = index + 1;
name = imgList(index).name;
img =imread([folder_name, '/', name]);

name = strtok(name,'.');
[height,width,depth] = size(img);
set(handles.startButton,'UserData',name);
imagesc(img);
set(gca,'Units','pixels');
colormap('gray');
set(hObject,'UserData',index);
set(handles.axes, 'UserData', [height width]);
objectNum = 0;
set(handles.labelObjButton,'UserData',objectNum);
record.annotation.size.width = width;
record.annotation.size.height = height;
record.annotation.size.depth = depth;

% clean labeled objects & parts
set(handles.delObjButton,'Enable','Off');
set(handles.checkbox2,'Enable','Off');
set(handles.checkbox3,'Enable','Off');
set(handles.delPartButton,'Enable','Off');
set(handles.checkbox1,'Enable','Off');
set(handles.listbox3,'String','');
set(handles.listbox4,'String','');

% hObject    handle to nextImgButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
tableList(handles.listbox1, 'Data/catePartList.mat', 1);
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
global record
folder_name = get(handles.edit2,'string');
anno_name = get(handles.edit3,'String');
if ~exist(folder_name,'dir') || ~exist(anno_name,'dir');
    msgbox('Select valid folders first!');
    return;
end
imgList = dir(folder_name);

index = 3; % the index of the image in current image path
name = imgList(index).name;
img =imread([folder_name, '/', name]);

imagesc(img);
[height, width, depth] = size(img);
set(handles.axes,'UserData',[height width]);
set(gca,'Units','pixels');
colormap('gray');
set(handles.nextImgButton,'UserData',index);
set(handles.labelObjButton,'Enable','On');
set(handles.nextImgButton,'Enable','On');
set(handles.labelPartButton,'Enable','Off');
set(handles.partFinishButton,'Enable','Off');

% clean labeled objects & parts
set(handles.delObjButton,'Enable','Off');
set(handles.checkbox2,'Enable','Off');
set(handles.checkbox3,'Enable','Off');
set(handles.delPartButton,'Enable','Off');
set(handles.checkbox1,'Enable','Off');
set(handles.listbox3,'String','');
set(handles.listbox4,'String','');

% annotation record assignment
set(handles.labelObjButton,'UserData', 0); % initialize the object number
name = strtok(name,'.');
set(hObject,'UserData',name);
record = PASemptyrecord;
record.annotation.size.width = width;
record.annotation.size.height = height;
record.annotation.size.depth = depth;
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function h=drawbox(pts, color)
if numel(pts.xmin) ~= 0
    pts = [pts.xmin pts.ymin pts.xmax pts.ymax];
    h=line(pts([1 3 3 1 1]),pts([2 2 4 4 2]),'Color',color,'LineWidth',1);
end
return


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
index_selected = get(hObject,'Value');
list = get(hObject,'String');
global record
parts = record.annotation.object(index_selected).part;

set(handles.checkbox2,'Value',record.annotation.object(index_selected).truncated);
set(handles.checkbox3,'Value',record.annotation.object(index_selected).difficult);
partNum = numel(parts);
partNames = cell(partNum,1);

for i = 1 : partNum
    partNames{i} = parts(i).name;
end
set(handles.listbox4,'Value',1);
set(handles.listbox4,'string',partNames);
if numel(parts(1).bndbox.xmin) ~= 0
    set(handles.checkbox1,'Enable','On');
    set(handles.checkbox1,'Value',record.annotation.object(index_selected).part(1).occluded);
else
    set(handles.checkbox1,'Enable','Off');
end
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
objectIndex = get(handles.listbox3,'Value');
partIndex = get(hObject,'Value');
global record
set(handles.checkbox1,'Value',record.annotation.object(objectIndex).part(partIndex).occluded);
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in delObjButton.
function delObjButton_Callback(hObject, eventdata, handles)
index = get(handles.listbox3,'Value');
objectNum = get(handles.labelObjButton,'UserData');
objectNum = objectNum - 1;
set(handles.labelObjButton,'UserData',objectNum); 
global record
objects(1:index-1) = record.annotation.object(1:index-1);
objects(index:objectNum) = record.annotation.object(index+1:end);
delObject = record.annotation.object(index);
if objectNum ~= 0
    record.annotation.object = objects;
else
    record.annotation.object = PASemptyobject;
end

% delete the bounding box drawn
drawbox(delObject.bndbox,[1 1 1]);
part = delObject.part;
numPart = numel(part);
for i = 1 : numPart
    drawbox(part(i).bndbox,[1 1 1]);
end

%set the labelled object list
objNames = cell(objectNum,1);
for i = 1 : objectNum
    objNames{i} = record.annotation.object(i).name;
end
set(handles.listbox3,'Value',1);
set(handles.listbox3,'String',objNames);

if objectNum == 0
    set(hObject,'Enable','off');
    set(handles.delPartButton,'Enable','off');
    set(handles.checkbox1,'Enable','Off');
    set(handles.checkbox2,'Enable','Off');
    set(handles.checkbox3,'Enable','Off');
end

%set the labelled part list
numPart = numel(record.annotation.object(1).part);
if numPart ~= 0
    set(handles.listbox4,'Value',1);
    partNames = cell(numPart,1);
    for i = 1 : numPart
        partNames{i} = record.annotation.object(1).part(i).name;
    end
    set(handles.listbox4,'Value',1)
    set(handles.listbox4,'String',partNames);
    set(handles.checkbox1,'Value',record.annotation.object(1).part(1).occluded);
end


% hObject    handle to delObjButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in delPartButton.
function delPartButton_Callback(hObject, eventdata, handles)
objIndex = get(handles.listbox3,'Value');
partIndex = get(handles.listbox4,'Value');
global record
part = record.annotation.object(objIndex).part;
partNum = numel(part);
partNew(1:partIndex-1) = part(1:partIndex-1);
partNew(partIndex:partNum-1) = part(partIndex+1:end);
partDel = part(partIndex);
partNum = partNum - 1;
set(handles.labelPartButton,'UserData', partNum);
if partNum ~= 0
    record.annotation.object(objIndex).part = partNew;
    set(handles.checkbox1,'Value',record.annotation.object(objIndex).part(partNum).occluded);
else
    record.annotation.object(objIndex).part = PASemptypart;
    set(hObject,'Enable','Off');
    set(handles.checkbox1,'Value',0);
    set(handles.checkbox1,'Enable','Off');
end

%delete the bounding box of that part
drawbox(partDel.bndbox, [1 1 1]);

%refresh the labeled part listbox

partNames = cell(partNum,1);
for i = 1 : partNum
    partNames{i} = partNew(i).name;
end
set(handles.listbox4,'Value', partNum);
set(handles.listbox4,'String',partNames);
% hObject    handle to delPartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
value = get(hObject,'Value');
objectIndex = get(handles.listbox3,'Value');
partIndex = get(handles.listbox4,'Value');
global record;
record.annotation.object(objectIndex).part(partIndex).occluded = value;
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
value = get(hObject,'Value');
objectIndex = get(handles.listbox3,'Value');
global record;
record.annotation.object(objectIndex).truncated = value;
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
value = get(hObject,'Value');
objectIndex = get(handles.listbox3,'Value');
global record;
record.annotation.object(objectIndex).difficult = value;
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on selection change in listboxPose.
function listboxPose_Callback(hObject, eventdata, handles)
% hObject    handle to listboxPose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxPose contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxPose

% --- Executes during object creation, after setting all properties.
function listboxPose_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxPose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
if exist('Data/poseList.mat', 'file')
    load('Data/poseList.mat');
    list = a(:,1);
    set(hObject,'Value',1);
    set(hObject,'string',list);
end

% --- Executes on button press in editPoseButton.
function editPoseButton_Callback(hObject, eventdata, handles)
% hObject    handle to editPoseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tableList(handles.listboxPose, 'Data/poseList.mat', 0);
