
clear
% close all
clc

addpath('C:\Users\u0150099\OneDrive - KU Leuven\PhD\Stochastic Optimal Control\Exploration\contact')
addpath('C:\GBW_MyPrograms\HelperFunctionsToolkit\OptimisationToolkit\misc')



radius = 0.032;
stiffness = 10e6;
dissipation = 2;
thickness = 17*1e-3; % 17, 12
Mg = 0.3*62*9.81; % 0.3, 0.2

% radius = 0.05;
% stiffness = 3.72e6;
% dissipation = 0.01;
% thickness = 17*1e-3; % 17, 12
% Mg = 0.3*62*9.81; % 0.3, 0.2

% radius = 0.03;
% stiffness = 1.06e7;
% dissipation = 2.40;
% thickness = 12*1e-3; % 17, 12
% Mg = 0.2*62*9.81; % 0.3, 0.2

transitionVelocity = 0.2;
staticFriction = 0.8;
dynamicFriction = 0.8;
viscousFriction = 0.5;



import casadi.*

pos = SX.sym('pos',1);
vel = SX.sym('vel',1);

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


% [f_simpleContactForce] = createSXFunctionSimpleContactForce(stiffness=15,...
%     v_saturation=0.5, saturated_v_gain=0.1, dissipation=0.4,...
%     max_force=0.5, K_highForce=50, max_frac=0,...
%     mu_viscousFriction=0.5);


[f_simpleContactForce] = createSXFunctionSimpleContactForce(stiffness=15,...
        v_saturation=0.1, saturated_v_gain=0.05, dissipation=0.5,...
        max_force=0.5, K_highForce=1, max_frac=0.1,...
        mu_viscousFriction=0.5);



%%

for f = [0.22, 2.2, 10] % Hz


    ampl = 4e-3; % m
    
    t = SX.sym('t',1);
    rds = SX.sym('radius',1);
    
    compr = -( cos(t*f*(2*pi)) - 1 )*ampl/2;
    y = rds - compr;
    ydot = jacobian(y,t);
    
    f_get_y_ydot = Function('f_get_y_ydot',{t,rds},{y,ydot,compr});
    
    
    %%
    N = 100;
    time = linspace(0,1/f,N);
    
    [pos,vel,cmpr] = f_get_y_ydot(time,radius);
    
    load = f_HC(pos,vel);
    
    pos = full(pos);
    vel = full(vel);
    cmpr = full(cmpr);
    load = full(load);
    
    
    
    
    figure(1)
    hold on
    plot(cmpr*1e3,load*1e-3,'-','linewidth',2,'DisplayName',sprintf("HC: f = %.2f Hz",f));


    strain = cmpr/thickness;
    strain_rate = -vel/thickness;

    [Fn] = f_simpleContactForce(strain, strain_rate, [0;0])*Mg;

    Fn = full(Fn(2,:));

    plot(cmpr*1e3,Fn*1e-3,'-.','linewidth',2,'DisplayName',sprintf("new: f = %.2f Hz",f));

end




xlabel('Compression (mm)')
ylabel('load (kN)')
legend('Location','northwest')
title('Force-displacement of contact sphere, sine wave displacement.')


%%










