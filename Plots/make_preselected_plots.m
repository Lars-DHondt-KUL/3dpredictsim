%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script allows to plot preselected groups of results from the Thesis_Lars
% branch. See \3dpredictsim\Plots\make_any_plot.m to generate
% figures of results, filtered by parameter values
% 
% 
%
% Author: Lars D'Hondt (May 2021)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

%% selection
% results from the static foot compression simultion
plot_static_foot = 0;
% results from the dynamic whole-body gait simulation
plot_full_separate = 0; % separate figures like  in the report
plot_full_tabbed = 0; % single figure with different tabs



%% Paths
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/PassiveMoments']);
addpath([pathRepo '/FootModel']);
ResultsFolder = {'MidTarsalJoint'};

% resultsRepo = fullfile(pathRepo,'\Results\');
resultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results/';

for i=1:numel(ResultsFolder)
    pathResult{i} = fullfile([pathRepo '/Results/' ResultsFolder{i}]);
end
scs = get(0,'ScreenSize');

%%
ref{1} = fullfile([resultsRepo 'Final\Fal_s1_bCst_ig21_pp.mat']);

%% groups of results

% default, best COT
groupNames{1} = 'd_m_t_j = 0 Nms/rad, k_m_t_p = 5 Nm/rad';
Results_default = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T5_ig24_v2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1500_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k2000_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k5000_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k10000_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100000_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1000000_MTP_T5_ig23_pp.mat'])};

% default, all ig
groupNames{end+1} = 'd_m_t_j = 0 Nms/rad, k_m_t_p = 5 Nm/rad (ig21)';
Results_default_ig21 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_MTP_T5_ig21_pp.mat'])};

groupNames{end+1} = 'd_m_t_j = 0 Nms/rad, k_m_t_p = 5 Nm/rad (ig23)';
Results_default_ig23 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k5000_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k10000_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100000_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1000000_MTP_T5_ig23_pp.mat'])};

groupNames{end+1} = 'd_m_t_j = 0 Nms/rad, k_m_t_p = 5 Nm/rad (ig24)';
Results_default_ig24 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T5_ig24_v2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1500_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k2000_MTP_T5_ig24_pp.mat'])};


% damping 1, best COT
groupNames{end+1} = 'd_m_t_j = 1 Nms/rad, k_m_t_p = 5 Nm/rad';
Results_d010 = {
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_d010_MTP_T5_ig21_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1000_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1500_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k2000_d010_MTP_T5_ig24_pp.mat'])};

% damping 1, all ig
groupNames{end+1} = 'd_m_t_j = 1 Nms/rad, k_m_t_p = 5 Nm/rad (ig21)';
Results_d010_ig21 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_d010_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_d010_MTP_T5_ig21_pp.mat'])};

groupNames{end+1} = 'd_m_t_j = 1 Nms/rad, k_m_t_p = 5 Nm/rad (ig23)';
Results_d010_ig23 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_d010_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_d010_MTP_T5_ig23_pp.mat'])};

groupNames{end+1} = 'd_m_t_j = 1 Nms/rad, k_m_t_p = 5 Nm/rad (ig24)';
Results_d010_ig24 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1000_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1500_d010_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k2000_d010_MTP_T5_ig24_pp.mat'])};

% damping 2, best COT
groupNames{end+1} = 'd_m_t_j = 2 Nms/rad, k_m_t_p = 5 Nm/rad';
Results_d020 = {
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_d020_MTP_T5_ig21_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1000_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1500_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k2000_d020_MTP_T5_ig24_pp.mat'])};

% damping 2, all ig
groupNames{end+1} = 'd_m_t_j = 2 Nms/rad, k_m_t_p = 5 Nm/rad (ig21)';
Results_d020_ig21 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_d020_MTP_T5_ig21_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_d020_MTP_T5_ig21_pp.mat'])};

groupNames{end+1} = 'd_m_t_j = 2 Nms/rad, k_m_t_p = 5 Nm/rad (ig23)';
Results_d020_ig23 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_d020_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_d020_MTP_T5_ig23_pp.mat'])};

groupNames{end+1} = 'd_m_t_j = 2 Nms/rad, k_m_t_p = 5 Nm/rad (ig24)';
Results_d020_ig24 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1000_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1500_d020_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k2000_d020_MTP_T5_ig24_pp.mat'])};


groupNames{end+1} = 'd_m_t_j = 5 Nms/rad, k_m_t_p = 5 Nm/rad';
Results_d050 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_d050_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_d050_MTP_T5_ig24_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_d050_MTP_T5_ig24_pp.mat']) % not converged
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_d050_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_d050_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_d050_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_d050_MTP_T5_ig24_pp.mat'])};

groupNames{end+1} = 'd_m_t_j = 0 Nms/rad, k_m_t_p = 2 Nm/rad';
Results_T2 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1000_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1500_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k2000_MTP_T2_ig24_pp.mat'])};

groupNames{end+1} = 'd_m_t_j = 0 Nms/rad, k_m_t_p = 10 Nm/rad';
Results_T10 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1000_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1500_MTP_T10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k2000_MTP_T10_ig24_pp.mat'])};

groupNames{end+1} = 'k_P_F x2';
Results_PFx2 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k150_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k250_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_MTP_T5_ig24_PFx2_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1000_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k1500_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k2000_MTP_T5_ig24_PFx2_pp.mat'])};

groupNames{end+1} = 'vs Falisse 2019';
Results_vs = {
    fullfile([resultsRepo 'Final\Fal_s1_bCst_ig1_v8_pp.mat'])
    fullfile([resultsRepo 'Final\Fal_s1_bCst_ig1_v10_pp.mat'])
    fullfile([resultsRepo 'Final\Fal_s1_bCst_ig1_v12_pp.mat'])
    fullfile([resultsRepo 'Final\Fal_s1_bCst_ig1_v14_pp.mat'])
    fullfile([resultsRepo 'Final\Fal_s1_bCst_ig1_v16_pp.mat'])
    fullfile([resultsRepo 'Final\Fal_s1_bCst_ig1_v18_pp.mat'])
    fullfile([resultsRepo 'Final\Fal_s1_bCst_ig1_v27_pp.mat'])};
    
groupNames{end+1} = 'vs Song 2011';
Results_vs_Song = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_Mu0_ig1_v8_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_Mu0_ig1_v10_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_Mu0_ig1_v12_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_Mu0_ig1_v14_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_Mu0_ig1_v16_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_Mu0_ig1_v18_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_Mu0_ig1_v27_pp.mat'])};

groupNames{end+1} = 'PF only';
Results_PFonly = {
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k10_MTP_T5_ig24_PFx10_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k10_MTP_T2_ig24_PFx10_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_T5_ig24_PFx10_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_T2_ig24_PFx10_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T5_ig24_PFx5_pp.mat'])};

groupNames{end+1} = 'Muscle-driven mtp';
Results_Musc = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu1_ig23_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu1_ig24_pp.mat']) % local min
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu1_np_ig23_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu1_spx2_ig24_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu5_np_ig23_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_T5_ig24_PFx10_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_Mu2_ig24_PFx10_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_Mu5_ig24_PFx10_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_Mu5_ig24_PFx5_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k20_MTP_Mu5_ig24_PFx5_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_fitted6_MTP_Mu5_ig24_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_Mu5_ig24_pp.mat'])
    };
    
groupNames{end+1} = 'k_m_t_j_,_n_e_g = 10 Nm/rad';
Results_singed_lin = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_k100_10_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_k200_10_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_k300_10_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_k400_10_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_k500_10_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_k800_10_MTP_T5_ig24_pp.mat'])};

groupNames{end+1} = 'k_m_t_j_,_n_e_g test';
Results_singed_lin_test = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_signed_lin_MTP_T5_ig1_300_50_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_signed_lin_MTP_T5_ig24_300_10_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_signed_lin_MTP_T5_ig24_300_30_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_signed_lin_MTP_T5_ig24_500_30_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_signed_lin_MTP_T5_ig24_500_50_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_aCst_PF_Natali2010_ls150_MT_nl_signed_lin_MTP_T5_ig24_500_50_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_signed_lin_MTP_Mu5_ig24_300_10_pp.mat'])};

groupNames{end+1} = 'other PF models';
Results_other_PF = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_signed_lin_MTP_T5_ig24_300_10_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_signed_lin_MTP_T5_ig24_300_10_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_signed_lin_MTP_T5_ig24_800_50_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_linear_ls150_MT_nl_signed_lin_MTP_T5_ig24_300_10_pp.mat'])};

groupNames{end+1} = 'no PF';
Results_no_PF = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_None_ls150_MT_k250_MTP_T17_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_None_ls150_MT_k500_MTP_T17_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_None_ls150_MT_k800_MTP_T17_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_None_ls150_MT_k1000_MTP_T17_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_None_ls150_MT_k1500_MTP_T17_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_None_ls150_MT_k2000_MTP_T17_ig24_pp.mat'])};
    
groupNames{end+1} = 'd_m_t_p = 0 Nms/rad';
Results_mtp_d0 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k100_MTP_T5_d00_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k200_MTP_T5_d00_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_d00_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k400_MTP_T5_d00_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k500_MTP_T5_d00_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_MTP_T5_d00_ig24_pp.mat'])};

groupNames{end+1} = 'stiffer contact';
Results_stiff_contact = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_spx10_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu1_np_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu1_spx2_ig24_pp.mat'])};

groupNames{end+1} = 'misc';
Results_misc = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_fitted6_MTP_T2_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_fitted6_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_none_ls148_MT_k1000_MTP_k10_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_none_ls148_MT_k500_MTP_k10_ig24_pp.mat'])
    };

best_COT = fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig23_pp.mat']);

main_results_walking = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_None_ls150_MT_k500_MTP_T17_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_T5_ig24_PFx10_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig23_pp.mat'])};

main_results_running = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_None_ls150_MT_k1000_MTP_T17_ig23_v27_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_T5_ig23_PFx10_v27_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig23_v27_pp.mat'])};

Results_PF_models = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_linear_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Cheng2008_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T5_ig23_pp.mat'])
    };
    

PF_stiffening = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T5_ig24_v2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T5_ig24_PFx2_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k50_MTP_T5_ig24_PFx5_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k30_MTP_T5_ig24_PFx10_pp.mat'])};

Results_mtp_wrt_k_mtj = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_nl_Song2011_MTP_T5_ig24_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T5_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k800_MTP_T5_ig21_pp.mat'])};


Results_combination = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T1_spx10_ig23_PFx10_spx10_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T5_ig23_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu1_spx10_ig23_PFx10_pp.mat']) % wrong GRF, not sure if caused by sim or pp
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_T1_spx10_ig23_PFx10_v133_pp.mat'])
    };
    
