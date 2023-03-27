
clear
clc


load('C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\with_better_knee\Fal_s1_mtjc2_sc_cspx10_oy2_ATx70_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_old_bounds_pp.mat','R')

Modelpath1 = fullfile('C:\Users\u0150099\Documents\master_thesis\3dpredictsim\OpenSimModel\subject1',[R.S.OsimFileName '_cspx10_oy2.osim']);

bodies = {'pelvis','femur_r','tibia_r','calcn_r','forefoot_r'};


coord_names_sim = R.colheaders.joints;
Qs_sim = R.Qs;

[rot_sim] = getBodyRotationInGround(Modelpath1,Qs_sim,coord_names_sim,bodies);

%%
load('C:\Users\u0150099\Documents\master_thesis\3dpredictsim\Data\Fal_s1.mat','Data');
% Qref = Data.IK_mtj_custom;
% Qs_ref = Qref.Qall_mean;
% coord_names_ref = Qref.colheaders;
% 
% for i=1:length(coord_names_ref)
%     if ~contains(coord_names_ref{i},'pelvis') && ~contains(coord_names_ref{i},'lumbar')
%         coord_names_ref{i} = [coord_names_ref{i} '_r'];
%     end
% end
% 
% [rot_ref] = getBodyRotationInGround(Modelpath1,Qs_ref,coord_names_ref,bodies);

%%
Qref = Data.IK_mtjc2_custom;
Qs_ref = Qref.Qall_mean;
coord_names_ref = Qref.colheaders;

for i=1:length(coord_names_ref)
    if ~contains(coord_names_ref{i},'pelvis') && ~contains(coord_names_ref{i},'lumbar')
        coord_names_ref{i} = [coord_names_ref{i} '_r'];
    end
end

[rot_ref2] = getBodyRotationInGround(Modelpath1,Qs_ref,coord_names_ref,bodies);


%%
x = 1:(100-1)/(size(R.Qs,1)-1):100;
x = 1:60;
idx = 1:length(x);

figure

yls = {'X','Y','Z'};
nb = length(bodies);

for i=1:3
    for j=1:nb
        subplot(nb,3,j*3-(3-i))
        hold on
%         plot(x,rot_ref.(bodies{j})(:,i),'-','DisplayName','IK mtj pin')
        plot(x,rot_ref2.(bodies{j})(idx,i),'-','DisplayName','IK mtjc2')
        plot(x,rot_sim.(bodies{j})(idx,i),'--','DisplayName','simulated')
        title(bodies{j})
        ylabel(yls{i},'Interpreter','none')
    end
end
legend

figure
for i=1:3
    for j=1:nb
        subplot(nb,3,j*3-(3-i))
        hold on
        diff = rot_sim.(bodies{j})(idx,i) - rot_ref2.(bodies{j})(idx,i);
        plot(x,diff,'-','DisplayName','simulated - IK mtjc2')

        title(bodies{j},'Interpreter','none')
        ylabel(yls{i})
    end
end
legend


%%
function [body_orientation] = getBodyRotationInGround(Modelpath,Qs,coord_names,body_names)

    import org.opensim.modeling.*;
    model = Model(Modelpath);
    s = model.initSystem;
    
    for k=1:length(body_names)
        body_orientation.(body_names{k}) = zeros(size(Qs,1),3);
    end
    
    for i=1:size(Qs,1)
        % Set state vector to 0
        state_vars = model.getStateVariableValues(s);
        state_vars.setToZero();
        model.setStateVariableValues(s,state_vars);
        for j=1:length(coord_names)
    
            qi = Qs(i,j)*pi/180;
            
            coord = model.getCoordinateSet.get(coord_names{j});
            coord.setValue(s,qi);
        end
     
        model.realizePosition(s);
        
        for k=1:length(body_names)
            body_k = model.getBodySet().get(body_names{k});
            body_orientation.(body_names{k})(i,:) = body_k.getTransformInGround(s).R().convertRotationToBodyFixedXYZ().getAsMat'*180/pi;
%             rot_mat = body_k.getTransformInGround(s).R().asMat33;%.getAsMat;
%             eulerAngles = getEulerAngles_z0_x1_y2(rot_mat);
%             body_orientation.(body_names{k})(i,:) = eulerAngles(:)*180/pi;
        end

%         tibia = model.getBodySet().get('tibia_r');
%         tibia_rot(i,:) = tibia.getTransformInGround(s).R().convertRotationToBodyFixedXYZ().getAsMat'*180/pi;
%     
%         femur = model.getBodySet().get('femur_r');
%         femur_rot(i,:) = femur.getTransformInGround(s).R().convertRotationToBodyFixedXYZ().getAsMat'*180/pi;
%     
%         calcn = model.getBodySet().get('calcn_r');
%         calcn_rot(i,:) = calcn.getTransformInGround(s).R().convertRotationToBodyFixedXYZ().getAsMat'*180/pi;
    
    end
    

end

%%
function [euler_angles] = getEulerAngles_z0_x1_y2(r)

    alpha = atan2(-r.get(1,2),r.get(2,2));
    beta = atan2(r.get(3,2),(sqrt(1-r.get(3,2)^2)));
    gamma = atan2(-r.get(3,1),r.get(3,3));

    euler_angles = [alpha,beta,gamma];


end