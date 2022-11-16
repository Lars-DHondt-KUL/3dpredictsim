function [M_mtj] = getMidtarsalJointPassiveMoment(q_mtj,qdot_mtj,varargin)


%% Default parameters
mtj_stiffness = '';
dMT = 0.1;
nl = 0; % use nonlinear ligament stiffness
kMT_li = 300; % linear stiffness
kMT_li2 = kMT_li;
M_offset = 0;

%% Get specific parameters
if isempty(varargin)
    
else
    S = varargin{1};
    if isfield(S.Foot,'dMT') && ~isempty(S.Foot.dMT)
        dMT = S.Foot.dMT;
    end
    if isfield(S.Foot,'MT_li_nonl') && ~isempty(S.Foot.MT_li_nonl)
        nl = S.Foot.MT_li_nonl;
    end
    if isfield(S.Foot,'kMT_li') && ~isempty(S.Foot.kMT_li)
        kMT_li = S.Foot.kMT_li;
    end
    if isfield(S.Foot,'kMT_li2') && ~isempty(S.Foot.kMT_li2)
        kMT_li2 = S.Foot.kMT_li2;
    else
        kMT_li2 = kMT_li;
    end
    if isfield(S.Foot,'mtj_stiffness') && ~isempty(S.Foot.mtj_stiffness)
        mtj_stiffness = S.Foot.mtj_stiffness;
    end
    if isfield(S.Foot,'M_MT_offset') && ~isempty(S.Foot.M_MT_offset)
        M_offset = S.Foot.M_MT_offset;
    end
end


%% elastic structures
if nl
    if strcmp(mtj_stiffness,'Gefen2002')
        % A. Gefen (2002) "Stress analysis of the standing foot following surgical 
        % plantar fascia release", Journal of Biomechanics 35, 629–637
        M_li = -9*(exp(4*(q_mtj-2*pi/180))-1)*1.2 + 2*exp(-10*(q_mtj+0.1));

    elseif strcmp(mtj_stiffness,'Song2011')
        % S. Song, C. LaMontagna, S. H. Collins and H. Geyer,
        % „The Effect of Foot Compliance Encoded in the Windlass Mechanism 
        % on the Energetics of Human Walking,” in 35th Annual International 
        % Conference of the IEEE EMBS, Osaka, Japan, 2013. 
        M_li = -800*q_mtj;
        
    elseif strcmp(mtj_stiffness,'signed_lin')
        y_p = -kMT_li*q_mtj.*(tanh(q_mtj*100-0.5)+1)/2;
        y_n = -kMT_li2*q_mtj.*(-tanh(q_mtj*100+0.5)+1)/2;
        M_li = y_p + y_n  + M_offset;
            
    elseif strcmp(mtj_stiffness,'MG_exp')
        % Geometry of ligaments spanning the midtarsal joint based on 
        % Tiago M. Malaquias, Carolina Silveira, Wouter Aerts, Friedl De Groote, 
        % Greta Dereymaeker, Jos Vander Sloten & Ilse Jonkers (2017) 
        % Extended foot-ankle musculoskeletal models for application in movement 
        % analysis, Computer Methods in Biomechanics and Biomedical Engineering, 
        % 20:2, 153-159, DOI: 10.1080/10255842.2016.1206533
        % Ligament elastic properties based on 
        % A. Gefen (2002) "Stress analysis of the standing foot following surgical 
        % plantar fascia release", Journal of Biomechanics 35, 629–637
        %
        % Exponential expression fitted to combined angle-torque
        % relationship of ligaments for simplification. Coefficients are
        % calculated in \3dpredictsim\FootModel\fitPlantarLigamentMoment.m
        coeff = [1.8046, -0.5673, 0.0902, 14.6539];
        M_li = coeff(1) + coeff(2)*exp( (coeff(3) + q_mtj).*coeff(4) );

    elseif strcmp(mtj_stiffness,'MG_poly')
        % Same as above, but polynomial fitted instead
        M_li = 0.081222 + -10.873*q_mtj.^1 + -307.95*q_mtj.^2 + -3487.8*q_mtj.^3 + -7202.7*q_mtj.^4 + 76515*q_mtj.^5;

    end
else
    M_li = -kMT_li*q_mtj + M_offset;
end

% viscous damping
M_d = -(dMT-0.1)*qdot_mtj;

% Total passive moment
M_mtj = M_li + M_d;














