

lTtilde = linspace(1,1.05,100);
FMo = 1;

%
k_t = 14.8;

FMo1 = 215.4*402/14.8;
F_t = FMo1*(lTtilde-1)*k_t;


%
FMo = (1558 + 683 + 3549);
lTs = 0.3711*1e3;
FMo = FMo*1.2;
k_T = 35*0.7;
shift = getShift(k_T);
c1 = 0.2;
c2 = 0.995;
c3 = 0.25 - shift;

f_t = FMo*(c1*exp(k_T*(lTtilde-c2)) - c3);

dfdl = k_T/lTs*FMo*c1*exp(k_T*(lTtilde-c2));
%

figure
subplot(211)
plot(lTtilde,F_t)
hold on
plot(lTtilde,f_t)

subplot(212)
plot(lTtilde([1,end]),[1,1]*215.4)
hold on
plot(lTtilde,dfdl)
