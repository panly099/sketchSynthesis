function varargout = judge(varargin)
% JUDGE MATLAB code for judge.fig
%      JUDGE, by itself, creates a new JUDGE or raises the existing
%      singleton*.
%
%      H = JUDGE returns the handle to a new JUDGE or the handle to
%      the existing singleton*.
%
%      JUDGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JUDGE.M with the given input arguments.
%
%      JUDGE('Property','Value',...) creates a new JUDGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before judge_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to judge_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help judge

% Last Modified by GUIDE v2.5 22-May-2015 12:55:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @judge_OpeningFcn, ...
                   'gui_OutputFcn',  @judge_OutputFcn, ...
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


% --- Executes just before judge is made visible.
function judge_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to judge (see VARARGIN)

% Choose default command line output for judge
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes judge wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.pushbuttonStart,'userData',varargin{1});

% --- Outputs from this function are returned to the command line.
function varargout = judge_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonStart.
function pushbuttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = get(hObject, 'UserData');
ratePath = [path, '/rating'];
sketches = dir(ratePath);
numSketches = length(sketches)-2;
if exist([path,'/rateResults.mat'],'file')
    delete([path,'/rateResults.mat']);
end

order = randperm(numSketches);
realOrNot = [zeros(1,numSketches/2), ones(1,numSketches/2)];
rate = zeros(3,numSketches);
rate(1,:) = order;
rate(2,:) = realOrNot(order);

save([path,'/rateResults.mat'], 'rate');
path = [path, '/rating'];
index = 1;
imageList = dir(path);
im = imread([path,'/', num2str(rate(1,index)), '.png']);
if rate(1,index) > numSketches/2
    % tu-berlin dataset
%             [~,~,im] = imread([path,'/', num2str(rate(1,index)), '.png']);
            
    % portrait face dataset
            im = imread([path,'/', num2str(rate(1,index)), '.png']);
            im = im(:,:,1);
            im = im ~= 255;
            se = strel('disk',3,8);
            im = imdilate(im, se);
            im = ~im;
            addpath('/homes/yl303/Documents/MATLAB/Sketchlet/Functions/facilities');
            bbox = getBoundingBox(~im, 0);
            im = im(bbox(2):bbox(4),bbox(1):bbox(3));
end
        
imshow(im);
index = index + 1;
set(handles.pushbuttonNext,'UserData', index);
set(hObject,'enable','off');

% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
valueReal = get(handles.radiobuttonReal,'value');
valueSyn = get(handles.radiobuttonSyn,'value');
if valueReal + valueSyn == 0
    msgbox('Please decide the sketch is drawn by a real human or not.');
else
    path = get(handles.pushbuttonStart, 'UserData');
    load([path,'/rateResults.mat']);
    index = get(hObject,'UserData');
    
    if valueReal == 1 
        rate(3,index - 1) = 1;
    else
        rate(3,index - 1) = 0;
    end
    save([path,'/rateResults.mat'], 'rate');
    path = [path, '/rating'];
    
    imageList = dir(path);
    if index <= size(rate,2)
        im = imread([path,'/', num2str(rate(1,index)),'.png']);
        if rate(1,index) > size(rate,2)/2
            % tu-berlin dataset
            %             [~,~,im] = imread([path,'/', num2str(rate(1,index)), '.png']);
            
            % portrait face dataset
            im = imread([path,'/', num2str(rate(1,index)), '.png']);
            im = im(:,:,1);
            im = im ~= 255;
            
            se = strel('disk',1,8);
            im = imdilate(im, se);
            im = ~im;
            addpath('/homes/yl303/Documents/MATLAB/Sketchlet/Functions/facilities');
            bbox = getBoundingBox(~im, 0);
            im = im(bbox(2):bbox(4),bbox(1):bbox(3));
        end
        imshow(im);
        index = index + 1;
        set(hObject,'UserData', index);
        
        set(handles.radiobuttonReal,'value',0);
        set(handles.radiobuttonSyn,'value',0);
    else
        msgbox('Well done! You have finished! Yi appreciate your work very much! Cheers!');
    end
end
% --- Executes on button press in radiobuttonReal.
function radiobuttonReal_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonReal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonReal
set(handles.radiobuttonSyn,'value',0);

% --- Executes on button press in radiobuttonSyn.
function radiobuttonSyn_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSyn
set(handles.radiobuttonReal,'value',0);
