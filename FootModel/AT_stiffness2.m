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
fse_lin2 = (lTtilde-1)*26;

figure
plot(lTtilde,fse35,'DisplayName','kT = 35 (exp)')
hold on
plot(lTtilde,fse17,'DisplayName','kT = 17.5 (exp)')
plot(lTtilde,fse_lin,'--','DisplayName','kT = 14.8 (lin)')
plot(lTtilde,fse_lin2,'--','DisplayName','kT = 26 (lin)')
ylim([-0.1,1.2])
yline(1,'k-')
xlabel('l^~_T')
ylabel('f_T')
legend('Location','best')

figure
plot(lTtilde,dfdl35,'DisplayName','kT = 35 (exp)')
hold on
plot(lTtilde,dfdl17,'DisplayName','kT = 17.5 (exp)')
ylim([0,50])
xlabel('l^~_T')
ylabel('df/dl')
legend('Location','best')



