%Your Details: (The below details should be included in every matlab script
%file that you create)
%{
    Name:Ke LIANG
    PSU Email ID:kul660@psu.edu
    Description: Face and EEG Feature Selection.
%}
clear all;
close all;
clc;

Whichdataset = inputdlg('Choose dataset you need (choices 1 for face, 2 for EEG):');
whichdataset = str2num(cell2mat(Whichdataset));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% load the data
if whichdataset == 1
    FeatureMatOD=dlmread('data/ODFeatureMat.txt');
    FeatureMatHD=dlmread('data/HDFeatureMat.txt');
    FeatureMat=[FeatureMatOD FeatureMatHD(:,2:end)];
    clear FeatureMatHD;
    clear FeatureMatOD;
elseif whichdataset == 2
    load('eeg_data.mat')
%     a = double(zeros(1,49920));
    index = find(all(eeg_data==0,2));
    b = eeg_data;
%     c = setdiff(eeg_data, a, 'rows');
    b(index,:) = [];
    d = labels;
    d(index,:) = [];
    eeg_data = b;
    labels = d;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if whichdataset == 1
    feature_names = double(zeros(1,1));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%the flow of your code should look like this
if whichdataset == 1
    Dim = size(FeatureMat,2)-1; %dimension of the feature
    countfeat(Dim,2) = 0;
elseif whichdataset == 2
    Dim = size(eeg_data,2)-1; %dimension of the feature
    countfeat(Dim,2) = 0;
    %%countfeat is a Mx2 matrix that keeps track of how many times a feature has been selected, where M is the dimension of the original feature space.
    %%The first column of this matrix records how many times a feature has ranked within top 1% during 100 times of feature ranking.
    %%The second column of this matrix records how many times a feature was selected by forward feature selection during 100 times.
end

%%%%%%%%%%%%%%%%%%%% test code %%%%%
%comment this out 
% tmp = randperm(Dim);
% topfeatures(:,1) = tmp(1:1000)';
% topfeatures(:,2) = 100*rand(1000,1);
% forwardselected = tmp(1:100)';
%%%%%%%%%%%%%%%%%%%%%%%%************
vroravr = inputdlg('Choose whether VR or AVR (choices 1 for VR, 2 for AVR):');
VRorAVR = str2num(cell2mat(vroravr));
Timesforevaluation = inputdlg('Choose times you want for evaluate the performance (from 1 to 100):');
Times = str2num(cell2mat(Timesforevaluation));
Toppercentage = inputdlg('Choose top percentage you want for evaluate the performance (from 0 to 1 (0.01 represents 1%; 0.1 represents 10%)):');
toppercentage = str2num(cell2mat(Toppercentage));
trainConfMat = {};
trainClassMat = {};
trainacc = {};
trainstd = {};
testConfMat = {};
testClassMat = {};
testacc = {};
teststd = {};
for i=1:Times
    fprintf("%d\n",i);
    
    % randomly divide into equal test and traing sets
    if whichdataset == 1
        [TrainMat, LabelTrain, TestMat, LabelTest]= randomDivideMulti(FeatureMat);
    elseif whichdataset == 2
        [TrainMat, LabelTrain, TestMat, LabelTest]= randomDivideMulti([labels,eeg_data]);
    end
    
    % start feature ranking
    topfeatures = rankingfeat(TrainMat, LabelTrain, VRorAVR, toppercentage); 
    countfeat(topfeatures(:,1),1) =  countfeat(topfeatures(:,1),1) +1;
    
    %% visualize the variance ratio of the top 1% features
    if i==1
        %% colorbar indicates the correspondance between the variance ratio
        %% of the selected feature
         plotFeat(topfeatures,feature_names,20,whichdataset);
    end

    % start forward feature selection %choose fitcdiscr
    forwardselected = forwardselection(TrainMat, LabelTrain, topfeatures);
    countfeat(forwardselected,2) =  countfeat(forwardselected,2) +1;    
    
    % start classification chooses 
    [train_ConfMat,train_ClassMat,train_acc,train_std,test_ConfMat,test_ClassMat,test_acc,test_std] = fitcdiscr_classification_from_proj2(TrainMat,TestMat,LabelTrain,LabelTest,forwardselected);
    trainConfMat{i} = train_ConfMat;
    trainClassMat{i} = train_ClassMat;
    trainacc{i} = train_acc;
    trainstd{i} = train_std;
    testConfMat{i} = test_ConfMat;
    testClassMat{i} = test_ClassMat;
    testacc{i} = test_acc;
    teststd{i} = train_std;
end
trainConfMat_ave = getaverage(trainConfMat,Times)
trainClassMat_ave = getaverage(trainClassMat,Times)
trainacc_ave = getaverage(trainacc,Times)
trainstd_ave = getaverage(trainstd,Times)
testConfMat_ave = getaverage(testConfMat,Times)
testClassMat_ave = getaverage(testClassMat,Times)
testacc_ave = getaverage(testacc,Times)
teststd_ave = getaverage(teststd,Times)
%% visualize the features that have ranked within top 1% most during 100 times of feature ranking
data(:,1)=[1:Dim]';
data(:,2) = countfeat(:,1);
%% colorbar indicates the number of times a feature at that location was
%% ranked within top 1%
    plotFeat(data,feature_names,20,whichdataset);
%% visualize the features that have been selected most during 100 times of
%% forward selection
data(:,2) = countfeat(:,2);
%% colorbar indicates the number of times a feature at that location was
%% selected by forward selection
    plotFeat(data,feature_names,20,whichdataset);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plotting the histogram
[count, index] = sort(countfeat(:,2), 'descend');
[idx, ~] = find(count ~= 0);
count = count(idx,1);
figure;
xlabel('Feature number');
ylabel('Histogram');
bar(categorical(index(1:ceil(length(count) * 0.1))), count(1:ceil(length(count) * 0.1)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: You don't need this step for classification. This is just for the inquisitive minds who want to see how the features actually look like.
% Suppose you want to visualize 5th subject in the Test set. The following code shows how the feature of the 5'th subject would look like:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % uncomment to visualize the features
% FeatureMat=dlmread('data/HDFeatureMat.txt');
% k=reshape(TrainMat(5,:),[125 62]);
% imagesc(flipud([k fliplr(k)]));
% COLORBAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
