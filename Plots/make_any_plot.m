%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script allows to plot any of the results from the Thesis_Lars
% branch. See \3dpredictsim\Plots\make_preselected_plots.m to generate
% figures preselected groups of results.
% 
% Select one or more folders with results to choose from. Then set
% values to the parameters you want to filter out. Put the paramaters in
% comment if you want to see results for any value. 
% The filter method relies on the name of the resultfile, so this does
% limit the possible filter criteria. 
% Line 127-133 shows how to manually add more filter criteria. It will only
% return filenames which contain that string. Use 'not_string' to get the
% filenames that do not contain 'string'.
% If no file in a folder contains a given string, that criterium will be
% dropped, for that folder only.
%
% Author: Lars D'Hondt (Dec 2021)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear 
close all
clc

%% Paths
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/FootModel']);


%% Folder(s) with results
ResultsFolder = {'debug'};

%% General information
S.subject = 'Fal_s1';

% S.suffixCasName = 'v3';     % suffix for name of folder with casadifunctions
% S.suffixName = 'v4';        % suffix for name of file with results


%% Tracking term
% S.TrackSim = 1;
% S.Track.Q_ankle = 1;
% S.Track.Q_subt = 1;

%% Foot model
%-------------------------------------------------------------------------%
% General
% S.Foot.Model = 'mtjc2';
   % 'mtp': foot with mtp joint
   % 'mtj': foot with mtp and midtarsal joint
% S.Foot.Scaling = 'custom'; % default, custom, personalised

% Achilles tendon
% S.AchillesTendonScaleFactor = 1;

% Tibialis anterior according to Rajagopal et al. (2015)
S.tib_ant_Rajagopal2015 = 0;

% Use geometry polynomials from old simulation (mtpPin)
S.useMtpPinPoly = 0;

% Use skeletal dynamics from old simulation (mtpPin)
S.useMtpPinExtF = 0;

% use custom muscle-tendon parameters
% S.MTparams = 'MTc2';

% Contact spheres
% S.Foot.contactStiffnessFactor = 10;  % 1 or 10, 10: contact spheres are 10x stiffer
% S.Foot.contactSphereOffsetY = 2;    % contact spheres are offset in y-direction to match static trial IK
% S.Foot.contactSphereOffset45Z = 0; % contact spheres 4 and 5 are offset to give wider contact area
% S.Foot.contactSphereOffset1X = 0;   % heel contact sphere offset in x-direction

%% metatarsophalangeal (mtp) joint
S.Foot.mtp_actuator = 0;    % use an ideal torque actuator
S.Foot.mtp_muscles = 1;     % extrinsic toe flexors and extensors act on mtp joint
S.Foot.kMTP = 1;            % additional stiffness of the joint (Nm/rad)
S.Foot.dMTP = 0.1;          % additional damping of the joint (Nms/rad)

%% midtarsal joint 
% (only used if Model = mtj)
S.Foot.mtj_muscles = 1;  % joint interacts with extrinsic foot muscles
% lumped ligaments (long, short planter ligament, etc)
% S.Foot.MT_li_nonl = 1;       % 1: nonlinear torque-angle characteristic
% S.Foot.mtj_stiffness = 'MG_exp_table';
% S.Foot.mtj_sf = 1; 

% S.Foot.kMT_li = 200;        % angular stiffness in case of linear
% S.Foot.kMT_li2 = 10;        % angular stiffness in case of signed linear
% S.dMT = 0.1;                % (Nms/rad) damping

% plantar fascia
% S.Foot.PF_stiffness = 'Natali2010'; % 'none''linear''Gefen2002''Cheng2008''Natali2010''Song2011'
% S.Foot.PF_sf = 5;
% S.Foot.PF_slack_length = 0.146; % (m) slack length

% Plantar Intrinsic Muscles represented by and ideal force actuator
% S.Foot.PIM = 0;             % include PIM actuator
% S.W.PIM = 5e4;              % weight on the excitations for cost function
% S.W.P_PIM = 1e4;            % weight on the net Work for cost function



% initial guess
% S.IGsel         = 2;    % initial guess identifier (1: quasi random, 2: data-based)
% S.IGmodeID      = 3;    % initial guess mode identifier (1 walk, 2 run, 3prev.solution, 4 solution from /IG/Data folder)


