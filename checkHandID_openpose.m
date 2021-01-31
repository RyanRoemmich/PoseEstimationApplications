function checkHandID_openpose(output_name)
clearvars -except output_name
file = sprintf('%s%s',output_name,'_openpose.mat');
cd = pwd;
load(fullfile(cd,file),'data_openpose','videoInfo')
which_hand = questdlg('Which hand do you want to analyze?','Which hand?','Right','Left','Right');
checkHandID(data_openpose,videoInfo,output_name,which_hand)
end
%%
function checkHandID(d,v,n,h)
global frame corrected_data raw_data p name frames frameInfo check_fig vid data_openpose cursor_obj h1 h2 h3
check_fig = []; corrected_data = []; frame = []; frameInfo = []; frames = []; name = []; p = []; raw_data = []; vid = []; h1 = []; h2 = []; h3 = [];
frame = 1;
name = n;
frames = 1:length(d.time);
vid = v;
data_openpose = d;

if strcmp(h,'Right') == 1
    hand_data = d.right_hand_data;
else
    hand_data = d.left_hand_data;
end

raw_data = hand_data;
corrected_data = hand_data;

frameInfo.frames_switch = false(1,length(frames)); frameInfo.frames_leftClear = false(1,length(frames)); frameInfo.frames_rightClear = false(1,length(frames));

check_fig = figure; set(check_fig,'WindowStyle','docked')

subplot(3,3,[1 2 4 5 7 8])
p = plot(squeeze(corrected_data.y(:,[5 9],1)),'.-'); zoom on; grid on
legend('thumb','index','location','northwest'); xlabel('frames'),ylabel('vertical position (pixel)');title(name)
set(gca,'xtick',frames)
  
uicontrol(check_fig,'style','pushbutton','String','Show Image',...
   'units','normalized','Position',[0.7 0.3 0.2 0.05],'Callback',@showImage); % pushbutton to show image

uicontrol(check_fig,'style','pushbutton','String','Clear all before',...
   'units','normalized','Position',[0.7 0.25 0.2 0.05],'Callback',@clearAllBefore); % pushbutton to clear all before

uicontrol(check_fig,'style','pushbutton','String','Clear all after',...
   'units','normalized','Position',[0.7 0.2 0.2 0.05],'Callback',@clearAllAfter); % pushbutton to clear all after

uicontrol(check_fig,'style','pushbutton','String','Clear index ID',...
   'units','normalized','Position',[0.7 0.15 0.1 0.05],'Callback',@clearIndex); % pushbutton to clear index ID

uicontrol(check_fig,'style','pushbutton','String','Restore index ID',...
   'units','normalized','Position',[0.7 0.1 0.1 0.05],'Callback',@restoreIndex); % pushbutton to restore index ID
   
uicontrol(check_fig,'style','pushbutton','String','Clear thumb ID',...
   'units','normalized','Position',[0.85 0.15 0.1 0.05],'Callback',@clearThumb); % pushbutton to clear thumb ID

uicontrol(check_fig,'style','pushbutton','String','Restore thumb ID',...
   'units','normalized','Position',[0.85 0.1 0.1 0.05],'Callback',@restoreThumb); % pushbutton to restore thumb ID

uicontrol(check_fig,'style','pushbutton','String','Restore entire data-series',...
   'units','normalized','Position',[0.7 0.025 0.2 0.05],'Callback',@restoreData); % pushbutton to restore entire data-series

uicontrol(check_fig,'style','pushbutton','String','Save',...
   'units','normalized','Position',[0.1 0.025 0.2 0.05],'Callback',@saveData); % pushbutton to save file

uicontrol(check_fig,'style','pushbutton','String','Zoom',...
   'units','normalized','Position',[0.65 0.55 0.1 0.05],'Callback',@zoomON); % pushbutton to zoom ON

uicontrol(check_fig,'style','pushbutton','String','Data tip',...
   'units','normalized','Position',[0.65 0.45 0.1 0.05],'Callback',@dataCursorON); % pushbutton to data cursor ON

datacursormode on;
cursor_obj = datacursormode(check_fig);

