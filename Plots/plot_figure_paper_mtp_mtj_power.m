
clear
close all
clc

FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\figures\draft';
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

%% load rference data

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
load([pathRepo '\Data\Fal_s1.mat'],'Data');

RefData = 'Fal_s1_mtjc4_FK_custom_right';

data_field = ['IK_' RefData(8:end)];
Qref = Data.(data_field);

data_field = ['ID_' RefData(8:end)];
Tref = Data.(data_field);

data_field = ['P_' RefData(8:end)];
Pref = Data.(data_field);

stance_ref_mean = 64.3;
stance_ref_std = 0.8233;

%% figure 

resultFiles = {
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1_N100_pp.mat'])
    };


joints_tit = {'Midtarsal','MTP','Midtarsal + MTP'};


label_fontsize = 12;
legend_fontsize = 12;
title_fontsize = 12;

CsV = {'k',[0.4660 0.6740 0.1880],'k',[0.6350 0.0780 0.1840],[0.3010 0.7450 0.9330]};
mrk = {'-','-.','-.','-.'};
lw = [2,1,2,1];

set(0,'defaultFigureColor','w')

%
fig2 = figure();
fig2.Position = [269 136 1200/2 300];
tl2 = tiledlayout(1,3);
tl2.TileSpacing = 'tight';

i_res=1;
load(resultFiles{i_res},'R')
x = 1:(100-1)/(size(R.Qs,1)-1):100;
x_to1 = x(R.GRFs(:,2) > 3);
x_to2 = x(x>=R.Event.Stance);
x_to12 = intersect(x_to1,x_to2);
x_to = x_to12(end);
idx_stance = find(x<=x_to);
x = 1:(100-1)/(length(idx_stance)-1):100;

line_linewidth = lw(i_res);

imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));
iFDB = find(strcmp(R.colheaders.muscles,'FDB_r'));

l_PF = R.windlass.l_PF;
F_PF = R.windlass.F_PF;
F_PIM = R.FT(:,iFDB(1));

M_mtj_li = R.windlass.M_li;
M_mtj_PF = R.windlass.MA_PF.mtj.*F_PF;
M_mtj_PIM = R.windlass.MA_PF.mtj.*F_PIM;
M_mtp_PF = R.windlass.MA_PF.mtp.*F_PF;
M_mtp_PIM = R.windlass.MA_PF.mtp.*F_PIM;

v_PF = R.windlass.v_PF;

P_PF = -v_PF.*F_PF/R.body_mass;
P_PIM = -v_PF.*F_PIM/R.body_mass;
P_mtj_li = R.Qdots(:,imtj)*pi/180.*M_mtj_li/R.body_mass;
P_mtj_PF = R.Qdots(:,imtj)*pi/180.*M_mtj_PF/R.body_mass;
P_mtj_PIM = R.Qdots(:,imtj)*pi/180.*M_mtj_PIM/R.body_mass;
P_mtp_PF = R.Qdots(:,imtp)*pi/180.*M_mtp_PF/R.body_mass;
P_mtp_PIM = R.Qdots(:,imtp)*pi/180.*M_mtp_PIM/R.body_mass;

P_mtj = R.Qdots(:,imtj)*pi/180.*R.Tid(:,imtj)/R.body_mass;
P_mtp = R.Qdots(:,imtp)*pi/180.*R.Tid(:,imtp)/R.body_mass;

pos_P_all = {P_mtj, P_mtp, P_mtj+P_mtp,...
           P_mtj_PIM+P_mtj_PF, P_mtp_PIM+P_mtp_PF, P_PIM+P_PF};



for i=1:6
    nexttile(rem(i-1,3)+1);
    i_res = floor((i-1)/3)+1;
    hold on
    Pij = pos_P_all{i};
    p1=plot(x,Pij(idx_stance),'linewidth',line_linewidth,'Color',CsV{i_res},...
        'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
    hold on

    lgp(ceil(i/3)) = p1;

    % layout
    if i_res==1
        if i == 1
            ylb = ylabel('Power (W/kg)','Fontsize',label_fontsize);
%                 ylb.Position(1) = -27;
        end
        ylim([-0.8,1.3])
        xlim([0,100])
        set(gca,'XTick',[0:50:100]);
        set(gca,'Fontsize',label_fontsize);
        set(gca,'XTickLabelRotation',0)
        title(joints_tit{i},'Fontsize',title_fontsize);
        xlabel('Stance phase (%)','Fontsize',label_fontsize+1)
        if i<=3
            yline(0,'Color',[1,1,1]*0.7)
        end
    end
end


%%
i_res=2;
load(resultFiles{i_res},'R')
x = 1:(100-1)/(size(R.Qs,1)-1):100;
x_to1 = x(R.GRFs(:,2) > 3);
x_to2 = x(x>=R.Event.Stance);
x_to12 = intersect(x_to1,x_to2);
x_to12 = x_to12(x_to12<70);
x_to = x_to12(end);
idx_stance = find(x<=x_to);
x = 1:(100-1)/(length(idx_stance)-1):100;

line_linewidth = lw(i_res);

imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));

P_mtp = R.Qdots(:,imtp)*pi/180.*R.Tid(:,imtp)/R.body_mass;

for i=2:3
    nexttile(i)
    lgp(3) = plot(x,P_mtp(idx_stance),'linewidth',line_linewidth,'Color',CsV{i_res+1},...
            'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName','Total joint power (3-segment)');

end

leg = {'Total joint power (nominal 3-segment foot model)',...
    'Contribution of plantar fascia and plantar intrinsic muscle to joint power',...
    'Total joint power (nominal 2-segment foot model)'};
lg = legend(lgp,leg,'Fontsize',legend_fontsize);
lg.Layout.Tile = 'South';
lg.Box = 'off';
%%
% exportgraphics(fig2,fullfile(FigRepo,'figure_mtp_mtj_power.jpeg'),'Resolution',300);








