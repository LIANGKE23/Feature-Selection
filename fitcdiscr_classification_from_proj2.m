function [train_ConfMat,train_ClassMat,train_acc,train_std,test_ConfMat,test_ClassMat,test_acc,test_std] = fitcdiscr_classification_from_proj2(TrainMat,TestMat,LabelTrain,LabelTest,forwardselected)
    LabelTrain = categorical(LabelTrain);
    LabelTest = categorical(LabelTest);

    train_featureVector = TrainMat(:,forwardselected);
    test_featureVector = TestMat(:,forwardselected);
    MdlLinear_train = fitcdiscr(train_featureVector,LabelTrain);
    MdlLinear_test = fitcdiscr(test_featureVector,LabelTest);
    train_pred = predict(MdlLinear_train,train_featureVector);
    test_pred = predict(MdlLinear_test,test_featureVector);

    train_ConfMat = confusionmat(LabelTrain,train_pred);
    train_ClassMat = train_ConfMat./(meshgrid(countcats(LabelTrain))');
    train_acc = mean(diag(train_ClassMat));
    train_std = std(diag(train_ClassMat));
    
    test_ConfMat = confusionmat(LabelTest,test_pred);
    test_ClassMat = test_ConfMat./(meshgrid(countcats(LabelTest))');
    test_acc = mean(diag(test_ClassMat));
    test_std = std(diag(test_ClassMat));
end

