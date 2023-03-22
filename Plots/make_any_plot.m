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
% ResultsRepo = fullfile(pathRepo,'Results');
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';
% ResultsFolder = {'debug'};
% ResultsFolder = {'with_better_knee'};
% ResultsFolder = {'different_speeds'};
ResultsFolder = {'results_paper'};

%% General information
S.subject = 'Fal_s1';

% S.suffixCasName = 'v3';     % suffix for name of folder with casadifunctions
% S.suffixName = 'v4';        % suffix for name of file with results

% Cost function weights
% S.W.Ak      = 50000;    % weight joint accelerations
% S.W.passMom = 1000;     % weight passive torques
% S.W.A       = 2000;     % weight muscle activations

%% Tracking term
% S.TrackSim = 1;
% S.Track.Q_ankle = 1;
% S.Track.Q_subt = 1;

%% Foot model
%-------------------------------------------------------------------------%
% General
S.Foot.Model = 'mtjc4';
   % 'mtp': foot with mtp joint
   % 'mtj': foot with mtp and midtarsal joint
S.Foot.Scaling = 'custom'; % default, custom, personalised

% fixed knee axis
S.fixed_knee = 1;

% Achilles tendon stiffness
S.AchillesTendonScaleFactor = 0.5;

% Triceps surae optimal force scale
S.TricepsFMoScale = 1.2;

% Reduce tendon slack length of Soleus
S.SoleusTendonShorter = 0;

% Reduce tendon slack length of gastrocnemius
S.GastrocTendonShorter = 0;

% Shift passive force-length curve of ankle muscle fibers
S.passiveFiberForceShift = -0.1;

% Tibialis anterior according to Rajagopal et al. (2015)
S.tib_ant_Rajagopal2015 = 0;

% Use geometry polynomials from old simulation (mtpPin)
S.useMtpPinPoly = 0;

% Use skeletal dynamics from old simulation (mtpPin)
S.useMtpPinExtF = 0;

% use custom muscle-tendon parameters
S.MTparams = 'MTc5'; % 

% Contact spheres
S.Foot.contactStiffnessFactor = 10;  % 1 or 10, 10: contact spheres are 10x stiffer
S.Foot.contactGeometryVersion = 9;
% S.Foot.contactSphereOffsetY = 0;    % contact spheres are offset in y-direction to match static trial IK
% % S.Foot.contactSphereOffset45Z = 0; % contact spheres 4 and 5 are offset to give wider contact area
S.Foot.contactSphereOffset1X = 0.01;   % heel contact sphere offset in x-direction


%% metatarsophalangeal (mtp) joint
S.Foot.mtp_actuator = 0;    % use an ideal torque actuator
% S.Foot.mtp_muscles = 1;     % extrinsic toe flexors and extensors act on mtp joint
% S.Foot.kMTP = 1;            % additional stiffness of the joint (Nm/rad)
% S.Foot.dMTP = 0.1;          % additional damping of the joint (Nms/rad)

%% midtarsal joint 
% S.Foot.mtj_muscles = 0;  % joint interacts with extrinsic foot muscles
% S.Foot.MT_li_nonl = 1;       % 1: nonlinear torque-angle characteristic
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% S.Foot.mtj_sf = 1; 

% S.Foot.kMT_li = 200;        % angular stiffness in case of linear
% S.Foot.kMT_li2 = 10;        % angular stiffness in case of signed linear
% S.dMT = 0.1;                % (Nms/rad) damping

% plantar fascia
S.Foot.PF_stiffness = 'Natali2010'; % 'none''linear''Gefen2002''Natali2010''Song2011'
S.Foot.PF_sf = 5;
% S.Foot.PF_sf_isvar = 0; 
% S.Foot.PF_slack_length = 0.146; % (m) slack length

% Plantar Intrinsic Muscles represented by and ideal force actuator
% S.Foot.PIM = 0;             % include PIM actuator
% S.W.PIM = 5e4;              % weight on the excitations for cost function
% S.W.P_PIM = 1e4;            % weight on the net Work for cost function



% initial guess
% S.IGsel         = 1;    % initial guess identifier (1: quasi random, 2: data-based)
% S.IGmodeID      = 1;    % initial guess mode identifier (1 walk, 2 run, 3prev.solution, 4 solution from /IG/Data folder)


