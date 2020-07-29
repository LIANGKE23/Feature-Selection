function topfeatures = rankingfeat(TrainMat, LabelTrain, VRorAVR, toppercentage)
%% input: TrainMat - a NxM matrix that contains the full list of features
%% of training data. N is the number of training samples and M is the
%% dimension of the feature. So each row of this matrix is the face
%% features of a single person.
%%        LabelTrain - a Nx1 vector of the class labels of training data

%% output: topfeatures - a Kx2 matrix that contains the information of the
%% top 1% features of the highest variance ratio. K is the number of
%% selected feature (K = ceil(M*0.01)). The first column of this matrix is
%% the index of the selected features in the original feature list. So the
%% range of topfeatures(:,1) is between 1 and M. The second column of this
%% matrix is the variance ratio of the selected features.

%% Initial
% get NxM for TrainMat
[n,m] = size(TrainMat);
samplepoints = n;
numoffeatures = m;
% get number of Class
numofclasses = length(countcats(categorical(LabelTrain)));
% get name of class
Labels = unique(LabelTrain);
% initial the Variance ratio 
VR = double(zeros(numoffeatures,1));
AVR = double(zeros(numoffeatures,1));
% initial K
K = ceil(numoffeatures * toppercentage);
% initial topfeatures
topfeatures = double(zeros(K, 2));
% initial var for each class
Var_k = double(zeros(numofclasses, 1));
if VRorAVR == 2
    % initial mean for each class
    Mean_k = double(zeros(numofclasses, 1));
    % saving |meani|-|meanj|
    mean_ij = double(zeros(numofclasses, numofclasses));
    for lk = 1:numofclasses
        for lxy = 1:numofclasses
            mean_ij(lk,lxy) = inf;
        end
    end
    % saving min |meani|-|meanj| for i
    mean_i = double(zeros(numofclasses, 1));
    USEFUL = double(zeros(numofclasses, 1));
end
%% get VR of features
%% VR(F) =Var(Sf)/(1/C*sum(Var_k(Sf)))
%% AVR(F) =Var(Sf)/(1/C*sum(Var_k(Sf)/mean_i(Sf)))
for i = 1:numoffeatures
    % get Var(Sf)
    Var_Sf = var(TrainMat(:,i));
    for j1 = 1:numofclasses
        Sf = double(TrainMat(:,i));
        Sf_for_class = Sf(Labels(j1) == LabelTrain,:);
        Var_k(j1) = var(Sf_for_class);
        if VRorAVR == 2
            Mean_k(j1) = mean(Sf_for_class);
        end
    end
    if VRorAVR == 1
        VR(i) = Var_Sf / (sum(Var_k)/numofclasses);
    elseif VRorAVR == 2
        for j2 = 1:numofclasses
            for j3 = 1:numofclasses
                if j2 ~= j3
                    mean_ij(j2,j3) = (abs(Mean_k(j2)-Mean_k(j3)));
                end
            end
            mean_i(j2) = min(mean_ij(j2,:));
        end
        for j4 = 1:numofclasses
            USEFUL(j4) = Var_k(j4)/mean_i(j4);
        end
        AVR(i) = Var_Sf / (sum(USEFUL)/numofclasses);
    end
end
%% Get top 1%

if VRorAVR == 1
    [VR_value, VR_index] = sort(VR, 'descend');
    [idx, ~] = find(isnan(VR_value));
    VR_value(idx,:) = [];
    VR_index(idx,:) = [];    
    topfeatures(:,1) = VR_index(1:K);
    topfeatures(:,2) = VR_value(1:K);
elseif VRorAVR == 2
    [AVR_value, AVR_index] = sort(AVR, 'descend');
    [idx, ~] = find(isnan(AVR_value));
    AVR_value(idx,:) = [];
    AVR_index(idx,:) = [];
    topfeatures(:,1) = AVR_index(1:K);
    topfeatures(:,2) = AVR_value(1:K);
end
end

        
        
        
    
