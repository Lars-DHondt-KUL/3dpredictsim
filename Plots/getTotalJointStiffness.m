clear
% close all
clc

ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

results = {
%     '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
%     '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
    '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
    '\with_better_knee\Fal_s1_mtjc4_FK_sd_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls141_FDB2_lTs120_Fpsl10_ig21'
%     '\different_speeds\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_vel27_ig1'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_vel27_ig23_igmtp'
%     '\different_speeds\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_vel27_ig23_igmtp'
    };

% LegNames = {'Rigid midfoot','Plantar fascia','Plantar intrinsic muscles'};
LegNames = {'custom scaling','isometric scaling'};

for ires = 1:length(results)
resultsfile = fullfile(ResultsRepo,[results{ires} '_pp.mat']);

load(resultsfile,'R')



S = R.S;

if contains(S.Foot.Model,'mtj')
    mtj = 1;
else
    mtj = 0;
end

nq.all = length(R.colheaders.joints);


% Load external function
import casadi.*
% The external function performs inverse dynamics through the
% OpenSim/Simbody C++ API. This external function is compiled as a dll from
% which we create a Function instance using CasADi in MATLAB. More details
% about the external function can be found in the documentation.

pathRepo = pwd;
[pathRepo0,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathRepo0);
addpath(genpath(pathRepo));
% Loading external functions.
setup.derivatives =  'AD'; % Algorithmic differentiation
pathExternalFunctions = 'C:\Users\u0150099\Documents\master_thesis\3dpredictsim\ExternalFunctions';
% cd(pathExternalFunctions)
F  = external('F',fullfile(pathExternalFunctions,['F_' S.ExternalFunc '.dll']));
load(fullfile(pathExternalFunctions,['F_' S.ExternalFunc '_IO.mat']),'IO');
% cd(pathRepo);

coord_names = cell(2,nq.all);
coord_names_tmp = fieldnames(IO.coordi);
for i=1:nq.all
    coord_names{1,i} = coord_names_tmp{i};
    coord_names{2,i} = IO.coordi.(coord_names_tmp{i});
end
IO.coord_namesi = coord_names;





% Muscle indices for later use
pathmusclemodel = fullfile(pathRepo,'MuscleModel',S.OsimFileName);
pathpolynomial = fullfile(pathRepo,'Polynomials',S.OsimFileName);
addpath(genpath(pathmusclemodel));
% Muscles from one leg and from the back
load([pathpolynomial,'/MuscleData.mat'],'MuscleData');
muscleNames = MuscleData.muscle_names;
% Total number of muscles
NMuscle = length(muscleNames(1:end-3))*2;
load([pathpolynomial,'/muscle_spanning_joint_INFO.mat'],'muscle_spanning_joint_INFO');
load([pathpolynomial,'/MuscleData.mat'],'MuscleData');
[~,mai] = MomentArmIndices(muscleNames(1:end-3),muscle_spanning_joint_INFO);
try
    load([pathpolynomial,'/ligament_spanning_joint_INFO.mat'],'ligament_spanning_joint_INFO');
    nq.PF       = size(ligament_spanning_joint_INFO,2);
catch
    nq.PF = 0;
end

nq.leg      = size(muscle_spanning_joint_INFO,2);

tension = getSpecificTensions(muscleNames(1:end-3));
tensions = [tension;tension];

% CasADi functions
% We create several CasADi functions for later use
pathCasADiFunctions = [pathRepo,'/CasADiFunctions'];
PathDefaultFunc = fullfile(pathCasADiFunctions,S.CasadiFunc_Folders);
f_lMT_vMT_dM = Function.load(fullfile(PathDefaultFunc,'f_lMT_vMT_dM'));
if nq.PF
    f_lLi_vLi_dM = Function.load(fullfile(PathDefaultFunc,'f_lLi_vLi_dM'));
end

f_FiberLength_TendonForce_tendon = Function.load(fullfile(PathDefaultFunc,'f_FiberLength_TendonForce_tendon'));
f_FiberVelocity_TendonForce_tendon = Function.load(fullfile(PathDefaultFunc,'f_FiberVelocity_TendonForce_tendon'));
f_forceEquilibrium_FtildeState_all_tendon = Function.load(fullfile(PathDefaultFunc,'f_forceEquilibrium_FtildeState_all_tendon'));

