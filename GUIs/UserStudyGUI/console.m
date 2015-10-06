function varargout = console(varargin)
% CONSOLE MATLAB code for console.fig
%      CONSOLE, by itself, creates a new CONSOLE or raises the existing
%      singleton*.
%
%      H = CONSOLE returns the handle to a new CONSOLE or the handle to
%      the existing singleton*.
%
%      CONSOLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONSOLE.M with the given input arguments.
%
%      CONSOLE('Property','Value',...) creates a new CONSOLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before console_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to console_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help console

% Last Modified by GUIDE v2.5 16-May-2015 16:46:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @console_OpeningFcn, ...
                   'gui_OutputFcn',  @console_OutputFcn, ...
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


% --- Executes just before console is made visible.
function console_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to console (see VARARGIN)

% Choose default command line output for console
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.pushbuttonStart,'enable','off');
set(handles.pushbuttonT1,'enable','off');
set(handles.pushbuttonT2,'enable','off');
set(handles.pushbuttonT3,'enable','off');
% UIWAIT makes console wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = console_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editId_Callback(hObject, eventdata, handles)
% hObject    handle to editId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editId as text
%        str2double(get(hObject,'String')) returns contents of editId as a double
id = get(handles.editId,'String');
if ~isempty(id)
    set(handles.pushbuttonStart,'enable','on');
else
    set(handles.pushbuttonStart,'enable','off');
end

% --- Executes during object creation, after setting all properties.
function editId_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonStart.
function pushbuttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
id = get(handles.editId,'String');
path = ['../../results/EvaluationCR/',id];
if ~exist(path,'dir')
    msgbox('Invalid Id! Please re-input.');    
else
    set(handles.pushbuttonT1,'enable','off');
     set(handles.pushbuttonT2,'enable','on');
      set(handles.pushbuttonT3,'enable','off');
    set(handles.pushbuttonStart,'enable','off');
    set(handles.pushbuttonT1, 'userData', path);
end

% --- Executes on button press in pushbuttonT1.
function pushbuttonT1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = get(hObject,'UserData');
recognition(path);
set(handles.pushbuttonT2,'enable','on');
set(handles.pushbuttonT1,'enable','off');

% --- Executes on button press in pushbuttonT2.
function pushbuttonT2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = get(handles.pushbuttonT1,'UserData');
comparison(path);
set(handles.pushbuttonT3,'enable','on');
set(handles.pushbuttonT2,'enable','off');
set(handles.pushbuttonT1,'enable','off');

% --- Executes on button press in pushbuttonT3.
function pushbuttonT3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonT3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = get(handles.pushbuttonT1,'UserData');
judge(path);
set(handles.pushbuttonT3,'enable','off');
set(handles.pushbuttonT2,'enable','off');
set(handles.pushbuttonT1,'enable','off');
