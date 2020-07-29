function forwardselected = forwardselection(TrainMat, LabelTrain, topfeatures)
%% input: TrainMat - a NxM matrix that contains the full list of features
%% of training data. N is the number of training samples and M is the
%% dimension of the feature. So each row of this matrix is the face
%% features of a single person.
%%        LabelTrain - a Nx1 vector of the class labels of training data
%%        topfeatures - a Kx2 matrix that contains the information of the
%% top 1% features of the highest variance ratio. K is the number of
%% selected feature (K = ceil(M*0.01)). The first column of this matrix is
%% the index of the selected features in the original feature list. So the
%% range of topfeatures(:,1) is between 1 and M. The second column of this
%% matrix is the variance ratio of the selected features.

%% output: forwardselected - a Px1 vector that contains the index of the 
%% selected features in the original feature list, where P is the number of
%% selected features. The range of forwardselected is between 1 and M. 
%% Initial
% number of features
[m,~] = size(topfeatures);
numtopfeatures = m;
% set an empty set
Y_value = [];
Y_index = [];
% Y = [nan,nan];
% set stopping conditions
Temprate = 0;
mark = [];
desirablerate = 0.98;
for i1 = 1:numtopfeatures %% for the num of features is less than the total features
% get sensitivity as the evluation critial
    evaluationcritial = double(zeros(numtopfeatures,1));
    count = 0;
    while(1)
        count = count + 1;
        if count > numtopfeatures
            break;
        end
        %data for classifier
        usedata = TrainMat(:,topfeatures(count,1));
        usedataall = double([Y_value,usedata]);
        MdlLinear = fitcdiscr(usedataall,LabelTrain); 
        train_pred = predict(MdlLinear,usedataall);
        %use classperf inbuild function to get the sensitivity
        evaluationcritial(count,1) = double(classperf(LabelTrain, train_pred).Sensitivity);
    end
    % get the best subset based on the classification accuracy
    [value,index] = max(evaluationcritial(:,1));
    % update checking stopping conditions
    if value < Temprate
        mark = [];
        break;
    elseif value == Temprate
        usedata_new = TrainMat(:,topfeatures(index,1));
        Y_value = double([Y_value,usedata_new]);
        Y_index = double([Y_index,topfeatures(index,1)]);
        if Temprate >= desirablerate
            break;
        end
        mark = [mark 1];
        if size(mark,1) >= 3
            break;
        end
        Temprate = value;  
    elseif value > Temprate  
        usedata_new = TrainMat(:,topfeatures(index,1));
        Y_value = double([Y_value,usedata_new]);
        Y_index = double([Y_index,topfeatures(index,1)]);        
        mark = [];
        if Temprate >= desirablerate
            break;
        end
        Temprate = value;
    end
end
forwardselected = Y_index;
end