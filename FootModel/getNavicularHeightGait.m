


nr = length(ResultsFile);

figure
hold on

for inr=1:nr
    load(ResultsFile{inr},'R');


    [h_nav] = getNavicularHeightGait2(R);


    plot(h_nav*1e3,'DisplayName',R.S.savename)
end

legend('Interpreter','none')




function [h_nav] = getNavicularHeightGait2(R)
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

midfoot_fr = model.getBodySet().get('midfoot_r').findBaseFrame();

h_nav = nan(size(R.Qs,1),1);


% loop over time
for i=1:size(R.Qs,1)
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


    osimVec3 = Vec3.createFromMat([0.00645768 0.00744676 -0.0479717]);
%     osimVec3 = Vec3.createFromMat([0.0639702 -0.011406 0.0227487]);
%     osimVec3 = Vec3.createFromMat([0.0639702 -0.011406 -0.00843405]);

    nav = midfoot_fr.findStationLocationInGround(state,osimVec3).getAsMat;

    h_nav(i) = nav(2);

end




end