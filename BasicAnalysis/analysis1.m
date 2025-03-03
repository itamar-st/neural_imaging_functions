function varargout = analysis1(varargin)
% ANALYSIS1 M-file for analysis1.fig
%      ANALYSIS1, by itself, creates a new ANALYSIS1 or raises the existing
%      singleton*.
%
%      H = ANALYSIS1 returns the handle to a new ANALYSIS1 or the handle to
%      the existing singleton*.
%
%      ANALYSIS1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSIS1.M with the given input arguments.
%
%      ANALYSIS1('Property','Value',...) creates a new ANALYSIS1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before analysis1_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to analysis1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help analysis1

% Last Modified by GUIDE v2.5 16-Apr-2007 15:19:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @analysis1_OpeningFcn, ...
                   'gui_OutputFcn',  @analysis1_OutputFcn, ...
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


% --- Executes just before analysis1 is made visible.
function analysis1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to analysis1 (see VARARGIN)

% Choose default command line output for analysis1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes analysis1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = analysis1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function dateBottonTXT_Callback(hObject, eventdata, handles)
% hObject    handle to dateBottonTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dateBottonTXT as text
%        str2double(get(hObject,'String')) returns contents of dateBottonTXT as a double


% --- Executes during object creation, after setting all properties.
function dateBottonTXT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dateBottonTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pathButtonTXT_Callback(hObject, eventdata, handles)
% hObject    handle to pathButtonTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pathButtonTXT as text
%        str2double(get(hObject,'String')) returns contents of pathButtonTXT as a double


% --- Executes during object creation, after setting all properties.
function pathButtonTXT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pathButtonTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%% --- Executes on button press in dateButton.
function dateButton_Callback(hObject, eventdata, handles)
% hObject    handle to dateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.rsd','Select the RSD-file');
MYhandles.date = FileName(1:4);
MYhandles.PathNameInput = PathName;
set(handles.dateButtonTXT,'String',[PathName,FileName(1:4)])
 set(handles.condTXT,'String','choose directory in the output directory slot');
handles.MYhandles = MYhandles;
% Update handles structure
guidata(hObject, handles);


%% --- Executes on button press in pathBotton.
function pathBotton_Callback(hObject, eventdata, handles)
% hObject    handle to pathBotton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PathName = uigetdir;
MYhandles.PathNameOutput = [PathName,'/'];
set(handles.pathButtonTXT,'String',PathName)
 set(handles.condTXT,'String','Up load your files to MAT files');
handles.MYhandles.PathNameOutput = MYhandles.PathNameOutput;
% Update handles structure
guidata(hObject, handles);

%% --- Executes on button press in loadFilesButton.
function loadFilesButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadFilesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MYhandles = handles.MYhandles;
date = MYhandles.date;

PathName = MYhandles.PathNameInput;
PathNameOut = MYhandles.PathNameOutput;

for condsNo = 1:9
    if get(handles.append,'value')==1
        keyNo = size(dir ([PathNameOut,date,'_',num2str(condsNo),'*.mat']),1);%find the highest key number
        fileNo = condsNo*1000+keyNo;
    else
        fileNo = condsNo*1000;
    end  
    
    files_temp = sort_rsd_files(PathName,date,condsNo);
    cd (PathNameOut)
    files = {files_temp.name}';
    
    cond = zeros(10000,256,1);
    frame_total=256;
    for a = 1:size(files,1);
        disp(['Cond No. ',num2str(condsNo),'  ,',files{a}  ' save as - ', date,'_',num2str(fileNo),'.mat'])
        %% read the file
        fid = fopen([PathName,files{a}]);
        A1=[];
        A1 = [A1,fread(fid,[12800,256],'int16')];
        A2 = reshape(A1,128,100,256);
        
        A3_temp = reshape(squeeze(A2(1:20,1:100,:)),2000,256);
        HB(:,a) = A3_temp(13,:);
        
        FRM = zeros(100,100,frame_total);
        FRMpre = zeros(10000,frame_total);

        %%header is off
        FRM=reshape(squeeze(A2(21:120,1:100,:)),100,100,256);
        
        %% make the frames
        if get(handles.IntrinsicButton,'value')==1% for intrisic signal
            FRM(:,:,2:256) = FRM(:,:,2:end)+FRM(:,:,ones(1,1,255));
            FRMpre=reshape(FRM,10000,256);
            SigmaMat = str2num(get(handles.SigmaMat,'String'));MYhandles.SigmaMat = SigmaMat;
            if ~isnan(SigmaMat)
                for b = 1:10000
                    %                  csaps(1:256,mean(FRMpre(b,:),1),1e-4,1:256);
                    FRMpre(b,:) = filtx(FRMpre(b,:),SigmaMat,'lm');
                end
            end
        else
            FRMpre=reshape(FRM,10000,256);
        end

        %% save the conds
        FileName = files{a};
        save ([PathNameOut,date,'_',num2str(fileNo),'.mat'],'FRMpre','FileName','HB');
        fclose(fid);
        fileNo = fileNo + 1;
    end
