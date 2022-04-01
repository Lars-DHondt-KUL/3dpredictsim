
clear
close all
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

load(fullfile(pathRepo,'Polynomials','Fal_s1_mtp_sc_Sv50','MuscleData.mat'))

muscle_names = MuscleData.muscle_names;

load(fullfile(pathRepo,'MuscleModel','Fal_s1_mtp_sc_Sv50','MTparameters.mat'))

iSol = find(strcmp(muscle_names,'soleus_r'));

disp(MTparameters(5,iSol))

MTparameters(5,iSol) = 0.5*MTparameters(5,iSol);

disp(MTparameters(5,iSol))

save(fullfile(pathRepo,'MuscleModel','Fal_s1_mtp_sc_Sv50','MTparameters.mat'),'MTparameters')