% Plantar Intrinsic Muscles represented by Flexor Digitorum Brevis
% S.Foot.FDB = 2;             % include Flexor Digitorum Brevis
% % Optimal fibre length
% S.Foot.FDB_lMo = 19.7e-3;
% % Tendon slack length
% S.Foot.FDB_lTs = 0.125;
% % Shift fiber passive force-length curve
% S.Foot.FDB_shift = -0.1;
% % scale FMo
% S.Foot.FDB_sf_FMo = 1;
% % apply nerve block (activation constrained to baseline)
% S.Foot.FDB_nerveBlock = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% main

% % new vs SOTA
% results = {
%     '\results_paper\Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     };
% LegNames = {'State-of-the-art 2-segment model','new 2-segment model','3-segment model'};

% % 3-segment and 2-segment model
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     };
% LegNames = {'3-segment model', 'new 2-segment model'};

% Achilles tendon
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     };
% LegNames = {'3-segment model: compliant Achilles tendon','2-segment model: compliant Achilles tendon','3-segment model: stiff Achilles tendon','2-segment model: stiff Achilles tendon'};

% % contact stiffness
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     };
% LegNames = {'3-segment model: stiff contact','2-segment model: stiff contact','3-segment model: compliant contact','2-segment model: compliant contact'};

% % scaling
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtjc3_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPp_k25_d020_tau_ig21_N100'
%     };
% LegNames = {'3-segment model: custom scaling','2-segment model: custom scaling','3-segment model: isometric scaling','2-segment model: isometric scaling'};


% % extrinsic foot muscles
 results = {
    '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
    '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
    '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_MTJp_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1_N100_v2'   
    '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_ig1_N100'
    };
 LegNames = {'3-segment model: muscle-driven mtj, mtpj', '2-segment model: passive mtpj', '3-segment model: passive mtj, mtpj','2-segment model: muscle-driven mtpj'};

% % intrinsic foot muscle, plantar fascia stiffness
%  results = {
% %     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_ig1_N100'
%     };
%  LegNames = {'stiff plantar fascia, with intrinsic muscle', 'stiff plantar fascia, without intrinsic muscle',...
%      'compliant plantar fascia, with intrinsic muscle','compliant plantar fascia, without intrinsic muscle'};
% LegNames = [{'2-segment'}, LegNames];

% % 
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_nb_lTs125_Fpsl10_ig21_N100_v2'
% %     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_nb_lTs125_Fpsl10_ig1_N100_v2'
% %     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1_N100'
% %     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_x2_ls146_ig1_N100'
%     };
% LegNames = {'with PIM','PIM nerve block','PIM nerve block (ig1)','w/o PIM','w/o PIM, PF stiff x2'};
    
% % 
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_x2_ls146_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_x5_ls146_ig1_N100'
%     };
% LegNames = {'with PIM','w/o PIM, PF stiff x2','w/o PIM, PF stiff x5'};
  

% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_ig1_N100'
%     '\results_paper\Fal_s1_mtjc3_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig1_N100'
%     };
% LegNames = {'Nominal 3-segment foot model','Nominal 2-segment foot model',...
%     'Compliant plantar fascia, without intrinsic muscle','Low arch height (3-segment)'};


% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_none_ls141_FDB2_lTs120_Fpsl10_ig21_pp.mat'
%     };
% LegNames = {'Nominal 3-segment foot model','Low-arched foot without plantar fascia'};

%% supplementary
% % number of mesh intervals
% results = {
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_N40' 
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N40'  
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_N60' 
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N60'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_N75' 
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N75'  
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_N100'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100' 
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_N125'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N125' 
%     };
% LegNames = {'N = 40, warm-start','N = 40, cold-start','N = 50, warm-start','N = 50, cold-start','N = 60, warm-start','N = 60, cold-start',...
%     'N = 75, warm-start','N = 75, cold-start','N = 100, warm-start','N = 100, cold-start','N = 125, warm-start','N = 125, cold-start'};

% % ipopt tolerance
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_tol5'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_tol6'
%     };
% LegNames = {'tol = 1e-4', 'tol = 1e-5', 'tol = 1e-6'};

% % Triceps surae parameters
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox150_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
% };
% LegNames = {'TS FMo x1.2; Fpas increased','TS FMo x1.5; Fpas increased','TS FMo x1.0; Fpas increased','TS FMo x1.2; Fpas generic'};

