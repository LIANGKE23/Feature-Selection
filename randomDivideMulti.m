    function [TrainMat, LabelTrain, TestMat, LabelTest]= randomDivideMulti(FeatureMat,LAB,TR_MAT,TS_MAT)
    
	% USAGE 
	%  FeatureMat	 = Feature Matrix with first column as the Labels
	% Label should be 1D e.g 0/1 or 1/2 and not 01/10 etc
	% TR_MAT 		= Number of subjects you want in Training set
	% TS_MAT 	= Number of subjects you want in Test set
	% LAB		= Class labels 
	% USAGE
	% e.g if you have 100 subjects and you want 21 in class I and 25 in class 2 in Training set 
	% and 20 in CLass I and 23 in CLass II in test set,  and your class labels are 0 and 1
	% then the code would lood like:
	%
	%  [TrainMat, LabelTrain, TestMat, LabelTest]= randomDivideMulti(FeatureMat,[0 1],[21 25],[20 23])
	%
	%If LAB is not specified, the Unique Labels are read from the first column of the Feature Matrix
	%
	%[TrainMat, LabelTrain, TestMat, LabelTest]= randomDivideMulti(FeatureMat,[0 1],[21 25],[20 23])
	%
	%If TR_MAT and TS_MAT is not specified the Data is divided equally into training and test set
	%
	%  [TrainMat, LabelTrain, TestMat, LabelTest]= randomDivideMulti(FeatureMat)
	
	
	% Code starts
	
    % Function to randomly select subjects
    %disp('Dividing Feature Matrix into Random Test and Training Matrix');

    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin<2,
         LAB=unique(FeatureMat(:,1));
         NUM_CLASS_CNT=getCount(FeatureMat(:,1));
         TR_MAT=ceil(NUM_CLASS_CNT/2);
         TS_MAT=NUM_CLASS_CNT-TR_MAT;
         % store the number of subjects required in training set
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin<3,
	NUM_CLASS_CNT=getCount(FeatureMat(:,1));
		TR_MAT=ceil(NUM_CLASS_CNT/2);
        TS_MAT=NUM_CLASS_CNT-TR_MAT;
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin<4,
        NUM_CLASS_CNT=getCount(FeatureMat(:,1));
        TS_MAT=NUM_CLASS_CNT-TR_MAT;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    % store the number of subjects required in test set    
    for cnt=1:length(LAB)
        numClassTr{cnt}.val=TR_MAT(cnt);
        numClassTs{cnt}.val=TS_MAT(cnt);
    end
    
   
    % store the labels of each class
    LabelMat=FeatureMat(:,1);

    % Store unique labels
    for cnt=1:length(LAB)
        Label{cnt}.val=LAB(cnt);
    end

   
    % generate the index for the labels
   IndexLabel=1:length(LabelMat);

    % store the index of each label
    for cnt=1:length(LAB)
        Label{cnt}.index=IndexLabel(LabelMat==Label{cnt}.val);
    end

    % randomly permute the indexes
    for cnt=1:length(LAB)
        Label{cnt}.indexVal=randperm(length(Label{cnt}.index));
    end


    % Store index for training set
    for cnt=1:length(LAB)
        Label{cnt}.Train=Label{cnt}.index(Label{cnt}.indexVal(1:numClassTr{cnt}.val));
    end

    % Store index for test set
    for cnt=1:length(LAB)
        Label{cnt}.Test=Label{cnt}.index(Label{cnt}.indexVal(numClassTr{cnt}.val+1:numClassTr{cnt}.val+numClassTs{cnt}.val));
    end

    TrainMat=[];
    TestMat=[];

    % Split into random Test and Train Matrix
    for cnt=1:length(LAB)
        TrainMat=[TrainMat; FeatureMat(Label{cnt}.Train,:)];
        TestMat=[TestMat; FeatureMat(Label{cnt}.Test,:)];
    end
    LabelTrain=TrainMat(:,1);
    LabelTest=TestMat(:,1);
    TrainMat=TrainMat(:,2:end);
    TestMat=TestMat(:,2:end);

  