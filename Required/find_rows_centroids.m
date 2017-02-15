%AUTHOR: MOHAMMAD M. GHASSEMI - MIT
function [ locationOfCentriods, estimated_rows, row_widths lines ] = find_rows_centroids(I,seg_len,num_peaks,ktimes,kclust)
%INPUTS:
%I         - is the spreadsheet image
%seg_len   - is the length of each image segment we will be breaking this into
%numpeaks  - is the number of hough peaks you want to cluster in the 
%            k-means algorithm.

%OUTPUTS:
% locationOfCentroids - for each image segment, it returns the location of
%                       row along the y-axis.
% estimated_rows      - the estimated number of rows from the k-means
%                       algorithm.
% row_widths          - the width of each of the rows.
% lines               - the line segments

%% This Section takes the image, breaks it into 20 pixel segments
pixel_length = seg_len;
num_pieces = floor((size(I,2)-pixel_length)/pixel_length)
lines = []; 
this_res = zeros(1,num_pieces);
theta_tol = 10; %The angle of the line
min_len = 10; %how short can a line be, before it's too short.
min_size = 10; %The minimum size of a box in pixels
%% TAKE THE IMAGE, BREAK IT INTO PICES, AND FIND THE NUMBER OF CLUSTERS.


parfor j=1:num_pieces;
    % GET THE SUBIMAGE
    this_chunk = (1+ (j-1)*pixel_length):j*pixel_length;  
    
    this_I = zeros(size(I,1),size(I,2));
    this_I(:,this_chunk) = I(:,this_chunk);
    % DO THE HOUGH TRANSFORM
    [H,theta,rho] = hough(this_I,'Theta',[90-theta_tol:.01:89.90 , -90:.01:-90+theta_tol]);
    
    P = houghpeaks(H,num_peaks,'threshold',0.5*max(H(:)));
    x = theta(P(:,2));y = rho(P(:,1));%plot(x,y,'s','color','black');
    
    %GET THE LINES.
    these_lines = houghlines(this_I,theta,rho,P,'FillGap',size(I(:,this_chunk),2)/2,'MinLength',10);
    if ~isempty(these_lines)
        %GET THE Y VALUES
        p1 = [these_lines.point1];
        y1= p1(2:2:end);
        p2 = [these_lines.point2];
        y2= p2(2:2:end);
        X = [y1,y2]';

        % IDENTIFY THE NUMBER OF LINES. 
        this_res(j) = GetClusters(round(size(I,2)/10), X, kclust );
    else
        this_res(j) = nan; 
    end
    j
end

%% We have the estimated number of rows from this.
estimated_rows = mode(this_res(~isnan(this_res)));

%% Using the estimated number of rows, get the line closest to the centroids
pixel_length = seg_len;
%num_peaks = 1000;
lines = []; this_res = []; index = 1;
theta_tol = 10;
estimated_rows, num_pieces
c = zeros(estimated_rows,num_pieces);
locationOfCentriods(estimated_rows,num_pieces) = 0;
parfor j=1:num_pieces;
    % GET THE SUBIMAGE
    this_chunk = (1+ (j-1)*pixel_length):j*pixel_length;  
    
    this_I = zeros(size(I,1),size(I,2));
    this_I(:,this_chunk) = I(:,this_chunk);
    
    % DO THE HOUGH TRANSFORM
    [H,theta,rho] = hough(this_I,'Theta',[90-theta_tol:.01:89.90 , -90:.01:-90+theta_tol]);
    
    P = houghpeaks(H,num_peaks,'threshold',0.5*max(H(:)));
    x = theta(P(:,2));y = rho(P(:,1));plot(x,y,'s','color','black');
    
    %GET THE LINES.
    these_lines = houghlines(this_I,theta,rho,P,'FillGap',size(I(:,this_chunk),2)/2,'MinLength',10);
    if ~isempty(these_lines)
        p1 = [these_lines.point1];
        y1= p1(2:2:end);
        p2 = [these_lines.point2];
        y2= p2(2:2:end);

        %plot(y1,y2,'.')
        X = [y1,y2]';

        % IDENTIFY THE NUMBER OF LINES.   
        [~, cx] = kmeans(X,estimated_rows,'Distance','cityblock','Replicates',ktimes);
        %c(1:28,1:2) = cx;
        cx = sort(cx);

        locationOfCentriods(:,j) = cx;

        %cxx(1:27,j) = abs(cx(1:end-1) - cx(2:end));

        %Find the thing which was closest to line1.
        %[~,ind] =  min(abs(X(:,1) - cx(1)));
        lines = [lines these_lines];
    else
      locationOfCentriods(:,j) = nan*ones(estimated_rows,1);  
    end
    
 
    
end


centmedian = nanmedian(locationOfCentriods');
row_widths = abs(centmedian(1:size(locationOfCentriods,1)-1) - centmedian(2:size(locationOfCentriods,1)))


end

