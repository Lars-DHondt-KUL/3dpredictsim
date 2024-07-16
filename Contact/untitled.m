

parameters.v_transition (1,1) = 0.2; % [m s^-1]
parameters.mu_friction (1,1) = 0.8; % [-]
parameters.mu_viscousFriction (1,1) = 0.5; % [-]


tangent_velocity_SX = linspace(-1,1,200);

mu_fr = parameters.mu_friction * tanh(tangent_velocity_SX/parameters.v_transition*pi) + ...
        parameters.mu_viscousFriction * tangent_velocity_SX/parameters.v_transition;


figure
plot(tangent_velocity_SX,mu_fr, 'LineWidth',2)
xlabel('v tangent [m/s]')
ylabel('mu [-]')

