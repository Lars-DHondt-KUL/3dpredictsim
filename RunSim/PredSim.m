function PredSim(S,slv,pp,batchQueue)

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);

S = GetDefaultSettings(S);

%% construct OpenSim model file name
if ~isfield(S,'OsimFileName')
    OsimFileName = [S.subject '_' S.Foot.Model];
    if strcmp(S.Foot.Scaling,'default')
        OsimFileName = [OsimFileName '_sd'];
    elseif strcmp(S.Foot.Scaling,'custom')
        OsimFileName = [OsimFileName '_sc'];
    elseif strcmp(S.Foot.Scaling,'personalised')
        OsimFileName = [OsimFileName '_sp'];
    end
    ExternalFunc = OsimFileName;
    if S.Foot.FDB
        OsimFileName = [OsimFileName '_FDB'];
    end
    if S.tib_ant_Rajagopal2015
        OsimFileName = [OsimFileName '_TAR'];
    end
    if S.useMtpPinPoly
        OsimFileName = [OsimFileName '_old'];
    end
    if isfield(S,'MTparams')
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
if S.Foot.contactSphereOffsetY == 1
    ExternalFunc = [ExternalFunc '_oy'];
elseif S.Foot.contactSphereOffsetY == 2
    ExternalFunc = [ExternalFunc '_oy2'];
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


%% build standardised names
[savename, casfuncfol] = getSavename(S);
S.CasadiFunc_Folders = casfuncfol;
S.savename = savename;

%% Prepare the simulation to run as part of a batch
% Casadi functions are made when
if batchQueue
    % Store the settings
    fieldname = S.savename;
    fieldname = fieldname((fieldname(:)~='_'));
    
    if (exist([pathRepo '/Results/batchQ.mat'],'file')==2) 
        load([pathRepo '/Results/batchQ.mat'],'batchQ');
    else
        batchQ.(fieldname) = struct('S',[]);
    end
    batchQ.(fieldname).S = S;
    % Specify function to use
    batchQ.(fieldname).PredSim = 'f_PredSim_Gait92_FootModel';
    batchQ.(fieldname).LoadSim = 'f_LoadSim_Gait92_FootModel';

    save([pathRepo '/Results/batchQ.mat'],'batchQ');
else


    % make folder to store results if it doesn't exist
    pathResults = fullfile([pathRepo '/Results'],S.ResultsFolder);
    if ~isfolder(pathResults)
        mkdir(pathResults);
    end

    % Create the casadifunctions if they do not exist yet
    if ~isfolder([pathRepo '\CasADiFunctions\' S.CasadiFunc_Folders])
        disp('Creating casadifunctions...');
        CreateCasadiFunctions(pathRepo,S);
        disp('...casadifunctions created');
    end
    % run the optimization
    if slv
        f_PredSim_Gait92_FootModel(S);
    end
    % post-proces simulation results
    if pp
        f_LoadSim_Gait92_FootModel(S.ResultsFolder,S.savename);
    end

end





















