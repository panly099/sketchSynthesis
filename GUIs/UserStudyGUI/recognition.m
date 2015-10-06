function varargout = recognition(varargin)
% RECOGNITION MATLAB code for recognition.fig
%      RECOGNITION, by itself, creates a new RECOGNITION or raises the existing
%      singleton*.
%
%      H = RECOGNITION returns the handle to a new RECOGNITION or the handle to
%      the existing singleton*.
%
%      RECOGNITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECOGNITION.M with the given input arguments.
%
%      RECOGNITION('Property','Value',...) creates a new RECOGNITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before recognition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to recognition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help recognition

% Last Modified by GUIDE v2.5 16-May-2015 17:04:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @recognition_OpeningFcn, ...
                   'gui_OutputFcn',  @recognition_OutputFcn, ...
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


% --- Executes just before recognition is made visible.
function recognition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to recognition (see VARARGIN)

% Choose default command line output for recognition
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes recognition wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.pushbuttonStart,'UserData',varargin{1});
set(handles.pushbuttonNext,'enable','off');

% --- Outputs from this function are returned to the command line.
function varargout = recognition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
index_selected = get(hObject,'Value');
list = get(hObject,'String');
item_selected = list{index_selected}; 
set(handles.editRecog,'String',item_selected);




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


% --- Executes on button press in pushbuttonStart.
function pushbuttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = get(hObject, 'UserData');
if exist([path,'/recogResults.mat'],'file')
    delete([path,'/recogResults.mat']);
end
path = [path,'/recognition'];
imageList = dir([path,'/*.png']);
index = 1;
im = imread([path,'/', imageList(index).name]);
imshow(im);
set(handles.pushbuttonNext, 'userData', index);
set(handles.pushbuttonNext,'enable','on');
set(hObject,'enable','off');

% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
recogString = get(handles.editRecog,'String');
if ~isempty(recogString)
    path = get(handles.pushbuttonStart,'UserData');
    if exist([path,'/recogResults.mat'],'file')
        load([path,'/recogResults']);
    else 
        recogResults = {};
    end
    sketchPath = [path,'/recognition'];
    
    recogClass = get(handles.editRecog, 'String');
    recogResults{end+1} = recogClass;
    save([path,'/recogResults.mat'], 'recogResults');
    
    index = get(hObject, 'UserData');
  
    imageList = dir([sketchPath,'/*.png']);
    index = index + 1;
    if index <= length(imageList)
        set(hObject,'UserData',index);
        im = imread([sketchPath,'/',imageList(index).name]);
        imshow(im);
    else
        msgbox('Well done! Please go to next task!');
        set(hObject,'enable','off');
    end
    
else
    msgbox('Please select a category you think this sketch belongs to.');
end


function editRecog_Callback(hObject, eventdata, handles)
% hObject    handle to editRecog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRecog as text
%        str2double(get(hObject,'String')) returns contents of editRecog as a double


% --- Executes during object creation, after setting all properties.
function editRecog_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRecog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
