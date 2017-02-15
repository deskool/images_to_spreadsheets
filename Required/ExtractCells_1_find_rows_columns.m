%COPYRIGHT: MOHAMMAD M. GHASSEMI, MIT
%DATE: May 16, 2016
%DESCRIPTION: EXTRACTS ROW AND COLUMN CANDIDATE POINTS FORM THE IMAGE.
function []= ExtractCells_1_find_rows_columns( DirectoryofJPG, SaveName, seg_len, num_peaks,ktimes,kclust,dilation,adap_threshold,adap_size,pre_blur)
%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% seg_len                 -what length segment should you break the image into, 20-40 reccomended.
% num_peaks               -how many hough peaks should you extract for the
% clustering, more is better.
% overlap                 -eventually, we will want to have overlaps, instead of chunks.
% num_rows                -allow user to specifiy this to speed things up.
% num_columns             -allow users to specify this to speed things up.
% ktimes                  -this is the number of times you run kmeans to identify final things. 
% kclust                  -this is for the number of times you run kmeans
% to identify clusters.
% adap_threshold          -the threshold of the adaptive filter.
% adap_size               -the radius of the adaptive filter.
% pre_blur                -the radius of the gassian filter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EXTRACT CELLS - Part 1
%figure,imshow(I_orig)
I_orig = imread(DirectoryofJPG);
I = imread(DirectoryofJPG);
I = rgb2gray(I);
%figure,imshow(I)

%% Gaussian Blur
H = fspecial('disk',pre_blur);
I = imfilter(I,H,'replicate');
%figure,imshow(I,[min(min(I)),max(max(I))]);
%waitforbuttonpress;

%% And dilate the image to fill in lines.
se = strel('disk',dilation);
I = imdilate(I,se);
%figure, imshow(I), 
%waitforbuttonpress;

%% Adaptive Thresholding to Remove shading
mode = 1; %1 is for median
I=adaptivethreshold(I,adap_size,adap_threshold,mode);
I = not(I);
%imshow(I);
%waitforbuttonpress;

%% And dilate the image to fill in lines.
se = strel('disk',dilation);
I = imdilate(I,se);
%figure, imshow(I)
%waitforbuttonpress;

%% Keep only the largest connected component
CC = bwconncomp(I);
numPixels = cellfun(@numel,CC.PixelIdxList);
idx = find(numPixels ~= max(numPixels));
for i = 1:length(idx)
I(CC.PixelIdxList{idx(i)}) = 0;
end
figure;imshow(I);
title('This is the pre-processed image - make sure it looks right!')
%% THIN THE IMAGE
I = bwmorph(I,'thin');
imshow(I);
%figure;imshow(I);
%waitforbuttonpress;

%% Find the centroids that describe the Rows and Columns, and get the row_width
[ row_c estimated_rows row_widths ~ ] = find_rows_centroids(I,seg_len,num_peaks,ktimes,kclust);
[ col_c estimated_columns column_widths ~ ] = find_column_centroids(I,seg_len,num_peaks,ktimes,kclust);

save([SaveName '.mat'],'row_c','estimated_rows','row_widths',...
                       'col_c','estimated_columns','column_widths',...
                       'I_orig', 'I');

end