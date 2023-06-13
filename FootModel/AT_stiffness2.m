clear

addpath('C:\Users\u0150099\Documents\master_thesis\3dpredictsim\VariousFunctions')


kT = 35;
shift = getShift(kT);

lTtilde = linspace(1,1.15,200);

fse35 = (exp(kT.*(lTtilde - 0.995)))/5 - 0.25 + shift;
dfdl35 = kT*(exp(kT.*(lTtilde - 0.995)))/5;

kT = 17.5;
shift = getShift(kT);

fse17 = (exp(kT.*(lTtilde - 0.995)))/5 - 0.25 + shift;
dfdl17 = kT*(exp(kT.*(lTtilde - 0.995)))/5;


fse_lin = (lTtilde-1)*14.8;

kT = 26;
shift = getShift(kT);

fse26 = (exp(kT.*(lTtilde - 0.995)))/5 - 0.25 + shift;
dfdl26 = kT*(exp(kT.*(lTtilde - 0.995)))/5;


figure
plot(lTtilde,fse35,'DisplayName','kT = 35 (exp)')
hold on
plot(lTtilde,fse17,'DisplayName','kT = 17.5 (exp)')
plot(lTtilde,fse_lin,'--','DisplayName','kT = 14.8 (lin)')
plot(lTtilde,fse26,'--','DisplayName','kT = 26 (exp)')
ylim([-0.1,1.2])
yline(1,'k-')
xlabel('l^~_T')
ylabel('f_T')
legend('Location','best')

% figure
% plot(lTtilde,dfdl35,'DisplayName','kT = 35 (exp)')
% hold on
% plot(lTtilde,dfdl17,'DisplayName','kT = 17.5 (exp)')
% ylim([0,50])
% xlabel('l^~_T')
% ylabel('df/dl')
% legend('Location','best')


% lTF35 = interp1(fse35,lTtilde,1)-1
% lTF17 = interp1(fse17,lTtilde,1)-1
% lTF35/lTF17


