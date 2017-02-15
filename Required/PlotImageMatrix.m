function []= PlotImageMatrix( image_matrix )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
ind = 1
for i = 1:size(image_matrix,1)
    for j = 1:size(image_matrix,2)
        subplot(size(image_matrix,1),size(image_matrix,2),ind); 
        imshow(image_matrix{i,j})
        ind = ind + 1;
    end
end

end

