

strain_rate_SX = linspace(-2,2,200);

parameters.v_saturation = 1;
parameters.saturated_v_gain = 0.1;

cte = pi/(2*parameters.v_saturation);
v_deformation = 1/cte*tanh(cte.*strain_rate_SX) +...
    parameters.saturated_v_gain * strain_rate_SX;


figure
hold on
plot(strain_rate_SX,strain_rate_SX,'-k','LineWidth',2)
plot(strain_rate_SX, v_deformation,'LineWidth',2)

axis equal
xlabel('actual strain rate','FontSize',12)
ylabel('strain rate used for dissipation','FontSize',12)