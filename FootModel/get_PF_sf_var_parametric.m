clear
% close all
clc

figure
hold on
grid on

xlim([-5,100.5])
ylim([-1,20])

x = 1:100;



%%
% parameters
t_rise = 60;
t_fall = 30;
t_duration = 75;
y_max = 18;

% create function
y_slope =@(a1,tr,t0,t) (a1-1)*(tanh((t-tr/2-t0)*pi*2/tr) + 1)/2;

y1 =@(t) y_slope(y_max,t_rise,1,t);
y2 =@(t) y_slope(y_max,t_fall,t_duration-t_fall+1,t);

y =@(t) y1(t) - y2(t) + 1;

% plot function
plot(x,y(x))

% plot parameters
plot([1,t_rise],[0.5,0.5],'.-')
plot([t_duration-t_fall,t_duration],[0.2,0.2],'.-')
plot([1,t_duration],[-0.1,-0.1],'.-')
plot([-1,-1],[0,y_max],'.-')
