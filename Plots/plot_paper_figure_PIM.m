
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
    };
LegNames = {'Nominal 4-segment foot model', 'Without intrinsic muscle'};



joints_ref = {'knee_angle','ankle_angle','mtj_angle','mtp_angle'};
joints_tit = {'Knee','Ankle','Midtarsal','MTP'};

muscles_sim = {'soleus_r','med_gas_r'};
muscles_ref = {'Soleus','Gastrocnemius-medialis'};
m_scale = [3.33, 2.94];

GRF_title = {'Forward','Vertical','Lateral'};

%

label_fontsize = 12;
legend_fontsize = 14;
title_fontsize = 14;

CsV = {'k',[0 0.4470 0.7410],[0.4660 0.6740 0.1880],[0.6350 0.0780 0.1840],[0.3010 0.7450 0.9330],[0.8500 0.3250 0.0980]};
mrk = {'-','-','-',':','--'};
lw = [2,2];

set(0,'defaultFigureColor','w')

%
fig2 = figure();
fig2.Position = [269 136 1200 700];
tl2 = tiledlayout(2,4);
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

    tlct = 1;

    %% kinematics
%     for i=1:length(joints_ref)
%         nexttile(tlct); tlct=tlct+1;
%         % plot reference data
%         if i_res==1
%             idx_jref = strcmp(Qref.colheaders,joints_ref{i});
%             if sum(idx_jref) == 1
%                 meanPlusSTD = (Qref.Qall_mean(:,idx_jref) + 2*Qref.Qall_std(:,idx_jref));
%                 meanMinusSTD = (Qref.Qall_mean(:,idx_jref) - 2*Qref.Qall_std(:,idx_jref));
% 
%                 stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
%                 intervalQ = 1:stepQ:size(R.Qs,1);
%                 sampleQ = 1:size(R.Qs,1);
%                 meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
%                 meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);
% 
%                 hold on
%                 p1=fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],...
%                     'LineStyle','none','DisplayName','Experimental data (mean \pm 2 SD)');
% 
%                 xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)
% 
%                 if i==3
%                     leg = p1;
%                 end
% 
%             end
%         end % end plot ref data
% 
%         % plot sim result
%         idx_jsim = strcmp(R.colheaders.joints,[joints_ref{i} '_r']);
%         if any(idx_jsim)
%             hold on
%             p1=plot(x,R.Qs(:,idx_jsim),'linewidth',line_linewidth,'Color',CsV{i_res},...
%                 'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',LegNames{i_res});
%             hold on
%             px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
%                         'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
%             uistack(px,"bottom");
% 
%             if i==3
%                 leg = [leg,p1];
%                 if i_res==length(resultFiles)
%                     lg = legend(leg,'Fontsize',legend_fontsize,'Location','northwest','NumColumns',3);
%                     lg.Position(2) = lg.Position(2)-0.45;
%                     lg.Position(1) = lg.Position(1)+0.24;
%                     lg.Box = 'off';
%                     lg.Layout.Tile = 'South';
%                 end
%             end
%         end
% 
%         % layout
%         if i_res==length(resultFiles)
%             if i == 1
%                 ylb = ylabel('Angle (°)','Fontsize',label_fontsize);
% %                 ylb.Position(1) = -38;
%             end
%             axis tight
%             yl = get(gca, 'ylim');
%             ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
%             xlim([0,100])
%             set(gca,'XTick',[0:20:100]);
%             set(gca,'Fontsize',label_fontsize);
%             set(gca,'XTickLabelRotation',0)
%             title(joints_tit{i},'Fontsize',title_fontsize);
% %             if i>2
% %                 xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
% %             end
% 
%         end
%     end % end of kinematics

    
   
% kinetics
    for i=1:length(joints_ref)
        nexttile(tlct); tlct=tlct+1;
        % plot reference data
        if i_res==1 && i<3
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
                p1=fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],...
                    'LineStyle','none','DisplayName','Experimental data (mean \pm 2 SD)');

