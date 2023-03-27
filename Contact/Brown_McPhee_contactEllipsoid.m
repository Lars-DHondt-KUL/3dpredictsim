function [force,varargout] = Brown_McPhee_contactEllipsoid(stiffness,dissipation,...
    normalvec,radius,sphereRot_inG,spherePos_inW,sphereLinVel_inW)

% make sure normalvec is a unit vector
normalvec = normalvec/norm(normalvec);

%% Ellipsoid frame
% rotation matrix world to elipsoid
Rot = eul2rotm(sphereRot_inG,'XYZ')*eul2rotm([0,-0.15,0],'XYZ');

% plane in ellipsoid frame
normalvec_inE = Rot*normalvec;
orW_inE = -Rot*spherePos_inW;
D = dot(orW_inE,-normalvec_inE);

% centre of pressure
CoP_inE = D*(-normalvec_inE).*radius;

% dimentionless distance plane to centre
d = D/norm(normalvec_inE.*radius);
% clamp d >= 0
d = d*smoothIf(d,0,0.01); 

% volume
volume = pi/3*radius(1)*radius(2)*radius(3)*(d^3 - 3*d + 2);
% clamp d <= 1
volume = volume*smoothIf(d,1,0.99);

% indentation velocity
indentationVel = -dot(sphereLinVel_inW,normalvec);

% normal force
Fn = stiffness*volume*(1 + dissipation*indentationVel);

% total force vector
force = Fn*normalvec;


if nargout >=2
    varargout{1} = D;
end
if nargout >=3
    varargout{2} = d;
end
if nargout >=4
    varargout{3} = volume;
end


end
