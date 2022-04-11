function [S] = GetDefaultSettings(S)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% solver settings
if ~isfield(S,'linear_solver')    
    S.linear_solver = 'mumps';
end

if ~isfield(S,'tol_ipopt')
    S.tol_ipopt     = 4;
end

if ~isfield(S,'max_iter')
    S.max_iter     = 10000;
end

if ~isfield(S,'savename_ig')
    S.savename_ig= [];
end

if ~isfield(S,'ResultsF_ig')
    S.ResultsF_ig = [];
end

% parallel computation settings
if ~isfield(S,'parallelMode')
    S.parallelMode = 'thread';
end

if  ~isfield(S,'NThreads') || isempty(S.NThreads)
    S.NThreads = 4;
end

% default number of mesh intervals
if ~isfield(S,'N') || isempty(S.N)
    S.N         = 50;       
end

% default number of mesh intervals
if ~isfield(S,'tanh_b') || isempty(S.tanh_b)
    S.tanh_b         = 100;       
end

%% subject settings
if ~isfield(S,'subject') || isempty(S.subject)
    S.subject = 'Fal_s1';
end

if ~isfield(S,'mass') || isempty(S.mass)
    S.mass = 62;
end

% quasi random initial guess
if ~isfield(S,'IG_PelvisY') || isempty(S.IG_PelvisY)
    if strcmp(S.subject,'s1_Poggensee')
        S.IG_PelvisY = 0.896;   % subject 1 poggensee
    else
        S.IG_PelvisY = 0.9385;  % subject 1
    end
end

% default settings walking speed
if ~isfield(S,'v_tgt') || isempty(S.v_tgt)
    S.v_tgt = 1.33;
end


S.ModelName = 'Gait92';

%% default weights
if isfield(S,'W')
    if ~isfield(S.W,'E')
        S.W.E       = 500;      % weight metabolic energy rate
    end
    if ~isfield(S.W,'Ak')
        S.W.Ak      = 50000;    % weight joint accelerations
    end
    if ~isfield(S.W,'ArmE')
        S.W.ArmE    = 10^6;     % weight arm excitations
    end
    if ~isfield(S.W,'passMom')
        S.W.passMom = 1000;     % weight passive torques
    end
    if ~isfield(S.W,'noDamping')
        S.W.noDamping = 0;      % do not use damping in penalty
    end
    if ~isfield(S.W,'A')
        S.W.A       = 2000;     % weight muscle activations
    end
    if ~isfield(S.W,'exp_E')
        S.W.exp_E   = 2;        % power metabolic energy
    end
    if ~isfield(S.W,'Mtp')
        S.W.Mtp     = 10^6;     % weight mtp excitations
    end
    if ~isfield(S.W,'PIM')
        S.W.PIM     = 10^3;     % weight PIM excitations
    end
    if ~isfield(S.W,'u')
        S.W.u       = 0.001;    % weight on excitations arms actuators
    end
    if ~isfield(S.W,'Lumbar')
        S.W.Lumbar  = 10^5;
    end
else
    S.W.E       = 500;      % weight metabolic energy rate
    S.W.Ak      = 50000;    % weight joint accelerations
    S.W.ArmE    = 10^6;     % weight arm excitations
    S.W.passMom = 1000;     % weight passive torques
    S.W.noDamping = 0;      % do not use damping in penalty
    S.W.A       = 2000;     % weight muscle activations
    S.W.exp_E   = 2;        % power metabolic energy
    S.W.Mtp     = 10^6;     % weight mtp excitations
    S.W.PIM     = 10^3;     % weight PIM excitations
    S.W.u       = 0.001;    % weight on excitations arms actuators
    S.W.Lumbar  = 10^5;
end

% initial guess identifier (1: quasi random, 2: data-based)
if ~isfield(S,'IGsel')
    S.IGsel     = 1;        
end

% initial guess mode identifier (1 walk, 2 run, 3prev.solution)
if ~isfield(S,'IGmodeID')
    S.IGmodeID  = 1;        
end

% initial guess case identifier
if ~isfield(S,'IGcase')    
    S.IGcase    = 0;        
end

% weakness hip actuators
if ~isfield(S,'h_weak')
    S.h_weak    = 0;     
end

% maximal contraction velocity identifier
if ~isfield(S,'Max_s')
    S.Max_s     = 0;    
end

% weakness ankle plantaflexors
if ~isfield(S,'pf_weak')
    S.pf_weak   = 0;      
end

% metabolic energy model identifier
if ~isfield(S,'mE')
    S.mE        = 0;       
end

% co-contraction identifier
if ~isfield(S,'coCont')
    S.coCont    = 0;        
end

% Kinematics Constraints - Default Settings
if isfield(S,'Constr')
    if ~isfield(S.Constr,'calcn')
        S.Constr.calcn = 0.09;  % by default at least 9cm distance between calcn
    end
    if ~isfield(S.Constr,'toes')
        S.Constr.toes = 0.1; % by default at least 10cm distance between toes
    end
    if ~isfield(S.Constr,'tibia')
        S.Constr.tibia = 0.11; % by default at least 11cm distance between toes
    end
