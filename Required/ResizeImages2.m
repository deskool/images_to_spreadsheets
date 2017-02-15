%COPYRIGHT: MOHAMMAD MAHDI GHASSEMI
%DATE: MARCH 19TH, 2015
function [ resized_clean_image_mat ] = ResizeImages2(image_mat_digits, has_stuff, x_resize, y_resize )
%This Function takes a matrix of images of digits and:
%     1. resizes them to to a specified dimentions via padding
%     2. Maintains the aspect ratio of the images.

% PARAMTERS OF THE FUCNTION:
% image_mat_digits   - This is a 3d matrix of images, where the 3rd dim is
%                    - each digit
% has_stuff          - Indicates which cells have stuff in them.
% x/y_resize         - Give the x and y dimensions you want to resize to.

ind = 1;
for i = 1:size(image_mat_digits,1)
    for j = 1:size(image_mat_digits,2)   
        for k = 1:size(image_mat_digits,3) 
           heights(ind) =  size(image_mat_digits{i,j,k},1);
           widths(ind) = size(image_mat_digits{i,j,k},2);
           ind = ind+1;
        end
    end
end

%This max is what we are going to map to the 28.
reference_height = max(heights)
reference_width = max(widths)


resized_clean_image_mat{size(image_mat_digits,1),size(image_mat_digits,2),size(image_mat_digits,3)} = [];
for i = 1:size(image_mat_digits,1)
    for j = 1:size(image_mat_digits,2)
        
        %ONLY WANT TO DO SOMETHING IF THERE IS SOMETHING IN THIS CELL.
        if(has_stuff(i,j) == 1)
            
            %FOR EACH DIGIT
            for k = 1:size(image_mat_digits,3) 
                %GRAB THE IMAGE 
                BW = image_mat_digits{i,j,k};  
                imshow(BW)
                 %Get the x and the y_dim
                 
                      
            %scale the image to be in a box the same size as the
            %reference_digit (max in this case)
            
%             ydim = size(BW,1); xdim = size(BW,2);
%             reference_height = ydim;
%             if(xdim < reference_height)
%                 pad = reference_height - xdim;
%                 
%                 if(mod(pad,2) > 0)
%                     padr = floor(pad/2); padl = padr + 1;
%                 else
%                     padr = pad/2; padl = padr;
%                 end
%                 
%                 %pad with columns
%                 BW = [zeros(ydim,padl) BW zeros(ydim,padr)];
%             end
%             
%             
%            ydim = size(BW,1); xdim = size(BW,2);
%            reference_height= xdim;
%            if(ydim < reference_width)
%                 pad = reference_width - ydim;
%                 
%                 if(mod(pad,2) > 0)
%                     padr = floor(pad/2); padl = padr + 1;
%                 else
%                     padr = pad/2; padl = padr;
%                 end
%                 
%                 %pad with rows
%                 BW = [zeros(padl,xdim); BW; zeros(padl,xdim)];
%            end
           
           
            ydim = size(BW,1); xdim = size(BW,2);
            ref_dim = max([xdim,ydim]);
            %If the height is more than the width
            if(ydim > xdim)
                pad = ref_dim - xdim;
                
                if(mod(pad,2) > 0)
                    padr = floor(pad/2); padl = padr + 1;
                else
                    padr = pad/2; padl = padr;
                end
                
                %pad with columns
                BW = [zeros(ref_dim,padl) BW zeros(ref_dim,padl)];
                

            %If the width is more than the height
            elseif(xdim > ydim)
                pad = ref_dim - ydim;
                
                if(mod(pad,2) > 0)
                    padr = floor(pad/2); padl = padr + 1;
                else
                    padr = pad/2; padl = padr;
                end
                
                %pad with rows
                BW = [zeros(padl,ref_dim); BW; zeros(padl,ref_dim)];
            end

            %resize the image
            if ~isempty(BW) & sum(sum(BW)) > 0
                BW = imresize(BW,[x_resize,y_resize]);
                resized_clean_image_mat{i,j,k} = BW;   
            end
            
                 
            end
        end
    end
end


end


