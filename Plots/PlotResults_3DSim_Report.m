function [] = PlotResults_3DSim_Report(ResultsFile,LegNames,RefData,mtj,makeplot,figNamePrefix)


makeplot.sol_all = 1;
rmse_stance_only = 1;
rmse_swing_only = 0;

div_by_dist_trav = 1;

if strcmp(RefData,'none')
    md = 0;
else
    md = 1;
end

set(0,'defaultTextInterpreter','tex');
set(0,'defaultFigureColor','w')

nr = length(ResultsFile);

if numel(LegNames) >= nr
    LN = 1;
    lgInt = 'tex';
else
    LN = 0;
    lgInt = 'none';
end

joints_ref = {'pelvis_tilt','pelvis_list','pelvis_rotation',...
        'hip_flexion','hip_adduction','hip_rotation',...
        'knee_angle','ankle_angle','subtalar_angle','mtj_angle','tmt_angle','mtp_angle',...
        'lumbar_extension','lumbar_bending','lumbar_rotation',...
        'arm_flex','arm_add','arm_rot','elbow_flex'};

joints_tit = {'Pelvis tilt','Pelvis list','Pelvis rotation','Pelvis tx',...
        'Pelvis ty','Pelvis tz','Hip flexion L','Hip adduction L',...
        'Hip rotation L','Hip flexion R','Hip adduction R','Hip rotation R',...
        'Knee L','Knee R','Ankle L','Ankle R','Subtalar L','Subtalar R',...
        'Midtarsal L','Midtarsal R','Tarsometatarsal L','Tarsometatarsal R',...
        'Metatarsophalangeal L','Metatarsophalangeal R',...
        'Lumbar extension','Lumbar bending','Lumbar rotation',...
        'Arm flexion L','Arm adduction L','Arm rotation L',...
        'Arm flexion R','Arm adduction R','Arm rotation R',...
        'Elbow flexion L','Elbow flexion R'};
        
% prep figures
scs = get(0,'ScreenSize');
fwide = [scs(3)/2, scs(4)/2-100];
fsq = [scs(3)/2, scs(4)*0.6];
fhigh = [scs(3)/2, scs(4)-120];
flong = [scs(3)/2, scs(4)/4];
fhigh1 = [scs(3)*0.4, scs(4)-120];
ffull = [scs(3),scs(4)-120];

fpos = [1,scs(4)/2+20;
        1,40;
        scs(3)/2,40;
        0,40;];

label_fontsize  = 12;
line_linewidth  = 1;
NumTicks = 6;
CsV = hsv(nr);
mrk = {'-',':','-',':'}; % 'LineStyle',mrk{rem(inr,length(mrk))+1}

if nr==2
    CsV = [[0 0 0];[0.8500 0.3250 0.0980]];
end
if nr==3
%     CsV = [[0 0.4470 0.7410];[0.4660 0.6740 0.1880];[0.6350 0.0780 0.1840]];
% %     CsV = [[0.6350 0.0780 0.1840];[0.4660 0.6740 0.1880]; [0 0.4470 0.7410]];
    CsV = [[0.8500 0.3250 0.0980];[0.2 0.2 0.2];[0 0 0]];
    CsV = [[0 0 0];[0.2 0.2 0.2];[0.8500 0.3250 0.0980]];
    mrk = {'-','-.','-'};
end

  
if nr==4
% %     CsV = [[0 0 0];[0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330];[0.8500 0.3250 0.0980]];
    CsV = [[0 0 0];[0.4660 0.6740 0.1880];[0.6350 0.0780 0.1840];[0.3010 0.7450 0.9330]];
%     CsV = [[0 0 0];[0.6350 0.0780 0.1840];[0.3010 0.7450 0.9330];[0.4660 0.6740 0.1880]];
    mrk = {'-','-.','-.',':'}; % 'LineStyle',mrk{rem(inr,length(mrk))+1}
end

for inr=1:nr
    load(ResultsFile{inr},'R');

%     disp(['Color: ' num2str(CsV(inr,:)*255)]);

%     disp([num2str(R.S.Foot.FDB_sf_FMo) '  '  num2str(R.S.IGsel) '  ' num2str(R.COT)])

%     pelvis_ty = R.Qs(:,5);
%     dy = max(pelvis_ty) - min(pelvis_ty);
%     dF = max(R.GRFs(:,2))*(R.body_mass*9.81)/100;
%     K = dF/dy;
%     disp(['leg stiffness = ' num2str(K*1e-3) ' N/mm'])

    if LN
        LegName = LegNames{inr};
    else
        LegName = R.S.savename;
    end
    
    has_no_tmt = 1;
    if isfield(R.S,'Foot')
        has_no_mtj = ~contains(R.S.Foot.Model,'mtj');
    else
        has_no_mtj = sum( contains(R.colheaders.joints,'mtj_angle_r') >0);
    end
    
    if makeplot.plot_bounds
        load([ResultsFile{inr}(1:end-7) '.mat'],'setup');
        scaling_Qs = setup.scaling.Qs;
        bounds_Qs_l = setup.bounds.Qs.lower;
        bounds_Qs_u = setup.bounds.Qs.upper;
        bounds_Qs_l = bounds_Qs_l.*scaling_Qs;
        bounds_Qs_u = bounds_Qs_u.*scaling_Qs;
        scaling_Qdots = setup.scaling.Qdots;
        bounds_Qdots_l = setup.bounds.Qdots.lower;
        bounds_Qdots_u = setup.bounds.Qdots.upper;
        bounds_Qdots_l = bounds_Qdots_l.*scaling_Qdots;
        bounds_Qdots_u = bounds_Qdots_u.*scaling_Qdots;
        scaling_Qddots = setup.scaling.Qdotdots;
        bounds_Qddots_l = setup.bounds.Qdotdots.lower;
        bounds_Qddots_u = setup.bounds.Qdotdots.upper;
        bounds_Qddots_l = bounds_Qddots_l.*scaling_Qddots;
        bounds_Qddots_u = bounds_Qddots_u.*scaling_Qddots;
    end

%% get indices
    imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
    iknee = strcmp(R.colheaders.joints,'knee_angle_r');
    iankle = strcmp(R.colheaders.joints,'ankle_angle_r');
    isubt = strcmp(R.colheaders.joints,'subtalar_angle_r');
    imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));
    ihip1 = find(strcmp(R.colheaders.joints,'hip_flexion_r'));
    ihip2 = find(strcmp(R.colheaders.joints,'hip_adduction_r'));
    ihip3 = find(strcmp(R.colheaders.joints,'hip_rotation_r'));
    iSol = find(strcmp(R.colheaders.muscles,'soleus_r'));
    iGas = find(strcmp(R.colheaders.muscles,'lat_gas_r'));
    iGas2 = find(strcmp(R.colheaders.muscles,'med_gas_r'));
    iTibAnt = find(strcmp(R.colheaders.muscles,'tib_ant_r'));
    iPerL = find(strcmp(R.colheaders.muscles,'per_long_r'));
    iPerB = find(strcmp(R.colheaders.muscles,'per_brev_r'));
    iPerT = find(strcmp(R.colheaders.muscles,'per_tert_r'));
    iTibPo = find(strcmp(R.colheaders.muscles,'tib_post_r'));
    if isempty(iGas)
        iGas = find(strcmp(R.colheaders.muscles,'gaslat_r'));
    end
    if isempty(iGas2)
        iGas2 = find(strcmp(R.colheaders.muscles,'gasmed_r'));
    end

    itriceps = [iSol,iGas,iGas2];

    ifd = find(strcmp(R.colheaders.muscles,'flex_dig_r'));
    ifh = find(strcmp(R.colheaders.muscles,'flex_hal_r'));
    ied = find(strcmp(R.colheaders.muscles,'ext_dig_r'));
    ieh = find(strcmp(R.colheaders.muscles,'ext_hal_r'));
    iFDB = find(strcmp(R.colheaders.muscles,'FDB_r'));

    ihamstrings(1) = find(strcmp(R.colheaders.muscles,'semimem_r'));
    ihamstrings(2) = find(strcmp(R.colheaders.muscles,'semiten_r'));
    ihamstrings(3) = find(strcmp(R.colheaders.muscles,'bifemlh_r'));
    ihamstrings(4) = find(strcmp(R.colheaders.muscles,'bifemsh_r'));
    
    iquadriceps_femoris(1) = find(strcmp(R.colheaders.muscles,'rect_fem_r'));
    iquadriceps_femoris(2) = find(strcmp(R.colheaders.muscles,'vas_med_r'));
    iquadriceps_femoris(3) = find(strcmp(R.colheaders.muscles,'vas_int_r'));
    iquadriceps_femoris(4) = find(strcmp(R.colheaders.muscles,'vas_lat_r'));
    
    igluteus_maximus(1) = find(strcmp(R.colheaders.muscles,'glut_max1_r'));
    igluteus_maximus(2) = find(strcmp(R.colheaders.muscles,'glut_max2_r'));
    igluteus_maximus(3) = find(strcmp(R.colheaders.muscles,'glut_max3_r'));
    
    igluteus_medius(1) = find(strcmp(R.colheaders.muscles,'glut_med1_r'));
    igluteus_medius(2) = find(strcmp(R.colheaders.muscles,'glut_med2_r'));
    igluteus_medius(3) = find(strcmp(R.colheaders.muscles,'glut_med3_r'));
    
    igluteus_minimus(1) = find(strcmp(R.colheaders.muscles,'glut_min1_r'));
    igluteus_minimus(2) = find(strcmp(R.colheaders.muscles,'glut_min2_r'));
    igluteus_minimus(3) = find(strcmp(R.colheaders.muscles,'glut_min3_r'));

    dist_trav = R.Qs(end,strcmp(R.colheaders.joints,'pelvis_tx')) - ...
                R.Qs(1,strcmp(R.colheaders.joints,'pelvis_tx'));

    body_mass = R.body_mass;
    
    %% calculate power and work

    x = 1:(100-1)/(size(R.Qs,1)-1):100;
    istance = 1:1:min(ceil(R.Event.Stance/100*length(x))+length(x)/10,length(x));
    ipush_off = find(R.GRFs_separate(:,2)<5 & R.GRFs_separate(:,14)>5);
    istance0 = 1:1:ceil(R.Event.Stance/100*length(x));
    iswing = istance0(end)+1:length(x);
    xst_10 = linspace(1,110,length(istance));
    xst = linspace(1,100,length(istance0));

    iheel_contact = find(R.GRFs_separate(:,2)>3);
    iff_contact = find(R.GRFs_separate(:,8)>1 | R.GRFs_separate(:,11)>1);
    itoe_contact = find(R.GRFs_separate(:,14)>1);
    iheel_contact = iheel_contact(iheel_contact(2:end)<iheel_contact(1:end-1)+5);

    P_hip = ( R.Qdots(:,ihip1)*pi/180.*R.Tid(:,ihip1) +...
        R.Qdots(:,ihip2)*pi/180.*R.Tid(:,ihip2) +...
        R.Qdots(:,ihip3)*pi/180.*R.Tid(:,ihip3) )/R.body_mass;

    P_knee = R.Qdots(:,iknee)*pi/180.*R.Tid(:,iknee)/R.body_mass;
    P_ankle = R.Qdots(:,iankle)*pi/180.*R.Tid(:,iankle)/R.body_mass;
    P_subt = R.Qdots(:,isubt)*pi/180.*R.Tid(:,isubt)/R.body_mass;
    P_mtp = R.Qdots(:,imtp)*pi/180.*R.Tid(:,imtp)/R.body_mass;

    W_knee = zeros(size(P_knee));
    W_ankle = zeros(size(P_ankle));
    W_subt = zeros(size(P_subt));
    W_mtp = zeros(size(P_mtp));

    for iw=2:length(x)
       W_knee(iw) = trapz(R.t(1:iw),P_knee(1:iw));
       W_ankle(iw) = trapz(R.t(1:iw),P_ankle(1:iw));
       W_subt(iw) = trapz(R.t(1:iw),P_subt(1:iw));
       W_mtp(iw) = trapz(R.t(1:iw),P_mtp(1:iw));
    end

    qdot_mtp = R.Qdots(:,imtp)*pi/180;

    if ~isempty(imtj)
        P_mtj = R.Qdots(:,imtj)*pi/180.*R.Tid(:,imtj)/R.body_mass;
        W_mtj = zeros(size(P_mtj));

        if isfield(R.windlass,'F_PIM')
            F_PIM = R.windlass.F_PIM(:,2);
        elseif ~isempty(iFDB)
            F_PIM = R.FT(:,iFDB(1));
        else
            F_PIM = zeros(size(P_mtj));
        end

        qdot_mtj = R.Qdots(:,imtj)*pi/180;
        if ~strcmp(R.S.Foot.PF_stiffness,'none')
            l_PF = R.windlass.l_PF;
            F_PF = R.windlass.F_PF;

            
            M_mtj_li = R.windlass.M_li;
            M_mtj_PF = R.windlass.MA_PF.mtj.*F_PF;
            M_mtj_PIM = R.windlass.MA_PF.mtj.*F_PIM;
            M_mtp_PF = R.windlass.MA_PF.mtp.*F_PF;
            M_mtp_PIM = R.windlass.MA_PF.mtp.*F_PIM;
            
            v_PF = R.windlass.v_PF;

        else
            l_PF = zeros(size(P_mtp));
            F_PF = l_PF;

            M_mtj_li =l_PF;
            M_mtj_PF = F_PF;
            M_mtj_PIM = F_PIM;
            M_mtp_PF = F_PF;
            M_mtp_PIM = F_PF;

            v_PF = l_PF;
        end
            
        
 
        
        
        P_PF = -v_PF.*F_PF/R.body_mass;
        P_PIM = -v_PF.*F_PIM/R.body_mass;
        P_mtj_li = qdot_mtj.*M_mtj_li/R.body_mass;
        P_mtj_PF = qdot_mtj.*M_mtj_PF/R.body_mass;
        P_mtj_PIM = qdot_mtj.*M_mtj_PIM/R.body_mass;
        P_mtp_PF = R.Qdots(:,imtp)*pi/180.*M_mtp_PF/R.body_mass;
        P_mtp_PIM = R.Qdots(:,imtp)*pi/180.*M_mtp_PIM/R.body_mass;

        W_PF = zeros(size(P_PF));
        W_li = zeros(size(P_mtj_li));
        W_mtp_WL = zeros(size(P_mtp_PF));

        for iw=2:length(x)
            W_PF(iw) = trapz(R.t(1:iw),P_PF(1:iw));
            W_li(iw) = trapz(R.t(1:iw),P_mtj_li(1:iw));
            W_mtp_WL(iw) = trapz(R.t(1:iw),P_mtp_PF(1:iw));
            W_mtj(iw) = trapz(R.t(1:iw),P_mtj(1:iw));
        end


    else
        P_PF = zeros(size(P_mtp));
        P_PIM = zeros(size(P_mtp));
        P_mtj = zeros(size(P_mtp));
        P_mtj_li = P_mtj;
        P_mtj_PF = zeros(size(P_mtp));
        P_mtj_PIM = zeros(size(P_mtp));
        P_mtp_PF = zeros(size(P_mtp));
        P_mtp_PIM = zeros(size(P_mtp));
        W_mtj = zeros(size(W_mtp));
    end

    P_joints = P_mtj + P_ankle + P_subt + P_mtp;
    W_joints = W_mtj + W_ankle + W_subt + W_mtp;

    if isfield(R,'vT')
       P_T_Sol = -R.FT(:,iSol).*R.vT(:,iSol)/R.body_mass;
       P_T_Gas = -R.FT(:,iGas).*R.vT(:,iGas)/R.body_mass;
       P_T_Gas2 = -R.FT(:,iGas2).*R.vT(:,iGas2)/R.body_mass;

       W_T_Sol = zeros(size(P_T_Sol));
       W_T_Gas = zeros(size(P_T_Sol));
       W_T_Gas2 = zeros(size(P_T_Sol));

       for iw=2:length(xst_10)
            W_T_Sol(iw) = trapz(R.t(1:iw),P_T_Sol(1:iw));
            W_T_Gas(iw) = trapz(R.t(1:iw),P_T_Gas(1:iw));
            W_T_Gas2(iw) = trapz(R.t(1:iw),P_T_Gas2(1:iw));
       end

    end

    P_M_Sol = R.MetabB.Wdot(:,iSol)/R.body_mass;
    P_M_Gas = R.MetabB.Wdot(:,iGas)/R.body_mass;
    P_M_Gas2 = R.MetabB.Wdot(:,iGas2)/R.body_mass;

    P_E_Sol = R.MetabB.Etot(:,iSol)/R.body_mass;
    P_E_Gas = R.MetabB.Etot(:,iGas)/R.body_mass;
    P_E_Gas2 = R.MetabB.Etot(:,iGas2)/R.body_mass;

    P_M_hamstrings = sum(R.MetabB.Wdot(:,ihamstrings),2)/R.body_mass;
    P_M_quadriceps_femoris = sum(R.MetabB.Wdot(:,iquadriceps_femoris),2)/R.body_mass;
    
    P_M_triceps_knee = sum(R.FT(:,itriceps).*squeeze(R.dM(:,itriceps,4)).*R.Qdots(:,iknee)*pi/180,2)/R.body_mass;
    P_M_triceps_ankle = sum(R.FT(:,itriceps).*squeeze(R.dM(:,itriceps,5)).*R.Qdots(:,iankle)*pi/180,2)/R.body_mass;

    W_M_Sol = zeros(size(P_M_Sol));
    W_M_Gas = zeros(size(P_M_Sol));
    W_M_Gas2 = zeros(size(P_M_Sol));

    for iw=2:length(x)
        W_M_Sol(iw) = trapz(R.t(1:iw),P_M_Sol(1:iw));
        W_M_Gas(iw) = trapz(R.t(1:iw),P_M_Gas(1:iw));
        W_M_Gas2(iw) = trapz(R.t(1:iw),P_M_Gas2(1:iw));
    end

    P_HC_heel = R.P_mech_contact.vertical.calcn.r/R.body_mass;
    P_HC_ball = R.P_mech_contact.vertical.metatarsi.r/R.body_mass;
    P_HC_toes = R.P_mech_contact.vertical.toes.r/R.body_mass;
    P_HC = P_HC_heel + P_HC_ball + P_HC_toes;

    P_dist_hindfoot = P_mtp + P_mtj + P_HC;
    P_dist_forefoot = P_mtp + P_HC_ball + P_HC_toes;
    P_dist_hallux = P_HC_toes;

    W_HC_heel = zeros(size(P_HC));
    W_HC_ball = zeros(size(P_HC));
    W_HC_toes = zeros(size(P_HC));

    for iw=2:length(x)
        W_HC_heel(iw) = trapz(R.t(1:iw),R.P_mech_contact.vertical.calcn.r(1:iw))/R.body_mass;
        W_HC_ball(iw) = trapz(R.t(1:iw),R.P_mech_contact.vertical.metatarsi.r(1:iw))/R.body_mass;
        W_HC_toes(iw) = trapz(R.t(1:iw),R.P_mech_contact.vertical.toes.r(1:iw))/R.body_mass;
    end

    W_HC = W_HC_heel + W_HC_ball + W_HC_toes;
    P_tot = P_HC + P_joints;
    W_tot = W_HC + W_joints;
    P_leg_joints = P_hip + P_knee + P_ankle + P_subt + P_mtj + P_mtp;

    % impulse
    p_GRF = trapz(R.t,vecnorm(R.GRFs(:,1:3),2,2));
    p_mtj = trapz(R.t,R.Tid(:,imtj));

    
%%

    if inr==1 && md
        
        if contains(RefData,'Hamner')
            refName = RefData;
            t_mp = strfind(refName,'_');
            refName(t_mp) = ' ';

            load('C:\Users\u0150099\Documents\master_thesis\ReferenceData\ExperimentalData.mat','ExperimentalData')
            Qref.Qall_mean = ExperimentalData.Q.(RefData).Qs.mean;
            Qref.Qall_std = ExperimentalData.Q.(RefData).Qs.std;
            Qref.colheaders = ExperimentalData.Q.(RefData).Qs.colheaders;

            Tref.Tall_mean = ExperimentalData.Torques.(RefData).mean;
            Tref.Tall_std = ExperimentalData.Torques.(RefData).std;
            Tref.colheaders = ExperimentalData.Torques.(RefData).colheaders;

            Data.GRF.Fmean = ExperimentalData.GRFs.(RefData).mean;
            Data.GRF.Fstd = ExperimentalData.GRFs.(RefData).std;

        elseif contains(RefData,'Poggensee')
            refName = 'Poggensee';
            load('C:\Users\u0150099\OneDrive - KU Leuven\WTK\thesis\model\3dpredictsim\Data/Pog_s1.mat','Dat')

            Qref.Qall_mean = Dat.Normal.gc.Qall_mean*180/pi;
            Qref.Qall_std = Dat.Normal.gc.Qall_std*180/pi;
            Qref.colheaders = Dat.Normal.gc.colheaders;

            Tref.Tall_mean = Dat.Normal.gc.Tall_mean;
            Tref.Tall_std = Dat.Normal.gc.Tall_std;
            Tref.colheaders = Dat.Normal.gc.colheaders;
        
            Data.GRF.Fmean = Dat.Normal.gc.GRF.Fmean*65;
            Data.GRF.Fstd = Dat.Normal.gc.GRF.Fstd*65;

        else
            refName = 'Falisse';
            [pathHere,~,~] = fileparts(mfilename('fullpath'));
            [pathRepo,~,~] = fileparts(pathHere);
            load([pathRepo '\Data\Fal_s1.mat'],'Data');
            
    %         data_field = ['IK_' R.S.Foot.Model '_' R.S.Foot.Scaling];
            data_field = ['IK_' RefData(8:end)];
            if isfield(Data,data_field)
                Qref = Data.(data_field);
            else
                disp(['No experimental data found for "' RefData '"'])
                Qref = Data.IK_original;
            end
    
    %         data_field = ['ID_' R.S.Foot.Model '_' R.S.Foot.Scaling];
            data_field = ['ID_' RefData(8:end)];
            if isfield(Data,data_field)
                Tref = Data.(data_field);
            else
                Tref = Data.ID_original;
            end
    
            data_field = ['P_' RefData(8:end)];
            if isfield(Data,data_field)
                Pref = Data.(data_field);
            else
                Pref = Data.ID_original;
            end

            stance_ref_mean = 64.3;
            istance0_ref = 1:round(stance_ref_mean);

        end

    end
    
    Cs = CsV(inr,:);
    
    if inr==1
        hleg = figure('Position',[fpos(3,1),500,fwide]);
        tiledlayout('flow')
        nexttile(1)
        hold on
        plot(inr,R.COT,'o','Color',Cs,'MarkerFaceColor',Cs,'DisplayName',LegName);
        lh=legend('location','northeast','Interpreter',lgInt);
        if LN
            lh.Interpreter = 'Tex';
        else
            lh.Interpreter = 'none';
        end
%         lhPos = lh.Position;
%         lhPos(1) = lhPos(1)+0.38;
%         lhPos(2) = lhPos(2)-0.34;
%         set(lh,'position',lhPos);
        lh.Layout.Tile = 'south';
        title(lh,'Legend')
        title('Cost of transport')
        ylabel('\fontsize{10} COT (J kg^-^1 m^-^1)','Interpreter','tex')
        tmp=gca;
        tmp.XTickLabel = '';
        xlim([0,nr+1])
        grid on
    else
        figure(hleg)
        nexttile(1)
        hold on
        plot(inr,R.COT,'o','Color',Cs,'MarkerFaceColor',Cs,'DisplayName',LegName);  
    end
    
    COT_all(inr) = R.COT;
    
    
    x = 1:(100-1)/(size(R.Qs,1)-1):100;

    %% kinematics
    if makeplot.kinematics_Qs
    
        if inr==1
            h1 = figure('Position',[fpos(1,:),fwide]);
        else
            figure(h1);
        end

        idx_js = [4,5,7,8,9,10,12]; % colheaders mocap
        idx_sp = [1,2,3,5,6,7,8]; % subplots to use
        
        if has_no_tmt && has_no_mtj
            idx_Qs = [10,11,14,16,18,20]; % Qs in result file
        else
            idx_Qs = [10,11,14,16,18,20,22];
        end
        
        if mtj==1
            idx_title = [10,11,14,16,18,20,24]; % names for title
        elseif mtj==0
            idx_title = [10,11,14,16,18,22,24];
        else
            idx_title = [10,11,14,16,18,24];
            idx_js = [4,5,7,8,9,12]; % colheaders mocap
            idx_sp = [1,2,3,5,6,7]; % subplots to use
        end
        
        x = 1:(100-1)/(size(R.Qs,1)-1):100;

        j = 0;
        label_fontsize  = 12;
        line_linewidth  = 0.5;
        NumTicks = 6;
        for i = 1:length(idx_title)
            subplot(2,4,idx_sp(i))
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            % Experimental data
            if  inr == 1 && md
                idx_jref = strcmp(Qref.colheaders,joints_ref{idx_js(i)});
                if sum(idx_jref) ~= 1
                    idx_jref = strcmp(Qref.colheaders,[joints_ref{idx_js(i)} '_r']);
                end
                if sum(idx_jref) == 1
                    meanPlusSTD = (Qref.Qall_mean(:,idx_jref) + 2*Qref.Qall_std(:,idx_jref));
                    meanMinusSTD = (Qref.Qall_mean(:,idx_jref) - 2*Qref.Qall_std(:,idx_jref));

                    stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                    intervalQ = 1:stepQ:size(R.Qs,1);
                    sampleQ = 1:size(R.Qs,1);
                    meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                    meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

                    hold on
                    fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName',['MoCap ' refName]);
                    alpha(.25);
                end
            end

            % Simulation results
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            hold on;
            if (has_no_tmt && strcmp(joints_tit{idx_title(i)},'Tarsometatarsal R')) || ...
                    (has_no_mtj && strcmp(joints_tit{idx_title(i)},'Midtarsal R'))
                % skip this plot
            else
                j=j+1;
                plot(x,R.Qs(:,idx_Qs(j)),'linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',LegName); % ,'LineStyle',mrk{rem(inr,length(mrk))+1}

            end

            % Plot settings
            if inr == nr
                set(gca,'Fontsize',label_fontsize);
                ttl_tmp = joints_tit{idx_title(i)};
                title(ttl_tmp(1:end-2),'Fontsize',label_fontsize);
                % Y-axis
                if i == 1 || i == 4
                    ylabel('Angle (°)','Fontsize',label_fontsize);
                end
                % X-axis
                L = get(gca,'XLim');
%                 set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if i > 3
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])
            end
            if i == 3
                lh1=legend('location','northwest','Interpreter',lgInt);
                lhPos = lh1.Position;
                lhPos(1) = lhPos(1)+0.17;
%                 lhPos(2) = lhPos(2)+0.1;
%                 lh1.Box='off';
                set(lh1,'position',lhPos);
            end
        end
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h1,'PaperPositionMode','auto')
            print(h1,[figNamePrefix '_qs'],'-dpng','-r0')
% %             print(h1,[figNamePrefix '_qs'],'-depsc')
        end

    end
    if makeplot.kinematics_Qdots
        % qdots
        
        if inr==1
            h1a = figure('Position',[fpos(1,:),fwide]);
        else
            figure(h1a);
        end
        j = 0;
        label_fontsize  = 12;
        line_linewidth  = 0.5;
        NumTicks = 6;
        for i = 1:length(idx_title)
            subplot(2,4,idx_sp(i))
            x = 1:(100-1)/(size(R.Qdots,1)-1):100;
            % Experimental data
            if  inr == 1 && md
                idx_jref = strcmp(Qref.colheaders,joints_ref{idx_js(i)});
                if sum(idx_jref) ~= 1
                    idx_jref = strcmp(Qref.colheaders,[joints_ref{idx_js(i)} '_r']);
                end
                if sum(idx_jref) == 1
                    meanPlusSTD = (Qref.Qdotall_mean(:,idx_jref) + 2*Qref.Qdotall_std(:,idx_jref));
                    meanMinusSTD = (Qref.Qdotall_mean(:,idx_jref) - 2*Qref.Qdotall_std(:,idx_jref));

                    stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                    intervalQ = 1:stepQ:size(R.Qs,1);
                    sampleQ = 1:size(R.Qs,1);
                    meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                    meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

                    hold on
                    fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName',['MoCap ' refName]);
                    alpha(.25);
                end
            end

            % Simulation results
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            hold on;
            if (has_no_tmt && strcmp(joints_tit{idx_title(i)},'Tarsometatarsal R')) || ...
                    (has_no_mtj && strcmp(joints_tit{idx_title(i)},'Midtarsal R'))
                % skip this plot
            else
                j=j+1;
                plot(x,R.Qdots(:,idx_Qs(j)),'linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',LegName);

            end

            % Plot settings
            if inr == nr
                set(gca,'Fontsize',label_fontsize);
                ttl_tmp = joints_tit{idx_title(i)};
                title(ttl_tmp(1:end-2),'Fontsize',label_fontsize);
                % Y-axis
                if i == 1 || i == 4
                    ylabel('Angular velocity (°/s)','Fontsize',label_fontsize);
                end
                % X-axis
                L = get(gca,'XLim');
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if i > 3
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])
            end
            if i == 3
%                 lh1=legend('-DynamicLegend','location','northwest');
%                 lh1.Interpreter = 'tex';
%                 lhPos = lh1.Position;
%                 lhPos(1) = lhPos(1)+0.17;
% %                 lhPos(2) = lhPos(2)+0.1;
% %                 lh1.Box='off';
%                 set(lh1,'position',lhPos);
            end
        end
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h1a,'PaperPositionMode','auto')
            print(h1a,[figNamePrefix '_qdots'],'-dpng','-r0')
% %             print(h1a,[figNamePrefix '_qdots'],'-depsc')
        end
    end
    
    
    %% kinetics
    if makeplot.kinetics
        
        if inr==1
            h2 = figure('Position',[fpos(2,:),fwide]);
        else
            figure(h2);
        end

        idx_js = [4,5,7,8,9,10,12]; % colheaders mocap
        idx_sp = [1,2,3,5,6,7,8]; % subplots to use
        
        if has_no_tmt && has_no_mtj
            idx_Qs = [10,11,14,16,18,20]; % Qs in result file
        else
            idx_Qs = [10,11,14,16,18,20,22];
        end
        
        if mtj==1
            idx_title = [10,11,14,16,18,20,24]; % names for title
        elseif mtj==0
            idx_title = [10,11,14,16,18,22,24];
        else
            idx_title = [10,11,14,16,18,24];
            idx_js = [4,5,7,8,9,12]; % colheaders mocap
            idx_sp = [1,2,3,5,6,7]; % subplots to use
        end
        
        x = 1:(100-1)/(size(R.Qs,1)-1):100;

        j = 0;
        label_fontsize  = 12;
        line_linewidth  = 0.5;
        for i = 1:length(idx_title)
            subplot(2,4,idx_sp(i))
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            % Experimental data
            if  inr == 1 && md
                idx_jref = strcmp(Tref.colheaders,joints_ref{idx_js(i)});
                if sum(idx_jref) ~= 1
                    idx_jref = strcmp(Qref.colheaders,[joints_ref{idx_js(i)} '_r']);
                end
                no_ID = contains(joints_ref{idx_js(i)},'mtj') || contains(joints_ref{idx_js(i)},'mtp');
                if sum(idx_jref) == 1 && ~no_ID
                    meanPlusSTD = Tref.Tall_mean(:,idx_jref) + 2*Tref.Tall_std(:,idx_jref);
                    meanMinusSTD = Tref.Tall_mean(:,idx_jref) - 2*Tref.Tall_std(:,idx_jref);
                    stepID = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                    intervalID = 1:stepID:size(R.Qs,1);
                    sampleID = 1:size(R.Qs,1);
                    meanPlusSTD = interp1(intervalID,meanPlusSTD,sampleID);
                    meanMinusSTD = interp1(intervalID,meanMinusSTD,sampleID);
                    hold on
                    fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName',['MoCap ' refName]);
                    alpha(.25);
                end
            end

            % Simulation results
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            hold on;
            if (has_no_tmt && strcmp(joints_tit{idx_title(i)},'Tarsometatarsal R')) || ...
                    (has_no_mtj && strcmp(joints_tit{idx_title(i)},'Midtarsal R'))
                % skip this plot
            else
                j=j+1;
                plot(x,R.Tid(:,idx_Qs(j)),'linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',LegName);

            end
            % Plot settings
            if inr == nr
                % Plot settings
                set(gca,'Fontsize',label_fontsize);
                ttl_tmp = joints_tit{idx_title(i)};
                title(ttl_tmp(1:end-2),'Fontsize',label_fontsize);
                % Y-axis
                if i == 1 || i == 4
                    ylabel('Torque (Nm)','Fontsize',label_fontsize);
                end
                % X-axis
                L = get(gca,'XLim');
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if i > 3
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])

            end
            if i == 3
                lh2=legend('-DynamicLegend','location','northwest');
                lh2.Interpreter = lgInt;
                lhPos = lh2.Position;
                lhPos(1) = lhPos(1)+0.15;
