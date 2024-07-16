clear
close all
clc
import casadi.*



% data1 = readtable('C:\Users\u0150099\Documents\master_thesis\3dpredictsim\Figures/Bennett_et_al_1990.csv');
% 
% data1_x = [data1.Series1; flip(data1.Series2)]+0.5;
% data1_y = [data1.Var2; flip(data1.Var4)];


fh1=figure;
hold on
% plot(data1_x, data1_y,'DisplayName','data Bennet et al, 1990 (2.2 Hz)')

xlabel('Strain [-]')
ylabel('Force [-]')
% legend('Location','best')



[f_simpleContactForce] = createSXFunctionSimpleContactForce("max_force",20,...
    "max_frac",0.1,"K_highForce",20);



strain = linspace(-5,40,200)*1e-2;


Fn = full( f_simpleContactForce(strain, 0, [0;0]) );


plot(strain, Fn(2,:), 'LineWidth',2)

