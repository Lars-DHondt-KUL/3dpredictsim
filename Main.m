%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script serves as the main file for the branch extended_foot_model. 
% It allows to specify the settings, solve, and post-process a single gait 
% simulation.
%
% Alternatively, the specified settings can be saved and added to a batch.
% To run the batch, use \RunSim\BatchRunQueue.m
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
%-------------------------------------------------------------------------%
% Full body gait simulation
run_simulation = 0;         % run solver
post_process_results = 0;   % postproces
add_to_batch_queue = 0;     % save settings to run later

% settings for optimization
S.v_tgt     = 1.33;     % average speed
S.N         = 50;       % number of mesh intervals
S.NThreads  = 6;        % number of threads for parallel computing
% S.max_iter  = 5;       % maximum number of iterations (comment -> 10000)
% S.linear_solver = 'ma86';

% S.tanh_b = 10;

% output folder
S.ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';
S.ResultsFolder = 'with_better_knee'; % 'with_better_knee'
% S.suffixCasName = '';     % suffix for name of folder with casadifunctions
% S.suffixName = 'N60';        % suffix for name of file with results

% Cost function weights
S.W.Ak      = 50000;    % weight joint accelerations
S.W.passMom = 1000;     % weight passive torques
S.W.noDamping = 1;
S.W.A       = 2000;     % weight muscle activations


%% Tracking term
S.TrackSim = 0;
S.Track.Q_ankle = 1;
S.Track.Q_subt = 1;
S.Track.Q_ref = 'mtjc4_custom';
S.W.Q_track = 1e4;


%% Foot model
%-------------------------------------------------------------------------%
% General
S.Foot.Model = 'mtj'; % 'mtjc4'
   % 'mtp': foot with mtp joint
   % 'mtj': foot with mtp and midtarsal joint
S.Foot.Scaling = 'custom'; % default, custom, personalised

% fixed knee axis
S.fixed_knee = 1;

% Achilles tendon stiffness
S.AchillesTendonScaleFactor = 0.5; % 0.5

% Triceps surae optimal force scale
S.TricepsFMoScale = 1.2; %round(1.2*0.8,2);

% Reduce tendon slack length of Soleus
S.SoleusTendonShorter = 0; %7e-3

% Reduce tendon slack length of gastrocnemius
S.GastrocTendonShorter = 0; %5e-3

% Shift passive force-length curve of ankle muscle fibers
S.passiveFiberForceShift = -0.1; %-0.1

% Tibialis anterior according to Rajagopal et al. (2015)
S.tib_ant_Rajagopal2015 = 0;

% Use geometry polynomials from old simulation (mtpPin)
S.useMtpPinPoly = 0;

% Use skeletal dynamics from old simulation (mtpPin)
S.useMtpPinExtF = 0;

% use custom muscle-tendon parameters
S.MTparams = 'MTc5';    % MTc5

% Contact spheres
S.Foot.contactStiffnessFactor = 10;  % 1 or 10, 10: contact spheres are 10x stiffer
S.Foot.contactGeometryVersion = -1; %(-1)
S.Foot.contactSphereOffsetY = 3; %(3)    % contact spheres are offset in y-direction to match static trial IK
S.Foot.contactSphereOffset45Z = 0; % contact spheres 4 and 5 are offset to give wider contact area
S.Foot.contactSphereOffset1X = 0.0;   % heel contact sphere offset in x-direction (0.025)

%% metatarsophalangeal (mtp) joint
if strcmp(S.Foot.Model(1:3),'mtp')
    % preset for passive mtp
    S.Foot.mtp_muscles = 0;     % extrinsic toe flexors and extensors act on mtp joint
    S.Foot.kMTP = 25;            % additional stiffness of the joint (Nm/rad)
    S.Foot.dMTP = 2;          % additional damping of the joint (Nms/rad)
else
    % preset for muscle-driven mtp
    S.Foot.mtp_muscles = 1;     % extrinsic toe flexors and extensors act on mtp joint
    S.Foot.kMTP = 1;            % additional stiffness of the joint (Nm/rad)
    S.Foot.dMTP = 0.1;          % additional damping of the joint (Nms/rad)
end
% S.Foot.mtp_muscles = 0;     % extrinsic toe flexors and extensors act on mtp joint
% S.Foot.kMTP = 25;            % additional stiffness of the joint (Nm/rad)
% S.Foot.dMTP = 2;          % additional damping of the joint (Nms/rad)

S.Foot.mtp_tau_pass = 1;    % use passive bushing torque
S.Foot.mtp_M_PF = 0;        % apply plantar fascia stiffness to mtp joint only
S.Foot.mtp_actuator = 0;    % use an ideal torque actuator

%% midtarsal joint 
% (only used if Model = mtj)
S.Foot.mtj_muscles = 1;  % joint interacts with extrinsic foot muscles
% lumped ligaments (long, short planter ligament, etc)
S.Foot.MT_li_nonl = 1;       % 1: nonlinear torque-angle characteristic
S.Foot.mtj_stiffness = 'MG_exp5_table';%'MG_exp5_table'
S.Foot.mtj_sf = 1; 

S.Foot.kMT_li = 0;        % angular stiffness in case of linear
S.Foot.kMT_li2 = 0;        % angular stiffness in case of signed linear
S.Foot.dMT = 0.1;                % (Nms/rad) damping

% plantar fascia
S.Foot.PF_stiffness = 'Natali2010'; % 'none''linear''Gefen2002''Cheng2008''Natali2010''Song2011'
S.Foot.PF_sf = 1;
S.Foot.PF_sf_isvar = 0; 
S.Foot.PF_slack_length = 0.146; % (m) slack length

% Plantar Intrinsic Muscles represented by an ideal force actuator
S.Foot.PIM = 0;             % include PIM actuator
S.W.PIM = 5e4;              % weight on the excitations for cost function
S.W.P_PIM = 1e4;            % weight on the net Work for cost function

% Plantar Intrinsic Muscles represented by Flexor Digitorum Brevis
S.Foot.FDB = 0;             % include Flexor Digitorum Brevis
% optimal fibre length
S.Foot.FDB_lMo = 19.7e-3; % 19.7e-3 23e-3
% Tendon slack length
S.Foot.FDB_lTs = round(142.9 -0.9091*S.Foot.FDB_lMo*1e3)*1e-3; % 125mm at lMo=19.7mm, and 122 at 23
% Shift fiber passive force-length curve
S.Foot.FDB_shift = -0.1;
% scale FMo
S.Foot.FDB_sf_FMo = 1;

%% Initial guess
%-------------------------------------------------------------------------%


% initial guess identifier                  
S.IGsel         = 2;   % (1: quasi random, 2: data-based)
% initial guess mode identifier
S.IGmodeID      = 1;   % (1 walk, 2 run, 3 prev.solution, 4 solution from /IG/Data folder)

if S.IGmodeID == 4
    S.savename_ig   = 'NoExo';
elseif S.IGmodeID == 3
    S.ResultsF_ig   = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\different_speeds';
    S.savename_ig   = 'Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel24_ig1';
end


%% run simulation
PredSim(S,run_simulation,post_process_results,add_to_batch_queue);














