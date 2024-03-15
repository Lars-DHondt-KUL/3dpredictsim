
clear
close all
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);


FigRepo = fullfile(pathRepo,'Figures');
ResultsRepo = fullfile(pathRepo,'Results');

FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\revision 2\figures/supplement';
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

%% load reference data


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

%% figure 2

% % nominal
% results = {
%     '\results_paper\Fal_s1_mtppin_FK_sd_cg1_MTPp_k25_d020_tau_ig1_N100_pp.mat'
%     '\results_paper\Fal_s1_mtp_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPp_k25_d020_tau_ig1_N100_pp.mat'
%     '\results_paper_v2\Fal_s1_mtjcf3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Natali2010_ls146_FDB2_lMo23_lTs123_Fpsl10_ig1_N100_pp.mat'
%     };
% LegNames = {'3-segment foot model Falisse et al.','Nominal 3-segment foot model','Nominal 4-segment foot model'};
% figName = 'nominal';
% CsV = [[0.8500 0.3250 0.0980];[0,0,0];[0,0,0]];
% mrk = {'-','-.','-','--'};
% lw = [2,2,2];

% % reduced stiffness
results = {
    fullfile([ '\results_paper_v2\Fal_s1_mtjcf3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Natali2010_ls146_FDB2_lMo23_lTs123_Fpsl10_ig1_N100_pp.mat'])
    fullfile([ '\results_paper_v2\Fal_s1_mtjcf3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Natali2010_ls146_ig1_N100_pp.mat'])
    fullfile([ '\results_paper_v2\Fal_s1_mtjcf3_FK_sc_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTc5_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Gefen2002_ls146_FDB2_lMo23_lTs123_Fpsl10_ig1_N100_pp.mat'])
    fullfile([ '\results_paper_v2\Fal_s1_mtjc3_FK_sd_cspx10_cg9_o1x10_ATx50_TFMox120_Fpsl10_MTPm_k1_d01_tau_MTJm_nl_lig_d01_PF_Natali2010_ls141_FDB2_lMo23_lTs118_Fpsl10_ig1_N100_pp.mat'])
};
LegNames = {'Nominal 4-segment foot model', 'Without intrinsic muscle','Compliant plantar fascia','Reduced arch height'};
figName = 'plantar_stiffness';
CsV = [[0,0,0];[0 0.4470 0.7410];[0.6350 0.0780 0.1840];[0.3010 0.7450 0.9330];[0.8500 0.3250 0.0980]];
mrk = {'-','-','-','-.','--'};
lw = [2,2,2,2];


resultFiles = results;



label_fontsize = 12;
legend_fontsize = 14;
title_fontsize = 14;



muscles_sim = {'soleus_r','med_gas_r','tib_ant_r','tib_post_r','per_long_r','per_brev_r','per_tert_r','FDB_r','flex_hal_r','flex_dig_r','ext_hal_r','ext_dig_r'};
muscles_ref = {'Soleus','Gastrocnemius-medialis','Tibialis-anterior','','Peroneus-longus','Peroneus-brevis','','','','','',''};
muscles_title = {'Soleus','Gastrocnemius','Tibialis anterior','Tibialis posterior','Peroneus longus','Peroneus brevis','Peroneus tertius',...
    'Plantar intrinsic','Flexor digitorum longus','Flexor hallucis longus','Extensor digitorum longus','Extensor hallucis longus'};
m_scale = [3.33, 2.94, 8/1.38, 1, 3, 3.7, 1,1,1,1,1];


set(0,'defaultFigureColor','w')

%
fig2 = figure();
fig2.Position = [269 136 1200 600];
tl2 = tiledlayout(3,4);
tl2.TileSpacing = 'tight';
tl2.Padding = 'compact';

leg = [];

for i_res=1:length(resultFiles)
    load(fullfile(ResultsRepo, resultFiles{i_res}),'R')
    x = 1:(100-1)/(size(R.Qs,1)-1):100;
    x_to1 = x(R.GRFs(:,2) > 3);
    x_to2 = x(x>=R.Event.Stance);
    x_to12 = intersect(x_to1,x_to2);
    x_to12 = x_to12(x_to12<70);
    x_to = x_to12(end);

    line_linewidth = lw(i_res);

    

    


    


   
    %% muscle activity
    for i=1:length(muscles_sim)
        nexttile(i)
        % plot reference data
        if i_res==1
            imus = strcmp(Data.EMGheaders,muscles_ref{i});
            if sum(imus) == 1 && ~isempty(imus)
                meanPlusSTD = (Data.lowEMG_mean(:,imus) + 2*Data.lowEMG_std(:,imus))*m_scale(i);
                meanMinusSTD = (Data.lowEMG_mean(:,imus) - 2*Data.lowEMG_std(:,imus))*m_scale(i);

                max(Data.lowEMG_mean(:,imus))

                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

                hold on
                p1=fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],...
                    'LineStyle','none','DisplayName','Experimental data (mean \pm 2 SD)');

                if i==1
                    leg = [leg,p1];
                end
                xline(stance_ref_mean,'Color',[1,1,1]*0.5,'linewidth',line_linewidth/2)

            end
        end % end plot ref data

        % plot sim result
        idx_jsim = strcmp(R.colheaders.muscles,muscles_sim{i});
        if any(idx_jsim)
            hold on
            p1=plot(x,R.a(:,idx_jsim),'linewidth',line_linewidth,'Color',CsV(i_res,:),...
                'LineStyle',mrk{rem(i_res-1,length(mrk))+1},'DisplayName',LegNames{i_res});
            hold on
            px=xline(x_to,'Color',CsV(i_res,:),'linewidth',line_linewidth/2,...
                        'LineStyle',mrk{rem(i_res-1,length(mrk))+1});
            uistack(px,"bottom");

            if i==1
                leg = [leg,p1];
                if i_res==length(resultFiles)
                    lg = legend(leg,'Orientation','Horizontal','Fontsize',legend_fontsize,'NumColumns',3);
                    lg.Layout.Tile = 'South';
                    lg.Box = 'off';
                end
            end
        end

        % layout
        if i_res==length(resultFiles)
            if i == 1 || i==5 || i==9
                ylb = ylabel('Activation (-)','Fontsize',label_fontsize);
                ylb.Position(1) = -20;
            end
            if i>8
                xlabel('Gait cycle (%)','Fontsize',label_fontsize+1)
            end

            axis tight
            yl = get(gca, 'ylim');
            ylim([0,yl(2)+0.1*norm(yl)])
            xlim([0,100])
            set(gca,'XTick',[0:20:100]);
            set(gca,'Fontsize',label_fontsize);
            set(gca,'XTickLabelRotation',0)
            title(muscles_title{i},'Fontsize',title_fontsize);
            

        end
    end % end of activity



end



%%

exportgraphics(fig2,fullfile(FigRepo,['figure_act_' figName '.jpeg']),'Resolution',300);








