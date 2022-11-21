clear
% close all
clc

import casadi.*

pos = SX.sym('pos',1);
vel = SX.sym('vel',1);

radius = 0.032;
radius = 0.05;

<<<<<<< Updated upstream
stiffness = 10e6;
=======
stiffness = 10e6; %*sqrt(0.03/radius);
>>>>>>> Stashed changes
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

pos = SX.sym('pos',1);
vel = SX.sym('vel',1);

radius = 0.032;

stiffness2 = 16e6;
dissipation2 = 0.565;
normal  = [0;1;0];

[force] = Brown_McPhee_contactSphere(stiffness2,radius,dissipation2,...
    normal,[0;pos;0],[0;vel;0]);

f_BM = Function('f_BM',{pos,vel},{force(2)});

%%

pos = SX.sym('pos',1);
vel = SX.sym('vel',1);

radius_E = [35.4, 54.0, 22.6]'*1e-3;
sphereRot_inG = [0.329,0.201,0.101];


stiffness = 8e7;
dissipation = 0.565;
normalvec  = [0;0;1];

spherePos_inG = [0;0;pos];
sphereLinVel_inG = [0;0;vel];

[force,dist,disp,vol] = Brown_McPhee_contactEllipsoid(stiffness,dissipation,...
    normalvec,radius_E,sphereRot_inG,spherePos_inG,sphereLinVel_inG);

f_BM_E = Function('f_BM_E',{pos,vel},{force(3),dist,disp,vol});


%%
f = 0.22; % Hz
f = 2.2;
% f =20;
ampl = 4e-3; % m

t = SX.sym('t',1);
rds = SX.sym('radius',1);

compr = -( cos(t*f*(2*pi)) - 1 )*ampl/2;
y = rds - compr;
ydot = jacobian(y,t);

f_get_y_ydot = Function('f_get_y_ydot',{t,rds},{y,ydot,compr});


%%
N = 500;
time = linspace(0,1/f,N);

[pos,vel,cmpr] = f_get_y_ydot(time,radius);

load = f_HC(pos,vel);

load2 = f_BM(pos,vel);

[pos3,vel3,cmpr3] = f_get_y_ydot(time,28e-3);
[load3,dist3,disp3,vol3] = f_BM_E(pos3,vel3);


pos = full(pos);
pos3 = full(pos3);
vel = full(vel);
vel3 = full(vel3);
cmpr = full(cmpr);
cmpr3 = full(cmpr3);
load = full(load);
load2 = full(load2);
load3 = full(load3);
dist3 = full(dist3);
disp3 = full(disp3);
vol3 = full(vol3);

W_loading = trapz(cmpr(1:N/2),load(1:N/2));
W_unloading = trapz(cmpr(N/2+1:end),load(N/2+1:end));
W_total = trapz(cmpr,load);
diss = W_total/W_loading*100;
diss2 = (1-abs(W_unloading)/abs(W_loading))*100;
disp([num2str(diss,'%.0f') ' % dissipation'])

W_loading3 = trapz(cmpr3(1:N/2),load3(1:N/2));
W_total3 = trapz(cmpr3,load3);
W_diss3 = W_total3/W_loading3*100

figure(2)
tiledlayout("flow")
nexttile
plot(time,cmpr3)
nexttile
plot(time,pos3)
nexttile
plot(time,vel3)
nexttile
plot(time(1:N/2),load3(1:N/2))
hold on
plot(time(N/2+1:end),load3(N/2+1:end))
nexttile
plot(time,dist3)
nexttile
plot(time,disp3)
nexttile
plot(time,vol3)

<<<<<<< Updated upstream

figure(1)
hold on
plot(cmpr*1e3,load*1e-3);
plot(cmpr*1e3,load2*1e-3);
plot(cmpr3*1e3,load3*1e-3);
=======
legname = ['Stiffness = ' num2str(stiffness*1e-6) 'E6',...
    ';  Radius = ' num2str(radius*1e3) ' mm',...
%     ';  Loaded at ' num2str(f) ' Hz'
    ];

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
plot(cmpr*1e3,load*1e-3,':','DisplayName',legname);
>>>>>>> Stashed changes
xlabel('Compression (mm)')
ylabel('load (kN)')
legend('Location','northwest')
title('Force-displacement of heel pad, sine wave displacement.')


