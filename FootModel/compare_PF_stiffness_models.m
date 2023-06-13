close all
clear
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/VariousFunctions']);
AddCasadiPaths();

set(0,'defaultTextInterpreter','tex');

%%
N = 1000;
ls = 0.146;
A0 = 60;
S.R_mtth = 9.5e-3;
S.sf_PF = 1;

l = linspace(ls,ls+0.02,N);
l_0 = linspace(ls-5e-4,ls+3e-3,N);
l_0p = linspace(ls,ls+2e-3,N);
q_mt = linspace(-30,30,N)'*pi/180;
q_mtp = linspace(-45,45,N)*pi/180;

% PF_stiffness = {'Cheng2008','Gefen2002','Ker1987','Natali2010','Song2011','linear','tanh'};
% PF_stiffness = {'linear','Natali2010','Cheng2008','Song2011','Gefen2002'};
% PF_stiffness = {'linear','Natali2010','Cheng2008','Gefen2002'};
% PF_stiffness = {'Natali2010','Natali2010','Natali2010','Natali2010'};
% PF_stiffness = {'Natali2010','Gefen2002'};
PF_stiffness = {'Natali2010','Gefen2002','linear','Song2011'};

PF_legNames = {'Natali et al., 2010','Gefen, 2002','linear (E = 350 MPa)','Song et al., 2011'};

% mtj_stiffness = {'Gefen2002','Ker1987','fitted1'};
% mtj_stiffness = {'Gefen2002','Ker1987','Song2011','signed_lin'};
mtj_stiffness = {'Song2011','signed_lin'};
S.MT_li_nonl = 1;
S.kMT_li = 300;          % angular stiffness in case of linear
S.kMT_li2 = 10;          % angular stiffness in case of linear
k_mtj = 300;
k_mtp = 5;

%%
for i=1:numel(PF_stiffness)
    [f_PF_stiffness,grad,Hess,f_PF_stiffness_nonsmoothed] = f_getPlantarFasciaStiffnessModelCasADiFunction(PF_stiffness{i},'ls',ls);
    F_PF(i,:) = full(f_PF_stiffness(l));
    F_PF_0(i,:) = full(f_PF_stiffness(l_0));
    F_PF_0_ns(i,:) = full(f_PF_stiffness_nonsmoothed(l_0p));
    g_F_PF(i,:) = full(grad(l_0));
    H_F_PF(i,:) = full(Hess(l_0));
    for j=1:N
        [~,temp] = getPassiveMtjMomentWindlass_v3(0,0,q_mtp(j),f_PF_stiffness,S);
        T_mtp(i,j) = full(temp);
    end
    T_mtp2(i,:) = T_mtp(i,:) - k_mtp.*q_mtp;
    T_mtp_offset(i,1) = -interp1(q_mtp,T_mtp2(i,:),0,'spline');
    T_mtp3(i,:) = T_mtp2(i,:) + T_mtp_offset(i,1);
end

% + [5;1.4;0.6;6;5;4];

for i=1:numel(mtj_stiffness)
    S.mtj_stiffness = mtj_stiffness{i};
    for j=1:length(q_mt)
        [~,~,~,M2,~,~,~,~,~,~,~] = getPassiveMtjMomentWindlass_v3(q_mt(j),0,0,0,S);
        M_li(i,j) = M2;
    end
    
end


