clear
% close all
clc

import casadi.*

%% Contact forces
% stiffnessSX         = 1e6;
% radiusSX            = SX.sym('radiusSX',1);
% dissipationSX       = 2;
% normalSX            = [0,1,0];
% transitionVelocitySX= 0.2;
% staticFrictionSX    = 0.8;
% dynamicFrictionSX   = 0.8;
% viscousFrictionSX   = 0.5;
% spherePosSX         = SX.sym('spherePosSX',3);
% orFramePosSX        = SX.sym('orFramePosSX',3);
% v_linSX             = SX.sym('v_linSX',3);
% omegaSX             = SX.sym('omegaSX',3);
% RotSX               = SX.sym('RotSX',9);
% TrSX                = SX.sym('TrSX',3);
% % Hunt-Crossley contact model
% forceSX = HCContactModel(stiffnessSX,radiusSX,dissipationSX,...
%     normalSX,transitionVelocitySX,staticFrictionSX,...
%     dynamicFrictionSX,viscousFrictionSX,spherePosSX,orFramePosSX,...
%     v_linSX,omegaSX,RotSX,TrSX);
% f_contactForce = Function('f_contactForce',{radiusSX,spherePosSX,...
%     orFramePosSX,v_linSX,omegaSX,RotSX,TrSX},{forceSX});
% 
% clearvars -except 'f_contactForce'


%% contact sphere info

% cslocation(:,1) = [-0.00042152 0.0069229175108780888 -0.0049972]';
cslocation(:,1) = [0.01 0.0069229175108780888 -0.0049972]';
cslocation(:,2) = [0.06 0.01192291751087809 0.02]';
cslocation(:,3) = [0.063970169355678008 -0.011406010125810932 0.02274865219]';
cslocation(:,4) = [0.063970169355678008 -0.011406010125810932 -0.00843404781]';
cslocation(:,5) = [0.053154 -0.0015385412445609557 -0.0034173]';
cslocation(:,6) = [1.7381e-06 -0.0015385412445609557 0.022294]';

csradius = [0.032,0.032,0.023,0.021,0.016,0.018];

csframe = {'calcn_r','calcn_r','forefoot_r','forefoot_r','toes_r','toes_r'};


%% Experimental data
% trialnr = 15;
% 
% trials.gait_14.icOff = 4.27;
% trials.gait_15.icOff = 3.2;
% trials.gait_23.icOff = 2.41;
% trials.gait_25.icOff = 2.2;
% trials.gait_27.icOff = 2.92;
% trials.gait_60.icOff = 2.26;
% trials.gait_61.icOff = 2.87;
% trials.gait_63.icOff = 1.86;
% trials.gait_64.icOff = 2.14;
% trials.gait_65.icOff = 2.1;
% 
% pathData = 'C:\Users\u0150099\Documents\master_thesis\ReferenceData\ModelScaling\reference_data';
% addpath(pathData);
% 
% % Extract joint kinematics
% pathIK = fullfile(pathData,['IK_Fal_s1_mtjc4_FK_sc_FDB2_MTc5_cspx0_oy3_gait_' num2str(trialnr) '.mot']);
% % Extract ground reaction forces and moments
% pathGRF = fullfile(pathData,'GRF',['GRF_gait_' num2str(trialnr) '.mot']);
% GRF = getGRF(pathGRF);
% 
% [~,idx_IC,hs] = getIC_1FP(GRF,20,trials.(['gait_' num2str(trialnr)]).icOff);
% 
% % interpolate
% intrvl = linspace(GRF.time(idx_IC(1)),GRF.time(idx_IC(2)),100);
% GRF_l = interp1(GRF.time,GRF.val.l,intrvl);
% GRF_r = interp1(GRF.time,GRF.val.r,intrvl);
% COP_l = interp1(GRF.time,GRF.pos.l,intrvl);
% COP_r = interp1(GRF.time,GRF.pos.r,intrvl);

%%

    pathIK = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21.mot';
    load('C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_pp.mat','R');
    intrvl = R.t;
    GRF_r = R.GRFs(:,1:3);

