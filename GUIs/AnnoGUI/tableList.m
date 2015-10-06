function varargout = tableList(varargin)
% TABLELIST MATLAB code for tableList.fig
%      TABLELIST, by itself, creates a new TABLELIST or raises the existing
%      singleton*.
%
%      H = TABLELIST returns the handle to a new TABLELIST or the handle to
%      the existing singleton*.
%
%      TABLELIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLELIST.M with the given input arguments.
%
%      TABLELIST('Property','Value',...) creates a new TABLELIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tableList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tableList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tableList

% Last Modified by GUIDE v2.5 27-Apr-2015 23:37:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tableList_OpeningFcn, ...
                   'gui_OutputFcn',  @tableList_OutputFcn, ...
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


% --- Executes just before tableList is made visible.
function tableList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tableList (see VARARGIN)

% Choose default command line output for tableList
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.uitable2,'UserData',{varargin{1} varargin{2}});
set(handles.editPartButton, 'UserData', varargin{3});
if varargin{3} == 1
    set(handles.editPartButton, 'Visible', 'On');
else
    set(handles.editPartButton, 'Visible', 'Off');
end

if exist(varargin{2},'file')
    load(varargin{2});
    if ~isempty(a)
        list = a(:,1)';
        set(handles.uitable2,'data',list);
    else
        set(handles.uitable2,'data',{});
    end
else
    set(handles.uitable2, 'Enable','Off');
end
% UIWAIT makes tableList wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tableList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)
dataFile = get(handles.uitable2,'UserData');
dataFile = dataFile{2};
flag = get(handles.editPartButton, 'UserData');
if exist(dataFile, 'file')
    load(dataFile);
else
    a = {};
    set(handles.uitable2,'Enable','On');
end
[x, ~] = size(a);

if flag == 1
    if x == 10
        msgbox('Maximum 10 categories!');
        return;
    end
else
    if x == 4
        msgbox('Maximum 4 poses!');
        return;
    end
end
a{x+1,1} = 'new';
if flag== 1
    a{x+1,2} = cell(1,1);
end
save(dataFile, 'a');
list = a(:,1)';
set(handles.uitable2,'data',list);
% hObject    handle to addButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in editPartButton.
function editPartButton_Callback(hObject, eventdata, handles)
indices = get(hObject,'UserData');
tablePart(indices);
% hObject    handle to editPartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function uitable2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in delButton.
function delButton_Callback(hObject, eventdata, handles)
indices = get(hObject,'UserData');
dataFile = get(handles.uitable2,'UserData');
dataFile = dataFile{2};
load(dataFile);
[xa,~] = size(a);
x = indices(2);
b(1:x-1,:) = a(1:x-1,:);
b(x:xa-1,:)=a(x+1:xa,:);
a = b;
if ~isempty(a)
    save(dataFile, 'a');
else
    delete(dataFile);
end
if ~isempty(a)
    list = a(:,1)';
    set(handles.uitable2,'data',list);
else
    set(handles.uitable2,'data',{});
end
set(hObject,'Enable','Off');
set(handles.editPartButton, 'Enable', 'Off');
% hObject    handle to delButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in uitable2.
function uitable2_CellEditCallback(hObject, eventdata, handles)
dataFile = get(handles.uitable2,'UserData');
dataFile = dataFile{2};
if exist(dataFile, 'file')
    load(dataFile);
else 
    a = {};
end
x = eventdata.Indices(2);
a{x,1} = eventdata.EditData;
save(dataFile, 'a');
list = a(:,1)';
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
if numel(eventdata.Indices) ~= 0 
    set(handles.delButton,'Enable','On');
    set(handles.editPartButton,'Enable','On');
    set(handles.editPartButton,'UserData',eventdata.Indices);
    set(handles.delButton,'UserData',eventdata.Indices);
end
% hObject    handle to uitable2 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function uitable2_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataFile = get(handles.uitable2,'UserData');
dataFile = dataFile{2};
if exist(dataFile,'file')
    handle = get(hObject,'UserData');
    handle = handle{1};
    load(dataFile);
    list = a(:,1);
    set(handle,'string',list);
end
