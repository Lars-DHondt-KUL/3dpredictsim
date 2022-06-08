
clear
close all
clc

pathmain = pwd;
[pathRepo,~,~]  = fileparts(pathmain);


%%
ModelPath = [pathRepo '\OpenSimModel\subject1\DetailedFootModel_pinMTJ_sc.osim'];
pathPoly = [pathRepo '\Polynomials\Fal_s1_mtj_sc'];

% ModelPath = [pathRepo '\OpenSimModel\subject1\DetailedFootModel_mtjc5_sc.osim'];
% pathPoly = [pathRepo '\Polynomials\Fal_s1_mtjc5_sc'];

if ~isfolder(pathPoly)
    mkdir(pathPoly);
end

ligament_names = {'LongPlantar1_r','LongPlantar2_r','LongPlantar3_r','LongPlantar4_r',... % long plantar ligament
    'CalcaneoCuboidPlantar1Mus_r','CalcaneoCuboidPlantar2Mus_r',... % short plantar ligament
    'CalcaneoNavicularPlantar1Mus_r','CalcaneoNavicularPlantar2Mus_r','CalcaneoNavicularPlantar3Mus_r',... % spring ligament
    'CalcaneoCuboidDorsalMus_r','CalcaneoNavicularBifurcateMus_r','CalcaneoCuboidBifurcateMus_r'}; % other


p = length(ligament_names);
n = 500;

q_mtj = linspace(-30,30,n)*pi/180;

CsV = hsv(p);
mrk = {'-','--',':','-.'};

%% Initialise model
import org.opensim.modeling.*;
model = Model(ModelPath);
s = model.initSystem;


for i=0:model.getCoordinateSet().getSize()-1
    if strcmp(char(model.getCoordinateSet().get(i)),'mtj_angle_r')
        idx_mtj = i;
        break
    end
end


%% Evaluate ligament moment for dummy motion
% Set state vector to 0
state_vars = model.getStateVariableValues(s);
state_vars.setToZero();
model.setStateVariableValues(s,state_vars);
model.realizePosition(s);
% Initialise matrices for results
l_0 = zeros(1,p);
pcsa_0 = zeros(1,p);
l_lig = zeros(n,p);
d_lig = zeros(n,p);
F_lig = zeros(n,p);

for j=1:p
    lig = Ligament.safeDownCast(model.getForceSet().get(ligament_names{j}));
    l_0(1,j) = lig.getRestingLength();
    pcsa_0(1,j) = lig.get_pcsa_force();
    Fl_c = lig.get_force_length_curve();

    for i=1:n
        % Set each coordinate value
        state_vars.set(idx_mtj*2,q_mtj(i));
        model.setStateVariableValues(s,state_vars);
        model.realizePosition(s);
        % Get length
        l_lig(i,j) = lig.getLength(s);
        % Get moment arm
        d_lig(i,j) = lig.computeMomentArm(s,model.getCoordinateSet().get(idx_mtj));
        
        % Get force
        l_ij = Vector(1,l_lig(i,j)/l_0(1,j));
        F_ij = Fl_c.calcValue(l_ij);
        F_lig(i,j) = F_ij*pcsa_0(1,j);

    end

end

M_lig = d_lig.*F_lig;
M_mtj = sum(M_lig,2);


%%

fg0=figure;
for i=1:p

    plot(q_mtj*180/pi,l_lig(:,i)/l_0(i),'Color',CsV(i,:),'LineStyle',mrk{rem(i,4)+1})
    hold on

    xlabel('Mtj angle (°)')
    ylabel('\lambda (-)')
end
ylim([1,1.5])

legend(ligament_names,'Interpreter','none','Location','northeastoutside')

%%

fg1=figure;
sgtitle('Linear stiffness')
subplot(3,1,1)
plot(q_mtj*180/pi,M_mtj)
xlabel('Mtj angle (°)')
ylabel('Mtj logament moment (Nm)')

for i=1:p
    subplot(3,1,2)
    plot(q_mtj*180/pi,M_lig(:,i),'Color',CsV(i,:),'LineStyle',mrk{rem(i,4)+1})
    hold on
    xlabel('Mtj angle (°)')
    ylabel('Mtj logament moment (Nm)')
    
    subplot(3,1,3)
    plot(l_lig(:,i)/l_0(i),F_lig(:,i),'Color',CsV(i,:),'LineStyle',mrk{rem(i,4)+1})
    hold on
    xlim([0.99,1.1])
    xlabel('\lambda (-)')
    ylabel('Tension (N)')
end
legend(ligament_names,'Interpreter','none','Location','northeastoutside')

