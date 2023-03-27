function [h_nav] = getNavicularHeight(R,model_path)

Qs = R.Qs;
colheaders = {'tibia_tilt','tibia_list','tibia_rotation','tibia_tx','tibia_ty',...
    'tibia_tz','ankle_angle_r','subtalar_angle_r','mtj_angle_r','mtp_angle_r'};


% opensim api
import org.opensim.modeling.*;
% use methodsview(object) to display methods for that object


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
    coord_names{i} = char(coord_set.get(i-1).getName());
    is_rotation(i) = strcmp(coord_set.get(i-1).getMotionType(),"Rotational");
end

midfoot_fr = model.getBodySet().get('midfoot_r').findBaseFrame();

n_mtp = size(Qs,1);
n_tib = size(Qs,2);

h_nav = nan(n_mtp,n_tib);

% loop over time
for i=1:n_mtp
    for ii=1:n_tib
        % loop over coordinates to set value
        for j=1:n_coord
            % index of coordinate in data from mot file
            idx = find(strcmp(strip(colheaders),coord_names(j)));
            % coordinate value
            q_ij = Qs(i,ii,idx);
            % need rotations in radians
            if is_rotation(j)
                q_ij = q_ij*pi/180;
            end
            % set coordinate value
            coord_set.get(coord_names{j}).setValue(state,q_ij);
    
        end
    
        % calculate model kinematics for state
        model.realizePosition(state);

        osimVec3 = Vec3.createFromMat([0.00645768 0.00744676 -0.0479717]);
        nav = midfoot_fr.findStationLocationInGround(state,osimVec3).getAsMat;

        h_nav(i,ii) = nav(2);
    end

end


end