uiwait(check_fig)
end
%% "Show Image" pushbutton
function showImage(source,event)
global frame vid cursor_obj h1 h2 h3
delete([h1 h2 h3]);
subplot(3,3,3),hold on
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
h1=imshow(read(vid.vid_openpose,frame));
h3 = title(['Frame ' num2str(frame) ],'fontsize',7);
else
h2=text(0,.5,'You must select a frame to show image');
set(gca,'Visible','off')
end
end
%% "Clear all before" pushbutton
function clearAllBefore(source,event)
global frame corrected_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data.x(1:frame,[5 9],:) = nan;
corrected_data.y(1:frame,[5 9],:) = nan;
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p = plot(squeeze(corrected_data.y(:,[5 9],1)),'.-'); zoom on; grid on; datacursormode on;
legend('thumb','index','location','northwest'); xlabel('frames'),ylabel('vertical position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_indexClear(frame) = true;
else
errordlg('You must select a frame!')
end
end
%% "Clear all after" pushbutton
function clearAllAfter(source,event)
global frame corrected_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data.x(frame:end,[5 9],:) = nan;
corrected_data.y(frame:end,[5 9],:) = nan;
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p = plot(squeeze(corrected_data.y(:,[5 9],1)),'.-'); zoom on; grid on; datacursormode on;
legend('thumb','index','location','northwest'); xlabel('frames'),ylabel('vertical position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_indexClear(frame) = true;
else
errordlg('You must select a frame!')
end
end
%% "Clear index" pushbutton
function clearIndex(source,event)
global frame corrected_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data.x(frame,9,:) = nan;
corrected_data.y(frame,9,:) = nan;
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p = plot(squeeze(corrected_data.y(:,[5 9],1)),'.-'); zoom on; grid on; datacursormode on;
legend('thumb','index','location','northwest'); xlabel('frames'),ylabel('vertical position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_indexClear(frame) = true;
else
errordlg('You must select a frame!')
end
end
%% "Restore index" pushbutton
function restoreIndex(source,event)
global frame corrected_data raw_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data.x(frame,9,:) = raw_data(frame,9,:);
corrected_data.y(frame,9,:) = raw_data(frame,9,:);
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p = plot(squeeze(corrected_data.y(:,[5 9],1)),'.-'); zoom on; grid on; datacursormode on;

legend('thumb','index','location','northwest'); xlabel('frames'),ylabel('vertical position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_indexClear(frame) = false;
else
errordlg('You must select a frame!')
end
end
%% "Clear thumb" pushbutton
function clearThumb(source,event)
global frame corrected_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data.x(frame,5,:) = nan;
corrected_data.y(frame,5,:) = nan;
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p = plot(squeeze(corrected_data.y(:,[5 9],1)),'.-'); zoom on; grid on; datacursormode on;
legend('thumb','index','location','northwest'); xlabel('frames'),ylabel('vertical position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_thumbClear(frame) = true;
else
errordlg('You must select a frame!')
end
end
%% "Restore thumb" pushbutton
function restoreThumb(source,event)
global frame corrected_data raw_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data.x(frame,5,:) = raw_data(frame,5,:);
corrected_data.y(frame,5,:) = raw_data(frame,5,:);
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p = plot(squeeze(corrected_data.y(:,[5 9],1)),'.-'); zoom on; grid on; datacursormode on;
legend('thumb','index','location','northwest'); xlabel('frames'),ylabel('vertical position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_thumbClear(frame) = false;
else
errordlg('You must select a frame!')
end
end
%% "Restore entire data-series" pushbutton
function restoreData(source,event)
global corrected_data raw_data p name frames frameInfo
corrected_data.x(:,[5 9],:) = raw_data.x(:,[5 9],:);
corrected_data.y(:,[5 9],:) = raw_data.y(:,[5 9],:);
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p = plot(squeeze(corrected_data.y(:,[5 9],1)),'.-'); zoom on; grid on; datacursormode on;
legend('thumb','index','location','northwest'); xlabel('frames'),ylabel('vertical position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_switch = false(1,length(frames)); frameInfo.frames_indexClear = false(1,length(frames)); frameInfo.frames_thumbClear = false(1,length(frames));
end
%% "Save" pushbutton
function saveData(source,event)
global corrected_data name check_fig data_openpose frameInfo
cd = pwd; 
data_openpose.corrected_data = corrected_data;
save(fullfile(cd,[name '_openpose.mat']),'data_openpose','frameInfo','-append')
close(check_fig)
end
%% "Zoom" pushbutton
function zoomON(source,event)
zoom on;
end
%% "Data tip" pushbutton
function dataCursorON(source,event) 
datacursormode on;
end