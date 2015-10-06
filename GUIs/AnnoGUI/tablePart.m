function varargout = tablePart(varargin)
% TABLEPART MATLAB code for tablePart.fig
%      TABLEPART, by itself, creates a new TABLEPART or raises the existing
%      singleton*.
%
%      H = TABLEPART returns the handle to a new TABLEPART or the handle to
%      the existing singleton*.
%
%      TABLEPART('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLEPART.M with the given input arguments.
%
%      TABLEPART('Property','Value',...) creates a new TABLEPART or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tablePart_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tablePart_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tablePart

% Last Modified by GUIDE v2.5 29-Jul-2015 14:19:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tablePart_OpeningFcn, ...
                   'gui_OutputFcn',  @tablePart_OutputFcn, ...
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


% --- Executes just before tablePart is made visible.
function tablePart_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tablePart (see VARARGIN)

% Choose default command line output for tablePart
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
cate = varargin{1}(2);
load('Data/catePartList.mat');
[x y] = size(a);
list = a{cate,2}';
set(handles.uitable2,'data',list);
set(handles.uitable2,'UserData',cate);
% UIWAIT makes tablePart wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tablePart_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
load('Data/catePartList.mat');
cate = get(handles.uitable2,'UserData');
temp = a{cate,2};
[x y] = size(temp);
if x == 10
    msgbox('Maximum 10 elements!');
    return;
end
temp{x+1,1} = 'new';
a{cate,2} = temp;
save('Data/catePartList.mat', 'a');
list = a{cate,2}';
set(handles.uitable2,'data',list);
% hObject    handle to pushbutton_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_del.
function pushbutton_del_Callback(hObject, eventdata, handles)

indices = get(hObject,'UserData');
cate = get(handles.uitable2,'UserData');
load('Data/catePartList.mat');
temp = a{cate,2};
[xa ya] = size(temp);
x = indices(2);
b(1:x-1,:) = temp(1:x-1,:);
b(x:xa-1,:)=temp(x+1:xa,:);
a{cate,2} = b;
save('Data/catePartList.mat', 'a');
list = a{cate,2}';
set(handles.uitable2,'data',list);
set(hObject,'Enable','Off');


% hObject    handle to pushbutton_del (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function uitable2_CreateFcn(hObject, eventdata, handles)

% hObject    handle to uitable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when entered data in editable cell(s) in uitable2.
function uitable2_CellEditCallback(hObject, eventdata, handles)
load('Data/catePartList.mat');
cate = get(hObject,'UserData');
x = eventdata.Indices(2);
a{cate,2}{x} = eventdata.EditData;
save('Data/catePartList.mat', 'a');
list = a{cate,2}';
set(hObject,'data',list);
% hObject    handle to uitable2 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected cell(s) is changed in uitable2.
function uitable2_CellSelectionCallback(hObject, eventdata, handles)
load('Data/catePartList.mat');
cate = get(handles.uitable2,'UserData');
if numel(eventdata.Indices) ~= 0 && numel(a{cate,2}) ~= 0
    set(handles.pushbutton_del,'Enable','On');
    set(handles.pushbutton_del,'UserData',eventdata.Indices);
end
% hObject    handle to uitable2 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
