function [R] = f_LoadSim_Gait92_FootModel(ResultsFolder,loadname)


%% Notes

% to simplify batch processing, the casadi functions were already created
% using the script CasadiFunctions_all_tmt.m
% This assumes invariant:
%   Muscle and tendon properties
%   Polynomials to compute moment arms
%   Functions to compute passive stiffness

% We can still vary:
% 1) the collocation scheme
% 2) the weights in the objective function
% 3) the external function


if strcmp(loadname(end-3:end),'.mat')
    loadname = loadname(1:end-4);
end

pathmain = mfilename('fullpath');
[filepath,~,~] =  fileparts(pathmain);
[pathRepo,~,~] = fileparts(filepath);
OutFolder = fullfile(ResultsFolder);
Outname = fullfile(OutFolder,[loadname '.mat']);
load(Outname,'w_opt','stats','Sopt','setup');
S = Sopt;

%% Model info
body_mass = S.mass;
body_weight = S.mass*9.81;
    
if contains(S.Foot.Model,'mtj')
    mtj = 1;
else
    mtj = 0;
end

%% User inputs (typical settings structure)
% load default CasadiFunctions

% flow control
writeIKmotion   = 1; % set to 1 to write .mot file

% settings for optimization
v_tgt       = S.v_tgt;      % average speed
N           = S.N;          % number of mesh intervals
W           = S.W;
exp_E       = S.W.exp_E;    % power metabolic energy

% ipopt options
tol_ipopt       = S.tol_ipopt;


%% Load external function
% AddCasadiPaths();
import casadi.*
% The external function performs inverse dynamics through the
% OpenSim/Simbody C++ API. This external function is compiled as a dll from
% which we create a Function instance using CasADi in MATLAB. More details
% about the external function can be found in the documentation.
pathRepo        = pwd;
addpath(genpath(pathRepo));
% Loading external functions.
setup.derivatives =  'AD'; % Algorithmic differentiation
pathExternalFunctions = [pathRepo,'/ExternalFunctions'];
cd(pathExternalFunctions)
F  = external('F',['F_' S.ExternalFunc '.dll']);
load(['F_' S.ExternalFunc '_IO.mat'],'IO');
cd(pathRepo);

%% Collocation scheme
% We use a pseudospectral direct collocation method, i.e. we use Lagrange
% polynomials to approximate the state derivatives at the collocation
% points in each mesh interval. We use d=3 collocation points per mesh
% interval and Radau collocation points.
pathCollocationScheme = [pathRepo,'/CollocationScheme'];
addpath(genpath(pathCollocationScheme));
d = 3; % degree of interpolating polynomial
method = 'radau'; % collocation method
[tau_root,C,D,B] = CollocationScheme(d,method);

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
pathpolynomial = fullfile(pathRepo,'Polynomials',S.OsimFileName);
pathmusclemodel = fullfile(pathRepo,'MuscleModel',S.OsimFileName);
addpath(genpath(pathmusclemodel));
% Muscles from one leg and from the back
load([pathpolynomial,'/MuscleData.mat'],'MuscleData');
muscleNames = MuscleData.muscle_names;
% Total number of muscles
NMuscle = length(muscleNames(1:end-3))*2;
pathpolynomial = fullfile(pathRepo,'Polynomials',S.OsimFileName);
load([pathpolynomial,'/muscle_spanning_joint_INFO.mat'],'muscle_spanning_joint_INFO');
load([pathpolynomial,'/MuscleData.mat'],'MuscleData');
% [~,mai] = MomentArmIndices(muscleNames(1:end-3),muscle_spanning_joint_INFO);
try
    load([pathpolynomial,'/ligament_spanning_joint_INFO.mat'],'ligament_spanning_joint_INFO');
    nq.PF = size(ligament_spanning_joint_INFO,2);
catch
    nq.PF = 0;
end
% Parameters for activation dynamics
tact = 0.015; % Activation time constant
tdeact = 0.06; % Deactivation time constant

%% Metabolic energy model parameters
% We extract the specific tensions and slow twitch rations.
pathMetabolicEnergy = [pathRepo,'/MetabolicEnergy'];
addpath(genpath(pathMetabolicEnergy));
tension = getSpecificTensions(muscleNames(1:end-3));
tensions = [tension;tension];
pctst = getSlowTwitchRatios(muscleNames(1:end-3));
pctsts = [pctst;pctst];

%% CasADi functions
% We create several CasADi functions for later use
pathCasADiFunctions = [pathRepo,'/CasADiFunctions'];
PathDefaultFunc = fullfile(pathCasADiFunctions,S.CasadiFunc_Folders);
f_lMT_vMT_dM = Function.load(fullfile(PathDefaultFunc,'f_lMT_vMT_dM'));
f_lT_vT = Function.load(fullfile(PathDefaultFunc,'f_lT_vT'));
if nq.PF
    f_lLi_vLi_dM = Function.load(fullfile(PathDefaultFunc,'f_lLi_vLi_dM'));
end

f_FiberLength_TendonForce_tendon = Function.load(fullfile(PathDefaultFunc,'f_FiberLength_TendonForce_tendon'));
f_FiberVelocity_TendonForce_tendon = Function.load(fullfile(PathDefaultFunc,'f_FiberVelocity_TendonForce_tendon'));
f_forceEquilibrium_FtildeState_all_tendon = Function.load(fullfile(PathDefaultFunc,'f_forceEquilibrium_FtildeState_all_tendon'));

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
f_Jnn3  = Function.load(fullfile(PathDefaultFunc,'f_Jnn3'));

% file with mass of muscles
MassFile = fullfile(PathDefaultFunc,'MassM.mat');
MuscleMass = load(MassFile);


%% Indices external function
% Indices of the elements in the external functions
% External function: F
% First, joint torques.
if mtj
    jointi = getJointi_mtj();
else
    jointi = getJointi();
end

% Vectors of indices for later use
residualsi          = 1:length(fieldnames(IO.coordi)); % all
ground_pelvisi      = double(IO.jointi.floating_base); % ground-pelvis
trunki              = double(IO.jointi.torso); % trunk
armsi               = double([IO.jointi.arm_l,IO.jointi.arm_r]); % arms
residuals_noarmsi   = setdiff(residualsi,armsi); % all but arms
roti                = double(IO.jointi.rotations);

% Number of degrees of freedom for later use
nq.all      = length(residualsi); % all
nq.abs      = length(ground_pelvisi); % ground-pelvis
nq.trunk    = length(trunki); % trunk
nq.arms     = length(armsi); % arms
nq.leg      = size(muscle_spanning_joint_INFO,2);

coord_names = cell(2,nq.all);
coord_names_tmp = fieldnames(IO.coordi);
for i=1:nq.all
    coord_names{1,i} = coord_names_tmp{i};
    coord_names{2,i} = IO.coordi.(coord_names_tmp{i});
end
IO.coord_namesi = coord_names;

% Body origins 
% Calcaneus
calcOrall.r    = double(IO.origin.calcn_r);
calcOrall.l    = double(IO.origin.calcn_l);
calcOrall.all  = [calcOrall.r,calcOrall.l];
% Femurs
femurOrall.r   = double(IO.origin.femur_r);
femurOrall.l   = double(IO.origin.femur_l);
femurOrall.all = [femurOrall.r,femurOrall.l];
% Hands
handOrall.r    = double(IO.origin.hand_r);
handOrall.l    = double(IO.origin.hand_l);
handOrall.all  = [handOrall.r,handOrall.l];
% Tibias
tibiaOrall.r   = double(IO.origin.tibia_r);
tibiaOrall.l   = double(IO.origin.tibia_l);
tibiaOrall.all = [tibiaOrall.r,tibiaOrall.l];
% toe joints
toesOrall.r   = double(IO.origin.toes_r);
toesOrall.l   = double(IO.origin.toes_l);
toesOrall.all = [toesOrall.r,toesOrall.l];
% midfoot
if mtj
    midfootOrall.r   = double(IO.origin.midfoot_r);
    midfootOrall.l   = double(IO.origin.midfoot_l);
    midfootOrall.all = [midfootOrall.r,midfootOrall.l];
end 
% Ground Reaction Forces
GRFi.r = IO.GRFs.right_foot;
GRFi.l = IO.GRFs.left_foot;
GRFi.all = [GRFi.r,GRFi.l];
NGRF = length(GRFi.all);

GRFi.calcn.r = [IO.GRFs.contact_sphere_1,IO.GRFs.contact_sphere_2];
GRFi.metatarsi.r = [IO.GRFs.contact_sphere_3,IO.GRFs.contact_sphere_4,IO.GRFs.contact_sphere_5];
GRFi.toes.r = [IO.GRFs.contact_sphere_6];
GRFi.calcn.l = [IO.GRFs.contact_sphere_7,IO.GRFs.contact_sphere_8];
GRFi.metatarsi.l = [IO.GRFs.contact_sphere_9,IO.GRFs.contact_sphere_10,IO.GRFs.contact_sphere_11];
GRFi.toes.l = [IO.GRFs.contact_sphere_12];
GRFi.separate = GRFi.calcn.r(1):GRFi.toes.l(end);

% GRF torques
GRFTi.r = IO.GRMs.right_total;
GRFTi.l = IO.GRMs.left_total;

% Contact sphere deformation power
if isfield(IO,'P_contact_deformation_y')
    P_HCi.calcn.r = [IO.P_contact_deformation_y.contact_sphere_1,IO.P_contact_deformation_y.contact_sphere_2];
    P_HCi.metatarsi.r = [IO.P_contact_deformation_y.contact_sphere_3,IO.P_contact_deformation_y.contact_sphere_4,...
        IO.P_contact_deformation_y.contact_sphere_5];
    P_HCi.toes.r = [IO.P_contact_deformation_y.contact_sphere_6];
    P_HCi.calcn.l = [IO.P_contact_deformation_y.contact_sphere_7,IO.P_contact_deformation_y.contact_sphere_8];
    P_HCi.metatarsi.l = [IO.P_contact_deformation_y.contact_sphere_9,IO.P_contact_deformation_y.contact_sphere_10,...
        IO.P_contact_deformation_y.contact_sphere_11];
    P_HCi.toes.l = [IO.P_contact_deformation_y.contact_sphere_12];
    P_HCi.separate = P_HCi.calcn.r(1):P_HCi.toes.l(end);
end

%% Joints
if mtj
    joints = {'pelvis_tilt','pelvis_list','pelvis_rotation','pelvis_tx',...
        'pelvis_ty','pelvis_tz','hip_flexion_l','hip_adduction_l',...
        'hip_rotation_l','hip_flexion_r','hip_adduction_r','hip_rotation_r',...
        'knee_angle_l','knee_angle_r','ankle_angle_l','ankle_angle_r',...
        'subtalar_angle_l','subtalar_angle_r',...
        'mtj_angle_l','mtj_angle_r','mtp_angle_l','mtp_angle_r',...
        'lumbar_extension','lumbar_bending','lumbar_rotation','arm_flex_l',...
        'arm_add_l','arm_rot_l','arm_flex_r','arm_add_r','arm_rot_r',...
        'elbow_flex_l','elbow_flex_r'};
