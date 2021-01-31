function findProSupHandEvents_openpose(output_name)
clearvars -except output_name
global cd name plot_thumb plot_thumb_up plot_thumb_down events_openpose time thumb g check_events uiexit file
file = sprintf('%s%s',output_name,'_openpose.mat');
cd = pwd;
name = output_name;
%%
events_openpose = [];
load(fullfile(cd,file),'data_openpose')
time = data_openpose.time;

thumb = data_openpose.filt_data.y(:,5,1);

[pks_thumb_up,locs_thumb_up] = findpeaks(thumb); [pks_thumb_down,locs_thumb_down] = findpeaks(-thumb);

events_openpose.thumb_up_frames = locs_thumb_up'; events_openpose.thumb_down_frames = locs_thumb_down';
%%
check_events = figure; set(check_events,'WindowStyle','docked'); uiexit = false;
subplot(1,3,[1 2]); hold on; brush on
plot_thumb = plot(time,thumb,'-k');
plot_thumb_up = plot(time(events_openpose.thumb_up_frames),thumb(events_openpose.thumb_up_frames),'og');
plot_thumb_down = plot(time(events_openpose.thumb_down_frames),thumb(events_openpose.thumb_down_frames),'or');
xlabel('time (s)'),ylabel('vertical position of thumb (pixels)')
title(name),legend('thumb position','Thumb up','Thumb down','location','northeast');
g = datacursormode(check_events);

uicontrol(gcf,'style','pushbutton','String','Delete Events',...
   'units','normalized','Position',[.75 .8 0.2 0.05],'Callback',@deleteHere); % pushbutton to delete events
uicontrol(gcf,'style','pushbutton','String','Create Up',...
   'units','normalized','Position',[.75 .65 0.2 0.05],'Callback',@upCreateHere); % pushbutton to create up events
uicontrol(gcf,'style','pushbutton','String','Create Down',...
   'units','normalized','Position',[.75 .55 0.2 0.05],'Callback',@downCreateHere); % pushbutton to create up events

uicontrol(gcf,'style','togglebutton','String','Brush',...
   'units','normalized','Position',[.64 .55 0.08 0.05],'Callback',@tgglBrush); % pushbutton to create down events
uicontrol(gcf,'style','togglebutton','String','Cursor',...
   'units','normalized','Position',[.64 .5 0.08 0.05],'Callback',@tgglCursor); % pushbutton to create down events
uicontrol(gcf,'style','togglebutton','String','Zoom',...
   'units','normalized','Position',[.64 .45 0.08 0.05],'Callback',@tgglZoom); % pushbutton to create down events

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
global plot_thumb plot_thumb_up plot_thumb_down events_openpose time thumb

if ~isempty(get(plot_thumb_up,'BrushData')) || ~isempty(get(plot_thumb_down,'BrushData')) % check that user has brushed data
thumbupBrush = logical(get(plot_thumb_up,'BrushData')); 
if true(logical(sum(thumbupBrush))) % check if user has brushed up events
events_openpose.thumb_up_frames(thumbupBrush) = []; % delete brushed up events
end
thumbdownBrush = logical(get(plot_thumb_down,'BrushData')); 
if true(logical(sum(thumbdownBrush))) % check if user has brushed down events
events_openpose.thumb_down_frames(thumbdownBrush) = []; % delete brushed down events
end

delete(plot_thumb);delete(plot_thumb_up);delete(plot_thumb_down);% delete plot of events
plot_thumb = plot(time,thumb,'-k');
plot_thumb_up = plot(time(events_openpose.thumb_up_frames),thumb(events_openpose.thumb_up_frames),'og');
plot_thumb_down = plot(time(events_openpose.thumb_down_frames),thumb(events_openpose.thumb_down_frames),'or');
legend('thumb position','Thumb up','Thumb down','location','northeast');
end
end
%% "Create Up" pushbutton
function upCreateHere(~,event)
global plot_thumb plot_thumb_up plot_thumb_down events_openpose time thumb

if ~isempty(getCursorInfo(g)) % check that user has used data cursor
s = getCursorInfo(g);
upNew = nan(length(s),1);
for u = 1:length(s) % 'for loop' for every data cursor   
upNew(u) = s(u).DataIndex;  
end
upNew(isnan(upNew)) = [];

for v = 1:length(upNew) % remove event from the existing vector with events so to ensure that events are not counted more than once
events_openpose.thumb_up_frames(events_openpose.thumb_up_frames == upNew(v)) = [];
end

events_openpose.thumb_up_frames = sort([events_openpose.thumb_up_frames upNew]); % add new events to vector with events

delete(plot_thumb);delete(plot_thumb_up);delete(plot_thumb_down);% delete plot of events
plot_thumb = plot(time,thumb,'-k');
plot_thumb_up = plot(time(events_openpose.thumb_up_frames),thumb(events_openpose.thumb_up_frames),'og');
plot_thumb_down = plot(time(events_openpose.thumb_down_frames),thumb(events_openpose.thumb_down_frames),'or');
legend('thumb position','Thumb up','Thumb down','location','northeast');
end
end
%% "Create Down" pushbutton
function downCreateHere(~,event)
global plot_thumb plot_thumb_up plot_thumb_down events_openpose time thumb

if ~isempty(getCursorInfo(g)) % check that user has used data cursor
s = getCursorInfo(g);
downNew = nan(length(s),1);
for u = 1:length(s) % 'for loop' for every data cursor   
downNew(u) = s(u).DataIndex;  
end
downNew(isnan(downNew)) = [];

for v = 1:length(downNew) % remove event from the existing vector with events so to ensure that events are not counted more than once
events_openpose.thumb_down_frames(events_openpose.thumb_down_frames == downNew(v)) = [];
end

events_openpose.thumb_down_frames = sort([events_openpose.thumb_down_frames downNew]); % add new events to vector with events

delete(plot_thumb);delete(plot_thumb_up);delete(plot_thumb_down);% delete plot of events
plot_thumb = plot(time,thumb,'-k');
plot_thumb_up = plot(time(events_openpose.thumb_up_frames),thumb(events_openpose.thumb_up_frames),'og');
plot_thumb_down = plot(time(events_openpose.thumb_down_frames),thumb(events_openpose.thumb_down_frames),'or');
legend('thumb position','Thumb up','Thumb down','location','northeast');
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