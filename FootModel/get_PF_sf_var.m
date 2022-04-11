function [sfa] = get_PF_sf_var(N,idx)

if idx==1
    sf = [2, 5,12,15,17, 18, 2, 1, 1, 1,1,2];
    gc = [1,10,30,40,45,50,60,65,70,80,90,100];
    
elseif idx==2
    sf = [2, 4,14,15,16,17, 18,18, 15, 3,1, 1,1,1,2];
    gc = [1,10,30,35,40,45,50,55,60,70,75,77,80,90,100];

end

x = 1:2*N;

sfa = interp1(gc,sf,x,'spline');

figure 
plot(x,sfa)
hold on
plot(gc,sf,'o')
xlabel('gait cycle (%)')
ylabel('scale factor (-)')
title('Plantar fascia stiffness scale factor')

