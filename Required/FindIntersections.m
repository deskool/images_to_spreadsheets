function [ intersections ] = FindIntersections( row_lines, col_lines,I, display )
if(display == 1)
imshow(I)
end
for i = 1:length(row_lines)
        this_row = [row_lines{i}];
    for j = 1:length(col_lines)
        this_column = [col_lines{j}];
        [xint yint] = cint(this_row(1,:),this_row(2,:),this_column(1,:),this_column(2,:));
        intersections(i,j,1:2) = [xint yint]; 
        if(display == 1)
        hold on;
        plot(xint,yint,'r*')
        end
    end
end

end

