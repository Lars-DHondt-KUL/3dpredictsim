
clear
close all
clc

%% load reference data

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

FigRepo = fullfile(pathRepo,'Figures');
ResultsRepo = fullfile(pathRepo,'Results');
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

load([pathRepo '\Data\Fal_s1.mat'],'Data');

RefData = 'Fal_s1_mtjc4_FK_custom_right';

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
%     fullfile([ResultsRepo '\results_paper\Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_ig1_N100_pp.mat']);
%     fullfile([ResultsRepo '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'])
    };
LegNames = {'Predictive simulation with 3-segment foot model'};
% LegNames = {'2-segment foot model Falisse et al.','new 2-segment foot model','3-segment foot model'};


joints_sim = {'hip_flexion_r','hip_adduction_r','knee_angle_r','ankle_angle_r','subtalar_angle_r','mtj_angle_r','mtp_angle_r'};
joints_ref = {'hip_flexion','hip_adduction','knee_angle','ankle_angle','subtalar_angle','mtj_angle','mtp_angle'};

muscles_sim = {'vas_med_r','soleus_r','med_gas_r','tib_ant_r','per_long_r','per_brev_r','FDB_r'};
muscles_ref = {'Vastus-medialis','Soleus','Gastrocnemius-medialis','Tibialis-anterior','Peroneus-longus','Peroneus-brevis','Plantar-intrinsic'};
muscles_title = {'Vastus medialis','Soleus','Gastrocnemius','Tibialis anterior','Peroneus longus','Peroneus brevis','Plantar intrinsic'};
m_scale = [10 3.33, 2.94, 8/1.38, 6.40, 3,1];

joints_tit = {'Hip flexion','Hip adduction','Knee','Ankle','Subtalar','Midtarsal','MTP'};
GRF_title = {'Forward','Vertical','Lateral'};

%

label_fontsize = 10;
legend_fontsize = 12;
title_fontsize = 11;

% CsV = {[0.4660 0.6740 0.1880],'k','k'};
CsV = {[0.8500 0.3250 0.0980],'k','k'};
CsV = {'k','k','k'};
mrk = {'-','-.','-','--'};
lw = [1,1,2];

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

    line_linewidth = lw(i_res);

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
            p1=plot(x,R.Qs(:,idx_jsim),'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',LegNames{i_res});
            hold on
            px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
                        'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
            uistack(px,"bottom");

            if i==1
                leg = [leg,p1];
                if i_res==length(resultFiles)
                    lg = legend(leg,'Orientation','Horizontal','Fontsize',legend_fontsize);
                    lg.Layout.Tile = 'South';
                    lg.Box = 'off';
                end
            end
        end

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Angle (°)','Fontsize',label_fontsize);
                ylb.Position(1) = -28;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(joints_tit{i},'Fontsize',title_fontsize);

        end
    end % end of kinematics

    %% kinetics
    for i=1:length(joints_sim)
        nexttile(i+length(joints_sim))
        % plot reference data
        if i_res==1 && i<6
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
            plot(x,R.Tid(:,idx_jsim)/R.body_mass,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
            hold on
            px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
                        'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
            uistack(px,"bottom");
        end

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Moment (Nm/kg)','Fontsize',label_fontsize);
                ylb.Position(1) = -28;
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
        plot(x,Pji,'linewidth',line_linewidth,'Color',CsV{i_res},...
            'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
        hold on
        px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
                    'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
        uistack(px,"bottom");

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Power (W/kg)','Fontsize',label_fontsize);
                ylb.Position(1) = -28;
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
        plot(x,R.GRFs(:,i),'linewidth',line_linewidth,'Color',CsV{i_res},...
            'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
        hold on
        px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
                    'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
        uistack(px,"bottom");

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
            title(GRF_title{i},'Fontsize',title_fontsize);

        end
    end % end of GRFs

    %% muscle activity
    for i=1:length(muscles_sim)
        nexttile(i+3*length(joints_sim))
        % plot reference data
        if i_res==1
            imus = strcmp(Data.EMGheaders,muscles_ref{i});
            if sum(idx_jref) == 1 && i<7
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
            plot(x,R.a(:,idx_jsim),'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
            hold on
            px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
                        'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
            uistack(px,"bottom");
        end

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Activation (-)','Fontsize',label_fontsize);
                ylb.Position(1) = -28;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([-0.02,yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(muscles_title{i},'Fontsize',title_fontsize);
            xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)

        end
    end % end of activity


end


%%

str = '(a)';
annotation(gcf,'textbox',[0.05,0.93,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(b)';
annotation(gcf,'textbox',[0.05,0.7,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(c)';
annotation(gcf,'textbox',[0.05,0.5,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);


str = '(d)';
annotation(gcf,'textbox',[0.54,0.5,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);


str = '(e)';
annotation(gcf,'textbox',[0.05,0.27,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);



%%

exportgraphics(fig2,fullfile(FigRepo,'figure_validation_gait2.jpeg'),'Resolution',300);








