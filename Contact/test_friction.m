
clear
close all
clc


N = 1e3;
vx = linspace(-0.2,5,N);




transitionVelocity = 0.2;
staticFriction = 0.8;
dynamicFriction = 0.8;
viscousFriction = 0.5;

fn = 1;
eps1 = 1e-8;

normal = [0,1,0];

for i=1:N

    v = [vx(i); 0; 0]';

    
    vnormal = v(1)*normal(1) + v(2)*normal(2) + v(3)*normal(3);
    vtangent = v - vnormal*normal;
    
    % Friction force
    aux = (vtangent(1)).^2 + (vtangent(2)).^2 + (vtangent(3)).^2 + eps1; 
    vslip = aux.^(0.5);
    vrel = vslip/transitionVelocity;
    ffriction = fn*(min(vrel,1)*(dynamicFriction + 2 * (staticFriction - ...
        dynamicFriction) / (1 + vrel*vrel)) + viscousFriction*vslip);
    % Contact force
    force = ffriction*(-vtangent) / vslip;

    mu(i) = -force(1)/fn;
end

figure(1)
hold on
plot(vx./transitionVelocity,mu)
grid on
xlabel('v / v_t')
ylabel('µ')