Results_active = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_ig23_PFact_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_PIM_w1e+06_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_PIM_w1e+03_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_PIM_w1e+03_w5e+02_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_PIM_w1e+03_w1e+04_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_PIM_w1e+04_w1e+04_ig23_pp.mat'])
    };

Results_active_muscle = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_ig23_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_PIM_w1e+03_w5e+02_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_PIM_w1e+03_w1e+04_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_Mf1_spx10_PIM_w1e+03_w1e+04_ig21_pp.mat']) % geometry errors
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_Mf1_spx10_PIM_w1e+03_w1e+04_ig23_v0_pp.mat'])
%     fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_PIM_w1e+04_w1e+04_ig23_pp.mat'])
    };

Results_active_muscle_v0 = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_T1_spx10_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_Mf1_spx10_PIM_w1e+03_w1e+04_ig23_v0_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_nl_Gefen2002_MTP_Mf1_spx10_ig23_v0_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mf1_spx10_ig23_v0_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mf1_spx10_PIM_w1e+03_w1e+04_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Gefen2002_ls150_MT_nl_Gefen2002_MTP_Mf1_spx10_PIM_w1e+03_w1e+04_ig23_pp.mat'])
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Song2011_ls150_MT_k200_MTP_Mf1_spx10_PIM_w1e+03_w1e+04_ig23_pp.mat'])
    };

Results_local_min = {
    fullfile([resultsRepo 'MidTarsalJoint\Fal_s1_bCst_PF_Natali2010_ls150_MT_k300_MTP_Mu1_ig24_pp.mat']) % local min
    };

Results_tanh = {
    fullfile([resultsRepo 'Final\Fal_s1_bCst_tanh10_ig21_pp.mat'])
    fullfile([resultsRepo 'Final\Fal_s1_bCst_tanh50_ig21_pp.mat'])
    fullfile([resultsRepo 'Final\Fal_s1_bCst_tanh100_ig21_pp.mat'])
    };

%%

filteredResultsWithRef{1}     = {ref{:}, Results_default{:}};           % 1
filteredResultsWithRef{end+1} = {ref{:}, Results_default_ig21{:}};      
filteredResultsWithRef{end+1} = {ref{:}, Results_default_ig23{:}}; 
filteredResultsWithRef{end+1} = {ref{:}, Results_default_ig24{:}}; 


filteredResultsWithRef{end+1} = {ref{:}, Results_d010{:}};              % 5
filteredResultsWithRef{end+1} = {ref{:}, Results_d010_ig21{:}};
filteredResultsWithRef{end+1} = {ref{:}, Results_d010_ig23{:}}; 
filteredResultsWithRef{end+1} = {ref{:}, Results_d010_ig24{:}}; 

filteredResultsWithRef{end+1} = {ref{:}, Results_d020{:}};              % 9
filteredResultsWithRef{end+1} = {ref{:}, Results_d020_ig21{:}};
filteredResultsWithRef{end+1} = {ref{:}, Results_d020_ig23{:}};
filteredResultsWithRef{end+1} = {ref{:}, Results_d020_ig24{:}};

