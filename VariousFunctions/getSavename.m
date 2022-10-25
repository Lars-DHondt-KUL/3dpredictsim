function [savename, casfuncfol,varargout] = getSavename(S)
% build savename and casadifunction foldername
savenameparts = {};
casfuncfolparts = {};
not = {};

% general settings
if isfield(S,'ExternalFunc')
    savenameparts{end+1} = S.ExternalFunc;
    casfuncfolparts{end+1} = S.ExternalFunc;
else
    savenameparts{end+1} = S.subject;
    casfuncfolparts{end+1} = S.subject;
    if isfield(S,'Foot')
        if isfield(S.Foot,'Model')
            savenameparts{end+1} = S.Foot.Model;
        end
        if isfield(S,'fixed_knee') && S.fixed_knee
            savenameparts{end+1} = 'FK';
        end
        if isfield(S.Foot,'Scaling')
            if strcmp(S.Foot.Scaling,'default')
                savenameparts{end+1} = 'sd';
            elseif strcmp(S.Foot.Scaling,'custom')
                savenameparts{end+1} = 'sc';
            elseif strcmp(S.Foot.Scaling,'personalised')
                savenameparts{end+1} = 'sp';
            end
        end
        if isfield(S.Foot,'contactStiffnessFactor')
            if S.Foot.contactStiffnessFactor == 10
                savenameparts{end+1} = 'cspx10';
            elseif S.Foot.contactStiffnessFactor == 5
                savenameparts{end+1} = 'cspx5';
            elseif S.Foot.contactStiffnessFactor == 1
                not{end+1} = 'not_cspx';
            end
        end
        if isfield(S.Foot,'contactGeometryVersion')
            if S.Foot.contactGeometryVersion>=0
                savenameparts{end+1} = ['cg' num2str(S.Foot.contactGeometryVersion)];
            else
                not{end+1} = 'not_cg';
            end
        end
        if isfield(S.Foot,'contactSphereOffsetY')
            if S.Foot.contactSphereOffsetY == 1
                savenameparts{end+1} = 'oy_';
            elseif S.Foot.contactSphereOffsetY >= 2
                savenameparts{end+1} = ['oy' num2str(S.Foot.contactSphereOffsetY)];
            end
        end
        if isfield(S.Foot,'contactSphereOffset1X')
            if S.Foot.contactSphereOffset1X ~= 0
                savenameparts{end+1} = ['o1x' num2str(S.Foot.contactSphereOffset1X*1e3)];
            else
                not{end+1} = 'not_o1x';
            end
        end
    end
end

if isfield(S,'TrackSim') && S.TrackSim 
    savenameparts{end+1} = 'Track';
    if isfield(S,'Track') && S.Track.Q_ankle
        savenameparts{end} = [savenameparts{end} 'AnkleQ'];
    end
    if isfield(S,'Track') && S.Track.Q_subt
        savenameparts{end} = [savenameparts{end} 'SubtQ'];
    end
end
if isfield(S,'AchillesTendonScaleFactor') && S.AchillesTendonScaleFactor~=1
    savenameparts{end+1} = ['ATx' num2str(S.AchillesTendonScaleFactor*100)];
    casfuncfolparts{end+1} = ['ATx' num2str(S.AchillesTendonScaleFactor*100)];
elseif isfield(S,'AchillesTendonScaleFactor') && S.AchillesTendonScaleFactor==1
     not{end+1} = 'not_ATx';
end
if isfield(S,'TricepsFMoScale') && S.TricepsFMoScale~=1
    savenameparts{end+1} = ['TFMox' num2str(S.TricepsFMoScale*100)];
    casfuncfolparts{end+1} = ['TFMox' num2str(S.TricepsFMoScale*100)];
elseif isfield(S,'TricepsFMoScale') && S.TricepsFMoScale==1
     not{end+1} = 'not_TFMox';
end
if isfield(S,'SoleusTendonShorter') && S.SoleusTendonShorter
    savenameparts{end+1} = ['ST' num2str(S.SoleusTendonShorter*1000)];
    casfuncfolparts{end+1} = ['ST' num2str(S.SoleusTendonShorter*1000)];
elseif isfield(S,'SoleusTendonShorter')
    not{end+1} = 'not_ST';
end
if isfield(S,'GastrocTendonShorter') && S.GastrocTendonShorter
    savenameparts{end+1} = ['GT' num2str(S.GastrocTendonShorter*1000)];
    casfuncfolparts{end+1} = ['GT' num2str(S.GastrocTendonShorter*1000)];
