
clear
close all
clc

FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\figures\draft';
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

%% load rference data

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
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

%% figure 

resultFiles = {
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100_pp.mat'])
    };
LegNames = {'Nominal 3-segment foot model','Nominal 2-segment foot model',...
    'Stiffer Achilles tendon (3-segment)','Stiffer Achilles tendon (2-segment)'};


joints_ref = {'knee_angle','ankle_angle'};
joints_tit = {'Knee','Ankle'};

muscles_sim = {'soleus_r','med_gas_r'};
muscles_ref = {'Soleus','Gastrocnemius-medialis'};
muscles_title = {'Soleus','Gastrocnemius'};
m_scale = [3.33, 2.94];

% GRF_title = {'Forward','Vertical','Lateral'};

%

label_fontsize = 12;
legend_fontsize = 12;
title_fontsize = 12;

% CsV = {'k','k',[0.4660 0.6740 0.1880],[0.6350 0.0780 0.1840],[0.3010 0.7450 0.9330]};
CsV = {'k','k',[149, 117, 205]/256,[0.4940 0.1840 0.5560],[115, 45, 217]/256};
mrk = {'-','-.','-','-.'};
lw = [2,1,2,1];

set(0,'defaultFigureColor','w')

%
fig2 = figure();
fig2.Position = [269 136 1200/2 600/2+70];
tl2 = tiledlayout(2,3);
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
    for i=1:length(joints_ref)
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
        idx_jsim = strcmp(R.colheaders.joints,[joints_ref{i} '_r']);
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
                    lg = legend(leg,'numcolumns',2,'Fontsize',legend_fontsize);
%                     lg.Position(2) = lg.Position(2)-0.5;
                    lg.Layout.Tile = 'South';
                    lg.Box = 'off';
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
            title(joints_tit{i},'Fontsize',title_fontsize);
%             xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
            if i==1
                set(gca,'YTick',[-60,-30,0]);
            end
        end
    end % end of kinematics




    %% powers
    for i=2 %1:length(joints_ref)
        nexttile(5)
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
        idx_jsim = strcmp(R.colheaders.joints,[joints_ref{i} '_r']);
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
                ylb.Position(1) = -27;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            ylim([-1.7,3.4])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
%             set(gca,'YTick',[-1,0,1.5,3]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(joints_tit{i},'Fontsize',title_fontsize);
            xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
        end
    end % end of powers



    %% muscle activity
    for i=1:length(muscles_sim)
        nexttile(i*3)
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
            plot(x,R.a(:,idx_jsim),'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
            hold on
            px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
                        'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
            uistack(px,"bottom");
        end

        % layout
        if i_res==length(resultFiles)
%             if i == 1
                ylb = ylabel('Activation (-)','Fontsize',label_fontsize);
%                 ylb.Position(1) = -27;
%             end
            set(gca,'YAxisLocation','right')
            axis tight
            yl = get(gca, 'ylim');
            ylim([-0.02,yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(replace(muscles_title{i},'-',' '),'Fontsize',title_fontsize);
            if i==2
                xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)    
            end
        end
    end % end of activity



    %% Achilles tendon power

    nexttile(4)

    % plot sim result
    iSol = find(strcmp(R.colheaders.muscles,'soleus_r'));
    iGas = find(strcmp(R.colheaders.muscles,'lat_gas_r'));
    iGas2 = find(strcmp(R.colheaders.muscles,'med_gas_r'));
    P_T_Sol = -R.FT(:,iSol).*R.vT(:,iSol)/R.body_mass;
    P_T_Gas = -R.FT(:,iGas).*R.vT(:,iGas)/R.body_mass;
    P_T_Gas2 = -R.FT(:,iGas2).*R.vT(:,iGas2)/R.body_mass;
    P_At = P_T_Sol+P_T_Gas+P_T_Gas2;

    hold on
    plot(x,P_At,'linewidth',line_linewidth,'Color',CsV{i_res},...
        'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
    hold on
    px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
    uistack(px,"bottom");

    % layout
    if i_res==length(resultFiles)
%         if i == 1
            ylb = ylabel('Power (W/kg)','Fontsize',label_fontsize);
            ylb.Position(1) = -27;
%         end
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
        ylim([-1.7,3.4])
        xlim([0,100])
        set(gca,'XTick',[0:50:100]);
%         set(gca,'YTick',[-1,0,1.5,3]);
        set(gca,'Fontsize',label_fontsize);
        set(gca,'XTickLabelRotation',0)
        title('Achilles tendon','Fontsize',title_fontsize);
        xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
    end



end

exportgraphics(fig2,fullfile(FigRepo,'figure_Atendon_stiffness.jpeg'),'Resolution',300);








