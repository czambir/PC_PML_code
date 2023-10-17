function Model=LearningData(Trfeat,Trclasses,classifier_name,MnLf,NoV)

Pcas=sum(Trclasses==1);Ncas=sum(Trclasses~=1);
for ii=1:size(Trfeat,2)
    dicotomize_feat=unique(Trfeat(:,ii));dicotomize_feat(isnan(dicotomize_feat))=[];
    IsDist(ii)=length(dicotomize_feat)<5;
end
switch classifier_name         %% classification
    case 'Naive'
        Model = fitcnb(Trfeat,Trclasses,'CategoricalPredictors',IsDist,'Cost',[0 1;Ncas/Pcas 0]);%Naive-bayes
    case 'NaiveU'
        Model = fitcnb(Trfeat,Trclasses,'CategoricalPredictors',IsDist,'Cost',[0 1;Ncas/Pcas 0], 'Prior', 'uniform');%Naive-bayes        
        
    case 'FLDA'
        Model= fitcdiscr(Trfeat,Trclasses); % FLDA
    case 'ANN'
        Model=ANN_classifier(other_values,other_classes,current_values); % ANN
    case 'SVM'
        Model = fitcsvm(Trfeat,Trclasses,'Standardize',true,'Cost',[0 1;Ncas/Pcas 0],'OutlierFraction',0.1,'KernelFunction','RBF'); % SVM 'KernelFunction','polynomial','PolynomialOrder',2,
    case 'RF'
       Ntree=100;cost_FN=1;MnLf=16;NoV=2;
     %   Model= TreeBagger(Ntree,Trfeat,num2str(Trclasses),'MinLeaf',MnLf,'Cost',[0 1;Ncas/Pcas 0],'OOBPrediction','on','NVarToSample',3);%,'NVarToSample',10
       Model= TreeBagger(Ntree,Trfeat,num2str(Trclasses),'MinLeaf',MnLf,'NVarToSample',NoV,'Cost',[0 1;Ncas/Pcas 0]);%,'NVarToSample',10
     case 'AdaBoostM1'
        min_loss=1;
        for i=25:25:500
            for j=1:4:30
                    NLearn=i;cost_FN=1;MnLf=j;
                     template = templateTree('MinLeaf',MnLf,'SplitCriterion','gdi','prune','off','MergeLeaves','on');
                     Model=fitensemble(Trfeat,Trclasses,'AdaBoostM1',NLearn,template,'Cost',[0 1;cost_FN 0],'CrossVal','On');
                     LossValue=kfoldLoss(Model);
                    if LossValue<min_loss
                       min_loss=LossValue;
                       store_param(1,1)=i;store_param(1,2)=j;store_param(1,3)=min_loss;
                    end
            end
        end 
        template = templateTree('MinLeaf',store_param(1,2),'SplitCriterion','gdi','prune','off','MergeLeaves','on');
        Model=fitensemble(Trfeat,Trclasses,'AdaBoostM1',store_param(1,1),template,'Cost',[0 1;cost_FN 0]);
                 
       
           case 'Tree'
    %    Model = fitctree(Trfeat,Trclasses,'Surrogate','on','CategoricalPredictors',IsDist,'Cost',[0 1;Ncas/Pcas 0],'Prior','Uniform');
        Model = fitctree(Trfeat,Trclasses,'Surrogate','on','CategoricalPredictors',IsDist,'Prior','Uniform');
  
    case 'LogIt'
        Model=mnrfit(Trfeat,(Trclasses+1));
        
    case 'TreeEnsemble'
        for feat=1:size(Trfeat,2)
        Dum_Model=fitctree(Trfeat(:,feat),Trclasses,'Surrogate','on');
        Model{feat}=Dum_Model;
        end
end