% % Achilles tendon stiffness - 3-segment
% results = {
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx30_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx40_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx60_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx70_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx80_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx90_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
% };
% LegNames = {'30%','40%','50%','60%','70%','80%','90%','100%'};


% % contact stiffness - 3-segment
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx3_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx5_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx20_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     };
% LegNames = {'1 MPa', '3 MPa', '5 MPa', '10 MPa', '20 MPa'};

% % plantar fascia stiffness
% results = {
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_linear_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Song2011_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     'results_paper/Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     };
% LegNames = {'Natali et al. (2010)','linear','Song et al. (2011)','Gefen (2002)'};

% % mtj axis orientation
% results = {
%     '\results_paper\Fal_s1_mtj_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc1_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc2_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc5_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     };
% LegNames = {'Sagittal','Orientation 1','Orientation 2','Orientation 3','Orientation 4','Orientation 5'};

% % mtj axis orientation - isometric scaling
% results = {
%     '\results_paper\Fal_s1_mtjc1_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc2_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc3_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc5_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig1_N100_pp.mat'
%     };
% LegNames = {'Orientation 1','Orientation 2','Orientation 3','Orientation 4','Orientation 5'};

% % PIM FMo
% results = {
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox200_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox150_ig1_N100_pp.mat'
% %     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox120_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox70_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox50_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox30_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox20_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1_N100_pp.mat'
% %     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_x2_ls146_ig1_N100_pp.mat'
%     };
% LegNames = {'200% FMo', '150% FMo', '100% FMo','70% FMo','50% FMo','30% FMo','20% FMo'};
% LegNames = [{'2-segment'}, LegNames, {'without intrinsic muscle'}];

% % PIM lMo
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lMo18_lTs127_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lMo23_lTs122_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lMo25_lTs120_Fpsl10_ig1_N100_pp.mat'
%     };
% LegNames = {'lMo = 18 mm (lTs = 127 mm)', 'lMo = 19.7 mm (lTs = 125 mm)', 'lMo = 23 mm (lTs = 122 mm)', 'lMo = 25 mm (lTs = 120 mm)'};

% % PIM lTs
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs123_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs124_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs126_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs127_Fpsl10_ig1_N100_pp.mat'
% 
%     };
% LegNames = {'lTs = 123 mm', 'lTs = 124 mm', 'lTs = 125 mm', 'lTs = 126 mm', 'lTs = 127 mm'};

% % passive foot model
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_MTJp_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1_N100_v2'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_MTJp_k400_d020_PF_Natali2010_ls146_ig1_N100_v2'
% %     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_MTJp_k400_d020_PF_Natali2010_x5_ls146_ig1_N100_v2'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_MTJp_nl_k400_50_d020_PF_Natali2010_ls146_ig1_N100_v2'
%     };
% LegNames = {'Muscle-driven foot joints','Muscle-driven foot joints, without intrinsic muscle','Passive foot','Passive foot with kMTJ = 400 Nm/rad and dMTJ = 2 Nms/rad',...
% ...     'Passive foot with kMTJ = 400 Nm/rad and dMTJ = 2 Nms/rad, Plantar fascia stiffness x5',...
%     'Passive foot with kMTJ = 400/50 Nm/rad and dMTJ = 2 Nms/rad'};

% % heel sphere x-position
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x15_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x20_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     };
% LegNames = {'x = 0 mm', 'x = 10 mm', 'x = 15 mm', 'x = 20 mm'};

% % contact sphere configuration
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg4_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg5_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg6_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg7_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg8_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'    
%     };
% LegNames = {'cg 4','cg 5','cg 6','cg 7','cg 8'};


% % velocity - 3-segment model
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel08_ig1_N100_vel08_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel10_ig1_N100_vel10_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel12_ig1_N100_vel12_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel14_ig1_N100_vel14_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel16_ig1_N100_vel16_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel18_ig1_N100_vel18_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel20_ig1_N100_vel20_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel22_ig1_N100_vel22_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel24_ig1_N100_vel24_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel26_ig1_N100_vel26_pp.mat'
%     };
% LegNames = {'0.8 m/s','1.0 m/s','1.2 m/s','1.33 m/s (self-selected)','1.4 m/s','1.6 m/s','1.8 m/s','2.0 m/s','2.2 m/s','2.4 m/s','2.6 m/s'};

