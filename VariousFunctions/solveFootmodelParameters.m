% Find the parameters for a new foot model (right foot), such that it is equivalent to
% the old footmodel, and to a more detailed footmodel.
% Every joint is taken at its default angle of 0�. This means that the 0�
% angle of the newly introduced tarsometatarsal joint corresponds to its
% rigid position in the old model.

% note: These functions are not needed to run any simulation, their only
% purpose is to calculate parameters needed for the source code of the
% external functions.

clear
% close all
clc

%% parameters from old model
m_cmf_0 = 0.9688202167589921;
I_cmf_0 = [0.000906321, 0.00252475, 0.00265422]';
com_cmf_0 = [0.0913924, 0.0274177, 0]';
mtp_0 = [0.163409678774199 -0.00182784875586352 0.000987038328166303]';   % in calcn ref
% derived params
mtp_02com_0 = com_cmf_0 - mtp_0;

%% parameters detailed model
com_calcn = [-0.0183999 -0.0127205 0.00168919]';
com_midfoot = [0.0136264 -0.00541573 -0.00226789]';
com_forefoot = [0.030362 -0.00692578 -0.000413788]';
chopart = [0.0221509217480428 0.00563051896570316 -0.000938103987425259]';   % in calcn ref
tarsometatarsal = [0.0224650598180872 -0.0131925031448367 0.00457222612063733]';   % in midfoot ref
mtp = [0.0604862357021971 -0.0140878323268576 0.00286827055184947]';     % in forefoot ref
m_calcn = 0.289923030444027;
m_midfoot = 0.139888239487345;
m_forefoot = 0.236187108315951;
% derived params
tarsometatarsal2com_calcn = -(chopart + tarsometatarsal - com_calcn);
tarsometatarsal2com_midfoot = -(tarsometatarsal - com_midfoot);
tarsometatarsal2com_cm = (tarsometatarsal2com_calcn * m_calcn + tarsometatarsal2com_midfoot * m_midfoot)/(m_calcn + m_midfoot);
mtp2com_cm = tarsometatarsal2com_cm - mtp;
mtp2com_forefoot = com_forefoot - mtp;
mtp2com_cmf = (mtp2com_cm * (m_calcn + m_midfoot) + mtp2com_forefoot * m_forefoot)/(m_calcn + m_midfoot + m_forefoot);

% Scale factor to account for the fact that the detailed model is based on
% a different person.
sf = mtp_02com_0./mtp2com_cmf; % distance from mtpj to com of calcn + midfoot + forefoot, since this vector can be specified in all 3 models.


%% approximate moments of inertia
% Not enough relations to describe inertias => approximate some values
% Open the forefoot of the detailed
% footmodel in Fusion 360. Convert mesh to solid, specify a mass density that satisfies the total mass, and calculate its
% moments of inertia at center of mass. Cross-elements are neglected.

Ifx = 1.834e-4;     %kg m^2
Ify = 6.182e-4;
Ifz = 5.296e-4;
If = [Ifx; Ify; Ifz];



% initial guess (c = calcaneus, f = forefoot)
mc = m_cmf_0*0.7;
mf = m_cmf_0*0.3;
Icx = I_cmf_0(1)*0.7;
Icy = I_cmf_0(2)*0.7;
Icz = I_cmf_0(3)*0.7;
COMcx = com_cmf_0(1)*0.5;
COMcy = com_cmf_0(2)*0.9;
COMcz = com_cmf_0(3);
COMfx = com_cmf_0(1)*1.5;
COMfy = com_cmf_0(2)*1.1;
COMfz = com_cmf_0(3);
MTJx = com_cmf_0(1);
MTJy = com_cmf_0(2);
MTJz = com_cmf_0(3);

init_vars = [mc,mf,COMcx,COMcy,COMcz,COMfx,COMfy,COMfz,MTJx,MTJy,MTJz,Icx,Icy,Icz]';

%% solve

optim_options = optimset('Display','off');

[x, fval, exitflag]=fsolve('footmodel',init_vars,optim_options,... 
    m_cmf_0,I_cmf_0,com_cmf_0,m_calcn,m_midfoot,m_forefoot,tarsometatarsal2com_cm,com_forefoot,If,sf);
    
    if (exitflag ~= 1)
        disp 'The fsolve exit flag was not 1, probably no convergence!'
        exitflag
    end
    
%% results for right foot
% format long
mc = x(1);
mf = x(2);
COMc = x(3:5);
COMf = x(6:8);
MTJ = x(9:11);
Ic = x(12:14);
MTPJ = mtp_0-MTJ;


disp('           I0                  Ic                  If')
disp([I_cmf_0 Ic If])

%% plot results in calcaneus ref frame
% This is the ref frame attached to the calcn in both the old model and the
% new model. The detailed model needs to be scaled.

