function [R] = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR)



pathmain        = pwd;
[pathRepo,~,~]  = fileparts(pathmain);
addpath(genpath(pathRepo));

import casadi.*

%% Settings


% if ~isfield(S,'OsimFileName')
%     OsimFileName = [S.subject '_' S.Foot.Model];
%     if strcmp(S.Foot.Scaling,'default')
%         OsimFileName = [OsimFileName '_sd'];
%     elseif strcmp(S.Foot.Scaling,'custom')
%         OsimFileName = [OsimFileName '_sc'];
%     elseif strcmp(S.Foot.Scaling,'personalised')
%         OsimFileName = [OsimFileName '_sp'];
%     end
%     S.OsimFileName = OsimFileName;
% end

S.Foot.contactGeometryVersion = 0;
S.Foot.kMTP = 1;
S.Foot.dMTP = 0.1;
S.Foot.mtp_tau_pass = 1;
S.Foot.contactSphereOffset45Z = 0;
S.Foot.contactSphereOffset1X = 0;
S.tib_ant_Rajagopal2015 = 0;
S.useMtpPinPoly = 0;
S.useMtpPinExtF = 0;
S.fixed_knee = 0;

S = GetDefaultSettings(S);

n_mtp = length(Qs_mtp);
n_tib = length(Fs_tib);


%% Build savename

if S.Foot.MT_li_nonl
    mtj_stiffness = S.Foot.mtj_stiffness;
else
    mtj_stiffness = ['k' num2str(S.kMT_li)];
end
    

legname = ['PF: ' S.Foot.PF_stiffness];
if ~strcmp(S.Foot.PF_stiffness,'none')
    legname = [legname ', l_s = ' num2str(S.Foot.PF_slack_length*1000)];
end
legname = [legname '; mtj: ' mtj_stiffness];
  
%%
S2 = S;
S2.Foot.PF_stiffness = 'Natali2010';
S2.Foot.PF_sf = 1;
% S2.Foot.PF_slack_length = 0.146;
S2.Foot.mtj_stiffness = 'MG_exp5_table';
S2.Foot.mtj_sf = 1; 
[S0] = getFileNames(S2);
S2.fixed_knee = 1;
S2.Foot.contactGeometryVersion = 9;
S2.Foot.contactSphereOffset1X = 0.01;
S2.Foot.contactSphereOffsetY = 0;
[S2] = getFileNames(S2);
[~, casfuncfol] = getSavename(S2);

pathCasADiFunctions = [pathRepo,'/CasADiFunctions'];
PathDefaultFunc = fullfile(pathCasADiFunctions,casfuncfol);
PolyFolder = fullfile(pathRepo,'Polynomials',S2.OsimFileName);
ext_name = ['Foot_' S0.ExternalFunc];
pathMusc = fullfile(pathRepo,'MuscleModel',S2.OsimFileName);
% if strcmp(S.Foot.Scaling,'custom')
%     PathDefaultFunc = fullfile(pathCasADiFunctions,...
%         'Fal_s1_mtj_sc_cspx10_oy_MTPm_k1_d05_MTJm_nl_Gefen2002_PF_Gefen2002_ls150');
%     PolyFolder = [pathRepo '\Polynomials\Fal_s1_mtj_sc'];
%     ext_name = 'Foot_Fal_s1_mtj_sc_cspx10_oy';
%     pathMusc = fullfile(pathRepo,'MuscleModel','Fal_s1_mtj_sc');
% 
% elseif strcmp(S.Foot.Scaling,'default')
%     PathDefaultFunc = fullfile(pathCasADiFunctions,...
%         'Fal_s1_mtj_sd_cspx10_oy_MTPm_k1_d05_MTJm_nl_Gefen2002_PF_Gefen2002_ls150');
%     PolyFolder = [pathRepo '\Polynomials\Fal_s1_mtj_sd'];
%     ext_name = 'Foot_Fal_s1_mtj_sd_cspx10_oy';
%     pathMusc = fullfile(pathRepo,'MuscleModel','Fal_s1_mtj_sd');
% end

%% Load external functions
% The external function performs inverse dynamics through the
% OpenSim/Simbody C++ API. This external function is compiled as a dll from
% which we create a Function instance using CasADi in MATLAB. More details
% about the external function can be found in the documentation.

% Loading external functions.
pathExternalFunctions = [pathRepo,'/ExternalFunctions'];
cd(pathExternalFunctions)

F  = external('F',['F_' ext_name '.dll']);
load(['F_' ext_name '_IO.mat'],'IO');
cd(pathmain);

%% CasADi functions
% We create several CasADi functions for later use

