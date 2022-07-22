%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script runs the batch of simulations created in another script. See
% main.m for more.
%
% Author: Lars D'Hondt (May 2021)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
close all
clc

%% Paths
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
addpath([pathRepo '/OCP']);
addpath([pathRepo '/VariousFunctions']);
addpath([pathRepo '/CasADiFunctions']);
addpath([pathRepo '/Musclemodel']);
addpath([pathRepo '/Polynomials']);
addpath([pathRepo '/FootModel']);

% StartPath = pwd;
StartPath = pathRepo;
cd(pathRepo)
pathExternalFunctions = fullfile(pathRepo,'ExternalFunctions');
ResultsRepo = 'C:\Users\u0150099\OneDrive - KU Leuven\3dpredictsim_results';

%% Load queue
load(fullfile(pathRepo,'Results','batchQ.mat'),'batchQ');

fields = fieldnames(batchQ);
% remove entries that already have a postprocessed result
for i=1:numel(fields)
pathResult_pp = fullfile(ResultsRepo,batchQ.(fields{i}).S.ResultsFolder,...
    [batchQ.(fields{i}).S.savename '_pp.mat']);
    if exist(pathResult_pp,'file')
        batchQ = rmfield(batchQ,(fields{i}));
    end
end




%%

name = getenv('COMPUTERNAME');
if strcmp(name,'GBW-D-W2711')       % desktop
    myCluster = parcluster('LocalProfile1_Lars_8x2');
    imax = 200; % max nr of jobs to start

elseif strcmp(name,'MSI')           % laptop 
    myCluster = parcluster('LocalProfile_2x2');
    imax = 2; % max nr of jobs to start

elseif strcmp(name,'GBW-L-W2122')   % laptop
    myCluster = parcluster('local');
    imax = 40; % max nr of jobs to start
end

%%
fields = fieldnames(batchQ);
imax = min(imax,numel(fields));

for i=1:imax
    % check if this job has been started
    if ~( isfield(batchQ.(fields{i}),'job_started') && ~isempty(batchQ.(fields{i}).job_started)...
            && batchQ.(fields{i}).job_started )
        % make folder to store results if it doesn't exist
        pathResults = fullfile([pathRepo '/Results'],batchQ.(fields{i}).S.ResultsFolder);
        if ~isfolder(pathResults)
            mkdir(pathResults);
        end

        % Create the casadifunctions if they do not exist yet
        if ~isfolder([pathRepo '\CasADiFunctions\' batchQ.(fields{i}).S.CasadiFunc_Folders])
            disp('Creating casadifunctions...');
            CreateCasadiFunctions(pathRepo,batchQ.(fields{i}).S);
            disp('...casadifunctions created');
        end

        PathPolynomials = fullfile(pathRepo,'Polynomials');
        pathResults = fullfile([pathRepo '/Results'],batchQ.(fields{i}).S.ResultsFolder);
        CasadiFiles = fullfile(pathRepo,'CasADiFunctions',batchQ.(fields{i}).S.CasadiFunc_Folders);
        batchQ.(fields{i}).S.NThreads  = 2;

%         job(i) = batch(myCluster,batchQ.(fields{i}).PredSim,0,{batchQ.(fields{i}).S},...
%             'CurrentFolder',StartPath,'AdditionalPaths',...
%             {CasadiFiles,PathPolynomials,pathExternalFunctions});
        batch(myCluster,batchQ.(fields{i}).PredSim,0,{batchQ.(fields{i}).S},...
            'CurrentFolder',StartPath,'AdditionalPaths',...
            {CasadiFiles,PathPolynomials,pathExternalFunctions});

        % mark this job as started
        batchQ.(fields{i}).job_started = 1;
    end  
end

save([pathRepo '/Results/batchQ.mat'],'batchQ');



