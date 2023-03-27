function [force] = Brown_McPhee_contactSphere(stiffness,radius,dissipation,...
    normalvec,spherePos_inG,sphereLinVel_inG)

% make sure normalvec is a unit vector
normalvec = normalvec/norm(normalvec);

indentation = norm(normalvec*radius - spherePos_inG);

volume = pi/3*indentation.^2.*(3*radius-indentation);

indentationVel = -dot(sphereLinVel_inG,normalvec);


Fn = stiffness*volume*(1 + dissipation*indentationVel);

force = Fn*normalvec;


end