
close all
clear
clc


results_folder = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results\contactmodel_param_sweep';

addpath('C:\GBW_MyPrograms\PredSim_test\PostProcessing')

res_filt = dir(fullfile(results_folder,'Fal_s1_k*_d20_sF8_dF8_vF5_tV20_*.mat'));
figure_savename = 'fig_sweep_staticFriction';




for i=1:length(res_filt)
    result_paths{i} = fullfile(results_folder,res_filt(i).name);
    legend_names{i} = replace(res_filt(i).name(1:end-4),'_',' ');
end
result_paths = result_paths([2:end,1]);
legend_names = legend_names([2:end,1]);
% result_paths = result_paths([3,5,1]);
% legend_names = legend_names([3,5,1]);



CsV = hsv(length(result_paths));
figure('Position',[524   545   751   214])
tiledlayout(1,3)

for i=1:length(result_paths)


    load(result_paths{i},'R','model_info');
    
    model_path = model_info.osim_path;

    pathIK = replace(result_paths{i},'.mat','.mot');

    intrvl = R.time.mesh_GC;
    
    [out] = OpenSim_body_frames(model_path,pathIK,intrvl);

    %
    x = 1:100;
    for j=1:3
        nexttile(j)
        hold on
        plot(x,out.torso.eul(1:100,j)*180/pi,'DisplayName',legend_names{i},'Color',CsV(i,:))
    end

    pelvis_ty = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.pelvis_ty);
    dy = max(pelvis_ty) - min(pelvis_ty);
    dF = max(R.ground_reaction.GRF_r(:,2));
    K = dF/dy;


    eff = R.energetics_mech.Wpos_contact(:,1)/(-R.energetics_mech.Wneg_contact(:,1));
    loss = 1-eff;
    disp(['Heelpad dissipates ' num2str(loss*100,2) ' % of absorbed energy.'])

end

nexttile(1)
ylabel('Torso Rz (°)')
xlabel('Gait Cycle (%)')
nexttile(2)
ylabel('Torso Ry (°)')
xlabel('Gait Cycle (%)')
nexttile(3)
ylabel('Torso Rx (°)')
xlabel('Gait Cycle (%)')
sgtitle({'Torso orientation in world (ZYX Euler angles)'})
% lg = legend;
% lg.Layout.Tile = 4;


%%



% exportgraphics(gcf,fullfile(results_folder,[figure_savename '_torso.png' ]),'Resolution',300);

