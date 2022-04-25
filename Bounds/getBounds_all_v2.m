% This script provides bounds and scaling factors for the design variables.
% The bounds on the joint variables are informed by experimental data.
% The bounds on the remaining variables are fixed.
% The bounds are scaled such that the upper/lower bounds cannot be
% larger/smaller than 1/-1.
%
% Author: Antoine Falisse
% Date: 12/19/2018
%
function [bounds,scaling] = getBounds_all_v2(Qs_IK,NMuscle,nq,jointi,v_tgt,midtarsal)


Qs_IK_upper = max(Qs_IK.Qall_mean + 2*Qs_IK.Qall_std,[],1)*pi/180;
Qs_IK_lower = min(Qs_IK.Qall_mean - 2*Qs_IK.Qall_std,[],1)*pi/180;

Qdots_IK_upper = max(Qs_IK.Qdotall_mean + 2*Qs_IK.Qdotall_std,[],1)*pi/180;
Qdots_IK_lower = min(Qs_IK.Qdotall_mean - 2*Qs_IK.Qdotall_std,[],1)*pi/180;

Qddots_IK_upper = max(Qs_IK.Qddotall_mean + 2*Qs_IK.Qddotall_std,[],1)*pi/180;
Qddots_IK_lower = min(Qs_IK.Qddotall_mean - 2*Qs_IK.Qddotall_std,[],1)*pi/180;

%% Spline approximation of Qs to get Qdots and Qdotdots
% Qs_spline.data = zeros(size(Qs_IK.allfilt));
% Qs_spline.data(:,1) = Qs_IK.allfilt(:,1);
% Qdots_spline.data = zeros(size(Qs_IK.allfilt));
% Qdots_spline.data(:,1) = Qs_IK.allfilt(:,1);
% Qdotdots_spline.data = zeros(size(Qs_IK.allfilt));
% Qdotdots_spline.data(:,1) = Qs_IK.allfilt(:,1);
% for i = 2:size(Qs_IK.allfilt,2)
%     Qs_IK.datafiltspline(i) = spline(Qs_IK.allfilt(:,1),Qs_IK.allfilt(:,i));
%     [Qs_spline.data(:,i),Qdots_spline.data(:,i),...
%         Qdotdots_spline.data(:,i)] = ...
%         SplineEval_ppuval(Qs_IK.datafiltspline(i),Qs_IK.allfilt(:,1),1);
% end