% transform new model to ref frame
c2COMf = MTJ+COMf;
c2MTPJ = MTJ+MTPJ; %=mtp0
% transform detailed model to ref frame
c2mtpj = mtp_0;
c2mtj = mtp_0 - mtp;
c2com_ff = mtp_0 + mtp2com_forefoot;
c2com_cm = mtp_0 + mtp2com_cm;
% scale detailed model
c2mtpj_s = mtp_0; 
c2mtj_s = mtp_0 - mtp.*sf;
c2com_ff_s = mtp_0 + mtp2com_forefoot.*sf;
c2com_cm_s = mtp_0 + mtp2com_cm.*sf;


%contact spheres
locSphere_1_r=[-0.00042152, -0.01, -0.0049972];
locSphere_2_r=[0.06, -0.01, 0.020001];
locSphere_3_r=[0.165, -0.01, 0.021183];
locSphere_4_r=[0.165, -0.01, -0.01];
locSphere_5_r=[0.053154, -0.01, -0.0034173];
locSphere_6_r=[1.7381e-06, -0.01, 0.022294];

locSphere_3_r_new = locSphere_3_r - MTJ';
locSphere_4_r_new = locSphere_4_r - MTJ';

%plot
figure
subplot(2,1,1)
hold on
grid on

plot(c2mtpj(1),c2mtpj(2),'.b')
plot(c2mtj(1),c2mtj(2),'.b')
plot(c2com_ff(1),c2com_ff(2),'*b')
plot(c2com_cm(1),c2com_cm(2),'*b')

plot(c2mtpj_s(1),c2mtpj_s(2),'.k')
plot(c2mtj_s(1),c2mtj_s(2),'.k')
plot(c2com_ff_s(1),c2com_ff_s(2),'*k')
plot(c2com_cm_s(1),c2com_cm_s(2),'*k')

plot(mtp_0(1),mtp_0(2),'or')
plot(MTJ(1),MTJ(2),'or')
plot(c2COMf(1),c2COMf(2),'xr')
plot(COMc(1),COMc(2),'xr')

plot(mtp_0(1),mtp_0(2),'og')
plot(com_cmf_0(1),com_cmf_0(2),'xg')
plot(0,0,'og')
title('side view (sagittal plane)')

plot(locSphere_1_r(1),locSphere_1_r(2),'*c')
plot(locSphere_2_r(1),locSphere_2_r(2),'*c')
plot(locSphere_3_r(1),locSphere_3_r(2),'*c')
plot(locSphere_4_r(1),locSphere_4_r(2),'*c')
plot(mtp_0(1)+locSphere_5_r(1),mtp_0(2)+locSphere_5_r(2),'*c')
plot(mtp_0(1)+locSphere_6_r(1),mtp_0(2)+locSphere_6_r(2),'*c')

subplot(2,1,2)
hold on
grid on

plot(c2mtpj(1),-c2mtpj(3),'.b')
plot(c2mtj(1),-c2mtj(3),'.b')
plot(c2com_ff(1),-c2com_ff(3),'*b')
plot(c2com_cm(1),-c2com_cm(3),'*b')

plot(c2mtpj_s(1),-c2mtpj_s(3),'.k')
plot(c2mtj_s(1),-c2mtj_s(3),'.k')
plot(c2com_ff_s(1),-c2com_ff_s(3),'*k')
plot(c2com_cm_s(1),-c2com_cm_s(3),'*k')

plot(mtp_0(1),-mtp_0(3),'or')
plot(MTJ(1),-MTJ(3),'or')
plot(c2COMf(1),-c2COMf(3),'xr')
plot(COMc(1),-COMc(3),'xr')

plot(mtp_0(1),-mtp_0(3),'og')
plot(com_cmf_0(1),-com_cmf_0(3),'xg')
plot(0,0,'og')
title('top view (right foot)')

plot(locSphere_1_r(1),-locSphere_1_r(3),'*c')
plot(locSphere_2_r(1),-locSphere_2_r(3),'*c')
plot(locSphere_3_r(1),-locSphere_3_r(3),'*c')
plot(locSphere_4_r(1),-locSphere_4_r(3),'*c')
plot(mtp_0(1)+locSphere_5_r(1),-(mtp_0(3)+locSphere_5_r(3)),'*c')
plot(mtp_0(1)+locSphere_6_r(1),-(mtp_0(3)+locSphere_6_r(3)),'*c')



%% relating vectors to foot arch compression
% based on DOI: 10.1038/srep19403

a = MTJ(1:2);
b = MTPJ(1:2);

l_0 = norm(a+b);
h0 = -b(2); 
% Difference in y-coordinate between calcn origin and mtpj 
% results in 1� difference, so it is omitted.

c0 = acos(h0/norm(a));
d0 = acos(h0/norm(b));

tmt0 = (c0+d0)*180/pi;

h1 = h0*0.8; 
c1 = acos(h1/norm(a));
d1 = acos(h1/norm(b));

tmt1 = (c1+d1)*180/pi;

tmt_bound = tmt1 - tmt0
% So 15� bound is sensible

h2 = h0*0.87; 
c2 = acos(h2/norm(a));
d2 = acos(h2/norm(b));

tmt2 = (c2+d2)*180/pi;