%%
fg2=figure;
for i=1:p
    e_lig = l_lig(:,i)/l_0(i)-1;
    e_lig_all(:,i) = e_lig;
    e_idx = find(e_lig>=0 & e_lig<=0.1);
    e_lig = e_lig(e_idx);
%     disp(length(e_lig))
%     p1 = polyfit(e_lig,F_lig(e_idx,i),1);
%     EA(i) = p1(1);
    tmp_name = ligament_names{i};
    plot(e_lig+1,F_lig(e_idx,i)/pcsa_0(i),'Color',CsV(i,:),'DisplayName',tmp_name(1:end-2))
    hold on
    tmp = F_lig(e_idx,i);
    if isempty(tmp)
        tmp(1) = 0;
    end
    F_rel_max(i) = tmp(end)/pcsa_0(i);

    idx_tmp = find(e_lig_all(:,i)<0.2,1,"last");
    if isempty(idx_tmp)
        idx_tmp(1) = n;
    end
    idx_max(i) = idx_tmp;
end
legend('Interpreter','tex','Location','southoutside')
xlabel('\lambda (-)','Interpreter','tex')
ylabel('Tension/PCSA (-)')
q_max = q_mtj(min(idx_max))*180/pi;
E_mean_M = max(F_rel_max)/0.1;

%%
lambda1 = linspace(1,1.15,500)';
modelfun_G_exp = @(coeff,x) coeff(1)*(exp( coeff(2)*(x-coeff(3)) ) - 1);
coeff_0 = [6.7,9,1];

x_fit = lambda1;
y_fit = getLigamentGefen2002(lambda1);

mdl = fitnlm(x_fit,y_fit,modelfun_G_exp,coeff_0);
coeff_sol = table2array(mdl.Coefficients(:,1));

f_getMtjLigamentMoment_G_exp = @(lm) modelfun_G_exp(coeff_sol,lm);

df_dl = @(lm) coeff_sol(1)*coeff_sol(2)*exp(coeff_sol(2)*(lm-coeff_sol(3)));

%%
lambda = linspace(1,1.1,500)';
sigma = getLigamentGefen2002(lambda);
sigma_exp = f_getMtjLigamentMoment_G_exp(lambda);
nu = 0.4;

sigma_eng = sigma.*lambda.^(-nu*2);
sigma_exp_eng = sigma_exp.*lambda.^(-nu*2);

fg3=figure;
plot(lambda,sigma,'DisplayName','Cauchy stress')
hold on
plot(lambda,sigma_eng,'DisplayName','engineering stress')
xlabel('\lambda (-)','Interpreter','tex')
ylabel('\sigma (N/mm^2)','Interpreter','tex')
legend('Interpreter','tex','Location','best')

pol =  polyfit(lambda-1,sigma_eng,1);
E_mean_G = pol(1);

sigma_pol = polyval(pol,lambda-1);
plot(lambda,sigma_pol,'--','DisplayName','\sigma_e 1e order polynomial fit')

E_mean_G1 = (lambda-1)\sigma_eng;
% plot(lambda,E_mean_G1*(lambda-1),'-.','DisplayName','\sigma_e tangent 1 of Gefen (2002) model')
plot([1,1.1],[0,0.1*E_mean_G1],'--','DisplayName','\sigma_e tangent of Gefen (2002) model')
legend

sf = E_mean_M/E_mean_G1;
figure(fg2)
hold on
plot([1,1.1],[0,0.1*E_mean_M],'--','DisplayName','Linear')
% plot([1,1.1],[0,0.1*E_mean_G1*sf],'--','DisplayName','scaled tangent of Gefen (2002) model')
% plot(lambda,sigma_eng*sf,'--k','DisplayName','scaled Gefen (2002) model')

E_tan_exp = df_dl(1.1);
sf2 = E_mean_M/E_tan_exp;
figure(fg2)
hold on
plot(lambda,sigma_exp_eng*sf2,'-k','DisplayName','scaled (@\lambda = 1.10) exponential fit of Gefen (2002) model')

E_tan_exp3 = df_dl(1.05);
sf3 = E_mean_M/E_tan_exp3;
plot(lambda,sigma_exp_eng*sf3,'-.k','DisplayName','scaled (@\lambda = 1.05) exponential fit of Gefen (2002) model')

%%
F_lig_G = zeros(size(F_lig));

for j=1:p
    lambda_j = l_lig(:,j)/l_0(1,j);
    sigma_j = getLigamentGefen2002(lambda_j);
    F_lig_G(:,j) = sigma_j*sf*pcsa_0(j);