%% Qs
% The extreme values are selected as upper/lower bounds, which are then
% further extended.
% Pelvis tilt
bounds.Qs.upper(jointi.pelvis.tilt) = max((Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tilt'))));
bounds.Qs.lower(jointi.pelvis.tilt) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tilt')));
% Pelvis list
bounds.Qs.upper(jointi.pelvis.list) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_list')),...
    abs(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_list'))));
bounds.Qs.lower(jointi.pelvis.list) = -bounds.Qs.upper(jointi.pelvis.list);
% Pelvis rot
bounds.Qs.upper(jointi.pelvis.rot) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_rotation')),...
    abs(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_rotation'))));
bounds.Qs.lower(jointi.pelvis.rot) = -bounds.Qs.upper(jointi.pelvis.rot);
% Hip flexion
bounds.Qs.upper(jointi.hip_flex.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'hip_flexion')));
bounds.Qs.lower(jointi.hip_flex.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'hip_flexion')));
bounds.Qs.upper(jointi.hip_flex.r) = bounds.Qs.upper(jointi.hip_flex.l);
bounds.Qs.lower(jointi.hip_flex.r) = bounds.Qs.lower(jointi.hip_flex.l);
% Hip adduction
bounds.Qs.upper(jointi.hip_add.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'hip_adduction')));
bounds.Qs.lower(jointi.hip_add.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'hip_adduction')));
bounds.Qs.upper(jointi.hip_add.r) = bounds.Qs.upper(jointi.hip_add.l);
bounds.Qs.lower(jointi.hip_add.r) = bounds.Qs.lower(jointi.hip_add.l);
% Hip rotation
bounds.Qs.upper(jointi.hip_rot.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'hip_rotation')));
bounds.Qs.lower(jointi.hip_rot.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'hip_rotation')));
bounds.Qs.upper(jointi.hip_rot.r) = bounds.Qs.upper(jointi.hip_rot.l);
bounds.Qs.lower(jointi.hip_rot.r) = bounds.Qs.lower(jointi.hip_rot.l);
% Knee
bounds.Qs.upper(jointi.knee.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'knee_angle')));
bounds.Qs.lower(jointi.knee.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'knee_angle')));
bounds.Qs.upper(jointi.knee.r) = bounds.Qs.upper(jointi.knee.l);
bounds.Qs.lower(jointi.knee.r) = bounds.Qs.lower(jointi.knee.l);
% Ankle
bounds.Qs.upper(jointi.ankle.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'ankle_angle')));
bounds.Qs.lower(jointi.ankle.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'ankle_angle')));
bounds.Qs.upper(jointi.ankle.r) = bounds.Qs.upper(jointi.ankle.l);
bounds.Qs.lower(jointi.ankle.r) = bounds.Qs.lower(jointi.ankle.l);
% Subtalar
bounds.Qs.upper(jointi.subt.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'subtalar_angle')));
bounds.Qs.lower(jointi.subt.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'subtalar_angle')));
bounds.Qs.upper(jointi.subt.r) = bounds.Qs.upper(jointi.subt.l);
bounds.Qs.lower(jointi.subt.r) = bounds.Qs.lower(jointi.subt.l);
% Trunk extension
bounds.Qs.upper(jointi.trunk.ext) = Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_extension'));
bounds.Qs.lower(jointi.trunk.ext) = Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_extension'));
% Trunk bending
bounds.Qs.upper(jointi.trunk.ben) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_bending')),...
    abs(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_bending'))));
bounds.Qs.lower(jointi.trunk.ben) = -bounds.Qs.upper(jointi.trunk.ben);
% Trunk rotation
bounds.Qs.upper(jointi.trunk.rot) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_rotation')),...
    abs(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_rotation'))));
bounds.Qs.lower(jointi.trunk.rot) = -bounds.Qs.upper(jointi.trunk.rot);
% Shoulder flexion
bounds.Qs.upper(jointi.sh_flex.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'arm_flex')));
bounds.Qs.lower(jointi.sh_flex.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'arm_flex')));
bounds.Qs.upper(jointi.sh_flex.r) = bounds.Qs.upper(jointi.sh_flex.l);
bounds.Qs.lower(jointi.sh_flex.r) = bounds.Qs.lower(jointi.sh_flex.l);
% Shoulder adduction
bounds.Qs.upper(jointi.sh_add.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'arm_add')));
bounds.Qs.lower(jointi.sh_add.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'arm_add')));
bounds.Qs.upper(jointi.sh_add.r) = bounds.Qs.upper(jointi.sh_add.l);
bounds.Qs.lower(jointi.sh_add.r) = bounds.Qs.lower(jointi.sh_add.l);
rec_uw_sh_add = bounds.Qs.upper(jointi.sh_add.l);
% Shoulder rotation
bounds.Qs.upper(jointi.sh_rot.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'arm_rot')));
bounds.Qs.lower(jointi.sh_rot.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'arm_rot')));
bounds.Qs.upper(jointi.sh_rot.r) = bounds.Qs.upper(jointi.sh_rot.l);
bounds.Qs.lower(jointi.sh_rot.r) = bounds.Qs.lower(jointi.sh_rot.l);
rec_uw_sh_rot = bounds.Qs.upper(jointi.sh_rot.l);
% Elbow
bounds.Qs.upper(jointi.elb.l) = max(Qs_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'elbow_flex')));
bounds.Qs.lower(jointi.elb.l) = min(Qs_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'elbow_flex')));
bounds.Qs.upper(jointi.elb.r) = bounds.Qs.upper(jointi.elb.l);
bounds.Qs.lower(jointi.elb.r) = bounds.Qs.lower(jointi.elb.l);
% The bounds are extended by twice the absolute difference between upper
% and lower bounds.
Qs_range = abs(bounds.Qs.upper - bounds.Qs.lower);
bounds.Qs.lower = bounds.Qs.lower - 1*Qs_range;
bounds.Qs.upper = bounds.Qs.upper + 1*Qs_range;
% For several joints, we manually adjust the bounds
% Pelvis_tx
bounds.Qs.upper(jointi.pelvis.tx) = 2;  
bounds.Qs.lower(jointi.pelvis.tx) = 0;
% Pelvis_ty
bounds.Qs.upper(jointi.pelvis.ty) = 1.1;  
bounds.Qs.lower(jointi.pelvis.ty) = 0.55;
% Pelvis_tz
bounds.Qs.upper(jointi.pelvis.tz) = 0.1;
bounds.Qs.lower(jointi.pelvis.tz) = -0.1;
% Mtp
bounds.Qs.upper(jointi.mtp.l) = 1.05;
bounds.Qs.lower(jointi.mtp.l) = -0.5;
bounds.Qs.upper(jointi.mtp.r) = 1.05;
bounds.Qs.lower(jointi.mtp.r) = -0.5;
% Mtj
if midtarsal
    bounds.Qs.upper(jointi.mtj.l) = 30*pi/180;
    bounds.Qs.lower(jointi.mtj.l) = -30*pi/180;
    bounds.Qs.upper(jointi.mtj.r) = 30*pi/180;
    bounds.Qs.lower(jointi.mtj.r) = -30*pi/180;
