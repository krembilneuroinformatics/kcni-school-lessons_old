function [predictions, volatility] = sim_Learner(iInput,iParameter,iModel,plotPE)
pathroot= fileparts(mfilename('fullpath')); %%% CHANGE;
savepath = [pathroot '/sim_results/'];
rp_model= {'softmax_social'}; %%Change

if nargin < 1
    iInput=load('inputs_volatility_hiprobs.txt');
end

if nargin < 2
    iParameter = 'omega_2ndlevel';
end
if nargin < 3
    iModel = 1;
end
if nargin < 4
    plotPE=false;
end

plotmu2hat=false;
probabilityAdvice = [0.8,0.8,0.10,0.90,0.5,0.10,0.90,0.50,0.8,0.8];
nTrials = 21;
if iModel == 1
    switch iParameter
        case 'omega_2ndlevel'
            parArray=[-10.5:0.5:-6.5];
            mu2_0=tapas_logit(0.45,1); % initial value of x1 (it is now 0.5).
            rho_2=-0.01;
            rho_3=0;
        case 'omega_3rdlevel'
            parArray=[-6.5:0.25:-2.5];
            mu2_0=tapas_logit(0.5,1); % initial value of x1 (it is now 0.5).
            rho_2=0;
            rho_3=0;
    end
else
    switch iParameter
        case 'm_3rdlevel'
            mu3_0=1;
            parArray=[mu3_0:0.11:1.66];
            mu2_0=tapas_logit(0.5,1); % initial value of x1 (it is now 0.5).
            om=[-6.5:0.5:-3.5]; % omega
        case 'phi_2ndlevel_biasedPrior'
            mu2_0=tapas_logit(0.5,1); % initial value of x1 (it is now 0.2);
            parArray=[tapas_sgm(-5,1):0.05:tapas_sgm(-1,1)]; % varying phi
            m_2ndlevel=tapas_logit(0.4,1);
            om=-6; % omega
    end
end



% Define parameters that do not change

kappa=1;
ze=exp(0.5);
beta=log(48);

if iModel == 1
    prc_model= {'tapas_hgf_binary'};
    
else
    prc_model= {'tapas_hgf_ar1_binary'};
    phi_2=tapas_sgm(-1.1972,1);
    phi_3=tapas_sgm(-2.1972,1); % Fixed to its prior
end

prob = load('SIBAK_Inputs.txt');
cue=prob(:,2);

P=numel(parArray);
if iModel ==1
    p_prc=zeros(P,14);
    for m=1:numel(rp_model)
        for i=1:numel(prc_model)
            fh = [];
            sh = [];
            lgh_a = NaN(1,P);
            lgstr = cell(1,P);
            for par=1:P
                final_input_u=iInput;
                switch iParameter
                    case 'omega_3rdlevel'
                        omega_3rdlevel=parArray(par);
                        p_prc=[NaN, mu2_0, 1, NaN, 1,0.1,...
                            NaN, rho_2, rho_3, ...
                            NaN, kappa, NaN, -3, omega_3rdlevel];
                        lgstr{par} = sprintf('\\omega_3 = %3.2f', omega_3rdlevel);
                    case 'omega_2ndlevel'
                        omega_2ndlevel=parArray(par);
                        p_prc=[NaN, mu2_0, 1, NaN, 1,0.1,...
                            NaN, rho_2, rho_3, ...
                            NaN, kappa, NaN, omega_2ndlevel, -4];
                        lgstr{par} = sprintf('\\omega_2 = %3.2f', omega_2ndlevel);
                end
                
                
                sim = tapas_simModel([final_input_u cue(1:size(final_input_u),:)], prc_model{i}, p_prc, rp_model{m}, [ze beta]);
                colors=jet(P);
                currCol = colors(par,:);
                mu1hat = sim.traj.muhat(:,1);
                mu3hat = sim.traj.muhat(:,3);
                predictions{par} = mu1hat;
                volatility{par} = mu3hat;
                
                [fh, sh, lgh_a(par)] = hgf_plot_rainbowsim(par, fh, sh);
                
            end
            legend(lgh_a,lgstr);
        end
    end