f_lMT_vMT_dM = Function.load(fullfile(PathDefaultFunc,'f_lMT_vMT_dM'));
f_lLi_vLi_dM = Function.load(fullfile(PathDefaultFunc,'f_lLi_vLi_dM'));
f_forceEquilibrium_FtildeState_all_tendon = Function.load(fullfile(PathDefaultFunc,...
    'f_forceEquilibrium_FtildeState_all_tendon'));
f_AllPassiveTorques = Function.load(fullfile(PathDefaultFunc,'f_AllPassiveTorques'));

f_T4 = Function.load(fullfile(PathDefaultFunc,'f_T4'));
f_T9 = Function.load(fullfile(PathDefaultFunc,'f_T9'));
f_T12 = Function.load(fullfile(PathDefaultFunc,'f_T12'));
if S.Foot.FDB
    f_T4 = Function.load(fullfile(PathDefaultFunc,'f_T5'));
    f_T9 = Function.load(fullfile(PathDefaultFunc,'f_T10'));
end

if strcmp(S.Foot.mtj_stiffness,'MG_table')
    f_getMtjLigamentMoment = Function.load((fullfile(PolyFolder,'f_getMtjLigamentMoment')));
elseif contains(S.Foot.mtj_stiffness,'MG_exp') && contains(S.Foot.mtj_stiffness,'_table')
    tmp = replace(S.Foot.mtj_stiffness,'MG_','');
    tmp = replace(tmp,'_table','');
    f_getMtjLigamentMoment = Function.load((fullfile(PolyFolder,['f_getMtjLigamentMoment_' tmp])));

elseif strcmp(S.Foot.mtj_stiffness,'MG_exp_table')
    f_getMtjLigamentMoment = Function.load((fullfile(PolyFolder,'f_getMtjLigamentMoment_exp')));
elseif strcmp(S.Foot.mtj_stiffness,'MG_exp_d_table')
    f_getMtjLigamentMoment = Function.load((fullfile(PolyFolder,'f_getMtjLigamentMoment_exp_d')));
elseif strcmp(S.Foot.mtj_stiffness,'MG_exp_e_table')
    f_getMtjLigamentMoment = Function.load((fullfile(PolyFolder,'f_getMtjLigamentMoment_exp_e')));
elseif strcmp(S.Foot.mtj_stiffness,'MG_exp_f_table')
    f_getMtjLigamentMoment = Function.load((fullfile(PolyFolder,'f_getMtjLigamentMoment_exp_f')));
elseif strcmp(S.Foot.mtj_stiffness,'MG_exp5_table')
    f_getMtjLigamentMoment = Function.load((fullfile(PolyFolder,'f_getMtjLigamentMoment_exp5')));
else
    error(S.Foot.mtj_stiffness)
end

%% Define specific casadi functions
f_PF_stiffness = f_getPlantarFasciaStiffnessModelCasADiFunction(S.Foot.PF_stiffness,'ls',S.Foot.PF_slack_length);

qin1     = MX.sym('qin_pass1',1);

% M_mtj = getMidtarsalJointPassiveMoment(qin1,qdotin1,S);
M_mtj_MX = f_getMtjLigamentMoment(qin1)*S.Foot.mtj_sf;

f_passiveMoment_mtj = Function('f_passiveMoment_mtj',{qin1},{M_mtj_MX},{'qin1'},{'M_mtj'});

K_pass = [-50 15 60 -30]';
theta_pass = [-0.4 0.5]';

qin1     = SX.sym('qin_pass1',1);

Tau_pass_1 = K_pass(1,1)*exp(K_pass(2,1)*(qin1-theta_pass(2,1)));
Tau_pass_2 = K_pass(3,1)*exp(K_pass(4,1)*(qin1-theta_pass(1,1)));
Tau_pass_SX = Tau_pass_1 + Tau_pass_2;
f_passiveTorque_mtj = Function('f_passiveTorque_mtj',{qin1},{Tau_pass_SX},{'qin1'},{'Tau_pass_mtj'});

% if S.Foot.FDB
%     load([pathMusc,'/FDBparameters.mat'],'FDBparameters');
%     % Parameters of force-length-velocity curves
%     load('Fvparam.mat','Fvparam')
%     load('Fpparam.mat','Fpparam')
%     load('Faparam.mat','Faparam')
%     % Function for Hill-equilibrium
%     FTtilde     = SX.sym('FTtilde',1); % Normalized tendon forces
%     a           = SX.sym('a',1); % Muscle activations
%     dFTtilde    = SX.sym('dFTtilde',1); % Time derivative tendon forces
%     lMT         = SX.sym('lMT',1); % Muscle-tendon lengths
%     vMT         = SX.sym('vMT',1); % Muscle-tendon velocities
%     tension_SX  = SX.sym('tension',1); % Tensions
%     
%     [Hilldiff_SX,FT_SX,Fce_SX,Fpass_SX,Fiso_SX,vMmax_SX,massM_SX] = ...
%         ForceEquilibrium_FtildeState_all_tendon(a,FTtilde,...
%         dFTtilde,lMT,vMT,FDBparameters(:,1),Fvparam,Fpparam,...
%         Faparam,tension_SX,35,0,0);
%     
%     f_forceEquilibrium_FtildeState_all_tendon_FDB = ...
%         Function('f_forceEquilibrium_FtildeState_all_tendon',{a,FTtilde,...
%         dFTtilde,lMT,vMT,tension_SX},{Hilldiff_SX,FT_SX,Fce_SX,Fpass_SX,Fiso_SX,vMmax_SX,massM_SX},...
%         {'a','FTtilde','dFTtilde','lMT','vMT','tension_SX'},...
%         {'Hilldiff','FT','Fce','Fpass','Fiso','vMmax','massM'});
% 
% 
% end

