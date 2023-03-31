
clear
close all
clc

%% load reference data

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

FigRepo = fullfile(pathRepo,'Figures');
ResultsRepo = fullfile(pathRepo,'Results');

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
    fullfile([ResultsRepo '\with_better_knee\Fal_s1_mtjc4_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_MG_exp5_table_d01_PF_none_ls141_FDB2_lTs120_Fpsl10_ig21_pp.mat'])
    };
LegNames = {'Nominal 3-segment foot model','Low-arched foot without plantar fascia'};


joints_ref = {'knee_angle','ankle_angle'};
joints_tit = {'Knee','Ankle'};

muscles_sim = {'soleus_r','med_gas_r'};
muscles_ref = {'Soleus','Gastrocnemius-medialis'};
m_scale = [3.33, 2.94];

GRF_title = {'Forward','Vertical','Lateral'};

%

label_fontsize = 12;
legend_fontsize = 12;
title_fontsize = 12;

CsV = {'k',[0.3010 0.7450 0.9330],[0.4660 0.6740 0.1880],[0.6350 0.0780 0.1840]};
mrk = {'-','-.','-','-.'};
lw = [2,2,2,2];

set(0,'defaultFigureColor','w')

%
fig2 = figure();
fig2.Position = [269 136 1200 300];
tl2 = tiledlayout(1,6);
tl2.TileSpacing = 'tight';

%%
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

% Digitised data from: 
% [1] M. C. O’Neill, B. Demes, N. E. Thompson, and B. R. Umberger, 
% “Three-dimensional kinematics and the origin of the hominin walking stride,” 
% Journal of The Royal Society Interface, vol. 15, no. 145, p. 20180205, Aug. 2018, 
% doi: 10.1098/rsif.2018.0205.
% [2] M. C. O’Neill, B. Demes, N. E. Thompson, S. G. Larson, J. T. Stern, and 
% B. R. Umberger, “Adaptations for bipedal walking: Musculoskeletal structure and 
% three-dimensional joint mechanics of humans and bipedal chimpanzees (Pan troglodytes),” 
% Journal of Human Evolution, vol. 168, p. 103195, Jul. 2022, doi: 10.1016/j.jhevol.2022.103195.

x_ch = linspace(1,100,100);
x_ch_s = linspace(1,stance_ref_mean,100);
if exist(fullfile(pathRepo,'Figures','chimp_ankle_df.csv'),'file')
    chimp_ankle_dat = importdata(fullfile(pathRepo,'Figures','chimp_ankle_df.csv'));
    chimp_ankle_df = interp1(chimp_ankle_dat.data(:,1),chimp_ankle_dat.data(:,2),x_ch,"spline","extrap");
    
    chimp_knee_dat = importdata(fullfile(pathRepo,'Figures','chimp_knee_flex.csv'));
    chimp_knee_flex = interp1(chimp_knee_dat.data(:,1),chimp_knee_dat.data(:,2),x_ch,"spline","extrap");
    
    chimp_qs = [-chimp_knee_flex', chimp_ankle_df'];
    
    chimp_ankle_dat = importdata(fullfile(pathRepo,'Figures','chimp_ankle.csv'));
    chimp_ankle = interp1(chimp_ankle_dat.data(:,1),chimp_ankle_dat.data(:,2),x_ch,"spline","extrap");
    
    chimp_knee_dat = importdata(fullfile(pathRepo,'Figures','chimp_knee.csv'));
    chimp_knee = interp1(chimp_knee_dat.data(:,1),chimp_knee_dat.data(:,2),x_ch,"spline","extrap");
    
    chimp_Ts = [chimp_knee', chimp_ankle'];
    
    chimp_GRFx_dat = importdata(fullfile(pathRepo,'Figures','chimp_GRFx.csv'));
    chimp_GRFx = interp1(chimp_GRFx_dat.data(:,1),chimp_GRFx_dat.data(:,2),x_ch,"spline","extrap");
    
    chimp_GRFy_dat = importdata(fullfile(pathRepo,'Figures','chimp_GRFy.csv'));
    chimp_GRFy = interp1(chimp_GRFy_dat.data(:,1),chimp_GRFy_dat.data(:,2),x_ch,"spline","extrap");
    
    chimp_GRF = [chimp_GRFx',chimp_GRFy'];

    refdat=1;
else
    refdat=0;
end

%%
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
        if i_res==1 && refdat
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

                p2=plot(x_ch,chimp_qs(:,i),'Color',[0 0.4470 0.7410],...
                    'LineWidth',3,'DisplayName',"Experimental data chimpanzee (mean) (O'Neill et al.)");

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

        end

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Angle (°)','Fontsize',label_fontsize);
%                 ylb.Position(1) = -27;
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
    end % end of kinematics


    %% kinetics
    for i=1:length(joints_ref)
        nexttile(i+2)
        % plot reference data
        if i_res==1 && i<6 && refdat
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
                p1=fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],'LineStyle','none','DisplayName','Experimental data human (mean \pm 2 SD)');

%                 xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

                leg_length = 0.85; % to unscale normalised data to human scale
                p2=plot(x_ch,chimp_Ts(:,i)*9.81*leg_length,'Color',[0 0.4470 0.7410],...
                    'LineWidth',3,'DisplayName',"Experimental data chimpanzee (mean) (O'Neill et al.)");

                if i==1
                    leg = [p1,p2];
                end

            end
        end % end plot ref data

        % plot sim result
        idx_jsim = strcmp(R.colheaders.joints,[joints_ref{i} '_r']);
        if any(idx_jsim)
            hold on
            plot(x,R.Tid(:,idx_jsim)/R.body_mass,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',LegNames{i_res});
            hold on
%             px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
%                         'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
%             uistack(px,"bottom");
        end


        if i==1
            leg = [leg,p1];
            if i_res==length(resultFiles)
                lg = legend('Fontsize',legend_fontsize,'numcolumns',2);
                lg.Layout.Tile = 'South';
                lg.Box = 'off';
            end
        end

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Moment (Nm/kg)','Fontsize',label_fontsize);
%                 ylb.Position(1) = -27;
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
    end % end of kinetics


    

    %% GRFs
    for i=1:2
        nexttile(i+2+2)
        % plot reference data
        if i_res==1 && refdat
            meanPlusSTD = Data.GRF.Fmean(:,i) + 2*Data.GRF.Fstd(:,i);
            meanMinusSTD = Data.GRF.Fmean(:,i) - 2*Data.GRF.Fstd(:,i);

            stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
            intervalQ = 1:stepQ:size(R.Qs,1);
            sampleQ = 1:size(R.Qs,1);
            meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
            meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

            hold on
            fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],'LineStyle','none');

%             xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)
            plot(x_ch_s,chimp_GRF(:,i)*100,'Color',[0 0.4470 0.7410],'LineWidth',3,'DisplayName','Experimental data chimpanzee (mean)');

        end % end plot ref data

        % plot sim result
        hold on
        plot(x,R.GRFs(:,i),'linewidth',line_linewidth,'Color',CsV{i_res},...
            'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',' ');
        hold on
%         px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
%                     'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
%         uistack(px,"bottom");

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
            xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
        end
    end % end of GRFs

    
  

end

%%

str = '(a)';
annotation(gcf,'textbox',[0.06,0.95,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(b)';
annotation(gcf,'textbox',[0.34,0.95,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(c)';
annotation(gcf,'textbox',[0.62,0.95,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

%%

exportgraphics(fig2,fullfile(FigRepo,'figure_chimp.jpeg'),'Resolution',300);








