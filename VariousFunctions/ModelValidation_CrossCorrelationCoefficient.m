function [ccc] = ModelValidation_CrossCorrelationCoefficient(pathSimResults, pathExpData)
% returns a struct with information about the cross-correlation coefficient
% of the simulation results and the mean measurement data


%% load files   
[path1,file1,~] = fileparts(pathSimResults);
addpath(path1);
load(file1,'R');
if R.S.ExoBool == 1
    if R.S.ExoScale == 0
        type = 'Passive';
    else
        type = 'Active';
    end
else
    type = 'Normal';
end

[path2,file2,~] = fileparts(pathExpData);
addpath(path2);
%     load(file2,'ExperimentalData');
load('D:\school\WTK\thesis\model\3dpredictsim\Data\Pog_s1.mat','Dat');
Qref = Dat.(type).gc;

%% Helper names
joints_ref = {'pelvis_tilt','pelvis_list','pelvis_rotation',...
    'hip_flexion','hip_adduction','hip_rotation',...
    'knee_angle','ankle_angle','subtalar_angle','tmt_angle','mtp_angle',...
    'lumbar_extension','lumbar_bending','lumbar_rotation',...
    'arm_flex','arm_add','arm_rot','elbow_flex'};
joints_ref_r = {'pelvis_tilt','pelvis_list','pelvis_rotation',...
    'hip_flexion_r','hip_adduction_r','hip_rotation_r',...
    'knee_angle_r','ankle_angle_r','subtalar_angle_r','tmt_angle_r','mtp_angle_r',...
    'lumbar_extension','lumbar_bending','lumbar_rotation',...
    'arm_flex_r','arm_add_r','arm_rot_r','elbow_flex_r'};
