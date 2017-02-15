%% DIGIT FINDER USING HOG
function [] = TrainDigitDetectors(cellSize)
[trainingSet,trainLabels,testSet,testLabels] = readMNIST(60000);

%For the HoG features.
%cellSize = [2 2];

%% ADJUST IMAGE ORIENTATION

%TRAINING SET
for i = 1:length(trainingSet)
    trainingSet{i} = flipdim((rot90(trainingSet{i},3)),2);
end
%TESTING SET
for i = 1:length(testSet)
    testSet{i} = flipdim((rot90(testSet{i},3)),2);
end

%% FEATURE EXTRACTION

% GET THE TRAINING FEATURES
parfor i = 1:length(trainingSet)%numel(trainingSet)
    img = trainingSet{i};
    lvl = graythresh(img);
    img = im2bw(img, lvl);
    trainFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
end

% GET THE TESTING FEATURES
parfor i = 1:length(testSet)%numel(trainingSet)
    img = testSet{i};
    lvl = graythresh(img);
    img = im2bw(img, lvl);
    testFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
end

%% FIT THE SVM MOT USING HOG.
hog_classifier_dec = fitcecoc(trainFeatures,...
                            trainLabels,...
                            'FitPosterior',1,...
                            'Verbose',2);
                                          
[predictedLabels, ~, ~, posteriorRegion] = predict(hog_classifier_dec, testFeatures);
[confidence,ind] = max(posteriorRegion')

%Sanity Check
mean((ind - 1) == predictedLabels')


%% SHOW THE PERFORMANCE RESULTS IN A CONFUSION MATRIX.
confMat = confusionmat(testLabels, predictedLabels);
helperDisplayConfusionMatrix(confMat)

save hog_classifier hog_classifier;    

end

