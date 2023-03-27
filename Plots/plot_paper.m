

clear 
close all
clc

%% Paths
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/FootModel']);

%% Select results
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

results = {
    '\with_better_knee\Fal_s1_mtp_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig21'
    '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig21'
    '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_oy3_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21'
    };
LegNames = {'Baseline model','Windlass mechanism','Plantar intrinsic muscles'};

colours = {[0.4660 0.6740 0.1880],[0 0.4470 0.7410],[0.6350 0.0780 0.1840]};
% colours = {[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.6350 0.0780 0.1840]};

lines = {'-','--','-.'};

norm_stance = 0;
lw = 2;

%% Load experimental reference data
load([pathRepo '\Data\Fal_s1.mat'],'Data');

RefData = 'Fal_s1_mtjc4_FK_custom';

data_field = ['IK_' RefData(8:end)];
Qref = Data.(data_field);

data_field = ['ID_' RefData(8:end)];
Tref = Data.(data_field);

data_field = ['P_' RefData(8:end)];
Pref = Data.(data_field);

%
stance_ref_mean = 64.3;
stance_ref_std = 0.8233;

%
istance_ref = find(Data.GRF.Fmean(:,2)>=3)';
iswing_ref = setdiff(1:length(Data.GRF.Fmean(:,2)),istance_ref);

x = 1:(100-1)/(length(Data.GRF.Fmean(:,2))-1):100;

q_name = {'hip_flexion','knee_angle','ankle_angle','subtalar_angle','mtj_angle','mtp_angle'};
q_titles = {'Hip flexion','Knee extension','Ankle dorsiflexion','Subtalar inversion','Midtarsal extension','MTP extension'};
for i=1:length(q_name)
    iref(i) = find(strcmp(Qref.colheaders,q_name{i}));
    meanPlusSTD = (Qref.Qall_mean(:,iref(i)) + 2*Qref.Qall_std(:,iref(i)));
    meanMinusSTD = (Qref.Qall_mean(:,iref(i)) - 2*Qref.Qall_std(:,iref(i)));
    q_ref(i).mean2std = [meanPlusSTD' fliplr(meanMinusSTD')];
    q_ref(i).mean = Qref.Qall_mean(:,iref(i));
end

m_name = {'Soleus','Gastrocnemius-medialis','Gastrocnemius-lateralis','Tibialis-anterior','Peroneus-longus','Peroneus-brevis'};
m_titles = {'Soleus','Gastrocnemius medialis','Gastrocnemius lateralis','Tibialis anterior','Peroneus longus','Peroneus brevis'};
m_sim = {'soleus_r','med_gas_r','lat_gas_r','tib_ant_r','per_long_r','per_brev_r'};
m_scale = [3.33,2.94,2.73,7.86,6.40,2.85];
for i=1:length(m_name)
    iref(i) = find(strcmp(Data.EMGheaders,m_name{i}));
    meanPlusSTD = (Data.lowEMG_mean(:,iref(i)) + 2*Data.lowEMG_std(:,iref(i)));
    meanMinusSTD = (Data.lowEMG_mean(:,iref(i)) - 2*Data.lowEMG_std(:,iref(i)));
    max_emg = max(Data.lowEMG_mean(:,iref(i)) + 3*Data.lowEMG_std(:,iref(i)));
    if max_emg*m_scale(i) >1
        m_scale(i) = 1/(max_emg);
    end
    m_ref(i).mean2std = [meanPlusSTD' fliplr(meanMinusSTD')]*m_scale(i);
    m_ref(i).mean = Data.lowEMG_mean(:,iref(i))*m_scale(i);
end

T_name = {'knee_angle','ankle_angle'};
T_titles = {'Knee extension','Ankle dorsiflexion'};
for i=1:length(T_name)
    iref(i) = find(strcmp(Tref.colheaders,T_name{i}));
    meanPlusSTD = (Tref.Tall_mean(:,iref(i)) + 2*Tref.Tall_std(:,iref(i)));
    meanMinusSTD = (Tref.Tall_mean(:,iref(i)) - 2*Tref.Tall_std(:,iref(i)));
    T_ref(i).mean2std = [meanPlusSTD' fliplr(meanMinusSTD')]/62;
    T_ref(i).mean = Tref.Tall_mean(:,iref(i))/62;
end

P_name = {'ankle_angle'};
P_titles = {'Ankle dorsiflexion'};
for i=1:length(P_name)
    iref(i) = find(strcmp(Pref.colheaders,P_name{i}));
    meanPlusSTD = (Pref.Pall_mean(:,iref(i)) + 2*Pref.Pall_std(:,iref(i)));
    meanMinusSTD = (Pref.Pall_mean(:,iref(i)) - 2*Pref.Pall_std(:,iref(i)));
    P_ref(i).mean2std = [meanPlusSTD' fliplr(meanMinusSTD')]/62;
    P_ref(i).mean = Pref.Pall_mean(:,iref(i))/62;
