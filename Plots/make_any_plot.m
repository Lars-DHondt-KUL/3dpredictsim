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
ResultsFolder = {'with_better_knee'};
% ResultsFolder = {'different_speeds'};

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
S.Foot.Model = 'mtp';
   % 'mtp': foot with mtp joint
   % 'mtj': foot with mtp and midtarsal joint
S.Foot.Scaling = 'default'; % default, custom, personalised

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
S.MTparams = ''; % 

% Contact spheres
S.Foot.contactStiffnessFactor = 10;  % 1 or 10, 10: contact spheres are 10x stiffer
% S.Foot.contactGeometryVersion = 4;
S.Foot.contactSphereOffsetY = 3;    % contact spheres are offset in y-direction to match static trial IK
S.Foot.contactSphereOffset45Z = 0; % contact spheres 4 and 5 are offset to give wider contact area
S.Foot.contactSphereOffset1X = 0;   % heel contact sphere offset in x-direction

%% metatarsophalangeal (mtp) joint
S.Foot.mtp_actuator = 0;    % use an ideal torque actuator
S.Foot.mtp_muscles = 0;     % extrinsic toe flexors and extensors act on mtp joint
S.Foot.kMTP = 25;            % additional stiffness of the joint (Nm/rad)
S.Foot.dMTP = 2;          % additional damping of the joint (Nms/rad)

%% midtarsal joint 
% (only used if Model = mtj)
% S.Foot.mtj_muscles = 1;  % joint interacts with extrinsic foot muscles
% lumped ligaments (long, short planter ligament, etc)
% S.Foot.MT_li_nonl = 1;       % 1: nonlinear torque-angle characteristic
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% S.Foot.mtj_sf = 1; 

% S.Foot.kMT_li = 200;        % angular stiffness in case of linear
% S.Foot.kMT_li2 = 10;        % angular stiffness in case of signed linear
% S.dMT = 0.1;                % (Nms/rad) damping

% plantar fascia
% S.Foot.PF_stiffness = 'Gefen2002'; % 'none''linear''Gefen2002''Cheng2008''Natali2010''Song2011'
% S.Foot.PF_sf = 1;
% S.Foot.PF_sf_isvar = 0; 
% S.Foot.PF_slack_length = 0.146; % (m) slack length

% Plantar Intrinsic Muscles represented by and ideal force actuator
% S.Foot.PIM = 0;             % include PIM actuator
% S.W.PIM = 5e4;              % weight on the excitations for cost function
% S.W.P_PIM = 1e4;            % weight on the net Work for cost function



% initial guess
% S.IGsel         = 2;    % initial guess identifier (1: quasi random, 2: data-based)
% S.IGmodeID      = 1;    % initial guess mode identifier (1 walk, 2 run, 3prev.solution, 4 solution from /IG/Data folder)


% Plantar Intrinsic Muscles represented by Flexor Digitorum Brevis
% S.Foot.FDB = 2;             % include Flexor Digitorum Brevis
% Tendon slack length
S.Foot.FDB_lTs = 0.125;
% Shift fiber passive force-length curve
S.Foot.FDB_shift = -0.1;
% scale FMo
S.Foot.FDB_sf_FMo = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LegNames = {'tmp'};
experimental_reference = 'Fal_s1_mtjc4_FK_custom';

%%

% % nominal simulations
% results = {
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     };
% % LegNames = {'Baseline model','Windlass mechanism','Plantar intrinsic muscles'};
% LegNames = {'Rigid midfoot','Plantar fascia','Plantar intrinsic muscles'};