elseif isfield(S,'GastrocTendonShorter')
    not{end+1} = 'not_GT';
end
if isfield(S,'passiveFiberForceShift') && S.passiveFiberForceShift
    savenameparts{end+1} = ['Fpsl' num2str(-S.passiveFiberForceShift*100)];
    casfuncfolparts{end+1} = ['Fpsl' num2str(-S.passiveFiberForceShift*100)];
% elseif isfield(S,'passiveFiberForceShift')
%     not{end+1} = 'not_Fpsl';
end

if isfield(S,'tib_ant_Rajagopal2015') && S.tib_ant_Rajagopal2015
    savenameparts{end+1} = 'TAR';
    casfuncfolparts{end+1} = 'TAR';
elseif isfield(S,'tib_ant_Rajagopal2015') && ~S.tib_ant_Rajagopal2015
    not{end+1} = 'not_TAR';
end

if isfield(S,'useMtpPinPoly') && S.useMtpPinPoly
    savenameparts{end+1} = 'oldPoly';
    casfuncfolparts{end+1} = 'oldPoly';
elseif isfield(S,'useMtpPinPoly') && ~S.useMtpPinPoly
    not{end+1} = 'not_oldPoly';
end

if isfield(S,'MTparams') && ~isempty(S.MTparams)
    savenameparts{end+1} = S.MTparams;
    casfuncfolparts{end+1} = S.MTparams;
end

if isfield(S,'Foot')
    % mtp related settings
    savenameparts{end+1} = 'MTP';
    casfuncfolparts{end+1} = 'MTP';
    if isfield(S.Foot,'mtp_muscles') && S.Foot.mtp_muscles
        savenameparts{end} = [savenameparts{end} 'm'];
        casfuncfolparts{end} = [casfuncfolparts{end} 'm'];
    elseif isfield(S,'Foot.mtp_actuator') && S.Foot.mtp_actuator
        savenameparts{end} = [savenameparts{end} 'a'];
        casfuncfolparts{end} = [casfuncfolparts{end} 'a'];
    elseif isfield(S.Foot,'mtp_muscles') || isfield(S,'Foot.mtp_actuator')
        savenameparts{end} = [savenameparts{end} 'p'];
        casfuncfolparts{end} = [casfuncfolparts{end} 'p'];
    end
    
    if isfield(S.Foot,'kMTP') && ~isempty(S.Foot.kMTP)
        savenameparts{end+1} = ['k' num2str(S.Foot.kMTP)];
        casfuncfolparts{end+1} = ['k' num2str(S.Foot.kMTP)];
    end
    if isfield(S.Foot,'dMTP') && ~isempty(S.Foot.dMTP)
        savenameparts{end+1} = ['d0' num2str(S.Foot.dMTP*10)];
        casfuncfolparts{end+1} = ['d0' num2str(S.Foot.dMTP*10)];
    end
    if isfield(S.Foot,'mtp_tau_pass') && ~isempty(S.Foot.mtp_tau_pass)
        if S.Foot.mtp_tau_pass
            savenameparts{end+1} = ['tau'];
            casfuncfolparts{end+1} = ['tau'];
        else
            not{end+1} = 'not_tau';
        end
    end
    
    
    % mtj related settings
    if ~isfield(S.Foot,'Model') || contains(S.Foot.Model,'mtj')
        if isfield(S.Foot,'mtj_muscles') && S.Foot.mtj_muscles
            savenameparts{end+1} = ['MTJm'];
            casfuncfolparts{end+1} = ['MTJm'];
        elseif isfield(S.Foot,'mtj_muscles')
            savenameparts{end+1} = ['MTJp'];
            casfuncfolparts{end+1} = ['MTJp'];
        end
        if isfield(S.Foot,'MT_li_nonl') && ~isempty(S.Foot.MT_li_nonl) && S.Foot.MT_li_nonl
            if isfield(S.Foot,'mtj_stiffness') && ~isempty(S.Foot.mtj_stiffness)
                if strcmp(S.Foot.mtj_stiffness,'signed_lin')
                    savenameparts{end+1} = ['nl_k' num2str(S.Foot.kMT_li) '_' num2str(S.Foot.kMT_li2)];
                    casfuncfolparts{end+1} = ['nl_k' num2str(S.Foot.kMT_li) '_' num2str(S.Foot.kMT_li2)];
                else
                    savenameparts{end+1} = ['nl_' S.Foot.mtj_stiffness];
                    casfuncfolparts{end+1} = ['nl_' S.Foot.mtj_stiffness];

                    if isfield(S.Foot,'mtj_sf') && S.Foot.mtj_sf~=1
                        savenameparts{end} = [savenameparts{end} '_x' num2str(S.Foot.mtj_sf)];
                        casfuncfolparts{end} = [casfuncfolparts{end} '_x' num2str(S.Foot.mtj_sf)];
                    end
                end
            else
                savenameparts{end+1} = ['nl'];
                casfuncfolparts{end+1} = ['nl'];
            end
        elseif isfield(S.Foot,'kMT_li') && ~isempty(S.Foot.kMT_li)
            savenameparts{end+1} = ['k' num2str(S.Foot.kMT_li)];
            casfuncfolparts{end+1} = ['k' num2str(S.Foot.kMT_li)];
        end
        if isfield(S.Foot,'MT_li_nonl') && ~isempty(S.Foot.MT_li_nonl) && ~S.Foot.MT_li_nonl
            not{end+1} = 'not_MTJp_nl';
            not{end+1} = 'not_MTJm_nl';
        end
        if isfield(S.Foot,'dMT') && ~isempty(S.Foot.dMT) && S.Foot.dMT~=0
            savenameparts{end+1} = ['d0' num2str(S.Foot.dMT*10)];
            casfuncfolparts{end+1} = ['d0' num2str(S.Foot.dMT*10)];
        end
    
        if isfield(S.Foot,'PF_stiffness') && ~isempty(S.Foot.PF_stiffness)
            savenameparts{end+1} = ['PF_' S.Foot.PF_stiffness];
            casfuncfolparts{end+1} = ['PF_' S.Foot.PF_stiffness];
        end
        if isfield(S.Foot,'PF_sf') && S.Foot.PF_sf~=1
            savenameparts{end} = [savenameparts{end} '_x' num2str(S.Foot.PF_sf)];
        end
        if isfield(S.Foot,'PF_sf_isvar') && S.Foot.PF_sf_isvar > 0
            savenameparts{end} = [savenameparts{end} '_xv' num2str(S.Foot.PF_sf_isvar)];
        end
        if isfield(S.Foot,'PF_slack_length') && ~isempty(S.Foot.PF_slack_length)
            savenameparts{end+1} = ['ls' num2str(S.Foot.PF_slack_length*1000)];
            casfuncfolparts{end+1} = ['ls' num2str(S.Foot.PF_slack_length*1000)];
        end
    