else
    S.Constr.calcn = 0.09;  % by default at least 9cm distance between calcn
    S.Constr.toes = 0.1; % by default at least 10cm distance between toes
    S.Constr.tibia = 0.11; % by default at least 11cm distance between toes
end


% Settings related to bounds on muscle activations
if isfield(S,'Bounds')
    if ~isfield(S.Bounds,'ActLower')
        S.Bounds.ActLower = 0.05;
    end
    if ~isfield(S.Bounds,'ActLowerHip')
        S.Bounds.ActLowerHip = [];
    end
    if ~isfield(S.Bounds,'ActLowerKnee')
        S.Bounds.ActLowerKnee = [];
    end
    if ~isfield(S.Bounds,'ActLowerAnkle')
        S.Bounds.ActLowerAnkle = [];
    end
else
    S.Bounds.ActLower = 0.05;
    S.Bounds.ActLowerHip = [];
    S.Bounds.ActLowerKnee = [];
    S.Bounds.ActLowerAnkle = [];
end

% bounds on final time (i.e. imposing stride frequency / stride length)
if ~isfield(S.Bounds,'tf')
    S.Bounds.tf = [];
end

% scaling exoskeleton timing
if isfield(S,'PercStance')
    if ~isfield(S.PercStance,'bool')
        S.PercStance.bool = 0;        
    end
    if ~isfield(S.PercStance,'xStanceOr')
        S.PercStance.xStanceOr = 0.61; % duration stance phase in experiment
    end
    if ~isfield(S.PercStance,'xStanceNew')
        S.PercStance.xStanceNew = 0.58; % duration stance phase in simulation
    end
else
    S.PercStance.bool = 0;
end

% symmetric motion ?
if ~isfield(S,'Symmetric')
    S.Symmetric = true;
end

% periodic motion
if ~isfield(S,'Periodic')
    S.Periodic = false;
end

% model used
if ~isfield(S.Foot,'Model')
    S.Foot.Model = 'mtp';
    S.Foot.mtp_muscles = 0;
    S.Foot.contactStiffnessFactor = 1;
    S.Foot.contactSphereOffsetY = 0;
    S.Foot.contactSphereOffset45Z = 0;
    S.Foot.contactSphereOffset1X = 0;
    S.useMtpPinExtF = 0;
    S.TrackSim = 0;
    S.Foot.PIM = 0;
    S.Foot.mtj_muscles = 0;
end

% default IK file to determine bounds
if ~isfield(S,'IKfile_Bounds')
    if contains(S.Foot.Model,'mtj')
        S.IKfile_Bounds = 'OpenSimModel\IK_Bounds_Default_mtj.mat';
    elseif strcmp(S.Foot.Model,'mtp')
        S.IKfile_Bounds = 'OpenSimModel\IK_Bounds_Default.mat';
    end
end

% default IK file for initial guess (when used data-informed guess)
if ~isfield(S,'IKfile_guess')
    if contains(S.Foot.Model,'mtj')
        S.IKfile_guess = 'OpenSimModel\IK_Guess_Default_mtj.mat';
    elseif strcmp(S.Foot.Model,'mtp')
        S.IKfile_guess = 'OpenSimModel\IK_Guess_Default.mat';
    end
end

% path with exoskeleton torque profile
if ~isfield(S,'DataSet')
    S.DataSet = 'PoggenSee2020_AFO';
end

% Boolean for exoskeleton use
if ~isfield(S,'ExoBool')
    S.ExoBool       = 0;
end

% scaling assistance profile
if ~isfield(S,'ExoScale')
    S.ExoScale      = 0;        % scale factor of exoskeleton assistance profile = 0 (i.e. no assistance)
end

% choosing assistance profile or control law
if ~isfield(S,'ExoController')
    S.ExoController = 's1 Pog';
end

%%
if ~isfield(S,'AchillesTendonScaleFactor') || isempty(S.AchillesTendonScaleFactor)
    S.AchillesTendonScaleFactor = 1;
end

if ~isfield(S,'SoleusTendonShorter') || isempty(S.SoleusTendonShorter)
    S.SoleusTendonShorter = 0;
end

if ~isfield(S.Foot,'kMTP') || isempty(S.Foot.kMTP)
    S.Foot.kMTP = 1.5/(pi/180)/5;
end
if ~isfield(S.Foot,'dMTP') || isempty(S.Foot.dMTP)
    S.Foot.dMTP = 0.5;
end

if ~isfield(S.Foot,'dMT') || isempty(S.Foot.dMT)
    S.Foot.dMT = 0.1;
end

if ~isfield(S.Foot,'FDB') || isempty(S.Foot.FDB)
    S.Foot.FDB = 0;
end
if S.Foot.FDB
    S.Foot.PIM = 0;
end

% Print the settings to the screen
disp(S);





end

