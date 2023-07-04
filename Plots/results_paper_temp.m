clear

% Achilles tendon
% results = {
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     };
% LegNames = {'3-segment model: compliant Achilles tendon','2-segment model: compliant Achilles tendon','3-segment model: stiff Achilles tendon','2-segment model: stiff Achilles tendon'};


% contact stiffness
% results = {
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sc_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     };
% LegNames = {'3-segment model: stiff contact','2-segment model: stiff contact','3-segment model: compliant contact','2-segment model: compliant contact'};

% scaling
% results = {
%     '\with_better_knee\Fal_s1_mtjc4_FK_sd_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtp_FK_sd_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTPp_k25_d020_tau_ig21'
%     };
% LegNames = {'3-segment model: custom scaling','2-segment model: custom scaling','3-segment model: isometric scaling','2-segment model: isometric scaling'};


% extrinsic foot muscles
%  results = {   
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_MTJp_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'   
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_ig21'
%     };
%  LegNames = {'3-segment model: muscle-driven mtj, mtpj', '2-segment model: passive mtpj', '3-segment model: passive mtj, mtpj','2-segment model: muscle-driven mtpj'};

% intrinsic foot muscle, plantar fascia stiffness
%  results = { 
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_FDB2_lTs125_Fpsl10_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_ig21'
%     };
%  LegNames = {'stiff plantar fascia, with intrinsic muscle', 'stiff plantar fascia, without intrinsic muscle',...
%      'compliant plantar fascia, with intrinsic muscle','compliant plantar fascia, without intrinsic muscle'};


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% main

% % new vs SOTA
% results = {
%     '\results_paper\Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     };
% LegNames = {'2-segment foot model Falisse et al.','new 2-segment foot model','3-segment foot model'};

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
%  results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_MTJp_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1_N100_v2'   
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_ig1_N100'
%     };
%  LegNames = {'3-segment model: muscle-driven mtj, mtpj', '2-segment model: passive mtpj', '3-segment model: passive mtj, mtpj','2-segment model: muscle-driven mtpj'};

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

% % effect of intrinsic muscle nerve block
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_nb_lTs125_Fpsl10_ig21_N100_v2'
%     };
% LegNames = {'Nominal 3-segment foot model','Intrinsic foot muscle nerve block'};
    
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
%     'Compliant plantar fascia, without intrinsic muscle','Reduced arch height (3-segment)'};


% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_none_ls141_FDB2_lTs120_Fpsl10_ig21_pp.mat'
%     };
% LegNames = {'Nominal 3-segment foot model','Low-arched foot without plantar fascia'};

% % effect of intrinsic muscle nerve block
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_tanh10'
%     };
% LegNames = {'tanh b = 100','tanh b = 10'};


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
% %     '\results_paper\Fal_s1_mtj_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
% %     '\results_paper\Fal_s1_mtjc1_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc2_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
% %     '\results_paper\Fal_s1_mtjc5_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     };
% % LegNames = {'Sagittal','Orientation 1','Orientation 2','Orientation 3','Orientation 4','Orientation 5'};
% LegNames = {'Orientation 2','Orientation 3','Orientation 4'};

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
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'    
%     };
% LegNames = {'cg 4','cg 5','cg 6','cg 7','cg 8', 'cg 9', 'cg 9 o1x10'};


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

%% other
% % added stiffness
% % v = 1.25 m/s
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel12.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k5_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel12.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k10_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel12.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k40_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel12.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k110_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel12.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k200_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel12.5_ig1_N100'
%     };
% LegNames = {'v = 1.25, k = 1','v = 1.25, k = 5','v = 1.25, k = 10','v = 1.25, k = 40','v = 1.25, k = 110','v = 1.25, k = 200'};

% % v = 1.33 m/s
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k2_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k5_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100'
%     };
% LegNames = {'v = 1.33, k = 1','v = 1.33, k = 2','v = 1.33, k = 5'};

% % v = 1.75 m/s
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel17.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k5_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel17.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k10_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel17.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k40_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel17.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k110_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel17.5_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k200_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel17.5_ig1_N100'
%     };
% LegNames = {'v = 1.75, k = 1','v = 1.75, k = 5','v = 1.75, k = 10','v = 1.75, k = 40','v = 1.75, k = 110','v = 1.75, k = 200'};

% % v = 2.0 m/s
% results = {
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel20_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k5_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel20_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k40_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel20_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k110_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel20_ig1_N100'
%     '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k200_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel20_ig1_N100'
%     };
% LegNames = {'v = 2, k = 1','v = 2, k = 5','v = 2, k = 40','v = 2, k = 110','v = 2, k = 200'};





