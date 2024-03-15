close all
clear
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath('../FootModel')

FigRepo = fullfile(pathRepo,'Figures');
FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\revision 2\figures';


%%
S.subject = 'Fal_s1';
S.Foot.Model = 'mtjcf3';
S.Foot.Scaling = 'custom';
S.MTparams = 'MTc5';

S.Foot.contactGeometryVersion = 9;
S.Foot.contactSphereOffset1X = 0.010;
S.Foot.contactStiffnessFactor = 10;
S.Foot.contactSphereOffsetY = 0;
S.passiveFiberForceShift = -0.1;
S.AchillesTendonScaleFactor = 0.5;
S.TricepsFMoScale = 1.2;
S.Foot.mtp_muscles = 1;
S.Foot.mtj_muscles = 1;

S.Foot.PF_stiffness = 'Natali2018';
S.Foot.PF_sf = 1;
S.Foot.PF_slack_length = 0.146;

S.Foot.MT_li_nonl = 1;
S.Foot.mtj_stiffness = 'MG_exp5_table';
S.Foot.mtj_sf = 1; 

S.Foot.FDB = 2;
S.Foot.FDB_lMo = 23e-3;
S.Foot.FDB_lTs = 0.123;
S.Foot.FDB_shift = -0.1;
S.Foot.FDB_sf_FMo = 1;

S.activity = 0.0;
subtR = 1; % reduce subtalar mobility

Qs_mtp = [0];

%%
Results1 = {};

S.Foot.PF_stiffness = 'Natali2010';
S.Foot.PF_sf = 1; 
S.Foot.PF_slack_length = 0.146;
S.Foot.mtj_stiffness = 'MG_exp5_table';
Fs_tib = [0:50:300,400:100:900,1000:200:3000];
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results1{end+1} = R;

S.Foot.PF_stiffness = 'Gefen2002';
S.Foot.PF_sf = 1; 
S.Foot.PF_slack_length = 0.146;
S.Foot.mtj_stiffness = 'MG_exp5_table';
Fs_tib = [0:50:300,400:100:900,1000:200:3000];
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results1{end+1} = R;

S.Foot.PF_stiffness = 'none';
S.Foot.mtj_stiffness = 'MG_exp5_table';
Fs_tib = [0:50:300,400:100:900,1000:200:2400];
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results1{end+1} = R;

S.Foot.FDB = 0;
S.Foot.PF_stiffness = 'none';
S.Foot.mtj_stiffness = 'MG_exp5_table';
Fs_tib = [0:50:300,400:100:900,1000:200:2200];
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results1{end+1} = R;

S.Foot.PF_stiffness = 'none';
S.Foot.mtj_stiffness = 'MG_exp5_d_table';
Fs_tib = [0,20,40,50:50:300,400:100:900,1000:200:1400];
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results1{end+1} = R;

S.Foot.PF_stiffness = 'none';
S.Foot.mtj_stiffness = 'MG_exp5_e_table';
Fs_tib = [0:50:600];
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results1{end+1} = R;

S.Foot.PF_stiffness = 'none';
S.Foot.mtj_stiffness = 'MG_exp5_f_table';
Fs_tib = [0:50:300];
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results1{end+1} = R;

%%

Results3 = {};
S.Foot.PF_stiffness = 'Natali2010';
S.Foot.PF_sf = 1; 
S.Foot.PF_slack_length = 0.146;
S.Foot.mtj_stiffness = 'MG_exp5_table';
% Fs_tib = [0,10,30,50:300,400:100:1000,1200:200:2400];
Fs_tib = [10,50,100:100:1000,1200:200:2400];
Qs_mtp = [0,15]*pi/180;
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results3{end+1} = R;


%%

