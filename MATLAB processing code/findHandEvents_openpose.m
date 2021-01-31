function findHandEvents_openpose(output_name)
clearvars -except output_name
global cd name plot_dist plot_index_down events_openpose time thumb index dist g check_events uiexit file
file = sprintf('%s%s',output_name,'_openpose.mat');
cd = pwd;
name = output_name;
%%
events_openpose = [];
load(fullfile(cd,file),'data_openpose','videoInfo')
time = data_openpose.time;

thumb = data_openpose.filt_data.y(:,5,1);
index = data_openpose.filt_data.y(:,9,1);
dist = index - thumb;

[pks_index_down,locs_index_down] = findpeaks(-dist);

events_openpose.index_down_frames = locs_index_down';
%%
check_events = figure; set(check_events,'WindowStyle','docked'); uiexit = false;
subplot(1,3,[1 2]); hold on; brush on
plot_dist = plot(time,dist,'-k');
plot_index_down = plot(time(events_openpose.index_down_frames),dist(events_openpose.index_down_frames),'or');
xlabel('time (s)'),ylabel('vertical distance between thumb and index (pixels)')
title(name),legend('distance','Index down','location','northeast');
g = datacursormode(check_events);

uicontrol(gcf,'style','pushbutton','String','Delete Events',...
   'units','normalized','Position',[.75 .8 0.2 0.05],'Callback',@deleteHere); % pushbutton to delete events
uicontrol(gcf,'style','pushbutton','String','Create Down',...
   'units','normalized','Position',[.75 .55 0.2 0.05],'Callback',@downCreateHere); % pushbutton to create index down events

uicontrol(gcf,'style','togglebutton','String','Brush',...
   'units','normalized','Position',[.64 .55 0.08 0.05],'Callback',@tgglBrush); % pushbutton to toggle brush on/off
uicontrol(gcf,'style','togglebutton','String','Cursor',...
   'units','normalized','Position',[.64 .5 0.08 0.05],'Callback',@tgglCursor); % pushbutton to toggle cursor on/off
uicontrol(gcf,'style','togglebutton','String','Zoom',...
   'units','normalized','Position',[.64 .45 0.08 0.05],'Callback',@tgglZoom); % pushbutton to toggle zoom on/off

uicontrol(gcf,'style','pushbutton','String','Save',...
    'units','normalized','units','normalized','Position',[.75 .2 .2 .05],'Callback',@saveHere); % pushbutton to save events
uicontrol(gcf,'style','pushbutton','String','Close',...
    'units','normalized','units','normalized','Position',[.75 .1 .2 .05],'Callback',@closeHere); % pushbutton to close fig and go to next subject in "for" loop   
uicontrol(gcf,'style','pushbutton','String','Exit',...
    'units','normalized','units','normalized','Position',[.1 .02 .1 .05],'Callback',@exitHere); % pushbutton to exit events function

uiwait(check_events)
end

%% "Delete" pushbutton
function deleteHere(source,event)
global plot_dist plot_index_down events_openpose time dist

if ~isempty(get(plot_index_down,'BrushData')) % check that user has brushed data
indexdownBrush = logical(get(plot_index_down,'BrushData')); 
if true(logical(sum(indexdownBrush))) % check if user has brushed index events
events_openpose.index_down_frames(indexdownBrush) = []; % delete brushed index events
end

delete(plot_dist);delete(plot_index_down);% delete plot of events
plot_dist = plot(time,dist,'-k');
plot_index_down = plot(time(events_openpose.index_down_frames),dist(events_openpose.index_down_frames),'or');
legend('distance','Index down','location','northeast');
end
end
%% "Create Down" pushbutton
function downCreateHere(~,event)
global plot_dist plot_index_down events_openpose time dist

if ~isempty(getCursorInfo(g)) % check that user has used data cursor
s = getCursorInfo(g);
downNew = nan(length(s),1);
for u = 1:length(s) % 'for loop' for every data cursor   
downNew(u) = s(u).DataIndex;  
end
downNew(isnan(downNew)) = [];

for v = 1:length(downNew) % remove event from the existing vector with events so to ensure that events are not counted more than once
events_openpose.index_down_frames(events_openpose.index_down_frames == downNew(v)) = [];
end

events_openpose.index_down_frames = sort([events_openpose.index_down_frames downNew]); % add new events to vector with events

delete(plot_dist);delete(plot_index_down);% delete plot of events
plot_dist = plot(time,dist,'-k');
plot_index_down = plot(time(events_openpose.index_down_frames),dist(events_openpose.index_down_frames),'or');
legend('distance','Index down','location','northeast');
end
end
%% "Brush" toggle
function tgglBrush(source,event)
brush on
end
%% "Cursor" toggle
function tgglCursor(source,event)
datacursormode on
end
%% "Zoom" toggle
function tgglZoom(source,event)
zoom on
end
%% "Save" pushbutton
function saveHere(source,event)
global cd file events_openpose
save(fullfile(cd,file),'events_openpose','-append')    
end
%% "Close" pushbutton
function closeHere(source,event)
global check_events
close(check_events)
end
%% "Exit" pushbutton
function exitHere(source,event)
global check_events uiexit
uiresume(check_events)
uiexit = true;
end