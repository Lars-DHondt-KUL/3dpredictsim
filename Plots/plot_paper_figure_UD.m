 

clear
close all
clc

%% load reference data

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

FigRepo = fullfile(pathRepo,'Figures');
FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\revision 1\figures';
ResultsRepo = fullfile(pathRepo,'Results');
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

% Digitised graph from DOI:10.1038/s41598-017-15218-7 not included
if exist(fullfile(pathRepo,'Figures','Takahashi_et_al_2017.csv'),'file')
    TKH17_dat = importdata(fullfile(pathRepo,'Figures','Takahashi_et_al_2017.csv'));
    
    TKH17.shank = TKH17_dat.data(:,1:2);
    TKH17.hindfoot = TKH17_dat.data(:,3:4);
    TKH17.forefoot = TKH17_dat.data(:,5:6);
    TKH17.hallux = TKH17_dat.data(:,7:8);
else
    TKH17.shank = [-1,-1];
    TKH17.hindfoot = [-1,-1];
    TKH17.forefoot = [-1,-1];
    TKH17.hallux = [-1,-1];

end

%% figure 

resultFiles = {
    fullfile([ResultsRepo '\results_paper_v2\Fal_s1_mtjcf3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Natali2010_ls146_FDB2_lMo23_lTs123_Fpsl10_ig1_N100_pp.mat'])
    };
LegNames = {'3-segment foot model'};

load(resultFiles{1},'R')
LegName = LegNames{1};

%%

x = 1:(100-1)/(size(R.Qs,1)-1):100;

imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
iknee = strcmp(R.colheaders.joints,'knee_angle_r');
iankle = strcmp(R.colheaders.joints,'ankle_angle_r');
isubt = strcmp(R.colheaders.joints,'subtalar_angle_r');
imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));

istance = 1:1:ceil(R.Event.Stance/100*length(x));
xst = linspace(1,100,length(istance));

P_ankle = R.Qdots(:,iankle)*pi/180.*R.Tid(:,iankle)/R.body_mass;
P_subt = R.Qdots(:,isubt)*pi/180.*R.Tid(:,isubt)/R.body_mass;
P_mtp = R.Qdots(:,imtp)*pi/180.*R.Tid(:,imtp)/R.body_mass;
P_mtj = R.Qdots(:,imtj)*pi/180.*R.Tid(:,imtj)/R.body_mass;

P_joints = P_mtj + P_ankle + P_subt + P_mtp;

P_HC_heel = R.P_mech_contact.vertical.calcn.r/R.body_mass;
P_HC_ball = R.P_mech_contact.vertical.metatarsi.r/R.body_mass;
P_HC_toes = R.P_mech_contact.vertical.toes.r/R.body_mass;
P_HC = P_HC_heel + P_HC_ball + P_HC_toes;

P_dist_hindfoot = P_mtp + P_mtj + P_HC;
P_dist_forefoot = P_mtp + P_HC_ball + P_HC_toes;
P_dist_hallux = P_HC_toes;
P_tot = P_HC + P_joints;

%%

label_fontsize = 12;
legend_fontsize = 12;
title_fontsize = 12;


line_linewidth = 2;

fig2 = figure();
fig2.Position = [269 136 1200 300];

tl2 = tiledlayout(1,6);
tl2.TileSpacing = 'tight';

nexttile(1)
hold on
yline(0,'-k')
plot(TKH17.shank(:,1),TKH17.shank(:,2),'-','Color',[1,1,1]*0.6,'linewidth',4)
plot(xst,P_tot(istance),'-','Color',[0.3, 0.3, 0.3],'linewidth',line_linewidth,'DisplayName','Distal to Shank');


ylim([-2.5,3.])
xlim([0,100])
ylabel('Power (W/kg)','Fontsize',label_fontsize);
xlabel('Stance phase (%)','Fontsize',label_fontsize);
title('Distal to shank','Fontsize',title_fontsize);
set(gca,'Fontsize',label_fontsize);

nexttile(2)
hold on
yline(0,'-k')
plot(TKH17.hindfoot(:,1),TKH17.hindfoot(:,2),'-','Color',[1,1,1]*0.6,'linewidth',4)
plot(xst,P_dist_hindfoot(istance),'-','Color',[0, 0.4470, 0.7410],'linewidth',line_linewidth,'DisplayName','Distal to Hindfoot');

