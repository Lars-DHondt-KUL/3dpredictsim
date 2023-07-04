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
    S.N         = 100;       
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
    if strcmp(S.subject,'Fal_s1')
        S.IG_PelvisY = 0.9385;
    end
end

% default settings walking speed
if ~isfield(S,'v_tgt') || isempty(S.v_tgt)
    S.v_tgt = 1.33;
end



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
    elseif contains(S.Foot.Model,'mtp')
        S.IKfile_Bounds = 'OpenSimModel\IK_Bounds_Default.mat';
    end
end

% default IK file for initial guess (when used data-informed guess)
if ~isfield(S,'IKfile_guess')
    if contains(S.Foot.Model,'mtj')
        S.IKfile_guess = 'OpenSimModel\IK_Guess_Default_mtj.mat';
    elseif contains(S.Foot.Model,'mtp')
        S.IKfile_guess = 'OpenSimModel\IK_Guess_Default.mat';
    end
end


%%
if ~isfield(S,'AchillesTendonScaleFactor') || isempty(S.AchillesTendonScaleFactor)
    S.AchillesTendonScaleFactor = 0.5;
end

if ~isfield(S,'SoleusTendonShorter') || isempty(S.SoleusTendonShorter)
    S.SoleusTendonShorter = 0;
end

if ~isfield(S,'GastrocTendonShorter') || isempty(S.GastrocTendonShorter)
    S.GastrocTendonShorter = 0;
end

if ~isfield(S.Foot,'kMTP') || isempty(S.Foot.kMTP)
    S.Foot.kMTP = 25;
end
if ~isfield(S.Foot,'dMTP') || isempty(S.Foot.dMTP)
    S.Foot.dMTP = 2;
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

% custom or isometric scaling
if ~isfield(S.Foot,'Scaling') || isempty(S.Foot.Scaling)
    S.Foot.Scaling = 'custom';
end

% use adapted muscle insertions on midfoot
if ~isfield(S,'MTparams') || isempty(S.MTparams)
    if strcmp(S.Foot.Scaling,'custom')
        S.MTparams = 'MTc5';
    else
        S.MTparams = '';
    end
end

if ~isfield(S.Foot,'insole_Takahashi_kMTP')
    S.Foot.insole_Takahashi_kMTP = 0;
end

if ~isfield(S.Foot,'insole_Stearne')
    S.Foot.insole_Stearne = [];
end

end