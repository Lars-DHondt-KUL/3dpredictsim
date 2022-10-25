
clear 
close all
clc

%% Paths
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';
ResultsFolder = 'different_speeds';

ResultFiles = {
    'Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_vel*'
    'Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel*'
    'Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_vel*'
    'Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel*'
    };

colrs = [[0.4940 0.1840 0.5560];[0 0.4470 0.7410];[0.4660 0.6740 0.1880];[0.6350 0.0780 0.1840]];

figure('Position',[100,100,1500,700])
tiledlayout('flow')
lgd = [];

for i=1:length(ResultFiles)
    MatFiles = dir(fullfile(ResultsRepo,ResultsFolder,[ResultFiles{i} '_pp.mat']));
    nsim = length(MatFiles);

    vs = zeros(nsim,1);
    COTs = vs;
    obj = vs;

    for j=1:nsim
        load(fullfile(MatFiles(j).folder,MatFiles(j).name),'R');
        vs(j) = R.S.v_tgt;
        COTs(j) = R.COT;
        obj(j) = R.Obj.J;


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

        elseif j>1 && vs(j)==vs(j-1)
%             [COTs([j-1,j]),idx] = min( COTs([j-1,j]));
%             obj([j-1,j]) = obj(j-2+idx);
            [obj([j-1,j]),idx] = min(obj([j-1,j]));
            COTs([j-1,j]) = COTs(j-2+idx);
        end

        clear('R')
    end
    
    nexttile(3)
    hold on
    plot(vs,COTs,'.-','Color',colrs(i,:),'MarkerSize',15);

    nexttile(4)
    hold on
    plot(vs,obj,'.-','Color',colrs(i,:),'MarkerSize',15);

end

nexttile(1)
lg=legend(lgd,{'Baseline','Rigid midfoot','Plantar fascia','Plantar intrinsic muscles'},'Location','northeast');
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
xlabel('Velocity (m/s)')
ylabel('COT (J m^-^1 kg^-^1)')
title('Minimum COT over different IG')

nexttile(4)
xlim([0.7,2.8])
xlabel('Velocity (m/s)')
ylabel('objective (n/a)')
title('Cost function')

