function varargout = comparison(varargin)
% COMPARISON MATLAB code for comparison.fig
%      COMPARISON, by itself, creates a new COMPARISON or raises the existing
%      singleton*.
%
%      H = COMPARISON returns the handle to a new COMPARISON or the handle to
%      the existing singleton*.
%
%      COMPARISON('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPARISON.M with the given input arguments.
%
%      COMPARISON('Property','Value',...) creates a new COMPARISON or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before comparison_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to comparison_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help comparison

% Last Modified by GUIDE v2.5 22-May-2015 12:17:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @comparison_OpeningFcn, ...
                   'gui_OutputFcn',  @comparison_OutputFcn, ...
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


% --- Executes just before comparison is made visible.
function comparison_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to comparison (see VARARGIN)

% Choose default command line output for comparison
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes comparison wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.pushbuttonStart,'userData',varargin{1});
set(handles.pushbuttonNext,'enable','off');
% --- Outputs from this function are returned to the command line.
function varargout = comparison_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonStart.
function pushbuttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = get(hObject,'UserData');
if exist([path,'/linkResults.mat'],'file')
    delete([path,'/linkResults.mat']);
end

linkPath = [path,'/linking'];
index = 1;

linkPath = [linkPath,'/', num2str(index)];
pairList = dir(linkPath);

p = randperm(2);
link = zeros(18,2);
if p(1) == 1
    link(1,1) = 1;
else
    link(1,1) = 0;
end
save([path,'/linkResults.mat'], 'link');

imgPath = [linkPath,'/', pairList(3).name, '/image.png'];
axes(handles.axes1);
imshow(imread(imgPath));

imgPath = [linkPath,'/', pairList(p(1)+2).name, '/refinement.png'];
axes(handles.axes2);
imshow(imread(imgPath));

imgPath = [linkPath,'/', pairList(4).name, '/image.png'];
axes(handles.axes3);
imshow(imread(imgPath));

imgPath = [linkPath,'/', pairList(p(2)+2).name, '/refinement.png'];
axes(handles.axes4);
imshow(imread(imgPath));

% imgPath = [path,'/', pairList(5).name, '/image.png'];
% axes(handles.axes5);
% imshow(imread(imgPath));
% 
% imgPath = [path,'/', pairList(p(3)+2).name, '/refinement.png'];
% axes(handles.axes6);
% imshow(imread(imgPath));
set(hObject, 'enable', 'off');
set(handles.pushbuttonNext, 'userData', index);
set(handles.pushbuttonNext,'enable','on');

% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
valueCorrect = get(handles.radiobuttonCorrect, 'value');
valueReverse = get(handles.radiobuttonReverse, 'value');
if valueCorrect + valueReverse == 0
    msgbox('Please select one mapping!');
else
    path = get(handles.pushbuttonStart,'UserData');
    index = get(hObject,'UserData');
    load([path,'/linkResults.mat']);
    if valueCorrect == 1
        link(index,2) = 1;
    else
        link(index,2) = 0;
    end
    

    linkPath = [path,'/linking'];
    
    index = index + 1;
    linkPath = [linkPath,'/', num2str(index)];
    if exist(linkPath, 'dir')
    pairList = dir(linkPath);
    
    p = randperm(2);
    if p(1) == 1
        link(index,1) = 1;
    else
        link(index,1) = 0;
    end
    
    imgPath = [linkPath,'/', pairList(3).name, '/image.png'];
    axes(handles.axes1);
    imshow(imread(imgPath));
    
    imgPath = [linkPath,'/', pairList(p(1)+2).name, '/refinement.png'];
    axes(handles.axes2);
    imshow(imread(imgPath));
    
    imgPath = [linkPath,'/', pairList(4).name, '/image.png'];
    axes(handles.axes3);
    imshow(imread(imgPath));
    
    imgPath = [linkPath,'/', pairList(p(2)+2).name, '/refinement.png'];
    axes(handles.axes4);
    imshow(imread(imgPath));
    
%     imgPath = [path,'/', pairList(5).name, '/image.png'];
%     axes(handles.axes5);
%     imshow(imread(imgPath));
%     
%     imgPath = [path,'/', pairList(p(3)+2).name, '/refinement.png'];
%     axes(handles.axes6);
%     imshow(imread(imgPath));
    
    set(handles.pushbuttonNext, 'userData', index);
    save([path,'/linkResults.mat'], 'link');
    
    set(handles.radiobuttonCorrect, 'value', 0);
    set(handles.radiobuttonReverse, 'value', 0);
    else
        msgbox('Well done! Please go to next task1');
    end
end

function editOrder_Callback(hObject, eventdata, handles)
% hObject    handle to editOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOrder as text
%        str2double(get(hObject,'String')) returns contents of editOrder as a double


% --- Executes during object creation, after setting all properties.
function editOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobuttonCorrect.
function radiobuttonCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonCorrect
set(handles.radiobuttonReverse,'Value',0);

% --- Executes on button press in radiobuttonReverse.
function radiobuttonReverse_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonReverse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonReverse
set(handles.radiobuttonCorrect,'Value',0);