%% Indices external function
% External function: F
% Joint torques.
residualsi = 1:length(fieldnames(IO.coordi)); % all
nq.leg = 11;
nq.all = length(residualsi);

jointfi.tibia.rx = double(IO.coordi.tibia_list);
jointfi.tibia.ry = double(IO.coordi.tibia_rotation);
jointfi.tibia.rz = double(IO.coordi.tibia_tilt);
jointfi.tibia.tx = double(IO.coordi.tibia_tx);
jointfi.tibia.ty = double(IO.coordi.tibia_ty);
jointfi.tibia.tz = double(IO.coordi.tibia_tz);
jointfi.ankle.r = double(IO.coordi.ankle_angle_r);
jointfi.subt.r = double(IO.coordi.subtalar_angle_r);
jointfi.mtj.r = double(IO.coordi.mtj_angle_r);
jointfi.mtp.r = double(IO.coordi.mtp_angle_r);

jointfi.calcn_GRF = double([IO.GRFs.contact_sphere_1;IO.GRFs.contact_sphere_2]);
jointfi.forefoot_GRF = double([IO.GRFs.contact_sphere_3;IO.GRFs.contact_sphere_4]);
jointfi.talus_or = double(IO.origin.talus_r);
jointfi.calcn_or = double(IO.origin.calcn_r);
jointfi.midfoot_or = double(IO.origin.midfoot_r);
jointfi.forefoot_or = double(IO.origin.forefoot_r);
jointfi.toes_or = double(IO.origin.toes_r);



%% Muscle information
% Muscles from one leg and from the back
% muscleNames = {'glut_med1_r','glut_med2_r','glut_med3_r',...
%     'glut_min1_r','glut_min2_r','glut_min3_r','semimem_r',...
%     'semiten_r','bifemlh_r','bifemsh_r','sar_r','add_long_r',...
%     'add_brev_r','add_mag1_r','add_mag2_r','add_mag3_r','tfl_r',...
%     'pect_r','grac_r','glut_max1_r','glut_max2_r','glut_max3_r',......
%     'iliacus_r','psoas_r','quad_fem_r','gem_r','peri_r',...
%     'rect_fem_r','vas_med_r','vas_int_r','vas_lat_r','med_gas_r',...
%     'lat_gas_r','soleus_r','tib_post_r','flex_dig_r','flex_hal_r',...
%     'tib_ant_r','per_brev_r','per_long_r','per_tert_r','ext_dig_r',...
%     'ext_hal_r','ercspn_r','intobl_r','extobl_r','ercspn_l',...
%     'intobl_l','extobl_l'};
% Muscle indices for later use
pathmusclemodel = fullfile(pathRepo,'MuscleModel',S2.OsimFileName);
addpath(genpath(pathmusclemodel));
% Total number of muscles

pathpolynomial = fullfile(pathRepo,'Polynomials',S2.OsimFileName);
load([pathpolynomial,'/muscle_spanning_joint_INFO.mat'],'muscle_spanning_joint_INFO');
load([pathpolynomial,'/MuscleData.mat'],'MuscleData');
muscleNames = MuscleData.muscle_names;
NMuscle = length(muscleNames(1:end-3))*2;
[~,mai] = MomentArmIndices(muscleNames(1:end-3),muscle_spanning_joint_INFO);
load([pathpolynomial,'/ligament_spanning_joint_INFO.mat'],'ligament_spanning_joint_INFO');
nq.PF = size(ligament_spanning_joint_INFO,2);
% Muscles in foot
musif = find(muscle_spanning_joint_INFO(:,5)==1 | muscle_spanning_joint_INFO(:,6)==1 | ...
    muscle_spanning_joint_INFO(:,7)==1 | muscle_spanning_joint_INFO(:,8)==1);
NMf = length(musif);
for i=1:NMf
    muscleNamesFoot{i} = muscleNames{musif(i)};
end