end

GRF_titles = {'Vertical GRF'};
meanPlusSTD = Data.GRF.Fmean(:,2) + 2*Data.GRF.Fstd(:,2);
meanMinusSTD = Data.GRF.Fmean(:,2) - 2*Data.GRF.Fstd(:,2);
GRF_ref(1).mean2std = [meanPlusSTD' fliplr(meanMinusSTD')];
GRF_ref(1).mean = Data.GRF.Fmean(:,2);

%%
scs = get(0,'ScreenSize');
f1 = figure('Position',[100,100,scs(3)/2, scs(3)*0.4]);
set(f1,'Color','w');


nh = 4;
nw = 4;
q_pl = [1,2,3,[1,2,3]+nw];
m_pl = q_pl+nw*2;
T_pl = [1,2]*nw;
P_pl = 3*nw;

%%
for i=1:length(results)

    load(fullfile(ResultsRepo, [results{i} '_pp.mat']),'R');
    istance = 1:1:ceil(R.Event.Stance);
    iswing = istance(end)+1:100;

    smpl_stance = linspace(istance(1),istance(end),length(istance_ref));
    smpl_swing = linspace(iswing(1),iswing(end),length(iswing_ref));

    % Plot kinematics
    for j=1:length(q_pl)
        subplot(nh,nw,q_pl(j))
        if i==1
            yl = [min(q_ref(j).mean2std),max(q_ref(j).mean2std)];
            yl = yl + [-1,1]*rms(yl)*0.2;
            if strcmp(q_name{j},'subtalar_angle')
                yl(2) = 18;
            end
            if norm_stance
                fill([iswing_ref([1,end]), fliplr(iswing_ref([1,end]))],[yl(1),yl(1),yl(2),yl(2)],[1,1,1]*0.9,'LineStyle','none')
            end
            hold on
            fill([x fliplr(x)],q_ref(j).mean2std,0.8*[1,1,1],'LineStyle','none','DisplayName','IK (mean \pm 2 SD)');
            xlim([0,100])
            ylim(yl)
            ylabel('Angle (°)')
            title(q_titles{j},'FontWeight','normal')
            set(gca,'XTick',[0:25:100])
%             xlabel('Gait cycle (%)')
%             xline(iswing_ref(1),'Color',[1,1,1]*0.9)


        end

        idx = find(strcmp(R.colheaders.joints,[q_name{j} '_r']));
        if length(idx)==1
            q_sim0 = R.Qs(:,idx);
            q_sim_stance = interp1(istance,q_sim0(istance),smpl_stance);
            q_sim_swing = interp1(iswing,q_sim0(iswing),smpl_swing);
            q_sim = [q_sim_stance, q_sim_swing];
            if norm_stance
                q_sim0 = q_sim;
            end
            plot(x,q_sim0,lines{i},'Color',colours{i},'LineWidth',lw);

