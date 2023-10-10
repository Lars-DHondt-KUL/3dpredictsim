
q_mt = linspace(0,20,200);

a = 0.1126; % length from calcn origin to mtj (m)
b = 0.1047; % length from mtj to mtpj (m)

figure
tiledlayout('flow')


%%
phi0 = 140*pi/180; % angle between a and b (rad)

L0 = sqrt(a^2 + b^2 - 2*a*b*cos(phi0));

H0 = a*b./L0*sin(phi0);


phi = phi0 + q_mt*pi/180;
l = sqrt(a^2 + b^2 - 2*a*b*cos(phi));
h = a*b./l.*sin(phi);




nexttile(1)
hold on
plot(q_mt,(l-L0)*1e3)
ylabel('\Deltal')
xlabel('\phi')

nexttile(2)
hold on
plot(q_mt,-(h-H0)*1e3)
ylabel('\Deltah')
xlabel('\phi')

k = 1e6;

M = (l-L0)*k.*h;

nexttile(3)
hold on
plot(q_mt,M)
ylabel('M')
xlabel('\phi')

theta = asin(h/a);
d = a/2*cos(theta);
F = M./d;

nexttile(4)
hold on
plot(q_mt,F)
ylabel('F')
xlabel('\phi')

nexttile(5)
hold on
plot((l-L0)*1e3,F)
ylabel('F')
xlabel('\Deltal')

nexttile(6)
hold on
plot(-(h-H0)*1e3,F)
ylabel('F')
xlabel('\Deltah')
