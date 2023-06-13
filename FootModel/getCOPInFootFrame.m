function [COP_in_calcn,COP_wrt_talus_in_calcn,talus_or] = getCOPInFootFrame(R)
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
% talus_or = model.getBodySet().get('talus_r').findBaseFrame().getPositionInGround(state).getAsMat
% toes_or_mtj = model.getBodySet().get('toes_r').findBaseFrame().getPositionInGround(state).getAsMat

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
calcn_fr = model.getBodySet().get('calcn_r').findBaseFrame();
% talus frame
talus_fr = model.getBodySet().get('talus_r').findBaseFrame();
% ground frame
gnd = model.getGround();

COP_in_ground = R.COPR;
COP_in_calcn = nan(size(COP_in_ground));
COP_wrt_talus_in_calcn = nan(size(COP_in_ground));
talus_or = nan(size(COP_in_ground));

% loop over time
for i=1:ceil(R.Event.Stance/100*(size(R.Qs,1)-1))
    % loop over coordinates to set value
    for j=1:n_coord
        % index of coordinate in data from mot file
        idx = find(strcmp(R.colheaders.joints,string(coord_names(j))));
        % coordinate value
        q_ij = R.Qs(i,idx);
        % need rotations in radians
        if is_rotation(j)
            q_ij = q_ij*pi/180;
        end
        % set coordinate value
        coord_set.get(coord_names{j}).setValue(state,q_ij);

    end

    % calculate model kinematics (positions) for state
    model.realizePosition(state);

    COP_i = Vec3.createFromMat(COP_in_ground(i,:));
    COPf_i = gnd.findStationLocationInAnotherFrame(state,COP_i,calcn_fr).getAsMat;
    COPt_i = gnd.findStationLocationInAnotherFrame(state,COP_i,talus_fr);

    COP_tf_i = talus_fr.expressVectorInAnotherFrame(state,COPt_i,calcn_fr).getAsMat;

    COP_in_calcn(i,:) = COPf_i;
    COP_wrt_talus_in_calcn(i,:) = COP_tf_i;


    talus_or(i,:) = model.getBodySet().get('talus_r').findBaseFrame().getPositionInGround(state).getAsMat;

end