% Plantar Intrinsic Muscles represented by Flexor Digitorum Brevis
% S.Foot.FDB = 1;             % include Flexor Digitorum Brevis



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% results = {
% %     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Gefen2002_ls146_PIM_w1e+03_w1e+04_ig21'
% %     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Gefen2002_ls146_PIM_w1e+03_w1e+05_ig21'
% %     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Gefen2002_ls146_PIM_w1e+04_w1e+05_ig21'
%     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Gefen2002_ls146_PIM_w1e+05_w1e+05_ig21'
%     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Gefen2002_ls146_PIM_w2e+04_w1e+05_ig21'
%     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Gefen2002_ls146_PIM2_w1e+05_w1e+05_ig21'
%     };

% results = {
%     '\debug\Fal_s1_mtj_sc_cspx10_oy_ATx70_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Gefen2002_ls146_PIM2_w5e+04_w1e+04_ig21'
%     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Gefen2002_ls146_FDB_ig21'
%     };

% results = {
%     '\MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T1_spx10_ig23_PFx10_v133'
%     '\MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T1_spx10_ig23_PFx10_spx10'
%     '\Final\Fal_s1_bCst_ig21'
%     };

% results = {
% %     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Gefen2002_ls146_ig21'
% %     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Natali2010_ls146_ig21'
%     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Natali2010_x5_ls146_ig21'
% %     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPp_k1_d01_MTJp_nl_MG_exp_table_d01_PF_Natali2010_x5_ls146_ig21'
% %     '\debug\Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d01_MTJm_nl_MG_exp_table_d01_PF_Natali2010_x10_ls146_ig21'
%     };

% results = {
%     '\debug\Fal_s1_mtj_sc_cspx10_oy_TrackAnkleQSubtQ_MTPm_k1_d01_MTJm_nl_MG_exp_v2_table_d01_PF_Natali2010_x2_ls146_FDB_ig21'
%     '\debug\Fal_s1_mtj_sc_cspx10_oy_TrackAnkleQSubtQ_MTc2_MTPm_k1_d01_MTJm_nl_MG_exp_v2_table_d01_PF_Natali2010_ls146_FDB_ig21'
%     };

% results = {
%     '\debug\Fal_s1_mtj_sc_cspx10_oy_TrackAnkleQSubtQ_MTc2_MTPm_k1_d01_MTJm_nl_MG_exp_v2_table_d01_PF_Natali2010_ls146_FDB_ig21'
%     '\debug\Fal_s1_mtjc_sc_cspx10_oy_TrackAnkleQSubtQ_MTc2_MTPm_k1_d01_MTJm_nl_MG_exp_v2_table_d01_PF_Natali2010_ls146_FDB_ig21'
%     };

% results = {
%     '/debug\Fal_s1_mtp_sd_MTPp_k17_d05_ig21'
%     '/debug\Fal_s1_mtp_sc_MTPp_k17_d05_ig21'
%     };

if exist('results','var') && ~isempty(results)
    filteredResults = {length(results)};
    for i=1:length(results)
        filteredResults{i} = fullfile(pathRepo, 'Results', [results{i} '_pp.mat']);
    end
else

    % get file names
    pathResult = {numel(ResultsFolder)};
    for i=1:numel(ResultsFolder)
        pathResult{i} = fullfile([pathRepo '/Results/' ResultsFolder{i}]);
    end
    
    
    % get filter criteria
    [~,~,criteria] = getSavename(S);
    
%     criteria{end+1} = 'not_PIM';
%     criteria{end+1} = 'not_FDB';
    criteria{end+1} = 'not_o1x25';
    criteria{end+1} = 'not_o45z10';
%     criteria{end+1} = 'not_Track';
    criteria{end+1} = 'not_table_x5';
    criteria{end+1} = 'not_test';
%     criteria{end+1} = 'not_mtjc';
%     criteria{end+1} = 'not_o45z10';
%     criteria{end+1} = 'not_MTc';
    criteria{end+1} = 'not_old';
    criteria{end+1} = 'not___v1';
    criteria{end+1} = 'not_ig24';
    criteria{end+1} = 'oy2';
