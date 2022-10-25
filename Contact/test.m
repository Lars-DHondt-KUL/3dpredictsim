clear
% close all
clc

import casadi.*

pos = SX.sym('pos',1);

stiffnessSX         = 5e6;
radiusSX            = 0.02;
dissipationSX       = 2;
normalSX            = [0,1,0];
transitionVelocitySX= 0.2;
staticFrictionSX    = 0.8;
dynamicFrictionSX   = 0.8;
viscousFrictionSX   = 0.5;
spherePosSX         = [0,0,0]';
orFramePosSX        = -[0,pos,0]';
v_linSX             = [0,0,0]';
omegaSX             = [0,0,0]';
RotSX               = reshape(eye(3),9,1);
TrSX                = orFramePosSX;

% Hunt-Crossley contact model
forceSX = HCContactModel(stiffnessSX,radiusSX,dissipationSX,...
    normalSX,transitionVelocitySX,staticFrictionSX,...
    dynamicFrictionSX,viscousFrictionSX,spherePosSX,orFramePosSX,...
    v_linSX,omegaSX,RotSX,TrSX);


f_HC = Function('f_HC',{pos},{forceSX});


ys = linspace(-1.2,-0.5,50)*radiusSX;
for i=1:50
    Fi = f_HC(ys(i));
    F(i,:) = full(Fi);
end


figure(1)
hold on
plot((ys+radiusSX)*1e3,F(:,2),'DisplayName',['r = ' num2str(radiusSX)])

