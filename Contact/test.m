clear
% close all
clc

import casadi.*

pos = SX.sym('pos',1);
vel = SX.sym('vel',1);

radius = 0.032;

stiffness = 60e6;
dissipation = 2;
transitionVelocity = 0.2;
staticFriction = 0.8;
dynamicFriction = 0.8;
viscousFriction = 0.5;

normal              = [0,1,0];
spherePosSX         = SX(3,1);
orFramePosSX        = [0,pos,0]';
v_linSX             = [0,vel,0]';
omegaSX             = SX(3,1);
RotSX               = reshape(SX.eye(3),9,1);
TrSX                = orFramePosSX;

% Hunt-Crossley contact model
forceSX = HCContactModel(stiffness,radius,dissipation,...
    normal,transitionVelocity,staticFriction,...
    dynamicFriction,viscousFriction,spherePosSX,orFramePosSX,...
    v_linSX,omegaSX,RotSX,TrSX);


f_HC = Function('f_HC',{pos,vel},{forceSX(2)});




%%
f = 0.22; % Hz
f = 5;
f = 2.2;
ampl = 4e-3; % m

t = SX.sym('t',1);
compr = -( cos(t*f*(2*pi)) - 1 )*ampl/2;
y = radius - compr;
ydot = jacobian(y,t);

f_get_y_ydot = Function('f_get_y_ydot',{t},{y,ydot,compr});


%%
N = 500;
time = linspace(0,1/f,N);

[pos,vel,cmpr] = f_get_y_ydot(time);

load = f_HC(pos,vel);

pos = full(pos);
vel = full(vel);
cmpr = full(cmpr);
load = full(load);

W_loading = trapz(cmpr(1:N/2),load(1:N/2));
W_unloading = trapz(cmpr(N/2+1:end),load(N/2+1:end));
W_total = trapz(cmpr,load);
W_diss = W_total/W_loading*100


% figure
% tiledlayout("flow")
% nexttile
% plot(time,cmpr)
% nexttile
% plot(time,pos)
% nexttile
% plot(time,vel)
% nexttile
% plot(time,load)

figure(1)
hold on
plot(cmpr*1e3,load*1e-3);
xlabel('Compression (mm)')
ylabel('load (kN)')