end
% Elbow
bounds.Qs.lower(jointi.elb.l) = 0;
bounds.Qs.lower(jointi.elb.r) = 0;
% Shoulder adduction
bounds.Qs.upper(jointi.sh_add.l) = rec_uw_sh_add;
bounds.Qs.upper(jointi.sh_add.r) = rec_uw_sh_add;
% Shoulder rotation
bounds.Qs.upper(jointi.sh_rot.l) = rec_uw_sh_rot;
bounds.Qs.upper(jointi.sh_rot.r) = rec_uw_sh_rot;
% We adjust some bounds when we increase the speed to allow for the
% generation of running motions.
if v_tgt > 1.33
    % Pelvis tilt
    bounds.Qs.lower(jointi.pelvis.tilt) = -20*pi/180;
    % Shoulder flexion
    bounds.Qs.lower(jointi.sh_flex.l) = -50*pi/180;
    bounds.Qs.lower(jointi.sh_flex.r) = -50*pi/180;
end

%% Qdots
% The extreme values are selected as upper/lower bounds, which are then
% further extended.
% Pelvis tilt
bounds.Qdots.upper(jointi.pelvis.tilt) = Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tilt'));
bounds.Qdots.lower(jointi.pelvis.tilt) = Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tilt'));
% Pelvis list
bounds.Qdots.upper(jointi.pelvis.list) = Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_list'));
bounds.Qdots.lower(jointi.pelvis.list) = Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_list'));
% Pelvis rotation
bounds.Qdots.upper(jointi.pelvis.rot) = Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_rotation'));
bounds.Qdots.lower(jointi.pelvis.rot) = Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_rotation'));
% Pelvis_tx
bounds.Qdots.upper(jointi.pelvis.tx) = Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tx')); 
bounds.Qdots.lower(jointi.pelvis.tx) = Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tx'));
% Pelvis_ty
bounds.Qdots.upper(jointi.pelvis.ty) = Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_ty')); 
bounds.Qdots.lower(jointi.pelvis.ty) = Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_ty')); 
% Pelvis_tz
bounds.Qdots.upper(jointi.pelvis.tz) = Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tz')); 
bounds.Qdots.lower(jointi.pelvis.tz) = Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tz'));
% Hip flexion
bounds.Qdots.upper(jointi.hip_flex.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'hip_flexion')));
bounds.Qdots.lower(jointi.hip_flex.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'hip_flexion')));
bounds.Qdots.upper(jointi.hip_flex.r) = bounds.Qdots.upper(jointi.hip_flex.l);
bounds.Qdots.lower(jointi.hip_flex.r) = bounds.Qdots.lower(jointi.hip_flex.l);
% Hip adduction
bounds.Qdots.upper(jointi.hip_add.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'hip_adduction')));
bounds.Qdots.lower(jointi.hip_add.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'hip_adduction')));
bounds.Qdots.upper(jointi.hip_add.r) = bounds.Qdots.upper(jointi.hip_add.l);
bounds.Qdots.lower(jointi.hip_add.r) = bounds.Qdots.lower(jointi.hip_add.l);
% Hip rotation
bounds.Qdots.upper(jointi.hip_rot.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'hip_rotation')));
bounds.Qdots.lower(jointi.hip_rot.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'hip_rotation')));
bounds.Qdots.upper(jointi.hip_rot.r) = bounds.Qdots.upper(jointi.hip_rot.l);
bounds.Qdots.lower(jointi.hip_rot.r) = bounds.Qdots.lower(jointi.hip_rot.l);
% Knee
bounds.Qdots.upper(jointi.knee.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'knee_angle')));
bounds.Qdots.lower(jointi.knee.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'knee_angle')));
bounds.Qdots.upper(jointi.knee.r) = bounds.Qdots.upper(jointi.knee.l);
bounds.Qdots.lower(jointi.knee.r) = bounds.Qdots.lower(jointi.knee.l);
% Ankle
bounds.Qdots.upper(jointi.ankle.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'ankle_angle')));
bounds.Qdots.lower(jointi.ankle.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'ankle_angle')));
bounds.Qdots.upper(jointi.ankle.r) = bounds.Qdots.upper(jointi.ankle.l);
bounds.Qdots.lower(jointi.ankle.r) = bounds.Qdots.lower(jointi.ankle.l);
% Subtalar
bounds.Qdots.upper(jointi.subt.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'subtalar_angle')));
bounds.Qdots.lower(jointi.subt.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'subtalar_angle')));
bounds.Qdots.upper(jointi.subt.r) = bounds.Qdots.upper(jointi.subt.l);
bounds.Qdots.lower(jointi.subt.r) = bounds.Qdots.lower(jointi.subt.l);
% Trunk extension
bounds.Qdots.upper(jointi.trunk.ext) = Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_extension'));
bounds.Qdots.lower(jointi.trunk.ext) = Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_extension'));
% Trunk bending
bounds.Qdots.upper(jointi.trunk.ben) = Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_bending'));
bounds.Qdots.lower(jointi.trunk.ben) = Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_bending'));
% Trunk rotation
bounds.Qdots.upper(jointi.trunk.rot) = Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_rotation'));
bounds.Qdots.lower(jointi.trunk.rot) = Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_rotation'));
% Shoulder flexion
bounds.Qdots.upper(jointi.sh_flex.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'arm_flex')));
bounds.Qdots.lower(jointi.sh_flex.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'arm_flex')));
bounds.Qdots.upper(jointi.sh_flex.r) = bounds.Qdots.upper(jointi.sh_flex.l);
bounds.Qdots.lower(jointi.sh_flex.r) = bounds.Qdots.lower(jointi.sh_flex.l);
% Shoulder adduction
bounds.Qdots.upper(jointi.sh_add.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'arm_add')));
bounds.Qdots.lower(jointi.sh_add.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'arm_add')));
bounds.Qdots.upper(jointi.sh_add.r) = bounds.Qdots.upper(jointi.sh_add.l);
bounds.Qdots.lower(jointi.sh_add.r) = bounds.Qdots.lower(jointi.sh_add.l);
% Shoulder rotation
bounds.Qdots.upper(jointi.sh_rot.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'arm_rot')));
bounds.Qdots.lower(jointi.sh_rot.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'arm_rot')));
bounds.Qdots.upper(jointi.sh_rot.r) = bounds.Qdots.upper(jointi.sh_rot.l);
bounds.Qdots.lower(jointi.sh_rot.r) = bounds.Qdots.lower(jointi.sh_rot.l);
% Elbow
bounds.Qdots.upper(jointi.elb.l) = max(Qdots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'elbow_flex')));
bounds.Qdots.lower(jointi.elb.l) = min(Qdots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'elbow_flex')));
bounds.Qdots.upper(jointi.elb.r) = bounds.Qdots.upper(jointi.elb.l);
bounds.Qdots.lower(jointi.elb.r) = bounds.Qdots.lower(jointi.elb.l);
% The bounds are extended by 3 times the absolute difference between upper
% and lower bounds.
Qdots_range = abs(bounds.Qdots.upper - bounds.Qdots.lower);
bounds.Qdots.lower = bounds.Qdots.lower - 3*Qdots_range;
bounds.Qdots.upper = bounds.Qdots.upper + 3*Qdots_range;
% Mtp
bounds.Qdots.upper(jointi.mtp.l) = 13;
bounds.Qdots.lower(jointi.mtp.l) = -13;
bounds.Qdots.upper(jointi.mtp.r) = 13;
bounds.Qdots.lower(jointi.mtp.r) = -13;
% Mtj
if midtarsal
    bounds.Qdots.upper(jointi.mtj.l) = 13;
    bounds.Qdots.lower(jointi.mtj.l) = -13;
    bounds.Qdots.upper(jointi.mtj.r) = 13;
    bounds.Qdots.lower(jointi.mtj.r) = -13;
