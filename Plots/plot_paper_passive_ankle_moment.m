

clear
close all
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);


fig1=figure('Position',[776   213   500   500]);
fig1.Color = 'w';
tiledlayout('flow')
nexttile(1)
hold on


%%

Nordez_dat = importdata(fullfile(pathRepo,'Figures','Nordez_et_al_2017.csv'));

df_iso_Nordez = Nordez_dat.data;

plot(df_iso_Nordez(:,1),-df_iso_Nordez(:,2),'-','Color',[1,1,1]*0.6,'DisplayName','Nordez et al., 2017 (mean)','LineWidth',3);


%%

sf=[1,1.2,1.5];

CsV = [[0 0.4470 0.7410];[0 0 0];[0.4660 0.6740 0.1880]];


load('C:\Users\u0150099\Documents\master_thesis\make_osim_model/ankle_pass.mat');

p1=plot(T_iso_pass(:,1),-T_iso_pass(:,4),'-','Color',CsV(2,:),'LineWidth',2,...
    'DisplayName','Increased passive stiffness (total moment)');

p1=plot(T_iso_pass(:,1),-T_iso_pass(:,5),'-','Color',CsV(2,:),'LineWidth',1,...
    'DisplayName','Increased passive stiffness (contribution of muscles)');


p1=plot(T_iso_pass(:,1),-T_iso_pass(:,2),'-.','Color',CsV(1,:),'LineWidth',2,...
    'DisplayName','Generic passive muscle stiffness (total moment)');

p1=plot(T_iso_pass(:,1),-T_iso_pass(:,3),'-.','Color',CsV(1,:),'LineWidth',1,...
    'DisplayName','Generic passive muscle stiffness (contribution of muscles)');




lg=legend('Location','southoutside','FontSize',12);
lg.Box = 'off';
xlabel('Angle (°)','FontSize',12)
ylabel('Moment (Nm)','FontSize',12)
title('Passive ankle moment','FontSize',12)
set(gca,'Fontsize',12);
xlim([-45,45])
ylim([-75,15])
lg.Layout.Tile = 'South';


%
FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\figures\draft/supplement';
figName = 'pass_iso_moment';
exportgraphics(fig1,fullfile(FigRepo,['figure_' figName '.jpeg']),'Resolution',300);
