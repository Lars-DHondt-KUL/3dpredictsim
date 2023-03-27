

clear
close all
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);


fig1=figure('Position',[776   213   728   637]);

tiledlayout('flow')
nexttile(2)
hold on
lg=legend('Location','eastoutside','FontSize',12);
lg.Box = 'off';
xlabel('Angle (°)','FontSize',12)
ylabel('Moment (Nm)','FontSize',12)
title('Peak plantarflexion','FontSize',12)
set(gca,'Fontsize',12);
xlim([-32,27])

nexttile(1)
hold on
lg=legend('Location','eastoutside','FontSize',12);
lg.Box = 'off';
xlabel('Angle (°)','FontSize',12)
ylabel('Moment (Nm)','FontSize',12)
title('Peak dorsiflexion','FontSize',12)
set(gca,'Fontsize',12);
xlim([-32,27])



%%
% Sale et al., 1982
% 90° knee flex
q_ankle = [-30,-25,-15,-5,5,15,20];
T_mean = [35.45,50.65,79.09,114.80,144.20,170.20,169.32];
T_std = [3.04,3.74,3.70,4.77,4.62,7.51,7.12];

nexttile(2)
plot(q_ankle,-T_mean,'d','Color',[1,1,1]*0.6,'DisplayName','Sale et al., 1982 (mean) knee 90°','LineWidth',3);

% Anderson et al., 2007

qs = linspace(-30,20,100)*pi/180;


% Plantar flexion
C1 = [0.095 (0.022) 0.104 (0.034) 0.114 (0.029) 0.093 (0.026) 0.106 (0.035) 0.125 (0.006)]*1.70*62*9.81;
C2 = [ 1.391 (0.089) 1.399 (0.190) 1.444 (0.136) 1.504 (0.235) 1.465 (0.136) 1.299 (0.095)];
C3 = [0.408 (0.083) 0.424 (0.186) 0.551 (0.103) 0.381 (0.143) 0.498 (0.132) 0.580 (0.115)];
C4 = [0.987 (0.595) 0.862 (0.487) 0.593 (0.165) 0.860 (0.448) 0.490 (0.262) 0.587 (0.258)];
C5 = [3.558 (2.144) 3.109 (1.760) 2.128 (0.578) 3.126 (1.613) 1.767 (0.944) 1.819 (0.423)];
C6 = [0.295 (0.214) 0.189 (0.213) 0.350 (0.133) 0.349 (0.270) 0.571 (0.313) 0.348 (0.158)];
B1 = [-5.781E-4 (1.193E-3) -5.218E-3 (1.135E-2) -1.311E-3 (3.331E-3) -2.888E-5 (3.562E-5) -5.693E-5 (3.164E-5) -2.350E-5 (2.535E-5)];
k1 = [-5.819 (7.384) -4.875 (6.770) -10.943 (10.291) -17.189 (7.848) -21.088 (1.786) -12.567 (10.885)];
B2 = [0.967 (0.323) 0.470 (0.328) 0.377 (0.403) 0.523 (0.394) 0.488 (0.258) 0.331 (0.247)];
k2 = [6.090 (1.196) 6.425 (1.177) 8.916 (3.119) 7.888 (1.141) 7.309 (0.902) 6.629 (2.186)];

T_pass_pf = B1(3)*exp(k1(3)*qs) + B2(3)*exp(k2(3)*qs);
T_act_iso_pf = C1(3)*cos(C2(3)*(qs-C3(3)));

% Dorsiflexion
C1 = [0.033 (0.005) 0.027 (0.006) 0.028 (0.005) 0.024 (0.002) 0.029 (0.002) 0.022 (0.003)]*1.70*62*9.81;
C2 = [1.510 (0.190) 1.079 (0.271) 1.293 (0.479) 1.308 (0.339) 1.419 (0.195) 1.096 (0.297)];
C3 = [-0.187 (0.067) -0.302 (0.171) -0.284 (0.178) -0.254 (0.133) -0.174 (0.056) -0.369 (0.109)];
C4 = [0.699 (0.108) 0.864 (0.446) 0.634 (0.216) 0.596 (0.148) 0.561 (0.188) 0.458 (0.089)];
C5 = [1.940 (0.301) 2.399 (1.236) 1.759 (0.601) 1.654 (0.410) 1.558 (0.521) 1.242 (0.213)];
C6 = [0.828 (0.134) 0.771 (0.206) 0.999 (0.214) 1.006 (0.284) 1.198 (0.290) 1.401 (0.427)];
B1 = [5.781E-4 (1.193E-3) 5.218E-3 (1.135E-2) 1.311E-3 (3.331E-3) 2.888E-5 (3.562E-5) 5.693E-5 (3.164E-5) 2.350E-5 (2.535E-5)];
k1 = [-5.819 (7.384) -4.875 (6.770) -10.943 (10.291) -17.189 (7.848) -21.088 (1.786) -12.567 (10.885)];
B2 = [-0.967 (0.323) -0.470 (0.328) -0.377 (0.403) -0.523 (0.394) -0.488 (0.258) -0.331 (0.247)];
k2 = [6.090 (1.196) 6.425 (1.177) 8.916 (3.119) 7.888 (1.141) 7.309 (0.902) 6.629 (2.186)];

