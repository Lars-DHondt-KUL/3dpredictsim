

clear
% close all
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/Musclemodel']);

%%
N = 100;
ls = 0.146;
l = linspace(ls,ls*1.1,N);
lambda = l/ls;

%% plantar fascia
f_PF_stiffness_Gefen = f_getPlantarFasciaStiffnessModelCasADiFunction('Gefen2002','ls',ls);
F_PF_G = full(f_PF_stiffness_Gefen(l));

f_PF_stiffness_Natali = f_getPlantarFasciaStiffnessModelCasADiFunction('Natali2010','ls',ls);
F_PF_N = full(f_PF_stiffness_Natali(l));

% f_PF_stiffness_Song = f_getPlantarFasciaStiffnessModelCasADiFunction('Song2011','ls',ls);
% F_PF_S = full(f_PF_stiffness_Song(l));
% 
% f_PF_stiffness_linear = f_getPlantarFasciaStiffnessModelCasADiFunction('linear','ls',ls);
% F_PF_l = full(f_PF_stiffness_linear(l));

%%
% figure
% hold on
% xlabel('\lambda (-)')
% ylabel('Force (N)')
% legend('Location','northwest')
% ylim([0,2000])
% plot(lambda,F_PF_G,'-','DisplayName','PF Gefen2002')
% plot(lambda,F_PF_N,'-','DisplayName','PF Natali2010')
% plot(lambda,F_PF_S,'-','DisplayName','PF Song2011')
% plot(lambda,F_PF_l,'-','DisplayName','PF linear')
% 
% plot(lambda,F_PF_N*0.5,'-','DisplayName','PF Natali2010 /2')
% plot(lambda,F_PF_G*3,'-','DisplayName','PF Gefen2002 *3')




%%

CsV = hsv(4);


h23=figure('Position',[750,500,350,250]);
hold on
xlabel('Strain (%)')
ylabel('Force (N)')
legend('Location','northeast')
title('Plantar fascia stiffness')
ylim([0,2000])
xlim([0,10])
eta = (lambda-1)*100;
plot(eta,F_PF_G,'-','Color',CsV(2,:),'DisplayName','compliant')
plot(eta,F_PF_N,'-','Color',CsV(3,:),'DisplayName','stiff')
plot(eta,F_PF_N*3,'-','Color',CsV(4,:),'DisplayName','3x stiff')

figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\Foot_Modeling_Meeting\2022_05_02\passive';
set(h23,'PaperPositionMode','auto')
print(h23,[figNamePrefix '_PF'],'-dpng','-r0')
