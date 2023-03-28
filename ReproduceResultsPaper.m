%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script aims to reproduce the simulation results shown in
%
% "A dynamic foot model for predictive simulations of gait reveals causal 
% relations between foot structure and whole body mechanics"
% https://www.biorxiv.org/content/10.1101/2023.03.22.533790v1
%
%
%
% Author: Lars D'Hondt
% Date: March 2023
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
close all
clc

%% Required user inputs
% Specify the folder where you downloaded CasADi
% (https://web.casadi.org/get/)
casadiPath = 'C:\GBW_MyPrograms\casadi_3_5_5';


%%
[pathRepo,~,~] = fileparts(mfilename('fullpath'));
addpath([pathRepo '/OCP']);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/Plots']);
addpath([pathRepo '/CasADiFunctions']);
addpath([pathRepo '/Musclemodel']);
addpath([pathRepo '/Polynomials']);
addpath([pathRepo '/FootModel']);
addpath([pathRepo '/RunSim']);

addpath(genpath(casadiPath))


%% Nominal 3-segment foot model

[S] = getSettingsNominalModel(3);