else
    p_prc=zeros(P,17);
    for m=1:numel(rp_model)
        for i=1:numel(prc_model)
            fh = [];
            sh = [];
            lgh_a = NaN(1,P);
            lgstr = cell(1,P);
            for par=1:P
                
                final_input_u=iInput;
                
                switch iParameter
                    case 'm_3rdlevel'
                        m_3rdlevel=parArray(par);
                        p_prc=[NaN, mu2_0, 1,NaN, 1,0.1,...
                            NaN, phi_2, phi_3, NaN, 0, m_3rdlevel,...
                            NaN, kappa, NaN, -2, -3];
                        lgstr{par} = sprintf('m_3 = %3.1f', m_3rdlevel);
                    case 'phi_2ndlevel_biasedPrior'
                        phi_2ndlevel=parArray(par);
                        p_prc=[NaN, mu2_0, 1,NaN, 1,0.1,...
                            NaN, phi_2ndlevel, phi_3, NaN, m_2ndlevel, 2,...
                            NaN, kappa, NaN, om, -6];
                        lgstr{par} = sprintf('\\phi_2 = %3.1f', phi_2ndlevel);
                end
                sim = tapas_simModel([final_input_u cue(1:size(final_input_u),:)], prc_model{i}, p_prc, rp_model{m}, [ze beta]);
                colors=jet(P);
                currCol = colors(par,:);
                mu1hat = sim.traj.muhat(:,1);
                mu3hat = sim.traj.muhat(:,3);
                predictions{par} = mu1hat;
                volatility{par} = mu3hat;
                
                [fh, sh, lgh_a(par)] = hgf_plot_rainbowsim(par, fh, sh);
                
            end
            legend(lgh_a,lgstr);
        end
    end
end