% % velocity - 2-segment model
% results = {
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel08_ig1_N100_vel08'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel12_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel14_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel16_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel18_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel20_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel22_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel24_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel26_ig1_N100'
%     };
% LegNames = {'0.8 m/s','1.0 m/s','1.2 m/s','1.33 m/s (self-selected)','1.4 m/s','1.6 m/s','1.8 m/s','2.0 m/s','2.2 m/s','2.4 m/s','2.6 m/s'};



%%
if exist('results','var') && ~isempty(results)
    filteredResults = {length(results)};
    for i=1:length(results)
        if ~contains(results{i},'_pp.mat')
            filteredResults{i} = fullfile(ResultsRepo, [results{i} '_pp.mat']);
        else
            filteredResults{i} = fullfile(ResultsRepo, results{i});
        end
    end
else

    % get file names
    pathResult = {numel(ResultsFolder)};
    for i=1:numel(ResultsFolder)
        pathResult{i} = fullfile(ResultsRepo, ResultsFolder{i});
    end
    
    
    % get filter criteria
    [~,~,criteria] = getSavename(S);
    
%     criteria{end+1} = 'not_PIM';
%     criteria{end+1} = 'not_FDB';
%     criteria{end+1} = 'not_o1x25';
%     criteria{end+1} = 'not_o45z10';
    criteria{end+1} = 'not_Track';
    criteria{end+1} = 'not_table_x5';
    criteria{end+1} = 'not_test';
%     criteria{end+1} = 'not_mtjc';
    criteria{end+1} = 'not_MTc6';
%     criteria{end+1} = 'not_k17';
%     criteria{end+1} = 'not_o1x';
%     criteria{end+1} = 'not_Fpsl';
    criteria{end+1} = 'not___v1';
    criteria{end+1} = 'not_Fpsl10_FMox';
%     criteria{end+1} = 'not_ig24';
%     criteria{end+1} = 'not_k25';
%     criteria{end+1} = 'not_mtppin';
%     criteria{end+1} = 'o1x';
%     criteria{end+1} = 'cg2';
%     criteria{end+1} = 'tau';
%     criteria{end+1} = 'Sv';
%     criteria{end+1} = 'ATx';
%     criteria{end+1} = 'not_cspx10';
    criteria{end+1} = 'cg';
%     criteria{end+1} = 'not_cg4';
%     criteria{end+1} = 'not_cg9';
    criteria{end+1} = 'not_vel';
