function varargout = CH_Analyze2(varargin)
% CH_ANALYZE2 MATLAB code for CH_Analyze2.fig
%      CH_ANALYZE2, by itself, creates a new CH_ANALYZE2 or raises the existing
%      singleton*.
%
%      H = CH_ANALYZE2 returns the handle to a new CH_ANALYZE2 or the handle to
%      the existing singleton*.
%
%      CH_ANALYZE2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CH_ANALYZE2.M with the given input arguments.
%
%      CH_ANALYZE2('Property','Value',...) creates a new CH_ANALYZE2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CH_Analyze2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CH_Analyze2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CH_Analyze2

% Last Modified by GUIDE v2.5 22-Sep-2015 15:17:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CH_Analyze2_OpeningFcn, ...
                   'gui_OutputFcn',  @CH_Analyze2_OutputFcn, ...
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


% --- Executes just before CH_Analyze2 is made visible.
function CH_Analyze2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CH_Analyze2 (see VARARGIN)

% Choose default command line output for CH_Analyze2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CH_Analyze2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CH_Analyze2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selectFdata.
function selectFdata_Callback(hObject, eventdata, handles)
% hObject    handle to selectFdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   %load F file
[Ffile,Ffilepath]=uigetfile('*.mat','pick the F file');
fullFfile=[Ffilepath Ffile];
set(hObject,'String',fullFfile);

% --- Executes on button press in newdatasource.
function newdatasource_Callback(hObject, eventdata, handles)
% hObject    handle to newdatasource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of newdatasource

