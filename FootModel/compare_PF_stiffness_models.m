clear
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/VariousFunctions']);
AddCasadiPaths();

set(0,'defaultTextInterpreter','tex');

%%
N = 1000;
ls = 0.150;
S.R_mtth = 9.5e-3;
S.sf_PF = 10;

l = linspace(ls,ls+0.02,N);
l_0 = linspace(ls-5e-4,ls+3e-3,N);
l_0p = linspace(ls,ls+2e-3,N);
q_mt = linspace(-30,30,N)'*pi/180;
q_mtp = linspace(-45,45,N)*pi/180;

% PF_stiffness = {'Cheng2008','Gefen2002','Ker1987','Natali2010','Song2011','linear','tanh'};
PF_stiffness = {'Cheng2008','Gefen2002','Natali2010','Song2011','linear'};
% PF_stiffness = {'Natali2010'};

% mtj_stiffness = {'Gefen2002','Ker1987','fitted1'};
mtj_stiffness = {'Gefen2002','Ker1987','Song2011'};
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
CsV = hsv(numel(PF_stiffness));
figure
for i=1:numel(PF_stiffness)
    subplot(231)
    hold on
    plot((l-ls)*1000,F_PF(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Elongation (mm)')
    ylabel('Force (N)')
    title('Plantar fascia force')
    ylim([0,2000])

    subplot(333)
    hold on
    pl=plot((l_0-ls)/ls*100,F_PF_0(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i});
    pls(i)=pl;
    grid on
    xlabel('Nominal strain (%)')
    ylabel('Force (N)')
    title('Plantar fascia force')
%     ylim([-10,200])
    
    subplot(336)
    hold on
    plot((l_0-ls)/ls*100,g_F_PF(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Nominal strain (%)')
    ylabel('\nablaF')
    title('Plantar fascia force gradient')

    subplot(339)
    hold on
    plot((l_0-ls)/ls*100,H_F_PF(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Nominal strain (%)')
    ylabel('\nabla^2F')
    title('Plantar fascia force Hessian')
    
    subplot(232)
    hold on
    plot(q_mtp*180/pi,T_mtp(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Mtp angle (�)')
    ylabel('Torque (Nm)')
    title('Plantar fascia torque on mtp')


    subplot(235)
    hold on
    plot(q_mtp*180/pi,T_mtp3(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Mtp angle (�)')
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
    xlabel('Midtarsal angle (�)')
    ylabel('Torque (Nm)')
    title('Midtarsal stiffness models')
    ylim([-100,100])
end

% plot(q_mt*180/pi,-q_mt*k_mtj,'DisplayName',['k = ' num2str(k_mtj) ' Nm/rad'])



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

figNamePrefix = 'D:\OneDrive\WTK\thesis\figuren\matlab\stiffness';

h1=figure;
for i=1:numel(PF_stiffness)
    hold on
    plot((l-ls)*1000,F_PF(i,:),'Color',CsV(i,:),'DisplayName',PF_stiffness{i})
    grid on
    legend('Location','best')
    xlabel('Elongation (mm)')
    ylabel('Force (N)')
    title('Plantar fascia force')
    ylim([0,2000])
end

set(h1,'PaperPositionMode','auto')
print(h1,[figNamePrefix '_PF'],'-dpng','-r0')
    
% h2=figure;
% for i=1:numel(mtj_stiffness)
%     hold on
%     plot(q_mt*180/pi,M_li(i,:),'DisplayName',mtj_stiffness{i})
%     grid on
%     legend('Location','best')
%     xlabel('Midtarsal angle (�)')
%     ylabel('Torque (Nm)')
%     title('Midtarsal stiffness models')
%     ylim([-100,100])
% end

% set(h2,'PaperPositionMode','auto')
% print(h2,[figNamePrefix '_mtj'],'-dpng','-r0')

% h3=figure;
% for i=1:numel(PF_stiffness)
%     hold on
%     plot(q_mtp*180/pi,T_mtp3(i,:),'DisplayName',PF_stiffness{i})
%     grid on
%     legend('Location','best')
%     xlabel('Mtp angle (�)')
%     ylabel('Torque (Nm)')
%     title('Full mtp torque')
% end
% plot(q_mtp*180/pi,-17*q_mtp,'--','DisplayName','original')

% set(h3,'PaperPositionMode','auto')
% print(h3,[figNamePrefix '_mtpj'],'-dpng','-r0')


