%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns a casADi function object that describes the tensile
% force of the plantar fascia in function of its length.
%
% modelType contains a string specifying the model to be used. Valid
% entries can be seen in section 3).
%
% It is possible to overwrite default parameter values by adding their
% name (string) and desired value (double) as additional inputs. Do note
% that most model types use different parameters.
%
% Author: Lars D'Hondt (March 2021)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f_PF_stiffness, varargout] = f_getPlantarFasciaStiffnessModelCasADiFunction(modelType,varargin)


import casadi.*
l = SX.sym('l'); % length as casadi variable

%% 1) Default parameters
E = 350; % Young's modulus (N/mm^2)
A0 = 70; % initial cross-section (mm^2)
nu = 0.4; % Poisson ratio
ls = 0.146; % slack length (m)
k = E*A0/ls; % spring constant (N/m)
dl_0 = ls/100*1; % toe-in length

%% 2) Check for possible non-default parameter inputs
if length(varargin) >= 2 && mod(length(varargin),2) == 0
   for i=1:2:length(varargin)
       if strcmp(varargin{i},'E')
           E = varargin{i+1};
       elseif strcmp(varargin{i},'A0')
           A0 = varargin{i+1};
       elseif strcmp(varargin{i},'ls')
           ls = varargin{i+1};
       end
       % might need to recalculate those:
       k = E*A0/ls; % spring constant (N/m)
       dl_0 = ls/100*1; % toe-in length
       if strcmp(varargin{i},'k1')
           k = varargin{i+1};
       elseif strcmp(varargin{i},'dl_0')
           dl_0 = varargin{i+1};
       end
   end
end

%% 3) Calculate force 
% intermediate variables
dl = l-ls; % elongation
lambda = l/ls; % stretch ratio
A = A0*lambda^(-nu*2); % actual cross-section

% stiffness models
if strcmp(modelType,'linear')
    F_PF = k*dl;
    F = F_PF*(tanh(dl*5e3-1.2)+1)/2;
    
elseif strcmp(modelType,'tanh')
    F_PF = k*(dl - dl_0*tanh(dl/dl_0));
    F = F_PF*(tanh(dl*1e4)+1)/2;
    
elseif strcmp(modelType,'Gefen2002')
    % 5th order polynomial approximation
    % https://doi.org/10.1016/S0021-9290(01)00242-1
    a1 = -488737.9;
    a2 = 2648898.5;
    a3 = -5736967.6;
    a4 = 6206986.7;
    a5 = -3354935.1;
    a6 = 724755.5;
    sigma = a1*lambda^5 + a2*lambda^4 + a3*lambda^3 + a4*lambda^2 + a5*lambda + a6 -0.100; % stress correction term, to make F=0 for l=ls
    F_PF = sigma*A; 
    F = F_PF*(tanh(dl*3e3-1)+1)/2;
    
elseif strcmp(modelType,'Cheng2008')
    % Mooney-Rivlin model with 5 parameters (2nd order)
    % DOI: 10.3113/FAI.2008.0845
    % https://digitalcommons.unf.edu/etd/740
    c10 = -222.1;
    c01 = 290.97;
    c20 = -1.1257;
    c11 = 4.7267;
    c02 = 79.602;
    lambda = l/ls; % stretch ratio
    I1 = ((lambda^2)+(2/lambda)); % 1st strain invariant
    I2 = ((2*lambda)+(lambda^-2)); % 2nd strain invariant
    W = c10*(I1-3) + c01*(I2-3) + c11*(I1-3)*(I2-3) + c20*(I1-3)^2 + ...
        c02*(I2-3)^2; % strain energy density function
        % sigma = lambda * jac(W,lambda)
        % sigma_e = sigma/lambda, assuming uniaxial tension
        % combining both steps gives:
    sigma_e = ls*jacobian(W,l); % engineering stress
    F_PF = sigma_e*A0;
    F = F_PF*(tanh(dl*5e3-1)+1)/2;
    
elseif strcmp(modelType,'Barrett2018')
    % data from DOI 10.1007/s00276-011-0873-z
    e_0 = 0.03; % nominal strain at 0 stress when extrapolating linear region (-)
    sigma_0 = 0.5; % nominal strain at e_0 (MPa)
    E = 72;
    % method from https://doi.org/10.1016/j.jbiomech.2017.10.037
    mu = -ls*e_0;
    F0 = sigma_0*A0;
    k = E*A0/ls;
    std = sqrt(2*pi)*F0/k;
    x = l - ls;
    z = (x+mu)/(sqrt(2)*std);
    zi = linspace(0,z,500)';
    d_erf = exp(-zi.^2);
    erf = 2/sqrt(pi)* sum(d_erf(2:end)*z)/500;
    F_PF = k*std/sqrt(2*pi)*exp(-(x+mu).^2/(2*std^2)) + k*(x+mu)/2 .*(erf+1);
    F = F_PF;
    
elseif strcmp(modelType,'Natali2010')
    % https://doi.org/10.3109/03008200903389127
    mu = 14.449; % (MPa)
    k = 254.02; % (MPa)
    alpha = 10.397; % (-)
    sigma = mu*(lambda^2 - 1/lambda) + k/(2*alpha) *(exp(alpha*(lambda^2-1))-1)*lambda^2; % Cauchy stress
    F_PF = sigma*A;
    F = F_PF*(tanh(dl*4e3-1.1)+1)/2;
    
elseif strcmp(modelType,'Ker1987')
    % see ligament_torques_Ker87.m
    F_PF = 1190429209.9 + -6723339025.14*lambda^1 + 15825461895.6*lambda^2 + -19872782816.5*lambda^3 +...
        14042641491.4*lambda^4 + -5294662348.84*lambda^5 + 832251593.622*lambda^6;
    F = F_PF*(tanh(dl*1e4-1)+1)/2;
    
elseif strcmp(modelType,'Song2011')
    k = 5e6;
    F_PF = k*dl^2;
    F = F_PF*(tanh(dl*1e4-1)+1)/2;

elseif strcmp(modelType,'none')
    % plantar fascia fully released
    F = 0;
else
    F = 0;
    warning('No valid function to describe the plantar fascia stiffness model, using 0 instead.')
end  



%% 4) Define outputs
% force-length function
f_PF_stiffness = Function('f_PF_stiffness',{l},{F},{'l'},{'F'});

% When asked, the funcion returns additional arguments for analysis
if nargout == 4
    % Hessian
    [H,g] = hessian(F,l);
    g_f = Function('gradient',{l},{g},{'l'},{'g'});
    varargout{1} = g_f;
    % gradient
    H_f = Function('hessian',{l},{H},{'l'},{'H'});
    varargout{2} = H_f;
    % force-length without tanh-smoothing
    f_PF_stiffness_nonsmoothed = Function('f_PF_stiffness_nonsmoothed',{l},{F_PF},{'l'},{'F'});
    varargout{3} = f_PF_stiffness_nonsmoothed;
end













end