ylim([-2.5,3.])
xlim([0,100])
ylabel(' ','Fontsize',1);
xlabel('Stance phase (%)','Fontsize',label_fontsize);
title('Distal to hindfoot','Fontsize',title_fontsize);
set(gca,'Fontsize',label_fontsize);

nexttile(3)
hold on
yline(0,'-k')
p2=plot(TKH17.forefoot(:,1),TKH17.forefoot(:,2),'-','Color',[1,1,1]*0.6,'linewidth',4,'DisplayName','Power (Experimental, Takahashi et al., 2017)');
p1=plot(xst,P_dist_forefoot(istance),'-','Color',[0.7, 0.1, 0.1],'linewidth',line_linewidth,'DisplayName','Power (Simulated)');
leg = [p2,p1];

ylim([-2.5,3.])
xlim([0,100])
xlabel('Stance phase (%)','Fontsize',label_fontsize);
title('Distal to forefoot','Fontsize',title_fontsize);
set(gca,'Fontsize',label_fontsize);

nexttile(4)
hold on
yline(0,'-k')
plot(TKH17.hallux(:,1),TKH17.hallux(:,2),'-','Color',[1,1,1]*0.6,'linewidth',4)
plot(xst,P_dist_hallux(istance),'-','Color',[0, 0.5, 0],'linewidth',line_linewidth,'DisplayName','Distal to Hallux');



ylim([-2.5,3.])
xlim([0,100])
xlabel('Stance phase (%)','Fontsize',label_fontsize);
title('Distal to hallux','Fontsize',title_fontsize);
set(gca,'Fontsize',label_fontsize);



%%

    
% results from DOI:10.1038/s41598-017-15218-7
% order: hallux, forefoot, hindfoot, shank
ref_pos_m = [0.006,0.012,0.042,0.185];
ref_pos_std = [0.004,0.005,0.012,0.028];
ref_neg_m = [-0.013,-0.095,-0.125,-0.197];
ref_neg_std = [0.004,0.031,0.026,0.040];
ref_net_m = [-0.006,-0.083,-0.083,-0.012];
ref_net_std = [0.005,0.032,0.021,0.054];
% order: mtj, mtj+forefoot, ankle
ref_pos_m2 = [0.1009,0.0458,0.1872];
ref_pos_std2 = [0.0308,0.0159,0.0338];
ref_neg_m2 = [-0.0536,-0.0822,-0.1181];
ref_neg_std2 = [0.0144,0.0197,0.0414];
ref_net_m2 = [0.0475,-0.0360,0.0694];
ref_net_std2 = [0.0301,0.0241,0.0611];

W_dist_shank = trapz(R.t(istance),P_tot(istance));
W_dist_hindfoot = trapz(R.t(istance),P_dist_hindfoot(istance));
W_dist_forefoot = trapz(R.t(istance),P_dist_forefoot(istance));
W_dist_hallux = trapz(R.t(istance),P_dist_hallux(istance));

W_mtjs = trapz(R.t(istance),P_mtj(istance));
W_mtjff = trapz(R.t(istance),P_mtj(istance)+P_dist_forefoot(istance));
W_ankles = trapz(R.t(istance),P_ankle(istance)+P_subt(istance));

[W_dist_shank_pos,W_dist_shank_neg] = getWork(P_tot(istance),R.t(istance));
[W_dist_hindfoot_pos,W_dist_hindfoot_neg] = getWork(P_dist_hindfoot(istance),R.t(istance));
[W_dist_forefoot_pos,W_dist_forefoot_neg] = getWork(P_dist_forefoot(istance),R.t(istance));
[W_dist_hallux_pos,W_dist_hallux_neg] = getWork(P_dist_hallux(istance),R.t(istance));

[W_mtj_pos,W_mtj_neg] = getWork(P_mtj(istance),R.t(istance));
[W_mtjff_pos,W_mtjff_neg] = getWork(P_mtj(istance)+P_dist_forefoot(istance),R.t(istance));
[W_ankle_pos,W_ankle_neg] = getWork(P_ankle(istance)+P_subt(istance),R.t(istance));

