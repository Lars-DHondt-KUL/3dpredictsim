clear
close all
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

h1=figure('Position',[400,400,600,500]);
tiledlayout('flow')
nexttile
hold on
xlabel('Strain (%)','FontSize',12)
ylabel('Stress (MPa)','FontSize',12)
title('Uniaxial tension test of plantar fascia','FontSize',12)

xlim([0,10])
ylim([0,50])

%%
data = readtable(fullfile(pathRepo,'Figures','Kitaoka_et_al_1994.csv'));

l0 = 100; %mm
A0 = 42; % mm^2
% A0 = 200;

lambda = data.deformation/l0 + 1;

nu = 0.4; % Poisson ratio
A = A0*lambda.^(-nu*2); % actual cross-section

sigma = data.force./A;

% sort
[lambda,idx] = sort(lambda);
sigma = sigma(idx);

% remove last few points to thin out large clump
% lambda = lambda(1:end-5);
% sigma = sigma(1:end-5);

leg(1)=plot((lambda-1)*100,sigma,'.','MarkerSize',10,'Color',[1,1,1]*0.5,'DisplayName','Data Kitaoka et al., 1994 (assuming CSA = 42 mm^2)');

%%
for i=["A","B","C"]
    data = readtable(fullfile(pathRepo,'Figures',['Fessel_et_al_2014_' char(i) '.csv']));
    
    lambda = data.strain/100 + 1;
    sigma = data.stress;
    
    nu = 0.4; % Poisson ratio
    sigma = sigma./(lambda.^(-nu*2)); % actual cross-section
    
    lambda = lambda(lambda<1.1);
    sigma = sigma(lambda<1.1);
    
    leg(2)=plot((lambda-1)*100,sigma,'-','LineWidth',2,'Color',[1,1,1]*0.5,'DisplayName',['Data Fessel et al., 2014 (3 specimen)']);
    text(10,sigma(end),i,'HorizontalAlignment','right','VerticalAlignment','bottom')
end

%%


f_sigma = @(mu,alpha,k,lambda)  mu*(lambda.^2 - 1./lambda) + k/(2*alpha) *(exp(alpha*(lambda.^2-1))-1).*lambda.^2;

lambda_fig = linspace(1,1.1,500)';

%%
% mu = 0;
% % function of the curve you want to fit
% modelfun = @(coeff,x) f_sigma(mu,coeff(1),coeff(2),x);
% % initial guess for coefficient vactor
% coeff_0 = [10.397, 254.20];
% % data points
% x_fit = lambda;
% y_fit = sigma;
% % fit the model
% mdl = fitnlm(x_fit,y_fit,modelfun,coeff_0);
% % get coefficient values
% coeff_sol = table2array(mdl.Coefficients(:,1));
% % fill in the fitted coefficients
% f_fittedCurve = @(q) modelfun(coeff_sol,q);
% 
% mu = mu
% alpha = coeff_sol(1)
% k = coeff_sol(2)

% plot(lambda_fig,f_fittedCurve(lambda_fig))

%%
mu = 14.449; % (MPa)
k = 254.02; % (MPa)
alpha = 10.397; % (-)

sigma_N = f_sigma(mu,alpha,k,lambda_fig);

leg(end+1)=plot((lambda_fig-1)*100,sigma_N,'-.k','LineWidth',2,'DisplayName','Model Natali et al., 2010 (fitted on data Wright and Rennels, 1964)');


%%
a1 = -488737.9;
a2 = 2648898.5;
a3 = -5736967.6;
a4 = 6206986.7;
a5 = -3354935.1;
a6 = 724755.5;
sigma_G = a1*lambda_fig.^5 + a2*lambda_fig.^4 + a3*lambda_fig.^3 + a4*lambda_fig.^2 + a5*lambda_fig + a6 -0.100; % stress correction term, to make F=0 for l=ls

leg(end+1)=plot((lambda_fig-1)*100,sigma_G,'--','Color',[0.8500 0.3250 0.0980],'LineWidth',2,'DisplayName','Model Gefen, 2002');

%%





%%

lg=legend(leg,'FontSize',12,'Box','off');
lg.Layout.Tile = 'south';

%%

FigRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\PhD\foot_modelling\paper\revision 1\figures';
exportgraphics(h1,fullfile(FigRepo,'PF_testing.jpeg'),'Resolution',300);
