function g=TestData(Model,Tsfeat,classifier)
 
if strcmp(classifier,'LogIt')==1
 scores=mnrval(Model,Tsfeat);  
 g=scores(:,2);
elseif strcmp(classifier,'TreeEnsemble')==1% 
    for i=1:size(Tsfeat,2)
       [output,scores] = predict(Model{i},Tsfeat(:,i));
       Final_scores(:,i)=scores(:,2);
    end
g=nanmedian(Final_scores,2);
else
[output,scores] = predict(Model,Tsfeat);
g=scores(:,2);
end