%                 lhPos(2) = lhPos(2)+0.1;
                set(lh2,'position',lhPos);
            end
        end
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h2,'PaperPositionMode','auto')
            print(h2,[figNamePrefix '_Ts'],'-dpng','-r0')
% %             print(h2,[figNamePrefix '_Ts'],'-depsc')
        end
    end
    
    
    %% soleus
    
        
    if makeplot.ankle_musc
        
        if inr==1
            if makeplot.sol_all
                h3 = figure('Position',[fpos(3,:),fhigh]);
            else
                h3 = figure('Position',[fpos(3,:),fwide]);
            end
        else
            figure(h3);
        end

        n_msc = 8;
        nn_msc = 4;
%         nn_msc = 6;

        if inr==1 && md 
            iSol_data = find(strcmp(Data.EMGheaders,'Soleus'));
            iGas_data = find(strcmp(Data.EMGheaders,'Gastrocnemius-medialis'));
            iGas2_data = find(strcmp(Data.EMGheaders,'Gastrocnemius-lateralis'));
            iTibAnt_data = find(strcmp(Data.EMGheaders,'Tibialis-anterior'));
            iPerL_data = find(strcmp(Data.EMGheaders,'Peroneus-longus'));
            iPerB_data = find(strcmp(Data.EMGheaders,'Peroneus-brevis'));
            
            ankle_act(:,1) = Data.lowEMG_mean([51:end,1:50],iSol_data);
            ankle_act(:,2) = Data.lowEMG_mean([51:end,1:50],iGas_data);
            ankle_act(:,3) = Data.lowEMG_mean([51:end,1:50],iGas2_data);
            ankle_act(:,4) = Data.lowEMG_mean([51:end,1:50],iTibAnt_data);
            ankle_act(:,5) = Data.lowEMG_mean([51:end,1:50],iPerL_data);
            ankle_act(:,6) = Data.lowEMG_mean([51:end,1:50],iPerB_data);

            imusd = [iSol_data,iGas_data,iGas2_data,iTibAnt_data,iPerL_data,iPerB_data];
            ankle_a = [ankle_act(ceil(end/2):end,:); ankle_act(1:ceil(end/2)-1,:)];
            
            ankle_a = interp1(1:100,ankle_a,x);
            
%             nn_msc = length(imusd);%+2;
            nn_msc = 4;

            
            for imu=1:nn_msc
                subplot(n_msc,nn_msc,imu); hold on;
                yyaxis right
                hold on
                meanPlusSTD = Data.lowEMG_mean(:,imusd(imu)) + 2*Data.lowEMG_std(:,imusd(imu));
                meanMinusSTD = Data.lowEMG_mean(:,imusd(imu)) - 2*Data.lowEMG_std(:,imusd(imu));
                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);
                p1=fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],[1,1,1]*0.8,'DisplayName','EMG data');
                alpha(.25)
                set(gca,'XTick',[0:20:100])
                plot(x,ankle_a(:,imu),'-k','DisplayName','mean EMG data')
                a1 = gca;
                a1.YColor = [0,0,0];
                if imu==1
                    lg_a = [p1];
                end
                if imu==nn_msc-2
                    ylabel('EMG (mV)')
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])
                yyaxis left
                a1 = gca;
                a1.YColor = [0,0,0];
            end
            
        end
        NumTicks = 6;
        imus = [iSol,iGas,iGas2,iTibAnt,iPerL,iPerB,iPerT,iTibPo];

        for imu=1:nn_msc
            
            subplot(n_msc,nn_msc,imu); hold on;
            hold on
            p2=plot(x,R.a(:,imus(imu)),'-','Color',CsV(inr,:),'DisplayName',LegName);
            hold on
            title(R.colheaders.muscles{imus(imu)},'Interpreter','none')
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
                if imu==1
                    ylabel('Activity (-)','Interpreter','latex');
                    if md
                        lg_a(end+1) = p2;
                    else
                        lg_a = [p2];
                    end
                    if inr==nr
                        lh3=legend(lg_a,'location','northwest');
                        lh3.Interpreter = lgInt;
                        lh3.Orientation = 'horizontal';
                    end
                end
            subplot(n_msc,nn_msc,nn_msc+imu)
            plot(x,R.FT(:,imus(imu)),'-','Color',CsV(inr,:),'DisplayName',LegName);
            hold on
            grid on
            
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$F^T$ (N)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([0,yl(2)+0.15*norm(yl)])
            xlim([0,100])

            subplot(n_msc,nn_msc,2*nn_msc+imu)
            plot(x,R.MetabB.Etot(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
            hold on
            grid on
            
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$\dot{E}$ (W)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])

            if makeplot.sol_all
                subplot(n_msc,nn_msc,3*nn_msc+imu)
                plot(x,R.MetabB.Wdot(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
                hold on
                grid on
                L = get(gca,'XLim');
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if imu==1
                    ylabel('$\dot{W}$ (W)','Interpreter','latex');
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.15*norm(yl),yl(2)+0.15*norm(yl)])
                xlim([0,100])

                if isfield(R,'vT')

                    subplot(n_msc,nn_msc,4*nn_msc+imu)
                    plot(x,-R.FT(:,imus(imu)).*R.vT(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
                    hold on
                    grid on

                    L = get(gca,'XLim');
                    set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                    if imu==1
                        ylabel('$P^T$ (W)','Interpreter','latex');
                    end
                    axis tight
                    yl = get(gca, 'ylim');
                    ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                    xlim([0,100])
                end

                subplot(n_msc,nn_msc,5*nn_msc+imu)
                plot(x,R.lMtilde(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
                hold on
                grid on
                L = get(gca,'XLim');
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if imu==1
                    ylabel('$\tilde{l}^M$ (-)','Interpreter','latex');
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.05*norm(yl),yl(2)+0.02*norm(yl)])
                xlim([0,100])

%                 subplot(n_msc,nn_msc,6*nn_msc+imu)
%                 plot(R.vMtilde(:,imus(imu)),'Color',CsV(inr,:),'DisplayName',LegName);
%                 hold on
%                 grid on
%                 L = get(gca,'XLim');
%                 set(gca,'XTick',linspace(L(1),L(2),NumTicks))
%                 if imu==1
%                     ylabel('$\dot{\tilde{l}^M}$ (-)','Interpreter','latex');
%                 end
%                 axis tight
%                 yl = get(gca, 'ylim');
%                 ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
%                 xlim([0,100])

                subplot(n_msc,nn_msc,6*nn_msc+imu)
                plot(x,R.Muscle.vM(:,imus(imu)),'Color',CsV(inr,:),'DisplayName',LegName);
                hold on
                grid on
                L = get(gca,'XLim');
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if imu==1
                    ylabel('$v^M$ (m/s)','Interpreter','latex');
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])

                subplot(n_msc,nn_msc,7*nn_msc+imu)
                plot(x,R.lMT(:,imus(imu)),'Color',CsV(inr,:),'DisplayName',LegName);
                hold on
                grid on
                L = get(gca,'XLim');
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if imu==1
                    ylabel('$l^{MT}$ (m)','Interpreter','latex');
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.01*norm(yl),yl(2)+0.01*norm(yl)])
                xlim([0,100])

            end
            
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
        end
        
        if inr==nr
            lhPos = lh3.Position;
%             lhPos(1) = lhPos(1)-0.12;
            if makeplot.sol_all
                lhPos(2) = lhPos(2)+0.08;
            else
                lhPos(2) = lhPos(2)+0.1;
            end
            set(lh3,'position',lhPos);
        end
            
        
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h3,'PaperPositionMode','auto')
            if makeplot.sol_all
                print(h3,[figNamePrefix '_calf_all'],'-dpng','-r0')
% %                 print(h3,[figNamePrefix '_calf_all'],'-depsc')
            else
                print(h3,[figNamePrefix '_calf'],'-dpng','-r0')
% %                 print(h3,[figNamePrefix '_calf'],'-depsc')
            end
        end
    end
    
    
    %%
    if makeplot.ankle_musc2
        
        if inr==1
            h3a = figure('Position',[fpos(2,:),fhigh]);

        else
            figure(h3a);
        end

        n_msc = 8;
%         nn_msc = 6;

        if inr==1 && md 

            iPerL_data = find(strcmp(Data.EMGheaders,'Peroneus-longus'));
            iPerB_data = find(strcmp(Data.EMGheaders,'Peroneus-brevis'));
            
            ankle2_act(:,1) = Data.lowEMG_mean(:,iPerL_data);
            ankle2_act(:,2) = Data.lowEMG_mean(:,iPerB_data);

            imusd = [iPerL_data,iPerB_data];

            
            
%             nn_msc = length(imusd);%+2;
            nn_msc = 4;

            
            for imu=1:length(imusd)
                subplot(n_msc,nn_msc,imu); hold on;
                yyaxis right
                hold on
                meanPlusSTD = Data.lowEMG_mean(:,imusd(imu)) + 2*Data.lowEMG_std(:,imusd(imu));
                meanMinusSTD = Data.lowEMG_mean(:,imusd(imu)) - 2*Data.lowEMG_std(:,imusd(imu));
                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);
                p1=fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],[1,1,1]*0.8,'DisplayName','EMG data');
                alpha(.25)
                set(gca,'XTick',[0:20:100])
                plot(ankle2_act(:,imu),'-k','DisplayName','mean EMG data')
                a1 = gca;
                a1.YColor = [0,0,0];
                if imu==1
                    lg_aa = [p1];
                end
                if imu==nn_msc-2
                    ylabel('EMG (mV)')
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])
                yyaxis left
                a1 = gca;
                a1.YColor = [0,0,0];
            end
            
        end
        NumTicks = 6;
        imus = [iPerL,iPerB,iPerT,iTibPo];

        for imu=1:nn_msc
            
            subplot(n_msc,nn_msc,imu); hold on;
            hold on
            p2=plot(x,R.a(:,imus(imu)),'-','Color',CsV(inr,:),'DisplayName',LegName);
            hold on
            title(R.colheaders.muscles{imus(imu)},'Interpreter','none')
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])
                if imu==1
                    ylabel('Activity (-)','Interpreter','latex');
                    if md
                        lg_aa(end+1) = p2;
                    else
                        lg_aa = [p2];
                    end
                    if inr==nr
                        lh3a=legend(lg_aa,'location','northwest');
                        lh3a.Interpreter = lgInt;
                        lh3a.Orientation = 'horizontal';
                    end
                end
            subplot(n_msc,nn_msc,nn_msc+imu)
            plot(x,R.FT(:,imus(imu)),'-','Color',CsV(inr,:),'DisplayName',LegName);
            hold on
            grid on
            
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$F^T$ (N)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([0,yl(2)+0.15*norm(yl)])
            xlim([0,100])

            subplot(n_msc,nn_msc,2*nn_msc+imu)
            plot(x,R.MetabB.Etot(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
            hold on
            grid on
            
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$\dot{E}$ (W)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])


            subplot(n_msc,nn_msc,3*nn_msc+imu)
            plot(x,R.MetabB.Wdot(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
            hold on
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$\dot{W}$ (W)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.15*norm(yl),yl(2)+0.15*norm(yl)])
            xlim([0,100])

            if isfield(R,'vT')

                subplot(n_msc,nn_msc,4*nn_msc+imu)
                plot(x,-R.FT(:,imus(imu)).*R.vT(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
                hold on
                grid on

                L = get(gca,'XLim');
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if imu==1
                    ylabel('$P^T$ (W)','Interpreter','latex');
                end
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])
            end

            subplot(n_msc,nn_msc,5*nn_msc+imu)
            plot(x,R.lMtilde(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
            hold on
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$\tilde{l}^M$ (-)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.05*norm(yl),yl(2)+0.02*norm(yl)])
            xlim([0,100])

%                 subplot(n_msc,nn_msc,6*nn_msc+imu)
%                 plot(R.vMtilde(:,imus(imu)),'Color',CsV(inr,:),'DisplayName',LegName);
%                 hold on
%                 grid on
%                 L = get(gca,'XLim');
%                 set(gca,'XTick',linspace(L(1),L(2),NumTicks))
%                 if imu==1
%                     ylabel('$\dot{\tilde{l}^M}$ (-)','Interpreter','latex');
%                 end
%                 axis tight
%                 yl = get(gca, 'ylim');
%                 ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
%                 xlim([0,100])

            subplot(n_msc,nn_msc,6*nn_msc+imu)
            plot(x,R.Muscle.vM(:,imus(imu)),'Color',CsV(inr,:),'DisplayName',LegName);
            hold on
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$v^M$ (m/s)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])

            subplot(n_msc,nn_msc,7*nn_msc+imu)
            plot(x,R.lMT(:,imus(imu)),'Color',CsV(inr,:),'DisplayName',LegName);
            hold on
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$l^{MT}$ (m)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.01*norm(yl),yl(2)+0.01*norm(yl)])
            xlim([0,100])

            
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
        end
        
        if inr==nr
            lhPos = lh3a.Position;
%             lhPos(1) = lhPos(1)-0.12;
            if makeplot.sol_all
                lhPos(2) = lhPos(2)+0.08;
            else
                lhPos(2) = lhPos(2)+0.1;
            end
            set(lh3a,'position',lhPos);
        end
            
        
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h3a,'PaperPositionMode','auto')
            print(h3a,[figNamePrefix '_peroneus'],'-dpng','-r0')
%             print(h3a,[figNamePrefix '_peroneus'],'-depsc')
        end
    end
    
    
    %% GRF
    if makeplot.GRF
        GRF_title = {'Fore-aft','Vertical','Lateral'};
        if inr==1
            h4 = figure('Position',[fpos(4,:),fsq]);
        else
            figure(h4);
        end

        
%         if inr==1 && md
%             subplot(3,5,[5;10])
%             hold on
%             grid on
%             iCOPd = find(Data.GRF.Fmean(:,2)>=20);
%             COPdzR = Data.GRF.COPmean(iCOPd,3)*1e3;
%             iCOPdL = mod(iCOPd+49,100)+1;
%             COPdzL = Data.GRF.COPmean(iCOPdL,3)*1e3;
%             COPdz = mean(COPdzR) + mean(COPdzL);
%             COPdzR = COPdzR - COPdz/2;
%             COPdx = Data.GRF.COPmean(iCOPd,1)*1e3;
%             COPdx = COPdx - COPdx(1);
%             
%             plot(COPdzR,COPdx,'.k','DisplayName','Measured');
%         end

        istance_COPR = find(R.GRFs(:,2)>30);
        COPz = R.COPR(istance_COPR,3)*1e3;
%         COPx = (R.COPR(istance_COPR,1)-R.COPR(istance_COPR(1),1))*1e3;
        COPx = R.COPR(istance_COPR,1)*1e3;
        subplot(3,5,[5;10])
        hold on
        grid on
        if max(abs(COPz))<1e2
            plot(COPz,COPx,'.','Color',CsV(inr,:),'DisplayName',LegName);
        end
        axis equal
        ylabel('Direction of walking (mm)')
        xlabel('Lateral (mm)')
        title('Centre of pressure')
        if inr==nr
%                 lh=legend('location','northwest');
%                 lhPos = lh.Position;
%                 lhPos(1) = lhPos(1)-0.15;
%                 set(lh,'position',lhPos);
            set(gca,'YAxisLocation','right')
        end
        
        
        if inr==1 && md
            for i=1:3
                subplot(3,4,i)
                hold on

                meanPlusSTD = Data.GRF.Fmean(:,i) + 2*Data.GRF.Fstd(:,i);
                meanMinusSTD = Data.GRF.Fmean(:,i) - 2*Data.GRF.Fstd(:,i);
                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);
                fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName','Measured');
                alpha(.25);


            end

        end
        for i=1:3
            subplot(3,4,i)
            hold on
            grid on
            l = plot(x,R.GRFs(:,i),'-','Color',CsV(inr,:));
            title(GRF_title{i});
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*abs(sum(yl)),yl(2)+0.1*abs(sum(yl))])
            xlim([0,100])
%             L = get(gca,'XLim');
%             set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if i==1
                ylabel({'Ground reaction force','(% body weight)'})
            end
        end
        l.DisplayName = LegName;

        if inr == 1
            lh=legend('location','northeast','Interpreter',lgInt);
            lhPos = lh.Position;
            lhPos(1) = lhPos(1)+0.1;
            lhPos(2) = lhPos(2)-0.02;
            set(lh,'position',lhPos);
        end

        if isfield(R,'GRFs_separate') && ~isempty(R.GRFs_separate)
            GRF_heel = sum(R.GRFs_separate(:,[2,5]),2);
            if R.S.Foot.contactGeometryVersion >= 5
                GRF_forefoot = sum(R.GRFs_separate(:,[8,11]),2);
                GRF_toes = R.GRFs_separate(:,14);
            else
                GRF_forefoot = sum(R.GRFs_separate(:,[8,11,14]),2);
                GRF_toes = R.GRFs_separate(:,17);
            end

            subplot(3,4,5)
            hold on
            grid on
            plot(x,GRF_heel,'Color',Cs);
            ylabel({'Ground reaction force','(% body weight)'})
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            title('Vertical GRF Heel')
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*abs(sum(yl)),yl(2)+0.1*abs(sum(yl))])
            xlim([0,100])

            subplot(3,4,6)
            hold on
            grid on
            plot(x,GRF_forefoot,'Color',Cs);
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            title('Vertical GRF Forefoot')
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*abs(sum(yl)),yl(2)+0.1*abs(sum(yl))])
            xlim([0,100])
            
            subplot(3,4,7)
            hold on
            grid on
            plot(x,GRF_toes,'Color',Cs);
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            title('Vertical GRF Toes')
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*abs(sum(yl)),yl(2)+0.1*abs(sum(yl))])
            xlim([0,100])

            for iGRF=1:6
                if iGRF==6 && R.S.Foot.contactGeometryVersion >= 5
                    continue
                end
                subplot(3,6,2*6+iGRF)
                hold on
                grid on
                plot(x,R.GRFs_separate(:,2+3*(iGRF-1)),'Color',Cs);
                if iGRF == 1
                    ylabel({'Ground reaction force','(% body weight)'})
                end
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                title({'Vertical GRF',['sphere ' num2str(iGRF)]})
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*abs(sum(yl)),yl(2)+0.1*abs(sum(yl))])
                xlim([0,100])
            end
        end
         
        
    
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h4,'PaperPositionMode','auto')
            print(h4,[figNamePrefix '_GRF'],'-dpng','-r0')
%             print(h4,[figNamePrefix '_GRF'],'-depsc')
        end
    end

    if makeplot.GRF_simple
        GRF_title = {'Fore-aft','Vertical','Lateral'};
        if inr==1
            h4a = figure('Position',[fpos(4,:),flong]);
            tiledlayout('flow')
        else
            figure(h4a);
        end

        if inr==1 && md
            for i=1:3
%                 subplot(1,3,i)
                nexttile(i)
                hold on

                meanPlusSTD = Data.GRF.Fmean(:,i) + 2*Data.GRF.Fstd(:,i);
                meanMinusSTD = Data.GRF.Fmean(:,i) - 2*Data.GRF.Fstd(:,i);
                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);
                fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName','Measured');
                alpha(.25);


            end

        end
        for i=1:3
%             subplot(1,3,i)
            nexttile(i)
            hold on
            grid on
            l = plot(x,R.GRFs(:,i),'-','Color',CsV(inr,:));
            title(GRF_title{i});
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*abs(sum(yl)),yl(2)+0.1*abs(sum(yl))])
            xlim([0,100])
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
%             L = get(gca,'XLim');
%             set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if i==1
                ylabel({'Ground reaction force','(% body weight)'})
            end
        end
        l.DisplayName = LegName;

        if inr == 1
%             lh=legend('location','northeast','Interpreter',lgInt);
%             lhPos = lh.Position;
%             lhPos(1) = lhPos(1)+0.1;
%             lhPos(2) = lhPos(2)-0.02;
%             set(lh,'position',lhPos);
            lh=legend('Interpreter',lgInt);
            lh.Layout.Tile = 4;

        end

        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h4a,'PaperPositionMode','auto')
            print(h4a,[figNamePrefix '_GRFs'],'-dpng','-r0')
%             print(h4,[figNamePrefix '_GRFs'],'-depsc')
        end
    end
    
    %% literature
    
    if makeplot.compareLiterature
        
        if inr==1
            pathmain = pwd;
            [pathRepo,~,~]  = fileparts(pathmain);
            folder = '\Figures';
            file = 'ankle_Caravaggi18.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_q_ankle = imread(pathRefImg);
            file = 'calcn_foreft_Caravaggi18.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_q_mtj = imread(pathRefImg);
            file = 'mtj_Caravaggi18.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_q_mtj2 = imread(pathRefImg);
            file = 'mtp1_Caravaggi18.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_q_mtp = imread(pathRefImg);
            file = 'PF_force_Caravaggi09.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_F_PF = imread(pathRefImg);
            file = 'talus_metatarsal_1_Lundgren_2008.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_talus_mtt1 = imread(pathRefImg);
            file = 'talus_metatarsal_1_inv_Lundgren_2008.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_talus_mtt1_inv = imread(pathRefImg);
            file = 'talus_metatarsal_1_add_Lundgren_2008.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_talus_mtt1_add = imread(pathRefImg);
            
            h5 = figure('Position',[fpos(1,:),fwide*0.5]);
            
            
%             h5 = figure('Position',[fpos(1,:),fwide]);
            
%             subplot(131)
%             hold on
%             axis tight
%             hi1 = image([-13,103],flip([-72,28]+30),img_q_ankle);
%             uistack(hi1,'bottom')
%             xlabel('Gait cycle (%)')
%             ylabel('Angle (°)')
%             title('Ankle')
            
            subplot(121)
            hold on
            axis tight
            ylim([-25,25])
            xlim([0,100])
%             hi1 = image([-12,102],flip([-72,27]+27.5),img_q_mtj);
            hi1 = image([-11,103],flip([-8,92]-42),img_q_mtj2);
            uistack(hi1,'bottom')
            xlabel('Gait cycle (%)')
            ylabel('Angle (°)')
            title('Midtarsal')
            
%             yl = get(gca,'YLim');
%             plot([20,20],get(gca,'YLim'),'color',[1,1,1]*0.3,'LineWidth',0.2)
%             plot([40,40],get(gca,'YLim'),'color',[1,1,1]*0.3)
%             plot([60,60],get(gca,'YLim'),'color',[1,1,1]*0.3)
%             plot([80,80],get(gca,'YLim'),'color',[1,1,1]*0.3)
%             plot([0,100],[0,0],'color',[1,1,1]*0.3)
%             plot([0,100],[-20,-20],'color',[1,1,1]*0.3)
%             plot([0,100],[20,20],'color',[1,1,1]*0.3)
            
            subplot(122)
            hold on
            axis tight
            ylim([-10,60])
            xlim([0,100])
            hi2 = image([-12,102],flip([-36,77]),img_q_mtp);
            uistack(hi2,'bottom')
            xlabel('Gait cycle (%)')
            ylabel('Angle (°)')
            title('Mtp')
%             
%             plot([20,20],get(gca,'YLim'),'color',[1,1,1]*0.3)
%             plot([40,40],get(gca,'YLim'),'color',[1,1,1]*0.3)
%             plot([60,60],get(gca,'YLim'),'color',[1,1,1]*0.3)
%             plot([80,80],get(gca,'YLim'),'color',[1,1,1]*0.3)
%             plot([0,100],[0,0],'color',[1,1,1]*0.3)
%             plot([0,100],[20,20],'color',[1,1,1]*0.3)
%             plot([0,100],[40,40],'color',[1,1,1]*0.3)
            

%             h7 = figure('Position',[fpos(2,:),scs(3)/2, scs(4)/3]);
%             title('Plantar fascia force, Caravaggi (2009), FE-simulation')
%             hold on
%             axis tight
%             hi5 = image([-13,112],flip([-0.16,1.75]),img_F_PF);
%             uistack(hi5,'bottom')
%             ylabel('Tension/BW (-)');
%             xlabel('Stance phase (%)');
% %             title('Plantar fascia force')
%             lh=legend('location','northwest');
%             lh.Interpreter = 'none';
            

                h5a = figure('Position',[fpos(2,:),fsq*0.6]);
                subplot(311)
                hold on
                axis tight
                xlim([0,100])
                hi2 = image([-1,101],[-16,15],img_talus_mtt1);
                uistack(hi2,'bottom')
                ylabel('Dorsiflexion (°)')
                title('First metatarsal relative to talus \rm (Lundgren and all, 2008)')
                
                subplot(312)
                hold on
                axis tight
                xlim([0,100])
                hi2 = image([-1,101],[-16,15],img_talus_mtt1_inv);
                uistack(hi2,'bottom')
                ylabel('Inversion (°)')
                
                subplot(313)
                hold on
                axis tight
                xlim([0,100])
                hi2 = image([-1,101],[-14,16],img_talus_mtt1_add);
                uistack(hi2,'bottom')
                xlabel('Stance (%)')
                ylabel('Abduction (°)')
        end
        
        
        % Q
        figure(h5)
%         subplot(131)
%         plot(x,R.Qs(:,iankle),'linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',LegName);
        
        if ~isempty(imtj)
            subplot(121)
            plot(x,R.Qs(:,imtj),'linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',LegName);

        end
        
        subplot(122)
        plot(x,R.Qs(:,imtp),'linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',LegName);
        
        
            
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h5,'PaperPositionMode','auto')
            print(h5,[figNamePrefix '_qs_lit_1'],'-dpng','-r0')
%             print(h5,[figNamePrefix '_qs_lit_1'],'-depsc')
        end
        
        %         
