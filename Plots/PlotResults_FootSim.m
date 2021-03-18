function [] = PlotResults_FootSim(R)

n_mtp = length(R.Qs_mtp);
n_tib = length(R.Fs_tib);

CsV = hsv(n_mtp);

h = figure('Position',[82,151,1497,827]);
h.Name = 'FootModel_Results';
hTabGroup = uitabgroup;
tab1 = uitab(hTabGroup, 'Title', 'Unloaded');
tab2 = uitab(hTabGroup, 'Title', 'Load effects');

tab4 = uitab(hTabGroup, 'Title', 'Positions');
tab3 = uitab(hTabGroup, 'Title', 'Arch stiffness');

%% unloaded condition
axes('parent', tab1);

% l0 = interp1(R.Qs_mtp*180/pi,R.l_fa(:,1),-29);
% l1 = interp1(R.Qs_mtp*180/pi,R.l_fa(:,1),30);

subplot(3,3,1)
hold on
plot(R.Qs_mtp*180/pi,R.l_fa(:,1)*1000)
hold on
% plot([-30,30],[1,0.95]*l0*1000,'--k')
xlabel('mtp angle (�)')
ylabel('arch length(mm)')
title('Foot arch length')

subplot(3,3,2)
hold on
plot(R.Qs_mtp*180/pi,R.h_fa(:,1)*1000)
xlabel('mtp angle (�)')
ylabel('arch height(mm)')
title('Foot arch height')

subplot(3,3,4)
hold on
plot(R.Qs_mtp*180/pi,R.l_PF(:,1)*1000)
xlabel('mtp angle (�)')
ylabel('PF length(mm)')
title('Plantar fascia length')

subplot(3,3,5)
hold on
plot(R.Qs_mtp*180/pi,R.M_li(:,1))
xlabel('mtp angle (�)')
ylabel('Torque (Nm)')
title('other passive torques')

subplot(3,3,6)
hold on
plot(R.Qs_mtp*180/pi,R.Qs(:,1,R.jointfi.tmt.r)*180/pi)
xlabel('mtp angle (�)')
ylabel('mt angle (�)')
title('Midtarsal joint angle')


subplot(3,3,7)
hold on
plot(R.Qs_mtp*180/pi,R.F_PF(:,1))
xlabel('mtp angle (�)')
ylabel('F PF (N)')
title('Plantar fascia force')

subplot(3,3,8)
hold on
plot(R.Qs_mtp*180/pi,R.M_PF(:,1))
xlabel('mtp angle (�)')
ylabel('Torque (Nm)')
title('Plantar fascia torque')

subplot(3,3,9)
hold on
plot(R.Qs_mtp*180/pi,R.GRF_calcn(:,1,2))
hold on
plot(R.Qs_mtp*180/pi,R.GRF_metatarsi(:,1,2))
xlabel('mtp angle (�)')
ylabel('GRF_y (N)')
title('vertical GRF')
legend('calcaneus','metatarsi','Location','best')


subplot(3,3,3)
hold on
for i=1:n_mtp
    
    xy = [squeeze(R.toes_or(i,1,1:2)),squeeze(R.metatarsi_or(i,1,1:2)),...
        squeeze(R.calcn_or(i,1,1:2)),squeeze(R.talus_or(i,1,1:2)),...
        squeeze(R.tibia_or(i,1,1:2))];
    
    plot(xy(1,:),xy(2,:),'-o','Color',CsV(i,:),'DisplayName',['mtp: ' num2str(R.Qs_mtp(i)*180/pi) '�'])
    
end
title('sagittal plane (right)')
xlabel('x')
ylabel('y')
axis equal
ylim([0,0.2])
legend('Location','best')

%%

for i=1:n_mtp
    axes('parent', tab2);
    
    js = find(R.failed(i,:)==0);
    Fs_tib = R.Fs_tib(js);
    
    
    
    subplot(3,3,1)
    hold on
    plot(Fs_tib,R.l_fa(i,js)*1000,'Color',CsV(i,:))
%     plot(Fs_tib,R.l_fa_ext(i,js)*1000,'Color',CsV(i,:))
    xlabel('tibia force (N)')
    ylabel('arch length(mm)')
    title('Foot arch length (sagittal)')

    subplot(3,3,2)
    hold on
    plot(Fs_tib,R.h_fa(i,js)*1000,'Color',CsV(i,:),'DisplayName','Windlass model');