filteredResultsWithRef{end+1} = {ref{:}, Results_d050{:}};              % 13
filteredResultsWithRef{end+1} = {ref{:}, Results_T2{:}};                % 14
filteredResultsWithRef{end+1} = {ref{:}, Results_T10{:}};               % 15
filteredResultsWithRef{end+1} = {ref{:}, Results_PFx2{:}};              % 16
filteredResultsWithRef{end+1} = {ref{:}, Results_vs{:}};                % 17
filteredResultsWithRef{end+1} = {ref{:}, Results_vs_Song{:}};           % 18
filteredResultsWithRef{end+1} = {ref{:}, Results_PFonly{:}};            % 19
filteredResultsWithRef{end+1} = {ref{:}, Results_Musc{:}};              % 20
filteredResultsWithRef{end+1} = {ref{:}, Results_singed_lin{:}};        % 21
filteredResultsWithRef{end+1} = {ref{:}, Results_singed_lin_test{:}};   % 22
filteredResultsWithRef{end+1} = {ref{:}, Results_other_PF{:}};          % 23
filteredResultsWithRef{end+1} = {ref{:}, Results_no_PF{:}};             % 24
filteredResultsWithRef{end+1} = {ref{:}, Results_mtp_d0{:}};            % 25
filteredResultsWithRef{end+1} = {ref{:}, Results_stiff_contact{:}};     % 26
filteredResultsWithRef{end+1} = {ref{:}, Results_misc{:}};              % 27
filteredResultsWithRef{end+1} = {ref{:}, main_results_walking{:}};      % 28
filteredResultsWithRef{end+1} = {Results_vs{end}, main_results_running{:}};% 29
filteredResultsWithRef{end+1} = {ref{:}, Results_PF_models{:}};         % 30
filteredResultsWithRef{end+1} = {ref{:}, Results_combination{:}};       % 31
filteredResultsWithRef{end+1} = {ref{:}, Results_mtp_wrt_k_mtj{:}};     % 32
filteredResultsWithRef{end+1} = {ref{:}, Results_local_min{:}};         % 33
filteredResultsWithRef{end+1} = {ref{:}, Results_active{:}};            % 34
filteredResultsWithRef{end+1} = {ref{:}, Results_active_muscle{:}};     % 35
filteredResultsWithRef{end+1} = {ref{:}, Results_active_muscle_v0{:}};  % 36
filteredResultsWithRef{end+1} = {Results_tanh{:}};                      % 37

idx = [1,5,9,13:16,21,25]; % for comparison plots in function of k_mtj
% idx = [1,5,9];


