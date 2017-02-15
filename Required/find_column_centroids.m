%AUTHOR: MOHAMMAD M. GHASSEMI -MIT
function [ locationOfCentriods,estimated_columns, column_widths, lines ] = find_column_centroids(I,pixel_length,num_peaks,ktimes,kclust)
%INPUTS:
%I            - is the spreadsheet image
%pixel_length - is the length of each image segment we will be breaking this into
%numpeaks     - is the number of hough peaks you want to cluster in the 
%               k-means algorithm.

%OUTPUTS:
% locationOfCentroids - for each image segment, it returns the location of
%                       row along the y-axis.
% estimated_rows      - the estimated number of rows from the k-means
%                       algorithm.
% lines               - the line segments

%% This Section takes the image, breaks it into 20 pixel segments
%pixel_length = 20;
num_pieces = floor((size(I,1)-pixel_length)/pixel_length);
%num_peaks = 1000;
%this_res has vote from each segment
lines = []; this_res = zeros(1,num_pieces);
theta_tol = 10;

%% TAKE THE IMAGE, BREAK IT INTO PICES, AND FIND THE NUMBER OF CLUSTERS.
% interestingly, on the mac, parfor doubles the speed. we go from 500
% seconds to run to 260.
% It's only when I use all 16 cores that my runtime is better - 182
% seconds... Trully rediculous.
% 364 - or 6 mins - even reducing the workload I get 291
parfor j=1:num_pieces;
    % GET THE SUBIMAGE
    this_chunk = (1+ (j-1)*pixel_length):j*pixel_length;  
    
    this_I = zeros(size(I,1),size(I,2));
    this_I(this_chunk,:) = I(this_chunk,:);
    
    % DO THE HOUGH TRANSFORM
    [H,theta,rho] = hough(this_I,'Theta',[0-theta_tol:.01:0 , 0:.01:0+theta_tol]);
    
    P = houghpeaks(H,num_peaks,'threshold',0.5*max(H(:)));

    
    %GET THE LINES.
    these_lines = houghlines(this_I,theta,rho,P,'FillGap',size(I(this_chunk,:),1)/2,'MinLength',10);
    if ~isempty(these_lines)
    %GET THE Y VALUES
    p1 = [these_lines.point1];
    y1= p1(1:2:end);
    p2 = [these_lines.point2];
    y2= p2(1:2:end);
    X = [y1,y2]';
    
    % IDENTIFY THE NUMBER OF LINES. 
    this_res(j) = GetClusters(round(size(I,1)/10), X, kclust);
    else
        this_res(j) = nan;   
    end
end

%% We have the estimated number of rows from this.
estimated_columns = mode(this_res(~isnan(this_res)));
%% Using the estimated number of rows, get the line closest to the centroids
%pixel_length = 20;
%num_peaks = 1000;
lines = []; this_res = []; index = 1;
theta_tol = 10;
c = zeros(estimated_columns,num_pieces);
locationOfCentriods(estimated_columns,num_pieces) = 0;
parfor j=1:num_pieces;
  
    this_chunk = (1+ (j-1)*pixel_length):j*pixel_length;  
    
    this_I = zeros(size(I,1),size(I,2));
    this_I(this_chunk,:) = I(this_chunk,:);
    
    % DO THE HOUGH TRANSFORM
    [H,theta,rho] = hough(this_I,'Theta',[0-theta_tol:.01:0 , 0:.01:0+theta_tol]);
    
    P = houghpeaks(H,num_peaks,'threshold',0.5*max(H(:)));

    
    %GET THE LINES.
    these_lines = houghlines(this_I,theta,rho,P,'FillGap',size(I(this_chunk,:),1)/2,'MinLength',10);
    if ~isempty(these_lines)
    %GET THE Y VALUES
    p1 = [these_lines.point1];
    y1= p1(1:2:end);
    p2 = [these_lines.point2];
    y2= p2(1:2:end);
    X = [y1,y2]';
     
    [~, cx] = kmeans(X,estimated_columns,'Distance','cityblock','Replicates',ktimes);
    cx = sort(cx);
    
    locationOfCentriods(:,j) = cx;
    
    %Find the thing which was closest to line1.
    %[~,ind] =  min(abs(X(:,1) - cx(1)));
    lines = [lines these_lines];
    else
        locationOfCentriods(:,j) = nan*ones(estimated_columns,1);  
    end
end

centmedian = nanmedian(locationOfCentriods');
column_widths = abs(centmedian(1:size(locationOfCentriods,1)-1) - centmedian(2:size(locationOfCentriods,1)))

end

