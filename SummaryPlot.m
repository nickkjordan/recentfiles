function varargout = SummaryPlot(varargin)
% SUMMARYPLOT MATLAB code for SummaryPlot.fig
%      SUMMARYPLOT, by itself, creates a new SUMMARYPLOT or raises the existing
%      singleton*.
%
%      H = SUMMARYPLOT returns the handle to a new SUMMARYPLOT or the handle to
%      the existing singleton*.
%
%      SUMMARYPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUMMARYPLOT.M with the given input arguments.
%
%      SUMMARYPLOT('Property','Value',...) creates a new SUMMARYPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SummaryPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SummaryPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SummaryPlot

% Last Modified by GUIDE v2.5 08-Jun-2012 15:40:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SummaryPlot_OpeningFcn, ...
    'gui_OutputFcn',  @SummaryPlot_OutputFcn, ...
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

% --- Executes just before SummaryPlot is made visible.
function SummaryPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SummaryPlot (see VARARGIN)

% Choose default command line output for SummaryPlot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using SummaryPlot.
if strcmp(get(hObject,'Visible'),'off')
    %    axes(findobj('Tag','defaultaxes'));
    plot(rand(5));
    set(gca,'XTick',[],'YTick',[],'XColor','white','YColor','white','parent',handles.mainfig);%'YDir','reverse'
    box off;
    cla;
end
% set(gcf,'Color','white')

% get the arguments passed to the GUI
global filename tasktype;

if length(varargin)>2
    tasktype=cell2mat(varargin{3});
else
    tasktype=[];
end
if length(varargin)>1
    filename=varargin{2};
else
    filename=[];
end

set(findobj('tag','dispfilename'),'string',filename);
set(findobj('tag','disptaskname'),'string',tasktype);

alignedata=struct(varargin{1});
alignment=alignedata(1,1).savealignname(max(strfind(alignedata(1,1).savealignname,'_'))+1:end);
set(findobj('tag','dispalignment'),'string',alignment);

%figdimension=get(findobj('tag','mainfig'),'Position');
figdimension=get(gca,'Position');
rasterdim=[figdimension(1)*1.1 (figdimension(4)*0.66)+figdimension(2)*1.1 figdimension(3)*0.9 figdimension(4)*0.3];

plotstart=1000;
plotstop=400;
fsigma=20;
cc=lines(length(alignedata));

numsubplot=length(alignedata)*3;
if numsubplot==3
    numsubplot=6;
