

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

f_PF_stiffness_Song = f_getPlantarFasciaStiffnessModelCasADiFunction('Song2011','ls',ls);
F_PF_S = full(f_PF_stiffness_Song(l));

f_PF_stiffness_linear = f_getPlantarFasciaStiffnessModelCasADiFunction('linear','ls',ls);
F_PF_l = full(f_PF_stiffness_linear(l));

%%
figure
hold on
xlabel('\lambda (-)')
ylabel('Force (N)')
legend('Location','northwest')
ylim([0,2000])
plot(lambda,F_PF_G,'-','DisplayName','PF Gefen2002')
plot(lambda,F_PF_N,'-','DisplayName','PF Natali2010')
plot(lambda,F_PF_S,'-','DisplayName','PF Song2011')
plot(lambda,F_PF_l,'-','DisplayName','PF linear')

plot(lambda,F_PF_N*0.5,'-','DisplayName','PF Natali2010 /2')
plot(lambda,F_PF_G*3,'-','DisplayName','PF Gefen2002 *3')