%         
%         % F
%         if isfield(R,'windlass') && ~isempty(R.windlass)
%             figure(h7)
%             plot(xst,R.windlass.F_PF(istance)/(R.body_mass*9.81),'linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',LegName);
%         end
%             
        
        u_ax_subt = [0.78717961, 0.60474746, -0.12094949]';
        cr_subt = [0,-u_ax_subt(3),u_ax_subt(2); u_ax_subt(3),0,-u_ax_subt(1); -u_ax_subt(2),u_ax_subt(1),0];
        u_ax_mtj = [0,0,1]';
        cr_mtj = [0,-u_ax_mtj(3),u_ax_mtj(2); u_ax_mtj(3),0,-u_ax_mtj(1); -u_ax_mtj(2),u_ax_mtj(1),0];

        q_subt_rad = R.Qs(:,isubt)*pi/180;
        if ~isempty(imtj)
            q_mtj_rad = R.Qs(:,imtj)*pi/180;
        else
            q_mtj_rad = zeros(size(q_subt_rad));
        end

        for i=1:length(q_mtj_rad)
            R_subt = cos(q_subt_rad(i))*eye(3) + sin(q_subt_rad(i))*cr_subt + (1-cos(q_subt_rad(i)))*(u_ax_subt*u_ax_subt');
            R_mtj = cos(q_mtj_rad(i))*eye(3) + sin(q_mtj_rad(i))*cr_mtj + (1-cos(q_mtj_rad(i)))*(u_ax_mtj*u_ax_mtj');
            Rot = R_subt*R_mtj;

            q_alpha(i) = atan(-Rot(1,2)/Rot(2,2))*180/pi;
            q_beta(i) = atan(Rot(3,2)/sqrt(1-Rot(3,2)^2))*180/pi;
            q_gamma(i) = atan(-Rot(3,1)/Rot(3,3))*180/pi;
        end

            figure(h5a)

            subplot(311)
            hold on
%             plot(xst,q_alpha(istance0),'k','linewidth',line_linewidth);
            plot(xst,q_alpha(istance0),'-.','linewidth',line_linewidth*2,'Color',CsV(inr,:),'DisplayName',LegName);
            
            subplot(312)
            hold on
%             plot(xst,q_beta(istance0),'k','linewidth',line_linewidth);
            plot(xst,q_beta(istance0),'-.','linewidth',line_linewidth*2,'Color',CsV(inr,:),'DisplayName',LegName);
            
            
            subplot(313)
            hold on
%             plot(xst,q_gamma(istance0),'k','linewidth',line_linewidth);
            plot(xst,q_gamma(istance0),'-.','linewidth',line_linewidth*2,'Color',CsV(inr,:),'DisplayName',LegName);
                        
            if inr==nr && ~strcmp(figNamePrefix,'none')
                set(h5a,'PaperPositionMode','auto')
                print(h5a,[figNamePrefix '_qs_lit_2'],'-dpng','-r0')
%                 print(h5a,[figNamePrefix '_qs_lit_2'],'-depsc')
            end
        
        end
    
        
        % P
    if makeplot.compareTakahashi17
        pathmain = pwd;
        [pathRepo,~,~]  = fileparts(pathmain);
        folder = '\Figures';
        file = 'foot_power_Takahashi17.png';
        pathRefImg = fullfile(pathRepo,folder,file);
        img_P_foot = imread(pathRefImg);
        file = 'mtj_power_Takahashi17.png';
        pathRefImg = fullfile(pathRepo,folder,file);
        img_P_mtj = imread(pathRefImg);
        file = 'ankle_power_Takahashi17.png';
        pathRefImg = fullfile(pathRepo,folder,file);
        img_P_ankle = imread(pathRefImg);
            
        
        h6 = figure('Position',[fpos(4,:),fsq*1.4]);
            
        % figures from reference
        subplot(3,3,1)
        hold on
        axis tight
        hi3 = image([-4,108],flip([-1.71,3.6]),img_P_foot);
        uistack(hi3,'bottom')
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        title({'Power based on experiment','\rm Takahashi and all, 2017'})
        yl_1 = get(gca, 'ylim');
        
        subplot(3,3,4)
        hold on
        axis tight
        hi4 = image([-6.5,109],flip([-1.64,1.69]),img_P_mtj);
        uistack(hi4,'bottom')
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        yl_4 = get(gca, 'ylim');
        
        subplot(3,3,7)
        hold on
        axis tight
        hi4 = image([-8,103],flip([-1.64,3.1]),img_P_ankle);
        uistack(hi4,'bottom')
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        yl_7 = get(gca, 'ylim');
        
        % net work
        W_dist_shank = trapz(R.t(istance0),P_tot(istance0));
        W_dist_hindfoot = trapz(R.t(istance0),P_dist_hindfoot(istance0));
        W_dist_forefoot = trapz(R.t(istance0),P_dist_forefoot(istance0));
        W_dist_hallux = trapz(R.t(istance0),P_dist_hallux(istance0));
        
        [W_dist_shank_pos,W_dist_shank_neg] = getWork(P_tot(istance0),R.t(istance0));
        [W_dist_hindfoot_pos,W_dist_hindfoot_neg] = getWork(P_dist_hindfoot(istance0),R.t(istance0));
        [W_dist_forefoot_pos,W_dist_forefoot_neg] = getWork(P_dist_forefoot(istance0),R.t(istance0));
        [W_dist_hallux_pos,W_dist_hallux_neg] = getWork(P_dist_hallux(istance0),R.t(istance0));
        
        
        
        [W_mtj_pos,W_mtj_neg] = getWork(P_mtj(istance0),R.t(istance0));
        [W_mtjfft_pos,W_mtjfft_neg] = getWork(P_mtj(istance0)+P_dist_forefoot(istance0),R.t(istance0));
        [W_anklesubt_pos,W_anklesubt_neg] = getWork(P_ankle(istance0)+P_subt(istance0),R.t(istance0));
        [W_anklesubthft_pos,W_anklesubthft_neg] = getWork(P_ankle(istance0)+P_subt(istance0)+P_dist_hindfoot(istance0),R.t(istance0));
        
        subplot(3,4,4)
        W_s = [W_dist_hallux_pos,W_dist_hallux_neg,W_dist_hallux,...
            W_dist_forefoot_pos,W_dist_forefoot_neg,W_dist_forefoot,...
            W_dist_hindfoot_pos,W_dist_hindfoot_neg,W_dist_hindfoot,...
            W_dist_shank_pos,W_dist_shank_neg,W_dist_shank]';
        
        br=bar(W_s);
        grid on
        br.FaceColor = 'flat';
        br.CData(1,:) = [0, 0.5, 0];
        br.CData(2,:) = [0, 0.5, 0];
        br.CData(3,:) = [0, 0.5, 0];
        br.CData(4,:) = [0.7, 0.1, 0.1];
        br.CData(5,:) = [0.7, 0.1, 0.1];
        br.CData(6,:) = [0.7, 0.1, 0.1];
        br.CData(7,:) = [0, 0.4470, 0.7410];
        br.CData(8,:) = [0, 0.4470, 0.7410];
        br.CData(9,:) = [0, 0.4470, 0.7410];
        br.CData(10,:) = [0, 0, 0];
        br.CData(11,:) = [0, 0, 0];
        br.CData(12,:) = [0, 0, 0];
        ylabel('Work (J/kg)')
        tmp=gca;
        tmp.XTickLabel = {'+','-','Hallux','+','-','Forefoot','+','-','Hindfoot','+','-','Shank'};
        tmp.XTickLabelRotation = 90;
        tmp.YAxisLocation = 'right';
%         tmp.XAxisLocation = 'top';
        title({'Pos, Neg, Net Work in simulation','\rm this work'})
        
        subplot(3,4,8)
        W_s = [W_dist_forefoot_pos,W_dist_forefoot_neg,W_dist_forefoot,W_mtj_pos,W_mtj_neg,W_mtj(istance0(end)),...
            W_mtjfft_pos,W_mtjfft_neg,W_dist_forefoot+W_mtj(istance0(end)),...
            W_dist_hindfoot_pos,W_dist_hindfoot_neg,W_dist_hindfoot]'
        br=bar(W_s);
        grid on
        br.FaceColor = 'flat';
        br.CData(1,:) = [0.7, 0.1, 0.1];
        br.CData(2,:) = [0.7, 0.1, 0.1];
        br.CData(3,:) = [0.7, 0.1, 0.1];
        br.CData(4,:) = [0.3010, 0.7450, 0.9330];
        br.CData(5,:) = [0.3010, 0.7450, 0.9330];
        br.CData(6,:) = [0.3010, 0.7450, 0.9330];
        br.CData(7,:) = [0.3,0.3,0.3];
        br.CData(8,:) = [0.3,0.3,0.3];
        br.CData(9,:) = [0.3,0.3,0.3];
        br.CData(10,:) = [0, 0.4470, 0.7410];
        br.CData(11,:) = [0, 0.4470, 0.7410];
        br.CData(12,:) = [0, 0.4470, 0.7410];
        ylabel('Work (J/kg)')
        tmp=gca;
        tmp.XTickLabel = {'+','-','Forefoot','+','-','Midtarsal','+','-','Summation','+','-','Hindfoot'};
        tmp.XTickLabelRotation = 90;
        tmp.YAxisLocation = 'right';
%         tmp.XAxisLocation = 'top';
%         title('Net Work')
        
        subplot(3,4,12)
        W_s = [W_dist_hindfoot_pos,W_dist_hindfoot_neg,W_dist_hindfoot,...
            W_anklesubt_pos,W_anklesubt_neg,W_ankle(istance(end))+W_subt(istance(end)),...
            W_anklesubthft_pos,W_anklesubthft_neg,W_dist_hindfoot+W_ankle(istance(end))+W_subt(istance(end)),...
            W_dist_shank_pos,W_dist_shank_neg,W_dist_shank]';
        br=bar(W_s);
        grid on
        br.FaceColor = 'flat';
        br.CData(1,:) = [0, 0.4470, 0.7410];
        br.CData(2,:) = [0, 0.4470, 0.7410];
        br.CData(3,:) = [0, 0.4470, 0.7410];
        br.CData(4,:) = [0.4660, 0.6740, 0.1880];
        br.CData(5,:) = [0.4660, 0.6740, 0.1880];
        br.CData(6,:) = [0.4660, 0.6740, 0.1880];
        br.CData(7,:) = [0.3,0.3,0.3];
        br.CData(8,:) = [0.3,0.3,0.3];
        br.CData(9,:) = [0.3,0.3,0.3];
        br.CData(10,:) = [0, 0, 0];
        br.CData(11,:) = [0, 0, 0];
        br.CData(12,:) = [0, 0, 0];
        ylabel('Work (J/kg)')
        tmp=gca;
        tmp.XTickLabel = {'+','-','Hindfoot','+','-','Ankle','+','-','Summation','+','-','Shank'};
        tmp.XTickLabelRotation = 90;
        tmp.YAxisLocation = 'right';
%         tmp.XAxisLocation = 'top';
%         title('Net Work')
        
        % figures from here
        subplot(3,3,2)
        plot(xst_10,P_dist_hallux(istance),'-','Color',[0, 0.5, 0],'linewidth',line_linewidth,'DisplayName','Distal to Hallux');
        hold on
        grid on
        plot(xst_10,P_dist_forefoot(istance),'-','Color',[0.7, 0.1, 0.1],'linewidth',line_linewidth,'DisplayName','Distal to Forefoot');
        plot(xst_10,P_dist_hindfoot(istance),'-','Color',[0, 0.4470, 0.7410],'linewidth',line_linewidth,'DisplayName','Distal to Hindfoot');
        plot(xst_10,P_tot(istance),'-','Color','k','linewidth',line_linewidth,'DisplayName','Distal to Shank');
        yl_2 = get(gca, 'ylim');
        ylim([min(yl_1(1),yl_2(1)), max(yl_1(2),yl_2(2))])
        xlim([0,100])
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        title({'Power predicted in simulation','\rm this work'})
        lh=legend('location','northwest','Interpreter',lgInt);
%         lhPos = lh.Position;
%         lhPos(1) = lhPos(1)+0.15;
%         lhPos(2) = lhPos(2)-0.01;
%         set(lh,'position',lhPos);

        subplot(3,3,5)
        plot(xst_10,P_dist_forefoot(istance),'--','Color',[0.7, 0.1, 0.1],'linewidth',line_linewidth,'DisplayName','Distal to Forefoot');
        hold on
        grid on
%         plot(xst,P_mtp(istance),':','Color',[0.7, 0.1, 0.1],'linewidth',line_linewidth,'DisplayName','Metatarsophalangeal joint');
        if ~isempty(imtj)
            plot(xst_10,P_mtj(istance),'--','Color',[0.3010, 0.7450, 0.9330],'linewidth',line_linewidth,'DisplayName','Midtarsal joint');
            plot(xst_10,P_mtj(istance)+P_dist_forefoot(istance),'-','Color',[0.3, 0.3, 0.3],'linewidth',line_linewidth,'DisplayName','Midtarsal joint + Distal to Forefoot');
        end
        plot(xst_10,P_dist_hindfoot(istance),'-','Color',[0, 0.4470, 0.7410],'linewidth',line_linewidth,'DisplayName','Distal to Hindfoot');
        yl_5 = get(gca, 'ylim');
        ylim([min(yl_4(1),yl_5(1)), max(yl_4(2),yl_5(2))])
        xlim([0,100])
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        lh=legend('location','northwest','Interpreter',lgInt);
        lhPos = lh.Position;
%         lhPos(1) = lhPos(1)+0.15;
        lhPos(2) = lhPos(2)+0.05;
        set(lh,'position',lhPos);
        
        subplot(3,3,8)
        plot(xst_10,P_dist_hindfoot(istance),'--','Color',[0, 0.4470, 0.7410],'linewidth',line_linewidth,'DisplayName','Distal to Hindfoot');
        hold on
        grid on
        plot(xst_10,P_ankle(istance)+P_subt(istance),'--','Color',[0.4660, 0.6740, 0.1880],'linewidth',line_linewidth,'DisplayName','Ankle');
        plot(xst_10,P_ankle(istance)+P_subt(istance)+P_dist_hindfoot(istance),'-','Color',[0.5, 0.5, 0.5],'linewidth',line_linewidth,'DisplayName','Ankle + Distal to Hindfoot');
        plot(xst_10,P_tot(istance),'-','Color','k','linewidth',line_linewidth,'DisplayName','Distal to Shank');
        yl_8 = get(gca, 'ylim');
        ylim([min(yl_7(1),yl_8(1)), max(yl_7(2),yl_8(2))])
        xlim([0,100])
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        lh=legend('location','northwest','Interpreter',lgInt);
%         lhPos = lh.Position;
%         lhPos(1) = lhPos(1)+0.15;
%         lhPos(2) = lhPos(2)-0.01;
%         set(lh,'position',lhPos);
        
        
        % get same scale on each pair
        subplot(331)
        ylim([min(yl_1(1),yl_2(1)), max(yl_1(2),yl_2(2))])
        subplot(334)
        ylim([min(yl_4(1),yl_5(1)), max(yl_4(2),yl_5(2))])
        subplot(337)
        ylim([min(yl_7(1),yl_8(1)), max(yl_7(2),yl_8(2))])
        
        
        
        if ~strcmp(figNamePrefix,'none')
            set(h6,'PaperPositionMode','auto')
            print(h6,[figNamePrefix '_Takahashi17_' num2str(inr)],'-dpng','-r0')
%             print(h6,[figNamePrefix '_Takahashi17_' num2str(inr)],'-depsc')
        end
        
    end
    
    
    if makeplot.compareTakahashi17_separate
        pathmain = pwd;
        [pathRepo,~,~]  = fileparts(pathmain);
        folder = '\Figures';
        file = 'foot_power_Takahashi17.png';
        pathRefImg = fullfile(pathRepo,folder,file);
        img_P_foot = imread(pathRefImg);
        file = 'mtj_power_Takahashi17.png';
        pathRefImg = fullfile(pathRepo,folder,file);
        img_P_mtj = imread(pathRefImg);
        file = 'ankle_power_Takahashi17.png';
        pathRefImg = fullfile(pathRepo,folder,file);
        img_P_ankle = imread(pathRefImg);
            
        
        h6c = figure('Position',[fpos(4,:),flong*2]);
        
        subplot(121)
        hold on
        axis tight
        hi3 = image([-4,108],flip([-1.71,3.6]),img_P_foot);
        uistack(hi3,'bottom')
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        title({'Power based on experiment','\rm Takahashi and all, 2017'})
        yl_1 = get(gca, 'ylim');
        
         subplot(122)
        plot(xst_10,P_dist_hallux(istance),'-','Color',[0, 0.5, 0],'linewidth',line_linewidth,'DisplayName','Distal to Hallux');
        hold on
        grid on
        plot(xst_10,P_dist_forefoot(istance),'-','Color',[0.7, 0.1, 0.1],'linewidth',line_linewidth,'DisplayName','Distal to Forefoot');
        plot(xst_10,P_dist_hindfoot(istance),'-','Color',[0, 0.4470, 0.7410],'linewidth',line_linewidth,'DisplayName','Distal to Hindfoot');
        plot(xst_10,P_tot(istance),'-','Color','k','linewidth',line_linewidth,'DisplayName','Distal to Shank');
        yl_2 = get(gca, 'ylim');
        ylim([min(yl_1(1),yl_2(1)), max(yl_1(2),yl_2(2))])
        xlim([0,100])
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        title({'Power predicted in simulation',['\rm this work (' LegName ')']})
        lh=legend('location','northwest','Interpreter',lgInt);
        
        subplot(121)
        ylim([min(yl_1(1),yl_2(1)), max(yl_1(2),yl_2(2))])
        
        if ~strcmp(figNamePrefix,'none')
            set(h6c,'PaperPositionMode','auto')
            print(h6c,[figNamePrefix '_Takahashi17_foot_' num2str(inr)],'-dpng','-r0')
%             print(h6c,[figNamePrefix '_Takahashi17_foot_' num2str(inr)],'-depsc')
        end
        
        %
        
        h6d = figure('Position',[fpos(4,:),fwide*2]);
        
        subplot(121)
        hold on
        axis tight
        hi4 = image([-6.5,109],flip([-1.64,1.69]),img_P_mtj);
        uistack(hi4,'bottom')
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        yl_4 = get(gca, 'ylim');
        title({'Power based on experiment','\rm Takahashi and all, 2017'})
        
        subplot(122)
        plot(xst_10,P_dist_forefoot(istance),'--','Color',[0.7, 0.1, 0.1],'linewidth',line_linewidth,'DisplayName','Distal to Forefoot');
        hold on
        grid on
        if ~isempty(imtj)
            plot(xst_10,P_mtj(istance),'--','Color',[0.3010, 0.7450, 0.9330],'linewidth',line_linewidth,'DisplayName','Midtarsal joint');
            plot(xst_10,P_mtj(istance)+P_dist_forefoot(istance),'-','Color',[0.3, 0.3, 0.3],'linewidth',line_linewidth,'DisplayName','Midtarsal joint + Distal to Forefoot');
        end
        plot(xst_10,P_dist_hindfoot(istance),'-','Color',[0, 0.4470, 0.7410],'linewidth',line_linewidth,'DisplayName','Distal to Hindfoot');
        yl_5 = get(gca, 'ylim');
        ylim([min(yl_4(1),yl_5(1)), max(yl_4(2),yl_5(2))])
        xlim([0,100])
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        lh=legend('location','northwest','Interpreter',lgInt);
        lhPos = lh.Position;
%         lhPos(1) = lhPos(1)+0.15;
%         lhPos(2) = lhPos(2)+0.05;
        set(lh,'position',lhPos);
        title({'Power predicted in simulation',['\rm this work (' LegName ')']})
        
        subplot(121)
        ylim([min(yl_4(1),yl_5(1)), max(yl_4(2),yl_5(2))])
        
        if ~strcmp(figNamePrefix,'none')
            set(h6d,'PaperPositionMode','auto')
            print(h6d,[figNamePrefix '_Takahashi17_mtj_' num2str(inr)],'-dpng','-r0')
%             print(h6d,[figNamePrefix '_Takahashi17_mtj_' num2str(inr)],'-depsc')
        end
        %
        
        h6e = figure('Position',[fpos(4,:),ffull]);
        
        subplot(121)
        hold on
        axis tight
        hi4 = image([-8,103],flip([-1.64,3.1]),img_P_ankle);
        uistack(hi4,'bottom')
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        yl_7 = get(gca, 'ylim');
        title({'Power based on experiment','\rm Takahashi and all, 2017'})
        
        subplot(122)
        plot(xst_10,P_dist_hindfoot(istance),'--','Color',[0, 0.4470, 0.7410],'linewidth',line_linewidth,'DisplayName','Distal to Hindfoot');
        hold on
        grid on
        plot(xst_10,P_ankle(istance)+P_subt(istance),'--','Color',[0.4660, 0.6740, 0.1880],'linewidth',line_linewidth,'DisplayName','Ankle');
%         plot(xst_10,P_ankle(istance),'--','Color',[0.4660, 0.6740, 0.1880],'linewidth',line_linewidth,'DisplayName','Ankle');
        plot(xst_10,P_ankle(istance)+P_subt(istance)+P_dist_hindfoot(istance),'-','Color',[0.5, 0.5, 0.5],'linewidth',line_linewidth,'DisplayName','Ankle + Distal to Hindfoot');
        plot(xst_10,P_tot(istance),'-','Color','k','linewidth',line_linewidth,'DisplayName','Distal to Shank');
        yl_8 = get(gca, 'ylim');
        ylim([min(yl_7(1),yl_8(1)), max(yl_7(2),yl_8(2))])
        xlim([0,100])
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        title({'Power predicted in simulation',['\rm this work (' LegName ')']})
        lh=legend('location','northwest','Interpreter',lgInt);
%         lhPos = lh.Position;
%         lhPos(1) = lhPos(1)+0.15;
%         lhPos(2) = lhPos(2)-0.01;
%         set(lh,'position',lhPos);
        
        
        subplot(121)
        ylim([min(yl_7(1),yl_8(1)), max(yl_7(2),yl_8(2))])
        
        
        
        if ~strcmp(figNamePrefix,'none')
            set(h6e,'PaperPositionMode','auto')
            print(h6e,[figNamePrefix '_Takahashi17_ankle_' num2str(inr)],'-dpng','-r0')
%             print(h6e,[figNamePrefix '_Takahashi17_ankle_' num2str(inr)],'-depsc')
        end
        
    end

    
    if makeplot.compareTakahashi17_mtj_only
        if inr==1
            pathmain = pwd;
            [pathRepo,~,~]  = fileparts(pathmain);
            folder = '\Figures';
            file = 'mtj_power_Takahashi17.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_P_mtj = imread(pathRefImg);
            h6a = figure('Position',[fpos(4,:),fsq(1)*0.5*1.5,fsq(2)*0.6*1.5]);
            hold on
            axis tight
            hi4 = image([-6.5,109],flip([-1.64,1.69]),img_P_mtj);
            uistack(hi4,'bottom')
            
            lh=legend('location','southwest','Interpreter',lgInt);
            lhPos = lh.Position;
            lhPos(1) = lhPos(1)+0.1;
            lhPos(2) = lhPos(2)+0.1;
            set(lh,'position',lhPos);
            title(lh,'This work')
        end
        figure(h6a)
        
        ylabel('Power (W/kg)');
        xlabel('Stance phase (%)');
        title({'Mechanical power midtarsal joint','\rm vs results from Takahashi and all, 2017'})
        if ~isempty(imtj)
            plot(xst_10,P_mtj(istance),'.-','Color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
        end
        

        if ~strcmp(figNamePrefix,'none')
            set(h6a,'PaperPositionMode','auto')
            print(h6a,[figNamePrefix '_Takahashi17_mtj'],'-dpng','-r0')
%             print(h6a,[figNamePrefix '_Takahashi17_mtj'],'-depsc')
        end

    end
    
    if makeplot.compareTakahashi17_W_bar
        h6b = figure('Position',[fpos(4,:),fwide]);
    
        % results from DOI:10.1038/s41598-017-15218-7
        % order: hallux, forefoot, hindfoot, shank
        ref_pos_m = [0.006,0.012,0.042,0.185];
        ref_pos_std = [0.004,0.005,0.012,0.028];
        ref_neg_m = [-0.013,-0.095,-0.125,-0.197];
        ref_neg_std = [0.004,0.031,0.026,0.040];
        ref_net_m = [-0.006,-0.083,-0.083,-0.012];
        ref_net_std = [0.005,0.032,0.021,0.054];
        % order: mtj, mtj+forefoot, ankle
        ref_pos_m2 = [0.1009,0.0458,0.1872];
        ref_pos_std2 = [0.0308,0.0159,0.0338];
        ref_neg_m2 = [-0.0536,-0.0822,-0.1181];
        ref_neg_std2 = [0.0144,0.0197,0.0414];
        ref_net_m2 = [0.0475,-0.0360,0.0694];
        ref_net_std2 = [0.0301,0.0241,0.0611];

        W_dist_shank = trapz(R.t(istance0),P_tot(istance0));
        W_dist_hindfoot = trapz(R.t(istance0),P_dist_hindfoot(istance0));
        W_dist_forefoot = trapz(R.t(istance0),P_dist_forefoot(istance0));
        W_dist_hallux = trapz(R.t(istance0),P_dist_hallux(istance0));
        
        W_mtjs = trapz(R.t(istance0),P_mtj(istance0));
        W_mtjff = trapz(R.t(istance0),P_mtj(istance0)+P_dist_forefoot(istance0));
        W_ankles = trapz(R.t(istance0),P_ankle(istance0)+P_subt(istance0));

        [W_dist_shank_pos,W_dist_shank_neg] = getWork(P_tot(istance0),R.t(istance0));
        [W_dist_hindfoot_pos,W_dist_hindfoot_neg] = getWork(P_dist_hindfoot(istance0),R.t(istance0));
        [W_dist_forefoot_pos,W_dist_forefoot_neg] = getWork(P_dist_forefoot(istance0),R.t(istance0));
        [W_dist_hallux_pos,W_dist_hallux_neg] = getWork(P_dist_hallux(istance0),R.t(istance0));
        
        [W_mtj_pos,W_mtj_neg] = getWork(P_mtj(istance0),R.t(istance0));
        [W_mtjff_pos,W_mtjff_neg] = getWork(P_mtj(istance0)+P_dist_forefoot(istance0),R.t(istance0));
        [W_ankle_pos,W_ankle_neg] = getWork(P_ankle(istance0)+P_subt(istance0),R.t(istance0));
        
        subplot(1,4,1)
        W_pos = [W_dist_hallux_pos,W_dist_forefoot_pos,W_dist_hindfoot_pos,W_dist_shank_pos]';
        W_neg = [W_dist_hallux_neg,W_dist_forefoot_neg,W_dist_hindfoot_neg,W_dist_shank_neg]';
        
        br=bar(W_pos);
        br.FaceColor = 'flat';
        br.CData(1,:) = [0, 0.5, 0];
        br.CData(2,:) = [0.7, 0.1, 0.1];
        br.CData(3,:) = [0, 0.4470, 0.7410];
        br.CData(4,:) = [0.3, 0.3, 0.3];
        hold on
        
        ebr=errorbar([1:4],ref_pos_m,-ref_pos_std,ref_pos_std);
        ebr.Color = [0 0 0];                            
        ebr.LineStyle = 'none';
        ebr.LineWidth = 2;

        grid on
        ylabel({'Work (J/kg)','Negative     Positive'})
        tmp=gca;
        tmp.XTickLabel = {'Hallux','Forefoot','Hindfoot','Shank'};
%         tmp.XAxisLocation = 'top';
%         tmp.XTickLabelRotation = 90;
%         title('Work distal to...')
        yl_1 = tmp.YLim;
        
        yyaxis right
        br=bar(W_neg);
        br.FaceColor = 'flat';
        br.CData(1,:) = [0, 0.5, 0];
        br.CData(2,:) = [0.7, 0.1, 0.1];
        br.CData(3,:) = [0, 0.4470, 0.7410];
        br.CData(4,:) = [0.3, 0.3, 0.3];
        hold on
        
        ebr=errorbar([1:4],ref_neg_m,-ref_neg_std,ref_neg_std);
        ebr.Color = [0 0 0];                            
        ebr.LineStyle = 'none'; 
        ebr.LineWidth = 2;

        tmp2 = gca;
        yl_2 = tmp2.YLim;
                
        tmp2.YAxis(2).Color = 'k';
        tmp2.YTickLabel = '';
        
        yl_12 = [min([yl_1,yl_2]), max([yl_1,yl_2])];
        ylim(yl_12)
        
        yyaxis left
        ylim(yl_12)
        

        
        subplot(1,4,2)
        W_net = [W_dist_hallux,W_dist_forefoot,W_dist_hindfoot,W_dist_shank]';
        
        br=bar(W_net);
        br.FaceColor = 'flat';
        br.CData(1,:) = [0, 0.5, 0];
        br.CData(2,:) = [0.7, 0.1, 0.1];
        br.CData(3,:) = [0, 0.4470, 0.7410];
        br.CData(4,:) = [0.3, 0.3, 0.3];
        hold on
        
        ebr=errorbar([1:4],ref_net_m,-ref_net_std,ref_net_std);
        ebr.Color = [0 0 0];                            
        ebr.LineStyle = 'none';
        ebr.LineWidth = 2;

        grid on
        ylabel('Net Work (J/kg)')
        tmp=gca;
        tmp.XTickLabel = {'Hallux','Forefoot','Hindfoot','Shank'};
%         tmp.XAxisLocation = 'top';
%         tmp.XTickLabelRotation = 90;
%         title('Work distal to...')
        ylim(yl_12)
        
        
        
        subplot(1,4,3)
        W_pos = [W_mtj_pos,W_mtjff_pos,W_ankle_pos]';
        W_neg = [W_mtj_neg,W_mtjff_neg,W_ankle_neg]';
        
        br=bar(W_pos);
        br.FaceColor = 'flat';
        br.CData(1,:) = [0.3010, 0.7450, 0.9330];
        br.CData(2,:) = [0.5, 0.5, 0.5];
        br.CData(3,:) = [0.4660, 0.6740, 0.1880];
        hold on
        
        ebr=errorbar([1:3],ref_pos_m2,-ref_pos_std2,ref_pos_std2);
        ebr.Color = [0 0 0];                            
        ebr.LineStyle = 'none';
        ebr.LineWidth = 2;

        grid on
        ylabel({'Work (J/kg)','Negative     Positive'})
        tmp=gca;
        tmp.XTickLabel = {'Midtarsal','MTJ + Forefoot','Ankle'};
%         tmp.XAxisLocation = 'top';
%         tmp.XTickLabelRotation = 90;
%         title('Work distal to...')
        yl_1 = tmp.YLim;
        
        yyaxis right
        br=bar(W_neg);
        br.FaceColor = 'flat';
        br.CData(1,:) = [0.3010, 0.7450, 0.9330];
        br.CData(2,:) = [0.5, 0.5, 0.5];
        br.CData(3,:) = [0.4660, 0.6740, 0.1880];
        hold on
        
        ebr=errorbar([1:3],ref_neg_m2,-ref_neg_std2,ref_neg_std2);
        ebr.Color = [0 0 0];                            
        ebr.LineStyle = 'none'; 
        ebr.LineWidth = 2;

        tmp2 = gca;
        yl_2 = tmp2.YLim;
                
        tmp2.YAxis(2).Color = 'k';
        tmp2.YTickLabel = '';
        
%         yl_12 = [min([yl_1,yl_2]), max([yl_1,yl_2])];
        ylim(yl_12)
        
        yyaxis left
        ylim(yl_12)
        

        
        subplot(1,4,4)
        W_net = [W_mtjs,W_mtjff,W_ankles]';
        
        br=bar(W_net);
        br.FaceColor = 'flat';
        br.CData(1,:) = [0.3010, 0.7450, 0.9330];
        br.CData(2,:) = [0.3, 0.3, 0.3];
        br.CData(3,:) = [0.4660, 0.6740, 0.1880];
        hold on
        
        ebr=errorbar([1:3],ref_net_m2,-ref_net_std2,ref_net_std2);
        ebr.Color = [0 0 0];                            
        ebr.LineStyle = 'none';
        ebr.LineWidth = 2;
        
        grid on
        ylabel('Net Work (J/kg)')
        tmp=gca;
        tmp.XTickLabel = {'Midtarsal','MTJ + Forefoot','Ankle'};
%         tmp.XAxisLocation = 'top';
%         tmp.XTickLabelRotation = 90;
%         title('Work distal to...')
        ylim(yl_12)


        legend({['Simulation (' LegName ')'],'Experiment (Takahashi et al., 2017)'},'Location','north','Interpreter',lgInt)
        


        if ~strcmp(figNamePrefix,'none')
            set(h6b,'PaperPositionMode','auto')
            print(h6b,[figNamePrefix '_Takahashi17_W_bar_' num2str(inr)],'-dpng','-r0')
%             print(h6b,[figNamePrefix '_Takahashi17_W_bar_' num2str(inr)],'-depsc')
        end
        
    end
    
    %% centre of pressure
%     if makeplot.COP
%         if inr==1
%             h8 = figure('Position',[fpos(2,:)+200,fhigh1(1)*0.4,fhigh1(2)*0.5]);
%             
%         end
%         
%         if isfield(R,'AnkleInGround')
%             ictt = find(R.AnkleInGround.leverArmGRF.r~=0);
%             relPos = (R.COPR(ictt,:) - R.AnkleInGround.position.r(ictt,:))*1e3;
%             istance_COPR = find(R.GRFs(:,2)>5);
%             istance_COPL = find(R.GRFs(:,5)>5);
            
%             COPz = [R.COPR(istance_COPR,3); R.COPL(istance_COPL,3)]*1e3;
%             COPx = [R.COPR(istance_COPR,1); R.COPL(istance_COPL,1)]*1e3;
%             COPz = R.COPR(istance_COPR,3)*1e3;
%             COPx = (R.COPR(istance_COPR,1)-R.COPR(istance_COPR(1),1))*1e3;

            
%             figure(h8)
%             plot(COPz,COPx,'.','Color',CsV(inr,:),'DisplayName',LegName);
%             hold on
%             grid on
%             axis equal
%             ylabel('Direction of walking (mm)')
%             xlabel('Lateral (mm)')
%             title({'Centre of pressure during stance','\rm W.r.t. ground reference'})
            
%             subplot(121)
%             p1=plot(0,0,'d','Color',CsV(inr,:),'DisplayName',['Ankle (' LegName ')']);
%             hold on
%             grid on
%             axis equal
%             xlabel('fore-after (mm)')
%             ylabel('vertical (mm)')
%             title('Centre of pressure during stance')
%             plot(relPos(:,1),relPos(:,2),'o','Color',p1.Color,'DisplayName',['COP (' LegName ')']);
%             
%             subplot(122)
%             p1=plot(0,0,'d','Color',CsV(inr,:),'DisplayName',['Ankle (' LegName ')']);
%             hold on
%             grid on
%             axis equal
%             ylabel('fore-after (mm)')
%             xlabel('lateral (mm)')
%             title('Centre of pressure during stance')
%             plot(relPos(:,3),relPos(:,1),'o','Color',p1.Color,'DisplayName',['COP (' LegName ')']);
%             legend('location','best')
            
            
%             figure
%             ictt1 = ictt(1:5:end);
%             grfx = [R.COPR(ictt1,1)*1e3, R.COPR(ictt1,1)*1e3 + R.GRFs(ictt1,1)];
%             grfy = [R.COPR(ictt1,2)*1e3, R.COPR(ictt1,2)*1e3 + R.GRFs(ictt1,2)];
%             plot(R.AnkleInGround.position.r(ictt1,1)*1e3,R.AnkleInGround.position.r(ictt1,2)*1e3,'d','DisplayName','Ankle');
%             hold on
%             plot(R.COPR(ictt1,1)*1e3,R.COPR(ictt1,2)*1e3,'o','DisplayName','COP');
%             plot(grfx',grfy','-','DisplayName','GRF');
%             grid on
%             axis equal
%             xlabel('fore-after (mm)')
%             ylabel('vertical (mm)')
%             title('Centre of pressure during stance')
            
%         end
%         
%         if inr==nr && ~strcmp(figNamePrefix,'none')
%             set(h8,'PaperPositionMode','auto')
%             print(h8,[figNamePrefix '_COP'],'-dpng','-r0')
% %             print(h8,[figNamePrefix '_COP'],'-depsc')
%         end
%         
%     end
    
    
    %% all
    if makeplot.allQsTs
        if inr==1
            h9 = figure('Position',[fpos(3,:),fhigh1]);
            h10 = figure('Position',[fpos(4,:),fhigh1]);
        end
        
        if has_no_tmt && has_no_mtj
            idx_Qs = [4,5,6,1,2,3,10,11,12,14,16,18,20,21,22,23,27,28,29,31];
        else
            idx_Qs = [4,5,6,1,2,3,10,11,12,14,16,18,20,22,23,24,25,29,30,31,33];
        end
        idx_title = [4,5,6,1,2,3,10,11,12,14,16,18,20,24,25,26,27,31,32,33,35];
        joints_ref = {'pelvis_tx','pelvis_ty','pelvis_tz',...
                'pelvis_tilt','pelvis_list','pelvis_rotation',...
                'hip_flexion','hip_adduction','hip_rotation',...
                'knee_angle','ankle_angle','subtalar_angle','mtj_angle','mtp_angle',...
                'lumbar_extension','lumbar_bending','lumbar_rotation',...
                'arm_flex','arm_add','arm_rot','elbow_flex'};
        
        joints_tit = {'Pelvis tilt','Pelvis list','Pelvis rotation','Pelvis tx',...
                'Pelvis ty','Pelvis tz','Hip flexion L','Hip adduction L',...
                'Hip rotation L','Hip flexion R','Hip adduction R','Hip rotation R',...
                'Knee L','Knee R','Ankle L','Ankle R','Subtalar L','Subtalar R',...
                'Midtarsal L','Midtarsal R','Tmt L','Tmt R',...
                'Mtp L','Mtp R',...
                'Lumbar extension','Lumbar bending','Lumbar rotation',...
                'Arm flexion L','Arm adduction L','Arm rotation L',...
                'Arm flexion R','Arm adduction R','Arm rotation R',...
                'Elbow flexion L','Elbow flexion R'};
    
        figure(h9)
        
        j = 0;
        label_fontsize  = 12;
        line_linewidth  = 1;
        for i = 1:length(idx_title)
            subplot(7,3,i)
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            % Experimental data
            if  inr == 1 && md
                idx_jref = strcmp(Qref.colheaders,joints_ref{i});
                if sum(idx_jref) == 1
                    meanPlusSTD = (Qref.Qall_mean(:,idx_jref) + 2*Qref.Qall_std(:,idx_jref));
                    meanMinusSTD = (Qref.Qall_mean(:,idx_jref) - 2*Qref.Qall_std(:,idx_jref));

                    stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                    intervalQ = 1:stepQ:size(R.Qs,1);
                    sampleQ = 1:size(R.Qs,1);
                    meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                    meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);

                    hold on
                    fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],...
                    'LineStyle','none','DisplayName','Experimental data (mean \pm 2 SD)');
                end
            end

            % Simulation results
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            hold on;
            axis tight
            xlim([0,100]);
            if (has_no_tmt && strcmp(joints_tit{idx_title(i)},'Tarsometatarsal R')) || ...
                    (has_no_mtj && strcmp(joints_tit{idx_title(i)},'Midtarsal R'))
                % skip this plot
            else
                j=j+1;
                plot(x,R.Qs(:,idx_Qs(j)),mrk{rem(inr-1,length(mrk))+1},'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                if makeplot.plot_bounds
                    yline(bounds_Qs_l(idx_Qs(j))*180/pi,'--','color',Cs)
                    yline(bounds_Qs_u(idx_Qs(j))*180/pi,'--','color',Cs)
                end

                if md
                    idx_jref = strcmp(Qref.colheaders,joints_ref{i});
                    if rmse_stance_only
                        Q_jref0 = Qref.Qall_mean(istance0_ref,idx_jref);
                        Q_jref1 = Qref.Qall_std(istance0_ref,idx_jref);
                        stepQ = (size(istance0,2)-1)/(size(Q_jref0,1)-1);
                        intervalQ = 1:stepQ:size(istance0,2);
                        sampleQ = 1:size(istance0,2);
                        Q_jref = interp1(intervalQ,Q_jref0,sampleQ);
                        Q_jrefw = interp1(intervalQ,Q_jref1,sampleQ);
                        Q_j_rmse = rms( ( Q_jref(:) - R.Qs(istance0,idx_Qs(j)) )./Q_jrefw' );
                        Q_j_R2 = corrcoef( Q_jref(:), R.Qs(istance0,idx_Qs(j)) );

                        if isnan(Q_j_rmse)
                            Q_j_rmse = rms( ( Q_jref(2:end) - R.Qs(istance0(2:end),idx_Qs(j))' )./Q_jrefw(2:end) );
                        end

                    elseif rmse_swing_only
                        Q_jref0 = Qref.Qall_mean((istance0_ref(end)+1):end,idx_jref);
                        Q_jref1 = Qref.Qall_std((istance0_ref(end)+1):end,idx_jref);
                        stepQ = (size(iswing,2)-1)/(size(Q_jref0,1)-1);
                        intervalQ = 1:stepQ:size(iswing,2);
                        sampleQ = 1:size(iswing,2);
                        Q_jref = interp1(intervalQ,Q_jref0,sampleQ);
                        Q_jrefw = interp1(intervalQ,Q_jref1,sampleQ);
                        Q_j_rmse = rms( ( Q_jref(:) - R.Qs(iswing,idx_Qs(j)) )./Q_jrefw' );
                        Q_j_R2 = corrcoef( Q_jref(:), R.Qs(iswing,idx_Qs(j)) );

                    else
                        Q_jref0 = Qref.Qall_mean(:,idx_jref);
                        Q_jref1 = Qref.Qall_std(:,idx_jref);
                        stepQ = (size(R.Qs,1)-1)/(size(Q_jref0,1)-1);
                        intervalQ = 1:stepQ:size(R.Qs,1);
                        sampleQ = 1:size(R.Qs,1);
                        Q_jref = interp1(intervalQ,Q_jref0,sampleQ);
                        Q_jrefw = interp1(intervalQ,Q_jref1,sampleQ);
                        Q_j_rmse = rms( ( Q_jref(:) - R.Qs(:,idx_Qs(j)) )./Q_jrefw' );
                        Q_j_R2 = corrcoef( Q_jref(:),R.Qs(:,idx_Qs(j)) );
                    end
                    Q_range(i) = max(Q_jref)-min(Q_jref);
%                     Q_j_rmse = Q_j_rmse/(max(Q_jref)-min(Q_jref));
                    if i==1
                        table_Q_rmse(inr,1).Name = LegName;
                        table_Q_R2(inr,1).Name = LegName;
                    end
                    table_Q_rmse(inr,1).(joints_ref{i}) = Q_j_rmse;
                    table_Q_R2(inr,1).(joints_ref{i}) = Q_j_R2(1,2);
                end

            end

            % Plot settings
            if inr==1
                set(gca,'Fontsize',label_fontsize);
                title(joints_tit{idx_title(i)},'Fontsize',label_fontsize);
                % Y-axis
                if i == 1
                    ylabel('Distance (m)','Fontsize',label_fontsize);
                end
                if i == 4 || i == 7 || i == 10 || i == 13 || i == 16 || i == 19
                    ylabel('Angle (°)','Fontsize',label_fontsize);
                end
                % X-axis
                L = get(gca,'XLim');
                NumTicks = 3;
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if i > 18
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
            end
            if inr==1 && i==1
                lhQ=legend('-DynamicLegend','location','northwest');
                lhQ.Interpreter = lgInt;
                lhQ.Orientation = 'horizontal';
                lhQ.NumColumns = ceil((nr+1)/2);
                lhQ.Box = 'off';
            end
            if inr==nr && i==1
                lhPos = lhQ.Position;
                lhPos(1) = lhPos(1)-0.1;
                lhPos(2) = lhPos(2)+0.08;
                set(lhQ,'position',lhPos);
            end
        end

        
        figure(h10)


        if has_no_tmt && has_no_mtj
            idx_Qs = [10,11,12,14,16,18,20,21,22,23];
        else
            idx_Qs = [10,11,12,14,16,18,20,22,23,24,25];
        end
        idx_title = [10,11,12,14,16,18,20,24,25,26,27];
        joints_ref = {'hip_flexion','hip_adduction','hip_rotation',...
                'knee_angle','ankle_angle','subtalar_angle','mtj_angle','mtp_angle',...
                'lumbar_extension','lumbar_bending','lumbar_rotation'};
        


        j = 0;
        label_fontsize  = 12;
        line_linewidth  = 1;
        for i = 1:length(idx_title)
            if i>8
                subplot(6,3,i+1)
            else
                subplot(6,3,i)
            end
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            % Experimental data
            if  inr == 1 && md
                idx_jref = strcmp(Tref.colheaders,joints_ref{i});
                if contains(joints_ref{i},'mtj') || contains(joints_ref{i},'mtp')
                    idx_jref = 0;
                end
                if sum(idx_jref) == 1
                    meanPlusSTD = Tref.Tall_mean(:,idx_jref) + 2*Tref.Tall_std(:,idx_jref);
                    meanMinusSTD = Tref.Tall_mean(:,idx_jref) - 2*Tref.Tall_std(:,idx_jref);

                    stepID = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                    intervalID = 1:stepID:size(R.Qs,1);
                    sampleID = 1:size(R.Qs,1);
                    meanPlusSTD = interp1(intervalID,meanPlusSTD,sampleID)/R.body_mass;
                    meanMinusSTD = interp1(intervalID,meanMinusSTD,sampleID)/R.body_mass;
                    hold on
                    fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],0.8*[1,1,1],...
                    'LineStyle','none','DisplayName','Experimental data (mean \pm 2 SD)');
                end
            end

            % Simulation results
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            hold on;
            axis tight
            xlim([0,100]);
            if (has_no_tmt && strcmp(joints_tit{idx_title(i)},'Tarsometatarsal R')) || ...
                    (has_no_mtj && strcmp(joints_tit{idx_title(i)},'Midtarsal R'))
                % skip this plot
            else
                j=j+1;
                plot(x,R.Tid(:,idx_Qs(j))/R.body_mass,mrk{rem(inr-1,length(mrk))+1},'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            
                if md
                    idx_jref = strcmp(Tref.colheaders,joints_ref{i});
                    if sum(idx_jref) == 1
                        if rmse_stance_only
                            T_jref0 = Tref.Tall_mean(istance0_ref,idx_jref);
                            T_jref1 = Tref.Tall_std(istance0_ref,idx_jref);
                            stepID = (size(istance0,2)-1)/(size(T_jref0,1)-1);
                            intervalID = 1:stepID:size(istance0,2);
                            sampleID = 1:size(istance0,2);
                            T_jref = interp1(intervalID,T_jref0,sampleID);
                            T_jrefw = interp1(intervalID,T_jref1,sampleID);
                            T_j_rmse = rms( ( T_jref(:) - R.Tid(istance0,idx_Qs(j)) )./T_jrefw' );
                            T_j_R2 = corrcoef( T_jref(:),R.Tid(istance0,idx_Qs(j)) );

                        elseif rmse_swing_only
                            T_jref0 = Tref.Tall_mean((istance0_ref(end)+1):end,idx_jref);
                            T_jref1 = Tref.Tall_std((istance0_ref(end)+1):end,idx_jref);
                            stepID = (size(iswing,2)-1)/(size(T_jref0,1)-1);
                            intervalID = 1:stepID:size(iswing,2);
                            sampleID = 1:size(iswing,2);
                            T_jref = interp1(intervalID,T_jref0,sampleID);
                            T_jrefw = interp1(intervalID,T_jref1,sampleID);
                            T_j_rmse = rms( ( T_jref(:) - R.Tid(iswing,idx_Qs(j)) )./T_jrefw' );
                            T_j_R2 = corrcoef( T_jref(:),R.Tid(iswing,idx_Qs(j)) );

                        else
                            T_jref0 = Tref.Tall_mean(:,idx_jref);
                            T_jref1 = Tref.Tall_std(:,idx_jref);
                            stepID = (size(R.Qs,1)-1)/(size(T_jref0,1)-1);
                            intervalID = 1:stepID:size(R.Qs,1);
                            sampleID = 1:size(R.Qs,1);
                            T_jref = interp1(intervalID,T_jref0,sampleID);
                            T_jrefw = interp1(intervalID,T_jref1,sampleID);
                            T_j_rmse = rms( ( T_jref(:) - R.Tid(:,idx_Qs(j)) )./T_jrefw' );
                            T_j_R2 = corrcoef( T_jref(:),R.Tid(:,idx_Qs(j)) );
                        end
                        T_range(i) = max(T_jref)-min(T_jref);
%                         T_j_rmse = T_j_rmse/(max(T_jref)-min(T_jref));
                    else
                        T_j_rmse = [];
                    end
                    if i==1
                        table_T_rmse(inr,1).Name = LegName;
                        table_T_rR2(inr,1).Name = LegName;
                    end
                    table_T_rmse(inr,1).(joints_ref{i}) = T_j_rmse;
                    table_T_R2(inr,1).(joints_ref{i}) = T_j_R2(1,2);
                end
            end
            % Plot settings
            if inr==1
                % Plot settings
                set(gca,'Fontsize',label_fontsize);
                title(joints_tit{idx_title(i)},'Fontsize',label_fontsize);
                % Y-axis
                if i == 1 || i == 4 || i == 7 || i == 9
                    ylabel('(Nm/kg)','Fontsize',label_fontsize);
                end
                % X-axis
                L = get(gca,'XLim');
                NumTicks = 3;
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if i > 8
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
            end
            if inr==1 && i==1
                lhT=legend('-DynamicLegend','location','northwest');
                lhT.Interpreter = lgInt;
                lhT.Orientation = 'horizontal';
                lhT.NumColumns = ceil((nr+1)/2);
                lhT.Box = 'off';
            end
            if inr==nr && i==1
                lhPos = lhT.Position;
                lhPos(1) = lhPos(1)-0.1;
                lhPos(2) = lhPos(2)+0.08;
                set(lhT,'position',lhPos);
            end
        end 
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h9,'PaperPositionMode','auto')
            print(h9,[figNamePrefix '_qs_all'],'-dpng','-r0')
%             print(h9,[figNamePrefix '_qs_all'],'-depsc')
            set(h10,'PaperPositionMode','auto')
            print(h10,[figNamePrefix '_Ts_all'],'-dpng','-r0')
%             print(h10,[figNamePrefix '_Ts_all'],'-depsc')
        end
        
    end
        
    %% all
    if makeplot.allQdots
        if inr==1
            h9b = figure('Position',[fpos(3,:),fhigh1]);
        end
        
        if has_no_tmt && has_no_mtj
            idx_Qs = [1,2,3,10,11,12,14,16,18,20,21,22,23,27,28,29,31];
        else
            idx_Qs = [1,2,3,10,11,12,14,16,18,20,22,23,24,25,29,30,31,33];
        end
        idx_title = [1,2,3,10,11,12,14,16,18,20,24,25,26,27,31,32,33,35];
        joints_ref = {'pelvis_tilt','pelvis_list','pelvis_rotation',...
                'hip_flexion','hip_adduction','hip_rotation',...
                'knee_angle','ankle_angle','subtalar_angle','mtj_angle','mtp_angle',...
                'lumbar_extension','lumbar_bending','lumbar_rotation',...
                'arm_flex','arm_add','arm_rot','elbow_flex'};
        
        joints_tit = {'Pelvis tilt','Pelvis list','Pelvis rotation','Pelvis tx',...
                'Pelvis ty','Pelvis tz','Hip flexion L','Hip adduction L',...
                'Hip rotation L','Hip flexion R','Hip adduction R','Hip rotation R',...
                'Knee L','Knee R','Ankle L','Ankle R','Subtalar L','Subtalar R',...
                'Midtarsal L','Midtarsal R','Tmt L','Tmt R',...
                'Mtp L','Mtp R',...
                'Lumbar extension','Lumbar bending','Lumbar rotation',...
                'Arm flexion L','Arm adduction L','Arm rotation L',...
                'Arm flexion R','Arm adduction R','Arm rotation R',...
                'Elbow flexion L','Elbow flexion R'};
    
        figure(h9b)
        
        j = 0;
        label_fontsize  = 12;
        line_linewidth  = 0.5;
        for i = 1:length(idx_title)
            subplot(6,3,i)
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            % Experimental data
            if  inr == 1 && md
                idx_jref = strcmp(Qref.colheaders,joints_ref{i});
                if sum(idx_jref) == 1
                    meanPlusSTD = (Qref.Qdotall_mean(:,idx_jref) + 2*Qref.Qdotall_std(:,idx_jref));
                    meanMinusSTD = (Qref.Qdotall_mean(:,idx_jref) - 2*Qref.Qdotall_std(:,idx_jref));

                    stepQdot = (size(R.Qddots,1)-1)/(size(meanPlusSTD,1)-1);
                    intervalQdot = 1:stepQdot:size(R.Qddots,1);
                    sampleQdot = 1:size(R.Qddots,1);
                    meanPlusSTD = interp1(intervalQdot,meanPlusSTD,sampleQdot);
                    meanMinusSTD = interp1(intervalQdot,meanMinusSTD,sampleQdot);

                    hold on
                    fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName',['MoCap ' refName]);
                    alpha(.25);
                end
            end

            % Simulation results
            
            hold on;
            axis tight
            xlim([0,100]);
            if (has_no_tmt && strcmp(joints_tit{idx_title(i)},'Tarsometatarsal R')) || ...
                    (has_no_mtj && strcmp(joints_tit{idx_title(i)},'Midtarsal R'))
                % skip this plot
            else
                j=j+1;
                plot(x,R.Qdots(:,idx_Qs(j)),'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                if makeplot.plot_bounds
                    yline(bounds_Qdots_l(idx_Qs(j))*180/pi,'--','color',Cs)
                    yline(bounds_Qdots_u(idx_Qs(j))*180/pi,'--','color',Cs)
                end
            end

            % Plot settings
            if inr==1
                set(gca,'Fontsize',label_fontsize);
                title(joints_tit{idx_title(i)},'Fontsize',label_fontsize);
                % Y-axis
                if i == 1 || i == 4 || i == 7 || i == 10 || i == 13 || i == 16
                    ylabel('Velocity (°/s)','Fontsize',label_fontsize);
                end
                % X-axis
                L = get(gca,'XLim');
                NumTicks = 3;
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if i > 15
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
            end
            if inr==1 && i==1
                lhQ=legend('-DynamicLegend','location','northwest');
                lhQ.Interpreter = lgInt;
                lhQ.Orientation = 'horizontal';
                lhQ.NumColumns = ceil((nr+1)/2);
            end
            if inr==nr && i==1
                lhPos = lhQ.Position;
                lhPos(1) = lhPos(1)-0.1;
                lhPos(2) = lhPos(2)+0.08;
                set(lhQ,'position',lhPos);
            end
        end

        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h9b,'PaperPositionMode','auto')
            print(h9b,[figNamePrefix '_qds_all'],'-dpng','-r0')
%             print(h9b,[figNamePrefix '_qds_all'],'-depsc')
            
        end
    end

    %% all
    if makeplot.allQddots
        if inr==1
            h9a = figure('Position',[fpos(3,:),fhigh1]);
        end
        
        if has_no_tmt && has_no_mtj
            idx_Qs = [1,2,3,10,11,12,14,16,18,20,21,22,23,27,28,29,31];
        else
            idx_Qs = [1,2,3,10,11,12,14,16,18,20,22,23,24,25,29,30,31,33];
        end
        idx_title = [1,2,3,10,11,12,14,16,18,20,24,25,26,27,31,32,33,35];
        joints_ref = {'pelvis_tilt','pelvis_list','pelvis_rotation',...
                'hip_flexion','hip_adduction','hip_rotation',...
                'knee_angle','ankle_angle','subtalar_angle','mtj_angle','mtp_angle',...
                'lumbar_extension','lumbar_bending','lumbar_rotation',...
                'arm_flex','arm_add','arm_rot','elbow_flex'};
        
        joints_tit = {'Pelvis tilt','Pelvis list','Pelvis rotation','Pelvis tx',...
                'Pelvis ty','Pelvis tz','Hip flexion L','Hip adduction L',...
                'Hip rotation L','Hip flexion R','Hip adduction R','Hip rotation R',...
                'Knee L','Knee R','Ankle L','Ankle R','Subtalar L','Subtalar R',...
                'Midtarsal L','Midtarsal R','Tmt L','Tmt R',...
                'Mtp L','Mtp R',...
                'Lumbar extension','Lumbar bending','Lumbar rotation',...
                'Arm flexion L','Arm adduction L','Arm rotation L',...
                'Arm flexion R','Arm adduction R','Arm rotation R',...
                'Elbow flexion L','Elbow flexion R'};
    
        figure(h9a)
        
        j = 0;
        label_fontsize  = 12;
        line_linewidth  = 0.5;
        for i = 1:length(idx_title)
            subplot(6,3,i)
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            % Experimental data
            if  inr == 1 && md
                idx_jref = strcmp(Qref.colheaders,joints_ref{i});
                if sum(idx_jref) == 1
                    meanPlusSTD = (Qref.Qddotall_mean(:,idx_jref) + 2*Qref.Qddotall_std(:,idx_jref));
                    meanMinusSTD = (Qref.Qddotall_mean(:,idx_jref) - 2*Qref.Qddotall_std(:,idx_jref));

                    stepQddot = (size(R.Qddots,1)-1)/(size(meanPlusSTD,1)-1);
                    intervalQddot = 1:stepQddot:size(R.Qddots,1);
                    sampleQddot = 1:size(R.Qddots,1);
                    meanPlusSTD = interp1(intervalQddot,meanPlusSTD,sampleQddot);
                    meanMinusSTD = interp1(intervalQddot,meanMinusSTD,sampleQddot);

                    hold on
                    fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName',['MoCap ' refName]);
                    alpha(.25);
                end
            end

            % Simulation results
            
            hold on;
            axis tight
            xlim([0,100]);
            if (has_no_tmt && strcmp(joints_tit{idx_title(i)},'Tarsometatarsal R')) || ...
                    (has_no_mtj && strcmp(joints_tit{idx_title(i)},'Midtarsal R'))
                % skip this plot
            else
                j=j+1;
                plot(x,R.Qddots(:,idx_Qs(j))*180/pi,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                if makeplot.plot_bounds
                    yline(bounds_Qddots_l(idx_Qs(j))*180/pi,'--','color',Cs)
                    yline(bounds_Qddots_u(idx_Qs(j))*180/pi,'--','color',Cs)
                end
            end

            % Plot settings
            if inr==1
                set(gca,'Fontsize',label_fontsize);
                title(joints_tit{idx_title(i)},'Fontsize',label_fontsize);
                % Y-axis
                if i == 1 || i == 4 || i == 7 || i == 10 || i == 13 || i == 16
                    ylabel('Acceleration (°/s^2)','Fontsize',label_fontsize);
                end
                % X-axis
                L = get(gca,'XLim');
                NumTicks = 3;
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if i > 15
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
            end
            if inr==1 && i==1
                lhQ=legend('-DynamicLegend','location','northwest');
                lhQ.Interpreter = lgInt;
                lhQ.Orientation = 'horizontal';
                lhQ.NumColumns = ceil((nr+1)/2);
            end
            if inr==nr && i==1
                lhPos = lhQ.Position;
                lhPos(1) = lhPos(1)-0.1;
                lhPos(2) = lhPos(2)+0.08;
                set(lhQ,'position',lhPos);
            end
        end

        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(ha9,'PaperPositionMode','auto')
            print(h9a,[figNamePrefix '_qdds_all'],'-dpng','-r0')
%             print(h9a,[figNamePrefix '_qdds_all'],'-depsc')
            
        end
    end
    
        %% all
    if makeplot.allPs
        if inr==1
            h9d = figure('Position',[fpos(3,:),fhigh1]);
        end
        
        if has_no_tmt && has_no_mtj
            idx_Qs = [1,2,3,10,11,12,14,16,18,20,21,22,23,27,28,29,31];
        else
            idx_Qs = [1,2,3,10,11,12,14,16,18,20,22,23,24,25,29,30,31,33];
        end
        idx_title = [1,2,3,10,11,12,14,16,18,20,24,25,26,27,31,32,33,35];
        joints_ref = {'pelvis_tilt','pelvis_list','pelvis_rotation',...
                'hip_flexion','hip_adduction','hip_rotation',...
                'knee_angle','ankle_angle','subtalar_angle','mtj_angle0','mtp_angle0',...
                'lumbar_extension','lumbar_bending','lumbar_rotation',...
                'arm_flex','arm_add','arm_rot','elbow_flex'};
        
        joints_tit = {'Pelvis tilt','Pelvis list','Pelvis rotation','Pelvis tx',...
                'Pelvis ty','Pelvis tz','Hip flexion L','Hip adduction L',...
                'Hip rotation L','Hip flexion R','Hip adduction R','Hip rotation R',...
                'Knee L','Knee R','Ankle L','Ankle R','Subtalar L','Subtalar R',...
                'Midtarsal L','Midtarsal R','Tmt L','Tmt R',...
                'Mtp L','Mtp R',...
                'Lumbar extension','Lumbar bending','Lumbar rotation',...
                'Arm flexion L','Arm adduction L','Arm rotation L',...
                'Arm flexion R','Arm adduction R','Arm rotation R',...
                'Elbow flexion L','Elbow flexion R'};
    
        figure(h9d)
        
        j = 0;
        label_fontsize  = 12;
        line_linewidth  = 0.5;
        for i = 1:length(idx_title)
            subplot(6,3,i)
            x = 1:(100-1)/(size(R.Qs,1)-1):100;
            % Experimental data
            if  inr == 1 && md
                idx_jref = strcmp(Pref.colheaders,joints_ref{i});
                if sum(idx_jref) == 1
                    meanPlusSTD = (Pref.Pall_mean(:,idx_jref) + 2*Pref.Pall_std(:,idx_jref));
                    meanMinusSTD = (Pref.Pall_mean(:,idx_jref) - 2*Pref.Pall_std(:,idx_jref));

                    stepQddot = (size(R.Qddots,1)-1)/(size(meanPlusSTD,1)-1);
                    intervalQddot = 1:stepQddot:size(R.Qddots,1);
                    sampleQddot = 1:size(R.Qddots,1);
                    meanPlusSTD = interp1(intervalQddot,meanPlusSTD,sampleQddot)/R.body_mass;
                    meanMinusSTD = interp1(intervalQddot,meanMinusSTD,sampleQddot)/R.body_mass;

                    hold on
                    fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName',['MoCap ' refName]);
                    alpha(.25);
                end
            end

            % Simulation results
            
            hold on;
            axis tight
            xlim([0,100]);
            if (has_no_tmt && strcmp(joints_tit{idx_title(i)},'Tarsometatarsal R')) || ...
                    (has_no_mtj && strcmp(joints_tit{idx_title(i)},'Midtarsal R'))
                % skip this plot
            else
                j=j+1;
                plot(x,R.Qdots(:,idx_Qs(j)).*R.Tid(:,idx_Qs(j))*pi/180/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                
                if md
                    idx_jref = strcmp(Pref.colheaders,joints_ref{i});
                    if sum(idx_jref) == 1
                        if rmse_stance_only
                            P_jref0 = Pref.Pall_mean(istance0_ref,idx_jref);
                            P_jref1 = Pref.Pall_std(istance0_ref,idx_jref);
                            stepID = (size(istance0,2)-1)/(size(P_jref0,1)-1);
                            intervalID = 1:stepID:size(istance0,2);
                            sampleID = 1:size(istance0,2);
                            P_jref = interp1(intervalID,P_jref0,sampleID);
                            P_jrefw = interp1(intervalID,P_jref1,sampleID);
                            Pji = R.Qdots(istance0,idx_Qs(j)).*R.Tid(istance0,idx_Qs(j))*pi/180;
                            P_j_rmse = rms( ( P_jref(:) - R.Qdots(istance0,idx_Qs(j)).*R.Tid(istance0,idx_Qs(j))*pi/180 )./P_jrefw' );
                            P_j_R2 = corrcoef( P_jref, Pji);

                        elseif rmse_swing_only
                            P_jref0 = Pref.Pall_mean((istance0_ref(end)+1):end,idx_jref);
                            P_jref1 = Pref.Pall_std((istance0_ref(end)+1):end,idx_jref);
                            stepID = (size(iswing,2)-1)/(size(P_jref0,1)-1);
                            intervalID = 1:stepID:size(iswing,2);
                            sampleID = 1:size(iswing,2);
                            P_jref = interp1(intervalID,P_jref0,sampleID);
                            P_jrefw = interp1(intervalID,P_jref1,sampleID);
                            Pji = R.Qdots(iswing,idx_Qs(j)).*R.Tid(iswing,idx_Qs(j))*pi/180;
                            P_j_rmse = rms( ( P_jref(:) - R.Qdots(iswing,idx_Qs(j)).*R.Tid(iswing,idx_Qs(j))*pi/180 )./P_jrefw' );
                            P_j_R2 = corrcoef( P_jref, Pji);

                        else
                            P_jref0 = Pref.Pall_mean(:,idx_jref);
                            P_jref1 = Pref.Pall_std(:,idx_jref);
                            stepID = (size(R.Qs,1)-1)/(size(P_jref0,1)-1);
                            intervalID = 1:stepID:size(R.Qs,1);
                            sampleID = 1:size(R.Qs,1);
                            P_jref = interp1(intervalID,P_jref0,sampleID);
                            P_jrefw = interp1(intervalID,P_jref1,sampleID);
                            Pji = R.Qdots(:,idx_Qs(j)).*R.Tid(:,idx_Qs(j))*pi/180;
                            P_j_rmse = rms( ( P_jref(:) - R.Qdots(:,idx_Qs(j)).*R.Tid(:,idx_Qs(j))*pi/180 )./P_jrefw' );
                            P_j_R2 = corrcoef( P_jref(:), Pji);
                        end
                        P_range(i) = max(P_jref)-min(P_jref);
%                         P_j_rmse = P_j_rmse/(max(P_jref)-min(P_jref));
                    else
                        P_j_rmse = [];
                    end
                    if i==1
                        table_P_rmse(inr,1).Name = LegName;
                        table_P_R2(inr,1).Name = LegName;
                    end
                    table_P_rmse(inr,1).(joints_ref{i}) = P_j_rmse;
                    table_P_R2(inr,1).(joints_ref{i}) = P_j_R2(1,2);
                end
            end

            % Plot settings
            if inr==1
                set(gca,'Fontsize',label_fontsize);
                title(joints_tit{idx_title(i)},'Fontsize',label_fontsize);
                % Y-axis
                if i == 1 || i == 4 || i == 7 || i == 10 || i == 13 || i == 16
                    ylabel('Power (W/kg)','Fontsize',label_fontsize);
                end
                % X-axis
                L = get(gca,'XLim');
                NumTicks = 3;
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if i > 15
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
            end
            if inr==1 && i==1
                lhQ=legend('-DynamicLegend','location','northwest');
                lhQ.Interpreter = lgInt;
                lhQ.Orientation = 'horizontal';
                lhQ.NumColumns = ceil((nr+1)/2);
            end
            if inr==nr && i==1
                lhPos = lhQ.Position;
                lhPos(1) = lhPos(1)-0.1;
                lhPos(2) = lhPos(2)+0.08;
                set(lhQ,'position',lhPos);
            end
        end

        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h9d,'PaperPositionMode','auto')
            print(h9d,[figNamePrefix '_P_all'],'-dpng','-r0')
%             print(h9d,[figNamePrefix '_P_all'],'-depsc')
            
        end
    end

    %%
%     x = 1:(100-1)/(size(R.Qs,1)-1):100;
%     if makeplot.k_mtj_lin
%         if inr==1
%             h11 = figure('Position',[fpos(4,:),fwide]);
%         end
%         
%         imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
%         iankle = strcmp(R.colheaders.joints,'ankle_angle_r');
%         isubt = strcmp(R.colheaders.joints,'subtalar_angle_r');
%         imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));
%         
%     
%         if ~isempty(imtj) && (R.S.MT_li_nonl == 0 || strcmp(R.S.mtj_stiffness,'signed_lin'))
%         
%             W_ankle = zeros(length(x),1);
%             W_subt = zeros(length(x),1);
%             W_mtp = zeros(length(x),1);
%             W_mtj = zeros(length(x),1);
%             
%             for ii=2:length(x)
%                W_ankle(ii) = trapz(R.Qs(1:ii,iankle)*pi/180,R.Tid(1:ii,iankle));
%                W_subt(ii) = trapz(R.Qs(1:ii,isubt)*pi/180,R.Tid(1:ii,isubt));
%                W_mtp(ii) = trapz(R.Qs(1:ii,imtp)*pi/180,R.Tid(1:ii,imtp));
%                W_mtj(ii) = trapz(R.Qs(1:ii,imtj)*pi/180,R.Tid(1:ii,imtj));
%             end
%             W_mtj(2:end) = (W_mtj(2:end)-W_mtj(2))/R.body_mass;
%             W_ankle(2:end) = (W_ankle(2:end)-W_ankle(2))/R.body_mass;
%             W_subt(2:end) = (W_subt(2:end)-W_subt(2))/R.body_mass;
%             W_mtp(2:end) = (W_mtp(2:end)-W_mtp(2))/R.body_mass;
%             W_tot = W_mtj + W_ankle + W_subt + W_mtp;
%             
%             figure(h11)
%             subplot(2,4,1)
%             hold on
%             grid on
%             plot(R.S.kMT_li,W_tot(end),'o','Color',Cs,'MarkerFaceColor',Cs)
%             ylabel('Work (J/kg)')
%             title('W_{mech} foot (1 GC)')
% 
%             
% 
%             subplot(2,4,5)
%             hold on
%             grid on
%             plot(R.S.kMT_li,R.COT*dist_trav,'o','Color',Cs,'MarkerFaceColor',Cs)
%             xlabel('mtj stiffness (Nm/rad)')
%             ylabel('Metab. Energy (J/kg)')
%             title('E_{metab} foot (1 GC)')
% 
%             subplot(2,4,2)
%             hold on
%             grid on
%             plot(R.S.kMT_li,W_tot(end)/dist_trav,'o','Color',Cs,'MarkerFaceColor',Cs)
%             ylabel('Work (J/(kg m))')
%             title({'W_{mech} foot (1 m)'})
% 
%             subplot(2,4,6)
%             hold on
%             grid on
%             plot(R.S.kMT_li,R.COT,'o','Color',Cs,'MarkerFaceColor',Cs)
%             xlabel('mtj stiffness (Nm/rad)')
%             ylabel('COT (J/(kg m)')
%             title('Cost of transport')
% 
% 
%             subplot(2,4,3)
%             hold on
%             grid on
%             plot(R.S.kMT_li,max(R.Qs(:,imtj)),'o','Color',Cs,'MarkerFaceColor',Cs)
%             ylabel('angle (°)')
%             title({'Max mtj angle'})
%         
%             subplot(2,4,7)
%             hold on
%             grid on
%             plot(R.S.kMT_li,min(R.Qs(:,imtj)),'o','Color',Cs,'MarkerFaceColor',Cs)
%             xlabel('mtj stiffness (Nm/rad)')
%             ylabel('angle (°)')
%             title({'Min mtj angle'})
%             
%             subplot(2,4,4)
%             hold on
%             grid on
%             plot(R.S.kMT_li,max(R.Qs(:,imtp)),'o','Color',Cs,'MarkerFaceColor',Cs)
%             ylabel('angle (°)')
%             title({'Max mtp angle'})
%         
%             subplot(2,4,8)
%             hold on
%             grid on
%             plot(R.S.kMT_li,min(R.Qs(:,imtp)),'o','Color',Cs,'MarkerFaceColor',Cs)
%             xlabel('mtj stiffness (Nm/rad)')
%             ylabel('angle (°)')
%             title({'Min mtp angle'})
%             
%         end
%         
%         if inr==nr && ~strcmp(figNamePrefix,'none')
%             set(h11,'PaperPositionMode','auto')
%             print(h11,[figNamePrefix '_k_mtj_lin'],'-dpng','-r0')
%         end
%         
%     end
       
    %% Windlass
    if makeplot.windlass
        if inr==1
            h12 = figure('Position',[fpos(4,:),fhigh]);
        end
        
        figure(h12)
        F_At = R.FT(:,iSol)+R.FT(:,iGas)+R.FT(:,iGas2);
     
        imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));

        if ~isempty(imtj)
%             F_PF = R.windlass.F_PF;
%             l_PF = R.windlass.l_PF;
            if isfield(R.windlass,'foot_arch_height')
                h_fa = R.windlass.foot_arch_height;
            else
                h_fa = zeros(size(l_PF)); % to do: add this to prost-processing
            end
            if isfield(R.windlass,'sf_PF')
                PF_sf_var = R.windlass.sf_PF;
            else
                PF_sf_var = ones(2*R.S.N,2)*R.S.Foot.PF_sf;
            end
            
            subplot(4,4,5)
            hold on
            plot(x,h_fa*1000,'color',Cs,'linewidth',line_linewidth)
            title('Foot arch height')
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('Height (mm)','Fontsize',label_fontsize);
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl(1)-yl(2)),yl(2)+0.1*norm(yl(1)-yl(2))])
            xlim([0,100])
        
            if max(F_PF) > 1 % else there is no PF
                subplot(4,4,1)
                hold on
                ls = R.S.Foot.PF_slack_length;
                PF_strain = (l_PF./ls-1)*100;
                plot(x,PF_strain,'color',Cs,'linewidth',line_linewidth)
                title('Plantar fascia strain')
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('Nominal strain (%)','Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])
                
                subplot(4,4,2)
                hold on
                plot(x,F_PF/(R.body_mass*9.81)*100,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                title('Plantar fascia force')
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('Force/BW (%)','Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])
                
                subplot(4,4,12)
                hold on
                plot(PF_strain,F_PF/(R.body_mass*9.81)*100,'color',Cs,'linewidth',line_linewidth,'LineStyle',mrk{rem(inr-1,length(mrk))+1},'DisplayName',LegName);
                title('Plantar fascia force-length')
                xlabel('Nominal strain (%)','Fontsize',label_fontsize);
                ylabel('Force/BW (%)','Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xl = get(gca, 'xlim');
                xlim([xl(1)-0.1*norm(xl),xl(2)+0.1*norm(xl)])

%                 subplot(2,4,3)
%                 hold on
%                 if R.S.Foot.PIM
%                     plot(x,F_PIM/(R.body_mass*9.81)*100,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
%                 end
%                 title('Plantar intr. musc. force')
%                 xlabel('Gait cycle (%)','Fontsize',label_fontsize);
%                 ylabel('Force/BW (%)','Fontsize',label_fontsize);
%                 axis tight
%                 yl = get(gca, 'ylim');
%                 ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
%                 xlim([0,100])
                
                subplot(4,4,3)
                hold on
                plot(x,M_mtj_PF,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                title('Plantar fascia moment mtj')
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('Moment (Nm)','Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])

%                 subplot(2,3,4)
%                 F_At = R.FT(:,iSol)+R.FT(:,iGas)+R.FT(:,iGas2);
%                 hold on
%                 plot(F_At(istance)*1e-3,F_PF(istance)*1e-3,'.','color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
%                 c = polyfit(F_At(istance),F_PF(istance),1);
%                 F_At_x = linspace(min(F_At(istance)),max(F_At(istance)),100);
%                 PF_At = polyval(c,F_At_x);
%                 plot(F_At_x*1e-3,PF_At*1e-3,'--','color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
%                 title('PF - Achilles force')
%                 xlabel('Achilles tendon force (kN)','Fontsize',label_fontsize);
%                 ylabel('PF force (kN)','Fontsize',label_fontsize);
%                 poly_1 = ['F_P_F = ' num2str(c(2),3) ' N + ' num2str(c(1),3) ' F_A_t'];
                
                subplot(4,4,7)
                hold on
                plot(x,PF_sf_var(:,1),'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                title('Plantar fascia scale factor')
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('scale factor (-)','Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,100])

%                 F_GRF = R.GRFs(iarch_stance,2)*R.body_mass*9.81/100;
%                 A_tmp = [F_GRF, F_At(iarch_stance)]\F_PF(iarch_stance);
%                 F_PF_est_1 = A_tmp(1)*F_GRF + A_tmp(2)*F_At(iarch_stance);
%                 F_PF_err_1 = norm(F_PF(iarch_stance)-F_PF_est_1);
%                 
%                 poly_PF_1 = ['F_P_F = ' num2str(A_tmp(1),3) ' GRF_y + ' num2str(A_tmp(2),3) ' F_A_t'];
%                 
%                 F_GRF = R.GRFs(istance0,2)*R.body_mass*9.81/100;
%                 A_tmp = [F_GRF, F_At(istance0)]\F_PF(istance0);
%                 F_PF_est_2 = A_tmp(1)*F_GRF + A_tmp(2)*F_At(istance0);
%                 F_PF_err_2 = norm(F_PF(istance0)-F_PF_est_2);
%                 
%                 poly_PF_2 = ['F_P_F = ' num2str(A_tmp(1),3) ' GRF_y + ' num2str(A_tmp(2),3) ' F_A_t'];
%                 
%                 F_GRF = R.GRFs(:,2)*R.body_mass*9.81/100;
%                 A_tmp = [F_GRF, F_At(:)]\F_PF(:);
%                 F_PF_est_3 = A_tmp(1)*F_GRF + A_tmp(2)*F_At(:);
%                 F_PF_err_3 = norm(F_PF-F_PF_est_3);
%                 
%                 poly_PF_3 = ['F_P_F = ' num2str(A_tmp(1),3) ' GRF_y + ' num2str(A_tmp(2),3) ' F_A_t'];
                
%                 disp(LegName)
%                 disp(poly_PF_1)
%                 disp(num2str(F_PF_err_1/length(F_PF_err_1)))
%                 disp(poly_PF_2)
%                 disp(num2str(F_PF_err_2/length(F_PF_err_2)))
%                 disp(poly_PF_3)
%                 disp(num2str(F_PF_err_3/length(F_PF_err_3)))
                
%                 subplot(2,3,6)
%                 hold on
%                 plot(x,F_PF/(R.body_mass*9.81/100),':','color',Cs,'linewidth',line_linewidth)
%                 plot(x(iarch_stance),F_PF_est_1/(R.body_mass*9.81/100),'--','color',Cs,'linewidth',line_linewidth)
                
%                 title('PF - At - GRF relation')
%                 xlabel('Gait cycle (%)','Fontsize',label_fontsize);
%                 ylabel('Force/BW (%)','Fontsize',label_fontsize);
                
%                 subplot(2,3,5)
%                 col_str = ['\color[rgb]{' num2str(Cs(1),2) ',' num2str(Cs(2),2) ',' num2str(Cs(3),2) '}'];
%                 if ~exist('polyNames','var')
%                     polyNames{1} = [col_str '\leftarrow - - \color{black}' poly_1];
%                     polyNames{2} = ['\color{black}' poly_PF_1 col_str ' - - \rightarrow'];
%                 else
%                     polyNames{end+1} = [col_str '\leftarrow - - \color{black}' poly_1];
%                     polyNames{end+1} = ['\color{black}' poly_PF_1 col_str ' - - \rightarrow'];
%                 end
%                 l_pn = length(polyNames);
%                 polyNamesPlot{1} = polyNames{l_pn-1};
%                 polyNamesPlot{2} = polyNames{l_pn};
%                 
%                 text(-0.2,1.2-0.18*length(polyNames),polyNamesPlot)
%                 axis off
%                 title('Polynomials')

                
                ccc(1,inr) = xcorr(F_PF,F_At,0,'coeff');
                ccc(2,inr) = xcorr(F_PF,R.Qs(:,imtj),0,'coeff');
                ccc(3,inr) = xcorr(F_PF,R.Qs(:,imtp),0,'coeff');
                ccc(4,inr) = xcorr(F_PF,R.GRFs_separate(:,2),0,'coeff');
                ccc(5,inr) = xcorr(F_PF,R.GRFs_separate(:,5),0,'coeff');
                ccc(6,inr) = xcorr(F_PF,R.GRFs_separate(:,8),0,'coeff');
                ccc_c(inr,:) = Cs;


                    
                f_plantar_quasi_stiffness = getPlantarQuasiStiffnessCasADiFunction(R.S);
                l_PF = R.windlass.l_PF;
                v_PF = R.windlass.v_PF;
                iFDB = find(strcmp(R.colheaders.muscles,'FDB_r'));
                a_FDB = R.a(:,iFDB);
                FTt_FDB = R.FTtilde(:,iFDB);
                dFTt_FDB = R.dFTtilde(:,iFDB);
                if f_plantar_quasi_stiffness.n_in == 2
                    pqs = full(f_plantar_quasi_stiffness(a_FDB,l_PF));
                else
                    pqs = full(f_plantar_quasi_stiffness(FTt_FDB,a_FDB,dFTt_FDB,l_PF,v_PF));
                end
                subplot(4,4,9)
                hold on
                plot(x,pqs,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('Quasi-stiffness (N/m)','Fontsize',label_fontsize);
                title('Plantar stiffness') 

                if isfield(R.S.Foot,'FDB') && R.S.Foot.FDB == 2
                    subplot(4,4,10)
                    hold on
                    F_FDB = R.FT(:,iFDB);
                    plot(x,F_FDB/(R.body_mass*9.81)*100,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                    ylabel('Force/BW (%)','Fontsize',label_fontsize);
                    title('PIM') 

                    subplot(4,4,14)
                    hold on
                    P_FDB = -v_PF.*R.FT(:,iFDB)/R.body_mass;
                    plot(x,P_FDB,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                    ylabel('Power (W/kg)','Fontsize',label_fontsize);
                    title('PIM')
                    plot(x,(-R.FT(:,iFDB).*R.vT(:,iFDB))/R.body_mass,'--','Color',CsV(inr,:));


                else
                    F_FDB = zeros(size(F_PF));
                    P_FDB = F_FDB;
                end

                subplot(4,4,13)
                hold on
                plot(x,P_PF,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('Power (W/kg)','Fontsize',label_fontsize);
                title('PF')

                subplot(4,4,15)
                hold on
                plot(x,(P_FDB+P_PF),'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('Power (W/kg)','Fontsize',label_fontsize);
                title('PF + PIM') 
    
                

                subplot(4,4,11)
                hold on
                plot(x,(F_FDB+F_PF)/(R.body_mass*9.81)*100,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('Force/BW (%)','Fontsize',label_fontsize);
                title('PF + PIM') 


%                 subplot(2,4,4)
%                 hold on
%                 plot(R.GRFs_separate(istance,2+3),F_PF(istance)/(R.body_mass*9.81/100),'.','color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
%                 title('PF force - forefoot GRF')
%                 xlabel('Vertical GRF/BW (%)','Fontsize',label_fontsize);
%                 ylabel('PF force/BW (%)','Fontsize',label_fontsize);
%                 
%                 subplot(2,4,8)
%                 hold on
%                 plot(R.GRFs_separate(istance,2+6),F_PF(istance)/(R.body_mass*9.81/100),'.','color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
%                 title('PF force - toe GRF')
%                 xlabel('Vertical GRF/BW (%)','Fontsize',label_fontsize);
%                 ylabel('PF force/BW (%)','Fontsize',label_fontsize);
                
            end

            subplot(4,4,16)
            hold on
            P_At = P_T_Sol+P_T_Gas+P_T_Gas2;
            plot(x,(P_At),'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('Power (W/kg)','Fontsize',label_fontsize);
            title('Achilles tendon') 

            subplot(4,4,8)
            hold on
            
            plot(R.Qs(ipush_off,imtp)-R.Qs(ipush_off(1),imtp),(h_fa(ipush_off)-h_fa(ipush_off(1)))*1e3,'-','Color',Cs)
            xlabel('\Delta mtp angle (°)')
            ylabel('\Delta arch height (mm)')
            grid on
            set(gca,'YAxisLocation','right')
            title('Push-off')
            axis tight
            yl = get(gca, 'ylim');
            xl = get(gca, 'xlim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([xl(1)-0.1*norm(xl),xl(2)+0.1*norm(xl)])
            
%             figure
%             plot(R.Qs(ipush_off,imtp)-R.Qs(ipush_off(1),imtp),log((h_fa(ipush_off)-h_fa(ipush_off(1)))*1e3),'Color',Cs)
        end
   
        figure(h12)
        if inr==nr && exist('ccc','var')
            subplot(4,4,4)
            cat_ccc = categorical({'Achilles force','Mtj angle','Mtp angle','GRF Heel','GRF Forefoot','GRF Toes'});
            cat_ccc = reordercats(cat_ccc,[1,3,2,4,5,6]);
            
            brc=bar(cat_ccc,ccc);
            for ibr=1:length(brc)
               brc(ibr).FaceColor = 'flat';
               brc(ibr).CData = ccc_c(ibr,:);
               
            end
            tmp=gca;
            tmp.XTickLabelRotation = 90;
            title('Relation to PF force')
            ylabel('R (-)')
            ylim([min(min(ccc))-0.05,1.05])
            
        end

        subplot(4,4,6)
        hold on
        plot(x,F_At/(R.body_mass*9.81)*100,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
        title('Achilles tendon')
        xlabel('Gait cycle (%)','Fontsize',label_fontsize);
        ylabel('Force/BW (%)','Fontsize',label_fontsize);
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
        xlim([0,100])
        if inr==nr
            lh12=legend('Location','northwest','Interpreter',lgInt);
            lhPos = lh12.Position;
            lhPos(1) = lhPos(1)+0.17;
            lhPos(2) = lhPos(2)+0.05;
            set(lh12,'position',lhPos);
            title(lh12,'Legend')
        end
        
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h12,'PaperPositionMode','auto')
            print(h12,[figNamePrefix '_WL'],'-dpng','-r0')
%             print(h12,[figNamePrefix '_WL'],'-depsc')
        end
        
     end


%%
    if makeplot.power
        if inr==1
            h14 = figure('Position',[fpos(4,:),fhigh]);
        end
        
        figure(h14)
        
        nh = 5;
        nw = 4;
        
        P_M_tri_sur = P_M_Sol+P_M_Gas+P_M_Gas2;
        P_At = P_T_Sol+P_T_Gas+P_T_Gas2;
        pos_P_all = {P_tot, P_joints, P_HC, 'none',...
                   P_HC_heel, P_HC_ball, P_HC_toes, P_leg_joints,...
                   P_ankle, P_subt, P_mtj, P_mtp,...
                   P_hip, P_knee, P_knee-P_M_triceps_knee, P_ankle-P_M_triceps_ankle,...
                   P_M_hamstrings,P_M_quadriceps_femoris,P_At,P_M_tri_sur};
               
        titles_P_all = {{'Ankle-foot','\fontsize{10}\rm joints + pads'},...
            {'Joints','\fontsize{10}\rm ankle + subt + mtj + mtp'},...
            {'Pads','\fontsize{10}\rm hindfoot + forefoot + toes'},...
            'none', {'Hindfoot','\fontsize{10}\rm (pads)'},{'Forefoot','\fontsize{10}\rm (pads)'},...
            {'Toes','\fontsize{10}\rm (pads)'},{'Joint total','\fontsize{10}\rm leg-foot'},...
            'Ankle','Subt','Mtj','Mtp',...
            'Hip','Knee',{'Knee w/o gastroc'},{'Ankle w/o gastroc, soleus'},...
            {'Hamstrings','\rm fibres, active'},{'Quadriceps femoris','\rm fibres, active'},{'Achilles tendon',''},{'Triceps surae','\rm fibres, active'}};
        
        for i_P=1:numel(pos_P_all)
            if ~strcmp(pos_P_all{i_P},'none')
                subplot(nh,nw,i_P)
                hold on
                grid on
%                 plot(xst_10,pos_P_all{i_P}(istance),'Color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                plot(x,pos_P_all{i_P}(:),'Color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                title(titles_P_all{i_P},'Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,110])
                set(gca,'XTick',[0:25:100])
                
                if mod(i_P-1,nw)==0
                    ylabel('P_{mech} (W/kg)','Fontsize',label_fontsize);
                end
                if i_P > nh*nw-nw
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
                if i_P==3 && inr==nr
                   lh14=legend('location','northwest','Interpreter',lgInt);
                   lhPos = lh14.Position;
                   lhPos(1) = lhPos(1)+0.2;
%                    lhPos(2) = lhPos(2)+0.05;
                   set(lh14,'position',lhPos);
                   title(lh14,'Legend')
                end
            end
        end
        
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h14,'PaperPositionMode','auto')
            print(h14,[figNamePrefix '_P1'],'-dpng','-r0')
%             print(h14,[figNamePrefix '_P1'],'-depsc')
        end
        
        %%
%         if inr==1
%             h15 = figure('Position',[fpos(3,:),fsq]);
%         end
%         
%         figure(h15)
%         
%         nh = 3;
%         nw = 4;
%         
%         pos_P_all = {P_hip,P_knee, P_ankle, P_subt,...
%             P_T_Sol, P_T_Gas, P_T_Gas2,P_T_Sol+P_T_Gas+P_T_Gas2,...
%             P_M_Sol, P_M_Gas, P_M_Gas2,P_M_Sol+P_M_Gas+P_M_Gas2};
%          
%         titles_P_all = {'Hip','Knee','Ankle','Subt',...
%             'Soleus tendon','Gas-med tendon','Gas-lat tendon',{'Sum Tendon','\fontsize{10}\rm sol + gas-med + gas-lat'},...
%             'Soleus fibres','Gas-med fibres','Gas-lat fibres',{'Sum fibres','\fontsize{10}\rm sol + gas-med + gas-lat'}};
%         
%         for i_P=1:numel(pos_P_all)
%             if ~strcmp(pos_P_all{i_P},'none')
%                 subplot(nh,nw,i_P)
%                 hold on
%                 grid on
%                 plot(xst,pos_P_all{i_P}(istance),'Color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
%                 title(titles_P_all{i_P},'Fontsize',label_fontsize);
%                 axis tight
%                 yl = get(gca, 'ylim');
%                 ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
%                 xlim([0,110,])
%                 
%                 if mod(i_P-1,nw)==0
%                     ylabel('P_{mech} (W/kg)','Fontsize',label_fontsize);
%                 end
%                 if i_P > nh*nw-nw
%                     xlabel('Stance phase (%)','Fontsize',label_fontsize);
%                 end
%             end
%         end
%         
%         if inr==nr && ~strcmp(figNamePrefix,'none')
%             set(h15,'PaperPositionMode','auto')
%             print(h15,[figNamePrefix '_P_ankle'],'-dpng','-r0')
% %             print(h15,[figNamePrefix '_P_ankle'],'-depsc')
%         end
        
%%
%         if inr==1
%             h16 = figure('Position',[fpos(3,:),fsq]);
%         end
%         
%         figure(h16)
%         
%         nh = 3;
%         nw = 4;
%         
%         if ~isempty(imtj)
%             pos_P_all = {P_mtj, P_mtp, P_mtj+P_mtp, 'none',...
%                 P_mtj-P_mtj_li, P_mtp_WL, P_PF, 'none',...
%                 P_mtj_li, P_mtp-P_mtp_WL, P_mtj+P_mtp-P_PF, 'none'};
%         else
%             pos_P_all = {P_mtj, P_mtp, P_mtj+P_mtp, 'none',...
%                 'none', 'none', 'none', 'none',...
%                 'none', 'none', 'none', 'none'};
%         end
%         
%                
%         titles_P_all = {'Mtj','Mtp',{'Sum','\fontsize{10}\rm mtj + mtj'},'none'...
%             'Mtj PF','Mtp PF','PF','none', 'Mtj non-PF','Mtp non-PF','Sum - PF','none'};
%         
%         for i_P=1:numel(pos_P_all)
%             if ~strcmp(pos_P_all{i_P},'none')
%                 subplot(nh,nw,i_P)
%                 hold on
%                 grid on
%                 plot(xst,pos_P_all{i_P}(istance),'Color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
%                 title(titles_P_all{i_P},'Fontsize',label_fontsize);
%                 axis tight
%                 yl = get(gca, 'ylim');
%                 ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
%                 xlim([0,110,])
%                 
%                 if mod(i_P-1,nw)==0
%                     ylabel('P_{mech} (W/kg)','Fontsize',label_fontsize);
%                 end
%                 if i_P > nh*nw-nw
%                     xlabel('Stance phase (%)','Fontsize',label_fontsize);
%                 end
%             end
%         end
%         
%          
%         
%         if inr==nr && ~strcmp(figNamePrefix,'none')
%             set(h16,'PaperPositionMode','auto')
%             print(h16,[figNamePrefix '_P_foot'],'-dpng','-r0')
% %             print(h16,[figNamePrefix '_P_foot'],'-depsc')
%         end
        

        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%
    %%
    if makeplot.work
        if inr==1
            h17 = figure('Position',[fpos(4,:),fsq]);
        end
        
        figure(h17)
        
        nh = 3;
        nw = 4;
        
        pos_P_all = {W_tot, W_joints, W_HC, 'none',...
                   W_HC_heel, W_HC_ball, W_HC_toes, 'none',...
                   W_ankle, W_subt, W_mtj, W_mtp};
               
        titles_P_all = {{'Ankle-foot','\fontsize{10}\rm joints + pads'},...
            {'Joints','\fontsize{10}\rm ankle + subt + mtj + mtp'},...
            {'Pads','\fontsize{10}\rm hindfoot + forefoot + toes'},...
            'none', 'Hindfoot','Forefoot','Toes','none',...
            'Ankle','Subt','Mtj','Mtp'};
        
        for i_P=1:numel(pos_P_all)
            if ~strcmp(pos_P_all{i_P},'none')
                subplot(nh,nw,i_P)
                hold on
                grid on
                plot(x,pos_P_all{i_P},'Color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                title(titles_P_all{i_P},'Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,110,])
                
                if mod(i_P-1,nw)==0
                    ylabel('W_{mech} (J/kg)','Fontsize',label_fontsize);
                end
                if i_P > nh*nw-nw
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
            end
        end
        
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h17,'PaperPositionMode','auto')
            print(h17,[figNamePrefix '_W1'],'-dpng','-r0')
%             print(h17,[figNamePrefix '_W1'],'-depsc')
        end
        
        %%
        if inr==1
            h18 = figure('Position',[fpos(3,:),fsq]);
        end
        
        figure(h18)
        
        nh = 3;
        nw = 4;
        
        pos_P_all = {W_knee, W_ankle, W_subt, W_knee+W_ankle+W_subt,...
            W_T_Sol, W_T_Gas, W_T_Gas2,W_T_Sol+W_T_Gas+W_T_Gas2,...
            W_M_Sol, W_M_Gas, W_M_Gas2,W_M_Sol+W_M_Gas+W_M_Gas2};
        
        
               
        titles_P_all = {'Knee','Ankle','Subt',{'Sum','\fontsize{10}\rm knee + ankle + subt'},...
            'Soleus tendon','Gas-med tendon','Gas-lat tendon',{'Sum Tendon','\fontsize{10}\rm sol + gas-med + gas-lat'},...
            'Soleus fibres','Gas-med fibres','Gas-lat fibres',{'Sum fibres','\fontsize{10}\rm sol + gas-med + gas-lat'}};
        
        for i_P=1:numel(pos_P_all)
            if ~strcmp(pos_P_all{i_P},'none')
                subplot(nh,nw,i_P)
                hold on
                grid on
                plot(x,pos_P_all{i_P},'Color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                title(titles_P_all{i_P},'Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,110,])
                
                if mod(i_P-1,nw)==0
                    ylabel('W_{mech} (J/kg)','Fontsize',label_fontsize);
                end
                if i_P > nh*nw-nw
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
            end
        end
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h18,'PaperPositionMode','auto')
            print(h18,[figNamePrefix '_W_ankle'],'-dpng','-r0')
%             print(h18,[figNamePrefix '_W_ankle'],'-depsc')
        end
        
%%
        if inr==1
            h19 = figure('Position',[fpos(3,:),fsq]);
        end
        
        figure(h19)
        
        nh = 3;
        nw = 4;
        
        if ~isempty(imtj)
            pos_P_all = {W_mtj, W_mtp, W_mtj+W_mtp, 'none',...
                W_mtj-W_li, W_mtp_WL, W_PF, 'none',...
                W_li, W_mtp-W_mtp_WL, 'none', 'none'};
        else
            pos_P_all = {W_mtj, W_mtp, W_mtj+W_mtp, 'none',...
                'none', 'none', 'none', 'none',...
                'none', 'none', 'none', 'none'};
        end
        
               
        titles_P_all = {'Mtj','Mtp',{'Sum','\fontsize{10}\rm mtj + mtj'},'none'...
            'Mtj PF','Mtp PF','PF','none', 'Mtj non-PF','Mtp non-PF','none','none'};
        
        for i_P=1:numel(pos_P_all)
            if ~strcmp(pos_P_all{i_P},'none')
                subplot(nh,nw,i_P)
                hold on
                grid on
                plot(x,pos_P_all{i_P},'Color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                title(titles_P_all{i_P},'Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
                xlim([0,110,])
                
                if mod(i_P-1,nw)==0
                    ylabel('W_{mech} (J/kg)','Fontsize',label_fontsize);
                end
                if i_P > nh*nw-nw
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
            end
        end
        
        if isfield(R,'GRFs_separate') && ~isempty(R.GRFs_separate)
            figure(h19)
            subplot(nh,nw,4)
            hold on
            grid on
            plot(xst_10,sum(R.GRFs_separate(istance,[2,5]),2),'Color',Cs);
%             plot(xst_10,R.GRFs_separate(istance,2),'Color',Cs);
            ylabel('% body weight','Fontsize',label_fontsize);
            title('Vertical GRF Heel')
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,110,])

            subplot(nh,nw,8)
            hold on
            grid on
            plot(xst_10,sum(R.GRFs_separate(istance,[8,11,14]),2),'Color',Cs);
%             plot(xst_10,R.GRFs_separate(istance,2+3),'Color',Cs);
            ylabel('% body weight','Fontsize',label_fontsize);
            title('Vertical GRF Forefoot')
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,110,])
            
            subplot(nh,nw,12)
            hold on
            grid on
            plot(xst_10,R.GRFs_separate(istance,17),'Color',Cs);
%             plot(xst_10,R.GRFs_separate(istance,2+6),'Color',Cs);
            xlabel('Stance phase (%)','Fontsize',label_fontsize);
            ylabel('% body weight','Fontsize',label_fontsize);
            title('Vertical GRF Toes')
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,110])
        end
        
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h19,'PaperPositionMode','auto')
            print(h19,[figNamePrefix '_W_foot'],'-dpng','-r0')
%             print(h19,[figNamePrefix '_W_foot'],'-depsc')
        end
        
    end
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        if makeplot.work_bar
            if inr == 1
                Ws_cat = categorical({'Hip','Knee','Ankle','Subt','Mtj',...
                    'Mtp','Joints total','Heel pad','Forefoot pad','Toes pad',...
                    'Achilles tendon','Plantar fascia','Plantar Intr. Mus.',...
                    'Foot deformation'});
                Ws_pos = zeros(length(Ws_cat),nr);
                Ws_neg = Ws_pos;
                Ws_pos_gc = Ws_pos;
                Ws_neg_gc = Ws_pos;
                Ws_net_gc = Ws_pos;
            end
%             % stance only
%             [W_hip_pos,W_hip_neg] = getWork(P_hip(istance),R.t(istance));
%             [W_knee_pos,W_knee_neg] = getWork(P_knee(istance),R.t(istance));
%             [W_ankle_pos,W_ankle_neg] = getWork(P_ankle(istance),R.t(istance));
%             [W_subt_pos,W_subt_neg] = getWork(P_subt(istance),R.t(istance));
%             [W_mtj_pos,W_mtj_neg] = getWork(P_mtj(istance),R.t(istance));
%             [W_mtp_pos,W_mtp_neg] = getWork(P_mtp(istance),R.t(istance));
%             P_sum = P_hip+P_knee+P_ankle+P_subt+P_mtj+P_mtp;
%             [W_sum_pos,W_sum_neg] = getWork(P_sum(istance),R.t(istance));
%             P_At = P_T_Sol+P_T_Gas+P_T_Gas2;
%             [W_At_pos,W_At_neg] = getWork(P_At(istance),R.t(istance));
%             [W_PF_pos,W_PF_neg] = getWork(P_PF(istance),R.t(istance));
%             
%             
%             Wi_pos = [W_hip_pos;W_knee_pos;W_ankle_pos;W_subt_pos;W_mtj_pos;W_mtp_pos];
%             Ws_pos(:,inr) = [Wi_pos;W_sum_pos;W_At_pos;W_PF_pos];
%             
%             Wi_neg = [W_hip_neg;W_knee_neg;W_ankle_neg;W_subt_neg;W_mtj_neg;W_mtp_neg];
%             Ws_neg(:,inr) = [Wi_neg;W_sum_neg;W_At_neg;W_PF_neg];

            % full gait cycle
            [W_hip_pos,W_hip_neg,W_hip_net] = getWork(P_hip,R.t);
            [W_knee_pos,W_knee_neg,W_knee_net] = getWork(P_knee,R.t);
            [W_ankle_pos,W_ankle_neg,W_ankle_net] = getWork(P_ankle,R.t);
            [W_subt_pos,W_subt_neg,W_subt_net] = getWork(P_subt,R.t);
            [W_mtj_pos,W_mtj_neg,W_mtj_net] = getWork(P_mtj,R.t);
            [W_mtp_pos,W_mtp_neg,W_mtp_net] = getWork(P_mtp,R.t);
            P_sum = P_hip+P_knee+P_ankle+P_subt+P_mtj+P_mtp;
            [W_sum_pos,W_sum_neg,W_sum_net] = getWork(P_sum,R.t);
            [W_heel_pos,W_heel_neg,W_heel_net] = getWork(P_HC_heel,R.t);
            [W_fft_pos,W_fft_neg,W_fft_net] = getWork(P_HC_ball,R.t);
            [W_toes_pos,W_toes_neg,W_toes_net] = getWork(P_HC_toes,R.t);
            [W_PF_pos,W_PF_neg,W_PF_net] = getWork(P_PF,R.t);
            [W_At_pos,W_At_neg,W_At_net] = getWork(P_T_Sol+P_T_Gas+P_T_Gas2,R.t);
%             [W_sol_pos,W_sol_neg] = getWork(P_M_Sol,R.t);
%             [W_gas_pos,W_gas_neg] = getWork(P_M_Gas+P_M_Gas2,R.t);
            [W_mtj_li_pos,W_mtj_li_neg,W_mtj_li_net] = getWork(P_dist_hindfoot,R.t);
            [W_PIM_pos,W_PIM_neg,W_PIM_net] = getWork(P_PIM,R.t);
%             [W_pads_pos,W_pads_neg] = getWork(P_HC,R.t);
%             [E_sol_pos,E_sol_neg] = getWork(P_E_Sol,R.t);
%             [E_gas_pos,E_gas_neg] = getWork(P_E_Gas+P_E_Gas2,R.t);
            
            Wi_pos = [W_hip_pos;W_knee_pos;W_ankle_pos;W_subt_pos;W_mtj_pos;W_mtp_pos];
            Ws_pos_gc(:,inr) = [Wi_pos;W_sum_pos;W_heel_pos;W_fft_pos;W_toes_pos;...
                W_At_pos;W_PF_pos;W_PIM_pos;W_mtj_li_pos];
            
            Wi_neg = [W_hip_neg;W_knee_neg;W_ankle_neg;W_subt_neg;W_mtj_neg;W_mtp_neg];
            Ws_neg_gc(:,inr) = [Wi_neg;W_sum_neg;W_heel_neg;W_fft_neg;W_toes_neg;...
                W_At_neg;W_PF_neg;W_PIM_neg;W_mtj_li_neg];
            
            Wi_net = [W_hip_net;W_knee_net;W_ankle_net;W_subt_net;W_mtj_net;W_mtp_net];
            Ws_net_gc(:,inr) = [Wi_net;W_sum_net;W_heel_net;W_fft_net;W_toes_net;...
                0;0;W_PIM_net;W_mtj_li_net];

            
            if div_by_dist_trav
                Ws_pos_gc(:,inr) = Ws_pos_gc(:,inr)/dist_trav;
                Ws_neg_gc(:,inr) = Ws_neg_gc(:,inr)/dist_trav;
                Ws_net_gc(:,inr) = Ws_net_gc(:,inr)/dist_trav;
            end

            if inr==2
                increase_pct_pos = (Ws_pos_gc(:,2)-Ws_pos_gc(:,1))./Ws_pos_gc(:,1)*100;
            end
            legW{inr} = LegName;
            
            % make figures
            if inr == nr
               Ws_cat = reordercats(Ws_cat,string(Ws_cat));
               
               % full gait cycle
               h20 = figure('Position',[fpos(2,:),fhigh1]);
               tl20 = tiledlayout(3,1);
               tl20.TileSpacing = 'none';

               nexttile(1)
               br1=bar(Ws_cat,Ws_pos_gc);
               grid on
               ylim([0,1.1*max(max(Ws_pos_gc))])
               for ibr=1:length(br1)
                   br1(ibr).FaceColor = 'flat';
                   br1(ibr).CData = CsV(ibr,:);
               end
               title('Mechanical work right leg')
               if div_by_dist_trav
                   ylabel('positive W (Jkg^{-1}m^{-1})')
               else
                   ylabel('positive W (Jkg^{-1})')
               end
               tmp=gca;
               tmp.XTickLabelRotation = 90;
               tmp.XTickLabel = 'none';

               lh20=legend(legW,'location','northeast','Interpreter',lgInt,'Box','off','Orientation','horizontal');
               lh20.Layout.Tile = 'South';
                
%                lhPos = lh20.Position;
% %                lhPos(1) = lhPos(1)+0.1;
%                lhPos(2) = lhPos(2)+0.05;
%                set(lh20,'position',lhPos);
% %                title(lh20,'Legend')
                
               nexttile(2)
               br2=bar(Ws_cat,Ws_neg_gc);
               grid on
               ylim([-1.1*max(max(Ws_pos_gc)),0])
               for ibr=1:length(br2)
                   br2(ibr).FaceColor = 'flat';
                   br2(ibr).CData = CsV(ibr,:);
               end
               if div_by_dist_trav
                   ylabel('negative W (Jkg^{-1}m^{-1})')
               else
                   ylabel('negative W (Jkg^{-1})')
               end
               tmp=gca;
               tmp.XTickLabelRotation = 90;
               tmp.XTickLabel = 'none';
               
               nexttile(3)
               br3=bar(Ws_cat,(Ws_net_gc));
               grid on
               xl = get(gca, 'xlim');
               axis tight
               yl = get(gca, 'ylim');
               ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
%                xlim(xl)
               for ibr=1:length(br3)
                   br3(ibr).FaceColor = 'flat';
                   br3(ibr).CData = CsV(ibr,:);
               end
               if div_by_dist_trav
                   ylabel('net W (Jkg^{-1}m^{-1})')
               else
                   ylabel('net W (Jkg^{-1})')
               end
               tmp=gca;
               tmp.XTickLabelRotation = 90;
               
                
               
               if inr==nr && ~strcmp(figNamePrefix,'none')
                    set(h20,'PaperPositionMode','auto')
                    print(h20,[figNamePrefix '_W_bar'],'-dpng','-r0')
%                     print(h20,[figNamePrefix '_W_bar'],'-depsc')
               end
                
%                figure
%                subplot(1,2,1)
%                bar([W_sol_pos,W_sol_neg]*R.body_mass)
%                ylabel('W (J)')
%                hold on
%                grid on
%                subplot(1,2,2)
%                vM = linspace(-0.04,0.06,500)';
%                 plot(vM,vM)
%                 hold on
%                 grid on
%                 b = 10;
%                 vM_pos = 0.5 + 0.5*tanh(b*(vM));
%                 vM_neg = 1-vM_pos;
%                 plot(vM,vM.*vM_neg)
%                 xlabel('vM')
%                 b = 100;
%                 vM_pos = 0.5 + 0.5*tanh(b*(vM));
%                 vM_neg = 1-vM_pos;
%                 plot(vM,vM.*vM_neg)
%                 legend({'vM','vM*vM_neg (b=10)','vM*vM_neg (b=100)'},'Interpreter','none')
                
            end
        end
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        if makeplot.work_bar_small
            if inr == 1
%                 Ws_cat = categorical({'Ankle-foot joints','Foot joints','Achilles tendon','Hip'});
                Ws_cat = categorical({'Joints distal to shank','Foot joints','Achilles tendon'});
                Ws_pos = zeros(length(Ws_cat),nr);
                Ws_neg = Ws_pos;
                Ws_pos_gc = Ws_pos;
                Ws_neg_gc = Ws_pos;
                Ws_net_gc = Ws_pos;
            end

            % full gait cycle
            [W_hip_pos,W_hip_neg] = getWork(P_hip,R.t);
            W_hip_net = trapz(R.t,P_hip);
            [W_mtjmtp_pos,W_mtjmtp_neg] = getWork(P_mtj+P_mtp,R.t);
            W_mtjmtp_net = trapz(R.t,P_mtj+P_mtp);
            P_sum_ds = P_ankle+P_subt+P_mtj+P_mtp;
            [W_sum_pos,W_sum_neg] = getWork(P_sum_ds,R.t);
            W_sum_net = trapz(R.t,P_sum_ds);
            [W_At_pos,W_At_neg] = getWork(P_T_Sol+P_T_Gas+P_T_Gas2,R.t);
            
%             Ws_pos_gc(:,inr) = [W_sum_pos;W_mtjmtp_pos;W_At_pos;W_hip_pos]/dist_trav;
%             Ws_neg_gc(:,inr) = [W_sum_neg;W_mtjmtp_neg;W_At_neg;W_hip_neg]/dist_trav;
%             Ws_net_gc(:,inr) = [W_sum_net;W_mtjmtp_net;0;W_hip_net]/dist_trav;
            
            Ws_pos_gc(:,inr) = [W_sum_pos;W_mtjmtp_pos;W_At_pos]/dist_trav;
            Ws_neg_gc(:,inr) = [W_sum_neg;W_mtjmtp_neg;W_At_neg]/dist_trav;
            Ws_net_gc(:,inr) = [W_sum_net;W_mtjmtp_net;0]/dist_trav;
            
            
            legW{inr} = LegName;
            
            % make figures
            if inr == nr
%                Ws_cat = reordercats(Ws_cat,[4,2,3,1]);
               Ws_cat = reordercats(Ws_cat,[3,2,1]);

               % full gait cycle
               h20s = figure('Position',[fpos(2,:),fhigh1]);
               subplot(311)
               br1=bar(Ws_cat,Ws_pos_gc);
               grid on
               for ibr=1:length(br1)
                   br1(ibr).FaceColor = 'flat';
                   br1(ibr).CData = CsV(ibr,:);
               end
               title('Mechanical work right leg')
               ylabel('positive W (Jkg^{-1}m^{-1})')
               tmp=gca;
%                tmp.XTickLabelRotation = 90;
%                tmp.YTick = [0:0.02:0.12];
%                ylim([0,0.12])
%                ylim([0,0.25])

               lh20=legend(legW,'location','northeast','Interpreter',lgInt);
               lhPos = lh20.Position;
%                lhPos(1) = lhPos(1)+0.1;
               lhPos(2) = lhPos(2)+0.05;
               set(lh20,'position',lhPos);
               title(lh20,'Legend')
                
               subplot(312)
               br2=bar(Ws_cat,Ws_neg_gc);
               grid on
               for ibr=1:length(br2)
                   br2(ibr).FaceColor = 'flat';
                   br2(ibr).CData = CsV(ibr,:);
               end
               ylabel('negative W (Jkg^{-1}m^{-1})')
               tmp=gca;
%                tmp.XTickLabel = '';
%                tmp.XTickLabelRotation = 90;
%                tmp.YTick = [-0.12,-0.1,-0.08,-0.06,-0.04,-0.02,0];
%                ylim([-0.12,0])
%                ylim([-0.25,0])
               
               subplot(313)
               br3=bar(Ws_cat,Ws_net_gc);
               grid on
               xl = get(gca, 'xlim');
%                axis tight
               yl = get(gca, 'ylim');
               xlim(xl)
               for ibr=1:length(br3)
                   br3(ibr).FaceColor = 'flat';
                   br3(ibr).CData = CsV(ibr,:);
               end
               ylabel('net W (Jkg^{-1}m^{-1})')
               tmp=gca;
%                tmp.XTickLabel = '';
%                tmp.XTickLabelRotation = 90;
%                tmp.YTickLabel = [0:0.02:0.12];
%                ylim([0,0.12])
%                ylim([-0.05,0.25])
               
               if inr==nr && ~strcmp(figNamePrefix,'none')
                    set(h20s,'PaperPositionMode','auto')
                    print(h20s,[figNamePrefix '_W_bar_s'],'-dpng','-r0')
%                     print(h20s,[figNamePrefix '_W_bar_s'],'-depsc')
               end
                
            end
        end
        
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if makeplot.power_main
        if inr==1
            h21 = figure('Position',[fpos(4,:)+300,fsq]);
        end

        figure(h21)

        nh = 4;
        nw = 5;

        if ~isempty(imtj) && max(P_PF)>1e-6
            pos_P_all = {'none',P_ankle, P_mtj, P_mtp, P_mtj+P_mtp,...
                       'none', P_joints, P_mtj_PF, P_mtp_PF, P_PF,...
                       'none','none',P_mtj_PIM, P_mtp_PIM, P_PIM,...
                       'none','none',P_mtj_PIM+P_mtj_PF, P_mtp_PIM+P_mtp_PF, P_PIM+P_PF};
        elseif ~isempty(imtj)
            pos_P_all = {'none',P_ankle, P_mtj, P_mtp, P_mtj+P_mtp,...
                       'none',P_joints, 'none', 'none', 'none',...
                       'none', 'none', 'none','none', 'none',...
                       'none', 'none', 'none','none', 'none'};
        else
            pos_P_all = {'none',P_ankle, 'none', P_mtp, 'none',...
                       'none',P_joints, 'none', 'none', 'none',...
                       'none', 'none', 'none','none', 'none',...
                       'none', 'none', 'none','none', 'none'};
        end

        titles_P_all = {'none','Ankle','Mtj','Mtp','Mtj + Mtp',...
            'none','Joints distal to shank', 'Mtj: by PF','Mtp: by PF','Plantar fascia',...
            'none','none', 'Mtj: by PIM','Mtp: by PIM','PIM',...
            'none','none', 'Mtj: by PF+PIM','Mtp: by PF+PIM','PF+PIM'};

        if R.S.Foot.PIM==1
            pos_P_all{6} = P_PIM;
            titles_P_all{6} = 'PIM';
        end
        
        for i_P=1:numel(pos_P_all)
            if ~strcmp(pos_P_all{i_P},'none')
                subplot(nh,nw,i_P)
                hold on
                grid on
                plot(xst_10,pos_P_all{i_P}(istance),'Color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
                title(titles_P_all{i_P},'Fontsize',label_fontsize);
                axis tight
                yl = get(gca, 'ylim');
                ylim([yl(1)-0.1*abs(sum(yl)),yl(2)+0.1*abs(sum(yl))])
                xlim([0,110])
    
                if i_P ~= 2 && i_P ~= 7
                    ylim([-0.8,1.3])
                end
                if mod(i_P-2,nw)==0
                    ylabel('P_{mech} (W/kg)','Fontsize',label_fontsize);
                end
                if i_P > nh*nw-nw
                    xlabel('Stance phase (%)','Fontsize',label_fontsize);
                end
                if i_P==2 && inr==nr
                   lh21=legend('location','northwest','Interpreter',lgInt);
                   lhPos = lh21.Position;
                   lhPos(1) = lhPos(1)-0.27;
                   lhPos(2) = lhPos(2)+0.05;
                   set(lh21,'position',lhPos);
                   title(lh21,'Legend')
                end
                
                
            end
            
        end
        
        subplot(nh,nw,6)
        W_leg_joints(inr)=trapz(R.t,P_leg_joints)/dist_trav;
        bar(inr,W_leg_joints(inr),'FaceColor',Cs);
        hold on
        tmp=gca;
        tmp.XTickLabel = '';
        ylabel('Net Work (Jkg^{-1}m^{-1})')
        title('Joint work')
        grid on
        
        if inr==nr
            ylim([0.8*min(W_leg_joints),1.1*max(W_leg_joints)]);

        end

        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h21,'PaperPositionMode','auto')
            print(h21,[figNamePrefix '_P_main'],'-dpng','-r0')
%             print(h21,[figNamePrefix '_P_main'],'-depsc')
        end
    end


    %%
    %%%%%%%%%%%%%%%%%


    if makeplot.spatiotemp
        if inr==1
            h22 = figure('Position',[fpos(3,1)+300,500,fsq*0.5]);
        end
        figure(h22)
        subplot(2,3,1)
        plot(inr,R.StrideLength,'o','Color',Cs,'MarkerFaceColor',Cs)
        hold on
        grid on
        ylabel('Stride length (m)');
        title('Stride length')
        set(gca,'XTickLabel','')
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)*0.95,yl(2)*1.05])
        xlim([0,nr+1])
        
        subplot(2,3,2)
        plot(inr,R.StepWidth_COP*100,'o','Color',Cs,'MarkerFaceColor',Cs);
        hold on
        grid on
        ylabel('Stride width (cm)')
        title('Stride width')
        set(gca,'XTickLabel','')
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)*0.95,yl(2)*1.05])
        xlim([0,nr+1])
        
        subplot(2,3,3)
        plot(inr,R.Event.Stance,'o','Color',Cs,'MarkerFaceColor',Cs);
        hold on
        grid on
        ylabel('% stance')
        title('Stance phase')
        set(gca,'XTickLabel','')
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)-1,yl(2)+1])
        xlim([0,nr+1])
        
        subplot(2,3,4)
        plot(inr,R.Event.DS,'o','Color',Cs,'MarkerFaceColor',Cs);
        hold on
        grid on
        ylabel('% double support')
        title('Double support')
        set(gca,'XTickLabel','')
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)-1,yl(2)+1])
        xlim([0,nr+1])

        subplot(2,3,5)
        plot(inr,1/R.tend,'o','Color',Cs,'MarkerFaceColor',Cs);
        hold on
        grid on
        ylabel('f (Hz)')
        title('Stride frequency')
        set(gca,'XTickLabel','')
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)-0.01,yl(2)+0.01])
        xlim([0,nr+1])

        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h22,'PaperPositionMode','auto')
            print(h22,[figNamePrefix '_sptmp'],'-dpng','-r0')
%             print(h22,[figNamePrefix '_sptmp'],'-depsc')
        end
    end
    %%
    %%%%%%%%%%%%%%
    if makeplot.ankle_correlation

        iankle_ref = strcmp(Qref.colheaders,'ankle_angle');
        q_ankle_ref = Qref.Qall_mean(:,iankle_ref);
        q_ankle_sim = R.Qs(:,iankle);
        idx_xc = [1,10,46,60,100];
        tmp_str = LegName;
        for ixc=1:length(idx_xc)-1
            idx_tmp = idx_xc(ixc):(idx_xc(ixc+1)-1);
            tmpx = xcorr(q_ankle_ref(idx_tmp),q_ankle_sim(idx_tmp),0,'coeff');
            tmp_str = [tmp_str ' & ' num2str(tmpx,2)];
        end

        if inr==1
            h23 = figure('Position',[fpos(4,:),fwide*0.7]);
            
            meanPlusSTD = (Qref.Qall_mean(:,iankle_ref) + 2*Qref.Qall_std(:,iankle_ref));
            meanMinusSTD = (Qref.Qall_mean(:,iankle_ref) - 2*Qref.Qall_std(:,iankle_ref));
            stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
            intervalQ = 1:stepQ:size(R.Qs,1);
            sampleQ = 1:size(R.Qs,1);
            meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
            meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);
            
            subplot(3,2,[1,3])
            hold on
            fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName','Measured (mean \pm 2 SD)');
            alpha(.25);

            %
            subplot(3,2,[2,4])
            hold on
            fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName','Measured (mean \pm 2 SD)');
            alpha(.25);
            q_ankle_hs = Qref.Qall_mean(1,iankle_ref);


            %
            i_to_ref = find(Data.GRF.Fmean(:,2)>5,1,'last');
            istance_ref = 1:i_to_ref-1;
            iswing_ref = i_to_ref:length(Data.GRF.Fmean(:,2));
        end

        q_ankle_sim_ofs = q_ankle_sim - q_ankle_sim(1) + q_ankle_hs;
        smpl_stance = linspace(istance0(1),istance0(end),length(istance_ref));
        smpl_swing = linspace(iswing(1),iswing(end),length(iswing_ref));
        
        q_stance_matched_ofs = interp1(istance0,q_ankle_sim_ofs(istance0),smpl_stance);
        q_swing_matched_ofs = interp1(iswing,q_ankle_sim_ofs(iswing),smpl_swing);
        q_matched_ofs = [q_stance_matched_ofs, q_swing_matched_ofs];
        
        q_stance_matched = interp1(istance0,q_ankle_sim(istance0),smpl_stance);
        q_swing_matched = interp1(iswing,q_ankle_sim(iswing),smpl_swing);
        q_matched = [q_stance_matched, q_swing_matched];

        q_stance_sf = max(q_ankle_ref(istance_ref))/max(q_stance_matched_ofs);
        q_matched_ofs_sc = q_matched_ofs*q_stance_sf;

        
        if inr==1
            disp('Ankle angle cross-correlation')
            disp('Phase   toe-off matched (w/o offset)')


        end
        disp(LegName)
        xcs_stance = xcorr(q_ankle_ref(istance_ref),q_stance_matched,0,'coeff');
        xcs_stance_ofs = xcorr(q_ankle_ref(istance_ref),q_stance_matched_ofs,0,'coeff');
        disp(['   Stance: R = ' num2str(xcs_stance,2) ' (' num2str(xcs_stance_ofs,2) ')'])
        
        xcs_swing = xcorr(q_ankle_ref(iswing_ref),q_swing_matched,0,'coeff');
        xcs_swing_ofs = xcorr(q_ankle_ref(iswing_ref),q_swing_matched_ofs,0,'coeff');
        disp(['   Swing:  R = ' num2str(xcs_swing,2) ' (' num2str(xcs_swing_ofs,2) ')'])


        figure(h23)
        subplot(3,2,[1,3])
        hold on
        plot(x,q_ankle_sim,'linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',LegName);
%         plot(x,q_matched,'--','linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',['toe-off matched']);

        if inr==nr
            figure(h23)
            subplot(3,2,[1,3])
            axis tight
            yl = get(gca, 'ylim');
            yl=[yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)];
            ylim(yl)
            xlim([0,100])
