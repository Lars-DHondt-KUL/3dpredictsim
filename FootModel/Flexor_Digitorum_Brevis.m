clear
close all
clc

pathmain = pwd;
[pathRepo,~,~]  = fileparts(pathmain);

%% parameters
% from: Tosovic, D., Ghebremedhin, E., Glen, C., Gorelick, M., & Mark Brown, J. 
% (2012). The architecture and contraction time of intrinsic foot muscles. 
% Journal of Electromyography and Kinesiology, 22(6), 930-938.

FDB_alphao = 20; % (°)
FDB_PCSA = 176; % (mm^2)
FDB_FL_ML = 0.27; % (-)

AH_alphao = 19; % (°)
AH_PCSA = 331; % (mm^2)
AH_FL_ML = 0.31; % (-)

% other parameters
FDB_sigma = getSpecificTensions({'FDB'}); % (N/mm^2)

%%
alphao = FDB_alphao*pi/180; % (rad)
PCSA = FDB_PCSA + AH_PCSA; % (mm^2)
FMo = PCSA*FDB_sigma; % (N)

lMT0 = 0.146; % (m) plantar fascia slack length
ML = lMT0*0.5; % Muscle belly has the same length as free tendon (visually estimated)
FL = ML*FDB_FL_ML; % (m) fibre length
lMo = FL; % (m) optimal fibre length

% lMo = 23e-3;

lTs = lMT0 - lMo*cos(alphao); % (m) the tendon covers the remaining length

%%
FDBparameters(1,1) = FMo;
FDBparameters(2,1) = lMo;
FDBparameters(3,1) = lTs;
FDBparameters(4,1) = alphao;
FDBparameters(5,1) = 10*lMo;

%%

% pathMusc = fullfile(pathRepo,'MuscleModel','Fal_s1_mtj_sc');

% save(fullfile(pathMusc,'FDBparameters.mat'),'FDBparameters');

%%
% lMT = 0.95*lMT0;
% 
% lM = sqrt((lMo.*sin(alphao)).^2+(lMT-lTs.*1).^2);
% 
% lMtilde = lM/lMo



