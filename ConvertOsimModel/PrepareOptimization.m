% This script extracts information from an OpenSim model, and stores it in
% a format that is accessible for formulating the simulation.
%
% Author: Lars D'Hondt
% Date: 7/Dec/2021
%

clear
close all
clc

%% Inputs
% OpenSim model information
Subject = 'Fal_s1'; % (= subject1 from Falisse et al.) fixed for now
FootModel = 'mtjc4'; % mtp or mtj
FixedKnee = 0; % 1 for fixed knee axis, 0 for moving
FootScaling = 'custom'; % default, custom
FDB = 2;
tib_ant_Rajagopal2015 = 0;
MTcustom = 5; % 5 is proper geometry for mtj models
% Boolean to select if we have to run the muscle analysis
Bool_RunMA = 1; 


%% Path information
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath(fullfile(pathRepo,'\VariousFunctions'));
addpath(fullfile(pathRepo,'\Polynomials'));


%%
% OpenSim file name from settings
OsimFileName = [Subject '_' FootModel];
if FixedKnee
    OsimFileName = [OsimFileName '_FK'];
end
if strcmp(FootScaling,'default')
    OsimFileName = [OsimFileName '_sd'];
elseif strcmp(FootScaling,'custom')
    OsimFileName = [OsimFileName '_sc'];
elseif strcmp(FootScaling,'personalised')
    OsimFileName = [OsimFileName '_sp'];
end
if FDB == 1
    OsimFileName = [OsimFileName '_FDB'];
elseif FDB == 2
    OsimFileName = [OsimFileName '_FDB2'];
end
if tib_ant_Rajagopal2015
    OsimFileName = [OsimFileName '_TAR'];
end
if MTcustom == 1
    OsimFileName = [OsimFileName '_MTc'];
elseif MTcustom >= 2
    OsimFileName = [OsimFileName '_MTc' num2str(MTcustom)];
end
% Manually overwrite OpenSim file name if wanted
% OsimFileName = 'CP3_T0_scaled_MRI_v7_scaledMT_right';
% OsimFileName = 'Hamner_modified';



% Path to save the polynomials
PolyFolder = OsimFileName;
pathPoly = fullfile(pathRepo,'Polynomials',PolyFolder);
if ~isfolder(pathPoly)
    mkdir(pathPoly);
end
% Path to save the muscle parameters
pathMusc = fullfile(pathRepo,'MuscleModel',PolyFolder);
if ~isfolder(pathMusc)
    mkdir(pathMusc);
end

OsimFileName = [OsimFileName '_cspx10_cg9_o1x10'];

% Modelpath
ModelPath = fullfile(pathRepo,'OpenSimModel/subject1',[OsimFileName '.osim']);
% if ~isfile(ModelPath)
%     OsimFileName = [OsimFileName '_cspx10_oy'];
%     ModelPath = fullfile(pathRepo,'OpenSimModel/subject1',[OsimFileName '.osim']);
%     if ~isfile(ModelPath)
%         OsimFileName = [OsimFileName '2'];
%         ModelPath = fullfile(pathRepo,'OpenSimModel/subject1',[OsimFileName '.osim']);
%     end
% end
disp(OsimFileName)



% muscles are hard coded
if FDB
    muscleNames = {'glut_med1_r','glut_med2_r','glut_med3_r',...
        'glut_min1_r','glut_min2_r','glut_min3_r','semimem_r',...
        'semiten_r','bifemlh_r','bifemsh_r','sar_r','add_long_r',...
        'add_brev_r','add_mag1_r','add_mag2_r','add_mag3_r','tfl_r',...
        'pect_r','grac_r','glut_max1_r','glut_max2_r','glut_max3_r',......
        'iliacus_r','psoas_r','quad_fem_r','gem_r','peri_r',...
        'rect_fem_r','vas_med_r','vas_int_r','vas_lat_r','med_gas_r',...
        'lat_gas_r','soleus_r','tib_post_r','flex_dig_r','flex_hal_r',...
        'tib_ant_r','per_brev_r','per_long_r','per_tert_r','ext_dig_r',...
        'ext_hal_r','FDB_r','ercspn_r','intobl_r','extobl_r','ercspn_l',...
        'intobl_l','extobl_l'};
else
    muscleNames = {'glut_med1_r','glut_med2_r','glut_med3_r',...
        'glut_min1_r','glut_min2_r','glut_min3_r','semimem_r',...
        'semiten_r','bifemlh_r','bifemsh_r','sar_r','add_long_r',...
        'add_brev_r','add_mag1_r','add_mag2_r','add_mag3_r','tfl_r',...
        'pect_r','grac_r','glut_max1_r','glut_max2_r','glut_max3_r',......
        'iliacus_r','psoas_r','quad_fem_r','gem_r','peri_r',...
        'rect_fem_r','vas_med_r','vas_int_r','vas_lat_r','med_gas_r',...
        'lat_gas_r','soleus_r','tib_post_r','flex_dig_r','flex_hal_r',...
        'tib_ant_r','per_brev_r','per_long_r','per_tert_r','ext_dig_r',...
        'ext_hal_r','ercspn_r','intobl_r','extobl_r','ercspn_l',...
        'intobl_l','extobl_l'};
end

%% Fit polynomial functions to length and moment arms of muscles and ligaments
ModelName = 'Gait92';
if contains(OsimFileName,'_mtj')
    ModelName = [ModelName '_mtj'];
end

% run muscle analysis and fit polynomials
FitPolynomials(pathRepo,ModelName,ModelPath,PolyFolder,Bool_RunMA,muscleNames)

% fit polynomials to plantar fascia geometry
if contains(OsimFileName,'_mtj')
    getPlantarFasciaGeometry(pathRepo,ModelPath,PolyFolder)
else
    try
        getPlantarFasciaGeometry(pathRepo,ModelPath,PolyFolder)
    catch
        warning('Unable to extract plantar fascia information from osim file.')
    end
end

%% Get muscle parameters

MTparameters = getMTparameters(ModelPath,muscleNames);
save(fullfile(pathMusc,'MTparameters.mat'),'MTparameters');


















