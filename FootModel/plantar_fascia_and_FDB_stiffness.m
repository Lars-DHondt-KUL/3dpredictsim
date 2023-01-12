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


%% Generic muscle propertie
aTendon = 35;
shift = getShift(aTendon);
pass_shift = -0.1;
tension = 0.7;

load Fvparam
load Fpparam
load Faparam

%% FDB parameters
% from: Tosovic, D., Ghebremedhin, E., Glen, C., Gorelick, M., & Mark Brown, J. 
% (2012). The architecture and contraction time of intrinsic foot muscles. 
% Journal of Electromyography and Kinesiology, 22(6), 930-938.

FDB_alphao = 20; % (°)
FDB_PCSA = 176; % (mm^2)
FDB_FL_ML = 0.27; % (-)

AH_alphao = 19; % (°)
AH_PCSA = 331; % (mm^2)
AH_FL_ML = 0.31; % (-)

% derive parameters needed for model
alphao = FDB_alphao*pi/180; % (rad)
PCSA = FDB_PCSA + AH_PCSA; % (mm^2)
PCSA = PCSA*2;
FMo = PCSA*tension; % (N)

lMT0 = ls; % (m) plantar fascia slack length
ML = lMT0*0.5; % Muscle belly has the same length as free tendon (visually estimated)
FL = ML*FDB_FL_ML; % (m) fibre length
lMo = FL; % (m) optimal fibre length

% lMo = 23e-3;

lTs = lMT0 - lMo*cos(alphao); % (m) the tendon covers the remaining length
% lTs = 0.125;
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
lTs_vec = 0.12:0.0025:0.13;
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
end
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
