%% Images_to_spreadsheets.m
% COPYRIGHT: MOHAMMAD MAHDI GHASSEMI, MIT
% DESCRIPTION: THIS CODE CONVERTS IMAGES TO SPREASHEETS.
% INSTRUCTIONS: PLEASE SEE PAPER FOR FULL DETAIL:
% OUTPUTS: a <filename>_results.mat file that
[fList,pList] = matlab.codetools.requiredFilesAndProducts('Images_to_spreadsheets_Public_Release.m')

clear all;
%% PARAMTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DirectoryofJPG='/home/mohammad/Documents/IMAGES TO SPREADSHEETS/Test Images/Selection_033.png'
SaveName = DirectoryofJPG(max(strfind(DirectoryofJPG,'/'))+1:strfind(DirectoryofJPG,'.')-1)

% STEP 1 and 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
seg_len = 20;              % What size segments would you like to slice the image into? 20-40 is reccomended.
num_peaks = 4000;          % Durring the Hough Transform, how many peaks would you like to extract for clustering purposes? We reccomend 4000, but more is ok
ktimes = 100;              % The number of kmediods iterations used to identify a grid-line point in a segment.
kclust = 50;               % The number of kemdiods iterations used to identify the number of of rows and columns in the sheet.
pre_dilation  = 3;         % Turn this up if the gridlines are not getting connected, and down if things are touching that shouldn't be.
adap_threshold = 0.025;    % The threshold of the adaptive filter paramters
adap_size = 10;            % The size of the adaptive filter radius.
pre_blur = 1;              % The size of the gaussian filter radius

% STEP 3 PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mode = 0;                  % 1 = linear interpolation of the ends, 0 = flat.
angle = 10;                % used when finding candidate points, smaller is stricter.
k_start = 10;              % increase if lines are overlapping!
delta = 3;                 % parameter for final rows tuning

% STEP 4 PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
area_around_cell = 0.05;   % what percentage of the image outside the border would you like to include?

% STEP 5 PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noise_chunk_perc = .0025;  % adjust to remove noise higher removes larger chunks - .0025 reccome .005 for demo.
agression = 2;              % border removal algorithm, higher is less agressive - 2 reccomended, demo image:2.5
border = 5;                % The size of the black border around the image.
cell_dilation = 0;         % dilate the image in the cells - reccomended value = 0.
x_resize = 28;             % resize the digit-level images (x).
y_resize = 28;             % resize the digit-level images (y).
cellSize=[2,2];            % The cell size of the HoG features.

% STEP 6 PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
confidence_threshold = .95; % The confidence threshold to decide what the machine classifies
use_the_crowd = 0;          % 0 - Manually transcribe the images, 1- Let the crowd transcribe the images

% IMPORTANT ADDITIONAL INSTRUCTIONS FOR MECHANICAL TURK
%1. The use of this requires amazons aws-mturk-clt-1.3.1 library for Unix.
%   Please install this before beginning.
%2. You will need to log onto aws.amazon.com and get your key/secret key and
%   place them in the bin/mturk.properties file.
%3. To modify the experiment, please modify the files in
%   '.../aws-mturk-clt-1.3.1/samples/image_tagging'
%   Specifically, you will need to change
%A. image_tagging.properties
%B. image_tagging.inputs
%C. image_raging.question
%4. Lastly, you will need to create a bash file in the tools directory that
%   takes what's in dropbox, and generates the jobs.

%TURK PARAMTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resize_factor = 1;       % resize_factor - Resizes the images 1 means same size.
name = SaveName;         % What do you want the images that are saved to be called?

% Get your dropbox public folder adress: You can do this in the dropbox UI by clicking on a file and clicking get public URL.
dropbox_public_folder = ['https://dl.dropboxusercontent.com/u/81501921/']

% The directory of your dropbox 'Public' folder on your machine where you want to save the images
local_dir = '/home/mohammad/Dropbox (MIT)/Public/test';

% The location of the .input file in the AWS-MTURK-CLT-1.3.1 directory.
csv_filename = '/home/mohammad/Documents/aws-mturk-clt-1.3.1/samples/image_tagging/image_tagging.input'