%     plot(Fs_tib,R.h_fa_ext(i,js)*1000,'Color',CsV(i,:),'DisplayName','External func');
    xlabel('tibia force (N)')
    ylabel('arch height (mm)')
    title('Foot arch height (sagittal)')
    

    subplot(3,3,3)
    hold on
    plot(Fs_tib,R.l_PF(i,js)*1000,'Color',CsV(i,:))
    xlabel('tibia force (N)')
    ylabel('PF length(mm)')
    title('Plantar fascia length (sagittal)')
    
    subplot(3,3,4)
    hold on
    plot(Fs_tib,R.Qs(i,js,R.jointfi.subt.r)*180/pi,'Color',CsV(i,:))
    xlabel('tibia force (N)')
    ylabel('subt angle (�)')
    title('subtalar')
    
    subplot(3,3,5)
    hold on
    plot(Fs_tib,R.Qs(i,js,R.jointfi.ankle.r)*180/pi,'Color',CsV(i,:))
    xlabel('tibia force (N)')
    ylabel('ankle angle (�)')
    title('ankle')

    subplot(3,3,6)
    hold on
    plot(Fs_tib,R.Qs(i,js,R.jointfi.tmt.r)*180/pi,'Color',CsV(i,:),'DisplayName',['mtp: ' num2str(R.Qs_mtp(i)*180/pi) '�'])
    xlabel('tibia force (N)')
    ylabel('tmt angle (�)')
    lg02=legend('Location','northeast');
    title('tmt')
    
    subplot(3,3,7)
    hold on
    plot(Fs_tib,R.GRF_calcn(i,js,2),'Color',CsV(i,:))
    xlabel('tibia force (N)')
    ylabel('GRF_y calcn (N)')
    title('vertical GRF')

    subplot(3,3,8)
    hold on
    plot(Fs_tib,R.GRF_metatarsi(i,js,2),'Color',CsV(i,:))
    xlabel('tibia force (N)')
    ylabel('GRF_y metatarsi (N)')
    title('vertical GRF')
    
    subplot(3,3,9)
    hold on
    plot(Fs_tib,R.F_PF(i,js),'Color',CsV(i,:))
    xlabel('tibia force (N)')
    ylabel('F PF (N)')
    title('Plantar fascia force')

    axes('parent', tab4);
    subplot(2,3,[1,4])
    xy = [squeeze(R.toes_or(i,1,1:2)),squeeze(R.metatarsi_or(i,1,1:2)),...
        squeeze(R.calcn_or(i,1,1:2)),squeeze(R.talus_or(i,1,1:2)),...
        squeeze(R.tibia_or(i,1,1:2))];
    
    hold on
    grid on
    plot(xy(1,:),xy(2,:),'-o','Color',CsV(i,:),'DisplayName',['mtp: ' num2str(R.Qs_mtp(i)*180/pi) '�'])
%     plot(xy(1,1),xy(2,1),'x','Color',CsV(i,:))
    axis equal
    
end

title('sagittal plane (right)')
xlabel('x')
ylabel('y')
lg_pos=legend('Location','best');
title(lg_pos,'F_y = 0N')
        
% title(lg0,'line meaning')
% lhPos = lg0.Position;
% lhPos(1) = lhPos(1)+0.2;
% set(lg0,'position',lhPos);

title(lg02,'colour code')
lhPos = lg02.Position;
% lhPos(1) = lhPos(1)+0.1;
lhPos(2) = lhPos(2)+0.3;
set(lg02,'position',lhPos);


%%
axes('parent', tab4);

j = find(R.Qs_mtp(:)==0);
CsV = hsv(n_tib);
leg1 = [];

xmin = 0;
xmax = 0;
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 0;

