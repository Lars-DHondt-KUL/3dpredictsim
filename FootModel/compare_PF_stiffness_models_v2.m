clear
close all
clc


f_sigma = @(mu,alpha,k,lambda)  mu*(lambda.^2 - 1./lambda) + k/(2*alpha) *(exp(alpha*(lambda.^2-1))-1).*lambda.^2;

lambda = linspace(1,1.1,200);


mu = 0;
k = 356.42;
alpha = 4.419;
sigma(1,:) = f_sigma(mu,alpha,k,lambda);

k = 255.61;
alpha = 8.704;
sigma(2,:) = f_sigma(mu,alpha,k,lambda);

k = 236.41;
alpha = 14.684;
sigma(3,:) = f_sigma(mu,alpha,k,lambda);

k = 339.14;
alpha = 8.950;
sigma(4,:) = f_sigma(mu,alpha,k,lambda);

k = 295.7;
alpha = 9.123;
sigma(5,:) = f_sigma(mu,alpha,k,lambda);

mu = 14.449;
k = 254.02;
alpha = 10.397;
sigma(6,:) = f_sigma(mu,alpha,k,lambda);

% nu = 0.4; % Poisson ratio
% sigma(7,:) = sigma(6,:).*lambda.^(-nu*2);

legNames = {'sample 1','sample 2','sample 3','sample 4','Mean','Mean w/ mu'};
figure
hold on
plot(lambda,sigma(1:4,:),'--')
plot(lambda,sigma(5:end,:),'-','LineWidth',2)
xlabel('stretch [-]')
ylabel('stress [MPa]')

legend(legNames,'Location','best')