%     criteria{end+1} = 'pelvis_bounds';
%     criteria{end+1} = 'old_bounds';
%     criteria{end+1} = 'N100';
%     criteria{end+1} = 'not_1_N';
    criteria{end+1} = 'not_tol';
    
    % filter filenames
    [filteredResults] = filterResultfolderByParameters(pathResult,criteria);
    
    for i=1:numel(filteredResults)
        rfpathi = filteredResults{i};
        idx_i = strfind(rfpathi,'\');
        disp(rfpathi(idx_i(end-1):end));
    end

end
ref = {};

% ref{end+1} = fullfile([ResultsRepo '/debug\Fal_s1_mtp_sd_MTPp_k17_d05_ig21_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '/debug\Fal_s1_mtp_sc_MTPp_k17_d05_ig21_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '/debug\Fal_s1_mtp_sc_cspx10_oy_MTPp_k17_d05_ig21_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '/debug\Fal_s1_mtp_sd_MTPm_k1_d05_ig21_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '/debug\Fal_s1_mtp_sc_MTPm_k1_d01_ig21_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '\with_better_knee\Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_ig21_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_pp.mat']);
ref{end+1} = fullfile([ResultsRepo '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '\results_paper\Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_ig1_N100_pp.mat']);

filteredResultsWithRef = filteredResults';
% filteredResultsWithRef = [ref, filteredResults]';
% filteredResultsWithRef = [filteredResults, ref]';
% filteredResultsWithRef = ref;

ResultsFile = filteredResultsWithRef;


%%
% compare_Lundgren_2008(ResultsFile{1});

%% compare ALL muscles for 2 simulation results
% ResultsFile1 = filteredResultsWithRef{2};
% ResultsFile2 = filteredResultsWithRef{4};
% 
% % PlotResultsComparison_3DSim(ResultsFile1,ResultsFile2,{'with PIM','w/o PIM'});

%%
% LegNames = {''};

mtj = 1;
figNamePrefix = 'none';
% figNamePrefix = 'C:\Users\u0150099\Documents\WTK\thesis\figuren\extended_foot_model\musc';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\Model_Personalization_Meeting\compliant_and_stiff';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\WTK\thesis\figuren\extended_foot_model\mtj_axis';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\Journal club\foot_model';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\Foot_Modeling_Meeting\3segment';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\misc\PredSim';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\Conferences\ESMAC 2022\presentation\extra';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\midfoot_stiffness';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\Optimisation_Meeting/mesh';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\figures\draft/3seg';

%%% select figures to make
makeplot.kinematics_Qs                  = 0; % selected joint angles
makeplot.kinematics_Qdots               = 0; % selected joint velocities
makeplot.kinetics                       = 0; % selected joint torques
makeplot.ankle_musc                     = 0; % ankle muscles
makeplot.ankle_musc2                    = 0; % ankle muscles
makeplot.toes                           = 0; % toe flexor and extensor muscle info
makeplot.GRF                            = 0; % ground interaction
makeplot.GRF_simple                     = 0; % only total xyz GRFs
makeplot.COP                            = 0; % centre of pressure
makeplot.compareLiterature              = 0; % mtj and mtp Caravaggi 2018
makeplot.compareTakahashi17             = 0; % "distal to segment" power analysis
makeplot.compareTakahashi17_separate    = 0; % "distal to segment" power analysis
makeplot.compareTakahashi17_mtj_only    = 0; % plot mtj power over experimental result
makeplot.compareTakahashi17_W_bar       = 0; % "distal to segment" work analysis
makeplot.compareZelik15                 = 0; % foot muscle activity coordination
makeplot.compareZelik15b                = 0; % leg joint powers            
makeplot.allQsTs                        = 0; % all joint angles and torques
makeplot.allQdots                       = 0; % all joint velocities
makeplot.allQddots                      = 0; % all joint accelerations
makeplot.allPs                          = 0; % all joint powers
makeplot.plot_bounds                    = 0; % adds the bounds to the 3 figs above
makeplot.windlass                       = 1; % plantar fascia and foot arch info
makeplot.windlass_mtp                   = 0; % interaction windlass and mtp
makeplot.mtj_moments                    = 0; % mtj moment decomposition    
makeplot.power_main                     = 1; % main power components of foot
makeplot.power_windlass                 = 0; % windlass power transfer
makeplot.power                          = 0; % datailed power decomposition
makeplot.work                           = 0; % same as power, but work over GC
makeplot.work_bar                       = 1; % positive, negative and net work bar plot
makeplot.work_bar_small                 = 0; % positive, negative and net work bar plot
makeplot.spatiotemp                     = 0; % stridelength etc.
makeplot.ankle_correlation              = 0; % correlation of ankle 
makeplot.E_muscle_bar                   = 0; % muscle metabolic energy totals
makeplot.W_muscle_bar                   = 0; % muscle fibre work totals   
makeplot.E_muscle_bar_small             = 0; % metabolic energy and work by selected muscle groups
makeplot.Edot_all                       = 0; % summed metabolic energy rate
makeplot.Energy_cost                    = 0; % decompose metabolic cost components
makeplot.muscle_act                     = 0; % muscle activity
makeplot.muscle_act_exc                 = 0; % muscle activity and excitation   
makeplot.muscle_joint_moment            = 0; % moments of muscles around ankle-foot joints
makeplot.muscle_joint_power             = 1; % powers of muscles around ankle-foot joints
makeplot.Objective_cost                 = 0; % cost function decomposition
makeplot.tau_pass                       = 0; % passive joint torques
makeplot.ankle_gearing                  = 0; % ankle gearing ratio (pf vs grf)
makeplot.peak_soleus                    = 0; % peak force, activity, velocity                    

%%
if ~exist('LegNames','var')
    LegNames = {'Simulated'};
end
if ~exist('experimental_reference','var')
    experimental_reference = 'Fal_s1_mtjc4_FK_custom_right';
end
% experimental_reference = 'Fal_s1_mtjc4_FK_custom';
% experimental_reference = 'Fal_s1_mtp_FK_custom';
% experimental_reference = 'none';


PlotResults_3DSim_Report(ResultsFile,LegNames,experimental_reference,mtj,makeplot,figNamePrefix);