%             xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('angle (°)','Fontsize',label_fontsize);
            title('Ankle angle')
            
%             plot([1,1]*0,yl,'-ok','DisplayName','Heel strike');
%             plot([1,1]*10,yl,'-vk','DisplayName','Foot flat');
%             plot([1,1]*45,yl,'-*k','DisplayName','Heel lift');
%             plot([1,1]*59,yl,'-^k','DisplayName','Toe off');
%             plot([1,1]*66,yl,'-dk','DisplayName','Toe off (Meas)');
                
           lh23=legend('location','northwest','Interpreter',lgInt);
           lhPos = lh23.Position;
           lhPos(1) = lhPos(1)+0.4;
%            lhPos(2) = lhPos(2)+0.05;
           lhPos(2) = lhPos(2)-0.6;
           set(lh23,'position',lhPos);
           title(lh23,'Legend')

           
        end

        subplot(3,2,[2,4])
        hold on
%         plot(x,q_ankle_sim_ofs,'linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',LegName);
        plot(x,q_matched_ofs,'-','linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',['toe-off matched']);
%         plot(x,q_matched_ofs_sc,'-.','linewidth',line_linewidth,'Color',CsV(inr,:),'DisplayName',['toe-off matched']);
        if inr==nr
           subplot(3,2,[2,4])
           ylim(yl)
           xlim([0,100])
           xline(istance_ref(end)+0.5,'-k')
           title('Matched initial angle and toe-off timing')
        end

        if inr==1
            subplot(3,2,5)
            hold on
            meanPlusSTD = Data.GRF.Fmean(:,2) + 2*Data.GRF.Fstd(:,2);
            meanMinusSTD = Data.GRF.Fmean(:,2) - 2*Data.GRF.Fstd(:,2);
            stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
            intervalQ = 1:stepQ:size(R.Qs,1);
            sampleQ = 1:size(R.Qs,1);
            meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
            meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);
            fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k','DisplayName','Measured');
            alpha(.25);
        end

        subplot(3,2,5)
        hold on
        l = plot(R.GRFs(:,2),'-','Color',CsV(inr,:));
        axis tight
        yl = get(gca, 'ylim');
        ylim([yl(1)-0.1*abs(sum(yl)),yl(2)+0.1*abs(sum(yl))])
        xlim([0,100])
        ylabel('GRF (%BW)')
        xlabel('Gait cycle (%)','Fontsize',label_fontsize);

        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h23,'PaperPositionMode','auto')
            print(h23,[figNamePrefix '_ankle_corr_1'],'-dpng','-r0')
