
clear
clc

%%
S.subject = 'Fal_s1';
S.Foot.Model = 'mtjc4';
S.Foot.Scaling = 'custom';
% S.Foot.Scaling = 'default';
S.MTparams = 'MTc5';
S.Foot.contactStiffnessFactor = 10;
S.Foot.contactSphereOffsetY = 3;
S.passiveFiberForceShift = -0.1;
S.AchillesTendonScaleFactor = 0.5;
S.TricepsFMoScale = 1.2;
S.Foot.mtp_muscles = 1;
S.Foot.mtj_muscles = 1;

S.Foot.PF_stiffness = 'Gefen2002';
S.Foot.PF_sf = 1;
S.Foot.PF_slack_length = 0.146;

S.Foot.MT_li_nonl = 1;
% S.Foot.mtj_stiffness = 'MG_exp';
% S.Foot.mtj_stiffness = 'MG_poly';
% S.Foot.mtj_stiffness = 'Gefen2002';
S.Foot.mtj_stiffness = 'MG_exp5_table';
S.Foot.mtj_sf = 1; 

% S.Foot.FDB = 0;
S.Foot.FDB = 2;
S.Foot.FDB_lTs = 0.125;
S.Foot.FDB_shift = -0.1;
S.Foot.FDB_sf_FMo = 1;

S.activity = 0.0;
subtR = 1; % reduce subtalar mobility

%%
Qs_mtp = [0]*pi/180;
Fs_tib = [0];

% mtp angles to be considered
% Qs_mtp = [-45:15:45]*pi/180;
% Qs_mtp = [-30:30:30]*pi/180;
% Qs_mtp = [-30:30:30]*pi/180;
% Qs_mtp = [0:5:30]*pi/180;
% Qs_mtp = [-30:10:30]*pi/180;
Qs_mtp = [0,15]*pi/180;

% vertical forces on knee
% Fs_tib = [0:100:1000];
% Fs_tib = [0,100,320,640,960];
% Fs_tib = [0:0.1:1.5]*10*round(BW/10);
% Fs_tib = [0:50:300,400:100:1000,1200:200:3000];
% Fs_tib = [0:50:1000,1100:100:6000];

% Fs_tib = [0:50:500];
% Fs_tib = [50:50:300,400,500:250:2000];
Fs_tib = [0:100:2000];

%%
Results = {};

% S.Foot.Scaling = 'default';
% S.Foot.PF_stiffness = 'none';
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;
% 
% S.Foot.PF_stiffness = 'Gefen2002';
% S.Foot.PF_sf = 2; 
% S.Foot.PF_slack_length = 0.140;
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;

%%

% S.Foot.PF_stiffness = 'Natali2010';
% S.Foot.PF_sf = 1; 
% S.Foot.PF_slack_length = 0.146;
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% Fs_tib = [0:50:300,400:100:900,1000:250:3000];
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;
% 
% S.Foot.PF_stiffness = 'Gefen2002';
% S.Foot.PF_sf = 1; 
% S.Foot.PF_slack_length = 0.146;
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% Fs_tib = [0:50:300,400:100:900,1000:250:3000];
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;
% 
% S.Foot.PF_stiffness = 'none';
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% Fs_tib = [0:50:300,400:100:900,1000:250:2500];
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;
% 
% S.Foot.FDB = 0;
% S.Foot.PF_stiffness = 'none';
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% Fs_tib = [0:50:300,400:100:900,1000:250:2500];
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;
% 
% S.Foot.PF_stiffness = 'none';
% S.Foot.mtj_stiffness = 'MG_exp5_d_table';
% Fs_tib = [0:50:300,400:100:900,1000:250:1500];
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;
% 
% S.Foot.PF_stiffness = 'none';
% S.Foot.mtj_stiffness = 'MG_exp5_e_table';
% Fs_tib = [0:50:500];
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;
% 
% S.Foot.PF_stiffness = 'none';
% S.Foot.mtj_stiffness = 'MG_exp5_f_table';
% Fs_tib = [0:50:400];
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;


% S.Foot.PF_stiffness = 'Gefen2002';
% S.Foot.PF_sf = 1; 
% S.Foot.PF_slack_length = 0.146;
% S.Foot.mtj_stiffness = 'MG_exp_table';
% Fs_tib = [0:100:1000];
% Qs_mtp = [-30:10:30]*pi/180;
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;

% S.Foot.PF_stiffness = 'Gefen2002';
% S.Foot.PF_sf = 1; 
% S.Foot.PF_slack_length = 0.146;
% S.Foot.mtj_stiffness = 'MG_exp_table';
% Fs_tib = [0:100:1000];
% Qs_mtp = [-30:10:30]*pi/180;
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;

% S.Foot.PF_stiffness = 'Natali2010';
% S.Foot.PF_sf = 1; 
% S.Foot.PF_slack_length = 0.146;
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% % Fs_tib = [0:50:1000];
% % Qs_mtp = [-30:30:30]*pi/180;
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;
% 
% S.Foot.PF_stiffness = 'Gefen2002';
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;

% S.Foot.PF_stiffness = 'none';
% S.Foot.FDB = 0;
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;

% S.Foot.PF_stiffness = 'Natali2010';
% S.Foot.PF_sf = 1; 
% S.Foot.PF_slack_length = 0.146;
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% Fs_tib = [0:50:300,400:100:1000,1200:200:2000];
% Qs_mtp = [0,15,30]*pi/180;
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;
% 
% % S.Foot.PF_stiffness = 'none';
% S.Foot.PF_stiffness = 'Gefen2002';
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;


% S.Foot.PF_stiffness = 'Natali2010';
% S.Foot.PF_sf = 1; 
% S.Foot.PF_slack_length = 0.146;
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% Fs_tib = [50];
% Qs_mtp = [0]*pi/180;
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;

%%
% S.Foot.PF_stiffness = 'Gefen2002';
% S.Foot.PF_sf = 1; 
% S.Foot.PF_slack_length = 0.146;
% S.Foot.mtj_stiffness = 'MG_exp_table';
% Qs_mtp = 0;
% R = f_staticFootHanging(S,Qs_mtp,subtR);
% Results{end+1} = R;

% S.Foot.FDB = 0;
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;

% S.Foot.FDB = 1;
% R = f_staticFootCompression_v6(S,Qs_mtp,Fs_tib,subtR);
% Results{end+1} = R;

% Qs_mtp = [0]*pi/180;
% S.Foot.kMT_li = 0;
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% R = f_staticFootHanging(S,Qs_mtp,subtR);
% Results{end+1} = R;
% 
% Qs_mtp = [0]*pi/180;
% S.Foot.kMT_li = 0;
% S.Foot.mtj_stiffness = 'MG_exp5_table';
% R = f_staticFootHanging(S,Qs_mtp,subtR);
% Results{end+1} = R;

%%
% call plot function
nrf = length(Results);
CsV = hsv(nrf);
fig_nr = -1;
for i=1:nrf
    R = Results{i};
    if i==1
        h = PlotResults_FootSim(R,CsV(i,:),0,fig_nr);
    else
        PlotResults_FootSim(R,CsV(i,:),h,fig_nr);
    end
end


%%

% figNamePrefix = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\meetings\Model_Personalization_Meeting\mtj';
% set(h,'PaperPositionMode','auto')
% print(h,[figNamePrefix '_static_foot_loading'],'-dpng','-r0')
% print(h,[figNamePrefix '_static_foot_loading'],'-depsc')











