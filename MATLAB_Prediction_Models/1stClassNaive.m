close all;
clear all;
clc;

InputDataRemnant=xlsread('All_Class.xlsx','Sheet1');
InputFeatures=InputDataRemnant(:,3:end);% Features
InputClass=InputDataRemnant(:,2);  %Class
InputClass(InputClass==0)=5;
InputClass(InputClass==1)=0;
InputClass(InputClass==2)=0;
InputClass(InputClass==3)=0;
InputClass(InputClass==5)=1;
NoF=0;
ValMethod='CV';FeatMethod='pValue';
FreqFeatMethod='N';
Classifier='Naive';
k=41;%LOO
%% Removing Correlated Features
[p,h]=pValueCalculation(InputClass,InputFeatures);
[val,ind]=sort(p);SortedInputFeatures=InputFeatures(:,ind);
sel_featCorr = RemoveCorrFeatDiff_Type(SortedInputFeatures, 0.90);
InputFeatFinal=SortedInputFeatures(:,sel_featCorr);
for ft=2:2  
    outFile=strcat('Results_ELMvsAllLoo',num2str(ft),'_',ValMethod,FeatMethod,Classifier,datestr(now,'mm-dd-yyyy HH-MM-SS'),'.xlsx');
for iter=1:1
    TrTsPerf=[];
    SaveTsIdx=[];
    SaveTrIdx=[];    
    %% Validation Method
    ct=1;
    switch(ValMethod)
        case 'CV'
            PartIdx= DataPartition(InputFeatures, InputClass, iter,ValMethod, k);
             original_classes=[];
             discrimVal=[]; 
            SelFeatList=zeros(k,length(InputFeatures));
            TrTsPerf=[];
            SaveTsIdx=[];
            SaveTrIdx=[];
            for fold=1:k
                fold
                TrIdx=PartIdx.training(fold);
                TsIdx=PartIdx.test(fold);
                Trclasses=InputClass(TrIdx,:);
                Trfeat=InputFeatFinal(TrIdx,:);
                Tsclasses=InputClass(TsIdx,:);
                Tsfeat=InputFeatFinal(TsIdx,:);
                %sel_feat=FeatSelect(Trclasses,Trfeat,FeatMethod,Classifier);
                TsfeatPres=find(~isnan(Tsfeat));
                sel_feat1=TsfeatPres(1:min(ft,length(TsfeatPres)));                
                Trfeats=Trfeat(:,sel_feat1);Tsfeats=Tsfeat(:,sel_feat1);
                nan_find=sum(isnan(Tsfeats),2);
                Tsclasses(nan_find==(min(length(sel_feat1),length(sel_feat1))),:)=[];
                Tsfeats(nan_find==(min(length(sel_feat1),length(sel_feat1))),:)=[];
                Model=LearningData(Trfeats,Trclasses,Classifier); 
                TrScore=TestData(Model,Trfeats,Classifier);
                if ~isempty(Tsfeats)
                TsScore=TestData(Model,Tsfeats,Classifier); 
                [~,~,~,TrAUC,~,~,~] = perfcurve(Trclasses,TrScore,1);
                TrTsPerf=[TrTsPerf;[iter fold TrAUC 1]];
                original_classes(ct:ct+length(Tsclasses)-1)=Tsclasses;
                discrimVal(ct:ct+length(Tsclasses)-1)=TsScore; 
                SelFeatList(fold,1:length(sel_featCorr(sel_feat1)))=ind(sel_featCorr(sel_feat1));
                ct=ct+length(Tsclasses);
                SaveTsIdx=[SaveTsIdx; iter fold find(TsIdx==1)];
                SaveTrIdx=[SaveTrIdx; iter fold TrIdx'];
                end
                clear TrIdx TsIdx Trfeat Tsfeat Trfeats Tsfeats Model TsScore
                close all;
            end            
           [FPF,TPF,~,Az,~,~,~] = perfcurve(original_classes,discrimVal,1); 
           [fin_sort,sorted_ind]=sort(SaveTsIdx(:,3));sorted_prob=discrimVal(sorted_ind)';
           Store_data=99*ones(41,4);
           Store_data(:,1)=1:41;
           Store_data(fin_sort,2)=fin_sort;
           Store_data(fin_sort,3)=sorted_prob;
           Store_data(fin_sort,4)=sorted_prob>=0.5;
           %[EvalMetricYouden,EvalMetricHalf,EvalMetricMaxSensSpec,EvalMetricMaxPVNV,EvalMetricMaxAll,EvalMetricMaxPPV,EvalMetricMaxNPV,EvalMetricMaxSen,EvalMetricMaxSpec]= ClassifierPerformanecEvaluation(discrimVal,original_classes,discrimVal,original_classes,1);
%             h=figure();
%             plot(FPF,TPF,'r','linewidth',2);hold on;               
    end       
end
end