T_pass_df = B1(3)*exp(k1(3)*qs) + B2(3)*exp(k2(3)*qs);
T_act_iso_df = C1(3)*cos(C2(3)*(qs-C3(3)));



nexttile(1)
plot(qs*180/pi,(T_pass_df+T_act_iso_df),'Color',[1,1,1]*0.8,'DisplayName','Anderson et al., 2007 (mean) knee 50°','LineWidth',3);

nexttile(2)
plot(qs*180/pi,-(T_pass_pf+T_act_iso_pf),'Color',[1,1,1]*0.8,'DisplayName','Anderson et al., 2007 (mean) knee 50°','LineWidth',3);

%%
Holzer_dat = importdata(fullfile(pathRepo,'Figures','Holzer_et_al_2020.csv'));

pf_iso_min_Holzer = Holzer_dat.data(:,1:2);
pf_iso_max_Holzer = Holzer_dat.data(:,3:4);
pf_iso_max_Holzer = pf_iso_max_Holzer(~isnan(pf_iso_max_Holzer(:,1)),:);
nexttile(2)
fill([pf_iso_max_Holzer(:,1)', fliplr(pf_iso_min_Holzer(:,1)')],...
    -[pf_iso_max_Holzer(:,2)', fliplr(pf_iso_min_Holzer(:,2)')],[1,1,1]*0.9,...
    'DisplayName','Holzer et al., 2020 (range) knee 0°','LineStyle','none');


%%
Marsh_dat = importdata(fullfile(pathRepo,'Figures','Marsh_et_al_1981.csv'));

df_iso_Marsh = Marsh_dat.data;
nexttile(1)
plot(df_iso_Marsh(:,1),df_iso_Marsh(:,2),'o','Color',[1,1,1]*0.6,...
    'DisplayName','Marsh et al., 1981 (mean) knee 90°','LineWidth',3);



%%

sf=[1,1.2,1.5];

CsV = [[0 0.4470 0.7410];[0 0 0];[0.4660 0.6740 0.1880]];


load('C:\Users\u0150099\Documents\master_thesis\make_osim_model/knee_0.mat');

for i=1:3
    nexttile(2)
    p1=plot(T_iso_pf(:,1),T_iso_pf(:,1+i),'Color',CsV(i,:),'LineWidth',1,...
        'DisplayName',['Max isometric force: ' num2str(sf(i)*100) '% (knee 0°)']);
%     nexttile(1)
%     plot(T_iso_df(:,1),T_iso_df(:,1+i),'Color',CsV(i,:),'DisplayName',['FMo x' num2str(sf(i)) '(knee 0°)']);
end

load('C:\Users\u0150099\Documents\master_thesis\make_osim_model/knee_50.mat');

for i=1:3
    nexttile(2)
    p1=plot(T_iso_pf(:,1),T_iso_pf(:,1+i),'--','Color',CsV(i,:),'LineWidth',1,...
        'DisplayName',['Max isometric force: ' num2str(sf(i)*100) '% (knee 50°)']);
    nexttile(1)
    plot(T_iso_df(:,1),T_iso_df(:,1+i),'--','Color',CsV(i,:),'LineWidth',1,...
        'DisplayName',['Max isometric force: ' num2str(sf(i)*100) '% (knee 50°)']);
end


load('C:\Users\u0150099\Documents\master_thesis\make_osim_model/knee_90.mat');

for i=1:3
    nexttile(2)
    p1=plot(T_iso_pf(:,1),T_iso_pf(:,1+i),'-.','Color',CsV(i,:),'LineWidth',1,...
        'DisplayName',['Max isometric force: ' num2str(sf(i)*100) '% (knee 90°)']);
    nexttile(1)
    plot(T_iso_df(:,1),T_iso_df(:,1+i),'-.','Color',CsV(i,:),'LineWidth',1,...
        'DisplayName',['Max isometric force: ' num2str(sf(i)*100) '% (knee 90°)']);
end


%
FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\figures\draft/supplement';
figName = 'max_iso_moment';
exportgraphics(fig1,fullfile(FigRepo,['figure_' figName '.jpeg']),'Resolution',300);
