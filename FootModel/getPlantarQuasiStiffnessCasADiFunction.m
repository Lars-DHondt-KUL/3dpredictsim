function [f_plantar_quasi_stiffness] = getPlantarQuasiStiffnessCasADiFunction(S)

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/Musclemodel']);

import casadi.*

%%
ls = S.Foot.PF_slack_length;
f_PF_stiffness = f_getPlantarFasciaStiffnessModelCasADiFunction(S.Foot.PF_stiffness,'ls',ls);


%%
if isfield(S.Foot,'FDB') && S.Foot.FDB == 2
    aTendon = 35;
    shift = getShift(aTendon);
    pass_shift = S.Foot.FDB_shift;
    tension = 0.7;
    
    % hard-coded instead of loading mat-files to avoid error
    Fvparam = [-0.3183 -8.1492 -0.3741 0.8856];
    Fpparam = [-0.9952; 53.5982];
    Faparam = [0.8145; 1.0550; 0.1624; 0.0633; 0.4330; 0.7168; -0.0299; 0.2004];
    
    FMo = 709.8;
    lMo = 0.0197;
    alphao = 0.3491;
    
    if ~isfield(S.Foot,'FDB_sf_FMo')
        S.Foot.FDB_sf_FMo = 1;
    end
    FDBparameters(1,1) = FMo*S.Foot.FDB_sf_FMo;
    FDBparameters(2,1) = lMo;
    FDBparameters(3,1) = S.Foot.FDB_lTs;
    FDBparameters(4,1) = alphao;
    FDBparameters(5,1) = 10*lMo;
    
    %% Solve for tendon force
    Na = 50;
    Nl = 50;
    a = linspace(0,1,Na)';
    l = linspace(0.95,1.1,Nl)'*ls;
    
    % allocate result matrices
    FT_FDB = zeros(Nl,Na);
    % solver options
    options = optimset('Display','off');
    % initial guess
    FT0 = 0;
    
    for j=1:Na
        for i=1:Nl
            fun = @(FTt) getHilldiffFun(FTt,a(j),l(i),FDBparameters,Fvparam,Fpparam,Faparam,tension,aTendon,shift,pass_shift);
            FTtilde_i = fsolve(fun,FT0,options);
            FT_FDB(i,j) = FTtilde_i*FMo;
            FT0 = FTtilde_i; % warm-start for next length
        end
    end
    
    % casadi function for intrinsic muscle force
    f_PIM_force = interpolant('f_FDB_force','bspline',{a, l},FT_FDB(:));

    %% Solve for tendon force v2

    % Get muscle-tendon forces and derive Hill-equilibrium
    a_SX = SX.sym('a',1);
    FTtilde_SX = SX.sym('FTtilde',1);
    dFTtilde_SX = SX.sym('dFTtilde',1);
    lMT_SX = SX.sym('lMT',1);
    vMT_SX = SX.sym('vMT',1);
    
    [Hilldiff_SX,~,~,~,~,~,~] = ...
        ForceEquilibrium_FtildeState_all_tendon(a_SX,FTtilde_SX,dFTtilde_SX,lMT_SX,...
        vMT_SX,FDBparameters(:,1),Fvparam,Fpparam,Faparam,tension,...
        aTendon,shift,0,pass_shift);

    f_Hilldiff = Function('f_Hilldiff',{FTtilde_SX,a_SX,dFTtilde_SX,lMT_SX,vMT_SX},{Hilldiff_SX});

    % solve equilibrium
    f_FTtilde = rootfinder('f_FTtilde','newton',f_Hilldiff);

    % evaluate FT
    a_MX = MX.sym('a',1);
    FTtilde_sol_MX = MX.sym('FTtilde',1);
    dFTtilde_MX = MX.sym('dFTtilde',1);
    lMT_MX = MX.sym('lMT',1);
    vMT_MX = MX.sym('vMT',1);

    FTtilde_MX = f_FTtilde(FTtilde_sol_MX,a_MX,dFTtilde_MX,lMT_MX,vMT_MX);

    [~,FT_MX,~,~,~,~,~] = ...
        ForceEquilibrium_FtildeState_all_tendon(a_MX,FTtilde_MX,dFTtilde_MX,lMT_MX,...
        vMT_MX,FDBparameters(:,1),Fvparam,Fpparam,Faparam,tension,...
        aTendon,shift,0,pass_shift);

    f_PIM_force_v2 = Function('f_PIM_force_v2',{FTtilde_sol_MX,a_MX,dFTtilde_MX,lMT_MX,vMT_MX},{FT_MX});

    %% casadi function for total force
    a_MX = MX.sym('a',1);
    l_MX = MX.sym('l',1);
    v_MX = MX.sym('v',1);
    FTt_MX = MX.sym('FTt',1);
    dFTt_MX = MX.sym('dFTt',1);

    F_PF = f_PF_stiffness(l_MX)*S.Foot.PF_sf;
%     F_PIM = f_PIM_force([a_MX,l_MX]);
    F_PIM = f_PIM_force_v2(FTt_MX,a_MX,dFTt_MX,l_MX,v_MX);
    F_plantar = F_PF + F_PIM;
    
    plantar_quasi_stiffness = jacobian(F_plantar,l_MX);
    
%     f_plantar_quasi_stiffness = Function('f_plantar_quasi_stiffness',{a_MX,l_MX},{plantar_quasi_stiffness});
    f_plantar_quasi_stiffness = Function('f_plantar_quasi_stiffness',{FTt_MX,a_MX,dFTt_MX,l_MX,v_MX},{plantar_quasi_stiffness});

else
    %% casadi function for total force
    a_MX = MX.sym('a',1);
    l_MX = MX.sym('l',1);
    v_MX = MX.sym('v',1);
    FTt_MX = MX.sym('FTt',1);
    dFTt_MX = MX.sym('dFTt',1);
    
    F_PF = f_PF_stiffness(l_MX)*S.Foot.PF_sf;
    
    F_plantar = F_PF;
    
    plantar_quasi_stiffness = jacobian(F_plantar,l_MX);
    
%     f_plantar_quasi_stiffness = Function('f_plantar_quasi_stiffness',{a_MX,l_MX},{plantar_quasi_stiffness});
    f_plantar_quasi_stiffness = Function('f_plantar_quasi_stiffness',{FTt_MX,a_MX,dFTt_MX,l_MX,v_MX},{plantar_quasi_stiffness});
end




%%
function Hilldiff_fun = getHilldiffFun(FTtilde_fun,a_fun,lMT_fun,params_fun,...
    Fvparam_fun,Fpparam_fun,Faparam_fun,tension_fun,aTendon_fun,shift_fun,pass_shift_fun)

[Hilldiff_fun,~,~,~,~,~,~] = ...
    ForceEquilibrium_FtildeState_all_tendon(a_fun,FTtilde_fun,0,lMT_fun,...
    0,params_fun(:,1),Fvparam_fun,Fpparam_fun,Faparam_fun,tension_fun,...
    aTendon_fun,shift_fun,0,pass_shift_fun);

end

end