Results2 = {};
S.Foot.PF_stiffness = 'Natali2010';
S.Foot.PF_sf = 1; 
S.Foot.PF_slack_length = 0.146;
S.Foot.mtj_stiffness = 'MG_exp5_table';
S.Foot.FDB = 2;
S.Foot.FDB_lMo = 23e-3;
S.Foot.FDB_lTs = 0.123;
S.Foot.FDB_shift = -0.1;
S.Foot.FDB_sf_FMo = 1;
Fs_tib = [10:2:20,30:10:100,120:20:500,550:50:1000];
Qs_mtp = [-30,30]*pi/180;
S.activity = 0.01;
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results2{end+1} = R;
S.activity = 0;
R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
Results2{end+1} = R;


%%

label_fontsize = 11;
legend_fontsize = 12;
title_fontsize = 12;

%

fig1 = figure('Position',[269 136 1200 500]);
set(fig1,'Color','w');

% Ker et al., 1987

% subplot(3,4,[2,6])
subplot(3,3,[1,4])
hold on
CsV = hsv(length(Results1));

% Ker RF, Alexander RM, Kester RC, Bibby SR, Bennett MB. The spring in the 
% arch of the human foot. Nat Lond. 1987;325(6100):147–9. 
if exist(fullfile(pathRepo,'Figures','Ker_et_al_1987.csv'),'file')
    Ker87_dat = importdata(fullfile(pathRepo,'Figures','Ker_et_al_1987.csv'));
    Ker87.a = [Ker87_dat.data(:,1:2); flip(Ker87_dat.data(:,3:4))];
    Ker87.c = [Ker87_dat.data(:,5:6); flip(Ker87_dat.data(:,7:8))];
    Ker87.d = [Ker87_dat.data(:,9:10); flip(Ker87_dat.data(:,11:12))];
    Ker87.e = Ker87_dat.data(:,13:14);
    Ker87.f = Ker87_dat.data(:,15:16);
    
    plot(Ker87.a(:,1)*sqrt(65/85)-1,Ker87.a(:,2)*65/85,'Color',CsV(1,:),'LineWidth',1)
    plot(Ker87.a(:,1)*sqrt(65/85)-1,Ker87.a(:,2)*65/85,'--','Color',CsV(2,:),'LineWidth',1)
    plot(Ker87.c(:,1)*sqrt(65/85)-1,Ker87.c(:,2)*65/85,'Color',CsV(4,:),'LineWidth',1)
    plot(Ker87.d(:,1)*sqrt(65/85)-1,Ker87.d(:,2)*65/85,'Color',CsV(5,:),'LineWidth',1)
    plot(Ker87.e(:,1)*sqrt(65/85)-1,Ker87.e(:,2)*65/85,'Color',CsV(6,:),'LineWidth',1)
    plot(Ker87.f(:,1)*sqrt(65/85)-1,Ker87.f(:,2)*65/85,'Color',CsV(7,:),'LineWidth',1)
end

for i=1:length(Results1)
    R = Results1{i};

    j = find(R.Qs_mtp(:)==0);

    js = find(R.failed(j,:)==0);
    Fs_tib = R.Fs_tib(js);
    l_fa = R.l_fa_ext(j,js);
    h_fa = R.h_fa_ext(j,js);

    plot((l_fa-R.L0)*1000,Fs_tib/1000,'o','color',CsV(i,:),'DisplayName',R.legname)

    hold on
    axis tight

end
xlabel('Horizontal elongation (mm)','Fontsize',label_fontsize);
ylabel('Vertical force (kN)','Fontsize',label_fontsize);
set(gca,'Fontsize',label_fontsize);
title({'Contribution of ligaments','\rm(Ker et al, 1987)'},'Fontsize',title_fontsize);

% xlim([-0.3,7])
ylim([0,3.3])


% Welte et al., 2018

colours = {[0.4660 0.6740 0.1880],[0.6350 0.0780 0.1840],[0 0.4470 0.7410]};
mrk = {'o','d','p','.','x','s','h','+','<','^'};

% subplot(3,4,[4,8])
subplot(3,3,[3,6])
hold on

