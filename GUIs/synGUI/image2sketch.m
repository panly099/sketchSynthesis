function varargout = image2sketch(varargin)
% IMAGE2SKETCH MATLAB code for image2sketch.fig
%      IMAGE2SKETCH, by itself, creates a new IMAGE2SKETCH or raises the existing
%      singleton*.
%
%      H = IMAGE2SKETCH returns the handle to a new IMAGE2SKETCH or the handle to
%      the existing singleton*.
%
%      IMAGE2SKETCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE2SKETCH.M with the given input arguments.
%
%      IMAGE2SKETCH('Property','Value',...) creates a new IMAGE2SKETCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image2sketch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image2sketch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help image2sketch

% Last Modified by GUIDE v2.5 29-Jul-2015 00:30:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @image2sketch_OpeningFcn, ...
                   'gui_OutputFcn',  @image2sketch_OutputFcn, ...
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


% --- Executes just before image2sketch is made visible.
function image2sketch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image2sketch (see VARARGIN)

% Choose default command line output for image2sketch
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.pushbutton_Bbox, 'Enable', 'off');
addpath('../../scripts');
configureScript;
% UIWAIT makes image2sketch wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = image2sketch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browse.
function pushbutton_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lastPath = get(hObject, 'UserData');
if ~isempty(lastPath)
    [fileName, pathName] = uigetfile('*.*','Select an image',lastPath);
else
    [fileName, pathName] = uigetfile('*.*','Select an image');
end
if pathName ~= 0
    set(handles.edit1,'string',fileName);
    set(handles.pushbutton_browse,'UserData',pathName);

    im = imread([pathName,'/',fileName]);
    imshow(im);
    set(handles.axes1,'UserData',im);
    set(handles.pushbutton_Bbox, 'Enable', 'on');
end
% --- Executes on button press in pushbutton_Bbox.
function pushbutton_Bbox_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Bbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y,but]=ginput(1);
if lower(char(but)) == 1 || lower(char(but)) == 2 || lower(char(but)) == 3
    p1=get(gca,'CurrentPoint');
    rbbox;
    p2=get(gca,'CurrentPoint');
    p=round([p1;p2]);
    xmin=min(p(:,1));xmax=max(p(:,1));
    ymin=min(p(:,2));ymax=max(p(:,2));
end
im = get(handles.axes1,'UserData');
[height, width, ~] = size(im);
if xmin < 1
    xmin = 1;
end
if ymin < 1
    ymin = 1;
end
if xmax > width
    xmax = width;
end
if ymax > height
    ymax = height;
end
croppedImg = im(ymin:ymax,xmin:xmax,:);
imshow(croppedImg);
set(hObject, 'Enable', 'off');

flag = get(handles.radiobutton1, 'value');



index_selected = get(handles.listboxCate,'Value');
list = get(handles.listboxCate,'String');
cate = list{index_selected}; 

load(['../../results/',cate,'/cateInfo/strokeModel_final.mat']);
type = 'testing';
paramSettingScript;
cateId = find(ismember(cates,cate));

tic;
if isempty(strfind(cate,'face'))
    I = rgb2gray(croppedImg);
    
    if flag
        I = flip(I,2);
    end
    I = imresize(I, [strokeModel.avgHeight, strokeModel.avgWidth]);

    edgeSoft = pbCanny(double(I)/255);
    edgeSecond = edgeSoft > edgeThreshold(cateId);
    se = strel('disk',1,8);
    edgeSecond = imdilate(edgeSecond, se);
else
    tmp = croppedImg(:,:,1);
    tmp = imresize(tmp, [strokeModel.avgHeight, strokeModel.avgWidth]);
    tmp = tmp< 255;
    
    if flag
        tmp = flip(tmp,2);
    end
    
    edgeSecond = tmp;
end

% figure;imshow(~edgeSecond);

configuration = strokeSampling(edgeSecond, strokeModel,detScale(cateId), 1.1, 1.1, 0.7, 5);
detection = sketchDetect(edgeSecond, strokeModel, configuration, detScale(cateId), 0.7, 0.4);

synthesized1 = zeros(strokeModel.avgHeight, strokeModel.avgWidth);
for i = 1 : length(detection)
   if ~isempty(detection{i})
       synthesized1 = synthesized1 + detection{i};
   end
end

refineDet = detRefinePureLocation(detection,strokeModel, refineCircle(cateId), refineStep(cateId));
toc;

synthesized2 = zeros(strokeModel.avgHeight, strokeModel.avgWidth);
for i = 1 : length(refineDet)
   if ~isempty(refineDet{i})
       synthesized2 = synthesized2 + refineDet{i};
   end
end

if flag
    edgeSecond = flip(edgeSecond,2);
    synthesized1 = flip(synthesized1,2);
    synthesized2 = flip(synthesized2,2);
end

% figure;
% subplot(1,4,1);
% imshow(croppedImg);
% title('Image');
% 
% subplot(1,4,2);
% imshow(~edgeSecond);
% title('Edge map');
% 
% subplot(1,4,3);
% imshow(~synthesized1);
% title('Synthesis');
% 
% subplot(1,4,4);
imshow(~synthesized2);
% title('Refinement');
% 

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on selection change in listboxCate.
function listboxCate_Callback(hObject, eventdata, handles)
% hObject    handle to listboxCate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxCate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxCate


% --- Executes during object creation, after setting all properties.
function listboxCate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxCate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