%         if isfield(S.Foot,'FDB') 
%             if S.Foot.FDB == 1
%                 savenameparts{end+1} = 'FDB';
%                 casfuncfolparts{end+1} = 'FDB';
%             elseif S.Foot.FDB == 2
%                 savenameparts{end+1} = 'FDB2';
%                 casfuncfolparts{end+1} = 'FDB2';
%             end
%             if S.Foot.FDB
%                 if isfield(S.Foot,'FDB_lTs')
%                     savenameparts{end+1} = ['lTs' num2str(S.Foot.FDB_lTs*1000)];
%                     casfuncfolparts{end+1} = ['lTs' num2str(S.Foot.FDB_lTs*1000)];
%                 end
%                 if isfield(S.Foot,'FDB_shift') && S.Foot.FDB_shift
%                     savenameparts{end+1} = ['Fpsl' num2str(-S.Foot.FDB_shift*100)];
%                     casfuncfolparts{end+1} = ['Fpsl' num2str(-S.Foot.FDB_shift*100)];
%                 end
%                 if isfield(S.Foot,'FDB_sf_FMo') && S.Foot.FDB_sf_FMo~=1
%                     savenameparts{end+1} = ['FMox' num2str(S.Foot.FDB_sf_FMo*100)];
%                     casfuncfolparts{end+1} = ['FMox' num2str(S.Foot.FDB_sf_FMo*100)];
%                 end
%             end
%         end
        

        if isfield(S.Foot,'PIM') && S.Foot.PIM
            savenameparts{end+1} = 'PIM';
            casfuncfolparts{end+1} = 'PIM';
            if S.Foot.PIM == 2
                savenameparts{end} = [savenameparts{end} '2'];
            end
            if isfield(S,'W') && isfield(S.W,'PIM') && ~isempty(S.W.PIM)
                savenameparts{end+1} = ['w' num2str(S.W.PIM,2)];
            end
            if isfield(S,'W') && isfield(S.W,'P_PIM') && ~isempty(S.W.P_PIM)
                savenameparts{end+1} = ['w' num2str(S.W.P_PIM,2)];
            end
        end

    elseif isfield(S.Foot,'mtp_M_PF') && ~isempty(S.Foot.mtp_M_PF) && S.Foot.mtp_M_PF
        if isfield(S.Foot,'PF_stiffness') && ~isempty(S.Foot.PF_stiffness)
            savenameparts{end+1} = ['PF_' S.Foot.PF_stiffness];
            casfuncfolparts{end+1} = ['PF_' S.Foot.PF_stiffness];
        end
        if isfield(S.Foot,'PF_sf') && S.Foot.PF_sf~=1
            savenameparts{end} = [savenameparts{end} '_x' num2str(S.Foot.PF_sf)];
        end
        if isfield(S.Foot,'PF_slack_length') && ~isempty(S.Foot.PF_slack_length)
            savenameparts{end+1} = ['ls' num2str(S.Foot.PF_slack_length*1000)];
            casfuncfolparts{end+1} = ['ls' num2str(S.Foot.PF_slack_length*1000)];
        end
        
    end
      
    if isfield(S.Foot,'FDB') 
        if S.Foot.FDB == 1
            savenameparts{end+1} = 'FDB';
            casfuncfolparts{end+1} = 'FDB';
        elseif S.Foot.FDB == 2
            savenameparts{end+1} = 'FDB2';
            casfuncfolparts{end+1} = 'FDB2';
        elseif S.Foot.FDB == 0
            not{end+1} = 'not_FDB';
        end
        if S.Foot.FDB
            if isfield(S.Foot,'FDB_lTs')
                savenameparts{end+1} = ['lTs' num2str(S.Foot.FDB_lTs*1000)];
                casfuncfolparts{end+1} = ['lTs' num2str(S.Foot.FDB_lTs*1000)];
            end
            if isfield(S.Foot,'FDB_shift') && S.Foot.FDB_shift
                savenameparts{end+1} = ['Fpsl' num2str(-S.Foot.FDB_shift*100)];
                casfuncfolparts{end+1} = ['Fpsl' num2str(-S.Foot.FDB_shift*100)];
            end
            if isfield(S.Foot,'FDB_sf_FMo') && S.Foot.FDB_sf_FMo~=1
                savenameparts{end+1} = ['FMox' num2str(S.Foot.FDB_sf_FMo*100)];
                casfuncfolparts{end+1} = ['FMox' num2str(S.Foot.FDB_sf_FMo*100)];
            end
        end
    end