% The location of the amazon tools directory for image tagging.
Amazon_tools_dir = '/home/mohammad/Documents/aws-mturk-clt-1.3.1/samples/image_tagging'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 1 AND 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRACT THE CANDIDATE POINTS FROM THE RAW IMAGE %%%%%%%%%%%%%%%%%%%%%%%%%
ExtractCells_1_find_rows_columns( DirectoryofJPG, SaveName, seg_len, num_peaks,ktimes,kclust,pre_dilation,adap_threshold,adap_size,pre_blur)
load([SaveName '.mat'])
imshow(I)

%% STEP 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ROW AND COLUMN LINES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
display = 1;               % 1 = show, 0 = don't show.
[ row_lines ] = getRowLinesv4( I, seg_len, row_c, estimated_rows, mode, angle, display, k_start )
[ col_lines ] = getColumnLinesv4( I, seg_len, col_c, estimated_columns,mode,angle,display,k_start )
%save([SaveName '.mat'])

%% STEP 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOW EXTRACT THE INTERSECTION BETWEEN ROW AND COLUMN LINES %%%%%%%%%%%%%%%
display = 1;            %INPUT:  display    - 1 = show, 0 = don't show.
[ intersections ] = FindIntersections( row_lines, col_lines,I,display );

% EXTRACT AND ARRAY OF IMAGES USING INTERSECTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ image_matrix ] = MakeImageMatrix( I_orig,intersections,area_around_cell);
PlotImageMatrix(image_matrix);

%% STEP 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CLEAN BORDERS AND NOISE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[image_matrix_clean has_stuff] = CleanBordersAndNoise( image_matrix, noise_chunk_perc,agression,border, cell_dilation);
figure;PlotImageMatrix(image_matrix_clean)

%  EXTRACT INDIVIDUAL DIGITS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ image_mat_digits ] = ExtractIndividualDigits( image_matrix_clean,has_stuff,border)

%Display the individual Digits
for i = 1:size(image_mat_digits,3)
    PlotImageMatrix(image_mat_digits(:,:,i))
    waitforbuttonpress;
end
imshow(image_mat_digits{1,5,1})

% RESIZE THE DIGITS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[resized_clean_image_mat] = ResizeImages2(image_mat_digits, has_stuff, x_resize, y_resize)
for i = 1:size(image_mat_digits,3)
    PlotImageMatrix(resized_clean_image_mat(:,:,i))
    waitforbuttonpress;
end

% TRAIN (OR LOAD) THE HOG CLASSIFIER. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check if you have already trained the HOG Classifier
if(~exist('hog_classifier.mat'))
    TrainDigitDetectors(cellSize);
elseif(exist('hog_classifier') == 1) %If it's in the workspace
    %Do nothing
else %If you have already trained, then just load it.
    load hog_classifier;
end

% ANNOTATE WITH THE MACHINE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pred_labels, conf] = ImageHOGEstimates( resized_clean_image_mat,has_stuff,hog_classifier, cellSize);
MarkedForMachine = ones(size(image_matrix,1),size(image_matrix,2));
[ mech_labels ] = MachineMergeTranscribed( pred_labels, MarkedForMachine)

%% STEP 6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPLIT THE JOB INTO HUMAN AND MACHINE TASKS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MarkedForHuman = sum((conf < confidence_thresh),3) >= 1;
MarkedForMachine = and((has_stuff == 1), (MarkedForHuman == 0))

%This matrix says that all images are marked for the Humans.
MarkedForHuman = ones(size(image_matrix,1),size(image_matrix,2));
MarkedForMachine = ones(size(image_matrix,1),size(image_matrix,2));

if use_the_crowd == 0
    %TRANSCRIBE THE IMAGES MANUALLY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load(['/home/mohammad/Documents/Images/Results/' SaveName '_human_labels.mat']);
        human_labels(strcmp(human_labels,'Nothing')) = {''}; %remove the NOTHINGS
        human_labels(strcmp(human_labels,'nothing')) = {''}; %remove the NOTHINGS
        human_labels(strcmp(human_labels,'NOTHING')) = {''}; %remove the NOTHINGS
        human_labels(cellfun(@isempty,human_labels))={''};
        human_labels = strrep(human_labels,' ','');      %remove the whitespace.
    if i==1
       human_labels = human_labels(1:2,1:5);
    end