% --- Executes on button press in selectimagingtiming.
function selectimagingtiming_Callback(hObject, eventdata, handles)
% hObject    handle to selectimagingtiming (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[xlsfile,xlsfilepath]=uigetfile('*.xls','pick the matching Excel file');
fullxlsfile=[xlsfilepath xlsfile];
set(hObject,'String',fullxlsfile);


function badframesstr_Callback(hObject, eventdata, handles)
% hObject    handle to badframesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of badframesstr as text
%        str2double(get(hObject,'String')) returns contents of badframesstr as a double


% --- Executes during object creation, after setting all properties.
function badframesstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to badframesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baselineframes_Callback(hObject, eventdata, handles)
% hObject    handle to baselineframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baselineframes as text
%        str2double(get(hObject,'String')) returns contents of baselineframes as a double


% --- Executes during object creation, after setting all properties.
function baselineframes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baselineframes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function deletedframesstr_Callback(hObject, eventdata, handles)
% hObject    handle to deletedframesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deletedframesstr as text
%        str2double(get(hObject,'String')) returns contents of deletedframesstr as a double


% --- Executes during object creation, after setting all properties.
function deletedframesstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deletedframesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function corrbinsstr_Callback(hObject, eventdata, handles)
% hObject    handle to corrbinsstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of corrbinsstr as text
%        str2double(get(hObject,'String')) returns contents of corrbinsstr as a double


% --- Executes during object creation, after setting all properties.
function corrbinsstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to corrbinsstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function selectROIsstr_Callback(hObject, eventdata, handles)
% hObject    handle to selectROIsstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selectROIsstr as text
%        str2double(get(hObject,'String')) returns contents of selectROIsstr as a double


% --- Executes during object creation, after setting all properties.
function selectROIsstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectROIsstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in experimenttype.
function experimenttype_Callback(hObject, eventdata, handles)
% hObject    handle to experimenttype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns experimenttype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from experimenttype


% --- Executes during object creation, after setting all properties.
function experimenttype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimenttype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in goscience.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to goscience (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in excelbox.
function excelbox_Callback(hObject, eventdata, handles)
% hObject    handle to excelbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of excelbox


% --- Executes on button press in activeROIZFbox.
function activeROIZFbox_Callback(hObject, eventdata, handles)
% hObject    handle to activeROIZFbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of activeROIZFbox


% --- Executes on button press in activeROIZscorebox.
function activeROIZscorebox_Callback(hObject, eventdata, handles)
% hObject    handle to activeROIZscorebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of activeROIZscorebox



function freqofstimHzstr_Callback(hObject, eventdata, handles)
% hObject    handle to freqofstimHzstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqofstimHzstr as text
%        str2double(get(hObject,'String')) returns contents of freqofstimHzstr as a double


% --- Executes during object creation, after setting all properties.
function freqofstimHzstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqofstimHzstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lengthofstimsecstr_Callback(hObject, eventdata, handles)
% hObject    handle to lengthofstimsecstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lengthofstimsecstr as text
%        str2double(get(hObject,'String')) returns contents of lengthofstimsecstr as a double


% --- Executes during object creation, after setting all properties.
function lengthofstimsecstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lengthofstimsecstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numberofstimsstr_Callback(hObject, eventdata, handles)
% hObject    handle to numberofstimsstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberofstimsstr as text
%        str2double(get(hObject,'String')) returns contents of numberofstimsstr as a double


% --- Executes during object creation, after setting all properties.
function numberofstimsstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberofstimsstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pulsesperstimstr_Callback(hObject, eventdata, handles)
% hObject    handle to pulsesperstimstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pulsesperstimstr as text
%        str2double(get(hObject,'String')) returns contents of pulsesperstimstr as a double


% --- Executes during object creation, after setting all properties.
function pulsesperstimstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pulsesperstimstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stimdurationstr_Callback(hObject, eventdata, handles)
% hObject    handle to stimdurationstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stimdurationstr as text
%        str2double(get(hObject,'String')) returns contents of stimdurationstr as a double


% --- Executes during object creation, after setting all properties.
function stimdurationstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimdurationstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timebetweenstimsstr_Callback(hObject, eventdata, handles)
% hObject    handle to timebetweenstimsstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timebetweenstimsstr as text
%        str2double(get(hObject,'String')) returns contents of timebetweenstimsstr as a double


% --- Executes during object creation, after setting all properties.
function timebetweenstimsstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timebetweenstimsstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in rawfiguresplot.
function rawfiguresplot_Callback(hObject, eventdata, handles)
% hObject    handle to rawfiguresplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rawfiguresplot


% --- Executes on button press in stimoverlayplots.
function stimoverlayplots_Callback(hObject, eventdata, handles)
% hObject    handle to stimoverlayplots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stimoverlayplots


% --- Executes on button press in stimrespsignificance.
function stimrespsignificance_Callback(hObject, eventdata, handles)
% hObject    handle to stimrespsignificance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stimrespsignificance

function lagframesstr_Callback(hObject, eventdata, handles)
% hObject    handle to lagframesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lagframesstr as text
%        str2double(get(hObject,'String')) returns contents of lagframesstr as a double


% --- Executes during object creation, after setting all properties.
function lagframesstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lagframesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numscramblesstr_Callback(hObject, eventdata, handles)
% hObject    handle to numscramblesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numscramblesstr as text
%        str2double(get(hObject,'String')) returns contents of numscramblesstr as a double


% --- Executes during object creation, after setting all properties.
function numscramblesstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numscramblesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function percentilestr_Callback(hObject, eventdata, handles)
% hObject    handle to percentilestr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of percentilestr as text
%        str2double(get(hObject,'String')) returns contents of percentilestr as a double


% --- Executes during object creation, after setting all properties.
function percentilestr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to percentilestr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in compareresponses.
function compareresponses_Callback(hObject, eventdata, handles)
% hObject    handle to compareresponses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of compareresponses

function selectfirstsetstr_Callback(hObject, eventdata, handles)
% hObject    handle to selectfirstsetstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selectfirstsetstr as text
%        str2double(get(hObject,'String')) returns contents of selectfirstsetstr as a double


% --- Executes during object creation, after setting all properties.
function selectfirstsetstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectfirstsetstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function selectlastsetstr_Callback(hObject, eventdata, handles)
% hObject    handle to selectlastsetstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selectlastsetstr as text
%        str2double(get(hObject,'String')) returns contents of selectlastsetstr as a double


% --- Executes during object creation, after setting all properties.
function selectlastsetstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectlastsetstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in first5last5plots.
function first5last5plots_Callback(hObject, eventdata, handles)
% hObject    handle to first5last5plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of first5last5plots


%%% --- Executes on button press in goscience.
function goscience_Callback(hObject, eventdata, handles)
% hObject    handle to goscience (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%----------Simple parse---------------------
experimenttype=(get(handles.experimenttype,'Value'));
baselineframes=str2double(get(handles.baselineframes,'String'));
fullFfile=(get(handles.selectFdata,'String')); %file name
fullxlsfile=(get(handles.selectimagingtiming,'String')); %time data
spontisoframes = str2num(get(handles.framechopstr,'String'));
deleted=str2double(get(handles.deletedframesstr,'String'));
corrbins=str2double(get(handles.corrbinsstr,'String'));


%----------End Simple Parse------------------

%----------Stim architecture------------------------------------------------

%converting GUI inputs (strings) into numbers
numberofstims = str2double(get(handles.numberofstimsstr,'String'));
pulsesperstim = str2double(get(handles.pulsesperstimstr,'String'));
stimduration = str2double(get(handles.stimdurationstr,'String'));
timebetweenstims = str2double(get(handles.timebetweenstimsstr,'String'));
%----------End stim architecture----------------------------------------

%----------Stim response significance parameters-----------------------------
lagframes = str2double(get(handles.lagframesstr,'String'));
numscrambles = str2double(get(handles.numscramblesstr,'String'));
percentile = str2double(get(handles.percentilestr,'String'));
firstsetstims = str2num(get(handles.selectfirstsetstr,'String'));
lastsetstims = str2num(get(handles.selectlastsetstr,'String'));
%----------End stim response sig parameters-------------------------------


%--------------------Parse Bad Frame String into Matrix--------------
badframesstr=(get(handles.badframesstr,'String'));
stringpos=2; % initial position of string
spaces=0;
spaces(1)=0; %sets first space at 0

for i=2:length(badframesstr)
    if badframesstr(i)==' ' %Detects spaces and uses them as bounds
        spaces(stringpos)=i;
        stringpos=stringpos+1;
    end
end
spaces((length(spaces)+1))=length(badframesstr)+1; %sets last space at end
for i=1:(length(spaces)-1)
    badframes(i)=str2double(badframesstr(spaces(i)+1:spaces(i+1)-1));
end
%---------------------End Bad Frame Parse------------------------------


% %--------------------Parse ROI Select String into Matrix--------------
roiselect=str2num(get(handles.selectROIsstr,'String'));
% %---------------------End ROI Select Parse------------------------------

%-------------Output Selection----------------------------------------
% 1=Excel Data for Z_F
outputs(1)=get(handles.excelbox,'Value');

% 2=Active ROI DeltaF plots (similar to Raw plots but only active ROIs)
outputs(2)=get(handles.activeROIZFbox,'Value');

% Removed this on 11/10/14 - haven't been using "raw figures plot" for a
% while
% 4=Raw figures plot
% outputs(4)=get(handles.rawfiguresplot,'Value');

% 3=Stim overlay plots
outputs(3)=get(handles.stimoverlayplots,'Value');

% 4=Stim response significance (Excel)
outputs(4)=get(handles.stimrespsignificance,'Value');

% 5 = Whether data comes from "new data source" (DC_Calcium) or old data
outputs(5)=get(handles.newdatasource,'Value');

% 6 = Isolate responses
outputs(6)=get(handles.compareresponses,'Value');

% 7 = First 5 / Last 5 stim overlay plots
outputs(7)=get(handles.first5last5plots,'Value');
%-------------End Output Selection------------------------------------

%--------------------Run Analysis-------------------------------------
CH_Analyze2_Control(badframes,outputs,deleted,corrbins,roiselect, ...
        fullFfile,experimenttype,baselineframes,fullxlsfile,numberofstims, ...
        pulsesperstim,stimduration,timebetweenstims,lagframes,numscrambles,...
        percentile,firstsetstims,lastsetstims,spontisoframes);
%------------------End Run Analysis-----------------------------------



function framechopstr_Callback(hObject, eventdata, handles)
% hObject    handle to framechopstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framechopstr as text
%        str2double(get(hObject,'String')) returns contents of framechopstr as a double


% --- Executes during object creation, after setting all properties.
function framechopstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framechopstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