tmt_2 = tmt2 - tmt0

%% Windlass mechanism
% close all
clc


a = norm(a);    % calcn length
b = norm(b);    % metatarsi length
phi0 = tmt0*pi/180;    % tmt vector angle
g0 = phi0;      % tmt vector angle inf stiff

q1 = [-15:1:15]*pi/180;
q2 = [-20:10:30]*pi/180;

L0 = sqrt(a^2 + b^2 - 2*a*b*cos(phi0));
H0 = h0;

% ws = [0.8:0.1:1.3];
ws = 1;

for w=1:length(ws)

cWL = 0.03/0.97 * ws(w);
l0 = (1-cWL*(q2*180/pi)/20)*L0;

g = acos( (a^2 + b^2 - l0.^2)/(2*a*b) );

q1_0 = g-g0;

cWL_l = nanmean(q1_0./q2); % linearly dependent on cWL

figure
plot(q2*180/pi,q1_0*180/pi)
grid on
hold on
plot(q2*180/pi,cWL_l*q2*180/pi,'--')
xlabel('mtp angle')
ylabel('tmt angle (k = inf)')


kTMT = 1000;

for i=1:length(q2)
   M_lin(:,i) = kTMT*(q1(:) - q1_0(i));
   M_lin_lin(:,i) = kTMT*(q1(:) - q2(i)*cWL_l);
   M_l(:,i) = kTMT*(q1(:) - q2(i)*cWL*(-12.35));
end

colr = hsv(i);

figure
hold on
grid on
for j=1:i
    plot(q1*180/pi,M_lin(:,j),'color',colr(j,:),'DisplayName',[num2str(q2(j)*180/pi) ' nonl'])
    plot(q1*180/pi,M_lin_lin(:,j),'--','color',colr(j,:),'DisplayName',[num2str(q2(j)*180/pi) ' WL qs lin'])
    plot(q1*180/pi,M_l(:,j),':','color',colr(j,:),'DisplayName',[num2str(q2(j)*180/pi) ' WL qs lin smpl'])
end
legend
xlabel('tmt angle')
ylabel('tmt moment')
title('effect WL on \Delta q1 (k=cst)')


phi = phi0 + q1;
L = sqrt(a^2 + b^2 - 2*a*b*cos(phi));
h = a*b./L.*sin(phi);

% figure
% plot(q1,h)

k0 = 7.1079e+05;

for i=1:length(q2)
   F(:,i) = k0*L0/l0(i)*(L(:)-l0(i));
   M(:,i) = F(:,i).*h(:);
   k_nl(1,i) = nanmean( M(:,i)./((q1(:) - q1_0(i))) );
end

cWLk = nanmean( (k_nl(q2~=0)-k_nl(q2==0))./(q2(q2~=0)) );
k_l = kTMT+q2*cWLk;

figure
plot(q2*180/pi,k_nl)
hold on
grid on
plot(q2*180/pi,k_l)
xlabel('tmt angle')
ylabel('tmt k')
title('effect WL on k')

figure
hold on
grid on
for j=1:i
   plot(q1*180/pi,k_nl(:,j)*h,'color',colr(j,:),'DisplayName',num2str(q2(j)*180/pi))
end
xlabel('tmt angle')
ylabel('tmt k*h')
title('effect WL on k and moment arm')


for i=1:length(q2)
   M_l(:,i) = k_l(i)*(q1(:) - q2(i)*cWL_l);
end

colr = hsv(i);

figure
hold on
grid on
for j=1:i
    plot(q1*180/pi,M(:,j),'color',colr(j,:),'DisplayName',num2str(q2(j)*180/pi))
    plot(q1*180/pi,M_l(:,j),'--','color',colr(j,:),'DisplayName',num2str(q2(j)*180/pi))
end
legend
xlabel('tmt angle')
ylabel('tmt moment')
title('effect WL on \Delta q1 and k')

% energy

for i=1:length(q2)
   E_p(:,i) = k_l(i)*(q1(:) - q2(i)*cWL_l).^2/2;
end

figure
hold on
grid on
for j=1:i
    plot(q1*180/pi,E_p(:,j),'color',colr(j,:),'DisplayName',num2str(q2(j)*180/pi))
%     plot(q1,M_l(:,j),'--','color',colr(j,:),'DisplayName',num2str(q2(j)))
end
legend
xlabel('tmt angle')
ylabel('tmt E_p')
title('effect WL on \Delta q1 and k')


cw(1,w) = cWL;
cw(2,w) = cWL_l;
cw(3,w) = cWLk;

end

%%
if w>1
    figure
    subplot(311)
    plot(ws,cw(1,:))
    subplot(312)
    plot(ws,cw(2,:))
    subplot(313)
    plot(ws,cw(3,:))


    nanmean(cw(1,:)./ws);
    nanmean(cw(2,:)./ws);
    nanmean(cw(3,:)./ws);

    figure
    plot(ws,cw(2,:)./cw(1,:))

    nanmean(cw(2,:)./cw(1,:))
end