end
% We adjust some bounds when we increase the speed to allow for the
% generation of running motions.
if v_tgt > 1.33
    % Pelvis tx
    bounds.Qdots.upper(jointi.pelvis.tx) = 4;
end
%% Qdotdots
% The extreme values are selected as upper/lower bounds, which are then
% further extended.
% Pelvis tilt
bounds.Qdotdots.upper(jointi.pelvis.tilt) = Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tilt'));
bounds.Qdotdots.lower(jointi.pelvis.tilt) = Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tilt'));
% Pelvis list
bounds.Qdotdots.upper(jointi.pelvis.list) = Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_list'));
bounds.Qdotdots.lower(jointi.pelvis.list) = Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_list'));
% Pelvis rotation
bounds.Qdotdots.upper(jointi.pelvis.rot) = Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_rotation'));
bounds.Qdotdots.lower(jointi.pelvis.rot) = Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_rotation'));
% Pelvis_tx
bounds.Qdotdots.upper(jointi.pelvis.tx) = Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tx')); 
bounds.Qdotdots.lower(jointi.pelvis.tx) = Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tx'));
% Pelvis_ty
bounds.Qdotdots.upper(jointi.pelvis.ty) = Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_ty'));
bounds.Qdotdots.lower(jointi.pelvis.ty) = Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_ty'));
% Pelvis_tz
bounds.Qdotdots.upper(jointi.pelvis.tz) = Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tz'));
bounds.Qdotdots.lower(jointi.pelvis.tz) = Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'pelvis_tz'));
% Hip flexion
bounds.Qdotdots.upper(jointi.hip_flex.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'hip_flexion')));
bounds.Qdotdots.lower(jointi.hip_flex.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'hip_flexion')));
bounds.Qdotdots.upper(jointi.hip_flex.r) = bounds.Qdotdots.upper(jointi.hip_flex.l);
bounds.Qdotdots.lower(jointi.hip_flex.r) = bounds.Qdotdots.lower(jointi.hip_flex.l);
% Hip adduction
bounds.Qdotdots.upper(jointi.hip_add.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'hip_adduction')));
bounds.Qdotdots.lower(jointi.hip_add.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'hip_adduction')));
bounds.Qdotdots.upper(jointi.hip_add.r) = bounds.Qdotdots.upper(jointi.hip_add.l);
bounds.Qdotdots.lower(jointi.hip_add.r) = bounds.Qdotdots.lower(jointi.hip_add.l);
% Hip rotation
bounds.Qdotdots.upper(jointi.hip_rot.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'hip_rotation')));
bounds.Qdotdots.lower(jointi.hip_rot.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'hip_rotation')));
bounds.Qdotdots.upper(jointi.hip_rot.r) = bounds.Qdotdots.upper(jointi.hip_rot.l);
bounds.Qdotdots.lower(jointi.hip_rot.r) = bounds.Qdotdots.lower(jointi.hip_rot.l);
% Knee
bounds.Qdotdots.upper(jointi.knee.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'knee_angle')));
bounds.Qdotdots.lower(jointi.knee.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'knee_angle')));
bounds.Qdotdots.upper(jointi.knee.r) = bounds.Qdotdots.upper(jointi.knee.l);
bounds.Qdotdots.lower(jointi.knee.r) = bounds.Qdotdots.lower(jointi.knee.l);
% Ankle
bounds.Qdotdots.upper(jointi.ankle.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'ankle_angle')));
bounds.Qdotdots.lower(jointi.ankle.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'ankle_angle')));
bounds.Qdotdots.upper(jointi.ankle.r) = bounds.Qdotdots.upper(jointi.ankle.l);
bounds.Qdotdots.lower(jointi.ankle.r) = bounds.Qdotdots.lower(jointi.ankle.l);
% Subtalar
bounds.Qdotdots.upper(jointi.subt.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'subtalar_angle')));
bounds.Qdotdots.lower(jointi.subt.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'subtalar_angle')));
bounds.Qdotdots.upper(jointi.subt.r) = bounds.Qdotdots.upper(jointi.subt.l);
bounds.Qdotdots.lower(jointi.subt.r) = bounds.Qdotdots.lower(jointi.subt.l);
% Trunk extension
bounds.Qdotdots.upper(jointi.trunk.ext) = Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_extension'));
bounds.Qdotdots.lower(jointi.trunk.ext) = Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_extension'));
% Trunk bending
bounds.Qdotdots.upper(jointi.trunk.ben) = Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_bending'));
bounds.Qdotdots.lower(jointi.trunk.ben) = Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_bending'));
% Trunk rotation
bounds.Qdotdots.upper(jointi.trunk.rot) = Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_rotation'));
bounds.Qdotdots.lower(jointi.trunk.rot) = Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'lumbar_rotation'));
% Shoulder flexion
bounds.Qdotdots.upper(jointi.sh_flex.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'arm_flex')));
bounds.Qdotdots.lower(jointi.sh_flex.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'arm_flex')));
bounds.Qdotdots.upper(jointi.sh_flex.r) = bounds.Qdotdots.upper(jointi.sh_flex.l);
bounds.Qdotdots.lower(jointi.sh_flex.r) = bounds.Qdotdots.lower(jointi.sh_flex.l);
% Shoulder adduction
bounds.Qdotdots.upper(jointi.sh_add.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'arm_add')));
bounds.Qdotdots.lower(jointi.sh_add.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'arm_add')));
bounds.Qdotdots.upper(jointi.sh_add.r) = bounds.Qdotdots.upper(jointi.sh_add.l);
bounds.Qdotdots.lower(jointi.sh_add.r) = bounds.Qdotdots.lower(jointi.sh_add.l);
% Shoulder rotation
bounds.Qdotdots.upper(jointi.sh_rot.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'arm_rot')));
bounds.Qdotdots.lower(jointi.sh_rot.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'arm_rot')));
bounds.Qdotdots.upper(jointi.sh_rot.r) = bounds.Qdotdots.upper(jointi.sh_rot.l);
bounds.Qdotdots.lower(jointi.sh_rot.r) = bounds.Qdotdots.lower(jointi.sh_rot.l);
% Elbow angle
bounds.Qdotdots.upper(jointi.elb.l) = max(Qddots_IK_upper(:,strcmp(Qs_IK.colheaders(1,:),'elbow_flex')));
bounds.Qdotdots.lower(jointi.elb.l) = min(Qddots_IK_lower(:,strcmp(Qs_IK.colheaders(1,:),'elbow_flex')));
bounds.Qdotdots.upper(jointi.elb.r) = bounds.Qdotdots.upper(jointi.elb.l);
bounds.Qdotdots.lower(jointi.elb.r) = bounds.Qdotdots.lower(jointi.elb.l);
% The bounds are extended by 3 times the absolute difference between upper
% and lower bounds.
Qdotdots_range = abs(bounds.Qdotdots.upper - bounds.Qdotdots.lower);
bounds.Qdotdots.lower = bounds.Qdotdots.lower - 3*Qdotdots_range;
bounds.Qdotdots.upper = bounds.Qdotdots.upper + 3*Qdotdots_range;
% Mtp
bounds.Qdotdots.upper(jointi.mtp.l) = 500;
bounds.Qdotdots.lower(jointi.mtp.l) = -500;
bounds.Qdotdots.upper(jointi.mtp.r) = 500;
bounds.Qdotdots.lower(jointi.mtp.r) = -500;
% Mtj
if midtarsal
    bounds.Qdotdots.upper(jointi.mtj.l) = 500;
    bounds.Qdotdots.lower(jointi.mtj.l) = -500;
    bounds.Qdotdots.upper(jointi.mtj.r) = 500;
    bounds.Qdotdots.lower(jointi.mtj.r) = -500;