%             print(h23,[figNamePrefix '_ankle_corr_1'],'-depsc')
        end
    end

    %%
    
    if makeplot.E_muscle_bar
        iM = find(contains(R.colheaders.muscles,'_r'));
        if inr == 1 
%             mVect = R.colheaders.muscles(iM);

            mVect = {'Glut med 1','Glut med 2','Glut med 3',...
                'Glut min 1','Glut min 2','Glut min 3','Semimem',...
                'Semiten','Bic fem lh','Bic fem sh','Sar','Add long',...
                'Add brev','Add mag 1','Add mag 2','Add mag 3','TFL',...
                'Pect','Grac','Glut max 1','Glut max 2','Glut max 3',......
                'Iliacus','Psoas','Quad fem','Gem','Peri',...
                'Rect fem','Vas med','Vas int','Vas lat','Med gas',...
                'Lat gas','Soleus','Tib post','Flex dig','Flex hal',...
                'Tib ant','Per brev','Per long','Per tert','Ext dig',...
                'Ext hal','FDB','Ercspn','Intobl','Extobl'};

            
            mus_cat = categorical(mVect);
            Emus = zeros(length(mus_cat),nr);
            
            mus_cat = reordercats(mus_cat,[length(mVect):-1:1]);
        end     
        
        imu_ct = 1;
        for imu=1:length(mVect)
            if strcmp(mVect(imu),'FDB') && (~isfield(R.S.Foot,'FDB') || ~R.S.Foot.FDB)
                Emus(imu,inr) = 0;
            else
                Emus(imu,inr) = trapz(R.t,R.MetabB.Etot(:,iM(imu_ct)))/R.body_mass/dist_trav;
                imu_ct = imu_ct+1;
            end
        end
        

        if inr>1
            Etot_mus_i = 2*sum(Emus(:,inr));
            Etot_mus_1 = 2*sum(Emus(:,1));