else
    % GENERATE THE TURK IMAGES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PrepareImagesForTurk(image_matrix, 1, MarkedForHuman, name, dropbox_public_folder,local_dir,csv_filename)
    pause(60*60) %this allows the cell-level images to sync
    
    % SEND THE FILES TO TURK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    go_back = pwd; cd(Amazon_tools_dir)
    system('./run.sh')
    %system('./run_failures.sh')
    
    % WAIT UNTIL YOU GET THE RESULTS BACK FROM TURK.%%%%%%%%%%%%%%%%%%%%%%%%%%
    done = system('./getResults.sh')
    turk_annotations = import_turk_results('image_tagging.results');
    submitted = ~strcmp(turk_annotations.assignmentsubmittime, '""')
    while ( prod(submitted) == 0)
        done = system('./getResults.sh');
        turk_annotations = import_turk_results('image_tagging.results');
        submitted = ~strcmp(turk_annotations.assignmentsubmittime, '""')
        pause(60)
    end
    save turk_annotations turk_annotations
    
    
    % INTERPRET THE TURK ANNOTATIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    interpret_turk( turk_annotations, name );
    
    fid = fopen('test.csv', 'w') ;
    fprintf(fid, '%s,', human_labels{1,1:end-1}) ;
    fprintf(fid, '%s\n', human_labels{1,end}) ;
    fclose(fid) ;
    
    %Approve and delete the results.
    system('./approveAndDeleteResults.sh');
    cd(go_back)
end

%% STEP 7
%% SAVE AS TRAINING DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MERGE THE MANUAL AND THE AUTOMATIC TRANSCRIPTION RESULTS
result = nan*ones(size(image_matrix,1),size(image_matrix,2));
for i = 1:size(image_matrix,1)
    for j = 1:size(image_matrix,2)
        if(MarkedForHuman(i,j) == 1)
            result(i,j) = human_labels(i,j);
        end
        [ image_matrix ] = MakeImageMatrix( I_orig,intersections,error);
        if(MarkedForMachine(i,j) == 1)
            result(i,j) = mech_labels(i,j);
        end
    end
end

% DISPLAY THE RESULT WITH THE ORRIGINAL SPREADSHEET.
result
imshow(I_orig)


%CREATE TRAINING DATA FOR NEXT TIME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ind = 1;
td.bad_cell = zeros(size(human_labels,1),size(human_labels,2));
for i = 1:size(resized_clean_image_mat,1)
    for j = 1:size(resized_clean_image_mat,2)
        
        %ONLY IF THE HUMANS DID SOME ANNOTATION...
        if(~isempty(human_labels{i,j}))
            
            %AND ONLY IF THE NUMBER OF ENTRIES BY HUMANS AND MACHINES MATCH
            if(length(human_labels{i,j})*28 == size([resized_clean_image_mat{i,j,:}],2))
                
                %THEN TAKE EACH DIGIT, SAVE THE IMAGES IN THE TRAINING SET,
                %AND WRITE OUT THE GROUND TRUTH FROM THE HUMANS.
                for k = 1:size(resized_clean_image_mat,3)
                    if(~isempty(resized_clean_image_mat{i,j,k}))
                        td.training_data{ind} = resized_clean_image_mat{i,j,k};
                        td.ground_truth{ind} = human_labels{i,j}(k);
                        td.pred_labels{ind} = pred_labels{i,j,k};
                        td.conf{ind} = conf(i,j,k);
                        %imshow(training_data{ind})
                        %ground_truth{ind}
                        %waitforbuttonpress;
                        
                        ind = ind+1;
                    end
                end
            else
                td.bad_cell(i,j) = 1;
                
            end
        end
    end
end
td.mech_labels = mech_labels;
td.human_labels = human_labels;
td.confmat = conf;
save([SaveName '_results.mat'],'td')



