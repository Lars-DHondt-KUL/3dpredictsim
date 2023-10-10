clear
close all
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/Musclemodel']);

%%
N = 100;
ls = 0.146;
l = linspace(ls,ls*1.04,N);
lambda = l/ls;

%% plantar fascia
f_PF_stiffness_Gefen = f_getPlantarFasciaStiffnessModelCasADiFunction('Gefen2002','ls',ls);
F_PF_G = full(f_PF_stiffness_Gefen(l));

f_PF_stiffness_Natali = f_getPlantarFasciaStiffnessModelCasADiFunction('Natali2010','ls',ls);
F_PF_N = full(f_PF_stiffness_Natali(l));


%% Generic muscle propertie
aTendon = 35;
shift = getShift(aTendon);
pass_shift = -0.1;
tension = 0.7;

load Fvparam
load Fpparam
load Faparam

%% FDB parameters
FMo = 600;
alphao = 20*pi/180;
lMo = 23e-3;

lMT0 = ls; % (m) plantar fascia slack length


lTs = lMT0 - lMo*cos(alphao); % (m) the tendon covers the remaining length
lTs = 0.123;
FDBparameters(1,1) = FMo;
FDBparameters(2,1) = lMo;
FDBparameters(3,1) = lTs;
FDBparameters(4,1) = alphao;
FDBparameters(5,1) = 10*lMo;

%% Solve for tendon force
a = [0,0.5,1]; % activity

% allocate result matrices
FT_FDB = zeros(N,length(a));
lMtilde = FT_FDB;
lTtilde = FT_FDB;
% solver options
options = optimset('Display','off');
% initial guess
FT0 = 0;

for j=1:length(a)
    for i=1:N
        fun = @(FTt) getHilldiffFun(FTt,a(j),l(i),FDBparameters,Fvparam,Fpparam,Faparam,tension,aTendon,shift,pass_shift);
        FTtilde_i = fsolve(fun,FT0,options);
        FT_FDB(i,j) = FTtilde_i*FMo;
        FT0 = FTtilde_i; % warm-start for next length

        % Find normalized fiber length
        [~,lMtilde_i,lT_i] = FiberLength_TendonForce_tendon(FTtilde_i,FDBparameters,l(i),aTendon,shift);
        lMtilde(i,j) = lMtilde_i;
        lTtilde(i,j) = lT_i/FDBparameters(3,1);
    end
end

figure
hold on
for j=1:length(a)
    plot(lambda,FT_FDB(:,j),'DisplayName',['FDB a = ' num2str(a(j))])
end
xlabel('\lambda (-)')
ylabel('Force (N)')
title('Flexor Digitorum Brevis')
legend('Location','northwest')

%% Solve for tendon force
a = 0.5; % activity
% lTs_vec = 0.12:0.0025:0.13;
lTs_vec = 0.115:0.001:0.130;
N1 = length(lTs_vec);

% allocate result matrices
FT_FDB = zeros(N,N1);
lMtilde = FT_FDB;
lTtilde = FT_FDB;
% solver options
options = optimset('Display','off');
% initial guess
FT0 = 0;

for j=1:N1
    FDBparameters(3,1) = lTs_vec(j);

    for i=1:N
        fun = @(FTt) getHilldiffFun(FTt,a,l(i),FDBparameters,Fvparam,Fpparam,Faparam,tension,aTendon,shift,pass_shift);
        FTtilde_i = fsolve(fun,FT0,options);
        FT_FDB(i,j) = FTtilde_i*FMo;
        FT0 = FTtilde_i; % warm-start for next length

        % Find normalized fiber length
        [~,lMtilde_i,lT_i] = FiberLength_TendonForce_tendon(FTtilde_i,FDBparameters,l(i),aTendon,shift);
        lMtilde(i,j) = lMtilde_i;
        lTtilde(i,j) = lT_i/FDBparameters(3,1);
    end
end

figure
sgtitle({'Plantar intrinsic muscle with plantar fascia in parallel',['Static equibibrium for act = ' num2str(a)]})
subplot(2,2,1)
hold on
for j=1:N1
    plot(lambda,FT_FDB(:,j),'DisplayName',['FDB lTs = ' num2str(lTs_vec(j))])
end
xlabel('\lambda (-)')
ylabel('Force (N)')
title('Flexor Digitorum Brevis')
legend('Location','northwest')
ylim([0,2000])
plot(lambda,F_PF_G,'--','DisplayName','PF Gefen2002')
plot(lambda,F_PF_N,'--','DisplayName','PF Natali2010')

subplot(2,2,2)
hold on
for j=1:N1
    plot(lambda,F_PF_N'+FT_FDB(:,j),'DisplayName',['FDB lTs = ' num2str(lTs_vec(j))])
end
xlabel('\lambda (-)')
ylabel('Force (N)')
title('Flexor Digitorum Brevis + Plantar Fascia')
legend('Location','northwest')
ylim([0,2000])
plot(lambda,F_PF_G,'--','DisplayName','PF Gefen2002')
% plot(lambda,F_PF_N/2,'--','DisplayName','PF Natali2010 /2')
plot(lambda,F_PF_N,'--','DisplayName','PF Natali2010')
plot(lambda,F_PF_N*3,'--','DisplayName','PF Natali2010 x3')

subplot(2,2,3)
hold on
for j=1:N1
    plot(lambda,lMtilde(:,j),'DisplayName',['FDB lTs = ' num2str(lTs_vec(j))])
%     disp(['FDB lTs = ' num2str(lTs_vec(j)) '      ' num2str(mean(lMtilde(:,j)))]);
end

[~, idx_min] = min(abs(mean(lMtilde,1)-1));
lTs_sel = lTs_vec(idx_min);
disp(['FDB lTs = ' num2str(lTs_sel) ' mm']);

xlabel('\lambda (-)')
ylabel('lMtilde (-)')
title('Fiber length')
legend('Location','northwest')

subplot(2,2,4)
hold on
for j=1:N1
    plot(lambda,lTtilde(:,j),'DisplayName',['FDB lTs = ' num2str(lTs_vec(j))])
end
xlabel('\lambda (-)')
ylabel('lTtilde (-)')
title('Tendon length')
legend('Location','northwest')


%%

function Hilldiff_fun = getHilldiffFun(FTtilde_fun,a_fun,lMT_fun,params_fun,...
    Fvparam_fun,Fpparam_fun,Faparam_fun,tension_fun,aTendon_fun,shift_fun,pass_shift_fun)

[Hilldiff_fun,~,~,~,~,~,~] = ...
    ForceEquilibrium_FtildeState_all_tendon(a_fun,FTtilde_fun,0,lMT_fun,...
    0,params_fun(:,1),Fvparam_fun,Fpparam_fun,Faparam_fun,tension_fun,...
    aTendon_fun,shift_fun,0,pass_shift_fun);

end