%             disp(num2str( Etot_mus_i-Etot_mus_1 ))
%             disp(num2str( COT_all(inr)-COT_all(1) )) 
        end
        
        legMus{inr} = LegName;
        
        if inr==nr

            h24 = figure('Position',[fpos(3,:),fhigh1]);
            subplot(1,2,1)
            hold on
            br1=barh(mus_cat,Emus);
            grid on
            for ibr=1:length(br1)
               br1(ibr).FaceColor = 'flat';
               br1(ibr).EdgeColor = 'flat';
               br1(ibr).CData = CsV(ibr,:);
            end
            title('Metabolic energy of muscles')
            xlabel('E_{metab} (Jkg^{-1}m^{-1})')
            lh24=legend(legMus,'location','northwest','Interpreter',lgInt,'Box','off','Orientation','horizontal');
            lhPos = lh24.Position;
            lhPos(2) = lhPos(2)+0.06;
            set(lh24,'position',lhPos);
%             title(lh24,'Legend')

            subplot(1,2,2)
            hold on
            Emus_rel = Emus-Emus(:,1);
            br2=barh(mus_cat,Emus_rel(:,2:end));
            grid on
            for ibr=1:length(br2)
               br2(ibr).FaceColor = 'flat';
               br2(ibr).EdgeColor = 'flat';
               br2(ibr).CData = CsV(ibr+1,:);
            end
            plot([0,0],get(gca,'YLim'),'Color',CsV(1,:),'linewidth',1)
            title(['Absolute increase w.r.t. ' legMus{1}])
            xlabel('\DeltaE_{metab} (Jkg^{-1}m^{-1})')
            set(gca,'YAxisLocation','right')
            axis tight
  
        end
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h24,'PaperPositionMode','auto')
            print(h24,[figNamePrefix '_musc_all'],'-dpng','-r0')
%             print(h24,[figNamePrefix '_musc_all'],'-depsc')
        end
        
    end

    %%
    
    if makeplot.W_muscle_bar
        iM = find(contains(R.colheaders.muscles,'_r'));
        if inr == 1 
%             mVect = R.colheaders.muscles(iM);

            mVect = {'Glut med 1','Glut med 2','Glut med 3',...
                'Glut min 1','Glut min 2','Glut min 3','Semimem',...
                'Semiten','Bic fem lh','Bic fem sh','Sar','Add long',...
                'Add brev','Add mag 1','Add mag 2','Add mag 3','TFL',...
                'Pect','Grac','Glut max 1','Glut max 2','Glut max 3',......
                'Iliacus','Psoas','Quad fem','Gem','Peri',...
                'Rect fem','Vas med','Vas int','Vas lat','Med gas',...
                'Lat gas','Soleus','Tib post','Flex dig','Flex hal',...
                'Tib ant','Per brev','Per long','Per tert','Ext dig',...
                'Ext hal','FDB','Ercspn','Intobl','Extobl'};

            
            mus_cat = categorical(mVect);
            Wmus = zeros(length(mus_cat),nr);
            
            mus_cat = reordercats(mus_cat,[length(mVect):-1:1]);
        end     
        
        imu_ct = 1;
        for imu=1:length(mVect)
            if strcmp(mVect(imu),'FDB') && (~isfield(R.S.Foot,'FDB') || ~R.S.Foot.FDB)
                Wmus(imu,inr) = 0;
            else
                Wmus(imu,inr) = trapz(R.t,R.MetabB.Wdot(:,iM(imu_ct)))/R.body_mass/dist_trav;
                imu_ct = imu_ct+1;
            end
        end
        

        if inr>1
            Wtot_mus_i = 2*sum(Wmus(:,inr));
            Wtot_mus_1 = 2*sum(Wmus(:,1));
%             disp(num2str( Etot_mus_i-Etot_mus_1 ))
%             disp(num2str( COT_all(inr)-COT_all(1) )) 
        end
        
        legMus{inr} = LegName;
        
        if inr==nr

            h24a = figure('Position',[fpos(3,:),fhigh1]);
            subplot(1,2,1)
            hold on
            br1=barh(mus_cat,Wmus);
            grid on
            for ibr=1:length(br1)
               br1(ibr).FaceColor = 'flat';
               br1(ibr).CData = CsV(ibr,:);
            end
            title('Mechanical energy of muscle fibres')
            xlabel('W (Jkg^{-1}m^{-1})')
            lh24a=legend(legMus,'location','northeast','Interpreter',lgInt);
            lhPos = lh24a.Position;
            lhPos(1) = lhPos(1)+0.1;
            set(lh24a,'position',lhPos);
            title(lh24a,'Legend')

            subplot(1,2,2)
            hold on
            Wmus_rel = Wmus-Wmus(:,1);
            br2=barh(mus_cat,Wmus_rel(:,2:end));
            grid on
            for ibr=1:length(br2)
               br2(ibr).FaceColor = 'flat';
               br2(ibr).CData = CsV(ibr+1,:);
            end
            plot([0,0],get(gca,'YLim'),'Color',CsV(1,:),'linewidth',1)
            title(['Absolute increase w.r.t. ' legMus{1}])
            xlabel('\DeltaW (Jkg^{-1}m^{-1})')
            set(gca,'YAxisLocation','right')
            axis tight
  
        end
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h24a,'PaperPositionMode','auto')
            print(h24a,[figNamePrefix '_musc_all'],'-dpng','-r0')
%             print(h24a,[figNamePrefix '_musc_all'],'-depsc')
        end
        
    end


    %%
