%COPYRIGHT: MOHAMMAD MAHDI GHASSEMI
%DATE: MARCH 19TH, 2015
function [ image_mat_digits ] = ExtractIndividualDigits( image_matrix_clean,has_stuff,border  )
%This Function takes a matrix of images of digits and
%     1. Extracts the connected components, which it places along the third
%     axis.
% PARAMTERS OF THE FUCNTION:
% image_matrix_clean - This is a matrix of images (ideally preprocessed)
% has_stuff          - Indicates which cells have stuff in them.
% border             - After cutting the numbers out, how many pixels
%                      want to buffer/frame them with (reccomend 5)

image_mat_digits{size(image_matrix_clean,1),size(image_matrix_clean,2)} = [];
for i = 1:size(image_matrix_clean,1)
    for j = 1:size(image_matrix_clean,2)
              
        if(has_stuff(i,j) == 1)
            BW = image_matrix_clean{i,j};        
            %Connected-Component Labeling - one per digit?
            CC = bwconncomp(BW);
            bb_locs = regionprops(CC,'Image');
            
            for k = 1:length(bb_locs)
                image= [zeros(border,size(bb_locs(k).Image,2)); bb_locs(k).Image; zeros(border,size(bb_locs(k).Image,2))];
                image= [zeros(size(image,1),border), image, zeros(size(image,1),border)];
                if sum(sum(image)) > 0
                image_mat_digits{i,j,k} = image;
                end
            end
        end
    end
end






end

