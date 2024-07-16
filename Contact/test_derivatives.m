
clearvars -except stiffness f_HC radius
% close all
clc


import casadi.*


deformation_SX = SX.sym('d');

pos_SX = radius - deformation_SX;

F_SX = f_HC(pos_SX,0,stiffness);

[h,g] = hessian(F_SX,deformation_SX);

fun = Function('fun',{deformation_SX},{F_SX,g,h});


x = linspace(-2,10,500)*1e-3;

[y,dy,ddy] = fun(x);

y = full(y);
dy = full(dy);
ddy = full(ddy);

figure
tiledlayout(3,1)
nexttile
hold on
plot(x,y)
ylabel('F [N]','FontSize',14)

nexttile
hold on
plot(x,dy)
ylabel('\nablaF','FontSize',14)

nexttile
hold on
plot(x,ddy)
ylabel('\nabla^2F','FontSize',14)
xlabel('\Delta [mm]','FontSize',14)

%%
import casadi.*

% [f_simpleContactForce] = createSXFunctionSimpleContactForce(stiffness=10);

% [f_simpleContactForce] = createSXFunctionSimpleContactForce(stiffness=10,...
%         v_saturation=1, saturated_v_gain=0.1, dissipation=0.4,...
%         max_force=0.5, K_highForce=50, max_frac=0,...
%         mu_viscousFriction=0.5);

[f_simpleContactForce] = createSXFunctionSimpleContactForce(stiffness=10,...
        v_saturation=1, saturated_v_gain=0.1, dissipation=0.4,...
        max_force=0.6, K_highForce=10, max_frac=0.3, max_force_smooth=2,...
        mu_viscousFriction=0.5);

deformation_SX = SX.sym('d');

F_SX = f_simpleContactForce(deformation_SX/0.017, 0, [0;0]) *800*0.3;

[h,g] = hessian(F_SX(2),deformation_SX);

fun2 = Function('fun',{deformation_SX},{F_SX(2),g,h});


[y2,dy2,ddy2] = fun2(x);

y2 = full(y2);
dy2 = full(dy2);
ddy2 = full(ddy2);

nexttile(1)
plot(x,y2)

nexttile(2)
plot(x,dy2)

nexttile(3)
plot(x,ddy2)









