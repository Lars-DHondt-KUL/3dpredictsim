
clear
close all
clc

FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\figures\draft';
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

%% load rference data

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
load([pathRepo '\Data\Fal_s1.mat'],'Data');

RefData = 'Fal_s1_mtjc4_FK_custom';

data_field = ['IK_' RefData(8:end)];
Qref = Data.(data_field);

data_field = ['ID_' RefData(8:end)];
Tref = Data.(data_field);

data_field = ['P_' RefData(8:end)];
Pref = Data.(data_field);

stance_ref_mean = 64.3;
stance_ref_std = 0.8233;

%% figure 2

resultFiles = {
    fullfile([ResultsRepo '\with_better_knee\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig21_N100_pp.mat'])
    fullfile([ResultsRepo '\with_better_knee\Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_ig21_pp.mat']);
    };
LegNames = {'3-segment foot model','2-segment foot model Falisse et al.'};


joints_sim = {'hip_flexion_r','hip_adduction_r','knee_angle_r','ankle_angle_r','subtalar_angle_r','mtj_angle_r','mtp_angle_r'};
joints_ref = {'hip_flexion','hip_adduction','knee_angle','ankle_angle','subtalar_angle','mtj_angle','mtp_angle'};

muscles_sim = {'soleus_r','med_gas_r','tib_ant_r','per_long_r','per_brev_r','FDB_r'};
muscles_ref = {'Soleus','Gastrocnemius-medialis','Tibialis-anterior','Peroneus-longus','Peroneus-brevis','Plantar-intrinsic'};
m_scale = [3.33, 2.94, 8/1.38, 6.40, 3,1];

joints_tit = {'Hip flexion','Hip adduction','Knee','Ankle','Subtalar','Midtarsal','MTP'};
GRF_title = {'Forward','Vertical','Lateral'};

%
line_linewidth = 2;
label_fontsize = 9;
CsV = [[0 0.4470 0.7410];[0.4660 0.6740 0.1880];[0.6350 0.0780 0.1840]];
mrk = {'-','-.',':','--'};
set(0,'defaultFigureColor','w')

%
fig2 = figure();
fig2.Position = [269 136 1200 600];
tl2 = tiledlayout(4,7);
tl2.TileSpacing = 'tight';