end
%setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
%Plot rasters
%rastersh = axes('Position', rasterdim, 'Layer','top','XTick',[],'YTick',[],'XColor','white','YColor','white');
numrast=length(alignedata)
for i=1:numrast
    rasters=alignedata(i).rasters;
    alignidx= alignedata(i).alignidx;
    start = alignidx - plotstart;
    stop = alignidx + plotstop;
    
    trials = size(rasters,1);
    isnantrial=zeros(1,size(rasters,1));
    
    hrastplot(i)=subplot(numsubplot,1,i,'Layer','top', ...
        'XTick',[],'YTick',[],'XColor','white','YColor','white', 'Parent', handles.mainfig);
    rastpos=get(gca,'position');
    rastpos(2)=rastpos(2)+rastpos(4)*0.5; %reducing spacing between rasters
    set(gca,'position',rastpos);
    
    %axis([0 stop-start+1 0 size(rasters,1)]);
    hold on
    for j=1:size(rasters,1) %plotting rasters trial by trial
        spiketimes=find(rasters(j,start:stop)); %converting from a matrix representation to a time collection, within selected time range
        if isnan(sum(rasters(j,start:stop)))
            isnantrial(j)=1;
        end
        plot([spiketimes;spiketimes],[ones(size(spiketimes))*j;ones(size(spiketimes))*j-1],'color',cc(i,:),'LineStyle','-');
    end
    axis(gca, 'off', 'tight');
    
    %Plot sdf
    subplot(numsubplot,1,(numsubplot/3)+1:(numsubplot/3)+(numsubplot/3),'Layer','top','Parent', handles.mainfig);
    %sdfh = axes('Position', [.15 .65 .2 .2], 'Layer','top');
    title('Spike Density Function','FontName','calibri','FontSize',11);
    hold on;
    sumall=sum(rasters(~isnantrial,start:stop));
    sdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials
    
    plot(sdf,'Color',cc(i,:),'LineWidth',1.8);
    % axis([0 stop-start 0 200])
    axis(gca,'tight');
    box off;
    set(gca,'Color','white','TickDir','out','FontName','calibri','FontSize',8); %'YAxisLocation','rigth'
    hxlabel=xlabel(gca,'Time (ms)','FontName','calibri','FontSize',8);
    set(hxlabel,'Position',get(hxlabel,'Position') - [350 -0.2 0]); %doesn't stay there when export !
    hylabel=ylabel(gca,'Firing rate (spikes/s)','FontName','calibri','FontSize',8);
    
    patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
        [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
        [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
    
    %Plot eye velocities
    heyevelplot=subplot(numsubplot,1,(numsubplot*2/3)+1:numsubplot,'Layer','top','Parent', handles.mainfig);
    title('Eye velocity','FontName','calibri','FontSize',11);
    % h = xlabel('');     pos = get(h,'Position'); delete(h)
    % h = title('title'); set(h,'Position',pos);
    
    hold on;
    
    eyevel=alignedata(i).eyevel;
    eyevel=median(eyevel(:,start:stop));
    heyevelline(i)=plot(eyevel,'Color',cc(i,:),'LineWidth',1);
    %axis(gca,'tight');
    eyevelymax=max(eyevel);
    if eyevelymax>0.8
        eyevelymax=eyevelymax*1.1;
    else
        eyevelymax=0.8
    end
    axis([0 stop-start 0 eyevelymax]);
    set(gca,'Color','none','TickDir','out','FontSize',8,'FontName','calibri','box','off');
    ylabel(gca,'Eye velocity (deg/ms)','FontName','calibri','FontSize',8);
    patch([repmat((alignidx-start)-2,1,2) repmat((alignidx-start)+2,1,2)], ...
        [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
        [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
    
    % get directions for the legend
    curdir{i}=alignedata(i).dir;
    
end
%moving up all rasters now
if numrast==1
    allrastpos=(get(hrastplot,'position'));
else
    allrastpos=cell2mat(get(hrastplot,'position'));
end

disttotop=allrastpos(1,2)+allrastpos(1,4);
if disttotop<0.99 %if not already close to top of container
    allrastpos(:,2)=allrastpos(:,2)+(1-disttotop)/1.5;
end
if numrast>1
    allrastpos=mat2cell(allrastpos,ones(1,size(allrastpos,1))); %reconversion to cell .. un brin penible
    set(hrastplot,{'position'},allrastpos);
else
    set(hrastplot,'position',allrastpos);
end

%moving down the eye velocity plot
eyevelplotpos=get(heyevelplot,'position');
eyevelplotpos(1,2)=eyevelplotpos(1,2)-(eyevelplotpos(1,2))/1.5;
set(heyevelplot,'position',eyevelplotpos);

% plot a legend in this last graph
hlegdir = legend(heyevelline,curdir,'Location','NorthWest');
set(hlegdir,'Interpreter','none', 'Box', 'off','LineWidth',1.5,'FontName','calibri','FontSize',9);




%Plot eye velocities
%eyevelploth =

% UIWAIT makes SummaryPlot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SummaryPlot_OutputFcn(hObject, eventdata, handles)
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
axes(handles.figaxesh);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        plot(rand(5));
    case 2
        plot(sin(1:0.01:25.99));
    case 3
        bar(1:.5:10);
    case 4
        plot(membrane);
    case 5
        surf(peaks);
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});



function dispfilename_Callback(hObject, eventdata, handles)
% hObject    handle to dispfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dispfilename as text
%        str2double(get(hObject,'String')) returns contents of dispfilename as a double


% --- Executes during object creation, after setting all properties.
function dispfilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function disptaskname_Callback(hObject, eventdata, handles)
% hObject    handle to disptaskname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of disptaskname as text
%        str2double(get(hObject,'String')) returns contents of disptaskname as a double


% --- Executes during object creation, after setting all properties.
function disptaskname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to disptaskname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
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


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename tasktype directory;
alignment=get(findobj('tag','dispalignment'),'string');
subplots=findobj(handles.mainfig,'Type','axes');
%findobj(handles.mainfig,'Type','axes','Tag','legend')
figuresize=getpixelposition(handles.mainfig);
figuresize(1:2)=[80 167];
exportfigname=[directory,'figures\',filename,'_',tasktype,'_',alignment];
exportfig=figure('color','white','position',figuresize);
for k=1:length(subplots)
    copyobj(subplots(k),exportfig);
end
saveas(exportfig,exportfigname,'png');
delete(exportfig);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes during object creation, after setting all properties.
function figaxesh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figaxesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate figaxesh


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%When replotting,use uistack to reorder visual stacking order of objects if
%necessary


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function mainfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

mainfig = uipanel('BorderType','none',...
    'BackgroundColor','white',...
    'Units','points',...
    'Position',[0.032 0.02 0.595 0.925],...
    'Parent',gcf);



function dispalignment_Callback(hObject, eventdata, handles)
% hObject    handle to dispalignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dispalignment as text
%        str2double(get(hObject,'String')) returns contents of dispalignment as a double


% --- Executes during object creation, after setting all properties.
function dispalignment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispalignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