for i=1:2:n_tib
    if R.failed(j,i) == 0

        xy = [squeeze(R.toes_or(j,i,1:2)),squeeze(R.metatarsi_or(j,i,1:2)),...
            squeeze(R.calcn_or(j,i,1:2)),squeeze(R.talus_or(j,i,1:2)),...
            squeeze(R.tibia_or(j,i,1:2))];

        z = [squeeze(R.toes_or(j,i,3)),squeeze(R.metatarsi_or(j,i,3)),...
            squeeze(R.calcn_or(j,i,3)),squeeze(R.talus_or(j,i,3)),...
            squeeze(R.tibia_or(j,i,3))];

        xmin = min(xmin,min(xy(1,:)));
        xmax = max(xmax,max(xy(1,:)));
        ymin = min(ymin,min(xy(2,:)));
        ymax = max(ymax,max(xy(2,1:end-1)));
        zmin = min(zmin,min(z));
        zmax = max(zmax,max(z));
        
        range_x = [xmin-0.01,xmax+0.01];
        range_y = [ymin-0.01,ymin-0.01+norm(range_x)];
        
        subplot(2,3,2)
        hold on
        plot(xy(1,4:5),xy(2,4:5),'-','Color',CsV(i,:))
        plot(xy(1,1),xy(2,1),'x','Color',CsV(i,:))
        plot(xy(1,2),xy(2,2),'o','Color',CsV(i,:))
        plot(xy(1,3),xy(2,3),'.','Color',CsV(i,:))
        plot(xy(1,4),xy(2,4),'*','Color',CsV(i,:))
        axis equal
        title('sagittal plane (right)')
        xlabel('x')
        ylabel('y')
        ylim(range_y)
        xlim(range_x)
        range_y = get(gca, 'ylim');

        subplot(2,3,3)
        hold on
        plot(-z(1,4:5),xy(2,4:5),'-','Color',CsV(i,:))
        p1=plot(-z(1,1),xy(2,1),'x','Color',CsV(i,:),'DisplayName',['F_y = ' num2str(R.Fs_tib(i)) 'N']);
        plot(-z(1,2),xy(2,2),'o','Color',CsV(i,:))
        plot(-z(1,3),xy(2,3),'.','Color',CsV(i,:))
        plot(-z(1,4),xy(2,4),'*','Color',CsV(i,:))
        leg1(end+1) = p1;
        axis equal
        title('frontal plane (front)')
        xlabel('-z')
        ylabel('y')
        ylim(range_y)
        range_z = get(gca, 'xlim');
        lg1=legend(leg1,'Location','northeast');

        subplot(2,3,5)
        hold on
        p6=plot(xy(1,4:5),-z(1,4:5),'-','Color',CsV(i,:),'DisplayName','tibia');
        p2=plot(xy(1,1),-z(1,1),'x','Color',CsV(i,:),'DisplayName','toes or');
        p3=plot(xy(1,2),-z(1,2),'o','Color',CsV(i,:),'DisplayName','metatarsi or');
        p4=plot(xy(1,3),-z(1,3),'.','Color',CsV(i,:),'DisplayName','calcn or');
        p5=plot(xy(1,4),-z(1,4),'*','Color',CsV(i,:),'DisplayName','talus or');
        lg2=legend([p2,p3,p4,p5,p6],'Location','northeast');
        axis equal
        title('transverse plane (top)')
        xlabel('x')
        ylabel('-z')
        xlim(range_x)
        ylim(range_z)
    
    end
end


title(lg1,'colour meaning')
lhPos = lg1.Position;
lhPos(2) = lhPos(2)-0.4;
% lhPos(1) = lhPos(1)+0.1;
set(lg1,'position',lhPos);

title(lg2,'symbol meaning')
lhPos = lg2.Position;
lhPos(1) = lhPos(1)+0.2;
set(lg2,'position',lhPos);


js = find(R.failed(j,:)==0);
Fs_tib = R.Fs_tib(js);

%%
axes('parent', tab3);

subplot(1,3,1)
plot((R.l_fa(j,js)- min(R.l_fa(j,js)))*1000,Fs_tib/1000)
hold on
xlabel('horizontal elongation (mm)')
ylabel('vertical force (kN)')
title({'arch stiffness','as defined by Ker et al, 1987'})


subplot(1,3,2)
plot((max(R.h_fa(j,js))-R.h_fa(j,js))*1000,Fs_tib/1000)
hold on
xlabel('vertical displacement (mm)')
ylabel('vertical force (kN)')
title({'arch stiffness','as defined by Stearne et al, 2016'})



for i=1:n_mtp
    BW = R.S.mass*9.81;
    idx_ac = find(R.failed(i,:)==0 & R.Fs_tib<=BW);
    F_ac{i} = R.Fs_tib(idx_ac);
    h0_ac = R.h_fa(i,1);
    tmp = h0_ac - R.h_fa(i,idx_ac);
    ac{i} = tmp;
    ac_max(i) = max(ac{i});
end

CsV = hsv(n_mtp);

subplot(1,3,3)
hold on
grid on
for i=1:n_mtp
    ac_rel = ac{i}/max(ac_max);
    plot(ac_rel(:),F_ac{i}/BW,'-','color',CsV(i,:),'DisplayName',['mtp: ' num2str(R.Qs_mtp(i)*180/pi) '�'])
end
xlabel('arch compression (-)')
ylabel('vertical force /BW (-)')
title({'arch stiffness','as defined by Welte et al, 2018'})
leg = legend('Location','best');
title(leg,'mtp angle')
xlim([0,1])


end