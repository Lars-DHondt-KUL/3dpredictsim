
clear

addpath('C:\Users\u0150099\Documents\master_thesis\3dpredictsim\VariousFunctions')

lTtilde = linspace(1,1.15,200);



kT = 35;
shift = getShift(kT);

fse35 = (exp(kT.*(lTtilde - 0.995)))/5 - 0.25 + shift;

lTF35 = interp1(fse35,lTtilde,1)-1
