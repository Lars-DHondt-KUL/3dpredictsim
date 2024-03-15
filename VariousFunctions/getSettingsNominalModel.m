function [S] = getSettingsNominalModel(Nsegments)

[pathRepo,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathRepo);

S.ResultsRepo = fullfile(pathRepo,'Results');


%% settings for optimization
S.N = 100; % number of mesh intervals
S.suffixName = 'N100'; % suffix for name of file with results


%% Foot model
%-------------------------------------------------------------------------%
%
%% General
if Nsegments == 3 % foot with mtp joint
   S.Foot.Model = 'mtp';
   S.ResultsFolder = 'results_paper';

elseif Nsegments == 4 % foot with mtp and midtarsal joint
    S.Foot.Model = 'mtjcf3';
    S.ResultsFolder = 'results_paper_v2';

else
    error('number of foot segments should be 3 or 4')
end

S.Foot.Scaling = 'custom'; % default, custom

% fixed knee axis
S.fixed_knee = 1;

% Achilles tendon stiffness
S.AchillesTendonScaleFactor = 0.5;

% Triceps surae optimal force scale
S.TricepsFMoScale = 1.2;

% Shift passive force-length curve of ankle muscle fibers
S.passiveFiberForceShift = -0.1;


% Contact spheres
S.Foot.contactStiffnessFactor = 10;  % 1 or 10, 10: contact spheres are 10x stiffer
S.Foot.contactGeometryVersion = 9; %(-1)
S.Foot.contactSphereOffsetY = 0; %(3)    % contact spheres are offset in y-direction to match static trial IK
S.Foot.contactSphereOffset45Z = 0; % contact spheres 4 and 5 are offset to give wider contact area
S.Foot.contactSphereOffset1X = 0.010;   % heel contact sphere offset in x-direction (0.025)

%% metatarsophalangeal (mtp) joint
if strcmp(S.Foot.Model(1:3),'mtp')
    % preset for passive mtp
    S.Foot.mtp_muscles = 0;     % extrinsic toe flexors and extensors act on mtp joint
    S.Foot.kMTP = 25;            % additional stiffness of the joint (Nm/rad)
    S.Foot.dMTP = 2;          % additional damping of the joint (Nms/rad)
else
    % preset for muscle-driven mtp
    S.Foot.mtp_muscles = 1;     % extrinsic toe flexors and extensors act on mtp joint
    S.Foot.kMTP = 1;            % additional stiffness of the joint (Nm/rad)
    S.Foot.dMTP = 0.1;          % additional damping of the joint (Nms/rad)
end

S.Foot.mtp_tau_pass = 1;    % use passive bushing torque
S.Foot.mtp_M_PF = 0;        % apply plantar fascia stiffness to mtp joint only
S.Foot.mtp_actuator = 0;    % use an ideal torque actuator

%% midtarsal joint 
% (only used if Model = mtj)
S.Foot.mtj_muscles = 1;  % joint interacts with extrinsic foot muscles
% lumped ligaments (long, short planter ligament, etc)
S.Foot.MT_li_nonl = 1;       % 1: nonlinear torque-angle characteristic
S.Foot.mtj_stiffness = 'lig';
S.Foot.mtj_sf = 1; 

S.Foot.kMT_li = 400;        % angular stiffness in case of linear
S.Foot.kMT_li2 = 50;        % angular stiffness in case of signed linear
S.Foot.dMT = 0.1;           % (Nms/rad) damping

% plantar fascia
S.Foot.PF_stiffness = 'Natali2010'; % 'none''linear''Gefen2002''Cheng2008''Natali2010''Song2011'
S.Foot.PF_sf = 1; % scale factor on force
S.Foot.PF_sf_isvar = 0; % scale factor variable over gait cycle
S.Foot.PF_slack_length = 0.146; % (m) slack length


if strcmp(S.Foot.Model(1:3),'mtj')
    % Plantar Intrinsic Muscles represented by Flexor Digitorum Brevis
    S.Foot.FDB = 2;             % include Flexor Digitorum Brevis
    % optimal fibre length
    S.Foot.FDB_lMo = 23e-3;
    % Tendon slack length
    S.Foot.FDB_lTs = 0.123; 
    % Shift fiber passive force-length curve
    S.Foot.FDB_shift = -0.1;
    % scale FMo
    S.Foot.FDB_sf_FMo = 1;
    % apply nerve block (activation constrained to baseline)
    S.Foot.FDB_nerveBlock = 0;
else
    S.Foot.FDB = 0;
    S.Foot.FDB_lMo = 23e-3;
    S.Foot.FDB_lTs = 0.123;
    S.Foot.FDB_shift = -0.1;
    S.Foot.FDB_sf_FMo = 1;
    S.Foot.FDB_nerveBlock = 0;
end



end % end of function