for i_res=1:length(resultFiles)
    load(resultFiles{i_res},'R')
    x = 1:(100-1)/(size(R.Qs,1)-1):100;
    x_to1 = x(R.GRFs(:,2) > 3);
    x_to2 = x(x>=R.Event.Stance);
    x_to12 = intersect(x_to1,x_to2);
    x_to = x_to12(end);

    %% kinematics
    for i=1:length(joints_sim)
        nexttile(i)
        % plot reference data
        if i_res==1
            idx_jref = strcmp(Qref.colheaders,joints_ref{i});
            if sum(idx_jref) == 1
                meanPlusSTD = (Qref.Qall_mean(:,idx_jref) + 2*Qref.Qall_std(:,idx_jref));
                meanMinusSTD = (Qref.Qall_mean(:,idx_jref) - 2*Qref.Qall_std(:,idx_jref));

                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

                hold on
                p1=fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],...
                    'LineStyle','none','DisplayName','Experimental data (mean \pm 2 SD)');

                xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

                if i==1
                    leg = p1;
                end

            end
        end % end plot ref data

        % plot sim result
        idx_jsim = strcmp(R.colheaders.joints,joints_sim{i});
        if any(idx_jsim)
            hold on
            p1=plot(x,R.Qs(:,idx_jsim),'linewidth',line_linewidth,'Color',CsV(i_res,:),...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',LegNames{i_res});
            hold on
            xline(x_to,'Color',CsV(i_res,:),'linewidth',line_linewidth/2,...
                        'LineStyle',mrk{rem(i_res-1,length(mrk))+1})
            if i==1
                leg = [leg,p1];
                if i_res==length(resultFiles)
                    lg = legend(leg);
                    lg.Layout.Tile = 4*7;
                end
            end
        end

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Angle (°)','Fontsize',label_fontsize);
                ylb.Position(1) = -27;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(joints_tit{i},'Fontsize',label_fontsize);

        end
    end % end of kinematics

    %% kinetics
    for i=1:length(joints_sim)
        nexttile(i+length(joints_sim))
        % plot reference data
        if i_res==1 && i<5
            idx_jref = strcmp(Tref.colheaders,joints_ref{i});
            if sum(idx_jref) == 1
                meanPlusSTD = (Tref.Tall_mean(:,idx_jref) + 2*Tref.Tall_std(:,idx_jref))/R.body_mass;
                meanMinusSTD = (Tref.Tall_mean(:,idx_jref) - 2*Tref.Tall_std(:,idx_jref))/R.body_mass;

                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

                hold on
                fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],'LineStyle','none');

                xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

            end
        end % end plot ref data

        % plot sim result
        idx_jsim = strcmp(R.colheaders.joints,joints_sim{i});
        if any(idx_jsim)
            hold on
            plot(x,R.Tid(:,idx_jsim)/R.body_mass,'linewidth',line_linewidth,'Color',CsV(i_res,:),...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
            hold on
            xline(x_to,'Color',CsV(i_res,:),'linewidth',line_linewidth/2,...
                        'LineStyle',mrk{rem(i_res-1,length(mrk))+1})
        end

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Moment (Nm/kg)','Fontsize',label_fontsize);
                ylb.Position(1) = -27;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
        end
    end % end of kinetics


    %% powers
    for i=1:4
        nexttile(i+2*length(joints_sim))
        % plot reference data
        if i_res==1 && i<5
            idx_jref = strcmp(Pref.colheaders,joints_ref{i});
            if sum(idx_jref) == 1
                meanPlusSTD = (Pref.Pall_mean(:,idx_jref) + 2*Pref.Pall_std(:,idx_jref))/R.body_mass;
                meanMinusSTD = (Pref.Pall_mean(:,idx_jref) - 2*Pref.Pall_std(:,idx_jref))/R.body_mass;

                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

                hold on
                fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],  0.8*[1,1,1],'LineStyle','none');

                xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

            end
        end % end plot ref data

        % plot sim result
        idx_jsim = strcmp(R.colheaders.joints,joints_sim{i});
        Pji = R.Qdots(:,idx_jsim)*pi/180.*R.Tid(:,idx_jsim)/R.body_mass;
        hold on
        plot(x,Pji,'linewidth',line_linewidth,'Color',CsV(i_res,:),...
            'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
        hold on
        xline(x_to,'Color',CsV(i_res,:),'linewidth',line_linewidth/2,...
                    'LineStyle',mrk{rem(i_res-1,length(mrk))+1})

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Power (W/kg)','Fontsize',label_fontsize);
                ylb.Position(1) = -27;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
        end
    end % end of powers


    %% GRFs
    for i=1:3
        nexttile(i+2*length(joints_sim)+4)
        % plot reference data
        if i_res==1
            meanPlusSTD = Data.GRF.Fmean(:,i) + 2*Data.GRF.Fstd(:,i);
            meanMinusSTD = Data.GRF.Fmean(:,i) - 2*Data.GRF.Fstd(:,i);

            stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
            intervalQ = 1:stepQ:size(R.Qs,1);
            sampleQ = 1:size(R.Qs,1);
            meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
            meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

            hold on
            fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],'LineStyle','none');

            xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

        end % end plot ref data

        % plot sim result
        hold on
        plot(x,R.GRFs(:,i),'linewidth',line_linewidth,'Color',CsV(i_res,:),...
            'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
        hold on
        xline(x_to,'Color',CsV(i_res,:),'linewidth',line_linewidth/2,...
                    'LineStyle',mrk{rem(i_res-1,length(mrk))+1})

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylabel('GRF (% BW)','Fontsize',label_fontsize);
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(GRF_title{i});
        end
    end % end of GRFs

    %% muscle activity
    for i=1:length(muscles_sim)
        nexttile(i+3*length(joints_sim))
        % plot reference data
        if i_res==1
            imus = strcmp(Data.EMGheaders,muscles_ref{i});
            if sum(idx_jref) == 1 && i<6
                meanPlusSTD = (Data.lowEMG_mean(:,imus) + 2*Data.lowEMG_std(:,imus))*m_scale(i);
                meanMinusSTD = (Data.lowEMG_mean(:,imus) - 2*Data.lowEMG_std(:,imus))*m_scale(i);

                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

                hold on
                fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],'LineStyle','none');

                xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

            end
        end % end plot ref data

        % plot sim result
        idx_jsim = strcmp(R.colheaders.muscles,muscles_sim{i});
        if any(idx_jsim)
            hold on
            plot(x,R.a(:,idx_jsim),'linewidth',line_linewidth,'Color',CsV(i_res,:),...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
            hold on
            xline(x_to,'Color',CsV(i_res,:),'linewidth',line_linewidth/2,...
                        'LineStyle',mrk{rem(i_res-1,length(mrk))+1})
        end

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Activation (-)','Fontsize',label_fontsize);
                ylb.Position(1) = -27;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([-0.02,yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(replace(muscles_ref{i},'-',' '),'Fontsize',label_fontsize);
            xlabel('Gait cycle (%)')

        end
    end % end of activity


end

exportgraphics(fig2,fullfile(FigRepo,'figure_2.png'),'Resolution',300);