end

M_lig_G = d_lig.*F_lig_G;
M_mtj_G = sum(M_lig_G,2);


fg4=figure;
sgtitle('Gefen 2002 model')
subplot(3,1,1)
plot(q_mtj*180/pi,M_mtj_G)
hold on
plot(q_mtj*180/pi,M_mtj,'--k')
xlabel('Mtj angle (°)')
ylabel('Mtj logament moment (Nm)')
ylim([-100,100])

for i=1:p
    subplot(3,1,2)
    plot(q_mtj*180/pi,M_lig_G(:,i),'Color',CsV(i,:),'LineStyle',mrk{rem(i,4)+1})
    hold on
    xlabel('Mtj angle (°)')
    ylabel('Mtj logament moment (Nm)')
    ylim([-30,30])

    subplot(3,1,3)
    plot(l_lig(:,i)/l_0(i),F_lig_G(:,i),'Color',CsV(i,:),'LineStyle',mrk{rem(i,4)+1})
    hold on
    xlim([0.99,1.1])
    xlabel('\lambda (-)')
    ylabel('Tension (N)')
end
legend(ligament_names,'Interpreter','none','Location','northeastoutside')


%%
F_lig_G_exp = zeros(size(F_lig));

for j=1:p
    lambda_j = l_lig(:,j)/l_0(1,j);
    sigma_j = f_getMtjLigamentMoment_G_exp(lambda_j);
    sigma_j(lambda_j(:)<1) = 0;

    idx_12 = find(lambda_j(:)>1.2);
    if ~isempty(idx_12)
        sigma_j_12 = f_getMtjLigamentMoment_G_exp(1.2);
        sigma_j(idx_12) = (lambda_j(idx_12)-1.2)*df_dl(1.2) + sigma_j_12;
    end
    F_lig_G_exp(:,j) = sigma_j*sf2*pcsa_0(j);
end

% F_lig_G_exp(:,5) = F_lig_G_exp(:,5)*0.5; % adjust 1 ligament part

M_lig_G_exp = d_lig.*F_lig_G_exp;
M_mtj_G_exp = sum(M_lig_G_exp,2);


fg4a=figure;
sgtitle({'Exponential fit of Gefen 2002 model','scaled at \lambda = 1.10'})
subplot(3,1,1)
plot(q_mtj*180/pi,M_mtj_G_exp)
hold on
plot(q_mtj*180/pi,M_mtj,'--k')
xlabel('Mtj angle (°)')
ylabel('Mtj logament moment (Nm)')

for i=1:p
    subplot(3,1,2)
    plot(q_mtj*180/pi,M_lig_G_exp(:,i),'Color',CsV(i,:),'LineStyle',mrk{rem(i,4)+1})
    hold on
    xlabel('Mtj angle (°)')
    ylabel('Mtj logament moment (Nm)')
    
    subplot(3,1,3)
    plot(l_lig(:,i)/l_0(i),F_lig_G_exp(:,i),'Color',CsV(i,:),'LineStyle',mrk{rem(i,4)+1})
    hold on
    xlim([0.99,1.4])
    xlabel('\lambda (-)')
    ylabel('Tension (N)')
end
legend(ligament_names,'Interpreter','none','Location','northeastoutside')

%%
F_lig_G_exp3 = zeros(size(F_lig));

for j=1:p
    lambda_j = l_lig(:,j)/l_0(1,j);
    sigma_j = f_getMtjLigamentMoment_G_exp(lambda_j);
    sigma_j(lambda_j(:)<1) = 0;

    idx_12 = find(lambda_j(:)>1.2);
    if ~isempty(idx_12)
        sigma_j_12 = f_getMtjLigamentMoment_G_exp(1.2);
        sigma_j(idx_12) = (lambda_j(idx_12)-1.2)*df_dl(1.2) + sigma_j_12;
    end
    F_lig_G_exp3(:,j) = sigma_j*sf3*pcsa_0(j);
end

% F_lig_G_exp3(:,5) = F_lig_G_exp3(:,5)*0.5; % adjust 1 ligament part

M_lig_G_exp3 = d_lig.*F_lig_G_exp3;
M_mtj_G_exp3 = sum(M_lig_G_exp3,2);


fg4b=figure;
sgtitle({'Exponential fit of Gefen 2002 model','scaled at \lambda = 1.05'})
subplot(3,1,1)
plot(q_mtj*180/pi,M_mtj_G_exp3)
hold on
plot(q_mtj*180/pi,M_mtj,'--k')
xlabel('Mtj angle (°)')
ylabel('Mtj logament moment (Nm)')