end
%% Muscle activations
bounds.a.lower = 0.05*ones(1,NMuscle);
bounds.a.upper = ones(1,NMuscle);

%% Muscle-tendon forces
bounds.FTtilde.lower = zeros(1,NMuscle);
bounds.FTtilde.upper = 5*ones(1,NMuscle);

%% Time derivative of muscle activations
tact = 0.015;
tdeact = 0.06;
bounds.vA.lower = (-1/100*ones(1,NMuscle))./(ones(1,NMuscle)*tdeact);
bounds.vA.upper = (1/100*ones(1,NMuscle))./(ones(1,NMuscle)*tact);

%% Time derivative of muscle-tendon forces
bounds.dFTtilde.lower = -1*ones(1,NMuscle);
bounds.dFTtilde.upper = 1*ones(1,NMuscle);

%% Arm activations
bounds.a_a.lower = -ones(1,nq.arms);
bounds.a_a.upper = ones(1,nq.arms);

%% Arm excitations
bounds.e_a.lower = -ones(1,nq.arms);
bounds.e_a.upper = ones(1,nq.arms);

%% Mtp excitations
bounds.e_mtp.lower = -ones(1,2);
bounds.e_mtp.upper = ones(1,2);

%% Mtp activations
bounds.a_mtp.lower = -ones(1,2);
bounds.a_mtp.upper = ones(1,2);

