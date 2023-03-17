% clear
% close all
% clc

import casadi.*

cslocation(:,1) = [0.010 0.0069229175108780888 -0.0049972]';
cslocation(:,2) = [0.06 0.01192291751087809 0.02]';
cslocation(:,3) = [0.063970169355678008 -0.011406010125810932 0.02274865219]';
cslocation(:,4) = [0.063970169355678008 -0.011406010125810932 -0.00843404781]';
cslocation(:,5) = [0.053154 -0.0015385412445609557 -0.0034173]';
cslocation(:,6) = [1.7381e-06 -0.0015385412445609557 0.022294]';

csradius = [0.032,0.032,0.023,0.021,0.016,0.018];

csframe = {'calcn_r','calcn_r','forefoot_r','forefoot_r','toes_r','toes_r'};

fg1=figure;

nr = length(filteredResultsWithRef);
CsV = hsv(nr);

for i=1:nr

    load(filteredResultsWithRef{i},'R');
    
    x = 1:(100-1)/(size(R.Qs,1)-1):100;
    
    for j=1
        [sphere_p,sphere_v] = getSphereInGroundFrame(R,csframe{j},cslocation(:,j));
    
        indentation_j = sphere_p(:,2)-csradius(j);
        indentation_j(indentation_j>0) = 0;
    
    end
    
    figure(fg1)
    hold on
    plot(x, -indentation_j*1e3,'Color',CsV(i,:))


end

xlabel('gait cycle (%)')
ylabel('compression (mm)')
title('Heel pad compression')
