%COPYRIGHT: MOHAMMAD MAHDI GHASSEMI
%DATE: MARCH 19TH, 2015
function [] = PrepareImagesForTurk(image_matrix, resize_factor, MarkedForHuman, name, dropbox_public_folder,local_dir,csv_filename  )
%This Function takes a matrix of images and:
%     1. Saves the images in the public dropbox folder and,
%     2. Generates a csv that can be read by turk to find the images.
% PARAMTERS OF THE FUCNTION:
% image_mat       - This is a 2d matrix of images
% MarkedForHuman  - Indicates which cells you want to create images for.
% name            - This is the name you want to proceed each image.
%                   Reccomend that you use the spreadsheet name here
% dropbox_public_folder - give the webadress of the folder you are storing
%                         the images in.
% local_dir             - give the local directory that corresponds to the 
%                         public dropbox folder.
% csv_filename          - The name of the file that turk requests for
%                         linking your HITS to the public folder. 


%Need to find a clever way tyo set this.
%name = 'img';
%location of your public dropbox folder on the web.
%dropbox_public_folder = ['https://dl.dropboxusercontent.com/u/81501921/']
%local_dir = '/home/mohammad/Dropbox (MIT)/Public/test';
%csv_filename = 'turked_images.csv'


%Where do you want to save your files
%this should be the location on the local machine.
pwd_back = pwd;
cd(local_dir)

% THIS LOOP GENERATE THE PICTURES AND SAVES THEM
for i = 1:size(image_matrix,1)
    for j = 1:size(image_matrix,2)
        if(MarkedForHuman(i,j) == 1) 
        Icorrected = image_matrix{i,j,:};
        
        Icorrected = imresize(Icorrected,resize_factor);
        
        f = figure('visible','off');
        imshow(Icorrected);
        axis off
        set(gca,'position',[0 0 1 1],'units','normalized')
        %saveas(f,'newout','fig')
        
        correctName=strcat(name,'_',num2str(i),'_',num2str(j));
        currentFile=sprintf('%s',correctName);
     
        eval(['print(''-djpeg'','''  correctName  ''', ''-r0'')']);
        close; 
        end
    end
end
cd(pwd_back)

% GET THE NAMES OF ALL THE IMAGES IN THE FOLDER
file_list = getAllFiles([local_dir]);
%cell2csv('test.csv',human_labels,',',2001,'.')

% GENERATE The web locations for the csv files
% By appending the file name to the public folder adress.
for i = 1:length(file_list)
   file_list{i};
   slash_index = sort(find(file_list{i} == '/')); 
   slash_index = slash_index(end-1);
   turk_files{i} = [dropbox_public_folder file_list{i}(slash_index+1:end)]  ;
 end

turk_files{end} = []

% Generate the csv file for use by turk.
names_l = ['image_url'; turk_files'];       
cell2csv(csv_filename,names_l);


end