for i=1:p
    subplot(3,1,2)
    plot(q_mtj*180/pi,M_lig_G_exp3(:,i),'Color',CsV(i,:),'LineStyle',mrk{rem(i,4)+1})
    hold on
    xlabel('Mtj angle (°)')
    ylabel('Mtj logament moment (Nm)')
    
    subplot(3,1,3)
    plot(l_lig(:,i)/l_0(i),F_lig_G_exp3(:,i),'Color',CsV(i,:),'LineStyle',mrk{rem(i,4)+1})
    hold on
    xlim([0.99,1.4])
    xlabel('\lambda (-)')
    ylabel('Tension (N)')
end
legend(ligament_names,'Interpreter','none','Location','northeastoutside')


%%

fg5=figure;
% plot(q_mtj*180/pi,M_mtj,'DisplayName','Linear')
hold on
plot(q_mtj*180/pi,M_mtj_G,'DisplayName','Gefen (2002)')
legend('Location','best','Interpreter','tex')
xlabel('mtj angle (°)')
ylabel('mtj moment (Nm)')


%%
% modelfun = @(coeff,x) coeff(1) + coeff(2)*exp((coeff(3)+x).*coeff(4)) + coeff(5).*x;
% 
% coeff_0 = [0,-0.3,0.2,10,-10];
% M_tmp = modelfun(coeff_0,q_mtj);

% figure(fg5)
% plot(q_mtj*180/pi,M_tmp,'--','DisplayName','IG a + b*exp{(c+q)*d} + e*q')

%%
% idx_fit = find(q_mtj*180/pi<=q_max);
% x_fit = q_mtj(idx_fit);
% y_fit = M_mtj_G(idx_fit);
% 
% 
% mdl = fitnlm(x_fit,y_fit,modelfun,coeff_0);
% coeff_sol = table2array(mdl.Coefficients(:,1));
% f_getMtjLigamentMoment = @(q) modelfun(coeff_sol,q);


%%

% M_mtj_func = f_getMtjLigamentMoment(q_mtj);
% 
% figure(fg5)
% plot(q_mtj*180/pi,M_mtj_func,'--','DisplayName','a + b*exp{(c+q)*d} + e*q')

%%

% poly_GM = polyfit(q_mtj,M_mtj_G,5);
% figure(fg5)
% plot(q_mtj*180/pi,polyval(poly_GM,q_mtj),'--','DisplayName','5th order polynomial')
% 
% poly_GM = polyfit(q_mtj,M_mtj_G,15);
% figure(fg5)
% plot(q_mtj*180/pi,polyval(poly_GM,q_mtj),'--','DisplayName','15th order polynomial')

%%
% coeff = poly_GM(end:-1:1);
% codeString = ['M_li = ' num2str(coeff(1),5)];
% for ii=1:length(coeff)-1
%     codeString = [codeString ' + ' num2str(coeff(ii+1),5) '*q_mtj.^' num2str(ii)];
% end
% codeString = [codeString ';'];
% disp(codeString)

%%
% M_li = 0.081222 + -10.873*q_mtj.^1 + -307.95*q_mtj.^2 + -3487.8*q_mtj.^3 + -7202.7*q_mtj.^4 + 76515*q_mtj.^5;
% figure(fg5)
% plot(q_mtj*180/pi,M_li,'-.','DisplayName','5e-th order polynomial')

%% 
% % Adapt the moment to not fall back to 0 after a peak, but maintain its
% % peak value.
% M_mtj_G2 = M_mtj_G;
% 
% M_mtj_qn = M_mtj_G(q_mtj<0);
% [M_max,idx_max] = max(M_mtj_qn);
% q_n = q_mtj(q_mtj<0);
% q_max = q_n(idx_max);
% M_mtj_G2(q_mtj<q_max) = M_max;
% 
% M_mtj_qp = M_mtj_G(q_mtj>0);
% [M_min,idx_min] = min(M_mtj_qp);
% q_p = q_mtj(q_mtj>0);
% q_min = q_p(idx_min);
% M_mtj_G2(q_mtj>q_min) = M_min;
% 
% % figure(fg5)
% % plot(q_mtj*180/pi,M_mtj_G2,'--','DisplayName','plateau-ed')
% % ylim([M_min,M_max]*1.2)
% ylim([-100,20])

%%
% import casadi.*
% f_getMtjLigamentMoment = interpolant('f_getMtjLigamentMoment','bspline',{q_mtj},M_mtj_G2);
% 
% figure(fg5)
% M_mtj_cas = f_getMtjLigamentMoment(q_mtj);
% plot(q_mtj*180/pi,full(M_mtj_cas),'--','DisplayName','casadi function')
% 
% f_getMtjLigamentMoment.save((fullfile(pathPoly,'f_getMtjLigamentMoment')));

