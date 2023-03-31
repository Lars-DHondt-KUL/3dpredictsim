%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script aims to reproduce the simulation results shown in
%
% "A dynamic foot model for predictive simulations of (human) gait reveals 
% causal relations between foot structure and whole body mechanics"
% https://www.biorxiv.org/content/10.1101/2023.03.22.533790v1
%
% Do note that each simulation takes 3 hours or more.
%
% Author: Lars D'Hondt
% Date: March 2023
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
close all
clc

%% Required user inputs
% Specify the folder where you downloaded CasADi
% (https://web.casadi.org/get/)
casadiPath = 'C:\GBW_MyPrograms\casadi_3_5_5';

if ~exist(casadiPath,'file')
    error('Please download CasADi and specify the location in "casadiPath"')
end


%%
[pathRepo,~,~] = fileparts(mfilename('fullpath'));
addpath([pathRepo '/OCP']);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/Plots']);
addpath([pathRepo '/CasADiFunctions']);
addpath([pathRepo '/Musclemodel']);
addpath([pathRepo '/Polynomials']);
addpath([pathRepo '/FootModel']);
addpath([pathRepo '/RunSim']);

addpath(genpath(casadiPath))


%% Nominal 3-segment foot model
% get settings struct for nominal model
[S] = getSettingsNominalModel(3);
% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Nominal 2-segment foot model
% get settings struct for nominal model
[S] = getSettingsNominalModel(2);
% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Falisse's 2-segment foot model
% get settings struct for nominal model
[S] = getSettingsNominalModel(2);

% Changes w.r.t. nominal model
% MTP axis normal to sagittal plane
S.Foot.Model = 'mtppin';
% Default (i.e. uniform) scaling of foot
S.Foot.Scaling = 'default';
% Default Achilles tendon stiffness
S.AchillesTendonScaleFactor = 1;
% Default triceps surae maximal isometric force
S.TricepsFMoScale = 1;
% Default passive fibre force
S.passiveFiberForceShift = 0;
% Contact stiffness 1 MPa
S.Foot.contactStiffnessFactor = 1;
% Contact sphere configuration
S.Foot.contactGeometryVersion = 1; 
% No offset on heel contact sphere
S.Foot.contactSphereOffset1X = 0;

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Reduced contact stiffness (3-segment)
% get settings struct for nominal model
[S] = getSettingsNominalModel(3);

% Changes w.r.t. nominal model
% Contact stiffness 1 MPa
S.Foot.contactStiffnessFactor = 1;

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Reduced contact stiffness (2-segment)
% get settings struct for nominal model
[S] = getSettingsNominalModel(2);

% Changes w.r.t. nominal model
% Contact stiffness 1 MPa
S.Foot.contactStiffnessFactor = 1;

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Stiffer Achilles tendon (3-segment)
% get settings struct for nominal model
[S] = getSettingsNominalModel(3);

% Changes w.r.t. nominal model
% Default Achilles tendon stiffness
S.AchillesTendonScaleFactor = 1;

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Stiffer Achilles tendon (2-segment)
% get settings struct for nominal model
[S] = getSettingsNominalModel(2);

% Changes w.r.t. nominal model
% Default Achilles tendon stiffness
S.AchillesTendonScaleFactor = 1;

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Without intrinsic foot muscle
% get settings struct for nominal model
[S] = getSettingsNominalModel(3);

% Changes w.r.t. nominal model
% No plantar intrinsic foot muscle (represented by Flexor Digitorum Brevis)
S.Foot.FDB = 0;

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Compliant plantar fascia
% get settings struct for nominal model
[S] = getSettingsNominalModel(3);

% Changes w.r.t. nominal model
% Plantar fascia stress-strain according to Gefen (2002)
S.Foot.PF_stiffness = 'Gefen2002';

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Compliant plantar fascia and without intrinsic foot muscle
% get settings struct for nominal model
[S] = getSettingsNominalModel(3);

% Changes w.r.t. nominal model
% Plantar fascia stress-strain according to Gefen (2002)
S.Foot.PF_stiffness = 'Gefen2002';
% No plantar intrinsic foot muscle (represented by Flexor Digitorum Brevis)
S.Foot.FDB = 0;

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)

%% Reduced arch height (3-segment)
% get settings struct for nominal model
[S] = getSettingsNominalModel(3);

% Changes w.r.t. nominal model
% Default (i.e. uniform) scaling of foot
S.Foot.Scaling = 'default';
% Midtarsal joint axis orientation 3 (optimal for low arch)
S.Foot.Model = 'mtjc3';

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)


%% Conceptual chimpanzee
% get settings struct for nominal model
[S] = getSettingsNominalModel(3);

% Changes w.r.t. nominal model
% Default (i.e. uniform) scaling of foot
S.Foot.Scaling = 'default';
% No plantar fascia
S.Foot.PF_stiffness = 'none';

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)


%% Intrinsic foot muscle nerve block
% get settings struct for nominal model
[S] = getSettingsNominalModel(3);

% Changes w.r.t. nominal model
% Constrain activity of intrinsic foot muscle equal to its lower bound
S.Foot.FDB_nerveBlock = 1;
% warm-start initial guess
S.IGsel = 2;

% start simulation
PredSim(S,1,1,0); % (solve, post-process, do not add to batch)


%% ----------------------------------------------------------------------%%
% Reproduce figures
%%-----------------------------------------------------------------------%%
% Reference data from literature is not included

% figure 1
plot_paper_figure_static; % note: this will run the static simulations, but they are very fast

% figure 2
plot_figure_paper_gait;

% figure 3
plot_figure_paper_UD;

% figure 4
plot_figure_paper_ATStiffness;

% figure 5
plot_figure_paper_plantar_stiffness;

% figure 6
plot_figure_paper_chimp;