%     criteria{end+1} = 'AT';
%     criteria{end+1} = 'not_cspx10';
    
    % filter filenames
    [filteredResults] = filterResultfolderByParameters(pathResult,criteria);
    
    for i=1:numel(filteredResults)
        rfpathi = filteredResults{i};
        idx_i = strfind(rfpathi,'\');
        disp(rfpathi(idx_i(end-1):end));
    end

end
ref = {};

ref{end+1} = fullfile([pathRepo '/Results/debug\Fal_s1_mtp_sd_MTPp_k17_d05_ig21_pp.mat']);
% ref{end+1} = fullfile([pathRepo '/Results/debug\Fal_s1_mtp_sc_MTPp_k17_d05_ig21_pp.mat']);
% ref{end+1} = fullfile([pathRepo '/Results/debug\Fal_s1_mtp_sc_cspx10_oy_MTPp_k17_d05_ig21_pp.mat']);
% ref{end+1} = fullfile([pathRepo '/Results/debug\Fal_s1_mtp_sd_MTPm_k1_d05_ig21_pp.mat']);
% ref{end+1} = fullfile([pathRepo '/Results/debug\Fal_s1_mtp_sc_MTPm_k1_d01_ig21_pp.mat']);


filteredResultsWithRef = filteredResults';
filteredResultsWithRef = [ref, filteredResults]';
% filteredResultsWithRef = [filteredResults, ref]';


ResultsFile = filteredResultsWithRef;


%%
% compare_Lundgren_2008(ResultsFile{1});

%%
% LegNames = {'scaled default', 'scaled custom'};

% LegNames = {'mtp-model, passive', 'mtp-model, muscle', 'mtj-model, muscle, compliant PF',...
%     'mtj-model, muscle, stiff PF'};

% LegNames = {'mtp-model, passive','mtj-model, muscle, compliant PF',...
%     'mtj-model, muscle, stiff PF'};

LegNames = {'mtp-model, passive', 'mtj-model, muscle, stiff PF'};

% LegNames = {'Soleus 100% vMmax', 'Soleus 50% vMmax', 'Soleus 80% vMmax'};

% LegNames = {'mtp-model, passive','mtj, muscle,  PF Gefen2002','mtj, muscle, PF Natali2010',...
%     'mtj, muscle, 5x PF Natali2010', 'mtj, passive, 5x PF Natali2010', 'mtj, muscle, 10x PF Natali2010'};

mtj = 1;
figNamePrefix = 'none';
% figNamePrefix = 'C:\Users\u0150099\Documents\WTK\thesis\figuren\extended_foot_model\musc';
% figNamePrefix = 'C:\Users\u0150099\Documents\PhD\meetings\Model_Personalization_Meeting\stance';

%%% select figures to make
makeplot.kinematics                     = 1; % selected joint angles
makeplot.kinetics                       = 0; % selected joint torques
makeplot.ankle_musc                     = 1; % ankle muscles
makeplot.GRF                            = 0; % ground interaction
makeplot.compareLiterature              = 0; % mtj and mtp Caravaggi 2018
makeplot.compareTakahashi17             = 0; % "distal to segment" power analysis
makeplot.compareTakahashi17_separate    = 0; % "distal to segment" power analysis
makeplot.compareTakahashi17_mtj_only    = 0; % plot mtj power over experimental result
makeplot.compareTakahashi17_W_bar       = 0; % "distal to segment" work analysis
makeplot.allQsTs                        = 0; % all joint angles and torques
makeplot.windlass                       = 0; % plantar fascia and foot arch info
makeplot.windlass_mtp                   = 0; % interaction windlass and mtp
makeplot.power                          = 0; % datailed power decomposition
makeplot.work                           = 0; % same as power, but work over GC
makeplot.work_bar                       = 0; % positive, negative and net work bar plot
makeplot.work_bar_small                 = 0; % positive, negative and net work bar plot
makeplot.power_main                     = 0; % main power components of foot
makeplot.spatiotemp                     = 0; % stridelength etc.
makeplot.ankle_correlation              = 0; % correlation of ankle 
makeplot.E_muscle_bar                   = 1; % muscle metabolic energy totals
makeplot.W_muscle_bar                   = 0; % muscle fibre work totals   
makeplot.E_muscle_bar_small             = 0; % metabolic energy and work by selected muscle groups
makeplot.toes                           = 0; % toe flexor and extensor muscle info
makeplot.Edot_all                       = 0; % summed metabolic energy rate
makeplot.Energy_cost                    = 0; % decompose metabolic cost components
makeplot.muscle_act                     = 0; % muscle activity
makeplot.muscle_act_exc                 = 0; % muscle activity and excitation   
makeplot.muscle_joint_moment            = 0; % moments of muscles around ankle-foot joints
makeplot.muscle_joint_power             = 0; % powers of muscles around ankle-foot joints
makeplot.Objective_cost                 = 1; % cost function decomposition
makeplot.tau_pass                       = 0; % passive joint torques

PlotResults_3DSim_Report(ResultsFile,LegNames,'Fal_s1_mtjc2_custom',mtj,makeplot,figNamePrefix);


