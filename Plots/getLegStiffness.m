
% clear
% close all
% clc

addpath(genpath('C:\GBW_MyPrograms\NeuromechanicsToolkit'))




% res_file = fullfile(results_dir,'\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat');
figure
hold on
legend
CsV = hsv(length(ResultsFile));
for i=1:length(ResultsFile)

%     disp(LegNames{i})

    [k_leg] = calcLegStiffness(ResultsFile{i});

    plot(i,k_leg,'.','DisplayName',LegNames{i},'MarkerSize',20,'Color',CsV(i,:))
end


function [k_leg] = calcLegStiffness(res_file)

    load(res_file,'R');
    
    % model = 'Fal_s1_mtjc4_FK_sc_FDB2_MTc5_cspx10_cg9_o1x10';
    model = [R.S.OsimFileName '_cspx10_oy3'];
    
    filename_model = fullfile('C:\Users\u0150099\Documents\master_thesis\3dpredictsim\OpenSimModel\subject1',[model '.osim']);
    
    % kinematics_file = fullfile(results_dir,'\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100.mot');
    kinematics_file = replace(res_file,'_pp.mat','.mot');
    
    results_dir = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

    [BodyKin] = Opensim_BodyKinematics(filename_model,results_dir,kinematics_file);
    
    idx_com_y = find(strcmp(BodyKin.header,'center_of_mass_Y'));
    
    com_y = BodyKin.Pos(:,idx_com_y);
    com_y = com_y(1:length(com_y)/2);
    

    L0 = 0.94 - 0.07;
    
    idx_stance_r = find(R.GRFs(:,2)>=R.GRFs(1,2));
    
    idx_stance_l = find(R.GRFs(:,5)>=R.GRFs(1,2));
    
    idx_single_r = setdiff(idx_stance_r,idx_stance_l);
    
    
    tc = R.t(idx_stance_r(end));
    
    theta = asin(R.S.v_tgt*tc/(2*L0));
    
    theta_d = theta*180/pi;
    % DL = max(com_y(idx_single_r)-com_y(1)) + L0*(1-cos(theta));
    
    DL = max(com_y(idx_single_r)) - min(com_y(idx_single_r)) + L0*(1-cos(theta));
    
    DF = max(R.GRFs(idx_single_r,2))/100;
    
    k_leg = DF/DL;
    
%     disp(['K_leg = ' num2str(k_leg) ' N/BW/m'])


end