%% PIM excitations
bounds.e_PIM.lower = zeros(1,2);
bounds.e_PIM.upper = ones(1,2);

%% PIM activations
bounds.a_PIM.lower = zeros(1,2);
bounds.a_PIM.upper = ones(1,2);

%% Lumbar activations
% Only used when no muscles actuate the lumbar joints (e.g. Rajagopal
% model)
bounds.a_lumbar.lower = -ones(1,nq.trunk);
bounds.a_lumbar.upper = ones(1,nq.trunk);

%% Lumbar excitations
% Only used when no muscles actuate the lumbar joints (e.g. Rajagopal
% model)
bounds.e_lumbar.lower = -ones(1,nq.trunk);
bounds.e_lumbar.upper = ones(1,nq.trunk);

%% Final time
bounds.tf.lower = 0.1;
bounds.tf.upper = 1;


%% Scaling
% Qs
scaling.Qs      = max(abs(bounds.Qs.lower),abs(bounds.Qs.upper));
bounds.Qs.lower = (bounds.Qs.lower)./scaling.Qs;
bounds.Qs.upper = (bounds.Qs.upper)./scaling.Qs;
% Qdots
scaling.Qdots      = max(abs(bounds.Qdots.lower),abs(bounds.Qdots.upper));
bounds.Qdots.lower = (bounds.Qdots.lower)./scaling.Qdots;
bounds.Qdots.upper = (bounds.Qdots.upper)./scaling.Qdots;
% Qs and Qdots are intertwined
bounds.QsQdots.lower = zeros(1,2*nq.all);
bounds.QsQdots.upper = zeros(1,2*nq.all);
bounds.QsQdots.lower(1,1:2:end) = bounds.Qs.lower;
bounds.QsQdots.upper(1,1:2:end) = bounds.Qs.upper;
bounds.QsQdots.lower(1,2:2:end) = bounds.Qdots.lower;
bounds.QsQdots.upper(1,2:2:end) = bounds.Qdots.upper;
scaling.QsQdots                 = zeros(1,2*nq.all);
scaling.QsQdots(1,1:2:end)      = scaling.Qs ;
scaling.QsQdots(1,2:2:end)      = scaling.Qdots ;
% Qdotdots
scaling.Qdotdots = max(abs(bounds.Qdotdots.lower),...
    abs(bounds.Qdotdots.upper));
