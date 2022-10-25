function [out] = OpenSim_body_frames(model_path,mot_path,intrvl)
%--------------------------------------------------------------------------
% Example of extracting body positions and orientations from OpenSim model
% based on results on coordinates
%
% Author: Lars D'Hondt
% Date: 24/August/2022
%
%--------------------------------------------------------------------------

% opensim api
import org.opensim.modeling.*;
% use methodsview(object) to display methods for that object


%_path = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21.mot';

% load .mot file
mot_data = importdata(mot_path);

% number of data points
n_time = size(mot_data.data,1);

% load model
model = Model(model_path);
% initialize
state = model.initSystem;
% Get state vector
state_vector = model.getStateVariableValues(state);
% Set state vector to 0
state_vector.setToZero();
model.setStateVariableValues(state,state_vector);

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

% bodies
body_set = model.getBodySet();
n_body = body_set.getSize();
body_names = cell(1,n_body);
for i=1:n_body
    % api indexing starts at 0, so use i-1
    body_names{i} = body_set.get(i-1).getName();
end


% get Qs and Qdots
if isempty(intrvl)
    intrvl = mot_data.data(:,1);
end

for i=1:n_coord
    qi = interp1(mot_data.data(:,1),mot_data.data(:,i+1),intrvl);
    PP = spline(intrvl,qi);
    [Qsi,Qdotsi,~] = SplineEval_ppuval(PP,intrvl,1);
    Qs(:,i) = Qsi;
    Qdots(:,i) = Qdotsi;
end

%%
H_all = nan(n_time,n_body,4,4);
pos = nan(length(intrvl),n_body,3);
vel = pos;
omega = pos;
rot = nan(length(intrvl),n_body,9);

% loop over time
for i=1:length(intrvl)
    % loop over coordinates to set value
    for j=1:n_coord
        % index of coordinate in data from mot file
        idx = find(strcmp(mot_data.colheaders,string(coord_names(j))));
        % coordinate value
        q_ij = Qs(i,idx-1);
        qd_ij = Qdots(i,idx-1);
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
    model.realizeVelocity(state);

    % loop over bodies to get transformation matrix
    for j=1:n_body
        % Transform
        transform_ij = body_set.get(body_names{j}).getTransformInGround(state);
        % extract rotation matrix
        rot_ij = convert_Mat33(transform_ij.R().asMat33());
        % extract position vector
        trl_ij = transform_ij.T().getAsMat;
    
        %
        pos_ij = body_set.get(body_names{j}).getPositionInGround(state).getAsMat;
        vel_ij = body_set.get(body_names{j}).getVelocityInGround(state);
        v_ij = vel_ij.get(1).getAsMat;
        omega_ij = vel_ij.get(0).getAsMat;




        pos(i,j,:) = pos_ij(:);
        vel(i,j,:) = v_ij(:);
        omega(i,j,:) = omega_ij(:);
        rot(i,j,:) = reshape(rot_ij,9,1);
        
%         % construct homogeneous transformation matrix
%         H_ij = eye(4);
%         H_ij(1:3,1:3) = rot_ij;
%         H_ij(1:3,4) = trl_ij;
% 
%         H_all(i,j,:,:) = H_ij;
    end


end


for j=1:n_body
    tmp.pos = squeeze(pos(:,j,:));
    tmp.v_lin = squeeze(vel(:,j,:));
    tmp.omega = squeeze(omega(:,j,:));
    tmp.R = squeeze(rot(:,j,:));

    out.(char(body_names{j})) = tmp;
end

% helper function to convert OpenSim Mat33 type to 3x3 double matrix
function mat3x3 = convert_Mat33(mat33)
mat3x3 = nan(3,3);
for ii=1:3
    for jj=1:3
        mat3x3(ii,jj) = mat33.get(ii-1,jj-1);
    end
end %for
end %convert_Mat33
end %function