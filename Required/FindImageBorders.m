function [ left right top bottom  ] = FindImageBorders(BW, agression)
%% FIND UPPER AND LOWER BORDERS.
%go one strip at a time, and grab the bottomost of the top, and the topmost
%of the bottom.
clear maxes;
clear mins;

%imshow(BW)

for k = 1:size(BW,2)
    strip = BW(:,k);
    strip_border = find(strip == 1);
    %imshow(strip)
    
    %If it's not a white strip from a border..
    
    
    if(mean(strip) < .75)
        
        
        %We want to find the longest continuously connectect segment.
        smax = max(find(strip == 1));
        if(~isempty(smax))
            
            for i = 1:length(strip_border)
                if(~isempty(strip_border(find(strip_border == smax - 1))))
                    smax = strip_border(find(strip_border == smax - 1));
                else
                    maxes(k) = smax;
                    break;
                end
                
            end
        else
            maxes(k) =size(BW,1);
        end
        
        %hold on;
        %plot(1,smax,'*')
        
        smin = min(find(strip == 1));
        if(~isempty(smin))
            for i = 1:length(strip_border)
                
                if(~isempty(strip_border(find(strip_border == smin + 1))))
                    smin = strip_border(find(strip_border == smin + 1));
                else
                    mins(k) = smin;
                    break;
                end
            end
            
        else %if there is nothing
            mins(k) = 1;
        end
        
        
    else
        maxes(k) = nan;
        mins(k) = nan;
    end
    
end

%% CHECK FOR MISSING TOP AND BOTTOM
if( mean((maxes == Inf) & (mins == Inf)) > .3)
    left = 1;
    right = size(BW,1);
else
    
    ind = find(mins >= maxes);
    maxes(maxes(ind) < size(BW,1)/2) = size(BW,1);
    mins(mins(ind) > size(BW,1)/2) = 1;
    
    % This is all topsy turvy...
    left = nanmedian(mins)  + round(nanstd(mins)/agression) + 1;
    right = nanmedian(maxes) - round(nanstd(maxes)/agression) - 1;
    
    
    %we need to see if the min has passed the max mroe than 30% of the time,
    %then one of the borders i is probably missing.
    bad_line = left >= right;
    
    %then find if it's the top or the bottom piece that's the problem...
    if bad_line == 1
        if (right < size(BW,1)/2)
            right = size(BW,1);
        else
            left = 1;
        end
    end
    
end

%% FIND RIGHT AND LEFT BORDER
%go one strip at a time, and grab the bottomost of the top, and the topmost
%of the bottom.
clear maxes;
clear mins;
for k= 1:size(BW,1)
    strip = BW(k,:);
    strip_border = find(strip == 1);
    %    imshow(strip)
    if(mean(strip) < .75)
        
        smax = max(find(strip == 1));
        if(~isempty(smax))
            for i = 1:length(strip_border)
                if(~isempty(strip_border(find(strip_border == smax - 1))))
                    smax = strip_border(find(strip_border == smax - 1));
                else
                    maxes(k) = smax;
                    break;
                end
                
            end
        else
            maxes(k) = size(BW,2);
        end
        %hold on;
        %plot(smax,1,'*')
        
        
        smin = min(find(strip == 1));
        if(~isempty(smin))
            for i = 1:length(strip_border)
                
                if(~isempty(strip_border(find(strip_border == smin + 1))))
                    smin = strip_border(find(strip_border == smin + 1));
                else
                    mins(k) = smin;
                    break;
                end
            end
        else
            mins(k) = 1;
        end
        hold on;
        %plot(smin,1,'*')
        
    else
        maxes(k) = nan;
        mins(k) = nan;
    end
    
    
end

if( mean((maxes == Inf) & (mins == Inf)) > .3)
    bottom = 1;
    top = size(BW,2);
else
    
    ind = find(mins >= maxes);
    maxes(maxes(ind) < size(BW,2)/2) = size(BW,2);
    mins(mins(ind) > size(BW,2)/2) = 1;
    
    
    bottom = nanmedian(mins)  + round(nanstd(mins)/agression) + 1;
    top = nanmedian(maxes) - round(nanstd(maxes)/agression) - 1;
    
    %tops = maxes;
    %bottoms = mins;
    
    bad_line = bottom >= top;
    
    %then find if it's the top or the bottom piece that's the problem...
    if bad_line == 1
        if (top < size(BW,2)/2)
            top = size(BW,2)
        else
            bottom = 1;
        end
    end
end
%imshow(BW(left:right,bottom:top))

end