% if S.Foot.FDB
%     NM_f = NMf+1;
%     muscleNamesFoot{NM_f} = 'FDB';
% else
    NM_f = NMf;
% end

tensions = getSpecificTensions(muscleNamesFoot);

%% Get Boundaries
jointi = getJointi_mtj();

bounds_qs = [[-2,2]*pi/180; % tibia rx
             [-15,-0]*pi/180; % tibia rz
             [0.2,0.6]; % tibia ty
             [-50, 50]*pi/180; % ankle
             [-50, 50]*pi/180; % subt
             [-30,30]*pi/180]; % mtj

bounds_qs(5,:) = bounds_qs(5,:)/subtR;

scale_qs = ones(size(bounds_qs,1),1);
for i=1:size(bounds_qs,1)
    scale_qs(i) = max(abs(bounds_qs(i,:)));
    bounds_qs(i,:) = bounds_qs(i,:)./scale_qs(i);
end

bounds_FTs = [zeros(NM_f,1),ones(NM_f,1)];
scale_FTs = 5*ones(NM_f,1);

bounds_scaled = bounds_qs.*scale_qs;

%% Field names for moment arms:
MAj_fieldnames = {'hip_flex','hip_add','hip_rot','knee','ankle','subt','mtj','mtp'};
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
MAj_dof_idx = MAj_dof_idx(MAj_dof_idx>0);

%% Get resting arch length and height

% call external function
[T_0] = full(F([zeros(nq.all*2,1);zeros(nq.all,1)]));

% body origin positions
toes_or_0 = T_0(jointfi.toes_or);
midfoot_or_0 = T_0(jointfi.midfoot_or);
calcn_or_0 = T_0(jointfi.calcn_or);

% calculate arch length
L0 = norm(toes_or_0-calcn_or_0);

% calculate arch height (orthogonal decomposition)
vec_a = squeeze(midfoot_or_0 - toes_or_0); % mtpj to tmtj/mtj
vec_b = squeeze(calcn_or_0 - toes_or_0); % mtpj to heel
vec_ap = dot(vec_a,vec_b)/dot(vec_b,vec_b)*vec_b; % orthogonal projection of a onto b
vec_an = vec_a - vec_ap; % component of a that is normal to b 

H0 = abs(norm(vec_an));


%% Build system to solve

% variables
Q_tib_rx = MX.sym('Q_tib_rx',1);
Q_tib_rz = MX.sym('Q_tib_rz',1);
Q_tib_ty = MX.sym('Q_tib_ty',1);
Q_ankle = MX.sym('Q_ankle',1);
Q_subt = MX.sym('Q_subt',1);
Q_mtj = MX.sym('Q_mtj',1);
FT_tilde = MX.sym('FT_tilde',NM_f,1);
T_mtp_ext = MX.sym('T_mtp_ext',1);

% parameters
Q_mtp_gnd = MX.sym('Q_mtp',1);
F_tib_y = MX.sym('F_tib_y ',1);

% unscale
Q_tib_rx_nsc = Q_tib_rx*scale_qs(1);
Q_tib_ry_nsc = 0;
Q_tib_rz_nsc = Q_tib_rz*scale_qs(2);
Q_tib_tx_nsc = 0;
Q_tib_ty_nsc = Q_tib_ty*scale_qs(3);
Q_tib_tz_nsc = 0;
Q_ankle_nsc = Q_ankle*scale_qs(4);
Q_subt_nsc = Q_subt*scale_qs(5);
Q_mtj_nsc = Q_mtj*scale_qs(6);
Q_mtp_nsc = Q_mtp_gnd - 0.4751*Q_mtj_nsc; % mtp can move relative to foot

% Get muscle-tendon information
qin_r = MX.zeros(nq.leg,1); % adapt vector size to match full model
qin_r(4) = -pi/2; % knee flex
qin_r(5) = Q_ankle_nsc;
qin_r(6) = Q_subt_nsc;
qin_r(7) = Q_mtj_nsc;
qin_r(8) = Q_mtp_nsc;
qdotin_r = MX.zeros(nq.leg,1);
[lMTj_r,vMTj_r,MAj_r] = f_lMT_vMT_dM(qin_r,qdotin_r);

lMT_r = lMTj_r(musif);
vMT_r = vMTj_r(musif);

