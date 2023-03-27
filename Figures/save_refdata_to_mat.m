
clear
close all
clc

% Ker87_dat = importdata('Ker_et_al_1987.csv');
% 
% Ker87.a = [Ker87_dat.data(:,1:2); flip(Ker87_dat.data(:,3:4))];
% Ker87.c = [Ker87_dat.data(:,5:6); flip(Ker87_dat.data(:,7:8))];
% Ker87.d = [Ker87_dat.data(:,9:10); flip(Ker87_dat.data(:,11:12))];
% Ker87.e = Ker87_dat.data(:,13:14);
% Ker87.f = Ker87_dat.data(:,15:16);
% 
% 
% figure
% plot(Ker87.a(:,1),Ker87.a(:,2))
% hold on
% plot(Ker87.c(:,1),Ker87.c(:,2))
% plot(Ker87.d(:,1),Ker87.d(:,2))
% plot(Ker87.e(:,1),Ker87.e(:,2))
% plot(Ker87.f(:,1),Ker87.f(:,2))

%%
% Ker89_dat = importdata('Ker_et_al_1989.csv');
% 
% Ker89 = [Ker89_dat.data(:,1:2); flip(Ker89_dat.data(:,3:4))];
% 
% figure
% plot(Ker89(:,1),Ker89(:,2))
% hold on
% 
% Bennett90_dat = importdata('Bennett_et_al_1990.csv');
% 
% Bennett90 = [Bennett90_dat.data(:,1:2); flip(Bennett90_dat.data(:,3:4))];
% Bennett90(:,2) = Bennett90(:,2)*1e-3;
% Bennett90(:,1) = Bennett90(:,1) + 0.5;
% Bennett90 = Bennett90(Bennett90(:,1)>=0,:);
% 
% plot(Bennett90(:,1),Bennett90(:,2))


%%

% TKH17_dat = importdata('Takahashi_et_al_2017.csv');
% 
% TKH17.shank = TKH17_dat.data(:,1:2);
% TKH17.hindfoot = TKH17_dat.data(:,3:4);
% TKH17.forefoot = TKH17_dat.data(:,5:6);
% TKH17.hallux = TKH17_dat.data(:,7:8);
% % TKH17.shank(1,1)=0;
% 
% figure
% plot(TKH17.shank(:,1),TKH17.shank(:,2))
% hold on
% plot(TKH17.hindfoot(:,1),TKH17.hindfoot(:,2))
% plot(TKH17.forefoot(:,1),TKH17.forefoot(:,2))
% plot(TKH17.hallux(:,1),TKH17.hallux(:,2))



%%

x_ch = linspace(1,100,100);

chimp_ankle_dat = importdata('chimp_ankle.csv');
chimp_ankle = interp1(chimp_ankle_dat.data(:,1),chimp_ankle_dat.data(:,2),x_ch,"spline","extrap");

chimp_knee_dat = importdata('chimp_knee.csv');
chimp_knee = interp1(chimp_knee_dat.data(:,1),chimp_knee_dat.data(:,2),x_ch,"spline","extrap");

chimp_GRFx_dat = importdata('chimp_GRFx.csv');
chimp_GRFx = interp1(chimp_GRFx_dat.data(:,1),chimp_GRFx_dat.data(:,2),x_ch,"spline","extrap");

chimp_GRFy_dat = importdata('chimp_GRFy.csv');
chimp_GRFy = interp1(chimp_GRFy_dat.data(:,1),chimp_GRFy_dat.data(:,2),x_ch,"spline","extrap");