f_ArmActivationDynamics = Function.load(fullfile(PathDefaultFunc,'f_ArmActivationDynamics'));
f_MtpActivationDynamics = Function.load(fullfile(PathDefaultFunc,'f_MtpActivationDynamics'));

f_AllPassiveTorques = Function.load(fullfile(PathDefaultFunc,'f_AllPassiveTorques'));
if mtj
    f_PF_stiffness = Function.load(fullfile(PathDefaultFunc,'f_PF_stiffness'));
    f_passiveMoment_mtj = Function.load(fullfile(PathDefaultFunc,'f_passiveMoment_mtj'));
end

f_getMetabolicEnergySmooth2004all = Function.load(fullfile(PathDefaultFunc,'f_getMetabolicEnergySmooth2004all'));

f_J2    = Function.load(fullfile(PathDefaultFunc,'f_J2'));
f_J8    = Function.load(fullfile(PathDefaultFunc,'f_J8'));
f_J23   = Function.load(fullfile(PathDefaultFunc,'f_J23'));
f_J25   = Function.load(fullfile(PathDefaultFunc,'f_J25'));
f_J92   = Function.load(fullfile(PathDefaultFunc,'f_J92'));
f_J92exp = Function.load(fullfile(PathDefaultFunc,'f_J92exp'));
f_Jnn2  = Function.load(fullfile(PathDefaultFunc,'f_Jnn2'));
f_T4 = Function.load(fullfile(PathDefaultFunc,'f_T4'));
f_T6 = Function.load(fullfile(PathDefaultFunc,'f_T6'));
f_T9 = Function.load(fullfile(PathDefaultFunc,'f_T9'));
f_T12 = Function.load(fullfile(PathDefaultFunc,'f_T12'));
f_T13 = Function.load(fullfile(PathDefaultFunc,'f_T13'));
f_T27 = Function.load(fullfile(PathDefaultFunc,'f_T27'));
if S.Foot.FDB
    f_T4 = Function.load(fullfile(PathDefaultFunc,'f_T5'));
    f_T9 = Function.load(fullfile(PathDefaultFunc,'f_T10'));
end



if mtj
    jointi = getJointi_mtj();
else
    jointi = getJointi();
end

% get help indexes for left and right leg and for symmetry constraint
[IndexLeft,IndexRight,QsInvA,QsInvB,QdotsInvA,...
    QdotsInvB,orderQsOpp] = GetIndexHelper_IO(jointi,IO,MuscleData.dof_names);


% Field names for moment arms:
MAj_fieldnames = {'hip_flex','hip_add','hip_rot','knee','ankle','subt'};
if S.Foot.mtj_muscles && mtj
    MAj_fieldnames{end+1} = 'mtj';
end
if S.Foot.mtp_muscles
    MAj_fieldnames{end+1} = 'mtp';
end
MAj_dof_idx = zeros(length(MAj_fieldnames),1);
for i=1:nq.leg-3
        coord_i = MuscleData.dof_names{i};
        for j=1:length(MAj_fieldnames)
            MAj_fieldname_j = MAj_fieldnames{j};
            if contains(coord_i,MAj_fieldname_j)
                MAj_dof_idx(i) = j;
            end
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unscale variables
Qskj_nsc = MX.sym('Qs',nq.all,1);
Qdotskj_nsc = MX.sym('Qdots',nq.all,1);
FTtildekj_nsc = MX.sym('FTtilde',NMuscle,1);
dFTtildej_nsc = MX.sym('dFTtilde',NMuscle,1);
akj = MX.sym('ak',NMuscle,1);

