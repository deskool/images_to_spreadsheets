function [ col_lines, estimated_columns ] = getColumnLinesv4( I, seg_len, col_c, estimated_columns,mode,angle, display,kmediods_param,delta)

%% CHOOSE HOW YOU ARE GOING TO START THE LINE SEGMENTS.

this_col = [];this_loc=[];
for k = 1:size(col_c,1)
    this_col = [this_col, col_c(k,:)];
    this_loc = [this_loc, [1:seg_len:seg_len*size(col_c,2)]];
end
hold on;
plot(this_col,this_loc,'o')


[idx,~,~,~,midx] = kmedoids(this_col',estimated_columns,'Distance','cityblock','Replicates',kmediods_param);
for i = 1:estimated_columns
these = find(idx == i);
these(isnan(these)) = [];

[a inddd]  = min(abs(this_col(these) - median(this_col(these))));

midx(i) =  these(inddd(1));
end

cen_pts = [this_col(midx);this_loc(midx)];
[cen_pts] = sort(cen_pts,2);



if(display == 1)
    close;
    imshow(I)
    hold on;
end
hold on;


for i = 1:size(col_c,1)
   
    
        %% GRAB ALL POINTS.
    this_col = [];this_loc=[];
    for k = 1:size(col_c,1)
        this_col = [this_col, col_c(k,:)];
        this_loc = [this_loc, [1:seg_len:seg_len*size(col_c,2)]];
    end
    
    %plot(this_col,this_loc,'*')
    
    %% TAKE POINT CLOSEST TO MEDIAN
    this_line_col_down =  cen_pts(1,i);
    this_line_loc_down =  cen_pts(2,i);
    
    %plot(this_line_col_down(end),this_line_loc_down(end),'*')
    %waitforbuttonpress;
    %% GRAB POINTS BELOW
    try
    while(1)
        
        pts = [this_col;this_loc]';
        distScale = size(I,2);
        pt = [this_line_col_down(end);this_line_loc_down(end)]';
        direction = [0,this_line_col_down(end)+size(I,2)*100]; 
        
        ind =nearestDirectedPt(pt,pts,distScale,direction,angle);
        %plot(this_col(ind),this_loc(ind),'*');
        this_line_col_down = [this_line_col_down, this_col(ind)];
        this_line_loc_down = [this_line_loc_down, this_loc(ind)];

       kill = (this_loc == this_loc(ind(1)));

       this_col(kill) = [];
       this_loc(kill) = [];
    end
    catch
    end
     %plot(this_line_col_down,this_line_loc_down,'*')
    
     
    %% GRAB POINTS ABOVE.
    this_col = [];this_loc=[];
    for k = 1:size(col_c,1)
        this_col = [this_col, col_c(k,:)];
        this_loc = [this_loc, [1:seg_len:seg_len*size(col_c,2)]];
    end
    
    this_line_col_up =  cen_pts(1,i);
    this_line_loc_up =  cen_pts(2,i);
    
    try
    while(1)
        pts = [this_col;this_loc]';
        distScale = size(I,2);
        pt = [this_line_col_up(end);this_line_loc_up(end)]';
        direction = [0,-this_line_col_up(end)-size(I,2)*100]; 

        ind =nearestDirectedPt(pt,pts,distScale,direction,angle);

        this_line_col_up = [this_line_col_up, this_col(ind)];
        this_line_loc_up = [this_line_loc_up, this_loc(ind)];

       kill = (this_loc == this_loc(ind(1)));

       this_col(kill) = [];
       this_loc(kill) = [];
    end
    catch
    end
     %plot(this_line_col_up,this_line_loc_up,'*')
    
    this_line_loc_up(1) = [];
    this_line_col_up(1) = [];
    
    this_loc = [this_line_loc_up,this_line_loc_down];
    this_col = [this_line_col_up,this_line_col_down];
    
    %plot(this_loc,this_row,'*')
        
    [this_loc, ind] = sort(this_loc);
    this_col = this_col(ind);
     
     
    
    %%
    
    
    %plot(this_col,this_loc,'*');
    
    %fill the line below
    if(mode == 1)
        down_end = this_col(end) + (this_col(end) - this_col(end-1))*(size(I,1)-this_loc(end))/seg_len;
    end
    if(mode == 0)
        down_end = this_col(end);
    end
    %Catch lines that fly off the screen
    if(down_end > size(I,2) )
        down_end = size(I,2);
    elseif(down_end < 1) 
        down_end = 1;
    end
    
    this_col = [this_col down_end];
    this_loc = [this_loc size(I,1)];
    
    %fill the line above
    if(mode == 1)
        up_end = this_col(1) - (this_col(2) - this_col(1))*(this_loc(1))/seg_len;
    end
    if(mode == 0)
        up_end = this_col(1);
    end

    %Catch lines that fly off the screen
    if(up_end > size(I,2) )
        up_end = size(I,2);
    elseif(up_end < 1) 
        up_end = 1;
    end
    
    this_col = [up_end this_col];
    this_loc = [0 this_loc];
    
    if(display == 1)
        plot(this_col,this_loc,'LineWidth',3);
    end
    
    col_lines{i} = [this_col; this_loc] ;   
end

end