% since joint names are not consistent between measurement data and
% simulation results :(
joints_tit = {'Pelvis tilt','Pelvis list','Pelvis rotation','Pelvis tx',...
    'Pelvis ty','Pelvis tz','Hip flexion L','Hip adduction L',...
    'Hip rotation L','Hip flexion R','Hip adduction R','Hip rotation R',...
    'Knee L','Knee R','Ankle L','Ankle R',...
    'Subtalar L','Subtalar R','TMT L','TMT R','MTP L','MTP R',...
    'Lumbar extension','Lumbar bending','Lumbar rotation',...
    'Arm flexion L','Arm adduction L','Arm rotation L',...
    'Arm flexion R','Arm adduction R','Arm rotation R',...
    'Elbow flexion L','Elbow flexion R'};




%% compare
idx_Qs = [1,2,3,10,11,12,14,16,18,20,22,23,24,25,29,30,31,33];

%ccc.joints =-ones(length(idx_Qs),1);
ccc.kinematics.atShift0 = -ones(1,length(idx_Qs));      % -1 default, to see if field wasn't calculated
ccc.kinematics.max = -ones(1,length(idx_Qs));           % -1 default, to see if field wasn't calculated
ccc.kinematics.shiftAtMax = -ones(1,length(idx_Qs));    % -1 default, to see if field wasn't calculated

ccc.kinetics.atShift0 = -ones(1,length(idx_Qs));      % -1 default, to see if field wasn't calculated
ccc.kinetics.max = -ones(1,length(idx_Qs));           % -1 default, to see if field wasn't calculated
ccc.kinetics.shiftAtMax = -ones(1,length(idx_Qs));    % -1 default, to see if field wasn't calculated

%     subject = 'subject1';
%     Qref = ExperimentalData.Q;
%     IDref = ExperimentalData.Torques;

for i = 1:length(idx_Qs)
%         idx_jref = strcmp(Qref.(subject).Qs.colheaders,joints_ref{i});
    idx_jref = strcmp(Qref.colheaders,joints_ref_r{i});
    idx_sim = strcmp(R.colheaders.joints,joints_ref_r{i});
    ccc.joints{i} = joints_tit{idx_Qs(i)};
    if sum(idx_jref) == 1 && sum(idx_sim) == 1
%             mean = Qref.(subject).Qs.mean(:,idx_jref);
        %std = Qref.(subject).Qs.std(:,idx_jref);
        mean = Qref.Qall_mean(:,idx_jref).*180/pi;
        sim = R.Qs(:,idx_sim);
        m = size(mean);
        s = size(sim);
        if(m == s)
        %rmse(i,:) = rsquare(mean,sim);
        %[c,lags] = xcorr(mean,sim,50);
        [c,lags] = xcorr(mean,sim,50,'coeff');     % normalized
        lags_i = find(lags == 0);
        ccc.kinematics.atShift0(1,i) = c(lags_i);   % ccc at shift = 0
        ccc.kinematics.max(1,i) = max(c);      % max ccc
        c_i = find(c == max(c));
        ccc.kinematics.shiftAtMax(1,i) = lags(c_i);   % shift of max ccc
        ccc.kinematics.shift(:,i) = lags';
        ccc.kinematics.ccc(:,i) = c';
        end

%             mean = IDref.(subject).mean(:,idx_jref);
        %std = IDref.(subject).std(:,idx_jref);
        mean = Qref.Tall_bio_mean(:,idx_jref);
        sim = R.Tid(:,idx_sim);
        m = size(mean);
        s = size(sim);
        if(m == s)
        %rmse(i,:) = rsquare(mean,sim);
        %[c,lags] = xcorr(mean,sim,50);
        [c,lags] = xcorr(mean,sim,50,'coeff');     % normalized
        lags_i = find(lags == 0);
        ccc.kinetics.atShift0(1,i) = c(lags_i);   % ccc at shift = 0
        ccc.kinetics.max(1,i) = max(c);      % max ccc
        c_i = find(c == max(c));
        ccc.kinetics.shiftAtMax(1,i) = lags(c_i);   % shift of max ccc
        ccc.kinetics.shift(:,i) = lags';
        ccc.kinetics.ccc(:,i) = c';
        end
    end
end

iSol = find(strcmp(R.colheaders.muscles,'soleus_r'));
iGas = find(strcmp(R.colheaders.muscles,'lat_gas_r'));
iGas2 = find(strcmp(R.colheaders.muscles,'med_gas_r'));
iTib = find(strcmp(R.colheaders.muscles,'tib_ant_r'));
if isempty(iGas)
    iGas = find(strcmp(R.colheaders.muscles,'gaslat_r'));
end
if isempty(iGas2)
    iGas2 = find(strcmp(R.colheaders.muscles,'gasmed_r'));
end
if isempty(iTib)
    iTib = find(strcmp(R.colheaders.muscles,'tibant_r'));
end

iSol_data = find(strcmp(Dat.(type).EMGheaders,'soleus_r'));
iGas_data = find(strcmp(Dat.(type).EMGheaders,'gas_lat_r'));
iGas2_data = find(strcmp(Dat.(type).EMGheaders,'gas_med_r'));
iTib_data = find(strcmp(Dat.(type).EMGheaders,'tib_ant_r'));
% change order to match simulation gait cycle
sol_act = [Dat.(type).gc.lowEMG_mean(ceil(end/2):end,iSol_data); Dat.(type).gc.lowEMG_mean(1:ceil(end/2)-1,iSol_data)];
gas_act = [Dat.(type).gc.lowEMG_mean(ceil(end/2):end,iGas_data); Dat.(type).gc.lowEMG_mean(1:ceil(end/2)-1,iGas_data)];
gas2_act = [Dat.(type).gc.lowEMG_mean(ceil(end/2):end,iGas2_data); Dat.(type).gc.lowEMG_mean(1:ceil(end/2)-1,iGas2_data)];
tib_act = [Dat.(type).gc.lowEMG_mean(ceil(end/2):end,iTib_data); Dat.(type).gc.lowEMG_mean(1:ceil(end/2)-1,iTib_data)];

mDat_act = [sol_act, gas_act, gas2_act, tib_act];

mVect = {'Soleus','Gas-lat','Gas-med','Tib-ant'};
iM = [iSol iGas iGas2 iTib];

ccc.muscles.names = mVect;

for i=1:4
    
    mean = mDat_act(:,i);
    sim = R.a(:,iM(i));
    m = size(mean);
    s = size(sim);
    if(m == s)
    %rmse(i,:) = rsquare(mean,sim);
    %[c,lags] = xcorr(mean,sim,50);
    [c,lags] = xcorr(mean,sim,50,'coeff');     % normalized
    lags_i = find(lags == 0);
    ccc.muscles.atShift0(1,i) = c(lags_i);   % ccc at shift = 0
    ccc.muscles.max(1,i) = max(c);      % max ccc
    c_i = find(c == max(c));
    ccc.muscles.shiftAtMax(1,i) = lags(c_i);   % shift of max ccc
    ccc.muscles.shift(:,i) = lags';
    ccc.muscles.ccc(:,i) = c';
    end

end

end