% Welte L, Kelly LA, Lichtwark GA, Rainbow MJ. Influence of the windlass 
% mechanism on arch-spring mechanics during dynamic foot arch deformation. 
% J R Soc Interface. 2018;15(145):20180270.
if exist(fullfile(pathRepo,'Figures','Welte_et_al_2018.csv'),'file')
    Welte18_dat = importdata(fullfile(pathRepo,'Figures','Welte_et_al_2018.csv'));
    Welte18.pf = [Welte18_dat.data(:,1:2); flip(Welte18_dat.data(:,3:4))];
    Welte18.df = [Welte18_dat.data(:,5:6); flip(Welte18_dat.data(:,7:8))];
    
    plot(Welte18.pf(:,1),Welte18.pf(:,2),'Color',colours{1},'LineWidth',1,'DisplayName','Toe DF: -30° (Welte et al.)')
    plot(Welte18.df(:,1),Welte18.df(:,2),'Color',colours{2},'LineWidth',1,'DisplayName','Toe DF:  30° (Welte et al.)')
end

for j=1:length(Results2)
    R = Results2{j};

    BW = R.S.mass*9.81;
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

        h_ac = squeeze(R.h_nav(idx(i),idx_ac));
        tmp = h_ac(1) - h_ac;

        ac{i} = tmp;
        ac_max(i) = max(ac{i});
    end

    for i=1:n_i
        ac_rel = ac{i}/max(ac_max);

       if R.Qs_mtp(idx(i))<0
            tmp_lg = ['Toe DF: ' num2str(R.Qs_mtp(i)*180/pi) '°'];
        else
            tmp_lg = ['Toe DF:  ' num2str(R.Qs_mtp(i)*180/pi) '°'];
        end

        if R.S.activity==0
            tmp_lg = [tmp_lg ', no activation'];
        else
            tmp_lg = [tmp_lg ', baseline act'];
        end

        plot(ac_rel(:),F_ac{i}/BW,mrk{i+2*(j-1)},'Color',colours{i},'DisplayName',tmp_lg)
    
    end

    

end

xlabel('Arch compression (-)','Fontsize',label_fontsize);
ylabel('Vertical force (BW)','Fontsize',label_fontsize);
set(gca,'Fontsize',label_fontsize);
ttl=title({'Effect of toe dorsiflexion','\rm(Welte et al, 2018)'},'Fontsize',title_fontsize);
% title('Welte et al., 2018','Fontsize',title_fontsize);
xlim([0,1])
% ttl.VerticalAlignment = 'middle';

lh2 = legend('Location','northwest','Fontsize',legend_fontsize);
lh2.Position(2) = lh2.Position(2) - 0.63;
lh2.Position(1) = lh2.Position(1) - 0.02;
lh2.Box = 'off';

% Yawar et al., 2021

% subplot(3,4,[3,7])
subplot(3,3,[2,5])
hold on

% Yawar A, Eng MC, Tommasini S, Venkadesan M. Stiffness and work contributions 
% of the windlass in human feet. 2021 Jun;51.
if exist(fullfile(pathRepo,'Figures','Yawar_et_al_2021.csv'),'file')
    Yawar21_dat = importdata(fullfile(pathRepo,'Figures','Yawar_et_al_2021.csv'));
    Yawar21.pf = [Yawar21_dat.data(:,1:2); flip(Yawar21_dat.data(:,3:4))];
    Yawar21.df = [Yawar21_dat.data(:,5:6); flip(Yawar21_dat.data(:,7:8))];
    
    plot(Yawar21.pf(:,1),Yawar21.pf(:,2),'Color',colours{1},'LineWidth',1,'DisplayName','Toe DF:   0° (Yawar et al.)')
    plot(Yawar21.df(:,1),Yawar21.df(:,2),'Color',colours{2},'LineWidth',1,'DisplayName','Toe DF: 15° (Yawar et al.)')
end