% Here we take the indices from left since the vector is 1:49
for i=1:length(MAj_dof_idx)
    fieldname_i = MAj_fieldnames{MAj_dof_idx(i)};
    MAj.(fieldname_i).r   =  MAj_r(mai(i).mus.l',i);
end

% Get muscle-tendon forces and derive Hill-equilibrium
akj = MX.ones(NMuscle,1)*S.activity;  % adapt vector size to match full model
FTtildekj_nsc = MX.zeros(NMuscle,1);
dFTtildej_nsc = MX.zeros(NMuscle,1);
lMTj_lr = MX.zeros(NMuscle,1);
vMTj_lr = MX.zeros(NMuscle,1);
tensionsj_lr = MX.zeros(NMuscle,1);
for i=1:NMf
    FTtildekj_nsc((NMuscle/2+musif(i)),1) = FT_tilde(i)*scale_FTs(i);
    lMTj_lr((NMuscle/2+musif(i)),1) = lMT_r(i);
    vMTj_lr((NMuscle/2+musif(i)),1) = vMT_r(i);
    tensionsj_lr((46+musif(i)),1) = tensions(i);
end
[Hilldiffj,FTj,~,~,~] = f_forceEquilibrium_FtildeState_all_tendon(akj(:,1),...
        FTtildekj_nsc(:,1),dFTtildej_nsc(:,1),lMTj_lr,vMTj_lr,tensionsj_lr);

Hilldiff = MX.zeros(NM_f,1);
FT = MX.zeros(NM_f,1);
for i=1:NMf
    Hilldiff(i) = Hilldiffj(NMuscle/2+musif(i));
    FT(i) = FTj(NMuscle/2+musif(i));
end

% Right leg
Qs_PF = [Q_mtj_nsc;Q_mtp_nsc];
Qdots_PF = MX.zeros(size(Qs_PF));
[l_PFj_r,~,MA_PFj_r] =  f_lLi_vLi_dM(Qs_PF,Qdots_PF);
MA_PFj.mtj.r = MA_PFj_r(1);
MA_PFj.mtp.r = MA_PFj_r(2);

F_PFj = f_PF_stiffness([l_PFj_r,l_PFj_r])*S.Foot.PF_sf;
F_PF_PIMj.r = F_PFj(2);


% if S.Foot.FDB
%     [Hilldiffj_FDB,FTj_FDB,~,~,~] = f_forceEquilibrium_FtildeState_all_tendon_FDB(akj(1,1),...
%         FT_tilde(NM_f)*scale_FTs(NM_f),0,l_PFj_r,0,tensions(NM_f));
% 
%     Hilldiff(NM_f) = Hilldiffj_FDB;
%     FT(NM_f) = FTj_FDB;
% 
%     F_PF_PIMj.r = F_PF_PIMj.r + FTj_FDB;
% end


% Get passive torques
Qs_Tau_pass = MX.zeros(33,1);
Qs_Tau_pass(jointi.ankle.r) = Q_ankle_nsc;
Qs_Tau_pass(jointi.subt.r) = Q_subt_nsc*subtR; % multiply Q to get adjusted stiffness
Qs_Tau_pass(jointi.mtj.r) = Q_mtj_nsc;
Qs_Tau_pass(jointi.mtp.r) = Q_mtp_nsc;
Qdots_Tau_pass = MX.zeros(33,1);

Tau_passj_all = f_AllPassiveTorques(Qs_Tau_pass,Qdots_Tau_pass);
Tau_pass_ankle = Tau_passj_all(10);
Tau_pass_subt = Tau_passj_all(12);
% Tau_pass_mtj = Tau_passj_all(14);
Tau_pass_mtj = f_passiveTorque_mtj(Q_mtj_nsc);
% Tau_pass_mtp = Tau_passj_all(16);

T_pass_mtj = f_passiveMoment_mtj(Q_mtj_nsc);

% evaluate dynamics
qs = MX.zeros(nq.all,1);
qs(jointfi.tibia.rx) = Q_tib_rx_nsc;
qs(jointfi.tibia.ry) = Q_tib_ry_nsc;
qs(jointfi.tibia.rz) = Q_tib_rz_nsc;
qs(jointfi.tibia.tx) = Q_tib_tx_nsc;
qs(jointfi.tibia.ty) = Q_tib_ty_nsc;
qs(jointfi.tibia.tz) = Q_tib_tz_nsc;
qs(jointfi.ankle.r) = Q_ankle_nsc;
qs(jointfi.subt.r) = Q_subt_nsc;
qs(jointfi.mtj.r) = Q_mtj_nsc;
qs(jointfi.mtp.r) = Q_mtp_nsc;
qsqdots = MX.zeros(nq.all*2,1);
qsqdots(1:2:end,1) = qs;
qddots = MX.zeros(nq.all,1);

[Tj] = F([qsqdots(:,1);qddots(:,1)]);
% constraints
mai_i = 5; % helper index
% Ankle torque
Ft_ankle_r = FTj(mai(mai_i).mus.r',1);
T_ankle_r = f_T12(MAj.ankle.r,Ft_ankle_r);
f1 = Tj(jointfi.ankle.r,1)-(T_ankle_r + Tau_pass_ankle);
mai_i = mai_i+1;
% Subtalar torque
Ft_subt_r = FTj(mai(mai_i).mus.r',1);
T_subt_r = f_T12(MAj.subt.r,Ft_subt_r);
f2 = Tj(jointfi.subt.r,1)-(T_subt_r + Tau_pass_subt);
mai_i = mai_i+1;
% Mtj torque
T_mtj_tmp_r = Tau_pass_mtj + T_pass_mtj;
Ft_mtj_r        = FTj(mai(mai_i).mus.r',1);
T_mtj_r         = f_T9(MAj.mtj.r,Ft_mtj_r);
T_mtj_tmp_r     = T_mtj_tmp_r + T_mtj_r;
T_mtjPF_r       = MA_PFj.mtj.r*F_PF_PIMj.r;
T_mtj_tmp_r     = T_mtj_tmp_r + T_mtjPF_r;
f3 = Tj(jointfi.mtj.r,1)-(T_mtj_tmp_r);
mai_i = mai_i+1;
% Mtp torque
Ft_mtp_r        = FTj(mai(mai_i).mus.r',1);
T_mtp_r         = f_T4(MAj.mtp.r,Ft_mtp_r);
T_mtp_tmp_r     = T_mtp_r;
T_mtpPF_r       = MA_PFj.mtp.r*F_PF_PIMj.r;
T_mtp_tmp_r     = T_mtp_tmp_r + T_mtpPF_r;
f4 = Tj(jointfi.mtp.r,1)-(T_mtp_ext + T_mtp_tmp_r);

% Vertical force on knee
f5 = Tj(double(IO.coordi.tibia_ty),1) + F_tib_y;

% Hill difference
fh = Hilldiff;

% Equality constraints
ff = [f1;f2;f3;f4;f5;fh;];

% Objective
fo1 = (Tj(jointfi.calcn_or(2),1) - Tj(jointfi.toes_or(2),1) - 0.01)^2; % square to get positive value
fo2 = Tj(jointfi.midfoot_or(1),1)^2 + Tj(jointfi.midfoot_or(3),1)^2; % Knee position above navicular bone
%     fo2 = Tj(jointfi.talus_or(1),1)^2 + Tj(jointfi.talus_or(3),1)^2; % Knee position above talus

fo = fo1*1e2 + fo2;


%     % knee should be above arch, so on line connecting calcn and toes
%     % origin in xz-plane
%     fo_x = (Tj(jointfi.toes_or(1),1) - Tj(jointfi.calcn_or(1),1)) / Tj(jointfi.toes_or(1),1);
%     fo_z = (Tj(jointfi.toes_or(3),1) - Tj(jointfi.calcn_or(3),1)) / Tj(jointfi.toes_or(3),1);
%     fo = fo_x - fo_z;

% Define function to return constraints and objective
f_foot = Function('f_foot',{[Q_tib_rx;Q_tib_rz;Q_tib_ty;Q_ankle;Q_subt;Q_mtj;FT_tilde;T_mtp_ext],...
    Q_mtp_gnd,F_tib_y},{fo,ff});

% Define function to return forces and torques for post-processing
f_foot_pp = Function('f_foot_pp',{[Q_tib_rx;Q_tib_rz;Q_tib_ty;Q_ankle;Q_subt;Q_mtj;FT_tilde;T_mtp_ext],...
    Q_mtp_gnd,F_tib_y},...
    {FT,T_ankle_r,Tau_pass_ankle,T_subt_r,Tau_pass_subt,T_mtj_r,Tau_pass_mtj,T_pass_mtj,T_mtp_r,Q_mtp_nsc,...
    MA_PFj.mtj.r,l_PFj_r,F_PF_PIMj.r,T_mtpPF_r});


%%
% Declare arrays for postprocessing results
Qs = zeros(n_mtp,n_tib,nq.all);
Qdots = zeros(n_mtp,n_tib,nq.all);
Qddots = zeros(n_mtp,n_tib,nq.all);
QsQdots = zeros(n_mtp,n_tib,nq.all*2);
GRF_calcn = zeros(n_mtp,n_tib,3);
GRF_forefoot = zeros(n_mtp,n_tib,3);
toes_or = zeros(n_mtp,n_tib,3);
calcn_or = zeros(n_mtp,n_tib,3);
midfoot_or = zeros(n_mtp,n_tib,3);
talus_or = zeros(n_mtp,n_tib,3);
tibia_or = zeros(n_mtp,n_tib,3);
l_fa_ext = zeros(n_mtp,n_tib);
h_fa_ext = zeros(n_mtp,n_tib);
M_mtj = zeros(n_mtp,n_tib);
M_mtj_PF = zeros(n_mtp,n_tib);
M_mtj_li = zeros(n_mtp,n_tib);
F_PF = zeros(n_mtp,n_tib);
l_PF = zeros(n_mtp,n_tib);
MA_PF = zeros(n_mtp,n_tib);
M_mtp_PF = zeros(n_mtp,n_tib);
T_mtp_ext = zeros(n_mtp,n_tib);
failed = zeros(n_mtp,n_tib);
T_ankle = zeros(n_mtp,n_tib);
tau_ankle = zeros(n_mtp,n_tib);
T_subt = zeros(n_mtp,n_tib);
tau_subt = zeros(n_mtp,n_tib);
T_mtj = zeros(n_mtp,n_tib);
tau_mtj = zeros(n_mtp,n_tib);
T_mtp = zeros(n_mtp,n_tib);
T_ankle_ext = zeros(n_mtp,n_tib);
T_subt_ext = zeros(n_mtp,n_tib);
T_mtj_ext = zeros(n_mtp,n_tib);
for i=1:NM_f
    F_tendon.(muscleNamesFoot{i}) = zeros(n_mtp,n_tib);
end

%% make solver
opti = casadi.Opti();
% positions
qs_opti = opti.variable(6,1);
opti.subject_to(bounds_qs(:,1) <= qs_opti(:,1));
opti.subject_to(qs_opti(:,1) <= bounds_qs(:,2));
% muscle-tendon forces
FTtilde_opti = opti.variable(NM_f,1);
opti.subject_to(bounds_FTs(:,1) <= FTtilde_opti(:,1));
opti.subject_to(FTtilde_opti(:,1) <= bounds_FTs(:,2));
% torque from GRF on toes
T_mtp_opti = opti.variable(1,1);
% parameters
qmtp = opti.parameter();
Ftib = opti.parameter();
% equality constraints
[obj,constr] = f_foot([qs_opti;FTtilde_opti;T_mtp_opti],qmtp,Ftib);
opti.subject_to(constr == 0);

opti.minimize(obj);

% solver options
options.ipopt.hessian_approximation = 'limited-memory';
options.ipopt.mu_strategy           = 'adaptive';
options.ipopt.linear_solver         = 'mumps';
options.ipopt.tol                   = 1*10^(-4);
opti.solver('ipopt', options);

temp = [];


%% run solver        
for i=1:n_mtp
    % get initial guess
    qs_init = [0;0;0.45;0;0;0]./scale_qs;
    FTs_init = zeros(NM_f,1);

    for j=1:n_tib
        %% solve the static situation
        % initial guess
        opti.set_initial(qs_opti,qs_init);
        opti.set_initial(FTtilde_opti,FTs_init);
        opti.set_initial(T_mtp_opti,0);

        % set parameter values
        opti.set_value(qmtp, Qs_mtp(i));
        opti.set_value(Ftib, Fs_tib(j))
        % solve
        try
            sol = opti.solve();
            qs_sol = sol.value(qs_opti).*scale_qs;
            FTs_sol = sol.value(FTtilde_opti).*scale_FTs;
            T_mtp_sol = sol.value(T_mtp_opti);

%             % retrieve residuals
%             [~,f_res] = f_foot([qs_sol./scale_qs;FTs_sol./scale_FTs;T_mtp_sol],Qs_mtp(i),Fs_tib(j));
%             temp(:,end+1) = full(f_res);

            % Use solution to initialise next iteration with higher force.
            qs_init = qs_sol./scale_qs;
            FTs_init = FTs_sol./scale_FTs;

            %% postprocess results
            % get states
            Qs(i,j,jointfi.tibia.rx) = qs_sol(1);
            Qs(i,j,jointfi.tibia.rz) = qs_sol(2);
            Qs(i,j,jointfi.tibia.ty) = qs_sol(3); 
            Qs(i,j,jointfi.ankle.r) = qs_sol(4);
            Qs(i,j,jointfi.subt.r) = qs_sol(5);
            Qs(i,j,jointfi.mtj.r) = qs_sol(6);
            T_mtp_ext(i,j) = T_mtp_sol;

            QsQdots(i,j,1:2:end) = Qs(i,j,:);
            QsQdots(i,j,2:2:end) = Qdots(i,j,:);

            % call post-processing function
            [Fm,Ta,ta,Ts,ts,Tmtj,tmtj,M_lii,Tmtp,q_mtp,MA_PFi,l_PFi,F_PFi,M_mtpi] =...
                f_foot_pp([qs_sol./scale_qs;FTs_sol./scale_FTs;T_mtp_sol],Qs_mtp(i),Fs_tib(j));
            for ii=1:NM_f
                F_tendon.(muscleNamesFoot{ii})(i,j) = full(Fm(ii));
            end
            T_ankle(i,j) = full(Ta);
            tau_ankle(i,j) = full(ta);
            T_subt(i,j) = full(Ts);
            tau_subt(i,j) = full(ts);
            T_mtj(i,j) = full(Tmtj);
            tau_mtj(i,j) = full(tmtj);
            T_mtp(i,j) = full(Tmtp);

            Qs(i,j,jointfi.mtp.r) = full(q_mtp);
            
            M_mtj_li(i,j) = full(M_lii);
            F_PF(i,j) = full(F_PFi);
            l_PF(i,j) = full(l_PFi);
            MA_PF(i,j) = full(MA_PFi);
            M_mtp_PF(i,j) = full(M_mtpi);
            M_mtj_PF(i,j) = MA_PF(i,j)*F_PF(i,j);
            M_mtj(i,j) = M_mtj_li(i,j) + M_mtj_PF(i,j);

            % call external function
            [T_res] = full(F([vertcat(squeeze(QsQdots(i,j,:)));vertcat(squeeze(Qddots(i,j,:)))]));

            T_ankle_ext(i,j) = T_res(jointfi.ankle.r);
            T_subt_ext(i,j) = T_res(jointfi.subt.r);
            T_mtj_ext(i,j) = T_res(jointfi.mtj.r);

            % ground reaction forces
            GRF_calcn(i,j,:) = T_res(jointfi.calcn_GRF(1,:)) + T_res(jointfi.calcn_GRF(2,:));
            GRF_forefoot(i,j,:) = T_res(jointfi.forefoot_GRF(1,:)) + T_res(jointfi.forefoot_GRF(2,:));


            % body origin positions
            toes_or(i,j,:) = T_res(jointfi.toes_or);
            midfoot_or(i,j,:) = T_res(jointfi.midfoot_or);
            calcn_or(i,j,:) = T_res(jointfi.calcn_or);
            talus_or(i,j,:) = T_res(jointfi.talus_or);
            tibia_or(i,j,1) = Qs(i,j,jointfi.tibia.tx);
            tibia_or(i,j,2) = Qs(i,j,jointfi.tibia.ty);
            tibia_or(i,j,3) = Qs(i,j,jointfi.tibia.tz);
            
            % calculate arch length
            l_fa_ext(i,j) = norm(squeeze(toes_or(i,j,:)-calcn_or(i,j,:)));

            % calculate arch height (orthogonal decomposition)
            vec_a = squeeze(midfoot_or(i,j,:) - toes_or(i,j,:)); % mtpj to tmtj/mtj
            vec_b = squeeze(calcn_or(i,j,:) - toes_or(i,j,:)); % mtpj to heel
            vec_ap = dot(vec_a,vec_b)/dot(vec_b,vec_b)*vec_b; % orthogonal projection of a onto b
            vec_an = vec_a - vec_ap; % component of a that is normal to b 

            h_fa_ext(i,j) = abs(norm(vec_an));

        catch errmsg
            failed(i,j) = 1;
%             disp(errmsg)
        end

    end
end

disp(temp);

%% save results
R.S = S;
R.Qs_mtp = Qs_mtp;
R.Qs = Qs;
R.jointfi = jointfi;
R.Fs_tib = Fs_tib;
R.GRF_calcn = GRF_calcn;
R.GRF_forefoot = GRF_forefoot;
R.F_PF = F_PF;
R.l_PF = l_PF;
R.l_fa_ext = l_fa_ext;
R.L0 = L0;
R.H0 = H0;
R.M_mtp = M_mtp_PF;
R.h_fa_ext = h_fa_ext;
R.MA_PF = MA_PF;
R.toes_or = toes_or;
R.midfoot_or = midfoot_or;
R.calcn_or = calcn_or;
R.talus_or = talus_or;
R.tibia_or = tibia_or;
R.failed = failed;
R.FT = F_tendon;
R.T_ankle.muscle = T_ankle;
R.T_ankle.pass = tau_ankle;
R.T_ankle.ext = T_ankle_ext;
R.T_subt.muscle = T_subt;
R.T_subt.pass = tau_subt;
R.T_subt.ext = T_subt_ext;
R.T_mtj.ext = T_mtj_ext;
R.T_mtj.muscle = T_mtj;
R.T_mtj.pass = tau_mtj;
R.T_mtj.lig = M_mtj_li;
R.T_mtj.PF = M_mtj_PF;
R.T_mtp.muscle = T_mtp;
R.T_mtp.PF = M_mtp_PF;
R.M_WL = M_mtj;
R.T_mtp_ext = T_mtp_ext;

R.PF_stiffness = S.Foot.PF_stiffness;
R.legname = legname;

model_path = fullfile(pathRepo,'OpenSimModel\subject1',...
    ['Foot_Fal_s1_' S.Foot.Model '_sc_cspx10_oy3.osim']);
R.h_nav = getNavicularHeight(R,model_path);


end