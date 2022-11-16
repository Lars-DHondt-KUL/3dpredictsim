function [sphere_pos,sphere_vel] = getSphereInGroundFrame(R,body,loc_sphere)
import org.opensim.modeling.*;

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
osimpath = (fullfile(pathRepo, 'OpenSimModel','subject1'));


osimFiles = dir(fullfile(osimpath,[R.S.OsimFileName '*.osim']));

model_path = fullfile(osimpath,osimFiles(1).name);

% load model
model = Model(model_path);
% initialize
state = model.initSystem;
% Get state vector
state_vector = model.getStateVariableValues(state);
% Set state vector to 0
state_vector.setToZero();
model.setStateVariableValues(state,state_vector);

model.realizePosition(state);

% coordinates
coord_set = model.getCoordinateSet();
n_coord = coord_set.getSize();
coord_names = cell(1,n_coord);
is_rotation = zeros(1,n_coord);
for i=1:n_coord
    % opensim api indexing starts at 0, so use i-1
    coord_names{i} = coord_set.get(i-1).getName();
    is_rotation(i) = strcmp(coord_set.get(i-1).getMotionType(),"Rotational");
end

% calcn frame
body_fr = model.getBodySet().get(body).findBaseFrame();

sphere_pos = nan(size(R.Qs,1),3);


% loop over time
for i=1:size(R.Qs,1)
    % loop over coordinates to set value
    for j=1:n_coord
        % index of coordinate in data from mot file
        idx = find(strcmp(R.colheaders.joints,string(coord_names(j))));
        % coordinate value
        q_ij = R.Qs(i,idx);
        qd_ij = R.Qdots(i,idx);
        % need rotations in radians
        if is_rotation(j)
            q_ij = q_ij*pi/180;
            qd_ij = qd_ij*pi/180;
        end
        % set coordinate value
        coord_set.get(coord_names{j}).setValue(state,q_ij);
        coord_set.get(coord_names{j}).setSpeedValue(state,qd_ij);

    end

    % calculate model kinematics (positions) for state
%     model.realizePosition(state);
    model.realizeVelocity(state);

    pos_i = Vec3.createFromMat(loc_sphere);
    sphere_pos_i = body_fr.findStationLocationInGround(state,pos_i).getAsMat;
    sphere_vel_i = body_fr.findStationVelocityInGround(state,pos_i).getAsMat;


    sphere_pos(i,:) = sphere_pos_i;
    sphere_vel(i,:) = sphere_vel_i;

end




