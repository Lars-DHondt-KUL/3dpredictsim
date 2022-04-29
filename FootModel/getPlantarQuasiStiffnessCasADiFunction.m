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
    
    %% casadi function for intrinsic muscle force
    f_PIM_force = interpolant('f_FDB_force','bspline',{a, l},FT_FDB(:));

    %% casadi function for total force
    a_MX = MX.sym('a',1);
    l_MX = MX.sym('l',1);
    
    F_PF = f_PF_stiffness(l_MX)*S.Foot.PF_sf;
    F_PIM = f_PIM_force([a_MX,l_MX]);
    
    F_plantar = F_PF + F_PIM;
    
    plantar_quasi_stiffness = jacobian(F_plantar,l_MX);
    
    f_plantar_quasi_stiffness = Function('f_plantar_quasi_stiffness',{a_MX,l_MX},{plantar_quasi_stiffness});

else
    %% casadi function for total force
    a_MX = MX.sym('a',1);
    l_MX = MX.sym('l',1);
    
    F_PF = f_PF_stiffness(l_MX)*S.Foot.PF_sf;
    
    F_plantar = F_PF;
    
    plantar_quasi_stiffness = jacobian(F_plantar,l_MX);
    
    f_plantar_quasi_stiffness = Function('f_plantar_quasi_stiffness',{a_MX,l_MX},{plantar_quasi_stiffness});
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