%%
% import casadi.*
% f_getMtjLigamentMoment_exp = interpolant('f_getMtjLigamentMoment_exp','bspline',{q_mtj},M_mtj_G_exp);
% 
% figure(fg5)
% M_mtj_cas = f_getMtjLigamentMoment_exp(q_mtj);
% plot(q_mtj*180/pi,full(M_mtj_cas),'-','DisplayName','exp, scaled at \lambda = 1.10')
% 
% f_getMtjLigamentMoment_exp.save((fullfile(pathPoly,'f_getMtjLigamentMoment_exp')));
% 
% % assume long plantar ligament removed
% M_mtj_G_exp_d = sum(M_lig_G_exp(:,5:end),2);
% f_getMtjLigamentMoment_exp_d = interpolant('f_getMtjLigamentMoment_exp_d','bspline',{q_mtj},M_mtj_G_exp_d);
% f_getMtjLigamentMoment_exp_d.save((fullfile(pathPoly,'f_getMtjLigamentMoment_exp_d')));
% 
% % assume short plantar ligament also removed
% M_mtj_G_exp_e = sum(M_lig_G_exp(:,7:end),2);
% f_getMtjLigamentMoment_exp_e = interpolant('f_getMtjLigamentMoment_exp_e','bspline',{q_mtj},M_mtj_G_exp_e);
% f_getMtjLigamentMoment_exp_e.save((fullfile(pathPoly,'f_getMtjLigamentMoment_exp_e')));
% 
% % assume spring ligament also removed
% M_mtj_G_exp_f = sum(M_lig_G_exp(:,10:end),2);
% f_getMtjLigamentMoment_exp_f = interpolant('f_getMtjLigamentMoment_exp_f','bspline',{q_mtj},M_mtj_G_exp_f);
% f_getMtjLigamentMoment_exp_f.save((fullfile(pathPoly,'f_getMtjLigamentMoment_exp_f')));


%%

% f_test = Function.load((fullfile(pathPoly,'f_getMtjLigamentMoment')));
% 
% figure(fg5)
% M_mtj_cas_t = f_test(q_mtj);
% plot(q_mtj*180/pi,full(M_mtj_cas_t),'--','DisplayName','casadi function 1')

%%
% import casadi.*
% f_getMtjLigamentMoment_exp5 = interpolant('f_getMtjLigamentMoment_exp5','bspline',{q_mtj},M_mtj_G_exp3);
% 
% figure(fg5)
% M_mtj_cas5 = f_getMtjLigamentMoment_exp5(q_mtj);
% plot(q_mtj*180/pi,full(M_mtj_cas5),'-','DisplayName','exp, scaled at \lambda = 1.05')
% 
% f_getMtjLigamentMoment_exp5.save((fullfile(pathPoly,'f_getMtjLigamentMoment_exp5')));

%%
% M_mtj_G_exp4 = M_mtj_G_exp3;
% M_mtj_G_exp4(q_mtj<0) = M_mtj_G_exp4(q_mtj<0)*2;
% 
% import casadi.*
% f_getMtjLigamentMoment_exp_v2 = interpolant('f_getMtjLigamentMoment_exp_v2','bspline',{q_mtj},M_mtj_G_exp4);
% 
% figure(fg5)
% M_mtj_cas4 = f_getMtjLigamentMoment_exp_v2(q_mtj);
% plot(q_mtj*180/pi,full(M_mtj_cas4),'-','DisplayName','exp, scaled at \lambda = 1.10, M(q<0)x2')

% f_getMtjLigamentMoment_exp_v2.save((fullfile(pathPoly,'f_getMtjLigamentMoment_exp_v2')));

%%

% for i=1:length(ligament_names)
%     disp([ligament_names{i}(1:end-2) ' A_0 = ' num2str(pcsa_0(i)*sf2,2) ' mm^2'])
% end

%%

function sigma_f = getLigamentGefen2002(lambda_f)
    % Gefen2002
    a1 = -412640.5;
    a2 = 2235967.7;
    a3 = -4841544.8;
    a4 = 5236972.7;
    a5 = -2829945.7;
    a6 = 611190.6;
    sigma_f = a1*lambda_f.^5 + a2*lambda_f.^4 + a3*lambda_f.^3 + a4*lambda_f.^2 + a5*lambda_f + a6;
    sigma_f(lambda_f<1) = 0;
end