%%
CsV = hsv(numel(PF_stiffness)+1);
figure
for i=1:numel(PF_stiffness)
    subplot(231)
    hold on
    plot((l-ls)*1000,F_PF(i,:),'Color',CsV(i+1,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Elongation (mm)')
    ylabel('Force (N)')
    title('Plantar fascia force')
    ylim([0,2000])

    subplot(333)
    hold on
    pl=plot((l_0-ls)/ls*100,F_PF_0(i,:),'Color',CsV(i+1,:),'DisplayName',PF_stiffness{i});
    pls(i)=pl;
    grid on
    xlabel('Nominal strain (%)')
    ylabel('Force (N)')
    title('Plantar fascia force')
%     ylim([-10,200])
    
    subplot(336)
    hold on
    plot((l_0-ls)/ls*100,g_F_PF(i,:),'Color',CsV(i+1,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Nominal strain (%)')
    ylabel('\nablaF')
    title('Plantar fascia force gradient')

    subplot(339)
    hold on
    plot((l_0-ls)/ls*100,H_F_PF(i,:),'Color',CsV(i+1,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Nominal strain (%)')
    ylabel('\nabla^2F')
    title('Plantar fascia force Hessian')
    
    subplot(232)
    hold on
    plot(q_mtp*180/pi,T_mtp(i,:),'Color',CsV(i+1,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Mtp angle (°)')
    ylabel('Torque (Nm)')
    title('Plantar fascia torque on mtp')


    subplot(235)
    hold on
    plot(q_mtp*180/pi,T_mtp3(i,:),'Color',CsV(i+1,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Mtp angle (°)')
    ylabel('Torque (Nm)')
    title('Full mtp torque')
end

subplot(235)
plot(q_mtp*180/pi,-17*q_mtp,'--','DisplayName','original')
    
for i=1:numel(PF_stiffness)
    subplot(333)
    plot((l_0p-ls)/ls*100,F_PF_0_ns(i,:),'--','Color',pls(i).Color);
end
legend(pls,'Location','best')

for i=1:numel(mtj_stiffness)
    subplot(234)
    hold on
    plot(q_mt*180/pi,M_li(i,:),'DisplayName',mtj_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Midtarsal angle (°)')
    ylabel('Torque (Nm)')
    title('Midtarsal stiffness models')
    ylim([-100,100])
end

plot(q_mt*180/pi,-q_mt*k_mtj,'DisplayName',['k = ' num2str(k_mtj) ' Nm/rad'])



%%

% cf = (tanh((l_0-ls)*1e3/ls)+1)/2; 
% 
% figure
% plot(l_0,cf)


% e = 1.415; % %
% F = 212.5; % N
% l_e = ls*(1+e/100);
% 
% dF = interp1(l_0,g_F_PF(1,:),l_e);
% ddF = interp1(l_0,H_F_PF(1,:),l_e);
% 
% subplot(333)
% plot(e,F,'.k','MarkerSize',10)
% 
% subplot(336)
% plot(e,dF,'.k','MarkerSize',10)
% plot(([l_0(1),l_0(end)]-ls)/ls*100,[dF,dF],'k')



%%

% figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab_final\MLA_vs_WL';

scs = get(0,'ScreenSize');
fsq = [scs(3)/2, scs(4)*0.6];
h1=figure('Position',[100,500,500,500]);
% h1=figure;
% CsV = hsv(numel(PF_stiffness));
CsV = [[0 0 0];[0.8500 0.3250 0.0980];[0.4660 0.6740 0.1880];[0.3010 0.7450 0.9330];[0.4940 0.1840 0.5560];[0.6350 0.0780 0.1840]];
mrk = {'-','-','-.','--'};

for i=1:numel(PF_stiffness)
    hold on
%     if i==4
    plot((l-ls)/ls*100,F_PF(i,:)/A0,mrk{i},'Color',CsV(i,:),'DisplayName',PF_legNames{i},'LineWidth',2)
%     else
%          plot((l-ls)*1000,10*F_PF(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
%     end
%     grid on
%     legend('Location','best')
    xlabel('Strain (%)','FontSize',12)
    ylabel('Stress (MPa)','FontSize',12)
    title('Plantar fascia models','FontSize',12)
%     ylim([0,2000])
    xlim([0,8])
    ylim([0,60])
end
legend('FontSize',12,'Location','southoutside','NumColumns',2,'Box','off')

% set(h1,'PaperPositionMode','auto')
% print(h1,[figNamePrefix '_PF'],'-dpng','-r0')
    
FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\figures\draft/supplement';
% exportgraphics(h1,fullfile(FigRepo,'PF_stiffness.jpeg'),'Resolution',300);


% h2=figure;
% for i=1:numel(mtj_stiffness)
%     hold on
%     plot(q_mt*180/pi,M_li(i,:),'DisplayName',mtj_stiffness{i})
%     grid on
%     legend('Song2011 (k = 800)','k = 10 (q<0), k = 300 (q>0)')
%     xlabel('Midtarsal angle (°)')
%     ylabel('Torque (Nm)')
%     title('Midtarsal stiffness models')
%     ylim([-100,100])
% end
% 
% set(h2,'PaperPositionMode','auto')
% print(h2,[figNamePrefix '_mtj2'],'-dpng','-r0')

% h3=figure;
% CsV = hsv(numel(PF_stiffness));
% for i=1:numel(PF_stiffness)
%     hold on
%     plot(q_mtp*180/pi,T_mtp3(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
% end
% grid on
% legend('Location','best')
% xlabel('Mtp angle (°)')
% ylabel('Torque (Nm)')
% title('Full mtp torque')
% plot(q_mtp*180/pi,-17*q_mtp,'--','DisplayName','Falisse 2019')
% xlim([-20,45])
%     
% 
% set(h3,'PaperPositionMode','auto')
% print(h3,[figNamePrefix '_mtpj'],'-dpng','-r0')

% scs = get(0,'ScreenSize');
% fsq = [scs(3)/2, scs(4)*0.6];
% h4=figure('Position',[100,500,fsq*0.5]);
% CsV = hsv(numel(PF_stiffness)+3);
% A0 = 49.7; % initial cross-section (mm^2)
% for i=1:numel(PF_stiffness)
%     hold on
%     plot((l-ls)/ls*100,F_PF(i,:)/A0,'Color',CsV(i+1,:),'DisplayName',PF_stiffness{i})
%     grid on
% end
% lg=legend('Location','northwest');
% title(lg,'Model name')
% xlabel('Engineering strain (%)')
% ylabel('Engineering stress (MPa)')
% title('Models for plantar fascia under uniaxial tension')
% ylim([0,50])
% 
% set(h4,'PaperPositionMode','auto')
% print(h4,'D:\OneDrive\WTK\thesis\figuren\matlab_final\PF_stiffness_models','-dpng','-r0')
% print(h4,'D:\OneDrive\WTK\thesis\figuren\matlab_final\PF_stiffness_models','-depsc')


%%
% scs = get(0,'ScreenSize');
% figure('Position',[1+scs(3)/2,scs(4)/2+20,scs(3)/2, scs(4)/3]);
% 
% CsV = hsv(numel(PF_stiffness));
% 
% for i=1:numel(PF_stiffness)
%     subplot(131)
%     hold on
%     plot((l_0p-ls)/ls*100,F_PF_0_ns(i,:),'--','Color',CsV(i,:),'DisplayName',[PF_stiffness{i} ' non-smoothed']);
%     plot((l_0-ls)/ls*100,F_PF_0(i,:),'Color',CsV(i,:),'DisplayName',[PF_stiffness{i} ' smoothed']);
%     grid on
%     xlabel('Nominal strain (%)')
%     ylabel('Force (N)')
%     title('Plantar fascia force')
%     xlim([-0.5,2.5])
%     ylim([-10,100])
%     
%     
%     subplot(132)
%     hold on
%     plot((l_0-ls)/ls*100,g_F_PF(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
%     grid on
%     xlabel('Nominal strain (%)')
%     ylabel('\nablaF')
%     title('gradient')
%     xlim([-0.5,2.5])
% 
%     subplot(133)
%     hold on
%     plot((l_0-ls)/ls*100,H_F_PF(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
%     grid on
%     xlabel('Nominal strain (%)')
%     ylabel('\nabla^2F')
%     title('Hessian')
%     xlim([-0.5,2.5])
%     lh=legend('Location','northeast');
% end
%     
% lhPos = lh.Position;
% % lhPos(1) = lhPos(1)+0.5;
% % lhPos(2) = lhPos(2)+0.05;
% set(lh,'position',lhPos);
    
    
    
%%
clearvars

PF_stiffness = {'Natali2010','Gefen2002','linear'};

PF_legNames = {'Natali et al., 2010','Gefen, 2002','linear (E = 350 MPa)'};

l = linspace(1,1.10,200);

for i=1:numel(PF_stiffness)
    [f_PF_stiffness,grad,Hess,f_PF_stiffness_nonsmoothed] = f_getPlantarFasciaStiffnessModelCasADiFunction(PF_stiffness{i},'ls',1,'A0',1);
    F_PF(i,:) = full(f_PF_stiffness(l));
    g_F_PF(i,:) = full(grad(l));

end

h1=figure('Position',[100,500,500,500]);
tiledlayout(1,2)


CsV = [[0 0 0];[0.8500 0.3250 0.0980];[0.4660 0.6740 0.1880];[0.3010 0.7450 0.9330];[0.4940 0.1840 0.5560];[0.6350 0.0780 0.1840]];
mrk = {'-','-','-.','--'};


for i=1:numel(PF_stiffness)
    nexttile(1)
    hold on
%     if i==4
    plot((l-1)*100,F_PF(i,:),mrk{i},'Color',CsV(i,:),'DisplayName',PF_legNames{i},'LineWidth',2)
%     else
%          plot((l-ls)*1000,10*F_PF(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
%     end
%     grid on
%     legend('Location','best')
    xlabel('Strain (%)','FontSize',12)
    ylabel('Stress (MPa)','FontSize',12)
    title('Plantar fascia models','FontSize',12)
%         xlim([0,8])
%         ylim([0,60])

    nexttile(2)
    hold on
    plot((l),g_F_PF(i,:),mrk{i},'Color',CsV(i,:),'DisplayName',PF_legNames{i},'LineWidth',2)
    xlabel('Stretch (-)','FontSize',12)
    ylabel('Stiffness (MPa)','FontSize',12)

end

lg=legend('FontSize',12,'Location','southoutside','NumColumns',2,'Box','off');
lg.Layout.Tile = 'south';
    
    