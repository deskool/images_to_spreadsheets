function [ row_lines] = getRowLinesv4( I, seg_len, row_c, estimated_rows, mode, angle, display,kmediods_param)
%% This function extracts the Rowlines From the image.
% INPUTS:
%  I          - The Image
%  seg_len    - the segment length used when calling ExtractCells_1_find_rows_columns
%  error_tol  - the tolerance for error - NO LONGER USED
%  row_c      - the line candidate locations at each segment
%  row_widths - the estimed width of each row
%  mode       - 1 = linear interpolation of the ends, 0 = flat.
%  angle      - used when finding candidate points, smaller is stricter.
%  display    - 1 = show, 0 = don't show.
%  kforstart  - increase if lines are overlapping!
%  delta      - parameter for final rows tuning
%  reference  - 0 = median, 1 = kmeans
% OUTPUTS:
% row_lines   - A set of lines that trace the rows in the spreadsheet.

%% STEP 1, Get the starting points for each row.

%Condense the data into a set of points
this_row = [];this_loc=[];
for k = 1:size(row_c,1)
    this_row = [this_row, row_c(k,:)];
    this_loc = [this_loc, [1:seg_len:seg_len*size(row_c,2)]];    
end

%Do one last search to make sure that the rows and columns are not whacky
% last_max= 0;
% for  k = estimated_rows-delta:1:estimated_rows+delta
%     [idx,~,~,~,midx] = kmedoids(this_row',k,'Distance','cityblock','Replicates',kmediods_param);
% 
%     [silh,h] = silhouette(this_row',idx,'cityblock');
%     res = mean(silh);
%     this_max = res;
%     if(last_max > this_max)
%         break;
%     end
%     last_max = this_max;
% end
% estimated_rows = k-1;


[idx,~,~,~,midx] = kmedoids(this_row',estimated_rows,'Distance','cityblock','Replicates',kmediods_param);

for i = 1:estimated_rows
these = find(idx == i);
these(isnan(these)) = [];

[a inddd]  = min(abs(this_row(these) - median(this_row(these))));

midx(i) =  these(inddd(1));
end


cen_pts = [this_row(midx);this_loc(midx)];
[cen_pts] = sort(cen_pts,2);



%plot(this_loc(midx),this_row(midx),'*')

%get the correct starting points - cen_points
%cen_pts = [this_row(midx);this_loc(midx)];


%% PLOT THE RESULTS, IF DISPLAY = 1
if(display == 1)
    close;
    imshow(I)
    hold on;
    %plot(this_loc,this_row,'o')
end
%plot(this_loc(midx),this_row(midx),'o')
%plot([1,1000] ,[row_loc,row_loc],'g')

%% FOR EACH OF THE ROWS IN THE IMAGES.
for i = 1:estimated_rows
    
    %waitforbuttonpress;
    %close;
    %imshow(I)
    %hold on;
    %plot(this_loc,this_row,'o')
    %row_loc(i)
    %plot([1,size(I,2)],[row_loc(i),row_loc(i)],'LineWidth',3)
    
    %% GRAB ALL POINTS.
    this_row = [];this_loc=[];
    for k = 1:size(row_c,1)
        this_row = [this_row, row_c(k,:)];
        this_loc = [this_loc, [1:seg_len:seg_len*size(row_c,2)]];
    end
    %% The first thing we want to do is take the point closest to the MEDIAN LINE
    this_line_row_right =  cen_pts(1,i);
    this_line_loc_right =  cen_pts(2,i);

    %plot(this_line_loc_right,this_line_row_right,'*')
    %% NOW LOOK FOR POINTS TO THE RIGHT.
    try
        while(1)
            pts = [this_loc; this_row]';
            distScale = size(I,1);
            pt = [this_line_loc_right(end);this_line_row_right(end)]';
            direction = [this_line_loc_right(end)+size(I,1)*100,0];
            
            ind =nearestDirectedPt(pt,pts,distScale,direction,angle);
            
            this_line_row_right = [this_line_row_right, this_row(ind)];
            this_line_loc_right = [this_line_loc_right, this_loc(ind)];
            
            kill = (this_loc == this_loc(ind(1)));
            
            this_row(kill) = [];
            this_loc(kill) = [];
            %plot(this_loc(ind),this_row(ind),'*')
        end
    catch
    end
    %plot(this_line_loc_right,this_line_row_right,'*')
    
    %% NOW LOOK FOR POINTS TO THE LEFT
    this_row = [];this_loc=[];
    for k = 1:size(row_c,1)
        this_row = [this_row, row_c(k,:)];
        this_loc = [this_loc, [1:seg_len:seg_len*size(row_c,2)]];
    end
    %% The first thing we want to do is take the point closest to the MEDIAN LINE
    this_line_row_left =  cen_pts(1,i);
    this_line_loc_left =  cen_pts(2,i);
    
    %plot(this_line_loc_left(end),this_line_row_left(end),'*')
    %close;
    %imshow(I)
    %hold on;
    %plot(this_loc,this_row,'o')
    
    try
        while(1)
            pts = [this_loc; this_row]';
            distScale = size(I,1);
            pt = [this_line_loc_left(end);this_line_row_left(end)]';
            direction = [-this_line_loc_left(end)-size(I,1)*100,0];
            
            ind =nearestDirectedPt(pt,pts,distScale,direction,angle);
            
            this_line_row_left = [this_line_row_left, this_row(ind)];
            this_line_loc_left = [this_line_loc_left, this_loc(ind)];
            
            kill = (this_loc == this_loc(ind(1)));
            
            this_row(kill) = [];
            this_loc(kill) = [];
        end
    catch
    end
   %plot(this_line_loc_left,this_line_row_left,'*')
    
   
    this_line_loc_left(1) = [];
    this_line_row_left(1) = [];
    
    this_loc = [this_line_loc_left,this_line_loc_right];
    this_row = [this_line_row_left,this_line_row_right];
    
    %plot(this_loc,this_row,'*')
    
    [this_loc, ind] = sort(this_loc);
    this_row = this_row(ind);
    
    
    if(mode == 1)
        rhs_end = this_row(end) + (this_row(end) - this_row(end-1))*(size(I,2)-this_loc(end))/seg_len;
    end
    if(mode == 0)
        rhs_end = this_row(end)
    end
    
    %Catch lines that fly off the screen
    if(rhs_end > size(I,1) )
        rhs_end = size(I,1);
    elseif(rhs_end < 1)
        rhs_end = 1;
    end
    
    this_loc = [this_loc size(I,2)];
    this_row = [this_row rhs_end];
    
    %fill the line to the end of the lhs
    
    if(mode == 1)
        lhs_end = this_row(1) - (this_row(2) - this_row(1))*(this_loc(1))/seg_len;
    end
    if(mode == 0)
        lhs_end = this_row(1);
    end
    %Catch lines that fly off the screen
    if(lhs_end > size(I,1) )
        lhs_end = size(I,1);
    elseif(lhs_end < 1)
        lhs_end = 1;
    end
    
    this_loc = [0 this_loc];
    this_row = [lhs_end this_row];
    
    if(display == 1)
        plot(this_loc,this_row,'LineWidth',3)
    end
    
    row_lines{i} = [this_loc; this_row];
    
end

end



