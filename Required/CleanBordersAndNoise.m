%COPYRIGHT: MOHAMMAD MAHDI GHASSEMI
%DATE: MARCH 19TH, 2015

function [ image_matrix_clean has_stuff ] = CleanBordersAndNoise( image_matrix, noise_chunk_perc,agression,border,dilation )
%This Function takes a matrix of images, and 
%     1. Removes Borders
%     2. Converts to Black and White
%     3. Removes Specks in the image.
%     4. Eliminates trash around the image.
% PARAMTERS OF THE FUCNTION:
% image_matrix     - This is a matrix of images.
% noise_chunk_perc - This asks what percentage of the the total areas of
%                    the cell an image must be to be considered 'Noise'. 
%                    Higher is more agressive noise reduction
% agression        - This terms dictates what area around the border you
%                  - want to eliminiate. Higher agression eliminates more.
% border           - After cutting the numbers out, how many pixels do you
%                    want to buffer/frame them with (reccomend 5)

image_matrix_clean{size(image_matrix,1),size(image_matrix,2)} = [];
for i = 1:size(image_matrix,1)
    for j = 1:size(image_matrix,2)
        
        %uplaod image
        Icorrected = (rgb2gray(image_matrix{i,j,:}));
        
        %figure out what noise size might be?
        noise_chunk_size = round(noise_chunk_perc*size(Icorrected,1)*size(Icorrected,2));
        
        %Pre-process
        th  = graythresh(Icorrected);
        BW = not(im2bw(Icorrected, th));
        
         if(sum(sum(BW))/(size(BW,1)*size(BW,2)) > .6)
          BW = not(BW);
         end
        
        se = strel('disk',dilation);
        BW = imdilate(BW,se);
         
        %% EDGE DETECTION AND REMOVAL.
        %imshow(BW)

        %waitforbuttonpress;
        
        %agression = 2; %lower is more agressive.
        [left right top bottom] = FindImageBorders(BW,agression);
        
        BW(1:left,:) = 0;BW(right:end,:) = 0;
        BW(:,top:end) = 0;BW(:,1:bottom) = 0;
        
      
        
        %imshow(BW)
        
        %% WE MUST NOW CLEAN NOISE...
        BW = bwareaopen(BW, noise_chunk_size);
         %imshow(BW)
        %Mark the has stuff matrix if there is something in this cell.
        if( mean(mean(BW)) > 0);
            has_stuff(i,j) = 1;
        else
            has_stuff(i,j) = 0;
        end
        

        if(has_stuff(i,j) == 1)
            
            %You want to find the inner contents locations
            [a,b] = find(BW == 1);
            
            %Now cut out the contents with the border size.
            BW= BW(min(a)-border:max(a)+border,min(b)-border:max(b)+border);
            
            image_matrix_clean{i,j} = BW;
           
        end
    end
end

end