%% PLot
    function [fh, sh, lgh_a] = hgf_plot_rainbowsim(par, fh, sh)
        currCol = colors(par,:);
        if isempty(fh)
            % Set up display
            scrsz = get(0,'screenSize');
            outerpos = [0.2*scrsz(3),0.2*scrsz(4),0.8*scrsz(3),0.8*scrsz(4)];
            
            fh = figure(...
                'OuterPosition', outerpos,...
                'Name','HGF binary fit results');
            % set(gcf,'DefaultAxesColorOrder',colors);
            sh(1) = subplot(2,1,1);
            sh(2) = subplot(2,1,2);
            % sh(3) = subplot(3,1,3);
        else
            figure(fh);
        end
        % Number of trials
        t = size(sim.u,1);
        
        
        % Subplots
        axes(sh(1))
        
        
        % Volatility (x_3)
        Volatility_prior=sim.p_prc.mu_0(1,3);
        Volatility=sim.traj.mu(1:t-1,3);
        
        plot(0:t-1, ([Volatility_prior; Volatility]),'Color', currCol, 'LineWidth', 2);
        hold on;
        plot(0, Volatility_prior, 'o', 'Color', currCol,  'LineWidth', 2); % prior
        title(['Volatility ' sprintf('\\mu_3')], 'FontWeight', 'bold');
        switch iParameter
            case 1
                title(['Perceived Volatility of Social Cue with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                    ',' sprintf('\\rho='), num2str(sim.p_prc.rho(:,2))],'FontWeight', 'bold');
            case 2
                title(['Perceived Volatility of Social Cue with ' sprintf('\\kappa='), num2str(sim.p_prc.ka(1,2)), ...
                    ',' sprintf('\\rho='), num2str(sim.p_prc.rho(:,2))],'FontWeight', 'bold');
            case 3
                title(['Perceived Volatility of Social Cue with ' sprintf('\\kappa='), num2str(sim.p_prc.ka(1,2)), ...
                    ',' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)),',' sprintf('\\rho_2='), num2str(sim.p_prc.rho(:,2))],'FontWeight', 'bold');
            case {4,5}
                title(['Perceived Volatility of Social Cue with ' sprintf('\\kappa='), num2str(sim.p_prc.ka(1,2)), ...
                    ',' sprintf(' \\omega='), num2str(sim.p_prc.om(1,2)),',' sprintf('\\vartheta='), num2str(sim.p_prc.th)],'FontWeight', 'bold');
                
        end
        xlabel('Trial number');
        ylabel(sprintf('\\mu_3'));
        
        
        
        %% Prediction
        if plotPE==true
            axes(sh(2));
            probs=[ones(nTrials,1).*probabilityAdvice(1);ones(nTrials,1).*probabilityAdvice(2);...
                ones(nTrials,1).*probabilityAdvice(3);ones(nTrials,1).*probabilityAdvice(4);...
                ones(nTrials,1).*probabilityAdvice(5); ones(nTrials,1).*probabilityAdvice(6);...
                ones(nTrials,1).*probabilityAdvice(7); ones(nTrials,1).*probabilityAdvice(8);...
                ones(nTrials,1).*probabilityAdvice(9); ones(nTrials,1).*probabilityAdvice(10)];
            plot(0:t-1,probs,'Color',[0.5 0.5 0.5], 'LineWidth', 2);
            hold on;
            
            lgh_a=plot(0:t-1, sim.traj.sa(:,2).*(sim.traj.da(:,1)),'Color', currCol, 'LineWidth', 2);
            
            
            plot(0, tapas_sgm(sim.p_prc.mu_0(1,2), 1), 'o', 'Color', currCol,  'LineWidth', 2); % prior
            plot(1:t, sim.u(:,1)*2, 'o', 'Color', [0 0.6 0]); % inputs
            
            if ~isempty(find(strcmp(fieldnames(sim),'y'))) && ~isempty(sim.y)
                y = stretch(sim.y(:,1), 5+0.16 + (par-1)*0.05);
                plot(1:t, y, '.', 'Color', currCol); % responses
                
                if iModel==1
                    switch iParameter
                        case 'rho_2ndlevel'
                            title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                                ','  sprintf('\\rho_3='), num2str(sim.p_prc.rho(:,3))],'FontWeight', 'bold');
                        case 'rho_3rdlevel'
                            title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                                ',' sprintf('\\rho_2='), num2str(sim.p_prc.rho(:,2))],'FontWeight', 'bold');
                        case {'omega_2ndlevel','omega_3rdlevel'}
                            title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\kappa='), num2str(sim.p_prc.ka(1,2)), ...
                                ',' sprintf('\\rho_2='), num2str(sim.p_prc.rho(:,2)),',' sprintf('\\rho_3='), num2str(sim.p_prc.rho(:,3))],'FontWeight', 'bold');
                            
                    end
                else
                    title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                        ','  sprintf('\\phi_3='), num2str(sim.p_prc.phi(:,3))],'FontWeight', 'bold');
                end
                ylabel(sprintf('\\delta_1'));
                xlabel({'Trial number', ' '}); % A hack to get the relative subplot sizes right
            end
        elseif plotmu2hat==true
            axes(sh(2));
            lgh_a=plot(0:t, [sim.p_prc.mu_0(1,2); sim.traj.muhat(:,2)],'Color', currCol, 'LineWidth', 2);
            hold on;
            plot(0, sim.p_prc.mu_0(1,2), 'o', 'Color', currCol,  'LineWidth', 2); % prior
            plot(1:t, sim.u(:,1), 'o', 'Color', [0 0.6 0]); % inputs
            
            if ~isempty(find(strcmp(fieldnames(sim),'y'))) && ~isempty(sim.y)
                y = stretch(sim.y(:,1), 10+0.16 + (par-1)*0.05);
                plot(1:t, y, '.', 'Color', currCol); % responses
                
                if iModel==1
                    switch iParameter
                        case 'rho_2ndlevel'
                            title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                                ','  sprintf('\\rho_3='), num2str(sim.p_prc.rho(:,3))],'FontWeight', 'bold');
                        case 'rho_3rdlevel'
                            title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                                ',' sprintf('\\rho_2='), num2str(sim.p_prc.rho(:,2))],'FontWeight', 'bold');
                        case {'omega_2ndlevel','omega_3rdlevel'}
                            title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\kappa='), num2str(sim.p_prc.ka(1,2)), ...
                                ',' sprintf('\\rho_2='), num2str(sim.p_prc.rho(:,2)),',' sprintf('\\rho_3='), num2str(sim.p_prc.rho(:,3))],'FontWeight', 'bold');
                            
                    end
                else
                    title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                        ','  sprintf('\\phi_3='), num2str(sim.p_prc.phi(:,3))],'FontWeight', 'bold');
                end
                ylabel(sprintf('\\mu_2'));
                xlabel({'Trial number', ' '}); % A hack to get the relative subplot sizes right
            end
        else
            axes(sh(2));
            lgh_a=plot(0:t, [tapas_sgm(sim.p_prc.mu_0(1,2), 1); tapas_sgm(sim.traj.mu(:,2), 1)],'Color', currCol, 'LineWidth', 2);
            hold on;
            plot(0:t-1,([ones(nTrials,1).*probabilityAdvice(1);ones(nTrials,1).*probabilityAdvice(2);...
                ones(nTrials,1).*probabilityAdvice(3);ones(nTrials,1).*probabilityAdvice(4);...
                ones(nTrials,1).*probabilityAdvice(5); ones(nTrials,1).*probabilityAdvice(6);...
                ones(nTrials,1).*probabilityAdvice(7); ones(nTrials,1).*probabilityAdvice(8);...
                ones(nTrials,1).*probabilityAdvice(9);ones(nTrials,1).*probabilityAdvice(10)]),'Color', 'k', 'LineWidth', 2);
            plot(0, tapas_sgm(sim.p_prc.mu_0(1,2), 1), 'o', 'Color', currCol,  'LineWidth', 2); % prior
            plot(1:t, sim.u(:,1), 'o', 'Color', [0 0.6 0]); % inputs
            
            if ~isempty(find(strcmp(fieldnames(sim),'y'))) && ~isempty(sim.y)
                y = stretch(sim.y(:,1), 1+0.16 + (par-1)*0.05);
                plot(1:t, y, '.', 'Color', currCol); % responses
                
                if iModel==1
                    switch iParameter
                        case 'rho_2ndlevel'
                            title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                                ','  sprintf('\\rho_3='), num2str(sim.p_prc.rho(:,3))],'FontWeight', 'bold');
                        case 'rho_3rdlevel'
                            title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                                ',' sprintf('\\rho_2='), num2str(sim.p_prc.rho(:,2))],'FontWeight', 'bold');
                        case {'omega_2ndlevel','omega_3rdlevel'}
                            title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\kappa='), num2str(sim.p_prc.ka(1,2)), ...
                                ',' sprintf('\\rho_2='), num2str(sim.p_prc.rho(:,2)),',' sprintf('\\rho_3='), num2str(sim.p_prc.rho(:,3))],'FontWeight', 'bold');
                            
                    end
                else
                    title(['Input u (green), Prediction about Advice Validity with ' sprintf('\\omega='), num2str(sim.p_prc.om(1,2)), ...
                        ','  sprintf('\\phi_3='), num2str(sim.p_prc.phi(:,3))],'FontWeight', 'bold');
                end
                ylabel(sprintf('\\mu'));
                xlabel({'Trial number', ' '}); % A hack to get the relative subplot sizes right
            end
            
            
        end
        
    end
end

function y = stretch(y, fac)
y = y - 0.5;
y = y*fac;
y = y + 0.5;
end

