function [ image_matrix ] = MakeImageMatrix( I_orig,intersections, error)
%Error - how large of a buffer do you want around the object in cells.
for i = 1:size(intersections,1)-1
    for j = 1:size(intersections,2)-1
        
        xerror = (intersections(i,j+1,1) - intersections(i,j,1))*error;
        xcorners = [ (intersections(i,j,1) - xerror), 
                     (intersections(i,j+1,1) + xerror),
                     (intersections(i+1,j,1) -xerror),
                     (intersections(i+1,j+1,1) +xerror)];
        yerror = (intersections(i,j,2)-intersections(i+1,j,2))*error; 
        ycorners = [ (intersections(i,j,2) - yerror),
                     (intersections(i,j+1,2) + yerror),
                     (intersections(i+1,j,2) - yerror),
                     (intersections(i+1,j+1,2) + yerror)];
        
                 rec=round([min(xcorners), min(ycorners), max(xcorners)-min(xcorners), max(ycorners)-min(ycorners)]);
                 image2 = imcrop(I_orig,rec);
                 image_matrix{i,j}= image2; 
                 imshow(image2)
                 
    end
end

end

