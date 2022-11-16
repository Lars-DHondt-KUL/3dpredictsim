
clear 
close all
clc

%% Paths
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

ResultFiles = {
    'different_speeds/Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel*'
    'different_speeds/Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_vel*'
    'different_speeds/Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel*'
%     'different_speeds/Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_vel*'
%     'with_better_knee/Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel*tanh10*'
%     'with_better_knee/Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_vel*tanh10*'
    };

colrs = [
    [0 0.4470 0.7410];
    [0.4660 0.6740 0.1880];
    [0.6350 0.0780 0.1840];
    [0.4940 0.1840 0.5560];
    [0.8500 0.3250 0.0980];
    [0.3010 0.7450 0.9330];
    ];

f1 = figure('Position',[100,100,1500,700]);
tiledlayout('flow')
f2 = figure;
tiledlayout('flow')
lgd = [];

for i=1:length(ResultFiles)
    MatFiles = dir(fullfile(ResultsRepo,[ResultFiles{i} '_pp.mat']));
    nsim = length(MatFiles);

    vs = zeros(nsim,1);
    COTs = vs;
    COTbs = COTs;
    obj = vs;
    obj_E = obj;
    obj_a = obj;
    obj_ddq = obj;

    for j=1:nsim
        figure(f1)
        load(fullfile(MatFiles(j).folder,MatFiles(j).name),'R');
        vs(j) = R.S.v_tgt;
        COTs(j) = R.COT;
        obj(j) = R.Obj.J;

        dist_trav = R.Qs(end,strcmp(R.colheaders.joints,'pelvis_tx')) - R.Qs(1,strcmp(R.colheaders.joints,'pelvis_tx'));

        obj_E(j) = R.Obj.E/dist_trav*2;
        obj_a(j) = R.Obj.A/dist_trav*2;
        obj_ddq(j) = R.Obj.qdd/dist_trav*2;

        if isfield(R,'COT_smoothed')
            COTbs(j) = R.COT_smoothed;
        else
            COTbs(j) = nan;
        end

        if strfind(MatFiles(j).name,'ig1')
            mrk = '.';
        elseif strfind(MatFiles(j).name,'ig23_igmtp')
            mrk = 'o';
        elseif strfind(MatFiles(j).name,'ig23')
            mrk = 'v';
        else
            mrk = 'x';
            disp(MatFiles(j).name)
        end

        nexttile(1)
        hold on
        p1=plot(vs(j),COTs(j),mrk,'Color',colrs(i,:));
        if j==1
            lgd(end+1) = p1;
        end
        
        nexttile(2)
        hold on
        plot(vs(j),obj(j),mrk,'Color',colrs(i,:))

        if j>2 && vs(j)==vs(j-1) && vs(j)==vs(j-2)
            [obj([j-2,j-1,j]),idx] = min(obj([j-2,j-1,j]));
            COTs([j-2,j-1,j]) = COTs(j-3+idx);
            COTbs([j-2,j-1,j]) = COTbs(j-3+idx);
            obj_E([j-2,j-1,j]) = obj_E(j-3+idx);
            obj_a([j-2,j-1,j]) = obj_a(j-3+idx);
            obj_ddq([j-2,j-1,j]) = obj_ddq(j-3+idx);

        elseif j>1 && vs(j)==vs(j-1)
%             [COTs([j-1,j]),idx] = min( COTs([j-1,j]));
%             obj([j-1,j]) = obj(j-2+idx);
            [obj([j-1,j]),idx] = min(obj([j-1,j]));
            COTs([j-1,j]) = COTs(j-2+idx);
            COTbs([j-1,j]) = COTbs(j-2+idx);
            obj_E([j-1,j]) = obj_E(j-2+idx);
            obj_a([j-1,j]) = obj_a(j-2+idx);
            obj_ddq([j-1,j]) = obj_ddq(j-2+idx);
        end

        clear('R')
    end
    
    nexttile(3)
    hold on
    plot(vs,COTs,'.-','Color',colrs(i,:),'MarkerSize',15,'LineWidth',1.5);
    plot(vs,COTbs,'x-','Color',colrs(i,:),'MarkerSize',15);

    nexttile(4)
    hold on
    plot(vs,obj,'.-','Color',colrs(i,:),'MarkerSize',15);

    figure(f2)
    nexttile(1)
    hold on
    plot(vs,obj_E,'.-','Color',colrs(i,:),'MarkerSize',15);

    nexttile(2)
    hold on
    plot(vs,obj_a,'.-','Color',colrs(i,:),'MarkerSize',15);

    nexttile(3)
    hold on
    plot(vs,obj_ddq,'.-','Color',colrs(i,:),'MarkerSize',15);

end

figure(f1)
nexttile(1)
lg=legend(lgd,{'Rigid midfoot','Plantar fascia','Plantar intrinsic muscles','Baseline','Rigid midfoot with tanh_b = 10','Baseline with tanh_b = 10'},'Location','northeast');
title(lg,'Color -> model type','FontWeight','normal')
xlim([0.7,2.8])
xlabel('Velocity (m/s)')
ylabel('COT (J m^-^1 kg^-^1)')
title('Cost Of Transport')
% lg.Box = 'off';
pos = lg.Position;
pos(1) = pos(1) - pos(3)*1.05;
annotation('textbox',pos,'String',{'Shape -> initial guess','.    quasi-random','o   same v, mtp model','v   same model, prev v'})
% text(1.5,5.7,{'Shape -> initial guess','.    quasi-random','o   same v, mtp model','v   same model, prev v'})

nexttile(2)
xlim([0.7,2.8])
xlabel('Velocity (m/s)')
ylabel('objective (n/a)')
title('Cost function')

nexttile(3)
xlim([0.7,2.8])
xlabel('Velocity (m /s)')
ylabel('COT (J m^-^1 kg^-^1)')
title('Minimum COT over different IG')
% title('Cost Of Transport (COT)')
% xline(2,'--k')

nexttile(4)
xlim([0.7,2.8])
xlabel('Velocity (m/s)')
ylabel('objective (n/a)')
title('Cost function')

figure(f2)
nexttile(1)
xlim([0.7,2.8])
xlabel('Velocity (m/s)')
ylabel('objective (n/a)')
title('Cost function: metabolic energy term')

nexttile(2)
xlim([0.7,2.8])
xlabel('Velocity (m/s)')
ylabel('objective (n/a)')
title('Cost function: muscle activity term')

nexttile(3)
xlim([0.7,2.8])
xlabel('Velocity (m/s)')
ylabel('objective (n/a)')
title('Cost function: joint acceleration term')



%%


% % % exportgraphics(f1,'C:\Users\u0150099\Downloads/COT_vs_speed.png','Resolution',600);
