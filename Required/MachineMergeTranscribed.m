function [ mech_labels ] = MachineMergeTranscribed( pred_labels, MarkedForMachine)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
mech_labels = cell(size(pred_labels,1),size(pred_labels,2));
for i = 1:size(pred_labels,1)
    for j = 1:size(pred_labels,2)  
        if(MarkedForMachine(i,j) == 1)
        A = squeeze([pred_labels{i,j,:}]);
        mech_labels{i,j} = A  
        end   
    end
end

end