%     if inr ==1
%         h25=figure;
%     end
%     figure(h25)
%     
%     if ~isempty(imtj)
% %         qd_mtj = R.Qdots(:,imtj)*pi/180;
% %         dq_mtj = zeros(size(qd_mtj));
% %         for idq=3:length(dq_mtj)-2
% %             dq_mtj(idq) = mean(qd_mtj(idq-2:idq+2))*R.t(end)/100*5;
% %         end
%         
%         
% %         qk_mtj = dq_mtj./R.Tid(:,imtj);
% %         qk_mtj(dq_mtj<1e-4) = 0;
% 
%         subplot(1,2,1)
%         hold on
%         grid on
% %         plot(x,qk_mtj,'Color',Cs)
% %         plot(R.Qs(istance0,imtj),R.Tid(istance0,imtj),'.','Color',Cs)
%         plot(R.Qs(iarch_stance,imtj),R.Tid(iarch_stance,imtj),'.','Color',Cs)
%         plot(R.Qs(ipush_off,imtj),R.Tid(ipush_off,imtj),'o','Color',Cs)
% 
%         c1 = polyfit(R.Qs(iarch_stance,imtj),-R.Tid(iarch_stance,imtj),1);
%         qk_mtj_full_sup = c1(1)
% 
%         c2 = polyfit(R.Qs(ipush_off,imtj),-R.Tid(ipush_off,imtj),1);
%         qk_mtj_push_off = c2(1)
%         
% %         ylim([-1e4,1e4])
%         
%         
%     end
%     
%     
%     subplot(1,2,2)
%     hold on
%     grid on
%     plot(R.Qs(iarch_stance,imtp),R.Tid(iarch_stance,imtp),'.','Color',Cs)
%     plot(R.Qs(ipush_off,imtp),R.Tid(ipush_off,imtp),'o','Color',Cs)
    


    %%
 
    
    if makeplot.toes

        
        mVect_t = {'Flex-dig','Flex-hal','Ext-dig','Ext-hal','FDB'};

        imus = [ifd ifh ied ieh];

        if ~isempty(iFDB)
            imus(5) = iFDB;
        end

        if inr==1
            h25 = figure('Position',[fpos(3,:),fhigh]);
        end

         figure(h25);


        for imu=1:length(imus)

            subplot(8,5,imu); hold on;
            plot(x,R.a(:,imus(imu)),'-','Color',CsV(inr,:),'DisplayName',LegName);
            title(mVect_t{imu});
            ylabel('Activity (-)','Interpreter','latex');
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])

%             if inr==1 && imu==1
%                 lh3=legend('-DynamicLegend','location','northwest');
%                 lh3.Interpreter = 'tex';
% %                     lh3.Orientation = 'horizontal';
%             end

            subplot(8,5,5+imu)
            plot(x,R.FT(:,imus(imu)),'-','Color',CsV(inr,:),'DisplayName',LegName);
            hold on
            grid on

            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$F^T$ (N)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([0,yl(2)+0.15*norm(yl)])
            xlim([0,100])

            subplot(8,5,10+imu)
            plot(x,R.MetabB.Etot(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
            hold on
            grid on

            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$\dot{E}$ (W)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])

            subplot(8,5,15+imu)
            plot(x,R.MetabB.Wdot(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
            hold on
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$\dot{W}$ (W)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.15*norm(yl),yl(2)+0.15*norm(yl)])
            xlim([0,100])

            subplot(8,5,20+imu)
            plot(x,-R.FT(:,imus(imu)).*R.vT(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
            hold on
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$P^T$ (W)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])

            subplot(8,5,25+imu)
            plot(x,R.lMtilde(:,imus(imu)),'-','Color',CsV(inr,:)); hold on;
            hold on
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$\tilde{l}^M$ (-)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.05*norm(yl),yl(2)+0.02*norm(yl)])
            xlim([0,100])

            subplot(8,5,30+imu)
            plot(x,R.vMtilde(:,imus(imu)),'Color',CsV(inr,:),'DisplayName',LegName);
            hold on
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$\dot{\tilde{l}^M}$ (-)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.1*norm(yl),yl(2)+0.1*norm(yl)])
            xlim([0,100])


            subplot(8,5,35+imu)
            plot(x,R.lMT(:,imus(imu)),'Color',CsV(inr,:),'DisplayName',LegName);
            hold on
            grid on
            L = get(gca,'XLim');
            set(gca,'XTick',linspace(L(1),L(2),NumTicks))
            if imu==1
                ylabel('$l^{MT}$ (m)','Interpreter','latex');
            end
            axis tight
            yl = get(gca, 'ylim');
            ylim([yl(1)-0.05*abs(diff(yl)),yl(2)+0.05*abs(diff(yl))])
            xlim([0,100])


            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
        end


%         if inr==nr
%             lhPos = lh3.Position;
% %             lhPos(1) = lhPos(1)-0.12;
%             if makeplot.sol_all
%                 lhPos(2) = lhPos(2)+0.08;
%             else
%                 lhPos(2) = lhPos(2)+0.1;
%             end
%             set(lh3,'position',lhPos);
%         end
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h25,'PaperPositionMode','auto')
            print(h25,[figNamePrefix '_toes'],'-dpng','-r0')
%             print(h25,[figNamePrefix '_toes'],'-depsc')
        end

    end

% figure(2)
% if ~isempty(imtj)
%     plot(x,R.Qs(:,imtj)+R.Qs(:,iankle),'Color',CsV(inr,:)); hold on;
% else
%     plot(x,R.Qs(:,iankle),'Color',CsV(inr,:)); hold on;
% end
% xlabel('Gait cycle (%)','Fontsize',label_fontsize);
% ylabel('Ankle + mtj angle (°)','Fontsize',label_fontsize);



%%


    if makeplot.E_muscle_bar_small
        if inr == 1 

            mus_cat = categorical({'Hamstrings','Quadriceps femoris','Gluteus maximus','Gastrocnemius','Soleus','Gluteus medius','Gluteus minimus'});

            mus_cat = reordercats(mus_cat,[length(mus_cat):-1:1]);
            
            Emus = zeros(length(mus_cat),nr);
            Wmus = zeros(length(mus_cat),nr);


        end
        Wmus(1,inr) = trapz(R.t, sum(R.MetabB.Wdot(:,ihamstrings),2) )/R.body_mass/dist_trav;
        Wmus(2,inr) = trapz(R.t, sum(R.MetabB.Wdot(:,iquadriceps_femoris),2) )/R.body_mass/dist_trav;
        Wmus(3,inr) = trapz(R.t, sum(R.MetabB.Wdot(:,igluteus_maximus),2) )/R.body_mass/dist_trav;
        Wmus(4,inr) = trapz(R.t, sum(R.MetabB.Wdot(:,[iGas, iGas2]),2) )/R.body_mass/dist_trav;
        Wmus(5,inr) = trapz(R.t, sum(R.MetabB.Wdot(:,iSol),2) )/R.body_mass/dist_trav;
        Wmus(6,inr) = trapz(R.t, sum(R.MetabB.Wdot(:,igluteus_medius),2) )/R.body_mass/dist_trav;
        Wmus(7,inr) = trapz(R.t, sum(R.MetabB.Wdot(:,igluteus_minimus),2) )/R.body_mass/dist_trav;


        Emus(1,inr) = trapz(R.t, sum(R.MetabB.Etot(:,ihamstrings),2) )/R.body_mass/dist_trav;
        Emus(2,inr) = trapz(R.t, sum(R.MetabB.Etot(:,iquadriceps_femoris),2) )/R.body_mass/dist_trav;
        Emus(3,inr) = trapz(R.t, sum(R.MetabB.Etot(:,igluteus_maximus),2) )/R.body_mass/dist_trav;
        Emus(4,inr) = trapz(R.t, sum(R.MetabB.Etot(:,[iGas, iGas2]),2) )/R.body_mass/dist_trav;
        Emus(5,inr) = trapz(R.t, sum(R.MetabB.Etot(:,iSol),2) )/R.body_mass/dist_trav;
        Emus(6,inr) = trapz(R.t, sum(R.MetabB.Etot(:,igluteus_medius),2) )/R.body_mass/dist_trav;
        Emus(7,inr) = trapz(R.t, sum(R.MetabB.Etot(:,igluteus_minimus),2) )/R.body_mass/dist_trav;

        legMus{inr} = LegName;

        if inr==nr

            h26 = figure('Position',[fpos(3,:),fhigh1]);
            subplot(2,2,1)
            hold on
            br1=barh(mus_cat,Emus);
            grid on
            for ibr=1:length(br1)
               br1(ibr).FaceColor = 'flat';
               br1(ibr).CData = CsV(ibr,:);
            end
            title('Metabolic energy of muscles')
            xlabel('E_{metab} (Jkg^{-1}m^{-1})')
            lh26=legend(legMus,'location','northeast','Interpreter',lgInt);
            lhPos = lh26.Position;
            lhPos(1) = lhPos(1)+0.1;
            set(lh26,'position',lhPos);
            title(lh26,'Legend')

            subplot(2,2,2)
            hold on
            br2=barh(mus_cat,Wmus);
            grid on
            for ibr=1:length(br2)
               br2(ibr).FaceColor = 'flat';
               br2(ibr).CData = CsV(ibr,:);
            end
            title('Net Work of muscles')
            xlabel('W (Jkg^{-1}m^{-1})')
            set(gca,'YAxisLocation','right')
%             axis tight


            subplot(2,2,3)
            hold on
            Emus_rel = (Emus-Emus(:,1))./Emus(:,1)*100;
            br3=barh(mus_cat,Emus_rel(:,2:end));
            grid on
            for ibr=1:length(br3)
               br3(ibr).FaceColor = 'flat';
               br3(ibr).CData = CsV(ibr+1,:);
            end
            plot([0,0],get(gca,'YLim'),'Color',CsV(1,:),'linewidth',1)
            title(['Relative increase w.r.t. ' legMus{1}])
            xlabel('\delta E_{metab} (%)')
            
            subplot(2,2,4)
            hold on
            Wmus_rel = (Wmus-Wmus(:,1))./Wmus(:,1)*100;
            br4=barh(mus_cat,Wmus_rel(:,2:end));
            grid on
            for ibr=1:length(br4)
               br4(ibr).FaceColor = 'flat';
               br4(ibr).CData = CsV(ibr+1,:);
            end
            plot([0,0],get(gca,'YLim'),'Color',CsV(1,:),'linewidth',1)
            title(['Relative increase w.r.t. ' legMus{1}])
            xlabel('\delta W (%)')
            set(gca,'YAxisLocation','right')
            
            
        end
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h26,'PaperPositionMode','auto')
            print(h26,[figNamePrefix '_musc_s'],'-dpng','-r0')
%             print(h26,[figNamePrefix '_musc_s'],'-depsc')
        end
    end



%%


    if makeplot.Edot_all
        if inr==1
            h27 = figure('Position',[fpos(3,:),fwide]);
        end
        iM = [47:92];
        iM = find(contains(R.colheaders.muscles,'_r'));
        figure(h27);
        hold on
        Edot_all = sum(R.MetabB.Etot(:,iM),2)/R.body_mass;
        plot(x,Edot_all,'-','Color',CsV(inr,:),'DisplayName',LegName);
        legend('Interpreter',lgInt)
    end




%%

    if makeplot.Energy_cost
            if inr==1
                h28 = figure('Position',[fpos(3,:),fwide]);
                
                obj_cat = categorical({'E_{metab}','activity','arms','mtp',...
                    'PIM','P_{PIM}','accelerations','passive torques','da/dt'});
                obj = zeros(length(obj_cat),nr);
                
                obj_cat2 = categorical({'activation','maintenance','shortening','work'});
                obj2 = zeros(length(obj_cat2),nr);
                obj3 = obj2;

            end
            
%             obj(1,inr) = R.Obj.J;
            obj(1,inr) = R.Obj.E;
            obj(2,inr) = R.Obj.A;
            obj(3,inr) = R.Obj.Arm;
            obj(4,inr) = R.Obj.Mtp;
            if isfield(R.Obj,'PIM')
                obj(5,inr) = R.Obj.PIM;
            end
            if isfield(R.Obj,'P_PIM')
                obj(6,inr) = R.Obj.P_PIM;
            end
            obj(7,inr) = R.Obj.qdd;
            obj(8,inr) = R.Obj.Pass;
            obj(9,inr) = R.Obj.vA;
            
            
            E_sum = sum( trapz(R.t,R.MetabB.Etot,1) )/R.body_mass/dist_trav;
            A_sum = sum( trapz(R.t,R.MetabB.Adot,1) )/R.body_mass/dist_trav;
            M_sum = sum( trapz(R.t,R.MetabB.Mdot,1) )/R.body_mass/dist_trav;
            S_sum = sum( trapz(R.t,R.MetabB.Sdot,1) )/R.body_mass/dist_trav;
            W_sum = sum( trapz(R.t,R.MetabB.Wdot,1) )/R.body_mass/dist_trav;
            
            E_comp_sum = [A_sum,M_sum,S_sum,W_sum];
            E_comp_sum_rel = E_comp_sum/E_sum;
            obj2(:,inr) = E_comp_sum_rel*100;
            obj3(:,inr) = E_comp_sum;
            
            
            if inr == nr
                figure(h28);
%                 hold on
%                 subplot(1,3,1)
%                 br5=bar(obj_cat,obj);
%                 for ibr=1:length(br5)
%                    br5(ibr).FaceColor = 'flat';
%                    br5(ibr).CData = CsV(ibr,:);
%                 end
%                 title('')
                
                subplot(1,3,3)
                hold on
                br6=bar(obj_cat2,obj2);
                for ibr=1:length(br6)
                   br6(ibr).FaceColor = 'flat';
                   br6(ibr).CData = CsV(ibr,:);
                end
                sgtitle('Metabolic energy terms')
                ylabel('(%)')

                subplot(1,3,1)
                hold on
                br7=bar(obj_cat2,obj3);
                for ibr=1:length(br7)
                   br7(ibr).FaceColor = 'flat';
                   br7(ibr).CData = CsV(ibr,:);
                end
                ylabel('(J kg^-^1 m^-^1)')

                subplot(1,3,2)
                hold on
                br7=bar(obj_cat2,obj3-obj3(:,1));
                for ibr=2:length(br7)
                   br7(ibr).FaceColor = 'flat';
                   br7(ibr).CData = CsV(ibr,:);
                end
                yline(0,'Color',CsV(1,:))
                ylabel('(J kg^-^1 m^-^1)')

            end
            
            if inr==nr && ~strcmp(figNamePrefix,'none')
                set(h28,'PaperPositionMode','auto')
                print(h28,[figNamePrefix '_musc_E'],'-dpng','-r0')
%                 print(h28,[figNamePrefix '_musc_E'],'-depsc')
            end
            
    end

    

%%
    if makeplot.muscle_act
        if inr==1
            h29 = figure('Position',[fpos(3,:),fsq]);

            musc_exp = {'Gluteus-medialis','Rectus-femoris','Adductor-longus',...
                'Peroneus-longus','Peroneus-brevis','Hamstrings-lateralis',...
                'Hamstrings-medialis','Vastus-lateralis','Vastus-medialis',...
                'Tibialis-anterior','Gastrocnemius-lateralis','Gastrocnemius-medialis','Soleus'};

            musc_sim = {'glut_med1_r','rect_fem_r','add_long_r','per_long_r',...
                'per_brev_r','bifemlh_r','semimem_r','vas_lat_r','vas_med_r',...
                'tib_ant_r','lat_gas_r','med_gas_r','soleus_r'};

            for i=1:numel(musc_exp)
                subplot(5,3,i)
                hold on
                imus_i = find(strcmp(Data.EMGheaders,musc_exp{i}));
                yyaxis right
                meanPlusSTD = Data.lowEMG_mean(:,imus_i) + 2*Data.lowEMG_std(:,imus_i);
                meanMinusSTD = Data.lowEMG_mean(:,imus_i) - 2*Data.lowEMG_std(:,imus_i);
                stepQ = (size(R.Qs,1)-1)/(size(meanPlusSTD,1)-1);
                intervalQ = 1:stepQ:size(R.Qs,1);
                sampleQ = 1:size(R.Qs,1);
                meanPlusSTD = interp1(intervalQ,meanPlusSTD,sampleQ);
                meanMinusSTD = interp1(intervalQ,meanMinusSTD,sampleQ);
                fill([x fliplr(x)],[meanPlusSTD fliplr(meanMinusSTD)],'k');
                alpha(.25);
                set(gca,'XTick',[0:20:100])
                yyaxis left
                title(musc_sim{i},'Interpreter','none')
                axis tight
                yl = get(gca, 'ylim');
                ylim([0,yl(2)+0.1*norm(yl)])
                xlim([0,100])
               
            end
        end
        figure(h29)
        for i=1:numel(musc_exp)
            subplot(5,3,i)
            imus_i = find(strcmp(R.colheaders.muscles,musc_sim{i}));
            hold on
            plot(x,R.a(:,imus_i),'-','Color',CsV(inr,:),'DisplayName',LegName);
            ylabel('Activity (-)');
            axis tight
            yl = get(gca, 'ylim');
            ylim([0,yl(2)+0.1*norm(yl)])
            xlim([0,100])
        end
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h29,'PaperPositionMode','auto')
            print(h29,[figNamePrefix '_musc_act'],'-dpng','-r0')
%             print(h29,[figNamePrefix '_musc_act'],'-depsc')
        end
        
    end

    %%

    if makeplot.muscle_act_exc
        if inr==1
            h29a = figure('Position',[fpos(3,:),fsq]);

            musc_sim = {'per_long_r','per_brev_r','tib_ant_r',...
                'lat_gas_r','med_gas_r','soleus_r'};
            idx_act = [1,2,3,7,8,9];
        end
        figure(h29a)
        for i=1:numel(musc_sim)
            subplot(4,3,idx_act(i)+3)
            imus_i = find(strcmp(R.colheaders.muscles,musc_sim{i}));
            hold on
            plot(x,R.a(:,imus_i),'-','Color',CsV(inr,:),'DisplayName',LegName);
            ylabel('Activity (-)');
            axis tight
            yl = get(gca, 'ylim');
            ylim([0,yl(2)+0.1*norm(yl)])
            xlim([0,100])
            title(musc_sim{i},'Interpreter','none')
            
            subplot(4,3,idx_act(i))
            imus_i = find(strcmp(R.colheaders.muscles,musc_sim{i}));
            hold on
            plot(x,R.e(:,imus_i),'-','Color',CsV(inr,:),'DisplayName',LegName);
            ylabel('Excitation (-)');
            axis tight
            yl = get(gca, 'ylim');
            ylim([0,yl(2)+0.1*norm(yl)])
            xlim([0,100])
        end
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h29a,'PaperPositionMode','auto')
            print(h29a,[figNamePrefix '_musc_act_exc'],'-dpng','-r0')
%             print(h29a,[figNamePrefix '_musc_act_exc'],'-depsc')
        end
        
    end

    %%

    if makeplot.muscle_joint_moment
        if inr==1
            h30 = figure('Position',[fpos(4,:),ffull]);
        end   

        musi_ankle = find(R.dM(1,:,5)~=0 | R.dM(1,:,7)~=0);

        nr_musi_ankle = length(musi_ankle);
        
        musi_ankle = musi_ankle(nr_musi_ankle/2+1:end);
        nr_musi_ankle_1 = length(musi_ankle);
        nr_musi_ankle = 13;

        figure(h30)
        for i=1:nr_musi_ankle_1
           idx_dM = 5;
           subplot(4,nr_musi_ankle,i)
           hold on
           title(replace(replace(R.colheaders.muscles{musi_ankle(i)},'_r',''),'_',' '),'interpreter','none','Fontsize',12)
           T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM);
           idx_dM = idx_dM + 1;
           if norm(T_mus)>0
               plot(x,T_mus/body_mass,'Color',CsV(inr,:),'DisplayName',LegName);
           end
           if i==1
               ylabel('Ankle moment (Nm/kg)','Fontsize',10)
               if inr==1
                   legend('Fontsize',12,'Orientation','horizontal','Box','off')
               end
           end
%            if i==nr_musi_ankle-1
%                lh30=legend('location','northeast','Interpreter',lgInt);
%            end
           
           subplot(4,nr_musi_ankle,nr_musi_ankle+i)
           hold on
           T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM);
           idx_dM = idx_dM + 1;
           if norm(T_mus)>0
               plot(x,T_mus/body_mass,'Color',CsV(inr,:),'DisplayName',LegName);
           end
           if i==1
               ylabel('Subtalar moment (Nm/kg)','Fontsize',10)
           end

           subplot(4,nr_musi_ankle,2*nr_musi_ankle+i)
           hold on
           if i==1
               ylabel('Midtarsal moment (Nm/kg)','Fontsize',10)
           end
           if ~has_no_mtj && R.S.Foot.mtj_muscles
               T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM);
               idx_dM = idx_dM + 1;
               if norm(T_mus)>0
                   plot(x,T_mus/body_mass,'Color',CsV(inr,:),'DisplayName',LegName);
               end
           elseif ~has_no_mtj
               T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM);
               idx_dM = idx_dM + 1;
               if norm(T_mus)>0
%                    plot(x,T_mus,':','Color',CsV(inr,:),'DisplayName',LegName);
               end
           end

           subplot(4,nr_musi_ankle,3*nr_musi_ankle+i)
           hold on
           if i==1
               ylabel('MTP moment (Nm/kg)','Fontsize',10)
           end
           if R.S.Foot.mtp_muscles
               T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM);
               if norm(T_mus)>0
                   plot(x,T_mus/body_mass,'Color',CsV(inr,:),'DisplayName',LegName);
               end
           else
               T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM);
               if norm(T_mus)>0
%                    plot(x,T_mus,':','Color',CsV(inr,:),'DisplayName',LegName);
               end
           end
           
            xlabel('Gait cycle (%)','Fontsize',10)
            
        end

%        lhPos = lh30.Position;
%        lhPos(1) = lhPos(1)+0.1;
%        lhPos(2) = lhPos(2)+0.1;
%        set(lh30,'position',lhPos);

        if R.S.Foot.PIM
            subplot(4,nr_musi_ankle,3*nr_musi_ankle)
            hold on
            title('PIM')
            plot(x,M_mtj_PIM/body_mass,'Color',CsV(inr,:),'DisplayName',LegName);

            subplot(4,nr_musi_ankle,4*nr_musi_ankle)
            hold on
            plot(x,M_mtp_PIM/body_mass,'Color',CsV(inr,:),'DisplayName',LegName);
        end
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h30,'PaperPositionMode','auto')
            print(h30,[figNamePrefix '_musc_moment'],'-dpng','-r0')
%             print(h30,[figNamePrefix '_musc_moment'],'-depsc')
        end
    end
    
    %%

    if makeplot.muscle_joint_power
        if inr==1
            h31 = figure('Position',[fpos(4,:),ffull]);
            
           
        end

        musi_ankle = find(R.dM(1,:,5)~=0 | R.dM(1,:,7)~=0);
        nr_musi_ankle = length(musi_ankle);
        
        musi_ankle = musi_ankle(nr_musi_ankle/2+1:end);
        nr_musi_ankle = length(musi_ankle);
        nr_musi_ankle_1 = length(musi_ankle);
        nr_musi_ankle = 13;
        
        figure(h31)
        for i=1:nr_musi_ankle_1
           idx_dM = 5;
           subplot(4,nr_musi_ankle,i)
           hold on
           title(R.colheaders.muscles{musi_ankle(i)},'interpreter','none')
           T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM)/R.body_mass;
           idx_dM = idx_dM + 1;
           plot(x,T_mus.*R.Qdots(:,iankle)*pi/180,'Color',CsV(inr,:),'DisplayName',LegName);
           if i==1
               ylabel('P ankle (W/kg)')
           end
           if i==nr_musi_ankle-1
               lh31=legend('location','northeast','Interpreter',lgInt);
           end
           
           subplot(4,nr_musi_ankle,nr_musi_ankle+i)
           hold on
           T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM)/R.body_mass;
           idx_dM = idx_dM + 1;
           plot(x,T_mus.*R.Qdots(:,isubt)*pi/180,'Color',CsV(inr,:),'DisplayName',LegName);
           if i==1
               ylabel('P subt (W/kg)')
           end

           subplot(4,nr_musi_ankle,2*nr_musi_ankle+i)
           hold on
           if i==1
               ylabel('P mtj (W/kg)')
           end
           if ~has_no_mtj && R.S.Foot.mtj_muscles
               T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM)/R.body_mass;
               idx_dM = idx_dM + 1;
               if norm(T_mus)>0
                   P_mus_mtj = T_mus.*R.Qdots(:,imtj)*pi/180;
                   plot(x,P_mus_mtj,'Color',CsV(inr,:),'DisplayName',LegName);
               end
           end

           subplot(4,nr_musi_ankle,3*nr_musi_ankle+i)
           hold on
           if i==1
               ylabel('P mtp (W/kg)')
           end
           if R.S.Foot.mtp_muscles
               T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM)/R.body_mass;
               if norm(T_mus)>0
                   plot(x,T_mus.*R.Qdots(:,imtp)*pi/180,'Color',CsV(inr,:),'DisplayName',LegName);
               end
