
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
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Natali2010_ls146_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_FDB2_lTs125_Fpsl10_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper\Fal_s1_mtjc4_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_Gefen2002_ls146_ig1_N100_pp.mat'])
    };
LegNames = {'stiff plantar fascia, without intrinsic muscle (Nominal)', 'stiff plantar fascia, without intrinsic muscle',...
    'compliant plantar fascia, with intrinsic muscle','compliant plantar fascia, without intrinsic muscle'};



joints_ref = {'knee_angle','ankle_angle','mtj_angle','mtp_angle'};
joints_tit = {'Knee','Ankle','Midtarsal','MTP'};

muscles_sim = {'soleus_r','med_gas_r'};
muscles_ref = {'Soleus','Gastrocnemius-medialis'};
m_scale = [3.33, 2.94];

GRF_title = {'Forward','Vertical','Lateral'};

%

label_fontsize = 12;
legend_fontsize = 12;
title_fontsize = 12;

CsV = {'k',[0.4660 0.6740 0.1880],[0.6350 0.0780 0.1840],[0.3010 0.7450 0.9330]};
mrk = {'-','-.','-',':'};
lw = [2,2,2,2];

set(0,'defaultFigureColor','w')

%
fig2 = figure();
fig2.Position = [269 136 1200 600/2+50];
tl2 = tiledlayout(2,6);
tl2.TileSpacing = 'tight';

for i_res=1:length(resultFiles)
    load(resultFiles{i_res},'R')
    x = 1:(100-1)/(size(R.Qs,1)-1):100;
    x_to1 = x(R.GRFs(:,2) > 3);
    x_to2 = x(x>=R.Event.Stance);
    x_to12 = intersect(x_to1,x_to2);
    x_to12 = x_to12(x_to12<70);
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

                if i==3
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

            if i==3
                leg = [leg,p1];
                if i_res==length(resultFiles)
                    lg = legend(leg,'Fontsize',legend_fontsize,'Location','northwest');
                    lg.Position(2) = lg.Position(2)-0.45;
                    lg.Position(1) = lg.Position(1)+0.24;
                    lg.Box = 'off';
%                     lg.Layout.Tile = 'South';
                end
            end
        end

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Angle (°)','Fontsize',label_fontsize);
                ylb.Position(1) = -35;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(joints_tit{i},'Fontsize',title_fontsize);
%             if i>2
%                 xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
%             end

        end
    end % end of kinematics

    
   


    %% GRFs
    for i=2
        nexttile(5)
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
            if i
                ylabel('GRF (% BW)','Fontsize',label_fontsize);
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(GRF_title{i},'FontSize',title_fontsize);
            xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
        end
    end % end of GRFs

    %% cost of transport
    nexttile(6)

    % plot sim result
    hold on
    p1=plot(i_res,R.COT,'o','Color',CsV{i_res});

    if mrk{rem(i_res-1,length(mrk))+1} == '-'
        p1.MarkerFaceColor = CsV{i_res};
    else
        plot(i_res,R.COT,'.','Color',CsV{i_res});
    end


    % layout
    if i_res==length(resultFiles)
%         if i == 1
            ylabel('(J kg^-^1 m^-^1)','Fontsize',label_fontsize);
%         end

%         ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
        xlim([0.5,i_res+0.5])
        set(gca,'XTick','');
        set(gca,'Fontsize',label_fontsize);
        set(gca,'XTickLabelRotation',0)
        title('Cost of Transport','FontSize',title_fontsize);
    end



