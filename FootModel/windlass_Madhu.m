clear
% close all
clc


[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/Musclemodel']);


load('C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_pp.mat','R')

% load('C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel27_ig23_igmtp_pp.mat','R')

% load('C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_MTJp_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21_pp.mat','R')

isPassive = 0;

import casadi.*

pathCasADiFunctions = [pathRepo,'/CasADiFunctions'];
PathDefaultFunc = fullfile(pathCasADiFunctions,R.S.CasadiFunc_Folders);

f_PF_stiffness = Function.load(fullfile(PathDefaultFunc,'f_PF_stiffness'));
f_passiveMoment_mtj = Function.load(fullfile(PathDefaultFunc,'f_passiveMoment_mtj'));
f_lLi_vLi_dM = Function.load(fullfile(PathDefaultFunc,'f_lLi_vLi_dM'));

iFDB = find(strcmp(R.colheaders.muscles,'FDB_r'));
imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));

%%
lTs = 0.125;
FMo = 700;
lMo = 0.0197;
alphao = 0.3491;
params(1,1) = FMo;
params(2,1) = lMo;
params(3,1) = lTs;
params(4,1) = alphao;
params(5,1) = 10*lMo;

load Fvparam
load Fpparam
load Faparam

a_fun = MX.sym('a',1);
lMT_fun = MX.sym('lMT',1);
FT_fun = MX.sym('FT',1);
FTtilde_fun = FT_fun/FMo;
dFTtilde_fun = MX.sym('dFTtilde',1);

[Hilldiff_fun,~,~,~,~,~,~] = ...
    ForceEquilibrium_FtildeState_all_tendon(a_fun,FTtilde_fun,dFTtilde_fun,lMT_fun,...
    0,params(:,1),Fvparam,Fpparam,Faparam,0.7,35,0,0,-0.1);

f_FDB_Hilldiff = Function('f_FDB_Hilldiff',{FT_fun,a_fun,lMT_fun,dFTtilde_fun},{Hilldiff_fun});

f_FDB = rootfinder('f_FDB','newton',f_FDB_Hilldiff);

F_PF = f_PF_stiffness(lMT_fun);
F_FDB = f_FDB(FMo,a_fun,lMT_fun,dFTtilde_fun);

if isPassive
    F_pl = F_PF;
else
    F_pl = F_PF + F_FDB;
end
k_pl = jacobian(F_pl,lMT_fun);

f_plantar = Function('f_plantar',{a_fun,lMT_fun,dFTtilde_fun},{F_pl,k_pl});

%%
q_mtj = MX.sym('q_mtj',1);
T_mtj = -f_passiveMoment_mtj(q_mtj,0);

k_mtj_MX = jacobian(T_mtj,q_mtj);

f_k_mtj = Function('f_k_mtj',{q_mtj},{k_mtj_MX});



%%
k_PF = nan(1,100);
k_mtj = nan(1,100);

for i=1:100
    if isPassive
        [F_PFi,k_PFi] = f_plantar(0,R.windlass.l_PF(i),0);
    else
        [F_PFi,k_PFi] = f_plantar(R.a(i,iFDB),R.lMT(i,iFDB),R.dFTtilde(i,iFDB));
    end
    k_PF(i) = full(k_PFi);

    k_mtji = f_k_mtj(R.Qs(i,imtj)*pi/180);
    k_mtj(i) = full(k_mtji);
end
%%
istance = 1:100;
% istance = 1:57;

k_p = k_PF(istance);
k_m = k_mtj(istance);
h = -R.windlass.MA_PF.mtj(istance);
r = -R.windlass.MA_PF.mtp(istance);
% r = 9.5e-3*ones(size(r));

sf = sqrt(abs(k_m./k_p));

h_hat = h./sf';
r_hat = r./sf';

%%

right_side = h_hat./(1+h_hat.^2);

dphi = max(R.Qs((istance),imtj)) - R.Qs((istance),imtj);
left_side = dphi./(R.Qs((istance),imtp).*r_hat);

%%

figure
p1=plot(h_hat,left_side,'.','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$');
hold on
p2=plot(h_hat,right_side,'.','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$');
xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')

% xlim([0,10])

plot(h_hat(1),left_side(1),'o','Color',p1.Color)
plot(h_hat(10),left_side(10),'*','Color',p1.Color)
plot(h_hat(35),left_side(35),'+','Color',p1.Color)
plot(h_hat(57),left_side(57),'x','Color',p1.Color)

plot(h_hat(1),right_side(1),'o','Color',p2.Color)
plot(h_hat(10),right_side(10),'*','Color',p2.Color)
plot(h_hat(35),right_side(35),'+','Color',p2.Color)
plot(h_hat(57),right_side(57),'x','Color',p2.Color)

legend([p1,p2],Location="best",Interpreter="latex",FontSize=20)

%%

figure
tiledlayout("flow")
xsc = [0,ceil(max(h_hat))+1];
ysc = [0,max([left_side;right_side])];
xsc(2) = min([xsc(2),50]);


nexttile
hold on
idx = 1:10;
p1=plot(h_hat(idx),left_side(idx),'.','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$');
p2=plot(h_hat(idx),right_side(idx),'.','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$');
xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
title([num2str(idx(1)) '-' num2str(idx(end)) ' % GC'])
xlim(xsc)
ylim(ysc)

nexttile
hold on
idx = 11:35;
plot(h_hat(idx),left_side(idx),'.','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$','Color',p1.Color);
plot(h_hat(idx),right_side(idx),'.','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$','Color',p2.Color);
xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
title([num2str(idx(1)) '-' num2str(idx(end)) ' % GC'])
xlim(xsc)
ylim(ysc)
legend(Location="northeast",Interpreter="latex",FontSize=20)

