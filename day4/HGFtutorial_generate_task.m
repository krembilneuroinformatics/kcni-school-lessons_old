function HGFtutorial_generate_task()

%% Generate Input
numberBlocks = 10;
probabilityStructure=[0.5,0.5,0.9,0.1,0.9,0.1,0.8,0.2,0.5,0.5];
nTrials = 21;
meanProb=[tapas_logit(probabilityStructure(1),1) tapas_logit(probabilityStructure(2),1)...
    tapas_logit(probabilityStructure(3),1),tapas_logit(probabilityStructure(4),1)...
    tapas_logit(probabilityStructure(5),1),tapas_logit(probabilityStructure(6),1)...
    tapas_logit(probabilityStructure(7),1),tapas_logit(probabilityStructure(8),1)...
    tapas_logit(probabilityStructure(9),1),tapas_logit(probabilityStructure(10),1)];
u = [];
for iStages=1:numberBlocks
    inputVector=gen_design_volatility(meanProb(iStages), nTrials - 1);
    u=[u;inputVector'];
end

%% Basic Implementations
% Get optimal parameters
bopars = tapas_fitModel([], u, 'tapas_hgf_binary_config', 'tapas_bayes_optimal_binary_config',...
                        'tapas_quasinewton_optim_config');
tapas_hgf_binary_plotTraj(bopars);
% Simulation
sim = tapas_simModel(u, 'tapas_hgf_binary', bopars.p_prc.p, 'tapas_unitsq_sgm', 5);
tapas_hgf_binary_plotTraj(sim);

% Inversion
est = tapas_fitModel(sim.y, sim.u, 'tapas_hgf_binary_config', 'tapas_unitsq_sgm_config', 'tapas_quasinewton_optim_config');
tapas_hgf_binary_plotTraj(est);
tapas_fit_plotCorr(est);
%% Add Volatility
new_input = [];
for iStages=1:numberBlocks
    inputVector=gen_design(meanProb(iStages), nTrials - 1);
    new_input=[new_input;inputVector'];
end

% Simulation
sim2 = tapas_simModel(new_input, 'tapas_hgf_binary', bopars.p_prc.p, 'tapas_unitsq_sgm', 5);
tapas_hgf_binary_plotTraj(sim2);

% Inversion
est2 = tapas_fitModel(sim2.y, sim2.u, 'tapas_hgf_binary_config', 'tapas_unitsq_sgm_config', 'tapas_quasinewton_optim_config');
tapas_hgf_binary_plotTraj(est2);
tapas_fit_plotCorr(est2);
