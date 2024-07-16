function [] = f_PredSim_Gait92_FootModel(S)
% This is an adaptation to f_PredSim_Gait92, to possibly include the midtarsal
% joint, and the Plantar Intrinsic Muscles.


%% Adding the casadi path seems to be needed to run processes in batch
AddCasadiPaths();

%% User inputs (typical settings structure)
% settings for optimization
N           = S.N;          % number of mesh intervals
W           = S.W;          % weights optimization

if contains(S.Foot.Model,'mtj')
    mtj = 1;
else
    mtj = 0;
end

%% Load external function
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
[~,C,D,B] = CollocationScheme(d,method);

%% Muscle information
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
if nq.PF
    f_lLi_vLi_dM = Function.load(fullfile(PathDefaultFunc,'f_lLi_vLi_dM'));
end


try
    f_forceEquilibrium_FtildeState_all_tendon = Function.load(fullfile(PathDefaultFunc,'f_forceEquilibrium_FtildeState_all_tendon'));
    f_FiberLength_TendonForce_tendon = Function.load(fullfile(PathDefaultFunc,'f_FiberLength_TendonForce_tendon'));
    f_FiberVelocity_TendonForce_tendon = Function.load(fullfile(PathDefaultFunc,'f_FiberVelocity_TendonForce_tendon'));
catch
    f_forceEquilibrium_FtildeState_all_tendon = Function.load(fullfile(PathDefaultFunc,'f_forceEquilibrium'));
    f_FiberLength_TendonForce_tendon = Function.load(fullfile(PathDefaultFunc,'f_FiberLength'));
    f_FiberVelocity_TendonForce_tendon = Function.load(fullfile(PathDefaultFunc,'f_FiberVelocity'));
end
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
armsi               = double([IO.jointi.arm_l, IO.jointi.arm_r]); % arms
residuals_noarmsi   = setdiff(residualsi,armsi); % all but arms

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

% Second, origins bodies. 
% Calcaneus
calcOr.r    = double(IO.origin.calcn_r([1,3])); % x and z coordinate
calcOr.l    = double(IO.origin.calcn_l([1,3])); % x and z coordinate
calcOr.all  = [calcOr.r,calcOr.l];
% Femurs
femurOr.r   = double(IO.origin.femur_r([1,3])); % x and z coordinate
femurOr.l   = double(IO.origin.femur_l([1,3])); % x and z coordinate
femurOr.all = [femurOr.r,femurOr.l];
% Hands
handOr.r    = double(IO.origin.hand_r([1,3])); % x and z coordinate
handOr.l    = double(IO.origin.hand_l([1,3])); % x and z coordinate
handOr.all  = [handOr.r,handOr.l];
% Tibias
tibiaOr.r   = double(IO.origin.tibia_r([1,3])); % x and z coordinate
tibiaOr.l   = double(IO.origin.tibia_l([1,3])); % x and z coordinate
tibiaOr.all = [tibiaOr.r,tibiaOr.l];
% toe joints
toesOr.r   = double(IO.origin.toes_r([1,3])); % x and z coordinate
toesOr.l   = double(IO.origin.toes_l([1,3])); % x and z coordinate
toesOr.all = [toesOr.r,toesOr.l];

% individual sphere GRFs
GRFi.forefoot.r = double([IO.GRFs.contact_sphere_3(2),IO.GRFs.contact_sphere_4(2),IO.GRFs.contact_sphere_5(2)]);
GRFi.forefoot.l = double([IO.GRFs.contact_sphere_8(2),IO.GRFs.contact_sphere_9(2),IO.GRFs.contact_sphere_10(2)]);
GRFi.toes.r = double([IO.GRFs.contact_sphere_5(2)]);
GRFi.toes.l = double([IO.GRFs.contact_sphere_10(2)]);

%% Get tracking information
if S.TrackSim
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

%% Possibility to vary plantar fascia force scale factor over time (predefined)
PF_sf_isvar = 0;
if length(S.Foot.PF_sf_var)==2*N
    PF_sf_isvar = 1;
    PF_sf_var_r = horzcat(S.Foot.PF_sf_var(1:N));
    PF_sf_var_l = horzcat(S.Foot.PF_sf_var(N+1:end));
    PF_sf_var_lr = [PF_sf_var_l; PF_sf_var_r];
end

%% Get bounds and initial guess

% Kinematics file for bounds -- input arguments
IKfile_bounds = fullfile(pathRepo, S.IKfile_Bounds);

% We extract experimental data to set bounds and initial guesses if needed
joints = {'pelvis_tilt','pelvis_list','pelvis_rotation','pelvis_tx',...
    'pelvis_ty','pelvis_tz','hip_flexion_l','hip_adduction_l',...
    'hip_rotation_l','hip_flexion_r','hip_adduction_r','hip_rotation_r',...
    'knee_angle_l','knee_angle_r','ankle_angle_l','ankle_angle_r',...
    'subtalar_angle_l','subtalar_angle_r',...
    'mtj_angle_l','mtj_angle_r','mtp_angle_l','mtp_angle_r',...
    'lumbar_extension','lumbar_bending','lumbar_rotation','arm_flex_l',...
    'arm_add_l','arm_rot_l','arm_flex_r','arm_add_r','arm_rot_r',...
    'elbow_flex_l','elbow_flex_r'};

joints_no_mtj = {'pelvis_tilt','pelvis_list','pelvis_rotation','pelvis_tx',...
    'pelvis_ty','pelvis_tz','hip_flexion_l','hip_adduction_l',...
    'hip_rotation_l','hip_flexion_r','hip_adduction_r','hip_rotation_r',...
    'knee_angle_l','knee_angle_r','ankle_angle_l','ankle_angle_r',...
    'subtalar_angle_l','subtalar_angle_r','mtp_angle_l','mtp_angle_r',...
    'lumbar_extension','lumbar_bending','lumbar_rotation','arm_flex_l',...
    'arm_add_l','arm_rot_l','arm_flex_r','arm_add_r','arm_rot_r',...
    'elbow_flex_l','elbow_flex_r'};

if ~mtj
    joints = joints_no_mtj;
end

Qs_walk          = getIK(IKfile_bounds,joints);
[bounds,scaling] = getBounds_all(Qs_walk,NMuscle,nq,jointi,S.v_tgt,mtj);

% load([pathRepo '\Data\Fal_s1.mat'],'Data');
% Qs_IK = Data.(['IK_' S.Foot.Model '_' S.Foot.Scaling]);
% [bounds,scaling] = getBounds_all_v2(Qs_IK,NMuscle,nq,jointi,S.v_tgt,mtj);

% adapt bounds based on user input
bounds = AdaptBounds(bounds,S,mai);

% The initial guess depends on the settings
pathIG = [pathRepo,'/IG'];
addpath(genpath(pathIG));
if S.IGsel == 1 % Quasi-random initial guess
    guess = getGuess_QR_opti_int(N,nq,NMuscle,scaling,S.v_tgt,jointi,d,S.IG_PelvisY);
