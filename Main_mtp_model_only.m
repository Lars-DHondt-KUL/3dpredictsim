%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script serves as the main file for the branch extended_foot_model. 
% It allows to specify the settings, solve, and post-process a single gait 
% simulation.
%
% This is the simplified main: FOR MTP-MODEL ONLY
%
% To plot results, use \Plots\make_any_plot.m
%
% Simulating gait for a new OpenSim model requires 2 preparation steps:
%   1) Generate external function describing the skeleton and contact
%   dynamics. See https://github.com/Lars-DHondt-KUL/opensimAD.
%
%   2) Read muscle-tendon parameters and, approximate musculoskeletal 
%   geometry by running \ConvertOsimModel\PrepareOptimization.m 
%
% Author: Lars D'Hondt
% Date: December 2021
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
close all
clc

%% Paths
[pathRepo,~,~] = fileparts(mfilename('fullpath'));
addpath([pathRepo '/OCP']);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/Plots']);
addpath([pathRepo '/CasADiFunctions']);
addpath([pathRepo '/Musclemodel']);
addpath([pathRepo '/Polynomials']);
addpath([pathRepo '/Debug']);
addpath([pathRepo '/FootModel']);
addpath([pathRepo '/RunSim']);
AddCasadiPaths();

%% General settings

% Full body gait simulation
run_simulation = 1;         % run solver
post_process_results = 0;   % postproces

% settings for optimization
S.NThreads  = 6;        % number of threads for parallel computing
S.max_iter  = 10;       % maximum number of iterations (comment -> 10000)

% output folder
S.ResultsFolder = 'debug'; % subfolder of \Results where the result will be saved
% S.suffixCasName = 'v2';     % suffix for name of folder with casadifunctions
% S.suffixName = 'test';        % suffix for name of file with results

%% Subject
S.subject   = 'Fal_s1';
S.mass      = 62;
S.v_tgt     = 1.33;     % average speed
S.OsimFileName = 'Fal_s1_mtp_sc';

%% metatarsophalangeal (mtp) joint
S.Foot.mtp_actuator = 0;    % use an ideal torque actuator
S.Foot.mtp_muscles = 0;     % extrinsic toe flexors and extensors act on mtp joint
S.Foot.kMTP = 17;           % additional stiffness of the joint (Nm/rad)
S.Foot.dMTP = 0.5;          % additional damping of the joint (Nms/rad)
S.Foot.mtp_tau_pass = 0;    % use passive bushing torque


%% Initial guess


% initial guess identifier                  
S.IGsel         = 2;   % (1: quasi random, 2: data-based)
% initial guess mode identifier
S.IGmodeID      = 1;   % (1 walk, 2 run, 3 prev.solution, 4 solution from /IG/Data folder)

if S.IGmodeID == 4
    S.savename_ig   = 'NoExo';
elseif S.IGmodeID == 3
    S.ResultsF_ig   = '';
    S.savename_ig   = 'Fal_s1_bCst_ig21';
end


%% run simulation
PredSim(S,run_simulation,post_process_results,0);














