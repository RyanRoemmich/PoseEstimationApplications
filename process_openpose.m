function [output_name, trial_type] = process_openpose()
clearvars -except output_name
[file path] = uigetfile({'*.JSON'},'Pick all JSON files','MultiSelect','on');
[vid_name vid_path] = uigetfile({'*.mov;*.mp4;*.avi;*.qt;*.wmv','Video files (*.mov,*.mp4,*.avi,*.qt,*.wmv)'},'Pick original video file');
[vid_openpose_name vid_openpose_path] = uigetfile({'*.mov;*.mp4;*.avi;*.qt;*.wmv','Video files (*.mov,*.mp4,*.avi,*.qt,*.wmv)'},'Pick OpenPose labeled video file');
cd = pwd;
%%
noBodyLandmarks = 25; % BODY_25 model
noHandLandmarks = 21; % hand model
noFiles = length(file); % number of files

vid = VideoReader(fullfile(vid_path,vid_name));
vid_openpose = VideoReader(fullfile(vid_openpose_path,vid_openpose_name));
width = vid_openpose.Width; height = vid_openpose.Height;
sR_openpose = vid_openpose.FrameRate;
videoInfo.vid = vid; videoInfo.vid_openpose = vid_openpose;
find_period = find(ismember(vid_name,'.'),1,'last');
output_name = vid_name;
if output_name(find_period) == '.'
    output_name(find_period:end) = [];
end

time_openpose = nan(1,noFiles);
       
for j = 1:noFiles        
    val = jsondecode(fileread(fullfile(path,file{j}))); % load JSON file
    if ~isempty(val.people) % check if any people are detected
        body_data.x(j,:) = val.people(1).pose_keypoints_2d(1:3:end);
        body_data.y(j,:) = -val.people(1).pose_keypoints_2d(2:3:end);
        body_data.conf(j,:) = val.people(1).pose_keypoints_2d(3:3:end);
        left_hand_data.x(j,:) = val.people(1).hand_left_keypoints_2d(1:3:end);
        left_hand_data.y(j,:) = -val.people(1).hand_left_keypoints_2d(2:3:end);
        left_hand_data.conf(j,:) = val.people(1).hand_left_keypoints_2d(3:3:end);
        right_hand_data.x(j,:) = val.people(1).hand_right_keypoints_2d(1:3:end);
        right_hand_data.y(j,:) = -val.people(1).hand_right_keypoints_2d(2:3:end);
        right_hand_data.conf(j,:) = val.people(1).hand_right_keypoints_2d(3:3:end);
    end   
end

time_openpose = 0:1/sR_openpose:(noFiles-1)/sR_openpose; % time vector

data_openpose.body_data = body_data;
data_openpose.left_hand_data = left_hand_data;
data_openpose.right_hand_data = right_hand_data;
data_openpose.time = time_openpose;

trial_type = listdlg('PromptString','Select a trial type','SelectionMode','single','ListString',{'Finger Tap','Hand Open/Close','Hand Pronation/Supination','Toe Tap','Heel Tap'});

save(fullfile(cd,[output_name '_openpose.mat']),'data_openpose','videoInfo','output_name','trial_type')

clearvars -except output_name trial_type