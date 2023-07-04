clear
clc

% 3-point bending of beam, force in middle

k3p_all = [7,32,85]; % N/mm

L0 = 0.25; % m
for k3p = k3p_all*1e3 % N/m;

    % d = (F*L^3)/(48*E*I)
    % E*I = F*L0^3/(48*d)
    EI = k3p*L0^3/(48);
    
    % moment on free end of clamped beam
    L = L0/2; % free length MTP to midfoot
    
    % theta = (M*L)/(E*I)
    % k_MTP = M/theta = (E*I)/L
    k_MTP = EI/L

end