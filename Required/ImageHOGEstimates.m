%COPYRIGHT: MOHAMMAD MAHDI GHASSEMI
%DATE: MARCH 19TH, 2015
function [ pred_labels, conf ] = ImageHOGEstimates( resized_clean_image_mat,has_stuff,hog_classifier, cellSize  )
%This Function takes a matrix of images of digits and:
%     1. Uses a HOG Classifier to produce a label, and a confidence bound.

% PARAMTERS OF THE FUCNTION:
% image_mat       - This is a 3d matrix of images, where the 3rd dim is each digit
% has_stuff       - Indicates which cells have stuff in them.
% hog_classifier  - The trained HOG Classifier ClassificationECOC object.
% cell_size       - The cell size used in the HOG Transform

conf = nan*ones(size(resized_clean_image_mat,1),size(resized_clean_image_mat,2),size(resized_clean_image_mat,3));
pred_labels{size(resized_clean_image_mat,1),size(resized_clean_image_mat,2),size(resized_clean_image_mat,3)} = []
for i = 1:size(resized_clean_image_mat,1)
    for j = 1:size(resized_clean_image_mat,2)
        if(has_stuff(i,j) == 1) 
            for k = 1:size(resized_clean_image_mat,3)
                BW = resized_clean_image_mat{i,j,k};  
                if(~isempty(BW))
                mytestFeatures = extractHOGFeatures(BW, 'CellSize', cellSize);
                [mypredictedLabels, ~,~,conf_interval] = predict(hog_classifier, mytestFeatures);
                conf(i,j,k) = max(conf_interval');
                
                if (mypredictedLabels == 11)
                    mypredictedLabels = '.';
                else
                    mypredictedLabels = num2str(mypredictedLabels);
                end
                
                
                pred_labels{i,j,k} = mypredictedLabels;
                end
            end 
        end   
    end  
end


end