%             [r2,rmse] = rsquare(q_ref(j).mean(istance_ref)',q_sim_stance);
%             disp(['r2 = ' num2str(r2,2),'|  rmse = ' num2str(rmse)])
        end

    end

    % Plot muscle activities
    for j=1:length(m_pl)
        subplot(nh,nw,m_pl(j))
        if i==1
            yl = [min(m_ref(j).mean2std),max(m_ref(j).mean2std)];
            yl = yl + [-1,1]*rms(yl)*0.2;
            yl(1) = 0;
            yl(2) = min([yl(2),1]);
            if norm_stance
                fill([iswing_ref([1,end]), fliplr(iswing_ref([1,end]))],[yl(1),yl(1),yl(2),yl(2)],[1,1,1]*0.9,'LineStyle','none')
            end
            hold on
            fill([x fliplr(x)],m_ref(j).mean2std,0.8*[1,1,1],'LineStyle','none','DisplayName','EMG (mean \pm 2 SD)');
            xlim([0,100])
            ylim(yl)
            ylabel('Activity (-)')
            title(m_titles{j},'FontWeight','normal')
            set(gca,'XTick',[0:25:100])
%             xlabel('Gait cycle (%)')
%             xline(iswing_ref(1),'Color',[1,1,1]*0.9)
        end

        idx = find(strcmp(R.colheaders.muscles,m_sim{j}));
        if length(idx)==1
            a_sim0 = R.a(:,idx);
            a_sim_stance = interp1(istance,a_sim0(istance),smpl_stance);
            a_sim_swing = interp1(iswing,a_sim0(iswing),smpl_swing);
            a_sim = [a_sim_stance, a_sim_swing];
            if norm_stance
                a_sim0 = a_sim;
            end
            plot(x,a_sim0,lines{i},'Color',colours{i},'LineWidth',lw);
%             if i==3
%                 disp(max(a_sim)/max(m_ref(j).mean))
%             end
        end

    end

    % Plot kinetics
    for j=1:length(T_pl)
        subplot(nh,nw,T_pl(j))
        if i==1
            yl = [min(T_ref(j).mean2std),max(T_ref(j).mean2std)];
            yl = yl + [-1,1]*rms(yl)*0.2;
            if strcmp(T_name{j},'ankle_angle')
                yl(2) = 0.55;
            end
            if norm_stance
                fill([iswing_ref([1,end]), fliplr(iswing_ref([1,end]))],[yl(1),yl(1),yl(2),yl(2)],[1,1,1]*0.9,'LineStyle','none')
            end
            hold on
            fill([x fliplr(x)],T_ref(j).mean2std,0.8*[1,1,1],'LineStyle','none','DisplayName','ID (mean \pm 2 SD)');
            xlim([0,100])
            ylim(yl)
            ylabel('Moment (Nm/kg)')
            title(T_titles{j},'FontWeight','normal')
            set(gca,'XTick',[0:25:100])
%             xlabel('Gait cycle (%)')
%             xline(iswing_ref(1),'Color',[1,1,1]*0.9)
        end

        idx = find(strcmp(R.colheaders.joints,[T_name{j} '_r']));
        if length(idx)==1
            T_sim0 = R.Tid(:,idx)/R.S.mass;
            T_sim_stance = interp1(istance,T_sim0(istance),smpl_stance);
            T_sim_swing = interp1(iswing,T_sim0(iswing),smpl_swing);
            T_sim = [T_sim_stance, T_sim_swing];
            if norm_stance
                T_sim0 = T_sim;
            end
            plot(x,T_sim0,lines{i},'Color',colours{i},'LineWidth',lw);
        end

    end

    % Plot joint power
    for j=1:length(P_pl)
        subplot(nh,nw,P_pl(j))
        if i==1
            yl = [min(P_ref(j).mean2std),max(P_ref(j).mean2std)];
            yl = yl + [-1,1]*rms(yl)*0.2;
            if norm_stance
                fill([iswing_ref([1,end]), fliplr(iswing_ref([1,end]))],[yl(1),yl(1),yl(2),yl(2)],[1,1,1]*0.9,'LineStyle','none')
            end
            hold on
            fill([x fliplr(x)],P_ref(j).mean2std,0.8*[1,1,1],'LineStyle','none','DisplayName','P (mean \pm 2 SD)');
            xlim([0,100])
            ylim(yl)
            ylabel('Power (W/kg)')
            title(P_titles{j},'FontWeight','normal')
            set(gca,'XTick',[0:25:100])
%             xlabel('Gait cycle (%)')
%             xline(iswing_ref(1),'Color',[1,1,1]*0.9)
        end

        idx = find(strcmp(R.colheaders.joints,[P_name{j} '_r']));
        if length(idx)==1
            P_sim0 = R.Qdots(:,idx).*R.Tid(:,idx)*pi/180/R.S.mass;
            P_sim_stance = interp1(istance,P_sim0(istance),smpl_stance);
            P_sim_swing = interp1(iswing,P_sim0(iswing),smpl_swing);
            P_sim = [P_sim_stance, P_sim_swing];
            if norm_stance
                P_sim0 = P_sim;
            end
            plot(x,P_sim0,lines{i},'Color',colours{i},'LineWidth',lw);
        end

    end

    % Plot ground reaction forces
    for j=1
        subplot(nh,nw,nw*4)
        if i==1
            yl = [min(GRF_ref(j).mean2std),max(GRF_ref(j).mean2std)];
            yl = yl + [-1,1]*rms(yl)*0.2;
            yl(1) = 0;
            if norm_stance
                fill([iswing_ref([1,end]), fliplr(iswing_ref([1,end]))],[yl(1),yl(1),yl(2),yl(2)],[1,1,1]*0.9,'LineStyle','none','DisplayName','Swing')
            end
            hold on
            p1=fill([x fliplr(x)],GRF_ref(j).mean2std,0.8*[1,1,1],'LineStyle','none','DisplayName','Reference data (mean \pm 2 SD)');
            lg(1) = p1;
            xlim([0,100])
            ylim(yl)
            ylabel('GRF/BW (%)')
            title(GRF_titles{j},'FontWeight','normal')
            set(gca,'XTick',[0:25:100])
%             xlabel('Gait cycle (%)')
%             xline(iswing_ref(1),'Color',[1,1,1]*0.9)
        end

        idx = 2;
        if length(idx)==1
            GRF_sim0 = R.GRFs(:,idx);
            GRF_sim_stance = interp1(istance,GRF_sim0(istance),smpl_stance);
            GRF_sim_swing = interp1(iswing,GRF_sim0(iswing),smpl_swing);
            GRF_sim = [GRF_sim_stance, GRF_sim_swing];
            if norm_stance
                GRF_sim0 = GRF_sim;
            end
            pp=plot(x,GRF_sim0,lines{i},'Color',colours{i},'LineWidth',lw,'DisplayName',LegNames{i});
            lg(end+1) = pp;
        end

    end
end
leg = legend(lg,'Location','northeast','NumColumns',4,'Fontsize',11,'Box','off');
lglo = leg.Position;
lglo(2) = lglo(2) - 0.21;
leg.Position = lglo;

for i=1:nw
    subplot(nh,nw,nw*(nh-1)+i)
    xlabel('Gait cycle (%)')
end

for j=1:length(q_pl)
    subplot(nh,nw,q_pl(j))
    posi = get(gca,'Position');
    posi(1) = posi(1) - 0.05;
    posi(2) = posi(2) + 0.03;
    set(gca,'Position',posi);
end

for j=1:length(m_pl)
    subplot(nh,nw,m_pl(j))
    posi = get(gca,'Position');
    posi(1) = posi(1) - 0.05;
%     posi(2) = posi(2) + 0.03;
    set(gca,'Position',posi);

end

for j=1:length(T_pl)
    subplot(nh,nw,T_pl(j))
    posi = get(gca,'Position');
%     posi(1) = posi(1) - 0.05;
    posi(2) = posi(2) + 0.03;
    set(gca,'Position',posi);
end

% subplot(nh,nw,P_pl(1))
% posi = get(gca,'Position');
% posi(1) = posi(1) - 0.05;
% posi(2) = posi(2) + 0.03;
% set(gca,'Position',posi);
% 
% subplot(nh,nw,nw*4)


%%

% f2 = figure('Position',[100,100,scs(3)/2, scs(3)*0.4]);
% 
% nh = 4;
% nw = 4;
% 
% for i=1:length(results)
% 
%     load(fullfile(ResultsRepo, [results{i} '_pp.mat']),'R');
%     istance = 1:1:ceil(R.Event.Stance);
% 
%     imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
%     iankle = strcmp(R.colheaders.joints,'ankle_angle_r');
%     isubt = strcmp(R.colheaders.joints,'subtalar_angle_r');
%     imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));
% 
%     iSol = find(strcmp(R.colheaders.muscles,'soleus_r'));
%     iGas = find(strcmp(R.colheaders.muscles,'lat_gas_r'));
%     iGas2 = find(strcmp(R.colheaders.muscles,'med_gas_r'));
%     iFDB = find(strcmp(R.colheaders.muscles,'FDB_r'));
% 
%     P_ankle = R.Qdots(:,iankle)*pi/180.*R.Tid(:,iankle)/R.body_mass;
%     P_subt = R.Qdots(:,isubt)*pi/180.*R.Tid(:,isubt)/R.body_mass;
%     P_mtp = R.Qdots(:,imtp)*pi/180.*R.Tid(:,imtp)/R.body_mass;
% 
%     P_T_Sol = -R.FT(:,iSol).*R.vT(:,iSol)/R.body_mass;
%     P_T_Gas = -R.FT(:,iGas).*R.vT(:,iGas)/R.body_mass;
%     P_T_Gas2 = -R.FT(:,iGas2).*R.vT(:,iGas2)/R.body_mass;
%     P_AT = P_T_Sol+P_T_Gas+P_T_Gas2;
% 
%     P_M_Sol = -(R.Muscle.Fce(:,iSol)+R.Muscle.Fpass(:,iSol)).*R.Muscle.vM(:,iSol)/R.body_mass;
%     P_M_Gas = -(R.Muscle.Fce(:,iGas)+R.Muscle.Fpass(:,iGas)).*R.Muscle.vM(:,iGas)/R.body_mass;
%     P_M_Gas2 = -(R.Muscle.Fce(:,iGas2)+R.Muscle.Fpass(:,iGas2)).*R.Muscle.vM(:,iGas2)/R.body_mass;
%     P_TS = P_M_Sol+P_M_Gas+P_M_Gas2;
% 
%     if ~isempty(imtj)
%         P_mtj = R.Qdots(:,imtj)*pi/180.*R.Tid(:,imtj)/R.body_mass;
%         P_PF = -R.windlass.v_PF.*R.windlass.F_PF/R.body_mass;
%     end
% 
%     if ~isempty(iFDB)
% 
%     end
% 
% 
% 
%     subplot(nh,nw,1)
% 
% end