bounds.Qdotdots.lower = (bounds.Qdotdots.lower)./scaling.Qdotdots;
bounds.Qdotdots.upper = (bounds.Qdotdots.upper)./scaling.Qdotdots;
bounds.Qdotdots.lower(isnan(bounds.Qdotdots.lower)) = 0;
bounds.Qdotdots.upper(isnan(bounds.Qdotdots.upper)) = 0;
% Arm torque actuators
% Fixed scaling factor
scaling.ArmTau = 150;
% Fixed scaling factor
scaling.LumbarTau = 150;
% Mtp torque actuators
% Fixed scaling factor
scaling.MtpTau = 100;
% PIM force actuators
% Fixed scaling factor
scaling.PIMF = 10000; % this is too high
% Time derivative of muscle activations
% Fixed scaling factor
scaling.vA = 100;
% Muscle activations
scaling.a = 1;
% Arm activations
scaling.a_a = 1;
% Arm excitations
scaling.e_a = 1;
% Time derivative of muscle-tendon forces
% Fixed scaling factor
scaling.dFTtilde = 100;
% Muscle-tendon forces
scaling.FTtilde         = max(...
    abs(bounds.FTtilde.lower),abs(bounds.FTtilde.upper)); 
bounds.FTtilde.lower    = (bounds.FTtilde.lower)./scaling.FTtilde;
bounds.FTtilde.upper    = (bounds.FTtilde.upper)./scaling.FTtilde;

%% Hard bounds
% We impose the initial position of pelvis_tx to be 0
bounds.QsQdots_0.lower = bounds.QsQdots.lower;
bounds.QsQdots_0.upper = bounds.QsQdots.upper;
bounds.QsQdots_0.lower(2*jointi.pelvis.tx-1) = 0;
bounds.QsQdots_0.upper(2*jointi.pelvis.tx-1) = 0;

end
