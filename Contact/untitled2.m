
import casadi.*


x0 = linspace(-0.3,0.3,200);

x0_SX = SX.sym('x0');

x1_SX = x0_SX.*smoothIf(x0_SX,-0.1,0.1);

[f_smoothHuber_SX] = getSmoothingHuber_SXfunction(-0.1,0.1);

x2_SX = full( f_smoothHuber_SX(x0_SX, 0, x0_SX) );

dx1_SX = jacobian(x1_SX,x0_SX);
dx2_SX = jacobian(x2_SX,x0_SX);

fun = Function('f',{x0_SX},{x1_SX,x2_SX,dx1_SX,dx2_SX});

x3 = x0;
x3(x3<0) = 0;

[x1,x2,dx1,dx2] = fun(x0);

x1 = full(x1);
x2 = full(x2);
dx1 = full(dx1);
dx2 = full(dx2);

figure
tiledlayout(2,1)
nexttile
hold on
plot(x0,x3,'DisplayName', 'exact', 'LineWidth',2)
plot(x0,x1, 'DisplayName', 'tanh', 'LineWidth',2)
plot(x0,x2, 'DisplayName', 'cfr. Huber loss function', 'LineWidth',2)
xlabel('original value')
ylabel('clipped to positive values')

legend('Location','best')

nexttile
hold on
plot(x0,dx1, 'LineWidth',2)
plot(x0,dx1, 'LineWidth',2)
plot(x0,dx2, 'LineWidth',2)

