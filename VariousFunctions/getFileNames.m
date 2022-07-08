function [S] = getFileNames(S)



%% construct OpenSim model file name
if ~isfield(S,'OsimFileName')
    OsimFileName = [S.subject '_' S.Foot.Model];
    if S.fixed_knee
        OsimFileName = [OsimFileName '_FK'];
    end
    if strcmp(S.Foot.Scaling,'default')
        OsimFileName = [OsimFileName '_sd'];
    elseif strcmp(S.Foot.Scaling,'custom')
        OsimFileName = [OsimFileName '_sc'];
    elseif strcmp(S.Foot.Scaling,'personalised')
        OsimFileName = [OsimFileName '_sp'];
    end
    ExternalFunc = OsimFileName;
    if S.Foot.FDB == 1
        OsimFileName = [OsimFileName '_FDB'];
    elseif S.Foot.FDB == 2
        OsimFileName = [OsimFileName '_FDB2'];
    end
    if S.tib_ant_Rajagopal2015
        OsimFileName = [OsimFileName '_TAR'];
    end
    if S.useMtpPinPoly
        OsimFileName = [OsimFileName '_old'];
    end
    if isfield(S,'MTparams') && ~isempty(S.MTparams)
        OsimFileName = [OsimFileName '_' S.MTparams];
    end
    S.OsimFileName = OsimFileName;
else
    ExternalFunc = S.OsimFileName;
end

%% construct external function file name
if S.Foot.contactStiffnessFactor == 10
    ExternalFunc = [ExternalFunc '_cspx10'];
elseif S.Foot.contactStiffnessFactor == 5
    ExternalFunc = [ExternalFunc '_cspx5'];
end
if S.Foot.contactGeometryVersion > 1
    ExternalFunc = [ExternalFunc '_cg' num2str(S.Foot.contactGeometryVersion)];
end
if S.Foot.contactSphereOffsetY == 1
    ExternalFunc = [ExternalFunc '_oy'];
elseif S.Foot.contactSphereOffsetY >= 2
    ExternalFunc = [ExternalFunc '_oy' num2str(S.Foot.contactSphereOffsetY)];
end
if S.Foot.contactSphereOffset45Z
    ExternalFunc = [ExternalFunc '_o45z' num2str(S.Foot.contactSphereOffset45Z*1e3)];
end
if S.Foot.contactSphereOffset1X
    ExternalFunc = [ExternalFunc '_o1x' num2str(S.Foot.contactSphereOffset1X*1e3)];
end
if S.useMtpPinExtF
    ExternalFunc = [ExternalFunc '_old'];
end

S.ExternalFunc = ExternalFunc;