nexttile(5)
hold on
W_pos = [W_dist_hallux_pos,W_dist_forefoot_pos,W_dist_hindfoot_pos,W_dist_shank_pos]';
W_neg = [W_dist_hallux_neg,W_dist_forefoot_neg,W_dist_hindfoot_neg,W_dist_shank_neg]';

br=bar(flip(W_pos));
br.FaceColor = 'flat';
br.CData(4,:) = [0, 0.5, 0];

br.CData(2,:) = [0, 0.4470, 0.7410];
br.CData(1,:) = [0.3, 0.3, 0.3];
br.CData(3,:) = [0.7, 0.1, 0.1];
hold on
br.DisplayName = 'Work (simulated)';
leg(4) = br;

ebr=errorbar([4:-1:1],ref_pos_m,-ref_pos_std,ref_pos_std);
ebr.Color = [0 0 0];                            
ebr.LineStyle = 'none';
ebr.LineWidth = 1.5;

tmp=gca;
tmp.XTick = [0:4];
tmp.XTickLabel = {'Distal to...','...shank','...hindfoot','...forefoot','...hallux'};
tmp.XTickLabelRotation = 90;
title('Work')
yl_1 = tmp.YLim;


yyaxis right
br=bar(flip(W_neg));
br.FaceColor = 'flat';
br.CData(4,:) = [0, 0.5, 0];
br.CData(3,:) = [0.7, 0.1, 0.1];
br.CData(2,:) = [0, 0.4470, 0.7410];
br.CData(1,:) = [0.3, 0.3, 0.3];
hold on

ebr=errorbar([4:-1:1],ref_neg_m,-ref_neg_std,ref_neg_std);
ebr.Color = [0 0 0];                            
ebr.LineStyle = 'none'; 
ebr.LineWidth = 1.5;

tmp2 = gca;
yl_2 = tmp2.YLim;
        
tmp2.YAxis(2).Color = 'k';
tmp2.YAxis(1).Color = 'none';
% tmp2.YTickLabel = '';

yl_12 = [min([yl_1,yl_2]), max([yl_1,yl_2])];
ylim(yl_12)
set(gca,'Fontsize',label_fontsize);

yyaxis left
ylim(yl_12)
set(gca,'Fontsize',label_fontsize);



nexttile(6)
hold on
W_net = [W_dist_hallux,W_dist_forefoot,W_dist_hindfoot,W_dist_shank]';

br=bar(flip(W_net));
br.FaceColor = 'flat';
br.CData(4,:) = [0, 0.5, 0];
br.CData(3,:) = [0.7, 0.1, 0.1];
br.CData(2,:) = [0, 0.4470, 0.7410];
br.CData(1,:) = [0.3, 0.3, 0.3];
hold on

ebr=errorbar([4:-1:1],ref_net_m,-ref_net_std,ref_net_std);
ebr.Color = [0 0 0];                            
ebr.LineStyle = 'none';
ebr.LineWidth = 1.5;

ebr.DisplayName = 'Work (Experimental, Takahashi et al., 2017)';
leg(3) = ebr;

ylabel('Work (J/kg)','Fontsize',label_fontsize);

tmp=gca;
tmp.XTick = [0:4];
tmp.XTickLabel = {'Distal to...','...shank','...hindfoot','...forefoot','...hallux'};
tmp.XTickLabelRotation = 90;
tmp.YAxisLocation = 'right';
title('Net work')
ylim(yl_12)
set(gca,'Fontsize',label_fontsize);

lg = legend(leg,'Fontsize',legend_fontsize,'NumColumns',4);
lg.Color = 'none';
lg.Box = 'off';
lg.Layout.Tile = 'South';


str = '(a)';
annotation(gcf,'textbox',[0.06,0.96,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(b)';
annotation(gcf,'textbox',[0.66,0.96,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);


exportgraphics(fig2,fullfile(FigRepo,'figure_UD.jpeg'),'Resolution',300);


%%

function [pos_work,neg_work,varargout] = getWork(power,time)
    pos_power = power;
    pos_power(power<0) = 0;
    pos_work = trapz(time,pos_power);

    neg_power = power;
    neg_power(power>0) = 0;
    neg_work = trapz(time,neg_power);

    if nargout==3
        net_work = trapz(time,power);
        varargout{1} = net_work;
    end
end