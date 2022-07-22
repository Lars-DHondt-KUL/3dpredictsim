function [varargout] = PlotResults_FootSim(R,varargin)
fig2 = 0;

% if ~isfield(R,'legname')
%     if ~isfield(R.S,'mtj_stiffness')
%         R.S.mtj_stiffness = '';
%     end
%     legname = ['PF: ' R.PF_stiffness ', l_s = ' num2str(R.S.PF_slack_length*1000) '; mtj: ' R.S.mtj_stiffness];
%     R.legname = legname;
% end

n_mtp = length(R.Qs_mtp);
n_tib = length(R.Fs_tib);

mrk = {'-o','--d','-.v',':*','-p','-x','-s','-h','-+','-<','-^'};

mrk = {mrk{:},mrk{:},mrk{:}};

BW = R.S.mass*9.81;

if ~isempty(varargin)
    CsV = varargin{1};
else
    CsV = 'r';
end
if length(varargin)>=3 && varargin{3}~=0
    numFig = varargin{3};
else
    numFig = -1;
end
    
if length(varargin)>=2 && varargin{2}~=0
    h = varargin{2};
    BoolFirst = 0;
    if numFig <1
        tab1 = h.Parent.Children(1).Children(1).Children(1);
        tab2 = h.Parent.Children(1).Children(1).Children(2);
        tab3 = h.Parent.Children(1).Children(1).Children(3);
        tab4 = h.Parent.Children(1).Children(1).Children(4);
        tab5 = h.Parent.Children(1).Children(1).Children(5);
        tab6 = h.Parent.Children(1).Children(1).Children(6);
        tab7 = h.Parent.Children(1).Children(1).Children(7);
    end
else
    h = figure('Position',[82,151,1497,827]);
    BoolFirst = 1;
    h.Name = 'FootModel_Results';
    if numFig <1
        hTabGroup = uitabgroup;
        tab1 = uitab(hTabGroup, 'Title', 'Unloaded');
        tab2 = uitab(hTabGroup, 'Title', 'Load effects 1');
        tab3 = uitab(hTabGroup, 'Title', 'Load effects 2');
        tab4 = uitab(hTabGroup, 'Title', 'Arch stiffness');
        tab5 = uitab(hTabGroup, 'Title', 'mtp');
        tab6 = uitab(hTabGroup, 'Title', 'mtp stiffening');
        tab7 = uitab(hTabGroup, 'Title', 'mtj');
    end
end

    


% return figure handle if wanted
if nargout == 1
    varargout{1} = h;
end

%% unloaded condition
if numFig <1
    axes('parent', tab1);
elseif numFig==1
    figure(h)