end

% velocity
if isfield(S,'v_tgt')
    if S.v_tgt ~= 1.33
        if S.v_tgt<1
            savenameparts{end+1} = ['vel0' num2str(S.v_tgt*10)];
        else
            savenameparts{end+1} = ['vel' num2str(S.v_tgt*10)];
        end
    else
        not{end+1} = 'not_vel';
    end
end

% initial guess
if isfield(S,'IGsel') && ~isempty(S.IGsel)
    if S.IGsel == 1
        savenameparts{end+1} = ['ig1'];
    else
        savenameparts{end+1} = ['ig2' num2str(S.IGmodeID )];
    end
end



% % cost function weight factors
% if isfield(S,'W')
%     if isfield(S.W,'Ak')
%         savenameparts{end+1} = ['wAk' num2str(S.W.Ak,2)];
%     else
%         not{end+1} = 'not_wAk';
%     end
%     if isfield(S.W,'A')
%         savenameparts{end+1} = ['wa' num2str(S.W.A,2)];
%     else
%         not{end+1} = 'not_wa';
%     end
%     if isfield(S.W,'passMom')
%         if isfield(S.W,'noDamping') && S.W.noDamping
%             savenameparts{end+1} = ['wpMnD' num2str(S.W.passMom,2)];
%         else
%             savenameparts{end+1} = ['wpM' num2str(S.W.passMom,2)];
%         end
%     else
%         not{end+1} = 'not_wpM';
%     end
% end

if isfield(S,'suffixCasName')
    casfuncfolparts{end+1} = S.suffixCasName;
end
if isfield(S,'suffixName')
    savenameparts{end+1} = S.suffixName;
end
savename = savenameparts{1};
for i=2:numel(savenameparts)
    savename = [savename '_' savenameparts{i}];
end
criteria = {};
for i=1:numel(savenameparts)
    criteria{end+1} = savenameparts{i};
end
casfuncfol = casfuncfolparts{1};
for i=2:numel(casfuncfolparts)
    casfuncfol = [casfuncfol '_' casfuncfolparts{i}];
end

for i=1:numel(not)
    criteria{end+1} = not{i};
end


if nargout == 3
    varargout{1} = criteria;
else
    disp(savename);
    disp(casfuncfol);
end

end