end

% arange the files by index
files_temp = sort_rsd_files(PathName,date,'all');
cd (PathNameOut)
fileIND = {files_temp.name}';
save ([PathNameOut,'fileIND.mat'],'fileIND')

if get(handles.filesAndConds,'value')==1
    conds = zeros(10000,256,7);
    for condsNo = 1:7
        files = dir ([PathNameOut,date,'_',num2str(condsNo),'*.mat']);% name of the condition
        cond = zeros(10000,256,1);
        frame_total=256;
        for a = 1:size(files,1);
            disp (files(a).name)
            %% read the file
            load ([PathNameOut,files(a).name],'FRMpre')
            cond=cond+FRMpre;
        end
        cond = cond/size(files,1);
        conds(:,:,condsNo) = cond;
        clear files
    end

    %frame0dev
    timeFiltSigma = str2num(get(handles.timeFiltSigma,'String'));MYhandles.timeFiltSigma = timeFiltSigma;
    FrameZrange = str2num(get(handles.FrameZrange,'String'));MYhandles.FrameZrange = FrameZrange;
    % time filter
    
    if get(handles.IntrinsicButton,'value')==1% for intrisic signal
        if isnan(timeFiltSigma)
            condzn = conds;
        else
            condzn = zeros(10000,256,7);
            for a = 1:7
                for b = 1:10000
                    condzn(b,:,a) = filtx(conds(b,:,a),timeFiltSigma,'lm');
                end
            end
        end
    else
        condzn = conds;
    end
    condz = zeros(10000,256,7);
    % frame zero division
    FRMzero=mean(condzn(:,FrameZrange,:),2);
    condz=condzn./FRMzero(:,ones(1,256),:);
    MYhandles.condz = condz;
    
    save ([PathNameOut,'conds.mat'],'condz','conds')
    set(handles.condTXT,'String','Up load and conds OK');
else
    set(handles.condTXT,'String','Up load OK');
end

% --- Executes on button press in IntrinsicButton.
function IntrinsicButton_Callback(hObject, eventdata, handles)
% hObject    handle to IntrinsicButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IntrinsicButton
set(handles.VSDIbutton,'value',0)
set(handles.IntrinsicButton,'value',1)
set(handles.timeFiltSigma,'String','nan')
set(handles.FrameZrange,'String','5:10')

% --- Executes on button press in VSDIbutton.
function VSDIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to VSDIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VSDIbutton
set(handles.IntrinsicButton,'value',0)
set(handles.VSDIbutton,'value',1)
set(handles.timeFiltSigma,'String','nan')
set(handles.FrameZrange,'String','25:27')