nexttile
hold on
idx = 36:57;
plot(h_hat(idx),left_side(idx),'.','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$','Color',p1.Color);
plot(h_hat(idx),right_side(idx),'.','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$','Color',p2.Color);
xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
title([num2str(idx(1)) '-' num2str(idx(end)) ' % GC'])
xlim(xsc)
ylim(ysc)

nexttile
hold on
idx = 58:100;
plot(h_hat(idx),left_side(idx),'.','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$','Color',p1.Color);
plot(h_hat(idx),right_side(idx),'.','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$','Color',p2.Color);
xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
title([num2str(idx(1)) '-' num2str(idx(end)) ' % GC'])
xlim(xsc)
ylim(ysc)

%%

figure
tiledlayout("flow")
xsc = [0,ceil(max(h_hat))+1];
ysc = [0,max([left_side;right_side])];
% xsc(2) = min([xsc(2),6]);
% ysc(2) = min([ysc(2),1.5]);

nexttile
hold on
idx = 1:10;
p1=plot(h_hat(idx),left_side(idx),'.-','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$');
p2=plot(h_hat(idx),right_side(idx),'.-','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$');
xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
title([num2str(idx(1)) '-' num2str(idx(end)) ' % GC'])
xlim(xsc)
ylim(ysc)

nexttile
hold on
idx = 11:35;
plot(h_hat(idx),left_side(idx),'.-','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$','Color',p1.Color);
plot(h_hat(idx),right_side(idx),'.-','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$','Color',p2.Color);
xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
title([num2str(idx(1)) '-' num2str(idx(end)) ' % GC'])
xlim(xsc)
ylim(ysc)
legend(Location="northeast",Interpreter="latex",FontSize=20)

nexttile
hold on
idx = 36:57;
plot(h_hat(idx),left_side(idx),'.-','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$','Color',p1.Color);
plot(h_hat(idx),right_side(idx),'.-','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$','Color',p2.Color);
xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
title([num2str(idx(1)) '-' num2str(idx(end)) ' % GC'])
xlim(xsc)
ylim(ysc)

nexttile
hold on
idx = 58:100;
plot(h_hat(idx),left_side(idx),'.-','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$','Color',p1.Color);
plot(h_hat(idx),right_side(idx),'.-','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$','Color',p2.Color);
xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
title([num2str(idx(1)) '-' num2str(idx(end)) ' % GC'])
xlim(xsc)
ylim(ysc)


%%

% idxpo = 35:57;
% figure
% p1=plot(h_hat(idxpo),left_side(idxpo),'.','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$');
% hold on
% p2=plot(h_hat(idxpo),right_side(idxpo),'.','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$');
% xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
% ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
% 
% idxpo = 10:35;
% figure
% p1=plot(h_hat(idxpo),left_side(idxpo),'.','DisplayName','\rm$\frac{\Delta\phi}{\theta \hat{r}}$');
% hold on
% p2=plot(h_hat(idxpo),right_side(idxpo),'.','DisplayName','\rm$\frac{\hat{h}}{1+\hat{h}^2}$');
% xlabel('\rm$\hat{h}$',Interpreter='latex',FontSize=14)
% ylabel('\rm$\frac{\Delta\phi}{\theta \hat{r}}$',Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')


%%

figure
p1=plot(R.Qs(:,imtj),-R.Tid(:,imtj),'.');
hold on
xlabel('mtj angle (°)')
ylabel('mtj torque (Nm)')
yyaxis right
p2=plot(R.Qs(:,imtj),R.Qs(:,imtp),'.');
ylabel('mtp angle (°)')

yyaxis left
plot(R.Qs(1,imtj),-R.Tid(1,imtj),'o','Color',p1.Color)
plot(R.Qs(10,imtj),-R.Tid(10,imtj),'*','Color',p1.Color)
plot(R.Qs(35,imtj),-R.Tid(35,imtj),'+','Color',p1.Color)
plot(R.Qs(57,imtj),-R.Tid(57,imtj),'x','Color',p1.Color)


yyaxis right
plot(R.Qs(1,imtj),R.Qs(1,imtp),'o','Color',p2.Color)
plot(R.Qs(10,imtj),R.Qs(10,imtp),'*','Color',p2.Color)
plot(R.Qs(35,imtj),R.Qs(35,imtp),'+','Color',p2.Color)
plot(R.Qs(57,imtj),R.Qs(57,imtp),'x','Color',p2.Color)



%%

q_mtp = [-5,0:10:50];
q_mtj = -10:0.05:10;

M_mtj = -full(f_passiveMoment_mtj(q_mtj(:)*pi/180,0))';

figure
hold on

for i=1:length(q_mtp)
    for j=1:length(q_mtj)
        [l_PFj,~,MA_PFj] =  f_lLi_vLi_dM([q_mtj(j),q_mtp(i)]*pi/180,[0,0]);

        F_PFj = f_PF_stiffness(l_PFj);
        M_PFj = MA_PFj(1)*F_PFj;
        M_PF(i,j) = -full(M_PFj);

    end

    plot(q_mtj,M_PF(i,:)+M_mtj,'DisplayName',['q mtp = ' num2str(q_mtp(i)) '°'])
end

plot(R.Qs(:,imtj),-R.Tid(:,imtj),'.k','DisplayName','simulated');

plot(q_mtj,q_mtj*62/2.5)
legend('Location','best')
xlabel('q mtj (°)')
ylabel('M mtj (Nm)')
ylim([-10,80])


