%% check for unused results
% Results_all = {};
% for i=1:length(filteredResultsWithRef)
%     Results_all = {Results_all{:},filteredResultsWithRef{i}{2:end}};
% end
% 
% dpath = fullfile([resultsRepo 'MidTarsalJoint';
% MatFiles = dir(fullfile(dpath,'*_pp.mat'));
% 
% 
% nFil = length(MatFiles);
% not_yet = ones(nFil,1);
% for i=1:numel(Results_all)
%    for j=1:nFil 
%        if not_yet(j) == 1
%            filename = MatFiles(j).name;
%            if sum(strfind(Results_all{i},filename))>0
%                not_yet(j) = 0;
%            end
%        end
%    end
% end
% 
% for j=1:nFil 
%     if not_yet(j) == 1
%         disp(MatFiles(j).name);
%     end
% end



%% Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ResultsFile = filteredResultsWithRef{29};
% ResultsFile = {filteredResultsWithRef{31}{[2]}};

% uncomment ones of the groups below
%%%
% ResultsFile = {ref{:}};
% LegNames = {'Falisse 2019'};

%%%
% ResultsFile = filteredResultsWithRef{28};
% LegNames = {'Falisse 2019','Elastic arch','Windlass','Elastic arch & windlass'};

%%%
% ResultsFile = {best_COT};
% LegNames = {'Elastic arch & Windlass'};

%%%
% ResultsFile = filteredResultsWithRef{30};
% LegNames = {'Falisse 2019','PF: linear','PF: Natali2010','PF: Cheng2008',...
%     'PF: Song2011','PF: Gefen2002','PF,k_m_t_j: Song2011','PF,k_m_t_j: Gefen2002'};

%%%
% ResultsFile = {filteredResultsWithRef{1}{[1,end-3:-1:2]}};
% LegNames = {'Falisse 2019','k_{mtj} = 5000Nm/rad','k_{mtj} = 2000Nm/rad','k_{mtj} = 1500Nm/rad',...
%     'k_{mtj} = 800Nm/rad','k_{mtj} = 500Nm/rad','k_{mtj} = 400Nm/rad','k_{mtj} = 300Nm/rad',...
%     'k_{mtj} = 250Nm/rad','k_{mtj} = 200Nm/rad','k_{mtj} = 150Nm/rad','k_{mtj} = 100Nm/rad','k_{mtj} = 50Nm/rad'};

%%%
% ResultsFile = filteredResultsWithRef{32};
% LegNames = {'Falisse 2019','PF: Song2011; k_{mtj}=300Nm/rad','PF: Song2011; k_{mtj}=800Nm/rad','PF: Natali2010; k_{mtj}=300Nm/rad','PF: Natali2010; k_{mtj}=800Nm/rad'};

%%%
% ResultsFile = {filteredResultsWithRef{30}{[2:6]}};
% LegNames = {'PF: linear','PF: Natali2010','PF: Cheng2008','PF: Song2011','PF: Gefen2002'};

%%%
% ResultsFile = filteredResultsWithRef{20};
% LegNames = {'Falisse 2019','Elastic arch & Windlass','With toe flex/ext (k_{mtp}=5)','With toe flex/ext (k_{mtp}=1)'};

%%%
% ResultsFile = {filteredResultsWithRef{26}{[1,2,3]}};
% LegNames = {'Falisse 2019','Elastic arch & Windlass','Stiffer contact spheres'};

%%%
% ResultsFile = {filteredResultsWithRef{31}{[1,2]}};
% LegNames = {'Falisse 2019','Combination'};

%%%
% ResultsFile = filteredResultsWithRef{31};
% LegNames = {'Falisse 2019','Combination','Compliant'};

%%%
% ResultsFile = filteredResultsWithRef{34};
% LegNames = {'Falisse 2019','w/o actuator','F_{PF} * a_{sol}','PIM (w=1e+6)','PIM (w=1e+3)','PIM (w=1e+3, w_P=500)','PIM (w=1e+3, w_P=1e+4)','PIM (w=1e+4, w_P=1e+4)'};

%%%
% ResultsFile = filteredResultsWithRef{35};
% LegNames = {'Falisse 2019','w/o actuator','PIM (w=1e+3, w_P=1e+4)','musc, PIM (w=1e+3, w_P=1e+4)'};

%%%
% ResultsFile = {filteredResultsWithRef{28}{[1,3,4]},filteredResultsWithRef{26}{3},filteredResultsWithRef{31}{2}};
% LegNames = {'Falisse 2019','Windlass','Elastic arch & windlass','Stiffer contact spheres','Combination'};

%%%
% ResultsFile = {filteredResultsWithRef{26}{3},filteredResultsWithRef{31}{2}};
% LegNames = {'Stiffer contact spheres','Combination'};

%%%
% ResultsFile = filteredResultsWithRef{33};
% LegNames = {'Falisse 2019','Local minimum'};

%%%
% ResultsFile = {filteredResultsWithRef{1}{1},filteredResultsWithRef{1}{end}};
% LegNames = {'no mtj','k_{mtj} = 10^6N/rad'};

%%%
% ResultsFile = {filteredResultsWithRef{35}{[1,2,end]}};
% LegNames = {'Falisse 2019','w/o actuator','musc'};

%%%
% ResultsFile = filteredResultsWithRef{36};
% LegNames = {'Falisse 2019','w/o actuator','musc, PF: Gefen, mtj: Gefen','musc, PF: Natali, mtj: Gefen'...
%     ,'musc, PF: Natali, mtj: 300'};

%%%
% ResultsFile = {filteredResultsWithRef{36}{[1,end]}};
% LegNames = {'Falisse 2019','musc, PF: Natali, mtj: 300'};

%%%
% ResultsFile = {filteredResultsWithRef{28}{[1,4]},filteredResultsWithRef{26}{3},filteredResultsWithRef{31}{2},filteredResultsWithRef{36}{end}};
% LegNames = {'Falisse 2019','Elastic arch & windlass','EA & WL, stiff contact','Combination','musc, PF: Natali, mtj: 300'};


%%%
% ResultsFile = {filteredResultsWithRef{1}{[1,end-4:-1:2]}};
% LegNames = {'Falisse 2019','k_{mtj} = 2000Nm/rad','k_{mtj} = 1500Nm/rad',...
%     'k_{mtj} = 800Nm/rad','k_{mtj} = 500Nm/rad','k_{mtj} = 400Nm/rad','k_{mtj} = 300Nm/rad',...
%     'k_{mtj} = 250Nm/rad','k_{mtj} = 200Nm/rad','k_{mtj} = 150Nm/rad','k_{mtj} = 100Nm/rad','k_{mtj} = 50Nm/rad'};

%%%
% ResultsFile = {filteredResultsWithRef{9}{[1,end:-1:2]}}; %5 9
% LegNames = {'Falisse 2019','k_{mtj} = 2000Nm/rad','k_{mtj} = 1500Nm/rad',...
%     'k_{mtj} = 800Nm/rad','k_{mtj} = 500Nm/rad','k_{mtj} = 400Nm/rad','k_{mtj} = 300Nm/rad',...
%     'k_{mtj} = 250Nm/rad','k_{mtj} = 200Nm/rad','k_{mtj} = 150Nm/rad','k_{mtj} = 100Nm/rad','k_{mtj} = 50Nm/rad'};

%%%
ResultsFile = filteredResultsWithRef{37};
LegNames = {'tanh, b=10 (default)','tanh, b=50','tanh, b=100'};


%%
if plot_full_separate
    mtj = 1;
    figNamePrefix = 'none'; % set this to a path to save the figures
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\SOTA';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\MLA_vs_WL';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\best';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\PF_stiffness_1';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\k_mtj';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\k_mtj_Song';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\musc';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\contact_stiff';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\combination_3';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\active';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\local_min';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\k_mtj_d2';
%     figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\PIM';
%     figNamePrefix = 'C:\Users\u0150099\Documents\PhD\meetings\Optimisation_Meetings\tanh';



    %%% select figures to make
    makeplot.kinematics                     = 1; %selected joint angles
    makeplot.kinetics                       = 0; % selected joint torques
    makeplot.ankle_musc                     = 1; % ankle muscles
    makeplot.GRF                            = 1; % ground interaction
    makeplot.compareLiterature              = 0; % mtj and mtp Caravaggi 2018
    makeplot.compareTakahashi17             = 0; % "distal to segment" power analysis
    makeplot.compareTakahashi17_separate    = 0; % "distal to segment" power analysis
    makeplot.compareTakahashi17_mtj_only    = 0; % plot mtj power over experimental result
    makeplot.compareTakahashi17_W_bar       = 0; % "distal to segment" work analysis
    makeplot.allQsTs                        = 0; % all joint angles and torques
    makeplot.windlass                       = 1; % plantar fascia and foot arch info
    makeplot.power                          = 0; % datailed power decomposition
    makeplot.work                           = 0; % same as power, but work over GC
    makeplot.work_bar                       = 0; % positive, negative and net work bar plot
    makeplot.work_bar_small                 = 0; % positive, negative and net work bar plot
    makeplot.power_main                     = 0; % main power components of foot
    makeplot.spatiotemp                     = 0; % stridelength etc.
    makeplot.ankle_correlation              = 0; % correlation of ankle 
    makeplot.E_muscle_bar                   = 0; % muscle metabolic energy totals
    makeplot.E_muscle_bar_small             = 0; % metabolic energy and work by selected muscle groups
    makeplot.toes                           = 0; % toe flexor and extensor muscle info
    makeplot.Edot_all                       = 0; % summed metabolic energy rate
    makeplot.Energy_cost                    = 0; % decompose metabolic cost components
    makeplot.muscle_act                     = 0; % muscle activity
    makeplot.muscle_joint_power             = 0;
    

    %%% call function that makes figures
    PlotResults_3DSim_Report(ResultsFile,LegNames,'Fal_s1',mtj,makeplot,figNamePrefix);

%     PlotEnergySmoothing(ResultsFile,LegNames)

    for i=1:3
%         PlotEnergySmoothVsNonSmooth(ResultsFile{i},LegNames{i})
    end

end

%% make tabbed figure
% Set last argument to 0 for main figure, to 1 for cross-correlation
% coefficient figure or to 2 for both.
if plot_full_tabbed
    [h_default,h_ccc] = Plot3D(ResultsFile,'Fal_s1',0);
end

%% compare ALL muscles for 2 simulation results
ResultsFile1 = ref{1};
ResultsFile2 = filteredResultsWithRef{37}{end};

% % PlotResultsComparison_3DSim(ResultsFile1,ResultsFile2);

%% cost of transport in function of midtarsal joint stiffness
plot_COT_k = 0;
if plot_COT_k
%     idx = [1,5,9,13:16,21,25];
%     idx = [1,5,9];
%     idx = [1,13:16];   
% idx=1;

    scs = get(0,'ScreenSize');
    figure('Position',[1+scs(3)/2,scs(4)/2+20,scs(3)/2, scs(4)/2-100]);
    CsV = hsv(length(idx)+1);
    load(ref{1},'R');
    subplot(1,3,1:2)
    plot([0,1e6],[1,1]*R.COT,'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    subplot(2,3,6)
    semilogx([10,2e6],[1,1]*R.COT,'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    ds = zeros(9,20);
    for i=1:length(idx)
        k_COT = zeros(4,numel(filteredResultsWithRef{idx(i)}));

        for j=1:numel(filteredResultsWithRef{idx(i)})
            load(filteredResultsWithRef{idx(i)}{j},'R');
            has_mtj = isfield(R.S,'mtj') && ~isempty(R.S.mtj) && R.S.mtj;
            if has_mtj
                k_COT(1,j) = R.S.kMT_li;
                k_COT(2,j) = R.COT;
                
                dist_trav = R.Qs(end,strcmp(R.colheaders.joints,'pelvis_tx')) - R.Qs(1,strcmp(R.colheaders.joints,'pelvis_tx'));
                imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
                imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));
                qdot_mtj = R.Qdots(:,imtj)*pi/180;
                M_li = R.windlass.M_li;
                P_mtj_li = qdot_mtj.*M_li/R.body_mass/dist_trav;
                P_mtj_li_pos = P_mtj_li;
                P_mtj_li_pos(P_mtj_li_pos<0) = 0;
                W_mtj_li = trapz(R.t,P_mtj_li_pos);
                k_COT(3,j) = W_mtj_li;
                
                
                iarch_stance = find(R.GRFs_separate(:,2)>5 & R.GRFs_separate(:,8)>5);
                ipush_off = find(R.GRFs_separate(:,2)<5 & R.GRFs_separate(:,8)>5);
    
                c1 = polyfit(R.Qs(iarch_stance,imtp)*pi/180,-R.Tid(iarch_stance,imtp),1);
                k_COT(4,j) = c1(1);

                c2 = polyfit(R.Qs(ipush_off,imtp)*pi/180,-R.Tid(ipush_off,imtp),1);
                k_COT(5,j) = c2(1);
                
            end

        end
        subplot(1,3,1:2)
        plot(k_COT(1,2:end),k_COT(2,2:end),'.-','MarkerSize',20,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
        subplot(2,3,6)
        semilogx(k_COT(1,2:end),k_COT(2,2:end),'.-','MarkerSize',10,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
    end

    subplot(1,3,1:2)
    lh=legend('Location','northwest');
    lhPos = lh.Position;
    lhPos(1) = lhPos(1)+0.5;
    lhPos(2) = lhPos(2)+0.05;
    set(lh,'position',lhPos);
    xlabel('mtj stiffness (Nm/rad)')
    ylabel('COT (J kg^-^1 m^-^1)','Interpreter','tex')
    title('Cost of transport and midtarsal joint stiffness')
    xlim([0,2050])
    
    subplot(2,3,6)
    xlabel('\fontsize{10} mtj stiffness (Nm/rad)','Interpreter','tex')
    ylabel('\fontsize{10} COT (J kg^-^1 m^-^1)','Interpreter','tex')
    title('\fontsize{10} Convergence','Interpreter','tex')
    xlim([20,1e6])
    a1 = gca;
    a1.YAxisLocation = 'right';
    
end

%% stride frequency in function of midtarsal joint stiffness
plot_frq_k = 0;
if plot_frq_k
%     idx = [1,5,9,13:16,19,21,24,25];
%     idx = [1,5,9];
%     idx = [1,13:16];   

    scs = get(0,'ScreenSize');
    figure('Position',[1+scs(3)/2,scs(4)/2+20,scs(3)/2, scs(4)/2-100]);
    CsV = hsv(length(idx)+1);
    load(ref{1},'R');
    subplot(1,3,1:2)
    plot([0,1e6],[1,1]*1./(R.tf_step*2),'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    subplot(2,3,6)
    semilogx([10,2e6],[1,1]*1./(R.tf_step*2),'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    ds = zeros(9,20);
    for i=1:length(idx)
        k_frq = zeros(2,numel(filteredResultsWithRef{idx(i)}));

        for j=1:numel(filteredResultsWithRef{idx(i)})
            load(filteredResultsWithRef{idx(i)}{j},'R');
            has_mtj = isfield(R.S,'mtj') && ~isempty(R.S.mtj) && R.S.mtj;
            if has_mtj
                k_frq(1,j) = R.S.kMT_li;
                k_frq(2,j) = 1./(R.tf_step*2);
            end

        end
        subplot(1,3,1:2)
        plot(k_frq(1,2:end),k_frq(2,2:end),'.-','MarkerSize',20,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
        subplot(2,3,6)
        semilogx(k_frq(1,2:end),k_frq(2,2:end),'.-','MarkerSize',10,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
    end

    subplot(1,3,1:2)
    lh=legend('Location','northwest');
    lhPos = lh.Position;
    lhPos(1) = lhPos(1)+0.5;
    lhPos(2) = lhPos(2)+0.05;
    set(lh,'position',lhPos);
    xlabel('mtj stiffness (Nm/rad)')
    ylabel('frequenct (Hz)','Interpreter','tex')
    title('Stride frequency and midtarsal joint stiffness')
    xlim([0,2050])
    
    subplot(2,3,6)
    xlabel('\fontsize{10} mtj stiffness (Nm/rad)','Interpreter','tex')
    ylabel('\fontsize{10} f (Hz)','Interpreter','tex')
    title('\fontsize{10} Convergence','Interpreter','tex')
    xlim([20,1e6])
    a1 = gca;
    a1.YAxisLocation = 'right';
    
end

%% peak soleus activity in function of midtarsal joint stiffness
plot_aSol_k = 0;
if plot_aSol_k
%     idx = [1,5,9,13:16,19,21,24,25];
%     idx = [1,5,9];
%     idx = [1,13:16];   

    scs = get(0,'ScreenSize');
    figure('Position',[1+scs(3)/2,scs(4)/2+20,scs(3)/2, scs(4)/2-100]);
    CsV = hsv(length(idx)+1);
    load(ref{1},'R');
    iSol = find(strcmp(R.colheaders.muscles,'soleus_r'));
    subplot(1,3,1:2)
    plot([0,1e6],[1,1]*max(R.a(:,iSol)),'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    subplot(2,3,6)
    semilogx([10,2e6],[1,1]*max(R.a(:,iSol)),'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    ds = zeros(9,20);
    for i=1:length(idx)
        iSol = find(strcmp(R.colheaders.muscles,'soleus_r'));
        k_aSol = zeros(2,numel(filteredResultsWithRef{idx(i)}));

        for j=1:numel(filteredResultsWithRef{idx(i)})
            load(filteredResultsWithRef{idx(i)}{j},'R');
            has_mtj = isfield(R.S,'mtj') && ~isempty(R.S.mtj) && R.S.mtj;
            if has_mtj
                k_aSol(1,j) = R.S.kMT_li;
                k_aSol(2,j) = max(R.a(:,iSol));
            end

        end
        subplot(1,3,1:2)
        plot(k_aSol(1,2:end),k_aSol(2,2:end),'.-','MarkerSize',20,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
        subplot(2,3,6)
        semilogx(k_aSol(1,2:end),k_aSol(2,2:end),'.-','MarkerSize',10,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
    end

    subplot(1,3,1:2)
    lh=legend('Location','northwest');
    lhPos = lh.Position;
    lhPos(1) = lhPos(1)+0.5;
    lhPos(2) = lhPos(2)+0.05;
    set(lh,'position',lhPos);
    xlabel('mtj stiffness (Nm/rad)')
    ylabel('max activity','Interpreter','tex')
    title('Max soleus activity and midtarsal joint stiffness')
    xlim([0,2050])
    
    subplot(2,3,6)
    xlabel('\fontsize{10} mtj stiffness (Nm/rad)','Interpreter','tex')
    ylabel('\fontsize{10} a_max','Interpreter','tex')
    title('\fontsize{10} Convergence','Interpreter','tex')
    xlim([20,1e6])
    a1 = gca;
    a1.YAxisLocation = 'right';
    
end

%% objective function term for metabolic energy
plot_cost_E_k = 0;
if plot_cost_E_k
%     idx = [1,5,9,13:16,21,25];
%     idx = [1,5,9];
%     idx = [1,13:16];   
% idx=1;

    scs = get(0,'ScreenSize');
    figure('Position',[1+scs(3)/2,scs(4)/2+20,scs(3)/2, scs(4)/2-100]);
    CsV = hsv(length(idx)+1);
    load(ref{1},'R');
    dist_trav = R.Qs(end,strcmp(R.colheaders.joints,'pelvis_tx')) - ...
                R.Qs(1,strcmp(R.colheaders.joints,'pelvis_tx'));
    subplot(1,3,1:2)
    plot([0,1e6],[1,1]*R.Obj.E/dist_trav*2,'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    subplot(2,3,6)
    semilogx([10,2e6],[1,1]*R.Obj.E/dist_trav*2,'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    ds = zeros(9,20);
    for i=1:length(idx)
        k_cost_E = zeros(4,numel(filteredResultsWithRef{idx(i)}));

        for j=1:numel(filteredResultsWithRef{idx(i)})
            load(filteredResultsWithRef{idx(i)}{j},'R');
            has_mtj = isfield(R.S,'mtj') && ~isempty(R.S.mtj) && R.S.mtj;
            if has_mtj
                k_cost_E(1,j) = R.S.kMT_li;
                k_cost_E(2,j) = R.Obj.E/dist_trav*2;
                
                dist_trav = R.Qs(end,strcmp(R.colheaders.joints,'pelvis_tx')) - R.Qs(1,strcmp(R.colheaders.joints,'pelvis_tx'));
                imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
                imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));
                qdot_mtj = R.Qdots(:,imtj)*pi/180;
                M_li = R.windlass.M_li;
                P_mtj_li = qdot_mtj.*M_li/R.body_mass/dist_trav;
                P_mtj_li_pos = P_mtj_li;
                P_mtj_li_pos(P_mtj_li_pos<0) = 0;
                W_mtj_li = trapz(R.t,P_mtj_li_pos);
                k_cost_E(3,j) = W_mtj_li;
                
                
                iarch_stance = find(R.GRFs_separate(:,2)>5 & R.GRFs_separate(:,8)>5);
                ipush_off = find(R.GRFs_separate(:,2)<5 & R.GRFs_separate(:,8)>5);
    
                c1 = polyfit(R.Qs(iarch_stance,imtp)*pi/180,-R.Tid(iarch_stance,imtp),1);
                k_cost_E(4,j) = c1(1);

                c2 = polyfit(R.Qs(ipush_off,imtp)*pi/180,-R.Tid(ipush_off,imtp),1);
                k_cost_E(5,j) = c2(1);
                
            end

        end
        subplot(1,3,1:2)
        plot(k_cost_E(1,2:end),k_cost_E(2,2:end),'.-','MarkerSize',20,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
        subplot(2,3,6)
        semilogx(k_cost_E(1,2:end),k_cost_E(2,2:end),'.-','MarkerSize',10,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
    end

    subplot(1,3,1:2)
    lh=legend('Location','northwest');
    lhPos = lh.Position;
    lhPos(1) = lhPos(1)+0.5;
    lhPos(2) = lhPos(2)+0.05;
    set(lh,'position',lhPos);
    xlabel('mtj stiffness (Nm/rad)')
    ylabel('objective (-)','Interpreter','tex')
    title('Metabolic energy objective and midtarsal joint stiffness')
    xlim([0,2050])
    
    subplot(2,3,6)
    xlabel('\fontsize{10} mtj stiffness (Nm/rad)','Interpreter','tex')
    ylabel('\fontsize{10} objective (-)','Interpreter','tex')
    title('\fontsize{10} Convergence','Interpreter','tex')
    xlim([20,1e6])
    a1 = gca;
    a1.YAxisLocation = 'right';
    
end

%% objective function term for fatigue
plot_cost_a_k = 0;
if plot_cost_a_k
%     idx = [1,5,9,13:16,21,25];
%     idx = [1,5,9];
%     idx = [1,13:16];   
% idx=1;

    scs = get(0,'ScreenSize');
    figure('Position',[1+scs(3)/2,scs(4)/2+20,scs(3)/2, scs(4)/2-100]);
    CsV = hsv(length(idx)+1);
    load(ref{1},'R');
    dist_trav = R.Qs(end,strcmp(R.colheaders.joints,'pelvis_tx')) - ...
                R.Qs(1,strcmp(R.colheaders.joints,'pelvis_tx'));
    subplot(1,3,1:2)
    plot([0,1e6],[1,1]*R.Obj.A/dist_trav*2,'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    subplot(2,3,6)
    semilogx([10,2e6],[1,1]*R.Obj.A/dist_trav*2,'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    ds = zeros(9,20);
    for i=1:length(idx)
        k_cost_E = zeros(4,numel(filteredResultsWithRef{idx(i)}));

        for j=1:numel(filteredResultsWithRef{idx(i)})
            load(filteredResultsWithRef{idx(i)}{j},'R');
            has_mtj = isfield(R.S,'mtj') && ~isempty(R.S.mtj) && R.S.mtj;
            if has_mtj
                k_cost_E(1,j) = R.S.kMT_li;
                k_cost_E(2,j) = R.Obj.A/dist_trav*2;
                
                dist_trav = R.Qs(end,strcmp(R.colheaders.joints,'pelvis_tx')) - R.Qs(1,strcmp(R.colheaders.joints,'pelvis_tx'));
                imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
                imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));
                qdot_mtj = R.Qdots(:,imtj)*pi/180;
                M_li = R.windlass.M_li;
                P_mtj_li = qdot_mtj.*M_li/R.body_mass/dist_trav;
                P_mtj_li_pos = P_mtj_li;
                P_mtj_li_pos(P_mtj_li_pos<0) = 0;
                W_mtj_li = trapz(R.t,P_mtj_li_pos);
                k_cost_E(3,j) = W_mtj_li;
                
                
                iarch_stance = find(R.GRFs_separate(:,2)>5 & R.GRFs_separate(:,8)>5);
                ipush_off = find(R.GRFs_separate(:,2)<5 & R.GRFs_separate(:,8)>5);
    
                c1 = polyfit(R.Qs(iarch_stance,imtp)*pi/180,-R.Tid(iarch_stance,imtp),1);
                k_cost_E(4,j) = c1(1);

                c2 = polyfit(R.Qs(ipush_off,imtp)*pi/180,-R.Tid(ipush_off,imtp),1);
                k_cost_E(5,j) = c2(1);
                
            end

        end
        subplot(1,3,1:2)
        plot(k_cost_E(1,2:end),k_cost_E(2,2:end),'.-','MarkerSize',20,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
        subplot(2,3,6)
        semilogx(k_cost_E(1,2:end),k_cost_E(2,2:end),'.-','MarkerSize',10,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
    end

    subplot(1,3,1:2)
    lh=legend('Location','northwest');
    lhPos = lh.Position;
    lhPos(1) = lhPos(1)+0.5;
    lhPos(2) = lhPos(2)+0.05;
    set(lh,'position',lhPos);
    xlabel('mtj stiffness (Nm/rad)')
    ylabel('objective (-)','Interpreter','tex')
    title('Muscle activity objective and midtarsal joint stiffness')
    xlim([0,2050])
    
    subplot(2,3,6)
    xlabel('\fontsize{10} mtj stiffness (Nm/rad)','Interpreter','tex')
    ylabel('\fontsize{10} objective (-)','Interpreter','tex')
    title('\fontsize{10} Convergence','Interpreter','tex')
    xlim([20,1e6])
    a1 = gca;
    a1.YAxisLocation = 'right';
    
end

%% work by mtj stiffness
plot_W_mtj_k = 1;
if plot_W_mtj_k
%     idx = [1,5,9,13:16,21,25];
%     idx = [1,5,9];
%     idx = [1,13:16];   
% idx=1;

    scs = get(0,'ScreenSize');
    figure('Position',[1+scs(3)/2,scs(4)/2+20,scs(3)/2, scs(4)/2-100]);
    CsV = hsv(length(idx)+1);
    load(ref{1},'R');
    dist_trav = R.Qs(end,strcmp(R.colheaders.joints,'pelvis_tx')) - ...
                R.Qs(1,strcmp(R.colheaders.joints,'pelvis_tx'));
    subplot(1,3,1:2)
    plot([0,1e6],[1,1]*0,'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    subplot(2,3,6)
    semilogx([10,2e6],[1,1]*0,'Color',CsV(1,:),'DisplayName','Falisse 2019')
    hold on
    grid on
    ds = zeros(9,20);
    for i=1:length(idx)
        k_cost_E = zeros(4,numel(filteredResultsWithRef{idx(i)}));

        for j=1:numel(filteredResultsWithRef{idx(i)})
            load(filteredResultsWithRef{idx(i)}{j},'R');
            has_mtj = isfield(R.S,'mtj') && ~isempty(R.S.mtj) && R.S.mtj;
            if has_mtj
                k_cost_E(1,j) = R.S.kMT_li;
                k_cost_E(2,j) = R.Obj.A/dist_trav*2;
                
                dist_trav = R.Qs(end,strcmp(R.colheaders.joints,'pelvis_tx')) - R.Qs(1,strcmp(R.colheaders.joints,'pelvis_tx'));
                imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
                imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));
                qdot_mtj = R.Qdots(:,imtj)*pi/180;
                M_li = R.windlass.M_li;
                P_mtj_li = qdot_mtj.*M_li/R.body_mass/dist_trav;
                P_mtj_li_pos = P_mtj_li;
                P_mtj_li_pos(P_mtj_li_pos<0) = 0;
                W_mtj_li = trapz(R.t,P_mtj_li_pos);
                k_cost_E(3,j) = W_mtj_li;
                
                
                iarch_stance = find(R.GRFs_separate(:,2)>5 & R.GRFs_separate(:,8)>5);
                ipush_off = find(R.GRFs_separate(:,2)<5 & R.GRFs_separate(:,8)>5);
    
                c1 = polyfit(R.Qs(iarch_stance,imtp)*pi/180,-R.Tid(iarch_stance,imtp),1);
                k_cost_E(4,j) = c1(1);

                c2 = polyfit(R.Qs(ipush_off,imtp)*pi/180,-R.Tid(ipush_off,imtp),1);
                k_cost_E(5,j) = c2(1);
                
            end

        end
        subplot(1,3,1:2)
        plot(k_cost_E(1,2:end),k_cost_E(3,2:end),'.-','MarkerSize',20,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
        subplot(2,3,6)
        semilogx(k_cost_E(1,2:end),k_cost_E(3,2:end),'.-','MarkerSize',10,'Color',CsV(1+i,:),'DisplayName',groupNames{idx(i)})
    end

    subplot(1,3,1:2)
    lh=legend('Location','northwest');
    lhPos = lh.Position;
    lhPos(1) = lhPos(1)+0.5;
    lhPos(2) = lhPos(2)+0.05;
    set(lh,'position',lhPos);
    xlabel('mtj stiffness (Nm/rad)')
    ylabel('W (J kg^-^1 m^-^1)','Interpreter','tex')
    title('Positive work by midtarsal joint stiffness')
    xlim([0,2050])
    
    subplot(2,3,6)
    xlabel('\fontsize{10} mtj stiffness (Nm/rad)','Interpreter','tex')
    ylabel('\fontsize{10} objective (-)','Interpreter','tex')
    title('\fontsize{10} Convergence','Interpreter','tex')
    xlim([20,1e6])
    a1 = gca;
    a1.YAxisLocation = 'right';
    
end


%%

if plot_static_foot
    
%     resultFiles = {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Gefen2002_Gefen2002_Q-30_30_F0_3000_WLv3_ls150.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_none_Gefen2002_Q-30_30_F0_3000_WLv3_ls150.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_none_Ker1987_Q-30_30_F0_3000_WLv3_ls150.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k300_Q-30_30_F0_3000_WLv3_ls150_sb1.mat'])};
    
% resultFiles = {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Gefen2002_Gefen2002_Q-30_30_F0_3000_WLv3_ls150.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Gefen2002_fitted6_Q-30_30_F0_1000_WLv3_ls150_sb1_PFx2.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k300_Q-30_30_F0_3000_WLv3_ls150_sb1.mat'])};
            
% resultFiles = {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Gefen2002_k300_Q0_0_F0_1000_WLv3_ls150_sb1.mat'])
%                fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt2_v1_Gefen2002_k300_Q0_0_F0_1000_WLv3_ls150_sb1.mat'])
%                fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt3_v1_Gefen2002_k300_Q0_0_F0_1000_WLv3_ls150_sb1.mat'])};

            
% resultFiles = {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k300_Q-30_30_F0_3000_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k300_Q-30_30_F0_1000_WLv3_ls150_sb1_PFx10.mat'])};

            
%     resultFiles = {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_fitted4_Q-20_30_F0_0_WLv3_ls148_mtp1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_fitted4_Q-20_30_F0_0_WLv3_ls148_mtp2.mat'])};
    
%     resultFiles =  {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k50_Q0_30_F0_1000_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k300_Q0_30_F0_1000_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k800_Q0_30_F0_1000_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_linear_k300_Q0_30_F0_1000_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Gefen2002_Gefen2002_Q0_30_F0_1000_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_Song2011_Q0_30_F0_1000_WLv3_ls150_sb1.mat'])};
    
%     resultFiles =  {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k30_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k50_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k100_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k150_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k200_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k250_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k300_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k350_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k380_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k400_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k450_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k500_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k600_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k700_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k800_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k900_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k1000_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k1200_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k1500_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k2000_Q0_30_F0_960_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k5000_Q0_30_F0_960_WLv3_ls150_sb1.mat'])};


%     resultFiles =  {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k10_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k30_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k50_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k100_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k150_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k200_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k250_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k300_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k350_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k400_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k450_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k500_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k550_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k600_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k650_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k700_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k750_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k800_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k900_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k1000_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k1100_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k1200_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k1500_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k2000_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                     };
                

% resultFiles =  {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k300_Q-30_30_F0_945_WLv3_ls150_sb1.mat'])
% %                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k800_Q-30_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k300_Q-30_30_F0_945_WLv3_ls150_sb1.mat'])
% %                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k800_Q-30_30_F0_945_WLv3_ls150_sb1.mat'])
%                 };


% resultFiles =  {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k50_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k100_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k150_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k200_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k250_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k300_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k350_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k400_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k450_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k500_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k550_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k600_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k650_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k700_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k750_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k800_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k900_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k1000_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k1100_Q0_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Song2011_k1200_Q0_30_F0_945_WLv3_ls150_sb1.mat'])};


% resultFiles =  {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Gefen2002_Gefen2002_Q-30_30_F0_945_WLv3_ls150_sb1.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Gefen2002_Gefen2002_Q-30_30_F0_945_WLv3_ls150_sb2.mat'])
%                 fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Gefen2002_Gefen2002_Q-30_30_F0_945_WLv3_ls150_sb3.mat'])};

% resultFiles =  {fullfile([resultsRepo 'FootModel\Foot_3D_Fal_s1_mtj_subt1_v5_Natali2010_k300_Q-45_45_F0_0_WLv3_ls150_sb1.mat'])};

resultFiles =  {fullfile([resultsRepo 'FootModel\Foot_3D_Pog_s1_mtj_v6_Gefen2002_Gefen2002_Q0_0_F0_945_WLv3_ls150_sb1.mat'])};
            
            
    % call plot function
    nrf = numel(resultFiles);
    CsV = hsv(nrf);
    for i=1:nrf
        load(resultFiles{i},'R');
        if i==1
            h = PlotResults_FootSim(R,CsV(i,:),0,2);
        else
            PlotResults_FootSim(R,CsV(i,:),h,2);
        end
    end
    
end















%%

% k_MT = [10,30,50:50:800,900:100:1200,1500,2000];
% mtp_qdkl = [-0.1419,-0.064616,-0.016848,0.04365,0.067051,0.075793,0.078264,0.077705,...
%     0.075768,0.073134,0.0703,0.067442,0.068885,0.061921,0.059326,0.056915,...
%     0.054708,0.052554,0.047983,0.045381,0.043247,0.046333,0.032625,0.026503];
% 
% scs = get(0,'ScreenSize');
% h1 = figure('Position',[scs(3)/2,140,scs(3)*0.4, scs(4)/2-100]);
% 
% 
% subplot(2,4,[1,2])
% plot(k_COT(1,2:end),k_COT(2,2:end),'.-','MarkerSize',20,'DisplayName','Cost of transport')
% ylabel('COT (J kg^-^1 m^-^1)')
% xlim([-50,2050])
% xlabel('Midtarsal stiffness')
% title('Cost of transport')
% grid on
% set(gca,'Box','off')
% 
% subplot(2,4,[3,4])
% plot(k_COT(1,2:end),k_COT(3,2:end),'.-','MarkerSize',20,'DisplayName','Positive Work by k_{mtj}')
% ylabel('Work (J kg^-^1 m^-^1)')
% xlim([-50,2050])
% xlabel('Midtarsal stiffness')
% title('Positive work by midtarsal joint stiffness')
% grid on
% set(gca,'YAxisLocation','right')
% set(gca,'Box','off')
% 
% subplot(2,4,[6,7])
% plot(k_MT,mtp_qdkl*100,'.-','MarkerSize',20,'DisplayName','Relative mtp quasi-stiffness increase with load')
% title('Relative mtp quasi-stiffness increase with load increase')
% ylabel('(%)')
% xlim([-50,2050])
% xlabel('Midtarsal stiffness')
% grid on
% set(gca,'Box','off')
% 
% mtp_qdkl_i = interp1(k_MT,mtp_qdkl,k_COT(1,2:12),'spline','extrap');
% rr1 = xcorr(mtp_qdkl_i,k_COT(2,2:12),0,'coeff');
% text(-700,5,{'$\nwarrow$',['R = ' num2str(rr1,2)],'$\qquad \searrow$'},'Interpreter','latex')
% 
% rr2 = xcorr(mtp_qdkl_i,k_COT(3,2:12),0,'coeff');
% text(2300,5,{'$\qquad  \nearrow$',['R = ' num2str(rr2,2)],'$\swarrow$'},'Interpreter','latex')
% 
% 
% rr3 = xcorr(k_COT(2,2:12),k_COT(3,2:12),0,'coeff');
% text(700,30,{['$\leftarrow$ R = ' num2str(rr3,2) '$\rightarrow$']},'Interpreter','latex')
% 
% 
% % subplot(2,2,4)
% % plot(k_COT(1,5:end),k_COT(4,5:end),'.-','MarkerSize',20,'DisplayName','full support')
% % hold on
% % ylim([-200,200])
% % yyaxis right
% % plot(k_COT(1,2:end),k_COT(5,2:end),'.-','MarkerSize',20,'DisplayName','push-off')
% % ylim([-40,40])
% % title('Dynamic mtp quasi-stiffness (Nm/rad)')
% % ylabel('(Nm/rad)')
% % xlim([-50,2050])
% % xlabel('Midtarsal stiffness')
% % legend
% 
% 
% 
%%

% h1=gcf;
% figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\k_mtj';
% set(h1,'PaperPositionMode','auto')
% print(h1,[figNamePrefix '_COT_curve'],'-dpng','-r0')
% print(h1,[figNamePrefix '_COT_curve'],'-depsc')


%%
% h_GC = figure('Position',[scs(3)/2,140,scs(3)*0.4, scs(4)*0.3]);
% set(h_GC,'Color','w');
% 
% subplot(3,1,[1,2])
% pathRefImg = fullfile(pathRepo,'\Figures\gait_cycle.png');
% img_GC = imread(pathRefImg);
% hold on
% % axis tight
% axis equal
% hi3 = image([-5,65],flip([0,12.75]),img_GC);
% uistack(hi3,'bottom')
% xlim([-5,100])
% ylim([-1,14])
% xlabel('(%GC)')
% ax1=gca;
% ax1.XTick = [0:10:100];
% ax1.YTick = '';
% ax1.YAxis.Visible = 'off';
% ax1.XLabel.Position(1) = ax1.XLabel.Position(1) + 59;
% ax1.XLabel.Position(2) = ax1.XLabel.Position(2) + 3.5;
% ylim([-1,16])
% title({'Gait cycle',''})
% 
% ax2 = axes('Position', get(ax1,'Position'),'XAxisLocation','top','Color','none','XColor','k');
% ax2.XTick = [0:10:100];
% ax2.YTick = '';
% ax2.XLim = ax1.XLim/0.6;
% axis equal
% xlabel('Stance phase (%)')
% ax2.YAxis.Visible = 'off';
% ax2.XLabel.Position(1) = ax2.XLabel.Position(1) - 65;
% ax2.XLabel.Position(2) = ax2.XLabel.Position(2) - 8;
% ylim([-1,16])
% 
% % subplot(20,1,20)
% ax3_pos = get(ax1,'Position');
% ax3_pos(2) = ax3_pos(2)+0.11;
% ax3_pos(4) = 0.001;
% 
% ax3 = axes('Position',ax3_pos,'Color','none','XColor','k');
% ax3.YAxis.Visible = 'off';
% ax3.XLim = ax1.XLim;
% % ax3.XAxisLocation = 'top';
% ax3.XTick = [0,10,45,60];
% ax3.XTickLabel = {'     Heel strike','     Foot flat','     Heel lift','     Toe off'};
% ax3.XTickLabelRotation = -90;
% ax3.YLim = [0,1];
% text(20,-40,'Mid stance')
% text(47,-40,'Push-off')
% text(75,-40,'Swing')


% figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\GC';
% set(h_GC,'PaperPositionMode','auto')
% print(h_GC,[figNamePrefix],'-dpng','-r0')
% print(h_GC,[figNamePrefix],'-depsc')