% % effect of contact
% results = {
% %     '\with_better_knee\Fal_s1_mtppin_FK_sd_cg1_ATx50_MTPp_k25_d020_tau_ig21'
% %     '\with_better_knee\Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     };
% LegNames = {'original','x10'};

% % effect of Achilles tendon old model
% results = {
%     '\with_better_knee\Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtppin_FK_sd_cg1_ATx50_MTPp_k25_d020_tau_ig21'
%     };
% LegNames = {'regular','50%'};

% % effect of Achilles tendon mtj 
% results = {
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx70_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     };
% LegNames = {'50% FMo x1.2','50%','70%','100%'};

% % effect of Achilles tendon mtp
% results = {
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx40_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx70_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     };
% LegNames = {'40%','50% FMo x1.2','50%','70%','100%'};

% % effect of mtj axis orientation
% results = {
%     '\with_better_knee\Fal_s1_mtj_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc1_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc2_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc3_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc5_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     };
% LegNames = {'Sagittal','Orientation 1','Orientation 2','Orientation 3','Orientation 4','Orientation 5'};

% results = {
% %     '\with_better_knee\Fal_s1_mtj_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc1_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc2_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc3_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc5_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     };
% LegNames = {'Orientation 1','Orientation 2','Orientation 3','Orientation 4','Orientation 5'};

% % effect of IG
% results = {
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig24'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig24'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig24'
%     };
% LegNames = {'Baseline model QR','Baseline model data1','Baseline model data4','Windlass mechanism QR','Windlass mechanism data1','Windlass mechanism data4',...
%     'Plantar intrinsic muscles QR','Plantar intrinsic muscles data1','Plantar intrinsic muscles data4'};

% % effect of PIM FMo
% results = {
% %     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox150_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox150_ig1'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox120_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox120_ig1'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox80_ig21'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox80_ig1'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox50_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox50_ig1'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox30_ig21'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox30_ig1'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox30_ig23'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox20_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox20_ig1'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox10_ig21'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox10_ig23'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_FMox10_ig1'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     };
% LegNames = {'rigid midfoot','150% FMo','120% FMo','100% FMo','80% FMo','50% FMo','30% FMo','20% FMo','10% FMo','without'};

% % effect of triceps surae weakness
% results = {
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox96_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox72_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox96_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox72_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     };
% 
% LegNames = {'100% FMo (mtp)','80% FMo (mtp)','60% FMo (mtp)','100% FMo (PIM)','80% FMo (PIM)','60% FMo (PIM)'};

% % effect of mtp muscles
% results = {
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     };
% LegNames = {'passive mtp','muscle actuated mtp','muscle actuated mtp + PF','detailed model'};

% % major effects detailed model
% results = {
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_MTJp_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sd_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig21'
%     };
% LegNames = {'Best 3-segment model','w/o stiffer contacts','w/o compliant Achilles tendon','w/o intrinsic muscle','w/o muscles actuating mtj and mtpj','w/o custom scaling'};

% % major effects mtp model
results = {
    '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
    '\with_better_knee\Fal_s1_mtp_FK_sc_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
    '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
    '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_ig21'
    '\with_better_knee\Fal_s1_mtp_FK_sd_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtppin_FK_sd_cspx10_oy3_ATx50_MTPp_k25_d020_tau_ig21'
    };
LegNames = {'Best 2-segment model','w/o stiffer contacts','w/o compliant Achilles tendon','w/ muscles actuating mtpj','w/o custom scaling'};


% % nominal simulations v = 2.7 m/s
% results = {
% %     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
% %     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
% %     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel27_ig1'
% %     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_vel27_ig23_igmtp'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel27_ig23_igmtp'
%     };
% experimental_reference = 'HamnerS02_3ms';
% LegNames = {
%     'Rigid midfoot (v=1.33m/s)','Plantar fascia (v=1.33m/s)','Plantar intrinsic muscles (v=1.33m/s)',...
%     'Rigid midfoot (v=2.7m/s)','Plantar fascia (v=2.7/s)','Plantar intrinsic muscles (v=2.7m/s)'};

% % nominal simulations v = 2.0 m/s
% results = {
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel20_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_vel20_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel20_ig1'
%     };
% experimental_reference = 'HamnerS01_2ms';
% LegNames = {'Rigid midfoot (v=2.0m/s)','Plantar fascia (v=2.0m/s)','Plantar intrinsic muscles (v=2.0m/s)'};


% % effect of speed - mtp-model
% results = {
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel08_ig1'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel10_ig1'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel12_ig1'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel14_ig1'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel16_ig1'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel18_ig1'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel20_ig1'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel22_ig1'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel24_ig1'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel27_ig1'
%     };
% LegNames = {'0.8 m/s','1.0 m/s','1.2 m/s','1.33 m/s (self-selected)','1.4 m/s','1.6 m/s','1.8 m/s',...
%     '2.0 m/s','2.2 m/s','2.4 m/s','2.7 m/s'};

% % effect of speed - best model
% results = {
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel08_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel10_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel12_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel14_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel16_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel18_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel20_ig1'
% %     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel22_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel22_ig23'
% %     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel24_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel26_ig1'
% %     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel27_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel27_ig23'
%     };
% 
% LegNames = {'0.8 m/s','1.0 m/s','1.2 m/s','1.4 m/s','1.6 m/s','1.8 m/s','2.0 m/s','2.2 m/s','2.6 m/s','2.7 m/s'};

% % effect of plantar fascia
% results = {
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_FDB2_lTs125_Fpsl10_ig21'
%     };
% LegNames = {'PF Natali 2010','PF Natali 2010 + PIM','PF Gefen 2002','PF Gefen 2002 + PIM'};

% results = {
% %     '\with_better_knee\Fal_s1_mtjc2_FK_sc_cspx10_oy2_ATx70_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
% %     '\with_better_knee\Fal_s1_mtjc2_FK_sc_cspx10_oy2_ATx70_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc2_sc_cspx10_oy2_ATx70_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_ig21_old_bounds'
%     '\with_better_knee\Fal_s1_mtjc2_sc_cspx10_oy2_ATx70_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_FDB2_lTs125_Fpsl10_ig21_old_bounds'
%     };
% LegNames = {'PF Gefen 2002','PF Gefen 2002 + PIM'};


%%
if exist('results','var') && ~isempty(results)
    filteredResults = {length(results)};
    for i=1:length(results)
        filteredResults{i} = fullfile(ResultsRepo, [results{i} '_pp.mat']);
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
%     criteria{end+1} = 'pelvis_bounds';
%     criteria{end+1} = 'old_bounds';
    
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
ref{end+1} = fullfile([ResultsRepo '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21_pp.mat']);
% ref{end+1} = fullfile([ResultsRepo '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21_pp.mat']);


filteredResultsWithRef = filteredResults';
% filteredResultsWithRef = [ref, filteredResults]';
% filteredResultsWithRef = [filteredResults, ref]';
% filteredResultsWithRef = ref;

ResultsFile = filteredResultsWithRef;


%%
% compare_Lundgren_2008(ResultsFile{1});

%% compare ALL muscles for 2 simulation results
% ResultsFile1 = filteredResultsWithRef{1};
% ResultsFile2 = filteredResultsWithRef{3};
% 
% % PlotResultsComparison_3DSim(ResultsFile1,ResultsFile2,{'default','new'});

%%
% LegNames = {''};

mtj = 1;
figNamePrefix = 'none';
% figNamePrefix = 'C:\Users\u0150099\Documents\WTK\thesis\figuren\extended_foot_model\musc';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\Model_Personalization_Meeting\compliant_and_stiff';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\WTK\thesis\figuren\extended_foot_model\mtj_axis';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\Journal club\foot_model';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\Foot_Modeling_Meeting\2022_05_02\PIM';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\figures\draft\nominal_1';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\Conferences\ESMAC 2022\presentation\extra';
% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\plots_for_Madhu_2/run';


%%% select figures to make
makeplot.kinematics_Qs                  = 1; % selected joint angles
makeplot.kinematics_Qdots               = 0; % selected joint velocities
makeplot.kinetics                       = 0; % selected joint torques
makeplot.ankle_musc                     = 0; % ankle muscles
makeplot.ankle_musc2                    = 0; % ankle muscles
makeplot.GRF                            = 0; % ground interaction
makeplot.GRF_simple                     = 0; % only total xyz GRFs
makeplot.COP                            = 0; % centre of pressure
makeplot.compareLiterature              = 0; % mtj and mtp Caravaggi 2018
makeplot.compareTakahashi17             = 0; % "distal to segment" power analysis
makeplot.compareTakahashi17_separate    = 0; % "distal to segment" power analysis
makeplot.compareTakahashi17_mtj_only    = 0; % plot mtj power over experimental result
makeplot.compareTakahashi17_W_bar       = 0; % "distal to segment" work analysis
makeplot.compareZelik15                 = 0; % foot muscle activity coordination
makeplot.allQsTs                        = 0; % all joint angles and torques
makeplot.allQdots                       = 0; % all joint velocities
makeplot.allQddots                      = 0; % all joint accelerations
makeplot.allPs                          = 0; % all joint powers
makeplot.plot_bounds                    = 0; % adds the bounds to the 3 figs above
makeplot.windlass                       = 0; % plantar fascia and foot arch info
makeplot.windlass_mtp                   = 0; % interaction windlass and mtp
makeplot.power_main                     = 0; % main power components of foot
makeplot.power                          = 0; % datailed power decomposition
makeplot.work                           = 0; % same as power, but work over GC
makeplot.work_bar                       = 0; % positive, negative and net work bar plot
makeplot.work_bar_small                 = 0; % positive, negative and net work bar plot
makeplot.spatiotemp                     = 0; % stridelength etc.
makeplot.ankle_correlation              = 0; % correlation of ankle 
makeplot.E_muscle_bar                   = 0; % muscle metabolic energy totals
makeplot.W_muscle_bar                   = 0; % muscle fibre work totals   
makeplot.E_muscle_bar_small             = 0; % metabolic energy and work by selected muscle groups
makeplot.toes                           = 0; % toe flexor and extensor muscle info
makeplot.Edot_all                       = 0; % summed metabolic energy rate
makeplot.Energy_cost                    = 0; % decompose metabolic cost components
makeplot.muscle_act                     = 0; % muscle activity
makeplot.muscle_act_exc                 = 0; % muscle activity and excitation   
makeplot.muscle_joint_moment            = 0; % moments of muscles around ankle-foot joints
makeplot.muscle_joint_power             = 0; % powers of muscles around ankle-foot joints
makeplot.Objective_cost                 = 0; % cost function decomposition
makeplot.tau_pass                       = 0; % passive joint torques
makeplot.ankle_gearing                  = 0; % ankle gearing ratio (pf vs grf)


% experimental_reference = 'Fal_s1_mtjc4_FK_custom';
% experimental_reference = 'Fal_s1_mtp_FK_custom';
% experimental_reference = 'none';

PlotResults_3DSim_Report(ResultsFile,LegNames,experimental_reference,mtj,makeplot,figNamePrefix);




