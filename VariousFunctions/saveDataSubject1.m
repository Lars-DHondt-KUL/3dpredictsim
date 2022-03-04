% Save the experimental data from subject 1 by Antoine Falisse in the same
% format as the data from subject 1 by K. Poggensee
clear
clc

[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
load([pathRepo '\ExperimentalData\ExperimentalData.mat']);

%%
Dat.Normal.gc.colheaders = ExperimentalData.Q.subject1.Qs.colheaders;

Dat.Normal.gc.Qall_mean = ExperimentalData.Q.subject1.Qs.mean.*(pi/180);
Dat.Normal.gc.Qall_std = ExperimentalData.Q.subject1.Qs.std.*(pi/180);

Dat.Normal.gc.Qdotall_mean = ExperimentalData.Q.subject1.Qdots.mean.*(pi/180);
Dat.Normal.gc.Qdotall_std = ExperimentalData.Q.subject1.Qdots.std.*(pi/180);

Dat.Normal.gc.Tall_bio_mean = ExperimentalData.Torques.subject1.mean;
Dat.Normal.gc.Tall_bio_std = ExperimentalData.Torques.subject1.std;
Dat.Normal.gc.Tall_mean = ExperimentalData.Torques.subject1.mean;
Dat.Normal.gc.Tall_std = ExperimentalData.Torques.subject1.std;

Dat.Normal.EMGheaders = ExperimentalData.EMG.subject1.colheaders;
Dat.Normal.gc.lowEMG_mean = ExperimentalData.EMG.subject1.mean;
Dat.Normal.gc.lowEMG_std = ExperimentalData.EMG.subject1.std;

Dat.Normal.gc.GRF.Fmean = ExperimentalData.GRFs.subject1.mean;
Dat.Normal.gc.GRF.Fstd = ExperimentalData.GRFs.subject1.std;

%%
P_mech = ExperimentalData.Q.subject1.Qdots.all.*(pi/180).*ExperimentalData.Torques.subject1.all;

P_mech_mean = mean(P_mech,3);
P_mech_std = std(P_mech,0,3);



%%
% save([pathRepo '\Data\Fal_s1.mat'],'Dat');


Data.IK_original.colheaders = ExperimentalData.Q.subject1.Qs.colheaders;
Data.IK_original.Qall_mean = ExperimentalData.Q.subject1.Qs.mean;
Data.IK_original.Qall_std = ExperimentalData.Q.subject1.Qs.std;
Data.IK_original.Qdotall_mean = ExperimentalData.Q.subject1.Qdots.mean;
Data.IK_original.Qdotall_std = ExperimentalData.Q.subject1.Qdots.std;

load('C:\Users\u0150099\Documents\master_thesis\ReferenceData\ModelScaling\reference_data\Analysis\Qref_subject1_withMTJ_locked_scaled_default.mat');
Data.IK_mtp_default.colheaders = Qref.subject1.colheaders;
Data.IK_mtp_default.Qall_mean = Qref.subject1.Qs.mean;
Data.IK_mtp_default.Qall_std = Qref.subject1.Qs.std;
Data.IK_mtp_default.Qdotall_mean = Qref.subject1.Qdots.mean;
Data.IK_mtp_default.Qdotall_std = Qref.subject1.Qdots.std;

load('C:\Users\u0150099\Documents\master_thesis\ReferenceData\ModelScaling\reference_data\Analysis\Qref_subject1_withMTJ_locked_scaled_custom.mat');
Data.IK_mtp_custom.colheaders = Qref.subject1.colheaders;
Data.IK_mtp_custom.Qall_mean = Qref.subject1.Qs.mean;
Data.IK_mtp_custom.Qall_std = Qref.subject1.Qs.std;
Data.IK_mtp_custom.Qdotall_mean = Qref.subject1.Qdots.mean;
Data.IK_mtp_custom.Qdotall_std = Qref.subject1.Qdots.std;


load('C:\Users\u0150099\Documents\master_thesis\ReferenceData\ModelScaling\reference_data\Analysis\Qref_subject1_withMTJ_scaled_default.mat');
Data.IK_mtj_default.colheaders = Qref.subject1.colheaders;
Data.IK_mtj_default.Qall_mean = Qref.subject1.Qs.mean;
Data.IK_mtj_default.Qall_std = Qref.subject1.Qs.std;
Data.IK_mtj_default.Qdotall_mean = Qref.subject1.Qdots.mean;
Data.IK_mtj_default.Qdotall_std = Qref.subject1.Qdots.std;

load('C:\Users\u0150099\Documents\master_thesis\ReferenceData\ModelScaling\reference_data\Analysis\Qref_subject1_withMTJ_scaled_custom.mat');
Data.IK_mtj_custom.colheaders = Qref.subject1.colheaders;
Data.IK_mtj_custom.Qall_mean = Qref.subject1.Qs.mean;
Data.IK_mtj_custom.Qall_std = Qref.subject1.Qs.std;
Data.IK_mtj_custom.Qdotall_mean = Qref.subject1.Qdots.mean;
Data.IK_mtj_custom.Qdotall_std = Qref.subject1.Qdots.std;

load('C:\Users\u0150099\Documents\master_thesis\ReferenceData\ModelScaling\reference_data\Analysis\Qref_Fal_s1_mtjc_sc_FDB_MTc2.mat');
Data.IK_mtjc_custom.colheaders = Qref.subject1.colheaders;
Data.IK_mtjc_custom.Qall_mean = Qref.subject1.Qs.mean;
Data.IK_mtjc_custom.Qall_std = Qref.subject1.Qs.std;
Data.IK_mtjc_custom.Qdotall_mean = Qref.subject1.Qdots.mean;
Data.IK_mtjc_custom.Qdotall_std = Qref.subject1.Qdots.std;


Data.ID_original.colheaders = ExperimentalData.Q.subject1.Qs.colheaders;
Data.ID_original.Tall_mean = ExperimentalData.Torques.subject1.mean;
Data.ID_original.Tall_std = ExperimentalData.Torques.subject1.std;

Data.EMGheaders = ExperimentalData.EMG.subject1.colheaders;
Data.lowEMG_mean = ExperimentalData.EMG.subject1.mean;
Data.lowEMG_std = ExperimentalData.EMG.subject1.std;

Data.GRF.Fmean = ExperimentalData.GRFs.subject1.mean;
Data.GRF.Fstd = ExperimentalData.GRFs.subject1.std;

save([pathRepo '\Data\Fal_s1.mat'],'Data');