elseif S.IGsel == 2 % Data-informed initial guess
    if S.IGmodeID  < 2 % Data from average walking motion
        IKfile_guess    = fullfile(pathRepo, S.IKfile_guess);
        Qs_guess        = getIK(IKfile_guess,joints);
        time_IC         = [Qs_guess.time(1),Qs_guess.time(end)];
        guess = getGuess_DI_opti_int(Qs_guess,nq,N,time_IC,NMuscle,jointi,...
            scaling,S.v_tgt,d,mtj);
    elseif S.IGmodeID == 3 || S.IGmodeID == 4 % Data from selected motion
        % Extract joint positions from existing motion (previous results)
        if S.IGmodeID == 3
            GuessFolder = S.ResultsF_ig;
        elseif S.IGmodeID ==4
            GuessFolder = fullfile(pathRepo,'IG','data');
        end
        pathIK      = fullfile(GuessFolder,[S.savename_ig '.mot']);
        Qs_ig       = getIK(pathIK,joints_no_mtj);
        % When saving the results, we save a 2 full gait cycle (4*N) so here we
        % only select 1:N to have half a gait cycle
        nfr = length(Qs_ig.allfilt(:,1));
        frSel = round(nfr./4);
        Qs_ig.allfilt(:,6) = Qs_ig.allfilt(:,6) + 0.0131;
        Qs_ig_sel.allfilt   = Qs_ig.allfilt(1:frSel,:);
        Qs_ig_sel.time      = Qs_ig.time(1:frSel,:);
        Qs_ig_sel.colheaders = Qs_ig.colheaders;
        time_IC = [Qs_ig_sel.time(1),Qs_ig_sel.time(end)];
        guess = getGuess_DI_opti_int(Qs_ig_sel,nq,N,time_IC,NMuscle,jointi,scaling,S.v_tgt,d,mtj);
    end
end

guess = AdaptGuess_UserInput(guess,bounds,S);


%% Index helpers
% get help indexes for left and right leg and for symmetry constraint
[IndexLeft,IndexRight,QsInvA,QsInvB,QdotsInvA,...
    QdotsInvB,orderQsOpp] = GetIndexHelper_IO(jointi,IO,MuscleData.dof_names);