%            else
%                T_mus = R.FT(:,musi_ankle(i)) .* R.dM(:,musi_ankle(i),idx_dM);
%                if norm(T_mus)>0
%                    plot(x,T_mus.*R.Qdots(:,imtp)*pi/180,':','Color',CsV(inr,:),'DisplayName',LegName);
%                end
           end
           
            xlabel('% GC')
            
        end

       lhPos = lh31.Position;
       lhPos(1) = lhPos(1)+0.1;
       lhPos(2) = lhPos(2)+0.1;
       set(lh31,'position',lhPos);

        if R.S.Foot.PIM
            subplot(4,nr_musi_ankle,3*nr_musi_ankle)
            hold on
            title('PIM')
            plot(x,M_mtj_PIM.*R.Qdots(:,imtj)*pi/180/R.body_mass,'Color',CsV(inr,:),'DisplayName',LegName);

            subplot(4,nr_musi_ankle,4*nr_musi_ankle)
            hold on
            plot(x,M_mtp_PIM.*R.Qdots(:,imtp)*pi/180/R.body_mass,'Color',CsV(inr,:),'DisplayName',LegName);
        end
        
    end

    %%
    
    %%

    if makeplot.Objective_cost
        if inr==1
            h32 = figure('Position',[fpos(3,:),fsq]);
        end
        
        figure(h32)
        subplot(2,6,1)
        plot(inr,R.Obj.J,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('Objective')
%         disp(R.Obj.J)
%         disp(R.COT)

        subplot(2,6,2)
        plot(inr,R.Obj.E/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('E_{metabolic}')

        subplot(2,6,3)
        plot(inr,R.Obj.A/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('activity')

        subplot(2,6,4)
        plot(inr,R.Obj.Arm/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('arms e')

        subplot(2,6,5)
        plot(inr,R.Obj.Mtp/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('mtp e')

        if isfield(R.Obj,'PIM') && R.Obj.PIM >0
            subplot(2,6,6)
            plot(inr,R.Obj.PIM/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
            hold on
            title('PIM e')
        end

        if isfield(R.Obj,'P_PIM')  && R.Obj.P_PIM >0
            subplot(2,6,7)
            plot(inr,R.Obj.P_PIM/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
            hold on
            title('PIM Work')
        end

        subplot(2,6,8)
        plot(inr,R.Obj.qdd/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('accelerations')

        subplot(2,6,9)
        plot(inr,R.Obj.Pass/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('passive torques')

        subplot(2,6,10)
        plot(inr,R.Obj.vA/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:),'DisplayName',LegName)
        hold on
        title('da/dt')

        lh32=legend('location','northeast','Interpreter',lgInt);

        if isfield(R.Obj,'Track')  && R.Obj.Track >0
            subplot(2,6,11)
            plot(inr,R.Obj.Track/dist_trav*2,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:),'DisplayName',LegName)
            hold on
            title('Tracking')
        end

       

    end

    %%

    %% kinetics
    if makeplot.tau_pass
        
        if inr==1
            h33 = figure('Position',[fpos(2,:),fwide]);
        else
            figure(h33);
        end

        if has_no_tmt && has_no_mtj
            idx_Qs = [10,11,12,14,16,18,20,21,22,23,27,28,29,31]-6;
        else
            idx_Qs = [10,11,12,14,16,18,20,22,23,24,25,29,30,31,33]-6;
        end
        idx_title = [10,11,12,14,16,18,20,24,25,26,27,31,32,33,35]-6;
        
        joints_tit_1 = {'Hip flexion L','Hip adduction L',...
                'Hip rotation L','Hip flexion R','Hip adduction R','Hip rotation R',...
                'Knee L','Knee R','Ankle L','Ankle R','Subtalar L','Subtalar R',...
                'Midtarsal L','Midtarsal R','Tmt L','Tmt R',...
                'Mtp L','Mtp R',...
                'Lumbar extension','Lumbar bending','Lumbar rotation',...
                'Arm flexion L','Arm adduction L','Arm rotation L',...
                'Arm flexion R','Arm adduction R','Arm rotation R',...
                'Elbow flexion L','Elbow flexion R'};

        figure(h33)
        j = 0;
        label_fontsize  = 12;
        line_linewidth  = 0.5;
        x = 1:(100-1)/(size(R.Qs,1)-1):100;
        for i = 1:length(idx_title)
            subplot(5,3,i)
            
            hold on;
            axis tight
            xlim([0,100]);
            if (has_no_tmt && strcmp(joints_tit_1{idx_title(i)},'Tarsometatarsal R')) || ...
                    (has_no_mtj && strcmp(joints_tit_1{idx_title(i)},'Midtarsal R'))
                % skip this plot
            else
                j=j+1;
                plot(x,R.TPass(:,idx_Qs(j)),'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            end
            % Plot settings
            if inr==1
                % Plot settings
                set(gca,'Fontsize',label_fontsize);
                title(joints_tit_1{idx_title(i)},'Fontsize',label_fontsize);
                % Y-axis
                if i == 1 || i == 4 || i == 7 || i == 10 || i == 13 || i == 16
                    ylabel('Passive torque (Nm)','Fontsize',label_fontsize);
                end
                % X-axis
                L = get(gca,'XLim');
                NumTicks = 3;
                set(gca,'XTick',linspace(L(1),L(2),NumTicks))
                if i > 15
                    xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                end
            end
            if inr==1 && i==1
                lhT=legend('-DynamicLegend','location','northwest');
                lhT.Interpreter = lgInt;
                lhT.Orientation = 'horizontal';
            end
            if inr==nr && i==1
                lhPos = lhT.Position;
                lhPos(1) = lhPos(1)-0.1;
                lhPos(2) = lhPos(2)+0.08;
                set(lhT,'position',lhPos);
            end
        end 
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h33,'PaperPositionMode','auto')
            print(h33,[figNamePrefix '_Tpass_all'],'-dpng','-r0')
%             print(h33,[figNamePrefix '_Tpass_all'],'-depsc')
        end
    end

    %%


    if makeplot.windlass_mtp
        if inr==1
            h34 = figure('Position',[fpos(4,:),fwide]);
            tiledlayout(2,3)
            lg34 = [];
        end
        
        figure(h34)
        
        if ~isempty(imtj)

            nexttile(1)
            p1=plot(R.Qs(:,imtj),-R.Tid(:,imtj),'.','color',Cs,'DisplayName',LegName);
            
            hold on
            xlabel('mtj angle (°)')
            ylabel('mtj torque (Nm)')

            lg34a(1)=plot(R.Qs(iheel_contact(1),imtj),-R.Tid(iheel_contact(1),imtj),'o','Color',p1.Color,'MarkerSize',15,'DisplayName','first heel contact');
            lg34a(2)=plot(R.Qs(iheel_contact(end),imtj),-R.Tid(iheel_contact(end),imtj),'*','Color',p1.Color,'MarkerSize',15,'DisplayName','last heel contact');
            lg34a(3)=plot(R.Qs(iff_contact(1),imtj),-R.Tid(iff_contact(1),imtj),'+','Color',p1.Color,'MarkerSize',15,'DisplayName','first forefoot contact');
            lg34a(4)=plot(R.Qs(iff_contact(end),imtj),-R.Tid(iff_contact(end),imtj),'x','Color',p1.Color,'MarkerSize',15,'DisplayName','last forefoot contact');
            lg34a(5)=plot(R.Qs(itoe_contact(1),imtj),-R.Tid(itoe_contact(1),imtj),'<','Color',p1.Color,'MarkerSize',15,'DisplayName','first toe contact');
            lg34a(6)=plot(R.Qs(itoe_contact(end),imtj),-R.Tid(itoe_contact(end),imtj),'d','Color',p1.Color,'MarkerSize',15,'DisplayName','last toe contact');
            if inr==nr
                lh34a=legend(lg34a);
                lh34a.Layout.Tile = 6;
            end
            
            nexttile(3)
            p2=plot(R.Qs(:,imtj),R.Qs(:,imtp),'.','Color',Cs);
            hold on
            plot(R.Qs(iheel_contact(1),imtj),R.Qs(iheel_contact(1),imtp),'o','Color',Cs,'MarkerSize',15)
            plot(R.Qs(iheel_contact(end),imtj),R.Qs(iheel_contact(end),imtp),'*','Color',Cs,'MarkerSize',15)
            plot(R.Qs(iff_contact(1),imtj),R.Qs(iff_contact(1),imtp),'+','Color',Cs,'MarkerSize',15)
            plot(R.Qs(iff_contact(end),imtj),R.Qs(iff_contact(end),imtp),'x','Color',Cs,'MarkerSize',15)
            plot(R.Qs(itoe_contact(1),imtj),R.Qs(itoe_contact(1),imtp),'<','Color',Cs,'MarkerSize',15)
            plot(R.Qs(itoe_contact(end),imtj),R.Qs(itoe_contact(end),imtp),'d','Color',Cs,'MarkerSize',15)
            ylabel('mtpj angle (°)')
            xlabel('mtj angle (°)')

            lg34(end+1) = p2;

            nexttile(2)
            plot(R.Qs(:,imtp),-R.Tid(:,imtp),'.','color',Cs,'DisplayName',LegName);
            hold on
            xlabel('mtpj angle (°)')
            ylabel('mtpj torque (Nm)')

            plot(R.Qs(iheel_contact(1),imtp),-R.Tid(iheel_contact(1),imtp),'o','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(iheel_contact(end),imtp),-R.Tid(iheel_contact(end),imtp),'*','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(iff_contact(1),imtp),-R.Tid(iff_contact(1),imtp),'+','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(iff_contact(end),imtp),-R.Tid(iff_contact(end),imtp),'x','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(itoe_contact(1),imtp),-R.Tid(itoe_contact(1),imtp),'<','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(itoe_contact(end),imtp),-R.Tid(itoe_contact(end),imtp),'d','Color',p1.Color,'MarkerSize',15)
            
            [~,imaxmtp] = max(-R.Tid(:,imtp));
            ply_mtp = polyfit(R.Qs(imaxmtp:iff_contact(end),imtp),R.Tid(imaxmtp:iff_contact(end),imtp),1);
            k_mtp = ply_mtp(1)

            nexttile(4)
            plot(R.Qs(:,imtp),l_PF,'.','color',Cs,'DisplayName',LegName);
            hold on
            xlabel('mtpj angle (°)')
            ylabel('plantar fascia length (m)')

            plot(R.Qs(iheel_contact(1),imtp),l_PF(iheel_contact(1)),'o','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(iheel_contact(end),imtp),l_PF(iheel_contact(end)),'*','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(iff_contact(1),imtp),l_PF(iff_contact(1)),'+','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(iff_contact(end),imtp),l_PF(iff_contact(end)),'x','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(itoe_contact(1),imtp),l_PF(itoe_contact(1)),'<','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(itoe_contact(end),imtp),l_PF(itoe_contact(end)),'d','Color',p1.Color,'MarkerSize',15)
            
            nexttile(5)
            plot(R.Qs(:,imtp),F_PF,'.','color',Cs,'DisplayName',LegName);
            hold on
            xlabel('mtpj angle (°)')
            ylabel('plantar fascia force (N)')

            plot(R.Qs(iheel_contact(1),imtp),F_PF(iheel_contact(1)),'o','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(iheel_contact(end),imtp),F_PF(iheel_contact(end)),'*','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(iff_contact(1),imtp),F_PF(iff_contact(1)),'+','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(iff_contact(end),imtp),F_PF(iff_contact(end)),'x','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(itoe_contact(1),imtp),F_PF(itoe_contact(1)),'<','Color',p1.Color,'MarkerSize',15)
            plot(R.Qs(itoe_contact(end),imtp),F_PF(itoe_contact(end)),'d','Color',p1.Color,'MarkerSize',15)
            


            if inr==nr
                nexttile(3)
                lh34 = legend(lg34,'Location','north');
%                 annotation('textbox',[0.15,0.6,0.2,0.27],'String',{'o  first heel contact','*   last heel contact','+  first forefoot contact','x  last forefoot contact','<  first toe contact','d  last toe contact'})
            end
            
        end

            
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h34,'PaperPositionMode','auto')
            print(h34,[figNamePrefix '_WL_mtp'],'-dpng','-r0')
%             print(h34,[figNamePrefix '_WL_mtp'],'-depsc')
        end
    end

    %%
    if makeplot.compareZelik15
        
        if inr==1
            pathmain = pwd;
            [pathRepo,~,~]  = fileparts(pathmain);
            folder = '\Figures';
            file = 'Zelik15.png';
            pathRefImg = fullfile(pathRepo,folder,file);
            img_Zelik = imread(pathRefImg);
            h35 = figure('Position',[fpos(2,:),fsq]);
            subplot(1,2,1)
            hold on
            axis tight
            hi1 = image([-30,105],flip([0,1]),img_Zelik);
            uistack(hi1,'bottom')
            set(gca,'YTickLabel','')
        end
        if isempty(iFDB)
            iFDB = 0;
        end
        imus_Z = [iGas,iGas2,iSol,iPerL,iPerB,ifd,iFDB,0,0,ieh,iTibAnt];
        figure(h35)
        for iz=1:length(imus_Z)
            subplot(11,2,iz*2)
            hold on
            if imus_Z(iz)~=0
                plot(R.a(:,imus_Z(iz)),'-','Color',CsV(inr,:),'DisplayName',LegName);
            end
            if iz~=length(imus_Z)
                set(gca,'XTickLabel','')
            end
        end
        xlabel('Gait cycle (%)')

        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h35,'PaperPositionMode','auto')
            print(h35,[figNamePrefix '_Zelik'],'-dpng','-r0')
%             print(h35,[figNamePrefix '_Zelik'],'-depsc')
        end
    end

    %%
    if makeplot.compareZelik15b
        if inr==1
            h35a = figure('Position',[fpos(2,:),fsq]);
        end
        figure(h35a)

        subplot(5,1,1)
        hold on
        plot(x,P_leg_joints+P_HC,'-','Color',CsV(inr,:),'DisplayName',LegName);
        yl = [-2,3];
        ylim(yl)
        ylabel('Total (W/kg)')
        xline(x(iswing(1)),'--','Color',CsV(inr,:))
        if inr==1
            yline(0,'k')
        end

        subplot(5,1,2)
        hold on
        plot(x,P_hip,'-','Color',CsV(inr,:),'DisplayName',LegName);
        ylim(yl)
        ylabel('Hip (W/kg)')
        xline(x(iswing(1)),'--','Color',CsV(inr,:))
        if inr==1
            yline(0,'k')
        end

        subplot(5,1,3)
        hold on
        plot(x,P_knee,'-','Color',CsV(inr,:),'DisplayName',LegName);
        ylim(yl)
        ylabel('Knee (W/kg)')
        xline(x(iswing(1)),'--','Color',CsV(inr,:))
        if inr==1
            yline(0,'k')
        end

        subplot(5,1,4)
        hold on
        plot(x,P_ankle+P_subt,'-','Color',CsV(inr,:),'DisplayName',LegName);
        ylim(yl)
        ylabel('Ankle(W/kg)')
        xline(x(iswing(1)),'--','Color',CsV(inr,:))
        if inr==1
            yline(0,'k')
        end

        subplot(5,1,5)
        hold on
        plot(x,P_dist_hindfoot,'-','Color',CsV(inr,:),'DisplayName',LegName);
        ylim(yl)
        ylabel('Foot (W/kg)')
        xline(x(iswing(1)),'--','Color',CsV(inr,:))
        if inr==1
            yline(0,'k')
        end

        xlabel('Gait cycle (%)')
        
    end

    %%
    if makeplot.COP
        if inr==1
            h36 = figure('Position',[fpos(2,:),fsq]);
            subplot(2,1,1)
            hold on
            xlabel('Anterior (mm)')
            ylabel('Superior (mm)')

            subplot(2,1,2)
            hold on
            xlabel('Anterior (mm)')
            ylabel('Lateral (mm)')


        end
    
        if ~isfield(R,'COP_in_calcn') || ~isfield(R,'COP_wrt_talus_in_calcn')
            [COP_in_calcn, COP_wrt_talus_in_calcn] = getCOPInFootFrame(R);
            R.COP_in_calcn = COP_in_calcn*1e3;
            R.COP_wrt_talus_in_calcn = COP_wrt_talus_in_calcn*1e3;

            save(ResultsFile{inr},'R','-append');
        end

        istance_COPR = find(R.GRFs(:,2)>30);
        mtp_centre = [0.1182,-0.0630,0.0090]*1e3;

        figure(h36)
        subplot(211)
        hold on
        plot(R.COP_wrt_talus_in_calcn(istance_COPR,1),R.COP_wrt_talus_in_calcn(istance_COPR,2),'.','Color',CsV(inr,:),'DisplayName',LegName);
        plot(R.COP_wrt_talus_in_calcn(istance_COPR(1),1),R.COP_wrt_talus_in_calcn(istance_COPR(1),2),'+','Color',CsV(inr,:),'DisplayName',[LegName ' (heel strike)']);
        plot(R.COP_wrt_talus_in_calcn(istance_COPR(end),1),R.COP_wrt_talus_in_calcn(istance_COPR(end),2),'o','Color',CsV(inr,:),'DisplayName',[LegName ' (toe-off)']);
        if inr==nr

            axis equal
            xlm = get(gca,'XLim');
            xlm(1) = xlm(1)-5;
            xlm(2) = xlm(2)+5;
            xlim(xlm)
            title('Centre of pressure wrt ankle centre, in hindfoot ref frame')
            plot(mtp_centre(1),mtp_centre(2),'dk')
        end

        subplot(2,1,2)
        hold on
        plot(R.COP_wrt_talus_in_calcn(istance_COPR,1),R.COP_wrt_talus_in_calcn(istance_COPR,3),'.','Color',CsV(inr,:),'DisplayName',LegName);
        plot(R.COP_wrt_talus_in_calcn(istance_COPR(1),1),R.COP_wrt_talus_in_calcn(istance_COPR(1),3),'+','Color',CsV(inr,:),'DisplayName',[LegName ' (heel strike)']);
        plot(R.COP_wrt_talus_in_calcn(istance_COPR(end),1),R.COP_wrt_talus_in_calcn(istance_COPR(end),3),'o','Color',CsV(inr,:),'DisplayName',[LegName ' (toe-off)']);
        if inr==nr
            axis equal
            xlim(xlm)
            plot(mtp_centre(1),mtp_centre(3),'dk','DisplayName','MTP centre')
            legend('Location','best')
        end

    end


    %

    if makeplot.ankle_gearing
        if inr==1
            h37 = figure('Position',[fpos(2,:),fwide]);

            subplot(1,3,1)
            xlabel('% stance')
            ylabel('GRF lever arm (mm)')


            subplot(1,3,2)
            xlabel('% stance')
            ylabel('plantar flexor lever arm (mm)')

            subplot(1,3,3)
            xlabel('% stance')
            ylabel('ratio (-)')

        end
    
        if ~isfield(R,'COP_in_calcn') || ~isfield(R,'COP_wrt_talus_in_calcn') ...
                || ~isfield(R,'talus_in_gnd') %|| true
            [COP_in_calcn, COP_wrt_talus_in_calcn,talus_in_gnd] = getCOPInFootFrame(R);
            R.COP_in_calcn = COP_in_calcn*1e3;
            R.COP_wrt_talus_in_calcn = COP_wrt_talus_in_calcn*1e3;
            R.talus_in_gnd = talus_in_gnd;

            save(ResultsFile{inr},'R','-append');
        end

        GRF_lever = nan(size(R.talus_in_gnd,1),1);
        for igr=1:size(R.talus_in_gnd,1)

            vec_a = R.talus_in_gnd(igr,:) - R.COPR(igr,:);
            vec_b = R.GRFs(igr,1:3);
%             vec_a(3) = 0;
%             vec_b(3) = 0;
            vec_ap = dot(vec_a,vec_b)/dot(vec_b,vec_b)*vec_b; % orthogonal projection of a onto b
            vec_an = vec_a - vec_ap; % component of a that is normal to b 

            GRF_lever(igr) = norm(vec_an)*1e3 *(-sign(vec_a(1)));

        end
%         GRF_lever = sqrt(sum(R.COP_wrt_talus_in_calcn.^2,2));

        PF_lever = -R.dM(:,iSol,5)*1e3;

        figure(h37)
        subplot(131)
        hold on
%         plot(x,GRF_lever,'-','Color',CsV(inr,:),'DisplayName',LegName);
        plot(xst,GRF_lever(istance0),'-','Color',CsV(inr,:),'DisplayName',LegName);

        subplot(132)
        hold on
%         plot(x,PF_lever,'-','Color',CsV(inr,:),'DisplayName',LegName);
        plot(xst,PF_lever(istance0),'-','Color',CsV(inr,:),'DisplayName',LegName);

        subplot(133)
        hold on
%         plot(x,GRF_lever./PF_lever,'-','Color',CsV(inr,:),'DisplayName',LegName);
        plot(xst,GRF_lever(istance0)./PF_lever(istance0),'-','Color',CsV(inr,:),'DisplayName',LegName);

    end

    %

   %%

    if makeplot.mtj_moments
        if inr==1
            h37 = figure('Position',[fpos(4,:),fsq]);
            tiledlayout('flow')
        end   

        figure(h37)
        if ~has_no_mtj
            nexttile(1)
            hold on
            plot(x,R.Tid(:,imtj),'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Total moment mtj')
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('Moment (Nm)','Fontsize',label_fontsize);

            nexttile(2)
            hold on
            plot(x,M_mtj_li,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Ligaments')
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('Moment (Nm)','Fontsize',label_fontsize);

            nexttile(3)
            hold on
            plot(x,M_mtj_PF,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Plantar fascia')
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('Moment (Nm)','Fontsize',label_fontsize);

        end

        if ~has_no_mtj && R.S.Foot.mtj_muscles
            musi_mtj = find(R.dM(1,:,7)~=0);
    
            nr_musi_mtp = length(musi_mtj);
            
            musi_mtj = musi_mtj(nr_musi_mtp/2+1:end);
            nr_musi_mtj_1 = length(musi_mtj);
%             nr_musi_mtj = 13;
    

            for i=1:nr_musi_mtj_1
               nexttile(i+3)
               hold on
               if ~has_no_mtj && R.S.Foot.mtj_muscles
                   T_mus = R.FT(:,musi_mtj(i)) .* R.dM(:,musi_mtj(i),7);
                   if norm(T_mus)>0
                       plot(x,T_mus,'Color',CsV(inr,:),'DisplayName',LegName);
                   end
               elseif ~has_no_mtj
                   T_mus = R.FT(:,musi_mtj(i)) .* R.dM(:,musi_mtj(i),7);
                   if norm(T_mus)>0
    %                    plot(x,T_mus,':','Color',CsV(inr,:),'DisplayName',LegName);
                   end
               end
    
               title(R.colheaders.muscles{musi_mtj(i)},'interpreter','none')
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('Moment (Nm)','Fontsize',label_fontsize);
                
            end

        end

        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h37,'PaperPositionMode','auto')
            print(h37,[figNamePrefix '_musc_moment'],'-dpng','-r0')
        end
    end

    %%

    if makeplot.mtj_powers
        if inr==1
            h37a = figure('Position',[fpos(4,:),fsq]);
            tiledlayout('flow')
        end   

        figure(h37a)
        if ~has_no_mtj
            nexttile(1)
            hold on
            plot(x,R.Tid(:,imtj).*qdot_mtj/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Total')
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('Power (W/kg)','Fontsize',label_fontsize);

            lg = legend('Fontsize',label_fontsize,'Box','off');
            lg.Layout.Tile = 14;

            nexttile(2)
            hold on
            plot(x,M_mtj_li.*qdot_mtj/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Ligaments')
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('Power (W/kg)','Fontsize',label_fontsize);

            nexttile(3)
            hold on
            plot(x,M_mtj_PF.*qdot_mtj/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Plantar fascia')
            xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('Power (W/kg)','Fontsize',label_fontsize);

        end

        if ~has_no_mtj && R.S.Foot.mtj_muscles
            musi_mtj = find(R.dM(1,:,7)~=0);
    
            nr_musi_mtp = length(musi_mtj);
            
            musi_mtj = musi_mtj(nr_musi_mtp/2+1:end);
            nr_musi_mtj_1 = length(musi_mtj);
%             nr_musi_mtj = 13;
    

            for i=1:nr_musi_mtj_1
               nexttile(i+3)
               hold on
               if ~has_no_mtj && R.S.Foot.mtj_muscles
                   T_mus = R.FT(:,musi_mtj(i)) .* R.dM(:,musi_mtj(i),7);
                   if norm(T_mus)>0
                       plot(x,T_mus.*qdot_mtj/R.body_mass,'Color',CsV(inr,:),'DisplayName',LegName);
                   end
               elseif ~has_no_mtj
                   T_mus = R.FT(:,musi_mtj(i)) .* R.dM(:,musi_mtj(i),7);
                   if norm(T_mus)>0
    %                    plot(x,T_mus,':','Color',CsV(inr,:),'DisplayName',LegName);
                   end
               end
    
               title(replace(replace(R.colheaders.muscles{musi_mtj(i)},'_r',''),'_',' '),'interpreter','none')
                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('Power (W/kg)','Fontsize',label_fontsize);
                
            end

        end

        
%         if inr==nr && ~strcmp(figNamePrefix,'none')
%             set(h37a,'PaperPositionMode','auto')
%             print(h37a,[figNamePrefix '_musc_moment'],'-dpng','-r0')
%         end
    end

    %%

    if makeplot.peak_soleus
        if inr==1
            h38 = figure('Position',[fpos(4,:),fsq]);
            tiledlayout('flow')
        end   

        figure(h38)

        nexttile(1)
        plot(inr,max(R.a(:,iSol)),'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('Peak soleus activity')
        ylabel('Activity (-)')
        
        nexttile(2)
        [max_Fsol,idx_max_Fsol] = max(R.FT(:,iSol));
        
        plot(inr,max_Fsol,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('Peak soleus force')
        ylabel('Force (N)')

        nexttile(3)
        plot(inr,-R.Muscle.vM(idx_max_Fsol,iSol)*1e3,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('Velocity at peak force')
        ylabel('Contraction velocity (mm/s)')

        nexttile(4)
        plot(inr,mean(-R.Muscle.vM(istance0,iSol))*1e3,'o','Color',CsV(inr,:),'MarkerFaceColor',CsV(inr,:))
        hold on
        title('Average velocity')
        ylabel('Contraction velocity (mm/s)')


    end

    %%

    if makeplot.power_windlass
        if inr==1
            h39 = figure('Position',[fpos(4,:)+300,fsq*0.6]);
        end

        figure(h39)

        nh = 2;
        nw = 3;

        if ~isempty(imtj) && max(P_PF)>1e-6
            pos_P_all = {P_mtj, P_mtp, P_mtj+P_mtp,...
                       P_mtj_PF, P_mtp_PF, P_PF,...
                       P_mtj_PIM, P_mtp_PIM, P_PIM,...
                       P_mtj_PIM+P_mtj_PF, P_mtp_PIM+P_mtp_PF, P_PIM+P_PF};
        elseif ~isempty(imtj)
            pos_P_all = {P_mtj, P_mtp, P_mtj+P_mtp,...
                       'none', 'none', 'none',...
                       'none','none', 'none',...
                       'none','none', 'none'};
        else
            pos_P_all = {'none', P_mtp, 'none',...
                       'none', 'none', 'none',...
                       'none','none', 'none',...
                       'none','none', 'none'};
        end

        titles_P_all = {'Midtarsal','MTP','Midtarsal + MTP'};

        
        for i_P=1:numel(pos_P_all)
            if ~strcmp(pos_P_all{i_P},'none')

                i_sp = i_P;
                ls = '-';
                cli = inr;
                
                if i_P > 9
                    i_sp = i_P - 9;
                    ls = '-.';
                    cli = cli+1;
                elseif i_P > 6
                    i_sp = i_P - 3;
                    ls = '-.';
                elseif i_P > 3
                    ls = '-';
                    cli = cli+1;
                end

                subplot(nh,nw,i_sp)
                hold on
                grid on
                plot(xst_10,pos_P_all{i_P}(istance),ls,'Color',CsV(cli,:),'linewidth',line_linewidth);

                if i_P < 4
                    title(titles_P_all{i_P},'Fontsize',label_fontsize);
                end

                xlim([0,100])
                ylim([-0.8,1.3])

                if mod(i_P-1,nw)==0
                    ylabel('P_{mech} (W/kg)','Fontsize',label_fontsize);
                end
                if i_sp > nh*nw-nw
                    xlabel('Stance phase (%)','Fontsize',label_fontsize);
                end
                if i_sp==3 && inr==nr
                   legend({'Joint','Plantar fascia + PIM'},'location','northwest');
                elseif i_sp==6 && inr==nr
                   legend({'Plantar fascia','PIM'},'location','northwest');
                end
                
                
            end
            
        end
        
        

        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h39,'PaperPositionMode','auto')
            print(h39,[figNamePrefix '_P_windlass'],'-dpng','-r0')
        end
    end

%%

    if makeplot.Energy_smoothing
        if inr==1
            h40 = figure('Position',[fpos(3,:),fwide]);
            tiledlayout(1,5)
   
        end
    
        E_sum = sum( trapz(R.t,R.MetabB.Etot,1) )/R.body_mass/dist_trav;
        A_sum = sum( trapz(R.t,R.MetabB.Adot,1) )/R.body_mass/dist_trav;
        M_sum = sum( trapz(R.t,R.MetabB.Mdot,1) )/R.body_mass/dist_trav;
        S_sum = sum( trapz(R.t,R.MetabB.Sdot,1) )/R.body_mass/dist_trav;
        W_sum = sum( trapz(R.t,R.MetabB.Wdot,1) )/R.body_mass/dist_trav;
        
        if isfield(R,'MetabB_smooth')
            E_smooth_sum = sum( trapz(R.t,R.MetabB_smooth.Etot,1) )/R.body_mass/dist_trav;
            A_smooth_sum = sum( trapz(R.t,R.MetabB_smooth.Adot,1) )/R.body_mass/dist_trav;
            M_smooth_sum = sum( trapz(R.t,R.MetabB_smooth.Mdot,1) )/R.body_mass/dist_trav;
            S_smooth_sum = sum( trapz(R.t,R.MetabB_smooth.Sdot,1) )/R.body_mass/dist_trav;
            W_smooth_sum = sum( trapz(R.t,R.MetabB_smooth.Wdot,1) )/R.body_mass/dist_trav;      
        else
            E_smooth_sum = 0;
            A_smooth_sum = 0;
            M_smooth_sum = 0;
            S_smooth_sum = 0;
            W_smooth_sum = 0;
        end

            figure(h40);
 
            nexttile(1)
            hold on
            bar(inr-0.2,A_smooth_sum,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (smoothed)']);
            bar(inr+0.2,A_sum,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (unsmoothed)']);

            ylabel('(J kg^-^1 m^-^1)')
            title('Activation')

            nexttile(2)
            hold on
            bar(inr-0.2,M_smooth_sum,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (smoothed)']);
            bar(inr+0.2,M_sum,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (unsmoothed)']);

            ylabel('(J kg^-^1 m^-^1)')
            title('Maintenance')

            nexttile(3)
            hold on
            bar(inr-0.2,S_smooth_sum,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (smoothed)']);
            bar(inr+0.2,A_sum,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (unsmoothed)']);

            ylabel('(J kg^-^1 m^-^1)')
            title('Shortening')

            nexttile(4)
            hold on
            bar(inr-0.2,W_smooth_sum,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (smoothed)']);
            bar(inr+0.2,A_sum,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (unsmoothed)']);

            ylabel('(J kg^-^1 m^-^1)')
            title('Work')

            nexttile(5)
            hold on
            bar(inr-0.2,R.COT_smoothed,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (smoothed)']);
            bar(inr+0.2,R.COT,0.3,'FaceColor','flat','LineStyle','-','CData',CsV(inr,:),...
                'DisplayName',[LegName ' (unsmoothed)']);

            ylabel('(J kg^-^1 m^-^1)')
            title('Cost of Transport')
        
        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h40,'PaperPositionMode','auto')
            print(h40,[figNamePrefix '_E_smooth'],'-dpng','-r0')
    %                 print(h28,[figNamePrefix '_musc_E'],'-depsc')
        end
        
    end
%%

    if makeplot.mtj_powers
        if inr==1
            h41 = figure('Position',[fpos(4,:),fsq]);
            tl2=tiledlayout(13,3);
            tl2.TileSpacing = 'tight';
        end   

        figure(h41)

        P_mtj_mtp = zeros(length(x),13);

        nexttile(2)
        hold on
        P_mtj_mtp(:,1) = R.Tid(:,imtp).*qdot_mtp/R.body_mass;
        plot(x,R.Tid(:,imtp).*qdot_mtp/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
        title('MTP (total)')
        xlabel('Gait cycle (%)','Fontsize',label_fontsize);

%         ylabel('P (W/kg)','Fontsize',label_fontsize);

%         nexttile(4)
%         hold on
%         plot(x,M_mtj_li.*qdot_mtj/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
%         title('Ligaments')
%         xlabel('Gait cycle (%)','Fontsize',label_fontsize);
%         ylabel('P (W/kg)','Fontsize',label_fontsize);

        

        if ~has_no_mtj
            
            nexttile(1)
            hold on
            P_mtj_mtp(:,1) = P_mtj_mtp(:,1) + R.Tid(:,imtj).*qdot_mtj/R.body_mass;
            plot(x,R.Tid(:,imtj).*qdot_mtj/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Midtarsal (total)')
%             xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('P (W/kg)','Fontsize',label_fontsize);

            nexttile(4)
            hold on
            P_mtj_mtp(:,2) = M_mtj_li.*qdot_mtj/R.body_mass;
            plot(x,M_mtj_li.*qdot_mtj/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Ligaments')
%             xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('P (W/kg)','Fontsize',label_fontsize);

            nexttile(7)
            hold on
            plot(x,M_mtj_PF.*qdot_mtj/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Plantar fascia')
%             xlabel('Gait cycle (%)','Fontsize',label_fontsize);
            ylabel('P (W/kg)','Fontsize',label_fontsize);

            nexttile(8)
            hold on
            plot(x,M_mtp_PF.*qdot_mtp/R.body_mass,'color',Cs,'linewidth',line_linewidth,'DisplayName',LegName);
            title('Plantar fascia')
%             xlabel('Gait cycle (%)','Fontsize',label_fontsize);
%             ylabel('P (W/kg)','Fontsize',label_fontsize);

            P_mtj_mtp(:,3) = M_mtj_PF.*qdot_mtj/R.body_mass + M_mtp_PF.*qdot_mtp/R.body_mass;
        end

        if ~has_no_mtj && R.S.Foot.mtj_muscles
            musi_mtj = find(R.dM(1,:,7)~=0);
    
            nr_musi_mtj = length(musi_mtj);
            
            musi_mtj = musi_mtj(nr_musi_mtj/2+1:end);
            nr_musi_mtj_1 = length(musi_mtj);
%             nr_musi_mtj = 13;
    

            for i=1:nr_musi_mtj_1
               nexttile(3*i+9-2)
               hold on
               if ~has_no_mtj && R.S.Foot.mtj_muscles
                   T_mus = R.FT(:,musi_mtj(i)) .* R.dM(:,musi_mtj(i),7);
                   if norm(T_mus)>0
                       P_mtj_mtp(:,3+i) = T_mus.*qdot_mtj/R.body_mass;
                       plot(x,T_mus.*qdot_mtj/R.body_mass,'Color',CsV(inr,:),'DisplayName',LegName);
                   end
               elseif ~has_no_mtj
                   T_mus = R.FT(:,musi_mtj(i)) .* R.dM(:,musi_mtj(i),7);
                   if norm(T_mus)>0
    %                    plot(x,T_mus,':','Color',CsV(inr,:),'DisplayName',LegName);
                   end
               end
    
               title(R.colheaders.muscles{musi_mtj(i)},'interpreter','none')
%                 xlabel('Gait cycle (%)','Fontsize',label_fontsize);
                ylabel('P (W/kg)','Fontsize',label_fontsize);
                
            end

        end
        xlabel('Gait cycle (%)','Fontsize',label_fontsize);

        if R.S.Foot.mtp_muscles
%             musi_mtj = find(R.dM(1,:,8)~=0);
%     
%             nr_musi_mtp = length(musi_mtj);
%             
%             musi_mtj = musi_mtj(nr_musi_mtp/2+1:end);
%             nr_musi_mtj_1 = length(musi_mtj);
%             nr_musi_mtj = 13;
    

            for i=1:nr_musi_mtj_1
               nexttile(3*i+9-1)
               hold on
               if R.S.Foot.mtp_muscles
                   T_mus = R.FT(:,musi_mtj(i)) .* R.dM(:,musi_mtj(i),8);
                   if norm(T_mus)>0
                       P_mtj_mtp(:,3+i) = P_mtj_mtp(:,3+i) + T_mus.*qdot_mtp/R.body_mass;
                       plot(x,T_mus.*qdot_mtp/R.body_mass,'Color',CsV(inr,:),'DisplayName',LegName);
                   end
               elseif ~has_no_mtp
                   T_mus = R.FT(:,musi_mtj(i)) .* R.dM(:,musi_mtj(i),7);
                   if norm(T_mus)>0
    %                    plot(x,T_mus,':','Color',CsV(inr,:),'DisplayName',LegName);
                   end
               end
    
               title(R.colheaders.muscles{musi_mtj(i)},'interpreter','none')
%                xlabel('Gait cycle (%)','Fontsize',label_fontsize);
%                ylabel('P (W/kg)','Fontsize',label_fontsize);
                
            end

        end
        xlabel('Gait cycle (%)','Fontsize',label_fontsize);


        for i=1:13
            nexttile(3*i)
               hold on
               plot(x,P_mtj_mtp(:,i),'Color',CsV(inr,:),'DisplayName',LegName);

        end
        for i_pl=1:13*3
            nexttile(i_pl)
            yline(0,'Color',[1,1,1]*0.5)
            ylim([-0.9,1.2])
        end

        if inr==nr && ~strcmp(figNamePrefix,'none')
            set(h41,'PaperPositionMode','auto')
            print(h41,[figNamePrefix '_musc_moment'],'-dpng','-r0')
        end
    end

%%



end

figure(hleg)
nexttile(2)
COT_rel(:) = (COT_all(2:end)-COT_all(1))./COT_all(1)*100;
COT_rel = COT_rel';
brc = bar(COT_rel);
brc.FaceColor = 'flat';
for ibr=1:length(COT_rel)
   brc.CData(ibr,:) = CsV(ibr+1,:);
end
title('Relative COT increase')
ylabel('\delta COT (%)')
tmp=gca;
tmp.XTickLabel = '';
hold on
grid on
plot(tmp.XLim,[0,0],'Color',CsV(1,:),'linewidth',2)
% tmp.YLim(2)=0.5;
set(gca,'YAxisLocation','right')
% hleg.Position(3) = hleg.Position(3)*0.6;

if ~strcmp(figNamePrefix,'none')
    set(hleg,'PaperPositionMode','auto')
    print(hleg,[figNamePrefix '_legend'],'-dpng','-r0')
%     print(hleg,[figNamePrefix '_legend'],'-depsc')
end
    
if exist('table_Q_rmse','var')
    rmse_Q = struct2table(table_Q_rmse);
    R2_Q = struct2table(table_Q_R2);
end
if exist('table_T_rmse','var')
    rmse_T = struct2table(table_T_rmse);
    R2_T = struct2table(table_T_R2);
end
if exist('table_P_rmse','var')
    rmse_P = struct2table(table_P_rmse);
    R2_P = struct2table(table_P_R2);
end

function [pos_work,neg_work,varargout] = getWork(power,time)
    pos_power = power;
    pos_power(power<0) = 0;
    pos_work = trapz(time,pos_power);

    neg_power = power;
    neg_power(power>0) = 0;
    neg_work = trapz(time,neg_power);

    if nargout==3
        net_work = trapz(time,power);
        varargout{1} = net_work;
    end
end
end