%                 xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

                if i==1
                    leg = p1;
                end

            end
        end % end plot ref data

        % plot sim result
        idx_jsim = strcmp(R.colheaders.joints,[joints_ref{i} '_r']);
        if any(idx_jsim)
            hold on
            p1=plot(x,R.Tid(:,idx_jsim)/R.body_mass,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',LegNames{i_res});
            hold on
%             px=xline(x_to,'Color',CsV{i_res},'linewidth',line_linewidth/2,...
%                         'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
%             uistack(px,"bottom");

            if i==1
                leg = [leg,p1];
                if i_res==length(resultFiles)
                    lg = legend(leg,'Fontsize',legend_fontsize,'Location','northwest','NumColumns',3);
                    lg.Position(2) = lg.Position(2)-0.45;
                    lg.Position(1) = lg.Position(1)+0.24;
                    lg.Box = 'off';
                    lg.Layout.Tile = 'South';
                end
            end

            ax_i(i) = gca;
        end

        

        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Moment (Nm/kg)','Fontsize',label_fontsize);
%                 ylb.Position(1) = -28;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:20:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(joints_tit{i},'Fontsize',title_fontsize);
        end
    end % end of kinetics

    
    %% muscle moment


    nexttile(tlct); tlct=tlct+1;
    hold on

    idx_dM = find(strcmp(R.colheaders.dM,'knee_angle_r'));

    imus(1) = find(strcmp(R.colheaders.muscles,'med_gas_r'));
    imus(2) = find(strcmp(R.colheaders.muscles,'lat_gas_r'));

    T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
    T_mus = sum(T_mus,2)/R.body_mass;

    plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-.','DisplayName',' ');
    
    

%     imus = find(~contains(R.colheaders.muscles,'_gas_') & contains(R.colheaders.muscles,'_r'));

    imus = [];
    imus = find(contains(R.colheaders.muscles,'vas_') & contains(R.colheaders.muscles,'_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'rect_fem_r'));

    T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
    T_mus = sum(T_mus,2)/R.body_mass;

    plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','--','DisplayName',' ');


    imus = [];
    imus(1) = find(strcmp(R.colheaders.muscles,'semimem_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'semiten_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'bifemlh_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'bifemsh_r'));

    T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
    T_mus = sum(T_mus,2)/R.body_mass;

    plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle',':','DisplayName',' ');


    yp1(i_res) = -0.35-0.04*i_res;
    
    plot([1,10]+50,yp1(i_res)*[1,1],'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','--','DisplayName',' ');
    plot([1,10]+50,yp1(i_res)*[1,1]-0.11,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle',':','DisplayName',' ');
    plot([1,10]+50,yp1(i_res)*[1,1]-0.22,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-.','DisplayName',' ');

    if i_res==2
        str = {'      Quadriceps','      Hamstrings','      Gastrocnemii'};
        txt=text(50, mean(yp1)-0.11,str,'FontSize',11,'Horiz','left');
%         txt.EdgeColor = 'k';
    end

    nexttile(tlct); tlct=tlct+1;
    hold on

    idx_dM = find(strcmp(R.colheaders.dM,'ankle_angle_r'));

    imus = [];
    imus(1) = find(strcmp(R.colheaders.muscles,'med_gas_r'));
    imus(2) = find(strcmp(R.colheaders.muscles,'lat_gas_r'));
    imus(3) = find(strcmp(R.colheaders.muscles,'soleus_r'));

    T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
    T_mus = sum(T_mus,2)/R.body_mass;

    plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-.','DisplayName',' ');

    imus = [];
    imus(1) = find(strcmp(R.colheaders.muscles,'flex_dig_r'));
    imus(2) = find(strcmp(R.colheaders.muscles,'flex_hal_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'ext_dig_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'ext_hal_r'));
%     imus(end+1) = find(strcmp(R.colheaders.muscles,'tib_post_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'tib_ant_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'per_long_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'per_brev_r'));
    imus(end+1) = find(strcmp(R.colheaders.muscles,'per_tert_r'));

    T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
    T_mus = sum(T_mus,2)/R.body_mass;

    plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-','DisplayName',' ');



%     imus = [];
%     imus(1) = find(strcmp(R.colheaders.muscles,'tib_post_r'));
% 
%     T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
%     T_mus = sum(T_mus,2)/R.body_mass;
% 
%     plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
%                 'LineStyle',':','DisplayName',' ');


    yp2(i_res) = -1.4-0.07*i_res;
    xp2 = [3,3];

    plot([1,10]+xp2(1),yp2(i_res)*[1,1],'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-.','DisplayName',' ');
    plot([1,10]+xp2(2),yp2(i_res)*[1,1]-0.2,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-','DisplayName',' ');

    if i_res==2
        txt=text(xp2(1), mean(yp2),'      Triceps surae','FontSize',11,'Horiz','left');
        txt=text(xp2(2), mean(yp2)-0.2,{'      Extrinsic muscles crossing MTJ'},'FontSize',11,'Horiz','left');
        
%         plot(xp2(2), mean(yp2)-0.3,'.w')
%         txt.EdgeColor = 'k';
    end

    nexttile(tlct); tlct=tlct+1;
    hold on

    idx_dM = find(strcmp(R.colheaders.dM,'mtj_angle_r'));

%     imus = [];
%     imus(1) = find(strcmp(R.colheaders.muscles,'flex_dig_r'));
%     imus(2) = find(strcmp(R.colheaders.muscles,'flex_hal_r'));
% 
%     T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
%     T_mus = sum(T_mus,2)/R.body_mass;
% 
%     plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
%                 'LineStyle','--','DisplayName',' ');


%     imus = [];
%     imus(1) = find(strcmp(R.colheaders.muscles,'tib_post_r'));
    imus = find(~strcmp(R.colheaders.muscles,'FDB_r') & contains(R.colheaders.muscles,'_r'));

    T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
%     T_mus(T_mus>0) = 0;
    T_mus = sum(T_mus,2)/R.body_mass;
%     T_mus = T_mus/R.body_mass;

    plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-','DisplayName',' ');


    imus = find(strcmp(R.colheaders.muscles,'FDB_r'));
    if ~isempty(imus)
        T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
        T_mus = sum(T_mus,2)/R.body_mass;
    
        plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
                    'LineStyle','--','DisplayName',' ');
    end


    M_mtj_PF = R.windlass.MA_PF.mtj.*R.windlass.F_PF;
    plot(x,M_mtj_PF/R.body_mass,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-.','DisplayName',' ');


    yp3(i_res) = -0.7-0.04*i_res;

    if ~isempty(imus)
        plot([1,10]+3,yp3(i_res)*[1,1],'linewidth',line_linewidth,'Color',CsV{i_res},...
                    'LineStyle','--','DisplayName',' ');
    end
    plot([1,10]+3,yp3(i_res)*[1,1]-0.11,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-','DisplayName',' ');
    plot([1,10]+3,yp3(i_res)*[1,1]-0.22,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-.','DisplayName',' ');

    if i_res==2
        str = {'      Plantar intrinsic muscle','      Extrinsic muscles crossing MTJ','      Plantar fascia'};
        txt=text(3, mean(yp3)-0.11,str,'FontSize',11,'Horiz','left');
%         txt.EdgeColor = 'k';
    end


    nexttile(tlct); tlct=tlct+1;
    hold on

    idx_dM = find(strcmp(R.colheaders.dM,'mtp_angle_r'));

%     imus = [];
%     imus(1) = find(strcmp(R.colheaders.muscles,'flex_dig_r'));
%     imus(2) = find(strcmp(R.colheaders.muscles,'flex_hal_r'));
    imus = find(~strcmp(R.colheaders.muscles,'FDB_r') & contains(R.colheaders.muscles,'_r'));

    T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
%     T_mus(T_mus>0) = 0;
    T_mus = sum(T_mus,2)/R.body_mass;

    plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-','DisplayName',' ');

    
    imus = find(strcmp(R.colheaders.muscles,'FDB_r'));
    if ~isempty(imus)
        T_mus = R.FT(:,imus) .* R.dM(:,imus,idx_dM);
        T_mus = sum(T_mus,2)/R.body_mass;
    
        plot(x,T_mus,'linewidth',line_linewidth,'Color',CsV{i_res},...
                    'LineStyle','--','DisplayName',' ');
    end


    M_mtp_PF = R.windlass.MA_PF.mtp.*R.windlass.F_PF;
    plot(x,M_mtp_PF/R.body_mass,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-.','DisplayName',' ');


    yp4(i_res) = -0.125-0.0055*i_res;

    if ~isempty(imus)
        plot([1,10]+3,yp4(i_res)*[1,1],'linewidth',line_linewidth,'Color',CsV{i_res},...
                    'LineStyle','--','DisplayName',' ');
    end
    plot([1,10]+3,yp4(i_res)*[1,1]-0.015,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-','DisplayName',' ');
    plot([1,10]+3,yp4(i_res)*[1,1]-0.03,'linewidth',line_linewidth,'Color',CsV{i_res},...
                'LineStyle','-.','DisplayName',' ');

    if i_res==2
        str = {'      Plantar intrinsic muscle','      Extrinsic muscles crossing MTP','      Plantar fascia'};
        txt=text(3, mean(yp4)-0.015,str,'FontSize',11,'Horiz','left');
%         txt.EdgeColor = 'k';
    end



    for i=1:4

        nexttile(1*length(joints_ref)+i)
        hold on
        % layout
        if i_res==length(resultFiles)
            if i == 1
                ylb = ylabel('Moment (Nm/kg)','Fontsize',label_fontsize);
%                 ylb.Position(1) = -28;
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:20:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
            linkaxes([ax_i(i),gca],'y')
        end

    end
   

  

end



%%

str = '(a)';
annotation(gcf,'textbox',[0.01,0.95,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(b)';
annotation(gcf,'textbox',[0.01,0.52,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);



%%
exportgraphics(fig2,fullfile(FigRepo,'figure_wo_PIM.jpeg'),'Resolution',300);