FTtilde_sol = MX.sym('FTtilde_sol',NMuscle,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get muscle-tendon lengths, velocities, and moment arms
% Left leg
qinj_l          = Qskj_nsc(IndexLeft, 1);
qdotinj_l       = Qdotskj_nsc(IndexLeft, 1);
[lMTj_l,vMTj_l,MAj_l] =  f_lMT_vMT_dM(qinj_l,qdotinj_l);
for i=1:length(MAj_dof_idx)
    fieldname_i = MAj_fieldnames{MAj_dof_idx(i)};
    MAj.(fieldname_i).l   =  MAj_l(mai(i).mus.l',i);
end
% For the back muscles, we want left and right together: left
% first, right second. In MuscleInfo, we first have the right
% muscles (44:46) and then the left muscles (47:49). Since the back
% muscles only depend on back dofs, we do not care if we extract
% them "from the left or right leg" so here we just picked left.
MAj.trunk_ext    =  MAj_l([end-2:end,mai(nq.leg-2).mus.l]',nq.leg-2);
MAj.trunk_ben    =  MAj_l([end-2:end,mai(nq.leg-1).mus.l]',nq.leg-1);
MAj.trunk_rot    =  MAj_l([end-2:end,mai(nq.leg).mus.l]',nq.leg);
% Right leg
qinj_r      = Qskj_nsc(IndexRight,1);
qdotinj_r   = Qdotskj_nsc(IndexRight,1);
[lMTj_r,vMTj_r,MAj_r] = f_lMT_vMT_dM(qinj_r,qdotinj_r);
% Here we take the indices from left since the vector is 1:49
for i=1:length(MAj_dof_idx)
    fieldname_i = MAj_fieldnames{MAj_dof_idx(i)};
    MAj.(fieldname_i).r   =  MAj_r(mai(i).mus.l',i);
end
% Both legs
% In MuscleInfo, we first have the right back muscles (44:46) and
% then the left back muscles (47:49). Here we re-organize so that
% we have first the left muscles and then the right muscles.
lMTj_lr = [lMTj_l([1:end-6,end-2:end],1);lMTj_r(1:end-3,1)];
vMTj_lr = [vMTj_l([1:end-6,end-2:end],1);vMTj_r(1:end-3,1)];
% Get plantar fascia length, velocity, and moment arm
if mtj && (~strcmp(S.Foot.PF_stiffness,'none') || S.Foot.PIM)
    % Left leg
    qinPFj_l          = Qskj_nsc([jointi.mtj.l,jointi.mtp.l], 1);
    qdotinPFj_l       = Qdotskj_nsc([jointi.mtj.l,jointi.mtp.l], 1);
    [l_PFj_l,v_PFj_l,MA_PFj_l] =  f_lLi_vLi_dM(qinPFj_l,qdotinPFj_l);
    MA_PFj.mtj.l = MA_PFj_l(1);
    MA_PFj.mtp.l = MA_PFj_l(2);
    % Right leg
    qinPFj_r          = Qskj_nsc([jointi.mtj.r,jointi.mtp.r], 1);
    qdotinPFj_r       = Qdotskj_nsc([jointi.mtj.r,jointi.mtp.r], 1);
    [l_PFj_r,v_PFj_r,MA_PFj_r] =  f_lLi_vLi_dM(qinPFj_r,qdotinPFj_r);
    MA_PFj.mtj.r = MA_PFj_r(1);
    MA_PFj.mtp.r = MA_PFj_r(2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get muscle-tendon forces and derive Hill-equilibrium
[Hilldiffj,~,~,~,~,~,~] = ...
    f_forceEquilibrium_FtildeState_all_tendon(akj(:,1),...
    FTtildekj_nsc(:,1),dFTtildej_nsc(:,1),...
    lMTj_lr,vMTj_lr,tensions);

%%

f_Hilldiff = Function('f_Hilldiff',{FTtildekj_nsc,akj,dFTtildej_nsc,Qskj_nsc,Qdotskj_nsc},{Hilldiffj});

f_FTtilde = rootfinder('f_FTtilde','newton',f_Hilldiff);

FTtilde = f_FTtilde(FTtilde_sol,akj,dFTtildej_nsc,Qskj_nsc,Qdotskj_nsc);

[~,FTj,~,~,~,~,~] = ...
    f_forceEquilibrium_FtildeState_all_tendon(akj(:,1),...
    FTtilde(:,1),dFTtildej_nsc(:,1),...
    lMTj_lr,vMTj_lr,tensions);

%%
% Get plantar fascia and plantar intrinsic muscles force
if mtj
    % lumped ligament torque
    T_passj.mtj.l = f_passiveMoment_mtj(Qskj_nsc(jointi.mtj.l),Qdotskj_nsc(jointi.mtj.l));
    T_passj.mtj.r = f_passiveMoment_mtj(Qskj_nsc(jointi.mtj.r),Qdotskj_nsc(jointi.mtj.r));

    if strcmp(S.Foot.PF_stiffness,'none')

    else
        F_PFj_l = f_PF_stiffness(l_PFj_l)*S.Foot.PF_sf;
        F_PFj_r = f_PF_stiffness(l_PFj_r)*S.Foot.PF_sf;

        % only PF, no PIM
        F_PF_PIMj.l = F_PFj_l;
        F_PF_PIMj.r = F_PFj_r;

    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get passive joint torques
Tau_passj_all = f_AllPassiveTorques(Qskj_nsc(:,1),Qdotskj_nsc(:,1));
Tau_passj.hip.flex.l = Tau_passj_all(1);
Tau_passj.hip.flex.r = Tau_passj_all(2);
Tau_passj.hip.add.l = Tau_passj_all(3);
Tau_passj.hip.add.r = Tau_passj_all(4);
Tau_passj.hip.rot.l = Tau_passj_all(5);
Tau_passj.hip.rot.r = Tau_passj_all(6);
Tau_passj.knee.l = Tau_passj_all(7);
Tau_passj.knee.r = Tau_passj_all(8);
Tau_passj.ankle.l = Tau_passj_all(9);
Tau_passj.ankle.r = Tau_passj_all(10);
Tau_passj.subt.l = Tau_passj_all(11);
Tau_passj.subt.r = Tau_passj_all(12);
if mtj
    Tau_passj.mtj.l = Tau_passj_all(13);
    Tau_passj.mtj.r = Tau_passj_all(14);
    Tau_passj.mtp.l = Tau_passj_all(15);
    Tau_passj.mtp.r = Tau_passj_all(16);
    Tau_passj.trunk.ext = Tau_passj_all(17);
    Tau_passj.trunk.ben = Tau_passj_all(18);
    Tau_passj.trunk.rot = Tau_passj_all(19);
    Tau_passj.arm = Tau_passj_all(20:27);
else
    Tau_passj.mtp.l = Tau_passj_all(13);
    Tau_passj.mtp.r = Tau_passj_all(14);
    Tau_passj.trunk.ext = Tau_passj_all(15);
    Tau_passj.trunk.ben = Tau_passj_all(16);
    Tau_passj.trunk.rot = Tau_passj_all(17);
    Tau_passj.arm = Tau_passj_all(18:25);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tj = MX(nq.all,1);

% Muscle-driven joint torques for the lower limbs and the trunk
mai_i = 1; % helper index
% Hip flexion, left
Ft_hip_flex_l   = FTj(mai(mai_i).mus.l',1);
T_hip_flex_l    = f_T27(MAj.hip_flex.l,Ft_hip_flex_l);
Tj(jointi.hip_flex.l,1) = (T_hip_flex_l + Tau_passj.hip.flex.l);
% Hip flexion, right
Ft_hip_flex_r   = FTj(mai(mai_i).mus.r',1);
T_hip_flex_r    = f_T27(MAj.hip_flex.r,Ft_hip_flex_r);
Tj(jointi.hip_flex.r,1) = (T_hip_flex_r + Tau_passj.hip.flex.r);
mai_i = mai_i+1;
% Hip adduction, left
Ft_hip_add_l    = FTj(mai(mai_i).mus.l',1);
T_hip_add_l     = f_T27(MAj.hip_add.l,Ft_hip_add_l);
Tj(jointi.hip_add.l,1) = (T_hip_add_l + Tau_passj.hip.add.l);
% Hip adduction, right
Ft_hip_add_r    = FTj(mai(mai_i).mus.r',1);
T_hip_add_r     = f_T27(MAj.hip_add.r,Ft_hip_add_r);
Tj(jointi.hip_add.r,1) = (T_hip_add_r + Tau_passj.hip.add.r);
mai_i = mai_i+1;
% Hip rotation, left
Ft_hip_rot_l    = FTj(mai(mai_i).mus.l',1);
T_hip_rot_l     = f_T27(MAj.hip_rot.l,Ft_hip_rot_l);
Tj(jointi.hip_rot.l,1) = (T_hip_rot_l + Tau_passj.hip.rot.l);
% Hip rotation, right
Ft_hip_rot_r    = FTj(mai(mai_i).mus.r',1);
T_hip_rot_r     = f_T27(MAj.hip_rot.r,Ft_hip_rot_r);
Tj(jointi.hip_rot.r,1) = (T_hip_rot_r + Tau_passj.hip.rot.r);
mai_i = mai_i+1;
% Knee, left
Ft_knee_l       = FTj(mai(mai_i).mus.l',1);
T_knee_l        = f_T13(MAj.knee.l,Ft_knee_l);
Tj(jointi.knee.l,1) = (T_knee_l + Tau_passj.knee.l);
% Knee, right
Ft_knee_r       = FTj(mai(mai_i).mus.r',1);
T_knee_r        = f_T13(MAj.knee.r,Ft_knee_r);
Tj(jointi.knee.r,1) = (T_knee_r + Tau_passj.knee.r);
mai_i = mai_i+1;
% Ankle, left
Ft_ankle_l      = FTj(mai(mai_i).mus.l',1);
T_ankle_l       = f_T12(MAj.ankle.l,Ft_ankle_l);
Tj(jointi.ankle.l,1) = (T_ankle_l + Tau_passj.ankle.l);
% Ankle, right
Ft_ankle_r      = FTj(mai(mai_i).mus.r',1);
T_ankle_r       = f_T12(MAj.ankle.r,Ft_ankle_r);
Tj(jointi.ankle.r,1) = (T_ankle_r + Tau_passj.ankle.r);
mai_i = mai_i+1;
% Subtalar, left
Ft_subt_l       = FTj(mai(mai_i).mus.l',1);
T_subt_l        = f_T12(MAj.subt.l,Ft_subt_l);
Tj(jointi.subt.l,1) = (T_subt_l +  Tau_passj.subt.l);
% Subtalar, right
Ft_subt_r       = FTj(mai(mai_i).mus.r',1);
T_subt_r        = f_T12(MAj.subt.r,Ft_subt_r);
Tj(jointi.subt.r,1) = (T_subt_r + Tau_passj.subt.r );
mai_i = mai_i+1;
% Midtarsal
if mtj
    % mtj left
    T_mtj_tmp_l = Tau_passj.mtj.l + T_passj.mtj.l;
    if S.Foot.mtj_muscles 
        Ft_mtj_l        = FTj(mai(mai_i).mus.l',1);
        T_mtj_l         = f_T9(MAj.mtj.l,Ft_mtj_l);
        T_mtj_tmp_l     = T_mtj_tmp_l + T_mtj_l;
    end
    if ~strcmp(S.Foot.PF_stiffness,'none') || S.Foot.PIM
        T_mtjPF_l       = MA_PFj.mtj.l*F_PF_PIMj.l;
        T_mtj_tmp_l     = T_mtj_tmp_l + T_mtjPF_l;
    end
    Tj(jointi.mtj.l,1) = (T_mtj_tmp_l);
    % mtj right
    T_mtj_tmp_r = Tau_passj.mtj.r + T_passj.mtj.r;
    if S.Foot.mtj_muscles 
        Ft_mtj_r        = FTj(mai(mai_i).mus.r',1);
        T_mtj_r         = f_T9(MAj.mtj.r,Ft_mtj_r);
        T_mtj_tmp_r     = T_mtj_tmp_r + T_mtj_r;
    end
    if ~strcmp(S.Foot.PF_stiffness,'none') || S.Foot.PIM
        T_mtjPF_r       = MA_PFj.mtj.r*F_PF_PIMj.r;
        T_mtj_tmp_r     = T_mtj_tmp_r + T_mtjPF_r;
    end
    Tj(jointi.mtj.r,1) = (T_mtj_tmp_r);
    mai_i = mai_i+1;
end
% Metatarsophalangeal
% mtp left
T_mtp_tmp_l = Tau_passj.mtp.l;
if S.Foot.mtp_muscles 
    Ft_mtp_l        = FTj(mai(mai_i).mus.l',1);
    T_mtp_l         = f_T4(MAj.mtp.l,Ft_mtp_l);
    T_mtp_tmp_l     = T_mtp_tmp_l + T_mtp_l;
end
if mtj && (~strcmp(S.Foot.PF_stiffness,'none') || S.Foot.PIM)
    T_mtpPF_l       = MA_PFj.mtp.l*F_PF_PIMj.l;
    T_mtp_tmp_l     = T_mtp_tmp_l + T_mtpPF_l;
end
if S.Foot.mtp_actuator
    T_mtp_tmp_l     = T_mtp_tmp_l + a_mtpkj(1,1)*scaling.MtpTau;
end
Tj(jointi.mtp.l,1) = (T_mtp_tmp_l);
% mtp right
T_mtp_tmp_r = Tau_passj.mtp.r;
if S.Foot.mtp_muscles 
    Ft_mtp_r        = FTj(mai(mai_i).mus.r',1);
    T_mtp_r         = f_T4(MAj.mtp.r,Ft_mtp_r);
    T_mtp_tmp_r     = T_mtp_tmp_r + T_mtp_r;
end
if mtj && (~strcmp(S.Foot.PF_stiffness,'none') || S.Foot.PIM)
        T_mtpPF_r       = MA_PFj.mtp.r*F_PF_PIMj.r;
        T_mtp_tmp_r     = T_mtp_tmp_r + T_mtpPF_r;
end
Tj(jointi.mtp.r,1) = (T_mtp_tmp_r);
mai_i = mai_i+1;

% Lumbar extension
Ft_trunk_ext    = FTj([mai(mai_i).mus.l,mai(mai_i).mus.r]',1);
T_trunk_ext     = f_T6(MAj.trunk_ext,Ft_trunk_ext);
Tj(jointi.trunk.ext,1) = (T_trunk_ext + Tau_passj.trunk.ext);
mai_i = mai_i+1;
% Lumbar bending
Ft_trunk_ben    = FTj([mai(mai_i).mus.l,mai(mai_i).mus.r]',1);
T_trunk_ben     = f_T6(MAj.trunk_ben,Ft_trunk_ben);
Tj(jointi.trunk.ben,1) = (T_trunk_ben + Tau_passj.trunk.ben);
mai_i = mai_i+1;
% Lumbar rotation
Ft_trunk_rot    = FTj([mai(mai_i).mus.l,mai(mai_i).mus.r]',1);
T_trunk_rot     = f_T6(MAj.trunk_rot,Ft_trunk_rot);
Tj(jointi.trunk.rot,1) = (T_trunk_rot + Tau_passj.trunk.rot);



%%
f_jointStiffness = Function('f_jointStiffness',{FTtilde_sol,akj,dFTtildej_nsc,Qskj_nsc,Qdotskj_nsc},{Tj,jacobian(-Tj,Qskj_nsc)});
f_jointDamping = Function('f_jointDamping',{FTtilde_sol,akj,dFTtildej_nsc,Qskj_nsc,Qdotskj_nsc},{Tj,jacobian(-Tj,Qdotskj_nsc)});

if mtj
    f_debug = Function('f_debug',{FTtilde_sol,akj,dFTtildej_nsc,Qskj_nsc,Qdotskj_nsc},{Tau_passj.mtj.r, T_passj.mtj.r, T_mtj_r, T_mtjPF_r,FTj});
    f_mtj_muscles_stiffness = Function('f_mtj_muscles_stiffness',{FTtilde_sol,akj,dFTtildej_nsc,Qskj_nsc,Qdotskj_nsc},{jacobian(-T_mtj_r,Qskj_nsc)});
end


%%

N = size(R.Qs,1);

Ts = zeros(N,nq.all);
jac_Ts = zeros(N,nq.all,nq.all);
jac_Ts2 = zeros(N,nq.all,nq.all);
clearvars FT
for i=1:N
    [Tsi,jac_Tsi] = f_jointStiffness(R.FTtilde(i,:),R.a(i,:),R.dFTtilde(i,:),R.Qs(i,:)*pi/180,R.Qdots(i,:)*pi/180);
    [~,jac_Ts2i] = f_jointDamping(R.FTtilde(i,:),R.a(i,:),R.dFTtilde(i,:),R.Qs(i,:)*pi/180,R.Qdots(i,:)*pi/180);


    Ts(i,:) = full(Tsi);
    jac_Ts(i,:,:) = full(jac_Tsi);
    jac_Ts2(i,:,:) = full(jac_Ts2i);

    if mtj
        [Tau_passi,T_passi,T_musi,T_PFi,FTi] = f_debug(R.FTtilde(i,:),R.a(i,:),R.dFTtilde(i,:),R.Qs(i,:)*pi/180,R.Qdots(i,:)*pi/180);
        Tau_pass(i) = full(Tau_passi);
        T_pass(i) = full(T_passi);
        T_mus(i) = full(T_musi);
        T_PF(i) = full(T_PFi);
        FT(i,:) = full(FTi);
        jac_T_mus(i,:) = full(f_mtj_muscles_stiffness(R.FTtilde(i,:),R.a(i,:),R.dFTtilde(i,:),R.Qs(i,:)*pi/180,R.Qdots(i,:)*pi/180));
    end
end



%%
% DT = R.Tid-Ts;
% errs_rel = max(abs(DT)-1e-5*abs(R.Tid),[],1);
% errs_rel2 = max(abs(DT)./abs(R.Tid),[],1);
% errs_abs = max(abs(DT),[],1);
% 
% if mtj
%     T_mtj = [Tau_pass',T_pass',T_PF',T_mus'];
%     T_mtj(:,5) = Tau_pass'+T_pass'+T_PF'+T_mus';
% 
%     diff_FT = R.FT-FT;
%     diff_FT2 = diff_FT;
%     diff_FT2(abs(diff_FT2)<1e-5) = 0;
%     tmp = DT(:,strcmp(R.colheaders.joints,'mtj_angle_r'));
%     tmp_M_PF = R.windlass.MA_PF.mtj.*R.windlass.F_PF;
% end
% 
% R.colheaders.joints{(errs_abs)>1e-4}

%%
imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
iankle = strcmp(R.colheaders.joints,'ankle_angle_r');
imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));
ihip = find(strcmp(R.colheaders.joints,'hip_flexion_r'));
iknee = find(strcmp(R.colheaders.joints,'knee_angle_r'));

if ires==1
    f1=figure;
    tiledlayout('flow')
end

figure(f1)

nexttile(1)
hold on
p1=plot(squeeze(jac_Ts(:,iankle,iankle)));
ylabel({'$\frac{\partial M}{\partial q}$ $(\frac{Nm}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
xlabel('% GC')
title('ankle')

nexttile(2)
hold on
if ~isempty(imtj)
    plot(squeeze(jac_Ts(:,imtj,imtj)),'Color',p1.Color)
    ylabel({'$\frac{\partial M}{\partial q}$ $(\frac{Nm}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
    xlabel('% GC')
    title('midtarsal')
    plot(squeeze(jac_T_mus(:,imtj)),'--','Color',p1.Color)
end

nexttile(3)
hold on
plot(squeeze(jac_Ts(:,imtp,imtp)))
ylabel({'$\frac{\partial M}{\partial q}$ $(\frac{Nm}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
xlabel('% GC')
title('mtp')

nexttile(4)
hold on
plot(squeeze(jac_Ts(:,ihip,ihip)))
ylabel({'$\frac{\partial M}{\partial q}$ $(\frac{Nm}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
xlabel('% GC')
title('hip')

nexttile(5)
hold on
plot(squeeze(jac_Ts(:,iknee,iknee)),'DisplayName',LegNames{ires})
ylabel({'$\frac{\partial M}{\partial q}$ $(\frac{Nm}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
xlabel('% GC')
title('knee')

% yline(1/2.5*62*180/pi)

%

if ires==1
    f2=figure;
    tiledlayout('flow')
end

figure(f2)

nexttile(1)
hold on
p1=plot(squeeze(jac_Ts2(:,iankle,iankle)));
ylabel({'$\frac{\partial M}{\partial \dot{q}}$ $(\frac{Nms}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
xlabel('% GC')
title('ankle')

nexttile(2)
hold on
if ~isempty(imtj)
    plot(squeeze(jac_Ts2(:,imtj,imtj)),'Color',p1.Color)
    ylabel({'$\frac{\partial M}{\partial \dot{q}}$ $(\frac{Nms}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
    xlabel('% GC')
    title('midtarsal')
end

nexttile(3)
hold on
plot(squeeze(jac_Ts2(:,imtp,imtp)))
ylabel({'$\frac{\partial M}{\partial \dot{q}}$ $(\frac{Nms}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
xlabel('% GC')
title('mtp')

nexttile(4)
hold on
plot(squeeze(jac_Ts2(:,ihip,ihip)))
ylabel({'$\frac{\partial M}{\partial \dot{q}}$ $(\frac{Nms}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
xlabel('% GC')
title('hip')

nexttile(5)
hold on
plot(squeeze(jac_Ts2(:,iknee,iknee)),'DisplayName',LegNames{ires})
ylabel({'$\frac{\partial M}{\partial \dot{q}}$ $(\frac{Nms}{rad})$'},Interpreter='latex',FontSize=16,Rotation=0,HorizontalAlignment='right')
xlabel('% GC')
title('knee')

end
figure(f1)
nexttile(5)
lg=legend;
lg.Layout.Tile = 6;

figure(f2)
nexttile(5)
lg=legend;
lg.Layout.Tile = 6;