%     load('C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\contactmodel_param_sweep\Fal_s1_k60_d20_sF8_dF8_vF5_tV20_job464.mat','R','model_info');
%     intrvl = R.time.mesh_GC;
%     R.Qs = R.kinematics.Qs;
%     R.Qdots = R.kinematics.Qdots;
%     R.colheaders.joints = R.colheaders.coordinates;
%     R.S.OsimFileName = model_info.osim_path;


%%

% figure(1)
% for i=1:3
%     subplot(2,3,i)
%     hold on
%     plot(intrvl,GRF_r(:,i))
%     xlim([intrvl(1),intrvl(end)])
% end

%%
% model_path = fullfile('C:\Users\u0150099\Documents\master_thesis\3dpredictsim\OpenSimModel\subject1','Fal_s1_mtjc4_FK_sc_FDB2_MTc5_cspx10_oy3.osim');
% 
% [out] = OpenSim_body_frames(model_path,pathIK,intrvl,R.Qs,R.Qdots,R.colheaders.joints);
% 
% %
% csoffset = zeros(size(cslocation));
% 
% % csoffset(2,2) = 0.02;
% 
% % csoffset(1,6) = 0.05;
% % csoffset(2,6) = 0.005;
% 
% 
% % csoffset(2,3:4) = 0.005;
% % 
% % csoffset(:,1) = [0.02, 0.05 ,0]';
% % csoffset(:,2) = [0.02, 0.05 ,0]';
% 
% %
% 
% for i=1:length(intrvl)
%     for j=1 %[1,3:6]
%         tmp = out.(csframe{j});
% %         grfij = f_contactForce(csradius(j),cslocation(:,j)+csoffset(:,j),tmp.pos(i,:),tmp.v_lin(i,:),...
% %             tmp.omega(i,:),tmp.R(i,:),tmp.pos(i,:));
%         [grfij,cspos,csvel] = f_contact_force(csradius(j),cslocation(:,j)+csoffset(:,j),tmp.pos(i,:),tmp.v_lin(i,:),...
%             tmp.omega(i,:),tmp.R(i,:),tmp.pos(i,:));
% 
%         grf_r_i(:,j) = full(grfij);
%         sphere_pos(i,:,j) = cspos;
%         sphere_vel(i,:,j) = csvel;
%     end
%     grf_r(i,:) = sum(grf_r_i,2);
% 
% end
% 
% 
% 
% 
% %
% 
% figure(1)
% for i=1:3
%     subplot(2,3,i)
%     hold on
%     plot(intrvl,grf_r(:,i))
% end







%%
for j=1
    [sphere_p,sphere_v] = getSphereInGroundFrame(R,csframe{j},cslocation(:,j));

    indentation_j = sphere_p(:,2)-csradius(j);
    indentation_j(indentation_j>0) = 0;

end

figure(1)
hold on
plot(-indentation_j*1e3)
xlabel('gait cycle (%)')
ylabel('compression (mm)')
title('Heel pad compression')

% max(abs(sphere_p-sphere_pos),[],'all')
% max(abs(sphere_v-sphere_vel),[],'all')




function [forceSX,pos,vel] = f_contact_force(radiusSX,spherePosSX,...
    orFramePosSX,v_linSX,omegaSX,RotSX,TrSX)

%% Contact forces
stiffnessSX         = 10e6;
dissipationSX       = 2;
normalSX            = [0,1,0];
transitionVelocitySX= 0.2;
staticFrictionSX    = 0.8;
dynamicFrictionSX   = 0.8;
viscousFrictionSX   = 0.5;

% Hunt-Crossley contact model
[forceSX,pos,vel] = HCContactModel(stiffnessSX,radiusSX,dissipationSX,...
    normalSX,transitionVelocitySX,staticFrictionSX,...
    dynamicFrictionSX,viscousFrictionSX,...
    vertcat(spherePosSX(:)),vertcat(orFramePosSX(:)),...
    vertcat(v_linSX(:)),vertcat(omegaSX(:)),RotSX,vertcat(TrSX(:)));

end