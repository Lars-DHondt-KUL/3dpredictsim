
clear
close all
clc

%% load reference data

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

FigRepo = fullfile(pathRepo,'Figures');
ResultsRepo = fullfile(pathRepo,'Results');
FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\revision 2\figures';
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

load([pathRepo '\Data\Fal_s1.mat'],'Data');

RefData = 'Fal_s1_mtjcf3_FK_custom_right';

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
    fullfile([ResultsRepo '\results_paper_v2\Fal_s1_mtjcf3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Natali2010_ls146_FDB2_lMo23_lTs123_Fpsl10_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper_v2\Fal_s1_mtjcf3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Natali2010_ls146_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper_v2\Fal_s1_mtjcf3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Gefen2002_ls146_FDB2_lMo23_lTs123_Fpsl10_ig1_N100_pp.mat'])
    fullfile([ResultsRepo '\results_paper_v2\Fal_s1_mtjc3_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Natali2010_ls141_FDB2_lMo23_lTs118_Fpsl10_ig1_N100_pp.mat'])
    };
LegNames = {'Nominal 3-segment foot model', 'Without intrinsic muscle','Compliant plantar fascia','Reduced arch height'};



joints_ref = {'knee_angle','ankle_angle','subtalar_angle','mtj_angle','mtp_angle'};
joints_tit = {'Knee','Ankle','Subtalar','Midtarsal','MTP'};

muscles_sim = {'soleus_r','med_gas_r'};
muscles_ref = {'Soleus','Gastrocnemius-medialis'};
m_scale = [3.33, 2.94];

GRF_title = {'Forward','Vertical','Lateral'};

%

label_fontsize = 12;
legend_fontsize = 14;
title_fontsize = 14;

CsV = {'k',[0 0.4470 0.7410],[0.6350 0.0780 0.1840],[0.3010 0.7450 0.9330],[0.8500 0.3250 0.0980]};
mrk = {'-','-','-','-.','--'};
lw = [2,2,2,2,2];

set(0,'defaultFigureColor','w')

%
fig2 = figure();
fig2.Position = [269 136 1200 500];
tl2 = tiledlayout(2,5);
tl2.TileSpacing = 'tight';
tl2.Padding = 'compact';


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

%                 xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

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
%             px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
%                         'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
%             uistack(px,"bottom");

            if i==3
                leg = [leg,p1];
                if i_res==length(resultFiles)
                    lg = legend(leg,'Fontsize',legend_fontsize,'Location','northwest','NumColumns',3);
                    lg.Position(2) = lg.Position(2)-0.45;
                    lg.Position(1) = lg.Position(1)+0.24;
                    lg.Box = 'off';
                    lg.Layout.Tile = 'South';
                end
            end
        end

        % layout
        if i_res==length(resultFiles)
%             if i == 1
%                 ylb = ylabel('Angle (°)','Fontsize',label_fontsize);
%                 ylb.Position(1) = -38;
%             end
             ylabel('Angle (°)','Fontsize',label_fontsize);
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:20:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(joints_tit{i},'Fontsize',title_fontsize);
%             if i>2
%                 xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
%             end

        end
    end % end of kinematics

    
   

    %% cost of transport

    fprintf("%s\tCOT = %.3f\n",LegNames{i_res},R.COT)
    


    %% powers
    for i=2
        nexttile(6)
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

%                 xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

            end
        end % end plot ref data

        % plot sim result
        idx_jsim = strcmp(R.colheaders.joints,[joints_ref{i} '_r']);
        Pji = R.Qdots(:,idx_jsim)*pi/180.*R.Tid(:,idx_jsim)/R.body_mass;
        hold on
        plot(x,Pji,'linewidth',line_linewidth,'Color',CsV{i_res},...
            'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
        hold on
%         px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
%                     'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
%         uistack(px,"bottom");

        % layout
        if i_res==length(resultFiles)
            if i == 2
                ylb = ylabel('Power (W/kg)','Fontsize',label_fontsize);
%                 ylb.Position(1) = -35;
%                 ylb.Position(2) = 1.2;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:20:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(joints_tit{i},'Fontsize',title_fontsize);
            xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
        end
    end % end of powers


    %% Intrinsic muscle

    nexttile(7)

    idx_jsim = strcmp(R.colheaders.muscles,'FDB_r');
    if any(idx_jsim)
        hold on
        plot(x,R.a(:,idx_jsim),'linewidth',line_linewidth,'Color',CsV{i_res},...
            'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
        hold on
%         px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
%                     'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
    end

    % layout
    if i_res==length(resultFiles)
        ylb = ylabel('Activation (-)','Fontsize',label_fontsize);
%         ylb.Position(2) = 0.35;
        axis tight
        yl = get(gca, 'ylim');
        ylim([-0.02,yl(2)+0.1*norm(yl)])
        xlim([0,100])
        set(gca,'XTick',[0:20:100]);
        set(gca,'Fontsize',label_fontsize);
        set(gca,'XTickLabelRotation',0)
        title('Plantar intrinsic','Fontsize',title_fontsize);
        xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)

    end

    nexttile(8)

    idx_jsim = strcmp(R.colheaders.muscles,'FDB_r');
    if any(idx_jsim)
        hold on
        plot(x,R.lMtilde(:,idx_jsim),'linewidth',line_linewidth,'Color',CsV{i_res},...
            'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
        hold on
%         px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
%                     'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
    end

    % layout
    if i_res==length(resultFiles)
        ylb = ylabel('Fibre length (-)','Fontsize',label_fontsize);
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)-0.05*norm(yl),yl(2)+0.05*norm(yl)])
        xlim([0,100])
        set(gca,'XTick',[0:20:100]);
        set(gca,'Fontsize',label_fontsize);
        set(gca,'XTickLabelRotation',0)
        title('Plantar intrinsic','Fontsize',title_fontsize);
        xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)

    end

end

%%

nexttile(9)
% hold on
img_path = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper/initial submission\figures\draft\OpenSim model';
file = 'foot_sc.png';
pathRefImg = fullfile(img_path,file);
img_foot = imread(pathRefImg);
hi1 = image(img_foot);

% plot(1,1,'.w')
set(gca,'Fontsize',label_fontsize);
tmp = gca;
tmp.XAxis.Color = 'w';
tmp.YAxis.Visible = 'off';
xlabel('Nominal arch height','Fontsize',label_fontsize,'Color','k')
% title('Low arch height','Fontsize',title_fontsize);
axis equal


nexttile(10)
% hold on
file = 'foot_sd.png';
pathRefImg = fullfile(img_path,file);
img_foot = imread(pathRefImg);
hi1 = image(img_foot);

% plot(1,1,'.w')
set(gca,'Fontsize',label_fontsize);
tmp = gca;
tmp.XAxis.Color = 'w';
tmp.YAxis.Visible = 'off';
xlabel('Reduced arch height','Fontsize',label_fontsize,'Color','k')
% title('Regular arch height','Fontsize',title_fontsize);

axis equal

%%

str = '(a)';
annotation(gcf,'textbox',[0.01,0.95,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(b)';
annotation(gcf,'textbox',[0.01,0.55,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(c)';
annotation(gcf,'textbox',[0.20,0.55,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(d)';
annotation(gcf,'textbox',[0.39,0.55,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(e)';
annotation(gcf,'textbox',[0.60,0.55,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);



%%
exportgraphics(fig2,fullfile(FigRepo,'figure_plantar_stiffness3.jpeg'),'Resolution',300);