end
if numFig <1 || numFig==1
    subplot(3,3,1)
    hold on
    idx_20 = find((R.Qs_mtp)*180/pi==-20);
    if length(R.Qs_mtp)>1 && ~isempty(idx_20)
        l0 = max(R.l_fa_ext(idx_20,1));
        plot(R.Qs_mtp*180/pi,R.l_fa_ext(:,1)./l0,'.','color',CsV,'MarkerSize',15)
        c = polyfit(R.Qs_mtp'*180/pi,R.l_fa_ext(:,1)./l0,1);
        lm = polyval(c,R.Qs_mtp*180/pi);
        plot(R.Qs_mtp*180/pi,lm,'--','color',CsV)

        ylabel('Arch length normalised to max (-)')

        text(-10,lm(end),['y = ' num2str(c(2),3) ' + ' num2str(c(1)*50,3) ' *(x/50°)'],'color',CsV);
    else
        plot(R.Qs_mtp*180/pi,R.l_fa_ext(:,1)*1000,'-o','color',CsV)
        ylabel('arch length (mm)')

    end
    xlabel('Mtp angle (°)')
    title('Foot arch length')

%     return

    subplot(3,3,2)
    hold on
    plot(R.Qs_mtp*180/pi,R.h_fa_ext(:,1)*1000,'-o','color',CsV)
    xlabel('mtp angle (°)')
    ylabel('arch height (mm)')
    title('Foot arch height')

    subplot(3,3,3)
    hold on
    plot(R.Qs_mtp*180/pi,R.Qs(:,1,R.jointfi.mtj.r)*180/pi,'-o','color',CsV,'DisplayName',R.legname)
    xlabel('mtp angle (°)')
    ylabel('mtj angle (°)')
    title('Midtarsal joint angle')
    lg12 = legend('Location','northeast','Interpreter','none');
    lhPos = lg12.Position;
    lhPos(1) = lhPos(1)+0.1;
    set(lg12,'position',lhPos);

    subplot(3,3,4)
    hold on
    plot(R.Qs_mtp*180/pi,R.l_PF(:,1)*1000,'-o','color',CsV)
    xlabel('mtp angle (°)')
    ylabel('PF length (mm)')
    title('Plantar fascia length')

    subplot(3,3,5)
    hold on
    if isfield(R,'MA_PF')
        plot(R.Qs_mtp*180/pi,R.MA_PF(:,1)*1000,'-o','color',CsV)
    end
    xlabel('mtp angle (°)')
    ylabel('PF moment arm (mm)')
    title('Plantar fascia moment arm')

    subplot(3,3,6)
    hold on
    plot(R.Qs_mtp*180/pi,R.T_mtj.lig(:,1),'-o','color',CsV)
    xlabel('mtp angle (°)')
    ylabel('Torque (Nm)')
    title('mt torque (except PF)')

    subplot(3,3,7)
    hold on
    plot(R.Qs_mtp*180/pi,R.F_PF(:,1),'-o','color',CsV)
    xlabel('mtp angle (°)')
    ylabel('F PF (N)')
    title('Plantar fascia force')

    subplot(3,3,8)
    hold on
    plot(R.Qs_mtp*180/pi,R.T_mtj.PF(:,1),'-o','color',CsV)
    xlabel('mtp angle (°)')
    ylabel('Torque (Nm)')
    title('Plantar fascia torque')

    subplot(3,3,9)
    hold on
    plot(R.Qs_mtp*180/pi,R.GRF_calcn(:,1,2),'-o','color',CsV)
    hold on
    plot(R.Qs_mtp*180/pi,R.GRF_forefoot(:,1,2),'-*','color',CsV)
    xlabel('mtp angle (°)')
    ylabel('GRF_y (N)')
    title('vertical GRF')
    lg13=legend('calcaneus','forefoot','Location','northeast','Interpreter','none');
    lhPos = lg13.Position;
    lhPos(1) = lhPos(1)+0.1;
    set(lg13,'position',lhPos);

end

%%

if numFig <1
    axes('parent', tab2);
elseif numFig==2
    figure(h)
end
if numFig <1 || numFig==2
    
    for i=1:n_mtp
%         axes('parent', tab2);

        js = find(R.failed(i,:)==0);
        Fs_tib = R.Fs_tib(js);

        subplot(2,3,1)
        hold on
        plot(Fs_tib,R.l_fa_ext(i,js)*1000,mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('arch length (mm)')
        title('Foot arch length (sagittal)')

        subplot(2,3,2)
        hold on
        plot(Fs_tib,R.h_fa_ext(i,js)*1000,mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('arch height (mm)')
        title('Foot arch height (sagittal)')

        subplot(2,3,3)
        hold on
        if isfield(R,'MA_PF')
            plot(Fs_tib,R.MA_PF(i,js)*1000,mrk{i},'Color',CsV)
        end
        xlabel('tibia force (N)')
        ylabel('PF moment arm (mm)')
        title('Plantar fascia moment arm')

        subplot(2,3,4)
        hold on
        plot(Fs_tib,R.l_PF(i,js)*1000,mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('PF length (mm)')
        title('Plantar fascia length (sagittal)')

        subplot(2,3,5)
        hold on
        plot(Fs_tib,R.F_PF(i,js),mrk{i},'Color',CsV,...
            'DisplayName',[num2str(R.Qs_mtp(i)*180/pi) '°; ' R.legname])
        xlabel('tibia force (N)')
        ylabel('F PF (N)')
        title('Plantar fascia force')
        lg02=legend('Location','northeast','Interpreter','none');

    end

    title(lg02,'mtp, model')
    lhPos = lg02.Position;
    lhPos(1) = lhPos(1)+0.25;
    set(lg02,'position',lhPos);
end

%%
if numFig <1
    axes('parent', tab3);
elseif numFig==1
    figure(h)
end
if numFig <1 || numFig==3
    
    for i=1:n_mtp
    %     axes('parent', tab3);

        js = find(R.failed(i,:)==0);
        Fs_tib = R.Fs_tib(js);

        subplot(4,4,1)
        hold on
        plot(Fs_tib,R.Qs(i,js,R.jointfi.ankle.r)*180/pi,mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('angle (°)')
        title('ankle angle')

        subplot(4,4,2)
        hold on
        plot(Fs_tib,R.Qs(i,js,R.jointfi.subt.r)*180/pi,mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('angle (°)')
        title('subtalar angle')

        subplot(4,4,3)
        hold on
        plot(Fs_tib,R.Qs(i,js,R.jointfi.mtj.r)*180/pi,mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('angle (°)')
        title('midtarsal angle')

        subplot(4,4,4)
        hold on
        plot(Fs_tib,R.Qs(i,js,R.jointfi.mtp.r)*180/pi,mrk{i},'Color',CsV,...
            'DisplayName',[num2str(R.Qs_mtp(i)*180/pi) '°, ' R.legname])
        xlabel('tibia force (N)')
        ylabel('angle (°)')
        lg02=legend('Location','northeast','Interpreter','none');
        title('mtp angle')

        subplot(4,4,5)
        hold on
        plot(Fs_tib,R.T_ankle.muscle(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('ankle muscle moment')

        subplot(4,4,9)
        hold on
        plot(Fs_tib,R.T_ankle.pass(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('ankle passive torque')

        subplot(4,4,6)
        hold on
        plot(Fs_tib,R.T_subt.muscle(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('subtalar muscle moment')

        subplot(4,4,10)
        hold on
        plot(Fs_tib,R.T_subt.pass(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('subtalar passive torque')

        subplot(4,4,7)
        hold on
        plot(Fs_tib,R.T_mtj.muscle(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('midtarsal ligament moment')

        subplot(4,4,11)
        hold on
        plot(Fs_tib,R.T_mtj.pass(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('midtarsal passive torque')

        subplot(4,4,12)
        hold on
        plot(Fs_tib,R.T_mtj.lig(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('midtarsal ligament moment')

        subplot(4,4,15)
        hold on
        plot(Fs_tib,R.T_mtj.PF(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('midtarsal PF moment')

        subplot(4,4,8)
        hold on
        plot(Fs_tib,R.T_mtp.muscle(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('mtp muscle moment')

        subplot(4,4,16)
        hold on
        plot(Fs_tib,R.T_mtp.PF(i,js),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('torque (Nm)')
        title('mtp PF moment')

        subplot(4,4,13)
        hold on
        plot(Fs_tib,R.GRF_calcn(i,js,2),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('GRF_y (N)')
        title('vertical GRF calcaneus')

        subplot(4,4,14)
        hold on
        plot(Fs_tib,R.GRF_forefoot(i,js,2),mrk{i},'Color',CsV)
        xlabel('tibia force (N)')
        ylabel('GRF_y (N)')
        title('vertical GRF forefoot')

        

    end

    title(lg02,'mtp, model')
    lhPos = lg02.Position;
    lhPos(1) = lhPos(1)+0.1;
    set(lg02,'position',lhPos);

end


%%
if numFig <1
    axes('parent', tab4);
elseif numFig==4
    figure(h)
end
if numFig <1 || numFig==4
    
% axes('parent', tab4);

    j = find(R.Qs_mtp(:)==0);

    js = find(R.failed(j,:)==0);
    Fs_tib = R.Fs_tib(js);
    l_fa = R.l_fa_ext(j,js);
    h_fa = R.h_fa_ext(j,js);

    if BoolFirst
        % load reference graph images
        pathmain        = pwd;
        [pathRepo,~,~]  = fileparts(pathmain);
        folder = '\Figures';
        file = 'arch_stiffness_Ker87.png';
        pathRefImg = fullfile(pathRepo,folder,file);
        img_Ker = imread(pathRefImg);
        file = 'arch_stiffness_Welte18.png';
        pathRefImg = fullfile(pathRepo,folder,file);
        img_Welte = imread(pathRefImg);
        file = 'arch_stiffness_Stearne16.png';
        pathRefImg = fullfile(pathRepo,folder,file);
        img_Stearne = imread(pathRefImg);

    end

    subplot(3,5,[1,2,6,7])
%     if R.F_PF(j,js(end))<1
        plot((l_fa-R.L0)*1000,Fs_tib/1000,'-o','color',CsV,'DisplayName',R.legname)
%     else
%         plot((l_fa-l_fa(1))*1000,Fs_tib/1000,'-o','color',CsV,'DisplayName',R.legname)
%     end
    hold on
    if BoolFirst
        hi1 = image([1,9.65]*0.9-1,flip([0,4]*0.9^2),img_Ker);
        uistack(hi1,'bottom')
    end
    xlabel('Horizontal elongation (mm)')
    ylabel('Vertical force (kN)')
    title({'Foot arch stiffness','\rm as defined by Ker et al. (1987)'})
    lg12 = legend('Location','southeast','Interpreter','none');
    lhPos = lg12.Position;
    lhPos(2) = lhPos(2)-0.3;
    set(lg12,'position',lhPos);

% return

    subplot(3,5,[5,10])
%     if R.F_PF(j,js(end))<1
        plot((R.H0-h_fa)*1000,Fs_tib/1000,'color',CsV)
%     else
%         plot((h_fa(1)-h_fa)*1000,Fs_tib/1000,'color',CsV)
%     end
    hold on
    axis tight
    if BoolFirst
        hi2 = image([-2,12],flip([-0.3,6]),img_Stearne);
        uistack(hi2,'bottom')
    end
    xlabel('vertical displacement (mm)')
    ylabel('vertical force (kN)')
    title({'Foot arch stiffness','as defined by Stearne et al, 2016'})

    subplot(3,5,15)
%     if R.F_PF(j,js(end))<1
        plot((R.H0-h_fa(Fs_tib<=300))*1000,Fs_tib(Fs_tib<=300),'color',CsV)
%     else
%         plot((h_fa(1)-h_fa(Fs_tib<=300))*1000,Fs_tib(Fs_tib<=300),'color',CsV)
%     end
    hold on
    xlabel('vertical displacement (mm)')
    ylabel('vertical force (N)')
    title('Detail view')


    j1 = find(R.Qs_mtp(:)==-30*pi/180);
    j2 = find(R.Qs_mtp(:)==30*pi/180);

    if ~isempty(j1) && ~isempty(j2)
        idx = [j1,j2];
        n_i = 2;
    else
        idx = 1:n_mtp;
        n_i = n_mtp;
    end

    for i=1:n_i

        idx_ac = find(R.failed(idx(i),:)==0 & R.Fs_tib<=BW);
        F_ac{i} = R.Fs_tib(idx_ac);
        h0_ac = R.h_fa_ext(idx(i),1);
        tmp = h0_ac - R.h_fa_ext(idx(i),idx_ac);
        ac{i} = tmp;
        ac_max(i) = max(ac{i});
    end

    subplot(3,5,[3,4,8,9])
    hold on
    for i=1:n_i
        ac_rel = ac{i}/max(ac_max);
        plot(ac_rel(:),F_ac{i}/BW,mrk{i},'color',CsV,'DisplayName',['mtp: ' num2str(R.Qs_mtp(idx(i))*180/pi) '°'])
    end
    if BoolFirst
        hi3 = image([0,1],flip([0,0.9]),img_Welte);
        uistack(hi3,'bottom')
    end
    xlabel('arch compression (-)')
    ylabel('vertical force / body weight (-)')
    title({'Foot arch stiffness','\rm as defined by Welte and all, 2018'})
    leg = legend('Location','southeast','Interpreter','none');
    title(leg,'mtp dorsiflexion')
    xlim([0,1])

end

% return

%%
% if numFig <1
%     axes('parent', tab5);
% elseif numFig==5
%     figure(h)
% end
% if numFig <1 || numFig==5
% % axes('parent', tab5);
% 
%     for i=1:n_tib
% 
%         js = find(R.failed(:,i)==0);
% 
%         subplot(2,3,1)
%         hold on
%         plot(R.Qs_mtp(js)*180/pi,R.Qs(js,i,R.jointfi.mtp.r)*180/pi,mrk{i},'Color',CsV,...
%             'DisplayName',[num2str(R.Fs_tib(i)) 'N, ' R.legname])
%         xlabel('angle wrt ground(°)')
%         ylabel('angle wrt forefoot(°)')
%         title('mtp angle')
% 
%         subplot(2,3,2)
%         hold on
%         plot(R.Qs_mtp(js)*180/pi,R.Qs(js,i,R.jointfi.mtj.r)*180/pi,mrk{i},'Color',CsV,...
%             'DisplayName',[num2str(R.Fs_tib(i)) 'N, ' R.legname])
%         xlabel('mtp angle wrt ground(°)')
%         ylabel('angle(°)')
%         title('mtj angle')
% 
%         subplot(2,3,3)
%         hold on
%         T_mtp = R.M_mtp(js,i);% - R.S.kMTP*R.Qs_mtp(:);
%         plot(R.Qs_mtp(js)*180/pi,T_mtp,mrk{i},'Color',CsV,...
%             'DisplayName',[num2str(R.Fs_tib(i)) 'N, ' R.legname])
%         xlabel('mtp angle wrt ground(°)')
%         ylabel('torque(Nm)')
%         title('mtp torque from PF')
%         lg03=legend('Location','northeast');
% 
%         subplot(2,3,4)
%         hold on
%         plot(R.Qs_mtp(js)*180/pi,R.l_PF(js,i)*1000,mrk{i},'Color',CsV,...
%             'DisplayName',[num2str(R.Fs_tib(i)) 'N, ' R.legname])
%         xlabel('mtp angle wrt ground(°)')
%         ylabel('length (mm)')
%         title('PF length')
% 
%         if isfield(R,'T_mtp')
%             subplot(2,3,5)
%             hold on
%             plot(R.Qs_mtp(js)*180/pi,R.T_mtp(js,i),mrk{i},'Color',CsV,...
%                 'DisplayName',[num2str(R.Fs_tib(i)) 'N, ' R.legname])
%             xlabel('mtp angle wrt ground(°)')
%             ylabel('torque(Nm)')
%             title('external mtp torque')
%         end
%     end
%     title(lg03,'F, model')
%     lhPos = lg03.Position;
%     lhPos(2) = lhPos(2)-0.4;
%     set(lg03,'position',lhPos); 
% 
% end

%%

% if numFig <1
%     axes('parent', tab6);
% elseif numFig==6
%     figure(h)
% end
% if numFig <1 || numFig==6
%     
%     % axes('parent', tab6);
%     
% 
%     for i=1:n_tib
%         js = find(R.failed(:,i)==0);
%         T_mtp = R.M_mtp(js,i);
%         
%         pl = polyfit(R.Qs_mtp(js)'*180/pi,T_mtp,1);
%         pln = polyfit(R.Qs(js,i,R.jointfi.mtp.r)*180/pi,T_mtp,1);
% 
%         kg(i) = -pl(1);
%         kf(i) = -pln(1);
% 
%         if isfield(R,'T_mtp')
%             ple = polyfit(R.Qs_mtp(js)'*180/pi,R.T_mtp(js,i),1);
%             plne = polyfit(R.Qs(js,i,R.jointfi.mtp.r)*180/pi,R.T_mtp(js,i),1);
% 
%             kge(i) = ple(1);
%             kfe(i) = plne(1);
%         end
% 
%     end
% 
%     subplot(2,4,1)
%     hold on
%     grid on
%     % p11=plot(Fs_tib(js)/BW,kg,'o','Color',CsV,'DisplayName','toes wrt ground');
%     p12=plot(R.Fs_tib/BW,kf,'d','Color',CsV,'DisplayName','toes wrt forefoot');
%     xlabel('vertical tibia load / BW (-)')
%     ylabel('quasi-stiffness (Nm/°)')
%     title('quasi-stiffness mtp (from PF only)')
%     % lg05=legend([p11,p12]);
%     % title(lg05,'mtp angle definition')
%     % lhPos = lg05.Position;
%     % lhPos(2) = lhPos(2)-0.1;
%     % set(lg05,'position',lhPos); 
% 
%     subplot(2,4,2)
%     hold on
%     grid on
%     % plot(Fs_tib(js)/BW,kg./kg(1),'o','Color',CsV,'DisplayName',R.legname)
%     plot(R.Fs_tib/BW,kf./kf(1),'d','Color',CsV,'DisplayName',R.legname)
%     xlabel('vertical tibia load / BW (-)')
%     ylabel('relative quasi-stiffness (-)')
%     title('quasi-stiffness mtp (from PF only)')
%     lg06=legend('location','northwest');
%     title(lg06,'plantar fascia and midtarsal joint stiffness models')
%     lhPos = lg06.Position;
%     lhPos(2) = lhPos(2)-0.4;
%     set(lg06,'position',lhPos); 
% 
% 
%     if isfield(R,'T_mtp')
%         subplot(2,4,3)
%         hold on
%         grid on
%     %     plot(Fs_tib(js)/BW,kge,'o','Color',CsV,'DisplayName',R.legname)
%         plot(R.Fs_tib/BW,kfe,'d','Color',CsV,'DisplayName',R.legname)
%         xlabel('tibia force / BW (-)')
%         ylabel('quasi-stiffness (Nm/°)')
%         title('quasi-stiffness mtp (external)')
% 
%         subplot(2,4,4)
%         hold on
%         grid on
%     %     plot(Fs_tib(js)/BW,kge./kge(1),'o','Color',CsV,'DisplayName',R.legname)
%         plot(R.Fs_tib/BW,kfe./kfe(1),'d','Color',CsV,'DisplayName',R.legname)
%         xlabel('tibia force / BW (-)')
%         ylabel('relative quasi-stiffness (-)')
%         title('quasi-stiffness mtp (external)')
% 
%         subplot(2,4,7)
%         hold on
%         grid on
%         pln = polyfit(R.Fs_tib/BW,kfe./kfe(1),1);
%         plot(R.S.kMT_li,pln(1),'d','Color',CsV,'DisplayName',R.legname)
%         xlabel('mtj stiffness (Nm/rad)')
%         ylabel('mtp quasi-stiffening with load')
%         title('mtp quasi-stiffness increase with load')
%         disp(num2str(pln(1),5))
%     end
%     
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
if numFig <1
    axes('parent', tab7);
elseif numFig==4
    figure(h)
end
if numFig <1 || numFig==7

    idx0 = find(R.Qs_mtp(:) == 0);
    js = find(R.failed(idx0,:)==0);
    dH0 = min(R.talus_or(idx0,js))*1e3;

    for i=1:n_mtp
    %     axes('parent', tab3);

        js = find(R.failed(i,:)==0);
        Fs_tib = R.Fs_tib(js);

        subplot(2,2,1)
        hold on
        plot(R.Qs(i,js,R.jointfi.mtj.r)*180/pi,R.T_mtj.ext(i,js)/R.S.mass,...
            mrk{i},'Color',CsV,'DisplayName',[num2str(R.Qs_mtp(i)*180/pi) '°; ' R.legname])
        xlabel('angle (°)')
        ylabel('torque (Nm/kg)')
        title('midtarsal joint')

        subplot(2,2,2)
        hold on
        dH = R.talus_or(i,js)*1e3;
        dH = dH - dH0;
        ddH = dH(2:end) - dH(1:end-1);
        idxH = find(ddH>=0);
        plot(dH(idxH),Fs_tib(idxH)/BW,mrk{i},'Color',CsV,'DisplayName',...
            [num2str(R.Qs_mtp(i)*180/pi) '°; ' R.legname])
        xlabel('vertical displacement ankle (mm)')
        ylabel('vertical force (N/BW)')
        title('vertical stiffness')

    end

    legend('Location','best','Interpreter','none');

    subplot(2,2,1)
    hold on
    plot([0,2.5],[0,-1],'--k')


end



%%
if fig2
    % 
    h2 = figure('Position',[82,151,1497,827]);
    h2.Name = R.PF_stiffness;
    CsV1 = hsv(n_mtp);
    CsV2 = hsv(n_tib);

    %%

    for i=1:n_mtp

        figure(h2)
        subplot(2,3,[1,4])
        xy = [squeeze(R.toes_or(i,1,1:2)),squeeze(R.midfoot_or(i,1,1:2)),...
            squeeze(R.calcn_or(i,1,1:2)),squeeze(R.talus_or(i,1,1:2)),...
            squeeze(R.tibia_or(i,1,1:2))];

        hold on
        grid on
        plot(xy(1,:),xy(2,:),'-o','Color',CsV1(i,:),'DisplayName',['mtp: ' num2str(R.Qs_mtp(i)*180/pi) '°'])
        axis equal

    end

    title('sagittal plane (right)')
    xlabel('x')
    ylabel('y')
    lg_pos=legend('Location','best');
    title(lg_pos,'F_y = 0N')

    %%

    j = find(R.Qs_mtp(:)==0);
    leg1 = [];

    xmin = 0;
    xmax = 0;
    ymin = 0;
    ymax = 0;
    zmin = 0;
    zmax = 0;

%     for i=1:(ceil(n_tib/5)):n_tib
    for i=1:n_tib
        if R.failed(j,i) == 0
            figure(h2)

            xy = [squeeze(R.toes_or(j,i,1:2)),squeeze(R.midfoot_or(j,i,1:2)),...
                squeeze(R.calcn_or(j,i,1:2)),squeeze(R.talus_or(j,i,1:2)),...
                squeeze(R.tibia_or(j,i,1:2))];

            z = [squeeze(R.toes_or(j,i,3)),squeeze(R.midfoot_or(j,i,3)),...
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
            plot(xy(1,4:5),xy(2,4:5),'-','Color',CsV2(i,:))
            plot(xy(1,1),xy(2,1),'x','Color',CsV2(i,:))
            plot(xy(1,2),xy(2,2),'d','Color',CsV2(i,:))
            plot(xy(1,3),xy(2,3),'.','Color',CsV2(i,:))
            plot(xy(1,4),xy(2,4),'*','Color',CsV2(i,:))
            axis equal
            title('sagittal plane (right)')
            xlabel('x')
            ylabel('y')
            if i>1
                ylim(range_y)
                xlim(range_x)
            end
            range_y = get(gca, 'ylim');

            subplot(2,3,3)
            hold on
            plot(-z(1,4:5),xy(2,4:5),'-','Color',CsV2(i,:))
            p1=plot(-z(1,1),xy(2,1),'x','Color',CsV2(i,:),'DisplayName',['F_y = ' num2str(R.Fs_tib(i)) 'N']);
            plot(-z(1,2),xy(2,2),'d','Color',CsV2(i,:))
            plot(-z(1,3),xy(2,3),'.','Color',CsV2(i,:))
            plot(-z(1,4),xy(2,4),'*','Color',CsV2(i,:))
            leg1(end+1) = p1;
            axis equal
            title('frontal plane (front)')
            xlabel('-z')
            ylabel('y')
            if i>1
                ylim(range_y)
            end
            range_z = get(gca, 'xlim');
            lg1=legend(leg1,'Location','northeast');

            subplot(2,3,5)
            hold on
            p6=plot(xy(1,4:5),-z(1,4:5),'-','Color',CsV2(i,:),'DisplayName','tibia');
            p2=plot(xy(1,1),-z(1,1),'x','Color',CsV2(i,:),'DisplayName','toes or');
            p3=plot(xy(1,2),-z(1,2),'d','Color',CsV2(i,:),'DisplayName','metatarsi or');
            p4=plot(xy(1,3),-z(1,3),'.','Color',CsV2(i,:),'DisplayName','calcn or');
            p5=plot(xy(1,4),-z(1,4),'*','Color',CsV2(i,:),'DisplayName','talus or');
            lg2=legend([p2,p3,p4,p5,p6],'Location','northeast');
            axis equal
            title('transverse plane (top)')
            xlabel('x')
            ylabel('-z')
            if i>1
                xlim(range_x)
                ylim(range_z)
            end
            
        end
    end


    figure(h2)
    title(lg1,'colour meaning')
    lhPos = lg1.Position;
    lhPos(2) = lhPos(2)-0.4;
    % lhPos(1) = lhPos(1)+0.1;
    set(lg1,'position',lhPos);

    title(lg2,'symbol meaning')
    lhPos = lg2.Position;
    lhPos(1) = lhPos(1)+0.2;
    set(lg2,'position',lhPos);




    figure(h)
end

end