function OpenPoseMovementAnalysis_HC

[output_name, trial_type] = process_openpose();

if trial_type == 1 || trial_type == 2
    checkHandID_openpose(output_name);
    gapFillHand_filter_openpose(output_name);
    findHandEvents_openpose(output_name);
    calculateHandMovementFrequency_openpose(output_name);
elseif trial_type == 3
    checkHandID_openpose(output_name);
    gapFillHand_filter_openpose(output_name);
    findProSupHandEvents_openpose(output_name);
    calculateProSupHandMovementFrequency_openpose(output_name);
elseif trial_type == 4
    checkToeID_openpose(output_name);
    gapFillBody_filter_openpose(output_name);
    findToeEvents_openpose(output_name);
    calculateToeMovementFrequency_openpose(output_name);
else
    checkHeelID_openpose(output_name);
    gapFillBody_filter_openpose(output_name);
    findHeelEvents_openpose(output_name);
    calculateHeelMovementFrequency_openpose(output_name);
end