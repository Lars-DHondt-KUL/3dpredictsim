% --------------------------------------------------------------------------
% AdaptOpenSimModel
%   This framework uses an OpenSim model file as input. Commonly used models 
%   do not contain all information needed to formulate the simulation. This
%   script adapts a given .osim file to include Contact elements
% 
% Original author: Lars D'Hondt
% Original date: 27/May/2022
%
% Last edit by: 
% Last edit date: 
% --------------------------------------------------------------------------


clear
clc
[pathHere,~,~] = fileparts(mfilename('fullpath'));

% .osim file to adapt
path_osim_in = fullfile(pathHere,'Fal_s1_mtppin_FK_sd_cg0.osim');

% adapted .osim file
path_osim_out = fullfile(pathHere,'Fal_s1_mtppin_FK_sd_cg0.osim');


%% Define contact spheres
% https://github.com/antoinefalisse/3dpredictsim/blob/mtp_paper/ExternalFunctions/PredSim_SSCM_pp.cpp

% contact spheres right side
csp = 1;

% name of parent body
contact_spheres(csp).body = 'calcn_r';
% name of contact sphere
contact_spheres(csp).name = 's1_r';
% location in parent frame
contact_spheres(csp).location = [0.0035613, -0.021859, 0.012288];
% radius of sphere
contact_spheres(csp).radius = 0.048;
csp = csp+1;

contact_spheres(csp).body = 'calcn_r';
contact_spheres(csp).name = 's2_r';
contact_spheres(csp).location = [0.041235, -0.021859, 0.0015407];
contact_spheres(csp).radius = 0.046559;
csp = csp+1;

contact_spheres(csp).body = 'forefoot_r';
contact_spheres(csp).name = 's3_r';
contact_spheres(csp).location = [0.17339, -0.021859, -0.0037135];
contact_spheres(csp).radius = 0.039207;
csp = csp+1;

contact_spheres(csp).body = 'forefoot_r';
contact_spheres(csp).name = 's4_r';
contact_spheres(csp).location = [0.11755, -0.021859, 0.026721];
contact_spheres(csp).radius = 0.016006;
csp = csp+1;

contact_spheres(csp).body = 'toes_r';
contact_spheres(csp).name = 's5_r';
contact_spheres(csp).location = [0.057046, -0.021448, -0.0071363];
contact_spheres(csp).radius = 0.032;
csp = csp+1;

contact_spheres(csp).body = 'toes_r';
contact_spheres(csp).name = 's6_r';
contact_spheres(csp).location = [0.03191, -0.021448, 0.036857];
contact_spheres(csp).radius = 0.030695;
csp = csp+1;


%%

import org.opensim.modeling.*;
model = Model(path_osim_in);
s = model.initSystem;
calcn_or = model.getBodySet().get('calcn_r').findBaseFrame().getPositionInGround(s).getAsMat;
forefoot_or = model.getBodySet().get('forefoot_r').findBaseFrame().getPositionInGround(s).getAsMat;
offset = forefoot_or - calcn_or;

for i=1:length(contact_spheres)
    if strcmp(contact_spheres(i).body,'forefoot_r')
        contact_spheres(i).location = contact_spheres(i).location - offset';
    end
end

model.print(path_osim_out);



% mirror to get left side
for i=1:length(contact_spheres)
    contact_spheres(csp).body = [contact_spheres(i).body(1:end-1) 'l'];
    contact_spheres(csp).name = [contact_spheres(i).name(1:end-1) 'l'];
    contact_spheres(csp).location = contact_spheres(i).location;
    contact_spheres(csp).location(3) = -contact_spheres(csp).location(3);
    contact_spheres(csp).radius = contact_spheres(i).radius;
    csp = csp+1;
end






%%

add_contact_spheres(path_osim_out,contact_spheres)


