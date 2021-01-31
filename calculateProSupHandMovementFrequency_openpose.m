function calculateProSupHandMovementFrequency_openpose(output_name)
clearvars -except output_name
% global 
%[file path] = uigetfile({'*.mat'},'Pick all OpenPose ''.mat'' files','MultiSelect','off');
file = sprintf('%s%s',output_name,'_openpose.mat');
cd = pwd;
load(fullfile(cd,file),'events_openpose','videoInfo')
%%
outputs.thumb_down_times = events_openpose.thumb_down_frames/videoInfo.vid_openpose.FrameRate;

for ii = 2:length(events_openpose.thumb_down_frames)
    outputs.movement_times(ii-1,1) = (events_openpose.thumb_down_frames(ii)-events_openpose.thumb_down_frames(ii-1))/videoInfo.vid_openpose.FrameRate;
    outputs.movement_frequency(ii-1,1) = 1/outputs.movement_times(ii-1,1);
end

outputs.mean_movement_frequency = nanmean(outputs.movement_frequency);

save(fullfile(cd,file),'outputs','-append');