else
    joints = {'pelvis_tilt','pelvis_list','pelvis_rotation','pelvis_tx',...
        'pelvis_ty','pelvis_tz','hip_flexion_l','hip_adduction_l',...
        'hip_rotation_l','hip_flexion_r','hip_adduction_r','hip_rotation_r',...
        'knee_angle_l','knee_angle_r','ankle_angle_l','ankle_angle_r',...
        'subtalar_angle_l','subtalar_angle_r','mtp_angle_l','mtp_angle_r',...
        'lumbar_extension','lumbar_bending','lumbar_rotation','arm_flex_l',...
        'arm_add_l','arm_rot_l','arm_flex_r','arm_add_r','arm_rot_r',...
        'elbow_flex_l','elbow_flex_r'};
end

%% Get tracking information
if isfield(S,'TrackSim') && S.TrackSim
    load([pathRepo '\Data\Fal_s1.mat'],'Data');
    Qref = Data.(['IK_' S.Track.Q_ref]);
    if S.Track.Q_ankle
        Qref_ankle = Qref.Qall_mean(:,strcmp(Qref.colheaders,'ankle_angle'))*pi/180;
        Qref_ankle = interp1(linspace(1,2*N,length(Qref_ankle))',Qref_ankle,...
             (1:1:2*N)','spline','extrap');
        Qref_ankle_lr = [Qref_ankle(N+1:end),Qref_ankle(1:N)]';
    end
    if S.Track.Q_subt
        Qref_subt = Qref.Qall_mean(:,strcmp(Qref.colheaders,'subtalar_angle'))*pi/180;
        Qref_subt = interp1(linspace(1,2*N,length(Qref_subt))',Qref_subt,...
             (1:1:2*N)','spline','extrap');
        Qref_subt_lr = [Qref_subt(N+1:end),Qref_subt(1:N)]';
    end

    if S.Track.Q_ankle
        if S.Track.Q_subt
            Qref_lr = [Qref_ankle_lr;Qref_subt_lr];
        else
            Qref_lr = Qref_ankle_lr;
        end
    elseif S.Track.Q_subt
        Qref_lr = Qref_subt_lr;
    end

end

%% get scaling
scaling = setup.scaling;

%% Index helpers
[IndexLeft,IndexRight,QsSymA,QsSymB,QsSymA_ptx,...
    QsSymB_ptx,QsOpp] = GetIndexHelper_IO(jointi,IO,MuscleData.dof_names);

%% Read from the vector with optimization results

NParameters = 1;
tf_opt = w_opt(1:NParameters);
starti = NParameters+1;
a_opt = reshape(w_opt(starti:starti+NMuscle*(N+1)-1),NMuscle,N+1)';
starti = starti + NMuscle*(N+1);
a_col_opt = reshape(w_opt(starti:starti+NMuscle*(d*N)-1),NMuscle,d*N)';
starti = starti + NMuscle*(d*N);
FTtilde_opt = reshape(w_opt(starti:starti+NMuscle*(N+1)-1),NMuscle,N+1)';
starti = starti + NMuscle*(N+1);
FTtilde_col_opt =reshape(w_opt(starti:starti+NMuscle*(d*N)-1),NMuscle,d*N)';
starti = starti + NMuscle*(d*N);
Qs_opt = reshape(w_opt(starti:starti+nq.all*(N+1)-1),nq.all,N+1)';
starti = starti + nq.all*(N+1);
Qs_col_opt = reshape(w_opt(starti:starti+nq.all*(d*N)-1),nq.all,d*N)';
starti = starti + nq.all*(d*N);
Qdots_opt = reshape(w_opt(starti:starti+nq.all*(N+1)-1),nq.all,N+1)';
starti = starti + nq.all*(N+1);
Qdots_col_opt = reshape(w_opt(starti:starti+nq.all*(d*N)-1),nq.all,d*N)';
starti = starti + nq.all*(d*N);
a_a_opt = reshape(w_opt(starti:starti+nq.arms*(N+1)-1),nq.arms,N+1)';
starti = starti + nq.arms*(N+1);
a_a_col_opt = reshape(w_opt(starti:starti+nq.arms*(d*N)-1),nq.arms,d*N)';
starti = starti + nq.arms*(d*N);
if S.Foot.mtp_actuator
    a_mtp_opt = reshape(w_opt(starti:starti+2*(N+1)-1),2,N+1)';
    starti = starti + 2*(N+1);
    a_mtp_col_opt = reshape(w_opt(starti:starti+2*(d*N)-1),2,d*N)';
    starti = starti + 2*(d*N);
end
if S.Foot.PIM
    a_PIM_opt = reshape(w_opt(starti:starti+2*(N+1)-1),2,N+1)';
    starti = starti + 2*(N+1);
    a_PIM_col_opt = reshape(w_opt(starti:starti+2*(d*N)-1),2,d*N)';
    starti = starti + 2*(d*N);
end
vA_opt = reshape(w_opt(starti:starti+NMuscle*N-1),NMuscle,N)';
starti = starti + NMuscle*N;
e_a_opt = reshape(w_opt(starti:starti+nq.arms*N-1),nq.arms,N)';
starti = starti + nq.arms*N;
if S.Foot.mtp_actuator
    e_mtp_opt = reshape(w_opt(starti:starti+2*N-1),2,N)';
    starti = starti + 2*N;
end
if S.Foot.PIM
    e_PIM_opt = reshape(w_opt(starti:starti+2*N-1),2,N)';
    starti = starti + 2*N;
end
dFTtilde_col_opt=reshape(w_opt(starti:starti+NMuscle*(d*N)-1),NMuscle,d*N)';
starti = starti + NMuscle*(d*N);
qdotdot_col_opt =reshape(w_opt(starti:starti+nq.all*(d*N)-1),nq.all,(d*N))';
starti = starti + nq.all*(d*N);
if starti - 1 ~= length(w_opt)
    disp('error when extracting results')
end
% Combine results at mesh and collocation points
a_mesh_col_opt=zeros(N*(d+1)+1,NMuscle);
a_mesh_col_opt(1:(d+1):end,:)= a_opt;
FTtilde_mesh_col_opt=zeros(N*(d+1)+1,NMuscle);
FTtilde_mesh_col_opt(1:(d+1):end,:)= FTtilde_opt;
Qs_mesh_col_opt=zeros(N*(d+1)+1,nq.all);
Qs_mesh_col_opt(1:(d+1):end,:)= Qs_opt;
Qdots_mesh_col_opt=zeros(N*(d+1)+1,nq.all);
Qdots_mesh_col_opt(1:(d+1):end,:)= Qdots_opt;
a_a_mesh_col_opt=zeros(N*(d+1)+1,nq.arms);
a_a_mesh_col_opt(1:(d+1):end,:)= a_a_opt;
if S.Foot.mtp_actuator
    a_mtp_mesh_col_opt=zeros(N*(d+1)+1,2);
    a_mtp_mesh_col_opt(1:(d+1):end,:)= a_mtp_opt;
end
if S.Foot.PIM
    a_PIM_mesh_col_opt=zeros(N*(d+1)+1,2);
    a_PIM_mesh_col_opt(1:(d+1):end,:)= a_PIM_opt;
end
for k=1:N
    rangei = k*(d+1)-(d-1):k*(d+1);
    rangebi = (k-1)*d+1:k*d;
    a_mesh_col_opt(rangei,:) = a_col_opt(rangebi,:);
    FTtilde_mesh_col_opt(rangei,:) = FTtilde_col_opt(rangebi,:);
    Qs_mesh_col_opt(rangei,:) = Qs_col_opt(rangebi,:);
    Qdots_mesh_col_opt(rangei,:) = Qdots_col_opt(rangebi,:);
    a_a_mesh_col_opt(rangei,:) = a_a_col_opt(rangebi,:);
    if S.Foot.mtp_actuator
        a_mtp_mesh_col_opt(rangei,:) = a_mtp_col_opt(rangebi,:);
    end
    if S.Foot.PIM
        a_PIM_mesh_col_opt(rangei,:) = a_PIM_col_opt(rangebi,:);
    end
end

%% Unscale results
% States at mesh points
% Qs (1:N-1)
q_opt_unsc.rad = Qs_opt(1:end-1,:).*repmat(...
    scaling.Qs,size(Qs_opt(1:end-1,:),1),1);
% Convert in degrees
q_opt_unsc.deg = q_opt_unsc.rad;
q_opt_unsc.deg(:,roti) = q_opt_unsc.deg(:,roti).*180/pi;
% Qs (1:N)
q_opt_unsc_all.rad = Qs_opt.*repmat(scaling.Qs,size(Qs_opt,1),1);
% Convert in degrees
q_opt_unsc_all.deg = q_opt_unsc_all.rad;
q_opt_unsc_all.deg(:,roti) = q_opt_unsc_all.deg(:,roti).*180/pi;
% Qdots (1:N-1)
qdot_opt_unsc.rad = Qdots_opt(1:end-1,:).*repmat(...
    scaling.Qdots,size(Qdots_opt(1:end-1,:),1),1);
% Convert in degrees
qdot_opt_unsc.deg = qdot_opt_unsc.rad;
qdot_opt_unsc.deg(:,roti) = qdot_opt_unsc.deg(:,roti).*180/pi;
% Qdots (1:N)
qdot_opt_unsc_all.rad =Qdots_opt.*repmat(scaling.Qdots,size(Qdots_opt,1),1);
% Muscle activations (1:N-1)
a_opt_unsc = a_opt(1:end-1,:).*repmat(...
    scaling.a,size(a_opt(1:end-1,:),1),size(a_opt,2));
% Muscle-tendon forces (1:N-1)
FTtilde_opt_unsc = FTtilde_opt(1:end-1,:).*repmat(...
    scaling.FTtilde,size(FTtilde_opt(1:end-1,:),1),1);
% Arm activations (1:N-1)
a_a_opt_unsc = a_a_opt(1:end-1,:);
% Arm activations (1:N)
a_a_opt_unsc_all = a_a_opt;
if S.Foot.mtp_actuator
    % Mtp activations (1:N-1)
    a_mtp_opt_unsc = a_mtp_opt(1:end-1,:);
    % Mtp activations (1:N)
    a_mtp_opt_unsc_all = a_mtp_opt;
end
if S.Foot.PIM
    % PIM activations (1:N-1)
    a_PIM_opt_unsc = a_PIM_opt(1:end-1,:);
    % PIM activations (1:N)
    a_PIM_opt_unsc_all = a_PIM_opt;
end
% Controls at mesh points
% Time derivative of muscle activations (states)
vA_opt_unsc = vA_opt.*repmat(scaling.vA,size(vA_opt,1),size(vA_opt,2));
% Get muscle excitations from time derivative of muscle activations
e_opt_unsc = computeExcitationRaasch(a_opt_unsc,vA_opt_unsc,...
    ones(1,NMuscle)*tdeact,ones(1,NMuscle)*tact);
% Arm excitations
e_a_opt_unsc = e_a_opt;
% Mtp excitations
if S.Foot.mtp_actuator
    e_mtp_opt_unsc = e_mtp_opt;
end
% PIM excitations
if S.Foot.PIM
    e_PIM_opt_unsc = e_PIM_opt;
end
% States at collocation points
% Qs
q_col_opt_unsc.rad = Qs_col_opt.*repmat(scaling.Qs,size(Qs_col_opt,1),1);
% Convert in degrees
q_col_opt_unsc.deg = q_col_opt_unsc.rad;
q_col_opt_unsc.deg(:,roti) = q_col_opt_unsc.deg(:,roti).*180/pi;
% Qdots
qdot_col_opt_unsc.rad = Qdots_col_opt.*repmat(...
    scaling.Qdots,size(Qdots_col_opt,1),1);
% Convert in degrees
qdot_col_opt_unsc.deg = qdot_col_opt_unsc.rad;
qdot_col_opt_unsc.deg(:,roti) = qdot_col_opt_unsc.deg(:,roti).*180/pi;
% Muscle activations
a_col_opt_unsc = a_col_opt.*repmat(...
    scaling.a,size(a_col_opt,1),size(a_col_opt,2));
% Muscle-tendon forces
FTtilde_col_opt_unsc = FTtilde_col_opt.*repmat(...
    scaling.FTtilde,size(FTtilde_col_opt,1),1);
% Arm activations
a_a_col_opt_unsc = a_a_col_opt;
% Mtp activations
if S.Foot.mtp_actuator
    a_mtp_col_opt_unsc = a_mtp_col_opt;
end
% PIM activations
if S.Foot.PIM
    a_PIM_col_opt_unsc = a_PIM_col_opt;
end
% "Slack" controls at collocation points
% Time derivative of Qdots
qdotdot_col_opt_unsc.rad = ...
    qdotdot_col_opt.*repmat(scaling.Qdotdots,size(qdotdot_col_opt,1),1);
% Convert in degrees
qdotdot_col_opt_unsc.deg = qdotdot_col_opt_unsc.rad;
qdotdot_col_opt_unsc.deg(:,roti) = qdotdot_col_opt_unsc.deg(:,roti).*180/pi;
% Time derivative of muscle-tendon forces
dFTtilde_col_opt_unsc = dFTtilde_col_opt.*repmat(...
    scaling.dFTtilde,size(dFTtilde_col_opt,1),size(dFTtilde_col_opt,2));
dFTtilde_opt_unsc = dFTtilde_col_opt_unsc(d:d:end,:);

%% Time grid
% Mesh points
tgrid = linspace(0,tf_opt,N+1);
dtime = zeros(1,d+1);
for i=1:4
    dtime(i)=tau_root(i)*(tf_opt/N);
end
% Mesh points and collocation points
tgrid_ext = zeros(1,(d+1)*N+1);
for i=1:N
    tgrid_ext(((i-1)*4+1):1:i*4)=tgrid(i)+dtime;
end
tgrid_ext(end)=tf_opt;

%% Joint torques and ground reaction forces at mesh points (N-1), except #1
Xk_Qs_Qdots_opt             = zeros(N,2*nq.all);
Xk_Qs_Qdots_opt(:,1:2:end)  = q_opt_unsc_all.rad(2:end,:);
Xk_Qs_Qdots_opt(:,2:2:end)  = qdot_opt_unsc_all.rad(2:end,:);
Xk_Qdotdots_opt             = qdotdot_col_opt_unsc.rad(d:d:end,:);
Foutk_opt                   = zeros(N,F.nnz_out);
Tau_passk_opt_all           = zeros(N,nq.all-nq.abs);


for i = 1:N
    % ID moments
    [res] = F([Xk_Qs_Qdots_opt(i,:)';Xk_Qdotdots_opt(i,:)']); % ext func used in optimization
    Foutk_opt(i,:) = full(res); % extract ID moments from external function used in the optimization
    
    % passive moments
    Tau_passk_opt_all(i,:) = full(f_AllPassiveTorques(q_opt_unsc_all.rad(i+1,:),qdot_opt_unsc_all.rad(i+1,:)));
end
GRFk_opt = Foutk_opt(:,GRFi.all);
GRFk_separate_opt = Foutk_opt(:,GRFi.separate);

%% Joint torques and ground reaction forces at collocation points
Xj_Qs_Qdots_opt             = zeros(d*N,2*nq.all);
Xj_Qs_Qdots_opt(:,1:2:end)  = q_col_opt_unsc.rad;
Xj_Qs_Qdots_opt(:,2:2:end)  = qdot_col_opt_unsc.rad;
Xj_Qdotdots_opt             = qdotdot_col_opt_unsc.rad;
Foutj_opt                   = zeros(d*N,F.nnz_out);
Tau_passj_opt_all           = zeros(d*N,nq.all-nq.abs);
Tau_passj_opt_all_noDamping = Tau_passj_opt_all;

for i = 1:d*N
    % inverse dynamics
    [res] = F([Xj_Qs_Qdots_opt(i,:)';Xj_Qdotdots_opt(i,:)']); 
    Foutj_opt(i,:) = full(res); % extract ID moments from external function used in the optimization
    % passive torques
    Tau_passj_opt_all(i,:) = full(f_AllPassiveTorques(q_col_opt_unsc.rad(i,:),qdot_col_opt_unsc.rad(i,:)));
    Tau_passj_opt_all_noDamping(i,:) = full(f_AllPassiveTorques(q_col_opt_unsc.rad(i,:),zeros(size(qdot_col_opt_unsc.rad(i,:)))));
end
if isfield(S.W,'noDamping') && S.W.noDamping
    if mtj
        Tau_passj_J = Tau_passj_opt_all_noDamping(:,[1:12 17:end]);
    else
        Tau_passj_J = Tau_passj_opt_all_noDamping(:,[1:12 15:end]);
    end
else
    if mtj
        Tau_passj_J = Tau_passj_opt_all(:,[1:12 17:end]);
    else
        Tau_passj_J = Tau_passj_opt_all(:,[1:12 15:end]);
    end
end

%% Stride length and width
% For the stride length we also need the values at the end of the
% interval so N+1 where states but not controls are defined
Xk_Qs_Qdots_opt_all = zeros(N+1,2*size(q_opt_unsc_all.rad,2));
Xk_Qs_Qdots_opt_all(:,1:2:end)  = q_opt_unsc_all.rad;
Xk_Qs_Qdots_opt_all(:,2:2:end)  = qdot_opt_unsc_all.rad;
% We just want to extract the positions of the calcaneus origins so we
% do not really care about Qdotdot that we set to 0
Xk_Qdotdots_opt_all = zeros(N+1,size(q_opt_unsc_all.rad,2));
out_res_opt_all = zeros(N+1,F.nnz_out);
for i = 1:N+1
    [res] = F([Xk_Qs_Qdots_opt_all(i,:)';Xk_Qdotdots_opt_all(i,:)']);
    out_res_opt_all(i,:) = full(res);
end
% The stride length is the distance covered by the calcaneus origin
% Right leg
dist_r = sqrt(f_Jnn3(out_res_opt_all(end,calcOrall.r)-...
    out_res_opt_all(1,calcOrall.r)));
% Left leg
dist_l = sqrt(f_Jnn3(out_res_opt_all(end,calcOrall.l)-...
    out_res_opt_all(1,calcOrall.l)));
% The total stride length is the sum of the right and left stride
% lengths after a half gait cycle, since we assume symmetry
StrideLength_opt = full(dist_r + dist_l);
% The stride width is the medial distance between the calcaneus origins
StepWidth_opt = full(abs(out_res_opt_all(:,calcOrall.r(3)) - ...
    out_res_opt_all(:,calcOrall.l(3))));
stride_width_mean = mean(StepWidth_opt);

%% Assert average speed
dist_trav_opt = q_opt_unsc_all.rad(end,jointi.pelvis.tx) - ...
    q_opt_unsc_all.rad(1,jointi.pelvis.tx); % distance traveled
time_elaps_opt = tf_opt; % time elapsed
vel_aver_opt = dist_trav_opt/time_elaps_opt;
% assert_v_tg should be 0
assert_v_tg = abs(vel_aver_opt-v_tgt);
if assert_v_tg > 1*10^(-tol_ipopt)
    disp('Issue when reconstructing average speed')
end

%% Decompose optimal cost
J_opt           = 0;
J_2_opt         = 0;
E_cost          = 0;
A_cost          = 0;
Arm_cost        = 0;
Mtp_cost        = 0;
PIM_cost        = 0;
Qdotdot_cost    = 0;
Pass_cost       = 0;
GRF_cost        = 0;
vA_cost         = 0;
dFTtilde_cost   = 0;
QdotdotArm_cost = 0;
Track_cost      = 0;
count           = 1;
h_opt           = tf_opt/N;
for k=1:N
    for j=1:d
        % Get muscle-tendon lengths, velocities, moment arms
        % Left leg
        qin_l_opt_all = Xj_Qs_Qdots_opt(count,IndexLeft*2-1);
        qdotin_l_opt_all = Xj_Qs_Qdots_opt(count,IndexLeft*2);
        [lMTk_l_opt_all,vMTk_l_opt_all,~] = ...
            f_lMT_vMT_dM(qin_l_opt_all,qdotin_l_opt_all);
        % Right leg
        qin_r_opt_all = Xj_Qs_Qdots_opt(count,IndexRight*2-1);
        qdotin_r_opt_all = Xj_Qs_Qdots_opt(count,IndexRight*2);
        [lMTk_r_opt_all,vMTk_r_opt_all,~] = ...
            f_lMT_vMT_dM(qin_r_opt_all,qdotin_r_opt_all);
        % Both legs
        lMTk_lr_opt_all = [lMTk_l_opt_all([1:end-6,end-2:end],1);lMTk_r_opt_all(1:end-3,1)];
        vMTk_lr_opt_all = [vMTk_l_opt_all([1:end-6,end-2:end],1);vMTk_r_opt_all(1:end-3,1)];
        % force equilibirum
        [~,~,Fce_opt_all,Fpass_opt_all,Fiso_opt_all] = ...
            f_forceEquilibrium_FtildeState_all_tendon(...
            a_col_opt_unsc(count,:)',FTtilde_col_opt_unsc(count,:)',...
            dFTtilde_col_opt_unsc(count,:)',full(lMTk_lr_opt_all),...
            full(vMTk_lr_opt_all),tensions);
        % muscle-tendon kinematics
        [~,lMtilde_opt_all] = f_FiberLength_TendonForce_tendon(...
            FTtilde_col_opt_unsc(count,:)',full(lMTk_lr_opt_all));
        [vM_opt_all,~] = f_FiberVelocity_TendonForce_tendon(...
            FTtilde_col_opt_unsc(count,:)',...
            dFTtilde_col_opt_unsc(count,:)',full(lMTk_lr_opt_all),...
            full(vMTk_lr_opt_all));
        
        % Bhargava et al. (2004)
        [e_tot_all,~,~,~,~,~] = f_getMetabolicEnergySmooth2004all(...
            a_col_opt_unsc(count,:)',a_col_opt_unsc(count,:)',...
            full(lMtilde_opt_all),...
            full(vM_opt_all),full(Fce_opt_all)',full(Fpass_opt_all)',...
            MuscleMass.MassM',pctsts,full(Fiso_opt_all)',body_mass,S.tanh_b);
        e_tot_opt_all = full(e_tot_all)';        
        
        if S.Foot.PIM
            % Left leg
            qinPF_l_opt_all = Xj_Qs_Qdots_opt(count,[jointi.mtj.l,jointi.mtp.l]*2-1);
            qdotinPF_l_opt_all = Xj_Qs_Qdots_opt(count,[jointi.mtj.l,jointi.mtp.l]*2);

            [l_PFk_l,v_PFk_l_opt_all,~] = ...
                f_lLi_vLi_dM(qinPF_l_opt_all,qdotinPF_l_opt_all);
            % Right leg
            qinPF_r_opt_all = Xj_Qs_Qdots_opt(count,[jointi.mtj.r,jointi.mtp.r]*2-1);
            qdotinPF_r_opt_all = Xj_Qs_Qdots_opt(count,[jointi.mtj.r,jointi.mtp.r]*2);
            [l_PFk_r,v_PFk_r_opt_all,~] = ...
                f_lLi_vLi_dM(qinPF_r_opt_all,qdotinPF_r_opt_all);

            % PIMs
            F_PIM_col = a_PIM_col_opt_unsc(count,:)*scaling.PIMF;
            if S.Foot.PIM == 2
                F_PIM_col(1) = F_PIM_col(1)*(0.5+0.5*tanh(100*(full(l_PFk_l)/S.Foot.PF_slack_length)-96));
                F_PIM_col(2) = F_PIM_col(2)*(0.5+0.5*tanh(100*(full(l_PFk_r)/S.Foot.PF_slack_length)-96));
            end
            P_PIM_2 = -[v_PFk_l_opt_all,v_PFk_r_opt_all].*F_PIM_col;
            
            J_2_opt = J_2_opt + B(j+1) * sum(P_PIM_2)/body_mass*h_opt;
        end
        % objective function
        J_opt = J_opt + (...
            W.E*B(j+1) * (f_J92exp(e_tot_opt_all,exp_E))/body_mass*h_opt + ...
            W.A*B(j+1) * (f_J92(a_col_opt(count,:)))*h_opt +...
            W.ArmE*B(j+1) * (f_J8(e_a_opt(k,:)))*h_opt +...
            W.passMom*B(j+1)* (f_J23(Tau_passj_J(count,:)))*h_opt + ...
            W.u*B(j+1) * (f_J92(vA_opt(k,:)))*h_opt + ...
            W.u*B(j+1) * (f_J92(dFTtilde_col_opt(count,:)))*h_opt + ...
            W.u*B(j+1) * (f_J8(qdotdot_col_opt(count,armsi)))*h_opt);
        if mtj
            J_opt = J_opt + W.Ak*B(j+1) * (f_J25(qdotdot_col_opt(count,residuals_noarmsi)))*h_opt;
            Qdotdot_cost = Qdotdot_cost + W.Ak*B(j+1)*...
                (f_J25(qdotdot_col_opt(count,residuals_noarmsi)))*h_opt;
        else
            J_opt = J_opt + W.Ak*B(j+1) * (f_J23(qdotdot_col_opt(count,residuals_noarmsi)))*h_opt;
            Qdotdot_cost = Qdotdot_cost + W.Ak*B(j+1)*...
                (f_J23(qdotdot_col_opt(count,residuals_noarmsi)))*h_opt;
        end
        if S.Foot.mtp_actuator
            J_opt = J_opt + W.Mtp*B(j+1) * (f_J2(e_mtp_opt(k,:)))*h_opt;
            Mtp_cost = Mtp_cost + W.Mtp*B(j+1)*...
                (f_J2(e_mtp_opt(k,:)))*h_opt;
        end
        if S.Foot.PIM
            J_opt = J_opt + W.PIM*B(j+1) * (f_J2(e_PIM_opt(k,:)))*h_opt;
            PIM_cost = PIM_cost + W.PIM*B(j+1)*...
                (f_J2(e_PIM_opt(k,:)))*h_opt;
        end
        

        E_cost = E_cost + W.E*B(j+1)*...
            (f_J92exp(e_tot_opt_all,exp_E))/body_mass*h_opt;
        A_cost = A_cost + W.A*B(j+1)*...
            (f_J92(a_col_opt(count,:)))*h_opt;
        Arm_cost = Arm_cost + W.ArmE*B(j+1)*...
            (f_J8(e_a_opt(k,:)))*h_opt;
        Pass_cost = Pass_cost + W.passMom*B(j+1)*...
            (f_J23(Tau_passj_J(count,:)))*h_opt;
        vA_cost = vA_cost + W.u*B(j+1)*...
            (f_J92(vA_opt(k,:)))*h_opt;
        dFTtilde_cost = dFTtilde_cost + W.u*B(j+1)*...
            (f_J92(dFTtilde_col_opt(count,:)))*h_opt;
        QdotdotArm_cost = QdotdotArm_cost + W.u*B(j+1)*...
            (f_J8(qdotdot_col_opt(count,armsi)))*h_opt;
        count = count + 1;
    end
    if isfield(S,'TrackSim') && S.TrackSim
        if S.Track.Q_ankle
            track_err = q_opt_unsc.rad(k,[jointi.ankle.l, jointi.ankle.r]) - Qref_lr(1:2,k)';
            J_opt = J_opt + W.Q_track * f_J2(track_err)*h_opt;
            Track_cost = Track_cost + W.Q_track * f_J2(track_err)*h_opt;
            if S.Track.Q_subt
                track_err = q_opt_unsc.rad(k,[jointi.subt.l, jointi.subt.r]) - Qref_lr(3:4,k)';
                J_opt = J_opt + W.Q_track * f_J2(track_err)*h_opt;
                Track_cost = Track_cost + W.Q_track * f_J2(track_err)*h_opt;
            end
        elseif S.Track.Q_subt
            track_err = q_opt_unsc.rad(k,[jointi.subt.l, jointi.subt.r]) - Qref_lr(1:2,k)';
            J_opt = J_opt + W.Q_track * f_J2(track_err)*h_opt;
            Track_cost = Track_cost + W.Q_track * f_J2(track_err)*h_opt;
        end
    end
end
J_opt = J_opt/dist_trav_opt;

if S.Foot.PIM
    P_PIM_cost = W.P_PIM*J_2_opt^2;
    J_opt = J_opt + P_PIM_cost/dist_trav_opt;
else
    P_PIM_cost = 0;
end

J_optf = full(J_opt);           Obj.J = J_optf;
E_costf = full(E_cost);         Obj.E = E_costf;
A_costf = full(A_cost);         Obj.A = A_costf;
Arm_costf = full(Arm_cost);     Obj.Arm = Arm_costf;
Mtp_costf = full(Mtp_cost);     Obj.Mtp = Mtp_costf;
PIM_costf = full(PIM_cost);     Obj.PIM = PIM_costf;
Qdotdot_costf = full(Qdotdot_cost); Obj.qdd = Qdotdot_costf;
Pass_costf = full(Pass_cost);   Obj.Pass = Pass_costf;
vA_costf = full(vA_cost);       Obj.vA = vA_costf;
dFTtilde_costf = full(dFTtilde_cost); Obj.dFTtilde = dFTtilde_costf;
QdotdotArm_costf = full(QdotdotArm_cost); Obj.qdd_arm = QdotdotArm_costf;
P_PIM_costf = full(P_PIM_cost); Obj.P_PIM = P_PIM_costf;
Track_costf = full(Track_cost); Obj.Track = Track_costf;
% assertCost should be 0
assertCost = abs(J_optf - 1/(dist_trav_opt)*(E_costf+A_costf+Arm_costf+...
    Mtp_costf+PIM_costf+Qdotdot_costf+Pass_costf+vA_costf+dFTtilde_costf+...
    QdotdotArm_costf+P_PIM_costf+Track_costf));
assertCost2 = abs(stats.iterations.obj(end) - J_optf);
if assertCost > 1*10^(-tol_ipopt)
    disp('Issue when reconstructing optimal cost wrt sum of terms')
end
if assertCost2 > 1*10^(-tol_ipopt)
    disp('Issue when reconstructing optimal cost wrt stats')
end


%% Reconstruct full gait cycle
% We reconstruct the full gait cycle from the simulated half gait cycle
% Identify heel strike
threshold = 20; % there is foot-ground contact above the threshold
if exist('HS1','var')
    clear HS1
end

% increase threshold untill you have at least on frame above the threshold
nFramesBelow= sum(GRFk_opt(:,2)<threshold);
while nFramesBelow == 0
    threshold = threshold + 1;
    nFramesBelow= sum(GRFk_opt(:,2)<threshold);
end
if threshold <100
    phase_tran_tgridi = find(GRFk_opt(:,2)<threshold,1,'last');
else
    % heelstrike is in between left and right leg simulation
    if threshold >100 && GRFk_opt(end,5)<20
        phase_tran_tgridi = find(GRFk_opt(:,2)<threshold,1,'last');
    else
        % heelstrike is on the left leg
        phase_tran_tgridi =[];
        threshold = 20;
    end
end
if ~isempty(phase_tran_tgridi)
    if phase_tran_tgridi == N
        temp_idx = find(GRFk_opt(:,2)>threshold,1,'first');
        if ~isempty(temp_idx)
            if temp_idx-1 ~= 0 && ...
                    find(GRFk_opt(temp_idx-1,2)<threshold)
                phase_tran_tgridi_t = temp_idx;
                IC1i = phase_tran_tgridi_t;
                HS1 = 'r';
            end
        else
            IC1i = phase_tran_tgridi + 1;
            HS1 = 'r';
        end
    else
        IC1i = phase_tran_tgridi + 1;
        HS1 = 'r';
    end
end
if ~exist('HS1','var')
    % Check if heel strike is on the left side
    phase_tran_tgridi = find(GRFk_opt(:,5)<threshold,1,'last');
    if phase_tran_tgridi == N
        temp_idx = find(GRFk_opt(:,5)>threshold,1,'first');
        if ~isempty(temp_idx)
            if temp_idx-1 ~= 0 && ...
                    find(GRFk_opt(temp_idx-1,5)<threshold)
                phase_tran_tgridi_t = temp_idx;
                IC1i = phase_tran_tgridi_t;
                HS1 = 'l';
            else
                IC1i = phase_tran_tgridi + 1;
                HS1 = 'l';
            end
        else
            IC1i = phase_tran_tgridi + 1;
            HS1 = 'l';
        end
    else
        IC1i = phase_tran_tgridi + 1;
        HS1 = 'l';
    end
    
    % If heel strike is in between right and left leg, it will not have
    % found it yet.
    if isempty(phase_tran_tgridi)
        phase_tran_tgridi = 1;
        IC1i = 1;
        HS1 = 'l';
    end
end


    

% GRFk_opt is at mesh points starting from k=2, we thus add 1 to IC1i
% for the states
% if phase_tran_tgridi ~= N
    IC1i_c = IC1i;
    IC1i_s = IC1i + 1;
% end

% Qs
Qs_GC = zeros(N*2,size(q_opt_unsc.deg,2));
Qs_GC(1:N-IC1i_s+1,:) = q_opt_unsc.deg(IC1i_s:end,:);
Qs_GC(N-IC1i_s+2:N-IC1i_s+1+N,QsSymA) = q_opt_unsc.deg(1:end,QsSymB);
Qs_GC(N-IC1i_s+2:N-IC1i_s+1+N,QsOpp) = -q_opt_unsc.deg(1:end,QsOpp);
Qs_GC(N-IC1i_s+2:N-IC1i_s+1+N,jointi.pelvis.tx) = ...
    q_opt_unsc.deg(1:end,jointi.pelvis.tx) + ...
    q_opt_unsc_all.deg(end,jointi.pelvis.tx);
Qs_GC(N-IC1i_s+2+N:2*N,:) = q_opt_unsc.deg(1:IC1i_s-1,:);
Qs_GC(N-IC1i_s+2+N:2*N,jointi.pelvis.tx) = ...
    q_opt_unsc.deg(1:IC1i_s-1,jointi.pelvis.tx) + ...
    2*q_opt_unsc_all.deg(end,jointi.pelvis.tx);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    Qs_GC(:,QsSymA_ptx)  = Qs_GC(:,QsSymB_ptx);
    Qs_GC(:,QsOpp)       = -Qs_GC(:,QsOpp);
end
temp_Qs_GC_pelvis_tx = Qs_GC(1,jointi.pelvis.tx);
Qs_GC(:,jointi.pelvis.tx) = Qs_GC(:,jointi.pelvis.tx)-...
    temp_Qs_GC_pelvis_tx;

% Qdots
Qdots_GC = zeros(N*2,size(Qs_GC,2));
Qdots_GC(1:N-IC1i_s+1,:) = qdot_opt_unsc.deg(IC1i_s:end,:);
Qdots_GC(N-IC1i_s+2:N-IC1i_s+1+N,QsSymA_ptx) = ...
    qdot_opt_unsc.deg(1:end,QsSymB_ptx);
Qdots_GC(N-IC1i_s+2:N-IC1i_s+1+N,QsOpp) = ...
    -qdot_opt_unsc.deg(1:end,QsOpp);
Qdots_GC(N-IC1i_s+2+N:2*N,:) = qdot_opt_unsc.deg(1:IC1i_s-1,:);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    Qdots_GC(:,QsSymA_ptx) = Qdots_GC(:,QsSymB_ptx);
    Qdots_GC(:,QsOpp) = -Qdots_GC(:,QsOpp);
end

% Qdotdots
Qdotdots_GC = zeros(N*2,size(Qs_opt,2));
Qdotdots_GC(1:N-IC1i_c+1,:) = Xk_Qdotdots_opt(IC1i_c:end,:);
Qdotdots_GC(N-IC1i_c+2:N-IC1i_c+1+N,QsSymA_ptx) = ...
    Xk_Qdotdots_opt(1:end,QsSymB_ptx);
Qdotdots_GC(N-IC1i_c+2:N-IC1i_c+1+N,QsOpp) = ...
    -Xk_Qdotdots_opt(1:end,QsOpp);
Qdotdots_GC(N-IC1i_c+2+N:2*N,:) = Xk_Qdotdots_opt(1:IC1i_c-1,:);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    Qdotdots_GC(:,QsSymA_ptx) = Qdotdots_GC(:,QsSymB_ptx);
    Qdotdots_GC(:,QsOpp) = -Qdotdots_GC(:,QsOpp);
end


% Ground reaction forces
GRFs_opt = zeros(N*2,NGRF);
GRFs_opt(1:N-IC1i_c+1,:) = GRFk_opt(IC1i_c:end,1:6);
GRFs_opt(N-IC1i_c+2:N-IC1i_c+1+N,:) = GRFk_opt(1:end,[4:6,1:3]);
GRFs_opt(N-IC1i_c+2:N-IC1i_c+1+N,[3,6]) = ...
    -GRFs_opt(N-IC1i_c+2:N-IC1i_c+1+N,[3,6]);
GRFs_opt(N-IC1i_c+2+N:2*N,:) = GRFk_opt(1:IC1i_c-1,1:6);
GRFs_opt = GRFs_opt./(body_weight/100);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    GRFs_opt(:,[4:6,1:3]) = GRFs_opt(:,:);
    GRFs_opt(:,[3,6]) = -GRFs_opt(:,[3,6]);
end

% Separate GRF
if exist('GRFk_separate_opt','var')
    GRFs_sep_opt = zeros(N*2,length(GRFi.separate));
    GRFs_sep_opt(1:N-IC1i_c+1,:) = GRFk_separate_opt(IC1i_c:end,1:end);
    GRFs_sep_opt(N-IC1i_c+2:N-IC1i_c+1+N,:) = GRFk_separate_opt(1:end,[end/2+1:end,1:end/2]);
    GRFs_sep_opt(N-IC1i_c+2:N-IC1i_c+1+N,[3:3:end]) = ...
        -GRFs_sep_opt(N-IC1i_c+2:N-IC1i_c+1+N,[3:3:end]);
    GRFs_sep_opt(N-IC1i_c+2+N:2*N,:) = GRFk_separate_opt(1:IC1i_c-1,1:end);
    GRFs_sep_opt = GRFs_sep_opt./(body_weight/100);
    % If the first heel strike was on the left foot then we invert so that
    % we always start with the right foot, for analysis purpose
    if strcmp(HS1,'l')
        GRFs_sep_opt(:,[end/2+1:end,1:end/2]) = GRFs_sep_opt(:,:);
        GRFs_sep_opt(:,[3:3:end]) = -GRFs_sep_opt(:,[3:3:end]);
    end
end

% Joint torques
Ts_opt = zeros(N*2,size(Qs_opt,2));
Ts_opt(1:N-IC1i_c+1,1:nq.all) = Foutk_opt(IC1i_c:end,1:nq.all);
Ts_opt(N-IC1i_c+2:N-IC1i_c+1+N,QsSymA_ptx) = Foutk_opt(1:end,QsSymB_ptx);
Ts_opt(N-IC1i_c+2:N-IC1i_c+1+N,QsOpp) = -Foutk_opt(1:end,QsOpp);
Ts_opt(N-IC1i_c+2+N:2*N,1:nq.all) = Foutk_opt(1:IC1i_c-1,1:nq.all);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    Ts_opt(:,QsSymA_ptx) = Ts_opt(:,QsSymB_ptx);
    Ts_opt(:,QsOpp) = -Ts_opt(:,QsOpp);
end
Ts_opt = Ts_opt./body_mass;

% Muscle-Tendon Forces
orderMusInv = [NMuscle/2+1:NMuscle,1:NMuscle/2];
FTtilde_GC = zeros(N*2,NMuscle);
FTtilde_GC(1:N-IC1i_s+1,:) = FTtilde_opt_unsc(IC1i_s:end,:);
FTtilde_GC(N-IC1i_s+2:N-IC1i_s+1+N,:) = ...
    FTtilde_opt_unsc(1:end,orderMusInv);
FTtilde_GC(N-IC1i_s+2+N:2*N,:) = FTtilde_opt_unsc(1:IC1i_s-1,:);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    FTtilde_GC(:,:) = FTtilde_GC(:,orderMusInv);
end

% Muscle activations
Acts_GC = zeros(N*2,NMuscle);
Acts_GC(1:N-IC1i_s+1,:) = a_opt_unsc(IC1i_s:end,:);
Acts_GC(N-IC1i_s+2:N-IC1i_s+1+N,:) = a_opt_unsc(1:end,orderMusInv);
Acts_GC(N-IC1i_s+2+N:2*N,:) = a_opt_unsc(1:IC1i_s-1,:);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    Acts_GC(:,:) = Acts_GC(:,orderMusInv);
end

% Time derivative of muscle-tendon force
dFTtilde_GC = zeros(N*2,NMuscle);
dFTtilde_GC(1:N-IC1i_c+1,:) = dFTtilde_opt_unsc(IC1i_c:end,:);
dFTtilde_GC(N-IC1i_c+2:N-IC1i_c+1+N,:) = ...
    dFTtilde_opt_unsc(1:end,orderMusInv);
dFTtilde_GC(N-IC1i_c+2+N:2*N,:) = dFTtilde_opt_unsc(1:IC1i_c-1,:);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    dFTtilde_GC(:,:) = dFTtilde_GC(:,orderMusInv);
end

% Muscle excitations
vA_GC = zeros(N*2,NMuscle);
vA_GC(1:N-IC1i_c+1,:) = vA_opt_unsc(IC1i_c:end,:);
vA_GC(N-IC1i_c+2:N-IC1i_c+1+N,:) = vA_opt_unsc(1:end,orderMusInv);
vA_GC(N-IC1i_c+2+N:2*N,:) = vA_opt_unsc(1:IC1i_c-1,:);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    vA_GC(:,:) = vA_GC(:,orderMusInv);
end
e_GC = computeExcitationRaasch(Acts_GC,vA_GC,...
    ones(1,NMuscle)*tdeact,ones(1,NMuscle)*tact);

% Arm activations
orderArmInv = [jointi.sh_flex.r:jointi.sh_rot.r,...
    jointi.sh_flex.l:jointi.sh_rot.l,...
    jointi.elb.r,jointi.elb.l]-jointi.sh_flex.l+1;
a_a_GC = zeros(N*2,nq.arms);
a_a_GC(1:N-IC1i_s+1,:) = a_a_opt_unsc(IC1i_s:end,:);
a_a_GC(N-IC1i_s+2:N-IC1i_s+1+N,:) = a_a_opt_unsc(1:end,orderArmInv);
a_a_GC(N-IC1i_s+2+N:2*N,:) = a_a_opt_unsc(1:IC1i_s-1,:);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    a_a_GC(:,:) = a_a_GC(:,orderArmInv);
end

if S.Foot.mtp_actuator
    % Mtp activations
    orderMtpInv = [jointi.mtp.r,jointi.mtp.l]-jointi.mtp.l+1;
    a_mtp_GC = zeros(N*2,2);
    a_mtp_GC(1:N-IC1i_s+1,:) = a_mtp_opt_unsc(IC1i_s:end,:);
    a_mtp_GC(N-IC1i_s+2:N-IC1i_s+1+N,:) = a_mtp_opt_unsc(1:end,orderMtpInv);
    a_mtp_GC(N-IC1i_s+2+N:2*N,:) = a_mtp_opt_unsc(1:IC1i_s-1,:);
    % If the first heel strike was on the left foot then we invert so that
    % we always start with the right foot, for analysis purpose
    if strcmp(HS1,'l')
        a_mtp_GC(:,:) = a_mtp_GC(:,orderMtpInv);
    end
    % Mtp excitations
    e_mtp_GC = zeros(N*2,2);
    e_mtp_GC(1:N-IC1i_c+1,:) = e_mtp_opt_unsc(IC1i_c:end,:);
    e_mtp_GC(N-IC1i_c+2:N-IC1i_c+1+N,:) = e_mtp_opt_unsc(1:end,orderMtpInv);
    e_mtp_GC(N-IC1i_c+2+N:2*N,:) = e_mtp_opt_unsc(1:IC1i_c-1,:);
    % If the first heel strike was on the left foot then we invert so that
    % we always start with the right foot, for analysis purpose
    if strcmp(HS1,'l')
        e_mtp_GC(:,:) = e_mtp_GC(:,orderMtpInv);
    end
end

if S.Foot.PIM
    % PIM activations
    orderPIMInv = [2,1];
    a_PIM_GC = zeros(N*2,2);
    a_PIM_GC(1:N-IC1i_s+1,:) = a_PIM_opt_unsc(IC1i_s:end,:);
    a_PIM_GC(N-IC1i_s+2:N-IC1i_s+1+N,:) = a_PIM_opt_unsc(1:end,orderPIMInv);
    a_PIM_GC(N-IC1i_s+2+N:2*N,:) = a_PIM_opt_unsc(1:IC1i_s-1,:);
    % If the first heel strike was on the left foot then we invert so that
    % we always start with the right foot, for analysis purpose
    if strcmp(HS1,'l')
        a_PIM_GC(:,:) = a_PIM_GC(:,orderPIMInv);
    end
    % PIM excitations
    e_PIM_GC = zeros(N*2,2);
    e_PIM_GC(1:N-IC1i_c+1,:) = e_PIM_opt_unsc(IC1i_c:end,:);
    e_PIM_GC(N-IC1i_c+2:N-IC1i_c+1+N,:) = e_PIM_opt_unsc(1:end,orderPIMInv);
    e_PIM_GC(N-IC1i_c+2+N:2*N,:) = e_PIM_opt_unsc(1:IC1i_c-1,:);
    % If the first heel strike was on the left foot then we invert so that
    % we always start with the right foot, for analysis purpose
    if strcmp(HS1,'l')
        e_PIM_GC(:,:) = e_PIM_GC(:,orderPIMInv);
    end
end

% Arm excitations
e_a_GC = zeros(N*2,nq.arms);
e_a_GC(1:N-IC1i_c+1,:) = e_a_opt_unsc(IC1i_c:end,:);
e_a_GC(N-IC1i_c+2:N-IC1i_c+1+N,:) = e_a_opt_unsc(1:end,orderArmInv);
e_a_GC(N-IC1i_c+2+N:2*N,:) = e_a_opt_unsc(1:IC1i_c-1,:);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    e_a_GC(:,:) = e_a_GC(:,orderArmInv);
end


% Passive joint torques
if mtj
    Tau_pass_opt_inv = [jointi.hip_flex.r:jointi.hip_rot.r,...
        jointi.hip_flex.l:jointi.hip_rot.l,...
        jointi.knee.r,jointi.knee.l,jointi.ankle.r,jointi.ankle.l,...
        jointi.subt.r,jointi.subt.l,jointi.mtj.r,jointi.mtj.l,jointi.mtp.r,jointi.mtp.l,...
        jointi.trunk.ext:jointi.trunk.rot,...
        jointi.sh_flex.r:jointi.sh_rot.r,...
        jointi.sh_flex.l:jointi.sh_rot.l,...
        jointi.elb.r,jointi.elb.l]-jointi.hip_flex.l+1;
else
    Tau_pass_opt_inv = [jointi.hip_flex.r:jointi.hip_rot.r,...
        jointi.hip_flex.l:jointi.hip_rot.l,...
        jointi.knee.r,jointi.knee.l,jointi.ankle.r,jointi.ankle.l,...
        jointi.subt.r,jointi.subt.l,jointi.mtp.r,jointi.mtp.l,...
        jointi.trunk.ext:jointi.trunk.rot,...
        jointi.sh_flex.r:jointi.sh_rot.r,...
        jointi.sh_flex.l:jointi.sh_rot.l,...
        jointi.elb.r,jointi.elb.l]-jointi.hip_flex.l+1;
end
Tau_pass_opt_GC = zeros(N*2,nq.all-nq.abs);
Tau_pass_opt_GC(1:N-IC1i_c+1,:) = Tau_passk_opt_all(IC1i_c:end,:);
Tau_pass_opt_GC(N-IC1i_c+2:N-IC1i_c+1+N,:) = ...
    Tau_passk_opt_all(1:end,Tau_pass_opt_inv);
Tau_pass_opt_GC(N-IC1i_c+2+N:2*N,:) = Tau_passk_opt_all(1:IC1i_c-1,:);
% If the first heel strike was on the left foot then we invert so that
% we always start with the right foot, for analysis purpose
if strcmp(HS1,'l')
    Tau_pass_opt_GC(:,Tau_pass_opt_inv) = Tau_pass_opt_GC(:,:);
end

if isfield(S.Foot,'PF_sf_var') && length(S.Foot.PF_sf_var)==2*N
    PF_sf_var(:,1) = horzcat(S.Foot.PF_sf_var(1:N));
    PF_sf_var(:,2) = horzcat(S.Foot.PF_sf_var(N+1:end));
    PF_sf_var_GC = zeros(2*N,2);
    PF_sf_var_GC(1:N-IC1i_c+1,:) = PF_sf_var(IC1i_c:end,:);
    PF_sf_var_GC(N-IC1i_c+2:N-IC1i_c+1+N,:) = PF_sf_var(1:end,[2,1]);
    PF_sf_var_GC(N-IC1i_c+2+N:2*N,:) = PF_sf_var(1:IC1i_c-1,:);

    % If the first heel strike was on the left foot then we invert so that
    % we always start with the right foot, for analysis purpose
    if strcmp(HS1,'l')
        PF_sf_var_GC(:,[2,1]) = PF_sf_var_GC(:,:);
    end
else
    PF_sf_var_GC = ones(2*N,2)*S.Foot.PF_sf;
end


% Create .mot file for OpenSim GUI
q_opt_GUI_GC = zeros(2*N,1+nq.all+2);
q_opt_GUI_GC(1:N-IC1i_s+1,1) = tgrid(:,IC1i_s:end-1)';
q_opt_GUI_GC(N-IC1i_s+2:N-IC1i_s+1+N,1)  = tgrid(:,1:end-1)' + tgrid(end);
q_opt_GUI_GC(N-IC1i_s+2+N:2*N,1) = tgrid(:,1:IC1i_s-1)' + 2*tgrid(end);
q_opt_GUI_GC(:,2:end-2) = Qs_GC;
q_opt_GUI_GC(:,end-1:end) = 1.51*180/pi*ones(2*N,2); % pro_sup (locked)
q_opt_GUI_GC(:,1) = q_opt_GUI_GC(:,1)-q_opt_GUI_GC(1,1);
if writeIKmotion
    pathOpenSim = [pathRepo,'/OpenSim'];
    addpath(genpath(pathOpenSim));
    JointAngle.labels = [{'time'},joints,{'pro_sup_l'},{'pro_sup_r'}];
    % Two gait cycles
    % Joint angles
    q_opt_GUI_GC_2 = [q_opt_GUI_GC;q_opt_GUI_GC];
    q_opt_GUI_GC_2(2*N+1:4*N,1) = q_opt_GUI_GC_2(2*N+1:4*N,1) + ...
        q_opt_GUI_GC_2(end,1) + ...
        q_opt_GUI_GC_2(end,1)-q_opt_GUI_GC_2(end-1,1);
    q_opt_GUI_GC_2(2*N+1:4*N,jointi.pelvis.tx+1) = ...
        q_opt_GUI_GC_2(2*N+1:4*N,jointi.pelvis.tx+1) + ...
        2*q_opt_unsc_all.deg(end,jointi.pelvis.tx);
    % Muscle activations (to have muscles turning red when activated).
    Acts_GC_GUI = [Acts_GC;Acts_GC];
    % Combine data joint angles and muscle activations
    JointAngleMuscleAct.data = [q_opt_GUI_GC_2,Acts_GC_GUI];
    % Get muscle labels
    muscleNamesAll = cell(1,NMuscle);
    for i = 1:NMuscle/2
        muscleNamesAll{i} = [muscleNames{i}(1:end-2),'_l'];
        muscleNamesAll{i+NMuscle/2} = [muscleNames{i}(1:end-2),'_r'];
    end
    % Combine labels joint angles and muscle activations
    JointAngleMuscleAct.labels = JointAngle.labels;
    for i = 1:NMuscle
        JointAngleMuscleAct.labels{i+size(q_opt_GUI_GC_2,2)} = ...
            [muscleNamesAll{i},'/activation'];
    end
%     OutFolder = fullfile(pathRepo,'Results',S.ResultsFolder);
    filenameJointAngles = fullfile(OutFolder,[S.savename '.mot']);
    write_motionFile(JointAngleMuscleAct, filenameJointAngles);
end


if isfield(IO,'GRMs') || isfield(IO,'P_contact_deformation_y')
    % compute COP information
    nfr = length(Qs_GC(:,1));
    qdqdd = zeros(nfr,nq.all*2);
    qdqdd(:,1:2:nq.all*2) = Qs_GC;
    qdqdd(:,2:2:nq.all*2) = Qdots_GC;
    qdd = Qdotdots_GC;
    qdqdd(:,[roti*2-1,roti*2]) = qdqdd(:,[roti*2-1,roti*2])*pi./180;        
%     qdqdd(:,11) = qdqdd(:,11);
    COPR = zeros(nfr,3);    FR = zeros(nfr,3);  MR = zeros(nfr,3);
    COPL = zeros(nfr,3);    FL = zeros(nfr,3);  ML = zeros(nfr,3);  
    
    P_HC_c_r = zeros(nfr,1);
    P_HC_m_r = zeros(nfr,1);
    P_HC_t_r = zeros(nfr,1);
    P_HC_c_l = zeros(nfr,1);
    P_HC_m_l = zeros(nfr,1);
    P_HC_t_l = zeros(nfr,1);

    l_fa_ext = zeros(nfr,1);
    h_fa_ext = zeros(nfr,1);
    
    for ind = 1:nfr
        res = full(F([qdqdd(ind,:)'; qdd(ind,:)']));
        if isfield(IO,'GRMs')
            % compute the COP position
            FR(ind,:) = res(GRFi.r);
            FL(ind,:) = res(GRFi.l);
            MR(ind,:) = res(GRFTi.r);
            ML(ind,:) = res(GRFTi.l);
            if abs(FR(ind,2)) > 10
                COPR(ind,:) = [MR(ind,3)./FR(ind,2), 0, -MR(ind,1)./FR(ind,2)];
            end
            if abs(FL(ind,2)) > 10
                COPL(ind,:) = [ML(ind,3)./FL(ind,2), 0, -ML(ind,1)./FL(ind,2)];
            end
        end

        if isfield(IO,'P_contact_deformation_y')
            P_HC_c_r(ind) = sum(res(P_HCi.calcn.r));
            P_HC_m_r(ind) = sum(res(P_HCi.metatarsi.r));
            P_HC_t_r(ind) = sum(res(P_HCi.toes.r));
            P_HC_c_l(ind) = sum(res(P_HCi.calcn.l));
            P_HC_m_l(ind) = sum(res(P_HCi.metatarsi.l));
            P_HC_t_l(ind) = sum(res(P_HCi.toes.l));
        end

        if mtj
            toes_or = res(toesOrall.r);
            calcn_or = res(calcOrall.r);
            midfoot_or = res(midfootOrall.r);
    
            % calculate arch length
            l_fa_ext(ind) = norm(squeeze(toes_or-calcn_or));
    
            % calculate arch height (orthogonal decomposition)
            vec_a = squeeze(midfoot_or - toes_or); % mtpj to tmtj/mtj
            vec_b = squeeze(calcn_or - toes_or); % mtpj to heel
            vec_ap = dot(vec_a,vec_b)/dot(vec_b,vec_b)*vec_b; % orthogonal projection of a onto b
            vec_an = vec_a - vec_ap; % component of a that is normal to b 
    
            h_fa_ext(ind) = abs(norm(vec_an));
        end
    end
    

    P_mech_contact.vertical.calcn.r = P_HC_c_r;
    P_mech_contact.vertical.metatarsi.r = P_HC_m_r;
    P_mech_contact.vertical.toes.r = P_HC_t_r;
    P_mech_contact.vertical.calcn.l = P_HC_c_l;
    P_mech_contact.vertical.metatarsi.l = P_HC_m_l;
    P_mech_contact.vertical.toes.l = P_HC_t_l;

    
end

%% Metabolic cost of transport for a gait cycle
Qs_opt_rad = Qs_GC;
Qs_opt_rad(:,roti) = Qs_opt_rad(:,roti).*pi/180;
qdot_opt_GC_rad = Qdots_GC;
qdot_opt_GC_rad(:,roti)= qdot_opt_GC_rad(:,roti).*pi/180;
% Pre-allocations
e_mo_opt = zeros(2*N,1);
e_mo_optb = zeros(2*N,1);
vMtilde_opt_all = zeros(2*N, NMuscle);
lMtilde_opt_all = zeros(2*N, NMuscle);
vT_opt_all = zeros(2*N, NMuscle);
lT_opt_all = zeros(2*N, NMuscle);
metab_Etot  = zeros(2*N, NMuscle);
metab_Adot  = zeros(2*N, NMuscle);
metab_Mdot  = zeros(2*N, NMuscle);
metab_Sdot  = zeros(2*N, NMuscle);
metab_Wdot  = zeros(2*N, NMuscle);
FT_opt      = zeros(2*N, NMuscle);
lMT_Vect    = zeros(2*N, NMuscle);
vMT_Vect    = zeros(2*N, NMuscle);
dM_Vect     = zeros(2*N, NMuscle,nq.leg);
Fce_opt     = zeros(2*N, NMuscle);
vM_Vect     = zeros(2*N, NMuscle);
Fpass_opt   = zeros(2*N, NMuscle);

metab_Bargh2004  = zeros(2*N,1);  metab_Bargh2004B  = zeros(2*N,1);
metab_Umb2003  = zeros(2*N,1);    metab_Umb2003B  = zeros(2*N,1);
metab_Umb2010  = zeros(2*N,1);    metab_Umb2010B  = zeros(2*N,1);
metab_Uchida2016 = zeros(2*N,1);  metab_Uchida2016B  = zeros(2*N,1);
metab_Umb2010_h1 = zeros(2*N,1);  metab_Umb2010_h1B = zeros(2*N,1);
metab_Umb2010_neg = zeros(2*N,1); metab_Umb2010_negB = zeros(2*N,1);
metab_Marg1968 = zeros(2*N, NMuscle);

for nn = 1:2*N
    % Get muscle-tendon lengths, velocities, moment arms
    % Left leg
    qin_l_opt = Qs_opt_rad(nn,IndexLeft);
    qdotin_l_opt = qdot_opt_GC_rad(nn,IndexLeft);
    [lMTk_l_opt,vMTk_l_opt,dM_l] = f_lMT_vMT_dM(qin_l_opt,qdotin_l_opt);
    % Right leg
    qin_r_opt = Qs_opt_rad(nn,IndexRight);
    qdotin_r_opt = qdot_opt_GC_rad(nn,IndexRight);
    [lMTk_r_opt,vMTk_r_opt,dM_r] = f_lMT_vMT_dM(qin_r_opt,qdotin_r_opt);
    % Both legs
    lMTk_lr_opt     = [lMTk_l_opt([1:end-6,end-2:end],1);lMTk_r_opt(1:end-3,1)];
    vMTk_lr_opt     = [vMTk_l_opt([1:end-6,end-2:end],1);vMTk_r_opt(1:end-3,1)];
    dM_lr_opt       = [dM_l([1:end-6,end-2:end],:); dM_r(1:end-3,:)];
    % force equilibrium
    [~,FT_optt,Fce_optt,Fpass_optt,Fiso_optt] =...
        f_forceEquilibrium_FtildeState_all_tendon(...
        Acts_GC(nn,:)',FTtilde_GC(nn,:)',dFTtilde_GC(nn,:)',full(lMTk_lr_opt),...
        full(vMTk_lr_opt),tensions);
    % fiber kinematics
    [~,lMtilde_opt] = f_FiberLength_TendonForce_tendon(...
        FTtilde_GC(nn,:)',full(lMTk_lr_opt));
    lMtilde_opt_all(nn,:) = full(lMtilde_opt)';
    [vM_opt,vMtilde_opt] = f_FiberVelocity_TendonForce_tendon(FTtilde_GC(nn,:)',...
        dFTtilde_GC(nn,:)',full(lMTk_lr_opt),full(vMTk_lr_opt));
    vMtilde_opt_all(nn,:) = full(vMtilde_opt)';
    % tendon kinematics
    [lT_opt,vT_opt] = f_lT_vT(FTtilde_GC(nn,:)',...
        dFTtilde_GC(nn,:)',full(lMTk_lr_opt),full(vMTk_lr_opt));
    lT_opt_all(nn,:) = full(lT_opt)';
    vT_opt_all(nn,:) = full(vT_opt)';
    
    % Bhargava et al. (2004)
    [energy_total,Adot,Mdot,Sdot,Wdot,eBargh] = ...
        f_getMetabolicEnergySmooth2004all(Acts_GC(nn,:)',...
        Acts_GC(nn,:)',full(lMtilde_opt),full(vM_opt),...
        full(Fce_optt),full(Fpass_optt),MuscleMass.MassM',pctsts,...
        full(Fiso_optt)',body_mass,1e9);

    [~,~,~,~,~,eBarghb] = ...
        f_getMetabolicEnergySmooth2004all(Acts_GC(nn,:)',...
        Acts_GC(nn,:)',full(lMtilde_opt),full(vM_opt),...
        full(Fce_optt),full(Fpass_optt),MuscleMass.MassM',pctsts,...
        full(Fiso_optt)',body_mass,S.tanh_b);

    
%     % Umberger 2003
%     vMtildeUmbk_opt = full(vM_opt)./(MTparameters_m(2,:)');
%     [eUmb2003,~,~,~,eUmb2003B] = fgetMetabolicEnergySmooth2003all(...
%         Acts_GC(nn,:)',Acts_GC(nn,:)',full(lMtilde_opt),...
%         vMtildeUmbk_opt,full(vM_opt),full(Fce_optt)',...
%         MuscleMass.MassM',pctsts,10,...
%         full(Fiso_optt)',body_mass,10);
%     
%     % Umberger 2010
%     [eUmb2010,~,~,~,eUmb2010B] = fgetMetabolicEnergySmooth2010all(...
%         Acts_GC(nn,:)',Acts_GC(nn,:)',full(lMtilde_opt),...
%         vMtildeUmbk_opt,full(vM_opt),full(Fce_optt)',...
%         MuscleMass.MassM',pctsts,10,...
%         full(Fiso_optt)',body_mass,10);
%     
%     % Uchida et al. (2016)
%     [eUchida2016,~,~,~,eUchida2016B] = fgetMetabolicEnergySmooth2016all(...
%         Acts_GC(nn,:)',Acts_GC(nn,:)',full(lMtilde_opt),...
%         vMtildeUmbk_opt,full(vM_opt),full(Fce_optt)',...
%         MuscleMass.MassM',pctsts,10,...
%         full(Fiso_optt)',body_mass,10);
%     
%     % Umberger (2010) treating muscle lengthening
%     % heat rate as Umberger et al. (2003)
%     % vMtilde defined for this model as vM/lMopt
%     [eUmb2010_h1,~,~,~,eUmb2010_h1B] = fgetMetabolicEnergySmooth2010all_hl(...
%         Acts_GC(nn,:)',Acts_GC(nn,:)',full(lMtilde_opt),...
%         vMtildeUmbk_opt,full(vM_opt),full(Fce_optt)',...
%         MuscleMass.MassM',pctsts,10,...
%         full(Fiso_optt)',body_mass,10);
%     
%     % Umberger (2010) treating negative mechanical
%     % work as Umberger et al. (2003)
%     % vMtilde defined for this model as vM/lMopt
%     [eUmb2010_neg,~,~,~,eUmb2010_negB] = fgetMetabolicEnergySmooth2010all_neg(...
%         Acts_GC(nn,:)',Acts_GC(nn,:)',full(lMtilde_opt),...
%         vMtildeUmbk_opt,full(vM_opt),full(Fce_optt)',...
%         MuscleMass.MassM',pctsts,10,...
%         full(Fiso_optt)',body_mass,10);
%     
%     % Margaria 1968
%     eMarg1968 = fgetMetabolicEnergy_MargariaSmooth(full(Fce_optt)',full(vM_opt)');    
    
    % store results
    e_mo_opt(nn) = full(eBargh)';
    e_mo_optb(nn) = full(eBarghb)';
    metab_Etot(nn,:) = full(energy_total)';
    metab_Adot(nn,:) = full(Adot)';
    metab_Mdot(nn,:) = full(Mdot)';
    metab_Sdot(nn,:) = full(Sdot)';
    metab_Wdot(nn,:) = full(Wdot)';
    FT_opt(nn,:)     = full(FT_optt)';
    Fce_opt(nn,:)    = full(Fce_optt)';
    
    lMT_Vect(nn,:)  = full(lMTk_lr_opt);
    vMT_Vect(nn,:)  = full(vMTk_lr_opt);
    dM_Vect(nn,:,:) = full(dM_lr_opt);
    vM_Vect(nn,:)   = full(vM_opt)';
    Fpass_opt(nn,:) = full(Fpass_optt)';
    
%     metab_Bargh2004(nn)   = full(sum(energy_total));
%     metab_Umb2003(nn)     = full(sum(eUmb2003));
%     metab_Umb2010(nn)     = full(sum(eUmb2010));
%     metab_Uchida2016(nn)  = full(sum(eUchida2016));
%     metab_Umb2010_h1(nn)  = full(sum(eUmb2010_h1));
%     metab_Umb2010_neg(nn) = full(sum(eUmb2010_neg));
%     metab_Bargh2004B(nn)   = full(eBargh);
%     metab_Umb2003B(nn)     = full(eUmb2003B);
%     metab_Umb2010B(nn)     = full(eUmb2010B);
%     metab_Uchida2016B(nn)  = full(eUchida2016B);
%     metab_Umb2010_h1B(nn)  = full(eUmb2010_h1B);
%     metab_Umb2010_negB(nn) = full(eUmb2010_negB);
%     metab_Marg1968(nn,:)    = full(eMarg1968);
    
end
% Get COT
dist_trav_opt_GC = Qs_opt_rad(end,jointi.pelvis.tx) - ...
    Qs_opt_rad(1,jointi.pelvis.tx); % distance traveled
time_GC = q_opt_GUI_GC(:,1);
e_mo_opt_trb = trapz(time_GC,e_mo_opt);
e_mo_opt_trb_b = trapz(time_GC,e_mo_optb);
% Cost of transport: J/kg/m
% Energy model from Bhargava et al. (2004)
COT_GC = e_mo_opt_trb/body_mass/dist_trav_opt_GC;
COT_GCb = e_mo_opt_trb_b/body_mass/dist_trav_opt_GC;

% % COT for all models
% COTv.Bargh2004 = trapz(time_GC,metab_Bargh2004)/body_mass/dist_trav_opt_GC;
% COTv.Umb2003 = trapz(time_GC,metab_Umb2003)/body_mass/dist_trav_opt_GC;
% COTv.Umb2010 = trapz(time_GC,metab_Umb2010)/body_mass/dist_trav_opt_GC;
% COTv.Uchida2016 = trapz(time_GC,metab_Uchida2016)/body_mass/dist_trav_opt_GC;
% COTv.Umb2010_h1 = trapz(time_GC,metab_Umb2010_h1)/body_mass/dist_trav_opt_GC;
% COTv.Umb2010_neg = trapz(time_GC,metab_Umb2010_neg)/body_mass/dist_trav_opt_GC;
% COTv.Marg1968 = sum(trapz(time_GC,metab_Marg1968))/body_mass/dist_trav_opt_GC;
% 
% % COT for all models (with basal Rate
% COTvB.Bargh2004 = trapz(time_GC,metab_Bargh2004B)/body_mass/dist_trav_opt_GC;
% COTvB.Umb2003 = trapz(time_GC,metab_Umb2003B)/body_mass/dist_trav_opt_GC;
% COTvB.Umb2010 = trapz(time_GC,metab_Umb2010B)/body_mass/dist_trav_opt_GC;
% COTvB.Uchida2016 = trapz(time_GC,metab_Uchida2016B)/body_mass/dist_trav_opt_GC;
% COTvB.Umb2010_h1 = trapz(time_GC,metab_Umb2010_h1B)/body_mass/dist_trav_opt_GC;
% COTvB.Umb2010_neg = trapz(time_GC,metab_Umb2010_negB)/body_mass/dist_trav_opt_GC;
% COTvB.Marg1968 = sum(trapz(time_GC,metab_Marg1968))/body_mass/dist_trav_opt_GC;

% % Store Energy
% EnergyV.Bargh2004       = metab_Bargh2004;
% EnergyV.Umb2003         = metab_Umb2003;
% EnergyV.Umb2010         = metab_Umb2010;
% EnergyV.Uchida2016      = metab_Uchida2016;
% EnergyV.Umb2010_h1      = metab_Umb2010_h1;
% EnergyV.Umb2010_neg     = metab_Umb2010_neg;
% EnergyV.Marg1968        = metab_Marg1968;
% 
% % Store Energy (with basal rate)
% EnergyVB.Bargh2004       = metab_Bargh2004B;
% EnergyVB.Umb2003         = metab_Umb2003B;
% EnergyVB.Umb2010         = metab_Umb2010B;
% EnergyVB.Uchida2016      = metab_Uchida2016B;
% EnergyVB.Umb2010_h1      = metab_Umb2010_h1B;
% EnergyVB.Umb2010_neg     = metab_Umb2010_negB;
% EnergyVB.Marg1968        = metab_Marg1968;

%% subtract energy cost of standing in the computations of COT
% Note: this is de default method in pulmonary gas exchange papers.

% MetabStandingFile =  fullfile(pathRepo,'StaticStanding','MetabRate_Standing_s1_Poggensee.mat');
% if exist(MetabStandingFile,'file')
%     Rstanding           = load(MetabStandingFile);
%     COTrel.Bargh2004	= trapz(time_GC,(metab_Bargh2004 - Rstanding.Edot.Bargh2004))/body_mass/dist_trav_opt_GC;
%     COTrel.Umb2003      = trapz(time_GC,(metab_Umb2003 - Rstanding.Edot.eUmb2003))/body_mass/dist_trav_opt_GC;
%     COTrel.Umb2010      = trapz(time_GC,(metab_Umb2010 - Rstanding.Edot.eUmb2010))/body_mass/dist_trav_opt_GC;
%     COTrel.Uchida2016   = trapz(time_GC,(metab_Uchida2016 - Rstanding.Edot.eUchida2016))/body_mass/dist_trav_opt_GC;
%     COTrel.Umb2010_h1   = trapz(time_GC,(metab_Umb2010_h1 - Rstanding.Edot.eUmb2010_h1))/body_mass/dist_trav_opt_GC;
%     COTrel.Umb2010_neg  = trapz(time_GC,(metab_Umb2010_neg - Rstanding.Edot.eUmb2010_neg))/body_mass/dist_trav_opt_GC;
%     COTrel.Marg1968     = sum(trapz(time_GC,metab_Marg1968 - Rstanding.Edot.eMarg1968))/body_mass/dist_trav_opt_GC;
% else
%     COTrel.Bargh2004	= [];
%     COTrel.Umb2003      = [];
%     COTrel.Umb2010      = [];
%     COTrel.Uchida2016   = [];
%     COTrel.Umb2010_h1   = [];
%     COTrel.Umb2010_neg  = [];
%     COTrel.Marg1968     = [];
% end
    

%% Analyse windlass mechanism
if mtj

    M_li = f_passiveMoment_mtj(Qs_GC(:,jointi.mtj.r)*pi/180,Qs_GC(:,jointi.mtj.r)*pi/180);
    windlass.M_li = full(M_li);

    if ~strcmp(S.Foot.PF_stiffness,'none') || S.Foot.PIM
        for i=1:N*2
            [l_PFi,v_PFi,MA_PFi] =  f_lLi_vLi_dM(Qs_GC(i,[jointi.mtj.r,jointi.mtp.r])*pi/180,...
                Qdots_GC(i,[jointi.mtj.r,jointi.mtp.r])*pi/180);
            l_PF(i) = full(l_PFi);
            v_PF(i) = full(v_PFi);
            MA_PF_2(i,:) = full(MA_PFi);
        end
        MA_PF.mtj = MA_PF_2(:,1);
        MA_PF.mtp = MA_PF_2(:,2);
        windlass.MA_PF = MA_PF;
        windlass.l_PF = l_PF';
        windlass.v_PF = v_PF';
    end

    if S.Foot.PIM
        F_PIM = a_PIM_GC*scaling.PIMF;
        if S.Foot.PIM == 2
            F_PIM = F_PIM.*(0.5+0.5*tanh(100*(l_PF'/S.Foot.PF_slack_length)-96));
        end
        windlass.F_PIM = F_PIM;
    end
    
    if ~strcmp(S.Foot.PF_stiffness,'none')
        F_PF = f_PF_stiffness(l_PF).*PF_sf_var_GC(:,1)';
        windlass.F_PF = full(F_PF');
        windlass.sf_PF = PF_sf_var_GC;
    end
    
%     windlass.l_fa = l_fa;
%     windlass.h_fa = h_fa;
%     windlass.L0 = L0;
%     windlass.H0 = H0;

end

%% Save results
% Structure Results_all
R.t_step    = tgrid;
R.tf_step   = tgrid(end);
R.t         = q_opt_GUI_GC(:,1);
R.tend      = q_opt_GUI_GC(end,1) - q_opt_GUI_GC(1,1);
R.Qs        = Qs_GC;
R.Qdots     = Qdots_GC;
R.Qddots    = Qdotdots_GC;
R.GRFs      = GRFs_opt;
if exist('GRFs_sep_opt','var')
    R.GRFs_separate = GRFs_sep_opt;
end
R.Ts        = Ts_opt;
R.Tid       = Ts_opt.*body_mass;
R.a         = Acts_GC;
R.e         = e_GC;
R.COT       = COT_GC;
R.COT_smoothed = COT_GCb;
R.StrideLength = StrideLength_opt;
R.StepWidth = stride_width_mean;
R.vMtilde   = vMtilde_opt_all;
R.lMtilde   = lMtilde_opt_all;
R.MetabB.Etot = metab_Etot;
R.MetabB.Adot = metab_Adot;
R.MetabB.Mdot = metab_Mdot;
R.MetabB.Sdot = metab_Sdot;
R.MetabB.Wdot = metab_Wdot;
R.S           = S;  % settings for post processing
R.Sopt        = Sopt; % original settings used to solve the OCP
R.body_mass   = body_mass;
R.a_arm       = a_a_GC;
R.e_arm       = e_a_GC;
if S.Foot.mtp_actuator
    R.a_mtp       = a_mtp_GC;
    R.e_mtp       = e_mtp_GC;
end
if S.Foot.PIM
    R.a_PIM       = a_PIM_GC;
    R.e_PIM       = e_PIM_GC;
end
R.FT          = FT_opt;
R.TPass       = Tau_pass_opt_GC;
R.dt          = nanmean(diff(R.t));
R.Obj         = Obj;
R.lMT         = lMT_Vect;
R.vMT         = vMT_Vect;
R.lT          = lT_opt_all;
R.vT          = vT_opt_all;
R.dM          = dM_Vect;
R.FTtilde     = FTtilde_GC;
R.dFTtilde    = dFTtilde_GC;
R.Muscle.Fce  = Fce_opt;
R.Muscle.vM   = vM_Vect;
R.Muscle.Fpas = Fpass_opt;
R.Muscle.FT   = FT_opt;
R.COPL = COPL;
R.COPR = COPR; 

if exist('windlass','var')
    windlass.foot_arch_height  = h_fa_ext;
    windlass.foot_arch_length  = l_fa_ext;

    R.windlass = windlass;
end

R.P_mech_contact = P_mech_contact;


% header information
R.colheaders.joints = joints;
R.colheaders.GRF = {'fore_aft_r','vertical_r',...
    'lateral_r','fore_aft_l','vertical_l','lateral_l'};
for i = 1:NMuscle/2
    R.colheaders.muscles{i} = ...
        [muscleNames{i}(1:end-2),'_l'];
    R.colheaders.muscles{i+NMuscle/2} = ...
        [muscleNames{i}(1:end-2),'_r'];
end
R.colheaders.dM = MuscleData.dof_names;

%% Additional outcomes

% percentage stance and swing phase
[R.Event.Stance, R.Event.Swing, R.Event.DS] = GetPercentageStance(R.GRFs(:,[2 5]).*body_weight/100,30);


% Stepwidth
if isfield(R,'COPL') && isfield(R,'COPR')
    % compute average positin during left stance
    COPR_mean = nanmean(R.COPR(R.GRFs(:,2).*body_weight/100>30,3));
    COPL_mean = nanmean(R.COPL(R.GRFs(:,5).*body_weight/100>30,3));
    % stepwidth
    R.StepWidth_COP = abs(COPR_mean-COPL_mean);
end
%% Save data
% script information
R.info.script = 'f_LoadSim_Gait92_FootModel.m';
% Save data
% OutFolder = fullfile(pathRepo,'Results',S.ResultsFolder);
FilenameAnalysis = fullfile(OutFolder,[S.savename '_pp.mat']);
save(FilenameAnalysis,'R');

end