%% OCP create variables and bounds
% using opti
opti = casadi.Opti();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define static parameters
% Final time
tf = opti.variable();
opti.subject_to(bounds.tf.lower < tf < bounds.tf.upper);
opti.set_initial(tf, guess.tf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define states
% Muscle activations at mesh points
a = opti.variable(NMuscle,N+1);
opti.subject_to(bounds.a.lower'*ones(1,N+1) < a < ...
    bounds.a.upper'*ones(1,N+1));
opti.set_initial(a, guess.a');
% Muscle activations at collocation points
a_col = opti.variable(NMuscle,d*N);
opti.subject_to(bounds.a.lower'*ones(1,d*N) < a_col < ...
    bounds.a.upper'*ones(1,d*N));
opti.set_initial(a_col, guess.a_col');
% Muscle-tendon forces at mesh points
FTtilde = opti.variable(NMuscle,N+1);
opti.subject_to(bounds.FTtilde.lower'*ones(1,N+1) < FTtilde < ...
    bounds.FTtilde.upper'*ones(1,N+1));
opti.set_initial(FTtilde, guess.FTtilde');
% Muscle-tendon forces at collocation points
FTtilde_col = opti.variable(NMuscle,d*N);
opti.subject_to(bounds.FTtilde.lower'*ones(1,d*N) < FTtilde_col < ...
    bounds.FTtilde.upper'*ones(1,d*N));
opti.set_initial(FTtilde_col, guess.FTtilde_col');
% Qs at mesh points
Qs = opti.variable(nq.all,N+1);
% We want to constraint the pelvis_tx position at the first mesh point,
% and avoid redundant bounds
lboundsQsk = bounds.QsQdots.lower(1:2:end)'*ones(1,N+1);
lboundsQsk(jointi.pelvis.tx,1) = ...
    bounds.QsQdots_0.lower(2*jointi.pelvis.tx-1);
uboundsQsk = bounds.QsQdots.upper(1:2:end)'*ones(1,N+1);
uboundsQsk(jointi.pelvis.tx,1) = ...
    bounds.QsQdots_0.upper(2*jointi.pelvis.tx-1);
opti.subject_to(lboundsQsk < Qs < uboundsQsk);
opti.set_initial(Qs, guess.QsQdots(:,1:2:end)');
% Qs at collocation points
Qs_col = opti.variable(nq.all,d*N);
opti.subject_to(bounds.QsQdots.lower(1:2:end)'*ones(1,d*N) < Qs_col < ...
    bounds.QsQdots.upper(1:2:end)'*ones(1,d*N));
opti.set_initial(Qs_col, guess.QsQdots_col(:,1:2:end)');
% Qdots at mesh points
Qdots = opti.variable(nq.all,N+1);
opti.subject_to(bounds.QsQdots.lower(2:2:end)'*ones(1,N+1) < Qdots < ...
    bounds.QsQdots.upper(2:2:end)'*ones(1,N+1));
opti.set_initial(Qdots, guess.QsQdots(:,2:2:end)');
% Qdots at collocation points
Qdots_col = opti.variable(nq.all,d*N);
opti.subject_to(bounds.QsQdots.lower(2:2:end)'*ones(1,d*N) < Qdots_col < ...
    bounds.QsQdots.upper(2:2:end)'*ones(1,d*N));
opti.set_initial(Qdots_col, guess.QsQdots_col(:,2:2:end)');
% Arm activations at mesh points
a_a = opti.variable(nq.arms,N+1);
opti.subject_to(bounds.a_a.lower'*ones(1,N+1) < a_a < ...
    bounds.a_a.upper'*ones(1,N+1));
opti.set_initial(a_a, guess.a_a');
% Arm activations at collocation points
a_a_col = opti.variable(nq.arms,d*N);
opti.subject_to(bounds.a_a.lower'*ones(1,d*N) < a_a_col < ...
    bounds.a_a.upper'*ones(1,d*N));
opti.set_initial(a_a_col, guess.a_a_col');
% Mtp actuator
if S.Foot.mtp_actuator
    % Mtp activations at mesh points
    a_mtp = opti.variable(2,N+1);
    opti.subject_to(bounds.a_mtp.lower'*ones(1,N+1) < a_mtp < ...
        bounds.a_mtp.upper'*ones(1,N+1));
    opti.set_initial(a_mtp, guess.a_mtp');
    % Mtp activations at collocation points
    a_mtp_col = opti.variable(2,d*N);
    opti.subject_to(bounds.a_mtp.lower'*ones(1,d*N) < a_mtp_col < ...
        bounds.a_mtp.upper'*ones(1,d*N));
    opti.set_initial(a_mtp_col, guess.a_mtp_col');
end
% Plantar Intrinsic Muscles actuator
if S.Foot.PIM
    % PIM activations at mesh points
    a_PIM = opti.variable(2,N+1);
    opti.subject_to(bounds.a_PIM.lower'*ones(1,N+1) < a_PIM < ...
        bounds.a_PIM.upper'*ones(1,N+1));
    opti.set_initial(a_PIM, guess.a_PIM');
    % PIM activations at collocation points
    a_PIM_col = opti.variable(2,d*N);
    opti.subject_to(bounds.a_PIM.lower'*ones(1,d*N) < a_PIM_col < ...
        bounds.a_PIM.upper'*ones(1,d*N));
    opti.set_initial(a_PIM_col, guess.a_PIM_col');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define controls
% Time derivative of muscle activations (states) at mesh points
vA = opti.variable(NMuscle, N);
opti.subject_to(bounds.vA.lower'*ones(1,N) < vA < ...
    bounds.vA.upper'*ones(1,N));
opti.set_initial(vA, guess.vA');
% Arm excitations
e_a = opti.variable(nq.arms, N);
opti.subject_to(bounds.e_a.lower'*ones(1,N) < e_a < ...
    bounds.e_a.upper'*ones(1,N));
opti.set_initial(e_a, guess.e_a');
% Mtp excitations
if S.Foot.mtp_actuator
    e_mtp = opti.variable(2, N);
    opti.subject_to(bounds.e_mtp.lower'*ones(1,N) < e_mtp < ...
        bounds.e_mtp.upper'*ones(1,N));
    opti.set_initial(e_mtp, guess.e_mtp');
end
% PIM excitations
if S.Foot.PIM
    e_PIM = opti.variable(2, N);
    opti.subject_to(bounds.e_PIM.lower'*ones(1,N) < e_PIM < ...
        bounds.e_PIM.upper'*ones(1,N));
    opti.set_initial(e_PIM, guess.e_PIM');
end

% nerve block intrinsic foot muscle
if S.Foot.FDB_nerveBlock
    iFDB = find(contains(muscleNames,'FDB_'));
    if isempty(iFDB)
        S.Foot.FDB_nerveBlock = 0;
    else
        % indices of left and right muscle
        iFDB_lr = [iFDB, iFDB + length(muscleNames(1:end-3))];
        a_FDB = a(iFDB_lr,:);
        a_col_FDB = a_col(iFDB_lr,:);
        vA_FDB = vA(iFDB_lr,:);
        
        % set activation to baseline
        opti.subject_to(a_FDB(:) == bounds.a.lower(iFDB));
        opti.subject_to(a_col_FDB(:) == bounds.a.lower(iFDB));
        % no change in activation
        opti.subject_to(vA_FDB(:) == 0);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define "slack" controls
% Time derivative of muscle-tendon forces (states) at collocation points
dFTtilde_col = opti.variable(NMuscle, d*N);
opti.subject_to(bounds.dFTtilde.lower'*ones(1,d*N) < dFTtilde_col < ...
    bounds.dFTtilde.upper'*ones(1,d*N));
opti.set_initial(dFTtilde_col, guess.dFTtilde_col');
% Time derivative of Qdots (states) at collocation points
A_col = opti.variable(nq.all, d*N);
opti.subject_to(bounds.Qdotdots.lower'*ones(1,d*N) < A_col < ...
    bounds.Qdotdots.upper'*ones(1,d*N));
opti.set_initial(A_col, guess.Qdotdots_col');

%% OCP: collocation equations
% Define CasADi variables for static parameters
tfk         = MX.sym('tfk');
% Define CasADi variables for states
ak          = MX.sym('ak',NMuscle);
aj          = MX.sym('akmesh',NMuscle,d);
akj         = [ak aj];
FTtildek    = MX.sym('FTtildek',NMuscle);
FTtildej    = MX.sym('FTtildej',NMuscle,d);
FTtildekj   = [FTtildek FTtildej];
Qsk         = MX.sym('Qsk',nq.all);
Qsj         = MX.sym('Qsj',nq.all,d);
Qskj        = [Qsk Qsj];
Qdotsk      = MX.sym('Qdotsk',nq.all);
Qdotsj      = MX.sym('Qdotsj',nq.all,d);
Qdotskj     = [Qdotsk Qdotsj];
a_ak        = MX.sym('a_ak',nq.arms);
a_aj        = MX.sym('a_akmesh',nq.arms,d);
a_akj       = [a_ak a_aj];
% Define CasADi variables for controls
vAk     = MX.sym('vAk',NMuscle);
e_ak    = MX.sym('e_ak',nq.arms);

if S.Foot.mtp_actuator
    a_mtpk      = MX.sym('a_mtpk',2);
    a_mtpj      = MX.sym('a_mtpkmesh',2,d);
    a_mtpkj     = [a_mtpk a_mtpj];
    e_mtpk      = MX.sym('e_mtpk',2);
end
if S.Foot.PIM
    a_PIMk      = MX.sym('a_PIMk',2);
    a_PIMj      = MX.sym('a_PIMkmesh',2,d);
    a_PIMkj     = [a_PIMk a_PIMj];
    e_PIMk      = MX.sym('e_PIMk',2);
end
if S.TrackSim
    Qsk_track   = MX.sym('Qsk_track',2*(S.Track.Q_ankle+S.Track.Q_subt));
end
if PF_sf_isvar
    PF_sf_k     = MX.sym('PF_sf',2);
end

% Define CasADi variables for "slack" controls
dFTtildej   = MX.sym('dFTtildej',NMuscle,d);
Aj          = MX.sym('Aj',nq.all,d);
J           = 0; % Initialize cost function
J_2         = 0; % Initilize PIM power cost function
eq_constr   = {}; % Initialize equality constraint vector
ineq_constr1 = {}; % Initialize inequality constraint vector 1
ineq_constr2 = {}; % Initialize inequality constraint vector 2
ineq_constr3 = {}; % Initialize inequality constraint vector 3
ineq_constr4 = {}; % Initialize inequality constraint vector 4
ineq_constr5 = {}; % Initialize inequality constraint vector 5
ineq_constr6 = {}; % Initialize inequality constraint vector 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time step
h = tfk/N;

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
% Loop over collocation points
for j=1:d
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Unscale variables
    Qskj_nsc = Qskj.*(scaling.QsQdots(1:2:end)'*ones(1,size(Qskj,2)/2));
    
    Qdotskj_nsc = Qdotskj.*(scaling.QsQdots(2:2:end)'* ...
        ones(1,size(Qdotskj,2)/2));
    FTtildekj_nsc = FTtildekj.*(scaling.FTtilde'*ones(1,size(FTtildekj,2)));
    dFTtildej_nsc = dFTtildej.*scaling.dFTtilde;
    Aj_nsc = Aj.*(scaling.Qdotdots'*ones(1,size(Aj,2)));
    vAk_nsc = vAk.*scaling.vA;
    
    QsQdotskj_nsc = MX(nq.all*2, d+1);
    QsQdotskj_nsc(1:2:end,:) = Qskj_nsc;
    QsQdotskj_nsc(2:2:end,:) = Qdotskj_nsc;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get muscle-tendon lengths, velocities, and moment arms
    % Left leg
    qinj_l          = Qskj_nsc(IndexLeft, j+1);
    qdotinj_l       = Qdotskj_nsc(IndexLeft, j+1);
    if mtj && ~S.Foot.mtj_muscles
        qinj_l(find(strcmp(MuscleData.dof_names,'mtj_angle_r'))) = 0;
        qdotinj_l(find(strcmp(MuscleData.dof_names,'mtj_angle_r'))) = 0;
    end
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
    qinj_r      = Qskj_nsc(IndexRight,j+1);
    qdotinj_r   = Qdotskj_nsc(IndexRight,j+1);
    if mtj && ~S.Foot.mtj_muscles
        qinj_r(find(strcmp(MuscleData.dof_names,'mtj_angle_r'))) = 0;
        qdotinj_r(find(strcmp(MuscleData.dof_names,'mtj_angle_r'))) = 0;
    end
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
        qinPFj_l          = Qskj_nsc([jointi.mtj.l,jointi.mtp.l], j+1);
        qdotinPFj_l       = Qdotskj_nsc([jointi.mtj.l,jointi.mtp.l], j+1);
        [l_PFj_l,v_PFj_l,MA_PFj_l] =  f_lLi_vLi_dM(qinPFj_l,qdotinPFj_l);
        MA_PFj.mtj.l = MA_PFj_l(1);
        MA_PFj.mtp.l = MA_PFj_l(2);
        % Right leg
        qinPFj_r          = Qskj_nsc([jointi.mtj.r,jointi.mtp.r], j+1);
        qdotinPFj_r       = Qdotskj_nsc([jointi.mtj.r,jointi.mtp.r], j+1);
        [l_PFj_r,v_PFj_r,MA_PFj_r] =  f_lLi_vLi_dM(qinPFj_r,qdotinPFj_r);
        MA_PFj.mtj.r = MA_PFj_r(1);
        MA_PFj.mtp.r = MA_PFj_r(2);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get muscle-tendon forces and derive Hill-equilibrium
    [Hilldiffj,FTj,Fcej,Fpassj,Fisoj] = ...
        f_forceEquilibrium_FtildeState_all_tendon(akj(:,j+1),...
        FTtildekj_nsc(:,j+1),dFTtildej_nsc(:,j),...
        lMTj_lr,vMTj_lr,tensions);
    % Get plantar fascia and plantar intrinsic muscles force
    if mtj
        % lumped ligament torque
        T_passj.mtj.l = f_passiveMoment_mtj(Qskj_nsc(jointi.mtj.l,j+1),Qdotskj_nsc(jointi.mtj.l,j+1));
        T_passj.mtj.r = f_passiveMoment_mtj(Qskj_nsc(jointi.mtj.r,j+1),Qdotskj_nsc(jointi.mtj.r,j+1));

        if strcmp(S.Foot.PF_stiffness,'none')
            if S.Foot.PIM == 2
                % no PF, only PIM + prevent PIM force at low lengths
                F_PIMj.l = a_PIMkj(1,j+1)*scaling.PIMF*(0.5+0.5*tanh(100*(l_PFj_l/S.Foot.PF_slack_length)-96));
                F_PIMj.r = a_PIMkj(2,j+1)*scaling.PIMF*(0.5+0.5*tanh(100*(l_PFj_r/S.Foot.PF_slack_length)-96));
                F_PF_PIMj.l = F_PIMj.l;
                F_PF_PIMj.r = F_PIMj.r;
            elseif S.Foot.PIM
                % no PF, only PIM
                F_PIMj.l = a_PIMkj(1,j+1)*scaling.PIMF;
                F_PIMj.r = a_PIMkj(2,j+1)*scaling.PIMF;
                F_PF_PIMj.l = F_PIMj.l;
                F_PF_PIMj.r = F_PIMj.r;
            end
        else
            if PF_sf_isvar
                F_PFj_l = f_PF_stiffness(l_PFj_l)*PF_sf_k(1);
                F_PFj_r = f_PF_stiffness(l_PFj_r)*PF_sf_k(2);
            else
                F_PFj_l = f_PF_stiffness(l_PFj_l)*S.Foot.PF_sf;
                F_PFj_r = f_PF_stiffness(l_PFj_r)*S.Foot.PF_sf;
            end
            if S.Foot.PIM == 2
                % no PF, only PIM + prevent PIM force at low lengths
                F_PIMj.l = a_PIMkj(1,j+1)*scaling.PIMF*(0.5+0.5*tanh(100*(l_PFj_l/S.Foot.PF_slack_length)-96));
                F_PIMj.r = a_PIMkj(2,j+1)*scaling.PIMF*(0.5+0.5*tanh(100*(l_PFj_r/S.Foot.PF_slack_length)-96));
                F_PF_PIMj.l = F_PIMj.l + F_PFj_l;
                F_PF_PIMj.r = F_PIMj.r + F_PFj_r;
            elseif S.Foot.PIM
                % PF and PIM
                F_PIMj.l = a_PIMkj(1,j+1)*scaling.PIMF;
                F_PIMj.r = a_PIMkj(2,j+1)*scaling.PIMF;
                F_PF_PIMj.l = F_PIMj.l + F_PFj_l;
                F_PF_PIMj.r = F_PIMj.r + F_PFj_r;
            else
                % only PF, no PIM
                F_PF_PIMj.l = F_PFj_l;
                F_PF_PIMj.r = F_PFj_r;
            end
        end
        if S.Foot.FDB

        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get metabolic energy rate if in the cost function
    % Get muscle fiber lengths
    [~,lMtildej] = f_FiberLength_TendonForce_tendon(...
        FTtildekj_nsc(:,j+1),lMTj_lr);
    % Get muscle fiber velocities
    [vMj,~] = f_FiberVelocity_TendonForce_tendon(...
        FTtildekj_nsc(:,j+1),dFTtildej_nsc(:,j),...
        lMTj_lr,vMTj_lr);
    % Get metabolic energy rate Bhargava et al. (2004)
    [e_totj,~,~,~,~,~] = f_getMetabolicEnergySmooth2004all(...
        akj(:,j+1),akj(:,j+1),lMtildej,vMj,Fcej,Fpassj,...
        MuscleMass.MassM',pctsts,Fisoj,S.mass,S.tanh_b);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get passive joint torques
    Tau_passj_all = f_AllPassiveTorques(Qskj_nsc(:,j+1),Qdotskj_nsc(:,j+1));
    if S.W.noDamping
        Tau_passj_all_noDamping = f_AllPassiveTorques(Qskj_nsc(:,j+1),zeros(size(Qdotskj_nsc(:,j+1))));
    end
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
        if S.W.noDamping
            Tau_passj_J = Tau_passj_all_noDamping([1:12 17:end]);
        else
            Tau_passj_J = Tau_passj_all([1:12 17:end]);
        end
    else
        Tau_passj.mtp.l = Tau_passj_all(13);
        Tau_passj.mtp.r = Tau_passj_all(14);
        Tau_passj.trunk.ext = Tau_passj_all(15);
        Tau_passj.trunk.ben = Tau_passj_all(16);
        Tau_passj.trunk.rot = Tau_passj_all(17);
        Tau_passj.arm = Tau_passj_all(18:25);
        if S.W.noDamping
            Tau_passj_J = Tau_passj_all_noDamping([1:12 15:end]);
        else
            Tau_passj_J = Tau_passj_all([1:12 15:end]);
        end
    end


    % Expression for the state derivatives at the collocation points
    Qsp_nsc      = Qskj_nsc*C(:,j+1);
    Qdotsp_nsc   = Qdotskj_nsc*C(:,j+1);
    FTtildep_nsc = FTtildekj_nsc*C(:,j+1);
    ap           = akj*C(:,j+1);
    a_ap         = a_akj*C(:,j+1);
    if S.Foot.mtp_actuator
        a_mtpp       = a_mtpkj*C(:,j+1);
    end
    if S.Foot.PIM
        a_PIMp       = a_PIMkj*C(:,j+1);
    end
    % Append collocation equations
    % Dynamic constraints are scaled using the same scale
    % factors as the ones used to scale the states
    % Activation dynamics (implicit formulation)
    eq_constr{end+1} = (h*vAk_nsc - ap)./scaling.a;
    % Contraction dynamics (implicit formulation)
    eq_constr{end+1} = (h*dFTtildej_nsc(:,j) - FTtildep_nsc)./...
        scaling.FTtilde';
    % Skeleton dynamics (implicit formulation)
    qdotj_nsc = Qdotskj_nsc(:,j+1); % velocity
    eq_constr{end+1} = (h*qdotj_nsc - Qsp_nsc)./scaling.QsQdots(1:2:end)';
    eq_constr{end+1} = (h*Aj_nsc(:,j) - Qdotsp_nsc)./...
        scaling.QsQdots(2:2:end)';
    % Arm activation dynamics (explicit formulation)
    da_adtj = f_ArmActivationDynamics(e_ak,a_akj(:,j+1)');
    eq_constr{end+1} = (h*da_adtj - a_ap)./scaling.a_a;
    % Mtp activation dynamics (explicit formulation)
    if S.Foot.mtp_actuator
        da_mtpdtj = f_MtpActivationDynamics(e_mtpk,a_mtpkj(:,j+1)');
        eq_constr{end+1} = (h*da_mtpdtj - a_mtpp);
    end
    % PIM activation dynamics (explicit formulation)
    if S.Foot.PIM
        da_PIMdtj = f_MtpActivationDynamics(e_PIMk,a_PIMkj(:,j+1)');
        eq_constr{end+1} = (h*da_PIMdtj - a_PIMp);
    end
    % Add contribution to the quadrature function
    J = J + 1*(...
        W.E*B(j+1)      *(f_J92exp(e_totj,W.exp_E))/S.mass*h + ...
        W.A*B(j+1)      *(f_J92(akj(:,j+1)'))*h + ...
        W.ArmE*B(j+1)   *(f_J8(e_ak))*h +...
        W.passMom*B(j+1)*(f_J23(Tau_passj_J))*h + ...
        W.u*B(j+1)      *(f_J92(vAk))*h + ...
        W.u*B(j+1)      *(f_J92(dFTtildej(:,j)))*h + ...
        W.u*B(j+1)      *(f_J8(Aj(armsi,j)))*h);
    if mtj
        J = J + W.Ak*B(j+1)     *(f_J25(Aj(residuals_noarmsi,j)))*h;
    else
        J = J + W.Ak*B(j+1)     *(f_J23(Aj(residuals_noarmsi,j)))*h;
    end
    if S.Foot.mtp_actuator
        J = J + W.Mtp*B(j+1)    *(f_J2(e_mtpk))*h;
    end
    if S.Foot.PIM && S.W.PIM ~=0
        J = J + W.PIM*B(j+1)    *(f_J2(e_PIMk))*h;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Call external function (run inverse dynamics)
    [Tj] = F([QsQdotskj_nsc(:,j+1);Aj_nsc(:,j)]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add path constraints
    % Null pelvis residuals
    eq_constr{end+1} = Tj(ground_pelvisi,1);
    % Muscle-driven joint torques for the lower limbs and the trunk
    mai_i = 1; % helper index
    % Hip flexion, left
    Ft_hip_flex_l   = FTj(mai(mai_i).mus.l',1);
    T_hip_flex_l    = f_T27(MAj.hip_flex.l,Ft_hip_flex_l);
    eq_constr{end+1} = Tj(jointi.hip_flex.l,1)-(T_hip_flex_l + Tau_passj.hip.flex.l);
    % Hip flexion, right
    Ft_hip_flex_r   = FTj(mai(mai_i).mus.r',1);
    T_hip_flex_r    = f_T27(MAj.hip_flex.r,Ft_hip_flex_r);
    eq_constr{end+1} = Tj(jointi.hip_flex.r,1)-(T_hip_flex_r + Tau_passj.hip.flex.r);
    mai_i = mai_i+1;
    % Hip adduction, left
    Ft_hip_add_l    = FTj(mai(mai_i).mus.l',1);
    T_hip_add_l     = f_T27(MAj.hip_add.l,Ft_hip_add_l);
    eq_constr{end+1} = Tj(jointi.hip_add.l,1)-(T_hip_add_l + Tau_passj.hip.add.l);
    % Hip adduction, right
    Ft_hip_add_r    = FTj(mai(mai_i).mus.r',1);
    T_hip_add_r     = f_T27(MAj.hip_add.r,Ft_hip_add_r);
    eq_constr{end+1} = Tj(jointi.hip_add.r,1)-(T_hip_add_r + Tau_passj.hip.add.r);
    mai_i = mai_i+1;
    % Hip rotation, left
    Ft_hip_rot_l    = FTj(mai(mai_i).mus.l',1);
    T_hip_rot_l     = f_T27(MAj.hip_rot.l,Ft_hip_rot_l);
    eq_constr{end+1} = Tj(jointi.hip_rot.l,1)-(T_hip_rot_l + Tau_passj.hip.rot.l);
    % Hip rotation, right
    Ft_hip_rot_r    = FTj(mai(mai_i).mus.r',1);
    T_hip_rot_r     = f_T27(MAj.hip_rot.r,Ft_hip_rot_r);
    eq_constr{end+1} = Tj(jointi.hip_rot.r,1)-(T_hip_rot_r + Tau_passj.hip.rot.r);
    mai_i = mai_i+1;
    % Knee, left
    Ft_knee_l       = FTj(mai(mai_i).mus.l',1);
    T_knee_l        = f_T13(MAj.knee.l,Ft_knee_l);
    eq_constr{end+1} = Tj(jointi.knee.l,1)-(T_knee_l + Tau_passj.knee.l);
    % Knee, right
    Ft_knee_r       = FTj(mai(mai_i).mus.r',1);
    T_knee_r        = f_T13(MAj.knee.r,Ft_knee_r);
    eq_constr{end+1} = Tj(jointi.knee.r,1)-(T_knee_r + Tau_passj.knee.r);
    mai_i = mai_i+1;
    % Ankle, left
    Ft_ankle_l      = FTj(mai(mai_i).mus.l',1);
    T_ankle_l       = f_T12(MAj.ankle.l,Ft_ankle_l);
    eq_constr{end+1} = Tj(jointi.ankle.l,1)-(T_ankle_l + Tau_passj.ankle.l);
    % Ankle, right
    Ft_ankle_r      = FTj(mai(mai_i).mus.r',1);
    T_ankle_r       = f_T12(MAj.ankle.r,Ft_ankle_r);
    eq_constr{end+1} = Tj(jointi.ankle.r,1)-(T_ankle_r + Tau_passj.ankle.r);
    mai_i = mai_i+1;
    % Subtalar, left
    Ft_subt_l       = FTj(mai(mai_i).mus.l',1);
    T_subt_l        = f_T12(MAj.subt.l,Ft_subt_l);
    eq_constr{end+1} = Tj(jointi.subt.l,1)-(T_subt_l +  Tau_passj.subt.l);
    % Subtalar, right
    Ft_subt_r       = FTj(mai(mai_i).mus.r',1);
    T_subt_r        = f_T12(MAj.subt.r,Ft_subt_r);
    eq_constr{end+1} = Tj(jointi.subt.r,1)-(T_subt_r + Tau_passj.subt.r );
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
        if ~isempty(S.Foot.insole_Stearne) 
            if strcmp(S.Foot.insole_Stearne,'FAI')
                T_FAI_l = -100*(tanh((Qskj_nsc(jointi.mtj.l,j+1)*400-1)*pi)+1)/2;

            elseif strcmp(S.Foot.insole_Stearne,'FAI30')
                T_FAI_l = -30*(tanh((Qskj_nsc(jointi.mtj.l,j+1)*400-1)*pi)+1)/2;

            elseif strcmp(S.Foot.insole_Stearne,'FAI50')
                T_FAI_l = -50*(tanh((Qskj_nsc(jointi.mtj.l,j+1)*400-1)*pi)+1)/2;

            elseif strcmp(S.Foot.insole_Stearne,'FAI80')
                T_FAI_l = -80*(tanh((Qskj_nsc(jointi.mtj.l,j+1)*400-1)*pi)+1)/2;

            end
            T_mtj_tmp_l     = T_mtj_tmp_l + T_FAI_l;
        end
        eq_constr{end+1} = Tj(jointi.mtj.l,1)-(T_mtj_tmp_l);
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
        if ~isempty(S.Foot.insole_Stearne)
            if strcmp(S.Foot.insole_Stearne,'FAI')
                T_FAI_r = -100*(tanh((Qskj_nsc(jointi.mtj.r,j+1)*400-1)*pi)+1)/2;

            elseif strcmp(S.Foot.insole_Stearne,'FAI30')
                T_FAI_r = -30*(tanh((Qskj_nsc(jointi.mtj.r,j+1)*400-1)*pi)+1)/2;

            elseif strcmp(S.Foot.insole_Stearne,'FAI50')
                T_FAI_r = -50*(tanh((Qskj_nsc(jointi.mtj.r,j+1)*400-1)*pi)+1)/2;

            elseif strcmp(S.Foot.insole_Stearne,'FAI80')
                T_FAI_r = -80*(tanh((Qskj_nsc(jointi.mtj.r,j+1)*400-1)*pi)+1)/2;

            end
            T_mtj_tmp_r     = T_mtj_tmp_r + T_FAI_r;
        end
        eq_constr{end+1} = Tj(jointi.mtj.r,1)-(T_mtj_tmp_r);
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
        T_mtp_tmp_l     = T_mtp_tmp_l + a_mtpkj(1,j+1)*scaling.MtpTau;
    end
    if S.Foot.insole_Takahashi_kMTP~=0
%         GRF_l = Tj(GRFi.toes.l,1);
        GRF_l = sum(Tj(GRFi.forefoot.l,1));
        y1 = (tanh((GRF_l/5-3)*pi)+1)/2; % =0 if GRF<10 and =1 if GRF>20
        T_insole_l = -S.Foot.insole_Takahashi_kMTP*y1*Qskj_nsc(jointi.mtp.l,j+1);
        T_mtp_tmp_l     = T_mtp_tmp_l + T_insole_l;
    end
    eq_constr{end+1} = Tj(jointi.mtp.l,1)-(T_mtp_tmp_l);
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
    if S.Foot.mtp_actuator
        T_mtp_tmp_r     = T_mtp_tmp_r + a_mtpkj(2,j+1)*scaling.MtpTau;
    end
    if S.Foot.insole_Takahashi_kMTP~=0
%         GRF_r = Tj(GRFi.toes.r,1);
        GRF_r = sum(Tj(GRFi.forefoot.r,1));
        y1 = (tanh((GRF_r/5-3)*pi)+1)/2; % =0 if GRF<10 and =1 if GRF>20
        T_insole_r = -S.Foot.insole_Takahashi_kMTP*y1*Qskj_nsc(jointi.mtp.r,j+1);
        T_mtp_tmp_r     = T_mtp_tmp_r + T_insole_r;
    end
    eq_constr{end+1} = Tj(jointi.mtp.r,1)-(T_mtp_tmp_r);
    mai_i = mai_i+1;

    % Lumbar extension
    Ft_trunk_ext    = FTj([mai(mai_i).mus.l,mai(mai_i).mus.r]',1);
    T_trunk_ext     = f_T6(MAj.trunk_ext,Ft_trunk_ext);
    eq_constr{end+1} = Tj(jointi.trunk.ext,1)-(T_trunk_ext + Tau_passj.trunk.ext);
    mai_i = mai_i+1;
    % Lumbar bending
    Ft_trunk_ben    = FTj([mai(mai_i).mus.l,mai(mai_i).mus.r]',1);
    T_trunk_ben     = f_T6(MAj.trunk_ben,Ft_trunk_ben);
    eq_constr{end+1} = Tj(jointi.trunk.ben,1)-(T_trunk_ben + Tau_passj.trunk.ben);
    mai_i = mai_i+1;
    % Lumbar rotation
    Ft_trunk_rot    = FTj([mai(mai_i).mus.l,mai(mai_i).mus.r]',1);
    T_trunk_rot     = f_T6(MAj.trunk_rot,Ft_trunk_rot);
    eq_constr{end+1} = Tj(jointi.trunk.rot,1)-(T_trunk_rot + Tau_passj.trunk.rot);
    % Torque-driven joint torques for the arms
    % Arms
    eq_constr{end+1} = Tj(armsi,1)/scaling.ArmTau - (a_akj(:,j+1) + ...
        (Tau_passj.arm)/scaling.ArmTau);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Activation dynamics (implicit formulation)
    act1 = vAk_nsc + akj(:,j+1)./(ones(size(akj(:,j+1),1),1)*tdeact);
    act2 = vAk_nsc + akj(:,j+1)./(ones(size(akj(:,j+1),1),1)*tact);
    ineq_constr1{end+1} = act1;
    ineq_constr2{end+1} = act2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Contraction dynamics (implicit formulation)
    eq_constr{end+1} = Hilldiffj;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constraints to prevent parts of the skeleton to penetrate each
    % other.
    % Origins calcaneus (transv plane) at minimum 9 cm from each other.
    ineq_constr3{end+1} = f_Jnn2(Tj(calcOr.r,1) - Tj(calcOr.l,1));
    % Constraint to prevent the arms to penetrate the skeleton
    % Origins femurs and ipsilateral hands (transv plane) at minimum
    % 18 cm from each other.
    ineq_constr4{end+1} = f_Jnn2(Tj(femurOr.r,1) - Tj(handOr.r,1));
    ineq_constr4{end+1} = f_Jnn2(Tj(femurOr.l,1) - Tj(handOr.l,1));
    % Origins tibia (transv plane) at minimum 11 cm from each other.
    ineq_constr5{end+1} = f_Jnn2(Tj(tibiaOr.r,1) - Tj(tibiaOr.l,1));
    % Origins toes (transv plane) at minimum 10 cm from each other.
    ineq_constr6{end+1} = f_Jnn2(Tj(toesOr.r,1) - Tj(toesOr.l,1));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Extra cost function term to minimise net mechanical energy
    % generated/dissiped by both PIMs
    if S.Foot.PIM && S.W.P_PIM ~=0
        % calculate PIM mechanical power
        P_PIM.l = -v_PFj_l*F_PIMj.l;
        P_PIM.r = -v_PFj_r*F_PIMj.r;
        % normalised summ
        J_2 = J_2 + B(j+1) * (P_PIM.l+P_PIM.r)/S.mass*h;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % End loop over collocation points

if S.TrackSim
    Qsk_nsc = Qsk.*scaling.Qs';
    if S.Track.Q_ankle
        track_err = Qsk_nsc([jointi.ankle.l, jointi.ankle.r]) - Qsk_track(1:2);
        J = J + W.Q_track * f_J2(track_err)*h;
        if S.Track.Q_subt
            track_err2 = Qsk_nsc([jointi.subt.l, jointi.subt.r]) - Qsk_track(3:4);
            J = J + W.Q_track * f_J2(track_err2)*h;
        end
    elseif S.Track.Q_subt
        track_err = Qsk_nsc([jointi.subt.l, jointi.subt.r]) - Qsk_track(1:2);
        J = J + W.Q_track * f_J2(track_err)*h;
    end
end

eq_constr = vertcat(eq_constr{:});
ineq_constr1 = vertcat(ineq_constr1{:});
ineq_constr2 = vertcat(ineq_constr2{:});
ineq_constr3 = vertcat(ineq_constr3{:});
ineq_constr4 = vertcat(ineq_constr4{:});
ineq_constr5 = vertcat(ineq_constr5{:});
ineq_constr6 = vertcat(ineq_constr6{:});

% Createcasadi function for opti
if S.Foot.mtp_actuator
    if S.Foot.PIM       % mtp and PIM actuator
        % Casadi function to get constraints and objective
        f_coll = Function('f_coll',{tfk,ak,aj,FTtildek,FTtildej,Qsk,Qsj,Qdotsk,...
            Qdotsj,a_ak,a_aj,a_mtpk,a_mtpj,a_PIMk,a_PIMj,vAk,e_ak,e_mtpk,e_PIMk,dFTtildej,Aj},...
            {eq_constr,ineq_constr1,ineq_constr2,ineq_constr3,ineq_constr4,...
            ineq_constr5,ineq_constr6,J,J_2});
        % assign NLP problem to multiple cores
        f_coll_map = f_coll.map(N,S.parallelMode,S.NThreads);
        [coll_eq_constr, coll_ineq_constr1, coll_ineq_constr2, coll_ineq_constr3,...
            coll_ineq_constr4, coll_ineq_constr5, coll_ineq_constr6, Jall, J_2all] = f_coll_map(tf,...
            a(:,1:end-1), a_col, FTtilde(:,1:end-1), FTtilde_col, Qs(:,1:end-1), ...
            Qs_col, Qdots(:,1:end-1), Qdots_col, a_a(:,1:end-1), a_a_col, ...
            a_mtp(:,1:end-1), a_mtp_col, a_PIM(:,1:end-1), a_PIM_col, vA, e_a, e_mtp, e_PIM, dFTtilde_col, A_col);
    else                % only mtp actuator
        % Casadi function to get constraints and objective
        f_coll = Function('f_coll',{tfk,ak,aj,FTtildek,FTtildej,Qsk,Qsj,Qdotsk,...
            Qdotsj,a_ak,a_aj,a_mtpk,a_mtpj,vAk,e_ak,e_mtpk,dFTtildej,Aj},...
            {eq_constr,ineq_constr1,ineq_constr2,ineq_constr3,ineq_constr4,...
            ineq_constr5,ineq_constr6,J});
        % assign NLP problem to multiple cores
        f_coll_map = f_coll.map(N,S.parallelMode,S.NThreads);
        [coll_eq_constr, coll_ineq_constr1, coll_ineq_constr2, coll_ineq_constr3,...
            coll_ineq_constr4, coll_ineq_constr5, coll_ineq_constr6, Jall] = f_coll_map(tf,...
            a(:,1:end-1), a_col, FTtilde(:,1:end-1), FTtilde_col, Qs(:,1:end-1), ...
            Qs_col, Qdots(:,1:end-1), Qdots_col, a_a(:,1:end-1), a_a_col, ...
            a_mtp(:,1:end-1), a_mtp_col, vA, e_a, e_mtp, dFTtilde_col, A_col);
    end
else
    if S.Foot.PIM       % only PIM actuator
        % Casadi function to get constraints and objective
        f_coll = Function('f_coll',{tfk,ak,aj,FTtildek,FTtildej,Qsk,Qsj,Qdotsk,...
            Qdotsj,a_ak,a_aj,a_PIMk,a_PIMj,vAk,e_ak,e_PIMk,dFTtildej,Aj},...
            {eq_constr,ineq_constr1,ineq_constr2,ineq_constr3,ineq_constr4,...
            ineq_constr5,ineq_constr6,J,J_2});
        % assign NLP problem to multiple cores
        f_coll_map = f_coll.map(N,S.parallelMode,S.NThreads);
        [coll_eq_constr, coll_ineq_constr1, coll_ineq_constr2, coll_ineq_constr3,...
            coll_ineq_constr4, coll_ineq_constr5, coll_ineq_constr6, Jall, J_2all] = f_coll_map(tf,...
            a(:,1:end-1), a_col, FTtilde(:,1:end-1), FTtilde_col, Qs(:,1:end-1), ...
            Qs_col, Qdots(:,1:end-1), Qdots_col, a_a(:,1:end-1), a_a_col, ...
            a_PIM(:,1:end-1), a_PIM_col, vA, e_a, e_PIM, dFTtilde_col, A_col);
    else
        if S.TrackSim    
            if PF_sf_isvar % with tracking term, no actuators, variable PF
                % Casadi function to get constraints and objective
                f_coll = Function('f_coll',{tfk,ak,aj,FTtildek,FTtildej,Qsk,Qsj,Qdotsk,...
                    Qdotsj,a_ak,a_aj,vAk,e_ak,dFTtildej,Aj,Qsk_track,PF_sf_k},...
                    {eq_constr,ineq_constr1,ineq_constr2,ineq_constr3,ineq_constr4,...
                    ineq_constr5,ineq_constr6,J});
                % assign NLP problem to multiple cores
                f_coll_map = f_coll.map(N,S.parallelMode,S.NThreads);
                [coll_eq_constr, coll_ineq_constr1, coll_ineq_constr2, coll_ineq_constr3,...
                    coll_ineq_constr4, coll_ineq_constr5, coll_ineq_constr6, Jall] = f_coll_map(tf,...
                    a(:,1:end-1), a_col, FTtilde(:,1:end-1), FTtilde_col, Qs(:,1:end-1), ...
                    Qs_col, Qdots(:,1:end-1), Qdots_col, a_a(:,1:end-1), a_a_col, ...
                    vA, e_a, dFTtilde_col, A_col, Qref_lr, PF_sf_var_lr);

            else        % with tracking term, no actuators, fixed PF
                % Casadi function to get constraints and objective
                f_coll = Function('f_coll',{tfk,ak,aj,FTtildek,FTtildej,Qsk,Qsj,Qdotsk,...
                    Qdotsj,a_ak,a_aj,vAk,e_ak,dFTtildej,Aj,Qsk_track},...
                    {eq_constr,ineq_constr1,ineq_constr2,ineq_constr3,ineq_constr4,...
                    ineq_constr5,ineq_constr6,J});
                % assign NLP problem to multiple cores
                f_coll_map = f_coll.map(N,S.parallelMode,S.NThreads);
                [coll_eq_constr, coll_ineq_constr1, coll_ineq_constr2, coll_ineq_constr3,...
                    coll_ineq_constr4, coll_ineq_constr5, coll_ineq_constr6, Jall] = f_coll_map(tf,...
                    a(:,1:end-1), a_col, FTtilde(:,1:end-1), FTtilde_col, Qs(:,1:end-1), ...
                    Qs_col, Qdots(:,1:end-1), Qdots_col, a_a(:,1:end-1), a_a_col, ...
                    vA, e_a, dFTtilde_col, A_col, Qref_lr);

            end

        else            
            if PF_sf_isvar % w/o tracking term, no actuators, variable PF
                % Casadi function to get constraints and objective
                f_coll = Function('f_coll',{tfk,ak,aj,FTtildek,FTtildej,Qsk,Qsj,Qdotsk,...
                    Qdotsj,a_ak,a_aj,vAk,e_ak,dFTtildej,Aj,PF_sf_k},...
                    {eq_constr,ineq_constr1,ineq_constr2,ineq_constr3,ineq_constr4,...
                    ineq_constr5,ineq_constr6,J});
                % assign NLP problem to multiple cores
                f_coll_map = f_coll.map(N,S.parallelMode,S.NThreads);
                [coll_eq_constr, coll_ineq_constr1, coll_ineq_constr2, coll_ineq_constr3,...
                    coll_ineq_constr4, coll_ineq_constr5, coll_ineq_constr6, Jall] = f_coll_map(tf,...
                    a(:,1:end-1), a_col, FTtilde(:,1:end-1), FTtilde_col, Qs(:,1:end-1), ...
                    Qs_col, Qdots(:,1:end-1), Qdots_col, a_a(:,1:end-1), a_a_col, ...
                    vA, e_a, dFTtilde_col, A_col, PF_sf_var_lr);

            else    % w/o tracking term, no actuators, fixed PF
                % Casadi function to get constraints and objective
                f_coll = Function('f_coll',{tfk,ak,aj,FTtildek,FTtildej,Qsk,Qsj,Qdotsk,...
                    Qdotsj,a_ak,a_aj,vAk,e_ak,dFTtildej,Aj},...
                    {eq_constr,ineq_constr1,ineq_constr2,ineq_constr3,ineq_constr4,...
                    ineq_constr5,ineq_constr6,J});
                % assign NLP problem to multiple cores
                f_coll_map = f_coll.map(N,S.parallelMode,S.NThreads);
                [coll_eq_constr, coll_ineq_constr1, coll_ineq_constr2, coll_ineq_constr3,...
                    coll_ineq_constr4, coll_ineq_constr5, coll_ineq_constr6, Jall] = f_coll_map(tf,...
                    a(:,1:end-1), a_col, FTtilde(:,1:end-1), FTtilde_col, Qs(:,1:end-1), ...
                    Qs_col, Qdots(:,1:end-1), Qdots_col, a_a(:,1:end-1), a_a_col, ...
                    vA, e_a, dFTtilde_col, A_col);
            end
        end
    end
end


% constrains
opti.subject_to(coll_eq_constr == 0);
opti.subject_to(coll_ineq_constr1(:) >= 0);
opti.subject_to(coll_ineq_constr2(:) <= 1/tact);
opti.subject_to(S.Constr.calcn.^2 < coll_ineq_constr3(:) < 4); % origin calcaneus
opti.subject_to(0.0324 < coll_ineq_constr4(:) < 4); % arms
opti.subject_to(S.Constr.tibia.^2 < coll_ineq_constr5(:) < 4); % origin tibia minimum x cm away from each other
opti.subject_to(S.Constr.toes.^2   < coll_ineq_constr6(:) < 4); % origins toes minimum x cm away from each other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over mesh points
for k=1:N
    % Variables within current mesh interval
    % States
    akj = [a(:,k), a_col(:,(k-1)*d+1:k*d)];
    FTtildekj = [FTtilde(:,k), FTtilde_col(:,(k-1)*d+1:k*d)];
    Qskj = [Qs(:,k), Qs_col(:,(k-1)*d+1:k*d)];
    Qdotskj = [Qdots(:,k), Qdots_col(:,(k-1)*d+1:k*d)];
    a_akj = [a_a(:,k), a_a_col(:,(k-1)*d+1:k*d)];
    % Add equality constraints (next interval starts with end values of
    % states from previous interval)
    opti.subject_to(a(:,k+1) == akj*D);
    opti.subject_to(FTtilde(:,k+1) == FTtildekj*D); % scaled
    opti.subject_to(Qs(:,k+1) == Qskj*D); % scaled
    opti.subject_to(Qdots(:,k+1) == Qdotskj*D); % scaled
    opti.subject_to(a_a(:,k+1) == a_akj*D);
    if S.Foot.mtp_actuator
        a_mtpkj = [a_mtp(:,k), a_mtp_col(:,(k-1)*d+1:k*d)];
        opti.subject_to(a_mtp(:,k+1) == a_mtpkj*D);
    end
    if S.Foot.PIM
        a_PIMkj = [a_PIM(:,k), a_PIM_col(:,(k-1)*d+1:k*d)];
        opti.subject_to(a_PIM(:,k+1) == a_PIMkj*D);
    end
end % End loop over mesh points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Additional path constraints
if S.Symmetric
    % Periodicity of the states (or rather LR symmetry -half gait cycle)
    % Qs and Qdots
    opti.subject_to(Qs(QsInvA,end) - Qs(QsInvB,1) == 0);
    opti.subject_to(Qdots(QdotsInvA,end) - Qdots(QdotsInvB,1) == 0);
    opti.subject_to(Qs(orderQsOpp,end) + Qs(orderQsOpp,1) == 0);
    opti.subject_to(Qdots(orderQsOpp,end) + Qdots(orderQsOpp,1) == 0);
    % Muscle activations
    orderMusInv = [NMuscle/2+1:NMuscle,1:NMuscle/2];
    opti.subject_to(a(:,end) - a(orderMusInv,1) == 0);
    % Muscle-tendon forces
    opti.subject_to(FTtilde(:,end) - FTtilde(orderMusInv,1) == 0);
    % Arm activations
    orderArmInv = [4:6,1:3,8,7];
    opti.subject_to(a_a(:,end) - a_a(orderArmInv,1) == 0);
    % Mtp activations
    if S.Foot.mtp_actuator
        orderMtpInv = [jointi.mtp.r,jointi.mtp.l]-jointi.mtp.l+1;
        opti.subject_to(a_mtp(:,end) - a_mtp(orderMtpInv,1) == 0);
    end
    % PIM activations
    if S.Foot.PIM
        orderPIMInv = [2,1];
        opti.subject_to(a_PIM(:,end) - a_PIM(orderPIMInv,1) == 0);
    end
elseif S.Periodic
    opti.subject_to(Qs(:,end) - Qs(:,1) == 0);
    opti.subject_to(Qdots(:,end) - Qdots(:,1) == 0);
    opti.subject_to(Qs(:,end) + Qs(:,1) == 0);
    opti.subject_to(Qdots(:,end) + Qdots(:,1) == 0);
    % Muscle activations
    opti.subject_to(a(:,end) - a(:,1) == 0);
    % Muscle-tendon forces
    opti.subject_to(FTtilde(:,end) - FTtilde(:,1) == 0);
    % Arm activations
    opti.subject_to(a_a(:,end) - a_a(:,1) == 0);
    % Mtp activations
    if S.Foot.mtp_actuator
        opti.subject_to(a_mtp(:,end) - a_mtp(:,1) == 0);
    end
    % PIM activations
    if S.Foot.PIM
        opti.subject_to(a_PIM(:,end) - a_PIM(:,1) == 0);
    end
end
% Average speed
% Provide expression for the distance traveled
Qs_nsc = Qs.*(scaling.QsQdots(1:2:end)'*ones(1,N+1));
dist_trav_tot = Qs_nsc(jointi.pelvis.tx,end) -  Qs_nsc(jointi.pelvis.tx,1);
vel_aver_tot = dist_trav_tot/tf;
opti.subject_to(vel_aver_tot - S.v_tgt == 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scale cost function
Jall_sc = sum(Jall)/dist_trav_tot;
if S.Foot.PIM
    J_2all_sc = W.P_PIM*sum(J_2all)^2/dist_trav_tot;
    Jall_sc = Jall_sc + J_2all_sc;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create NLP solver
opti.minimize(Jall_sc);
options.ipopt.hessian_approximation = 'limited-memory';
options.ipopt.mu_strategy           = 'adaptive';
options.ipopt.max_iter              = S.max_iter;
options.ipopt.linear_solver         = S.linear_solver;
options.ipopt.tol                   = 1*10^(-S.tol_ipopt);
opti.solver('ipopt', options);
% Create and save diary
OutFolder = fullfile(S.ResultsRepo,S.ResultsFolder);
if ~isfolder(OutFolder)
    mkdir(OutFolder);
end
Outname = fullfile(OutFolder,[S.savename '_log.txt']);
diary(Outname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solve problem
% Opti does not use bounds on variables but constraints. This function
% adjusts for that.
%     opti.solve();
[w_opt,stats] = solve_NLPSOL(opti,options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diary off
% Extract results
% Create setup
setup.tolerance.ipopt = S.tol_ipopt;
setup.bounds = bounds;
setup.scaling = scaling;
setup.guess = guess;

%% Save the results
Outname = fullfile(OutFolder,[S.savename '.mat']);
Sopt = S;
save(Outname,'w_opt','stats','setup','Sopt');
end