%     %% Achilles tendon power
% 
%     nexttile(7)
% 
%     % plot sim result
%     iSol = find(strcmp(R.colheaders.muscles,'soleus_r'));
%     iGas = find(strcmp(R.colheaders.muscles,'lat_gas_r'));
%     iGas2 = find(strcmp(R.colheaders.muscles,'med_gas_r'));
%     P_T_Sol = -R.FT(:,iSol).*R.vT(:,iSol)/R.body_mass;
%     P_T_Gas = -R.FT(:,iGas).*R.vT(:,iGas)/R.body_mass;
%     P_T_Gas2 = -R.FT(:,iGas2).*R.vT(:,iGas2)/R.body_mass;
%     P_At = P_T_Sol+P_T_Gas+P_T_Gas2;
% 
%     hold on
%     plot(x,P_At,'linewidth',line_linewidth,'Color',CsV{i_res},...
%         'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
%     hold on
%     px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
%                 'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
%     uistack(px,"bottom");
% 
%     % layout
%     if i_res==length(resultFiles)
% %         if i == 1
%             ylb = ylabel('Power (W/kg)','Fontsize',label_fontsize);
%             ylb.Position(1) = -35;
% %         end
%         axis tight
%         yl = get(gca, 'ylim');
%         ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
%         ylim([-1.6,3.3])
%         xlim([0,100])
%         set(gca,'XTick',[0:50:100]);
%         set(gca,'Fontsize',label_fontsize);
%         set(gca,'XTickLabelRotation',0)
%         title('Achilles tendon','Fontsize',title_fontsize);
%         xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
%     end

    %% powers
    for i=2
        nexttile(7)
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
            if i == 2
                ylb = ylabel('Power (W/kg)','Fontsize',label_fontsize);
                ylb.Position(1) = -35;
                ylb.Position(2) = 1.2;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:50:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(joints_tit{i},'Fontsize',title_fontsize);
            xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
        end
    end % end of powers

    %% total leg joint power

    nexttile(8)

    % plot reference data
        if i_res==1
            idx_jref = strcmp(Pref.colheaders,'leg_total');
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
    leg_joints = {'hip_flexion_r','hip_adduction_r','hip_rotation_r','knee_angle_r',...
        'ankle_angle_r','subtalar_angle_r','mtj_angle_r','mtp_angle_r'};

    P_leg_joints = 0;

    for ip=1:length(leg_joints)
        idxp = find(strcmp(R.colheaders.joints,leg_joints{ip}));
        if ~isempty(idxp)
            Pip = R.Qdots(:,idxp).*R.Tid(:,idxp)*pi/180;
            P_leg_joints = P_leg_joints + Pip/R.body_mass;
        end
    end

    hold on
    plot(x,P_leg_joints,'linewidth',line_linewidth,'Color',CsV{i_res},...
        'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
    hold on
    px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
    uistack(px,"bottom");

    % layout
    if i_res==length(resultFiles)
%         if i == 1
%             ylb = ylabel('Power (W/kg)','Fontsize',label_fontsize);
%             ylb.Position(1) = -20;
%         end
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
        ylim([-1.6,3.3])
        xlim([0,100])
        set(gca,'XTick',[0:50:100]);
        set(gca,'Fontsize',label_fontsize);
        set(gca,'XTickLabelRotation',0)
        title('Joint total','Fontsize',title_fontsize);
        xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
    end


    %% plantar fascia

    nexttile(9)

    l_PF = R.windlass.l_PF;
    F_PF = R.windlass.F_PF;

    hold on
    ls = R.S.Foot.PF_slack_length;
    PF_strain = (l_PF./ls-1)*100;
    plot(x,PF_strain,'Color',CsV{i_res},'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'linewidth',line_linewidth)
    title('Plantar fascia','Fontsize',title_fontsize);
    xlabel('Gait cycle (%)','Fontsize',label_fontsize+1);
    ylabel('Strain (%)','Fontsize',label_fontsize);
    axis tight
    yl = get(gca, 'ylim');
    ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
    xlim([0,100])
    set(gca,'XTick',[0:50:100]);
    set(gca,'Fontsize',label_fontsize);
    set(gca,'XTickLabelRotation',0)

    nexttile(10)

    hold on
    plot(PF_strain,F_PF/60,'Color',CsV{i_res},'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'linewidth',line_linewidth)
    title('Plantar fascia','Fontsize',title_fontsize);
    xlabel('Strain (%)','Fontsize',label_fontsize);
    ylabel('Stress (MPa)','Fontsize',label_fontsize);
    axis tight
    yl = get(gca, 'ylim');
    ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
    xl = get(gca, 'xlim');
    xlim([xl(1)-0.1*norm(xl),xl(2)+0.1*norm(xl)])
    set(gca,'Fontsize',label_fontsize);

end

%%

str = '(a)';
annotation(gcf,'textbox',[0.06,0.96,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(b)';
annotation(gcf,'textbox',[0.625,0.96,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(c)';
annotation(gcf,'textbox',[0.77,0.96,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);


str = '(d)';
annotation(gcf,'textbox',[0.06,0.49,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);


str = '(e)';
annotation(gcf,'textbox',[0.35,0.49,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);




%%
% exportgraphics(fig2,fullfile(FigRepo,'figure_plantar_stiffness.jpeg'),'Resolution',300);