% --- Executes on button press in append.
function append_Callback(hObject, eventdata, handles)
% hObject    handle to append (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of append


function dateButtonTXT2_Callback(hObject, eventdata, handles)
% hObject    handle to dateButtonTXT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dateButtonTXT2 as text
%        str2double(get(hObject,'String')) returns contents of dateButtonTXT2 as a double


% --- Executes during object creation, after setting all properties.
function dateButtonTXT2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dateButtonTXT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pathButtonTXT2_Callback(hObject, eventdata, handles)
% hObject    handle to pathButtonTXT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pathButtonTXT2 as text
%        str2double(get(hObject,'String')) returns contents of pathButtonTXT2 as a double


% --- Executes during object creation, after setting all properties.
function pathButtonTXT2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pathButtonTXT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in dateButton2.
function dateButton2_Callback(hObject, eventdata, handles)
% hObject    handle to dateButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile('*.mat','Select the Mat-file');
MYhandles.date = FileName(1:4);
MYhandles.PathNameInput = PathName;
MYhandles.PathNameOutput = PathName;
set(handles.dateButtonTXT2,'String',[PathName,FileName(1:4)])
set(handles.pathButtonTXT2,'String',PathName)
set(handles.condTXT,'String','choose directory in the output directory slot or generate conds in the same directory');
handles.MYhandles = MYhandles;
% Update handles structure
guidata(hObject, handles);

%% --- Executes on button press in generateCondsButton.
function generateCondsButton_Callback(hObject, eventdata, handles)
% hObject    handle to generateCondsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


MYhandles = handles.MYhandles;
date = MYhandles.date;

PathName = MYhandles.PathNameInput;
PathNameOut = MYhandles.PathNameOutput;

conds = zeros(10000,256,7);
for condsNo = 1:7
    files = dir ([PathName,date,'_',num2str(condsNo),'*.mat']);% name of the condition
    cond = zeros(10000,256,1);
    frame_total=256;
    for a = 1:size(files,1);
        disp (files(a).name)
        %% read the file
        load ([PathName,files(a).name],'FRMpre')
        cond=cond+FRMpre;
    end
    cond = cond/size(files,1);
    conds(:,:,condsNo) = cond;
    clear files 
end
 % arange the files by index
  
save ([PathNameOut,'conds.mat'],'conds')
MYhandles.conds = conds;
set(handles.dateButtonTXT3,'String',[PathNameOut,'conds.mat'])
MYhandles.PathConds = [PathNameOut,'/'];
handles.MYhandles.PathConds = MYhandles.PathConds;
handles.MYhandles.conds = MYhandles.conds;
FzeroAndTimeFilt_Callback(hObject, eventdata, handles)

set(handles.condTXT,'String','Conds and Condz has been saved');

%% --- Executes on button press in pathButton2.
function pathButton2_Callback(hObject, eventdata, handles)
% hObject    handle to pathButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PathName = uigetdir;
MYhandles.PathNameOutput = [PathName,'/'];
set(handles.pathButtonTXT2,'String',PathName)
set(handles.condTXT,'String','generate conds.mat file');
handles.MYhandles.PathNameOutput = MYhandles.PathNameOutput;
% Update handles structure
guidata(hObject, handles);



%% --- Executes on button press in condsButton.
function condsButton_Callback(hObject, eventdata, handles)
% hObject    handle to condsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[FileName,PathName] = uigetfile('conds.mat','Select the conds.mat-file');

set(handles.dateButtonTXT3,'String',[PathName,'conds.mat'])
load ([PathName,FileName],'conds')
MYhandles.conds = conds;
MYhandles.PathConds = [PathName,'/'];
set(handles.condTXT,'String','you download the conds');
handles.MYhandles = MYhandles;
% Update handles structure
guidata(hObject, handles);



function FrameZrange_Callback(hObject, eventdata, handles)
% hObject    handle to FrameZrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameZrange as text
%        str2double(get(hObject,'String')) returns contents of FrameZrange as a double


% --- Executes during object creation, after setting all properties.
function FrameZrange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameZrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeFiltSigma_Callback(hObject, eventdata, handles)
% hObject    handle to timeFiltSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeFiltSigma as text
%        str2double(get(hObject,'String')) returns contents of timeFiltSigma as a double


% --- Executes during object creation, after setting all properties.
function timeFiltSigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeFiltSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on button press in FzeroAndTimeFilt.
function FzeroAndTimeFilt_Callback(hObject, eventdata, handles)
% hObject    handle to FzeroAndTimeFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MYhandles = handles.MYhandles;
PathConds = MYhandles.PathConds;
timeFiltSigma = str2num(get(handles.timeFiltSigma,'String'));MYhandles.timeFiltSigma = timeFiltSigma;
FrameZrange = str2num(get(handles.FrameZrange,'String'));MYhandles.FrameZrange = FrameZrange;
conds = MYhandles.conds;

% time filter
if get(handles.IntrinsicButton,'value')==1% for intrisic signal
    if isnan(timeFiltSigma)
        condzn = conds;
    else
        condzn = zeros(10000,256,7);
        for a = 1:7
            for b = 1:10000
                condzn(b,:,a) = filtx(conds(b,:,a),timeFiltSigma,'lm');
            end
        end
    end
else
    condzn = conds;
end
condz = zeros(10000,256,7);
 % frame zero division
 FRMzero=mean(condzn(:,FrameZrange,:),2);
 condz=condzn./FRMzero(:,ones(1,256),:);
set(handles.condTXT,'String','Conds has been calculated');



MYhandles.condz = condz;
save ([PathConds,'conds.mat'],'condz','-append')
handles.MYhandles = MYhandles;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in filesAndConds.
function filesAndConds_Callback(hObject, eventdata, handles)
% hObject    handle to filesAndConds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filesAndConds





function SigmaMat_Callback(hObject, eventdata, handles)
% hObject    handle to SigmaMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigmaMat as text
%        str2double(get(hObject,'String')) returns contents of SigmaMat as a double


% --- Executes during object creation, after setting all properties.
function SigmaMat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigmaMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function new_files = sort_rsd_files(directory,date,cond)
cd(directory)
if cond == 'all'
    files = dir([date,'*(0).rsd']);
else
    files = dir([date,int2str(cond),'*(0).rsd']);
end

for a = 1:size(files,1);
        n = files(a).name;
        [token1, remain1] = strtok(n,'-');
        [token2, remain2] = strtok(remain1,'-');
        [token3] = strtok(remain2,'-');
        [token4] = strtok(token3,'(');
        x1= str2double(token2);
        x2 = str2double(token4);
        file_indexes(a,:) = [x1,x2]; 
end
if exist('file_indexes')
    [new_file_indexes,inds] = sortrows(file_indexes);
    for f=1:size(file_indexes,1)
        new_files(f) = files(inds(f),:);
    end
new_files = new_files';
else
    new_files = struct('name',{});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = filtx(x, s, type, s1)
%FILTX	Gaussian filter for rows of a matrix.
%	Y = FILTX(X, S, TYPE, S1) 
%	
%	X:	Matrix to be filtered
%	S:	Sigma of gaussian to use (default 1)
%	TYPE:	A string of 1-2 characters to determind type of filter.
%		'l' (default) for low-pass, 'h' for high-pass,
%		'b' for band-pass (difference of gaussians)
%		If also 'm' is given (e.g, 'lm'), the image will be padded
%		with it's mirror reflections before filtering, instead of the
%		default which effectively does wrap around.
%	S1:	Sigma for high pass in case of band-pass (default 1.5*S)
%
%	See also: FILTY, FILT2, MFILTX, MFILTY, MFILT2
%


if (nargin < 2) s = 1; end;
if (nargin < 3) type = 'l'; end;
if (nargin < 4), s1 = 1.5 * s; end;

if (~isstr(type) | length(type(:)) > 2),
	error('TYPE should be a 1- or 2-element string vector!');
end;

mind = find(type == 'm');
do_mirror = length(mind);
if do_mirror,
	type(mind) = [];
	[m,n]=size(x);
	pad = ceil(4*s);	% Padding with 4*sigma pixels.
	if (type == 'b'), pad = ceil(4*max(s,s1)); end;
	pn = min(pad, n);	% Pad is not more than image width
	x = x(:, [pn:-1:1 1:n n:-1:(n-pn+1)]);
	y = filtx(x, s, type, s1);
	y = y(:, [1:n]+pn);	% get back to original size
	return;
end;

[m,n]=size(x);
sf  = 1 / (2*pi*s);	% sigma in frequency space
sf1 = 1 / (2*pi*s1);	%

%xx = fftshift([-n/2:1:(n/2-1)]')/n;
% The above is correct only for even n. The next line is more general.
xx = [0:ceil(n/2-1), ceil(-n/2):-1]' / n;

g = exp(-xx.^2/(2*sf.^2));
if (type =='h'), g = 1-g; end;
if (type =='b'),
	g1 = exp(-xx.^2/(2*sf1.^2));
	g = g - g1;
end;
g = g(:,ones(1,m));

fx = fft(x.');

y = real(ifft(fx.*g)).';
