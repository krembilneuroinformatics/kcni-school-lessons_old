path_toolbox='/Users/drea/Documents/MATLAB/tapas_v3/HGF'; %% Modify to the path of the HGF Toolbox
addpath(genpath(path_toolbox));

numberBlocks = 10;
probabilityAdvice = [0.8,0.8,0.10,0.90,0.5,0.10,0.90,0.50,0.8,0.8];
nTrials = 21;
meanProb=[tapas_logit(probabilityAdvice(1),1) tapas_logit(probabilityAdvice(2),1)...
    tapas_logit(probabilityAdvice(3),1),tapas_logit(probabilityAdvice(4),1)...
    tapas_logit(probabilityAdvice(5),1),tapas_logit(probabilityAdvice(6),1)...
    tapas_logit(probabilityAdvice(7),1),tapas_logit(probabilityAdvice(8),1)...
    tapas_logit(probabilityAdvice(9),1),tapas_logit(probabilityAdvice(10),1)];
u = [];
for iStages=1:numberBlocks
    inputVector=gen_design(meanProb(iStages), nTrials - 1);
    u=[u;inputVector'];
end

%% Simulate Learner
% sim_Learner(u,'omega_3rdlevel',1);

%% Psychosis
% Simulate HGF with Delusional Belief (cf. Models of Schizophrenia)
% on/off
[predictionsDelusion,volatilityDelusion] = sim_Learner(u,'phi_2ndlevel_biasedPrior',2);
% [predictionsDelusion,volatilityDelusion] = sim_Learner(u,'omega_2ndlevel',1);

%
% % Simulate HGF with Growing Uncertainty (cf. Models of Prodromal
% % Psychosis)
% [predictionsProdromal,volatilityProdromal] = sim_Learner(u,'m_3rdlevel',2);
[predictionsProdromal,volatilityProdromal] = sim_Learner(u,'omega_3rdlevel',1);

colourBlobArray = {'-b',  '-r'};
probs    =[ones(nTrials,1).*probabilityAdvice(1);ones(nTrials,1).*probabilityAdvice(2);...
    ones(nTrials,1).*probabilityAdvice(3);ones(nTrials,1).*probabilityAdvice(4);...
    ones(nTrials,1).*probabilityAdvice(5); ones(nTrials,1).*probabilityAdvice(6);...
    ones(nTrials,1).*probabilityAdvice(7); ones(nTrials,1).*probabilityAdvice(8);...
    ones(nTrials,1).*probabilityAdvice(9);ones(nTrials,1).*probabilityAdvice(10)];
trialNumber = size(probs);
tWindow  = 0:trialNumber-1;




meanPredictionsDelusion    = mean(cell2mat(predictionsDelusion),2);
stdPredictionsDelusion     = std(cell2mat(predictionsDelusion),0,2);

meanVolatilityDelusion    = mean(cell2mat(volatilityDelusion),2);
stdVolatilityDelusion     = std(cell2mat(volatilityDelusion),0,2);

meanPredictionsProdromal    = mean(cell2mat(predictionsProdromal),2);
stdPredictionsProdromal     = std(cell2mat(predictionsProdromal),0,2);

meanVolatilityProdromal    = mean(cell2mat(volatilityProdromal),2);
stdVolatilityProdromal     = std(cell2mat(volatilityProdromal),0,2);

figure; 

subplot(2,2,1)
tnueeg_line_with_shaded_errorbar(tWindow, meanVolatilityProdromal,stdVolatilityProdromal, colourBlobArray{1},1);
subplot(2,2,2)
tnueeg_line_with_shaded_errorbar(tWindow, meanVolatilityDelusion,stdVolatilityDelusion, colourBlobArray{1},1);



subplot(2,2,3)
plot(0:trialNumber-1,probs,'Color',[0.5 0.5 0.5], 'LineWidth', 2);
hold on;
tnueeg_line_with_shaded_errorbar(tWindow, meanPredictionsProdromal,stdPredictionsProdromal, colourBlobArray{2},1);

subplot(2,2,4)
plot(0:trialNumber-1,probs,'Color',[0.5 0.5 0.5], 'LineWidth', 2);
hold on;
tnueeg_line_with_shaded_errorbar(tWindow, meanPredictionsDelusion,stdPredictionsDelusion, colourBlobArray{2},1);