for j=1:length(Results3)
    R = Results3{j};

    idx0 = find(R.Qs_mtp(:) == 0);
    js = find(R.failed(idx0,:)==0);
    [dH0,idH0] = max(R.talus_or(idx0,js,2));
    dH0 = dH0*1e3;
    Ft0 = R.Fs_tib(idH0);

    j1 = find(R.Qs_mtp(:)==0*pi/180);
    j2 = find(R.Qs_mtp(:)==15*pi/180);
    
    for i=[j1,j2]

        js = find(R.failed(i,:)==0);
        Fs_tib = R.Fs_tib(js);

        hold on
        dH = R.talus_or(i,js,2)*1e3;
        dH = dH0 - dH;
        ddH = dH(2:end) - dH(1:end-1);
        idxH = find(ddH>=0);
        if R.Qs_mtp(i)~=0
            tmp_lg = ['Toe DF: ' num2str(R.Qs_mtp(i)*180/pi) '°'];
        else
            tmp_lg = ['Toe DF:   ' num2str(R.Qs_mtp(i)*180/pi) '°'];
        end

        if R.S.activity==0
            tmp_lg = [tmp_lg ', no activation'];
        else
            tmp_lg = [tmp_lg ', baseline act'];
        end


        plot(dH(idxH),(Fs_tib(idxH)-Ft0)/BW,mrk{i},'Color',colours{i},'DisplayName',tmp_lg)
    
        dHs(:,i) = dH;
        dHs(:,i) = nan;
        dHs(idxH,i) = dH(idxH);


    end

end

offset = rms(dHs(1:end-1,1)-dHs(1:end-1,2))
rmse = rms(dHs(1:end-1,1)-(dHs(1:end-1,2)+offset))


xlabel('Vertical displacement ankle (mm)','Fontsize',label_fontsize);
ylabel('Vertical force (BW)','Fontsize',label_fontsize);
set(gca,'Fontsize',label_fontsize);
title({'Effect of toe dorsiflexion','\rm(Yawar et al, 2021)'},'Fontsize',title_fontsize);
% title('Yawar et al., 2021','Fontsize',title_fontsize);

xlim([-1.5,25])
ylim([0,3.7])

lh3 = legend('Location','northwest','Fontsize',legend_fontsize);
lh3.Position(2) = lh3.Position(2) - 0.63;
lh3.Position(1) = lh3.Position(1) - 0.02;
lh3.Box = 'off';

%
subplot(3,3,7)
hold on

ylim([0.5,7])
str = 'Plantar fascia (Nominal)';
text(0, 6, str, 'FontSize',12,'Horiz','left');
str = 'Plantar fascia (Compliant)';
text(0, 5, str,'FontSize',12,'Horiz','left');
str = 'Plantar intrinsic muscle';
text(0, 4, str,'FontSize',12,'Horiz','left');
str = 'Long plantar ligament';
text(0, 3, str,'FontSize',12,'Horiz','left');
str = 'Short plantar ligament';
text(0, 2, str,'FontSize',12,'Horiz','left');
str = 'Spring ligament';
text(0, 1, str,'FontSize',12,'Horiz','left');


c=6;

xlim([3.5,12+c])

for ii=1:7
    fill([ii-0.49,ii+0.49,ii+0.49,ii-0.49]+4+c,[0.5,0.5,6.5,6.5],CsV(ii,:))
end

plot(5+c,[1:4,6],'xk')
plot(6+c,[1:5],'xk')
plot(7+c,[1:4],'xk')
plot(8+c,[1:3],'xk')
plot(9+c,[1:2],'xk')
plot(10+c,[1],'xk')

tmp = gca;
tmp.XAxis.Color = 'w';
tmp.YAxis.Visible = 'off';

title(' ')
%

str = '(a)';
annotation(gcf,'textbox',[0.08,0.95,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(b)';
annotation(gcf,'textbox',[0.36,0.95,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);

str = '(c)';
annotation(gcf,'textbox',[0.64,0.95,0.05,0.05],'String',str,'EdgeColor','none','FontSize',14);



%%

% exportgraphics(fig1,fullfile(FigRepo,'figure_static.jpeg'),'Resolution',300);






