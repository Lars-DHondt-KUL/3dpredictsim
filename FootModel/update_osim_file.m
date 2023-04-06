
approx_Gefen2002_exp;

clearvars -Except f_getMtjLigamentMoment
close all
clc



pathmain = pwd;
[pathRepo,~,~]  = fileparts(pathmain);

ModelPath = fullfile(pathRepo,'OpenSimModel','temp','DHondt_2023_model_with_3_segment_foot.osim');
ModelPath2 = fullfile(pathRepo,'OpenSimModel','temp','DHondt_2023_model_with_3_segment_foot_2.osim');

ligament_names = {'LongPlantar1_r','LongPlantar2_r','LongPlantar3_r','LongPlantar4_r',... % long plantar ligament
    'CalcaneoCuboidPlantar1Mus_r','CalcaneoCuboidPlantar2Mus_r',... % short plantar ligament
    'CalcaneoNavicularPlantar1Mus_r','CalcaneoNavicularPlantar2Mus_r','CalcaneoNavicularPlantar3Mus_r',... % spring ligament
    'CalcaneoCuboidDorsalMus_r','CalcaneoNavicularBifurcateMus_r','CalcaneoCuboidBifurcateMus_r',... % other
    'LongPlantar1_l','LongPlantar2_l','LongPlantar3_l','LongPlantar4_l',... % long plantar ligament
    'CalcaneoCuboidPlantar1Mus_l','CalcaneoCuboidPlantar2Mus_l',... % short plantar ligament
    'CalcaneoNavicularPlantar1Mus_l','CalcaneoNavicularPlantar2Mus_l','CalcaneoNavicularPlantar3Mus_l',... % spring ligament
    'CalcaneoCuboidDorsalMus_l','CalcaneoNavicularBifurcateMus_l','CalcaneoCuboidBifurcateMus_l'}; % other


import org.opensim.modeling.*;
model = Model(ModelPath);
s = model.initSystem;


p = length(ligament_names);

% for j=1
%     lig = Ligament.safeDownCast(model.getForceSet().get(ligament_names{j}));
% %     pcsa_0 = lig.get_pcsa_force();
% %     pcsa_1 = pcsa_0*0.010264759565015;
% %     lig.set_pcsa_force(pcsa_1);
%     Fl_c = lig.get_force_length_curve();
%     Fl_s = SimmSpline.safeDownCast(Fl_c);
%     Fl_s.dump()
% end

x_vec = [-5 0.998 0.999 1, 1.01:0.02:1.15,1.16,1.19,1.2:0.1:1.6,1.61,1.62,5];
y_vec = f_getMtjLigamentMoment(x_vec);
y_vec(y_vec<0) = 0;
y_vec(y_vec>1e3) = 1e3;

% figure
% plot(x_vec,y_vec,'.')

Fl_new = SimmSpline();
Fl_new.setName("stress_strain_curve")
for i=1:length(x_vec)
    Fl_new.addPoint(x_vec(i),y_vec(i));
end
% Fl_new.dump()

for j=1:p
    lig = Ligament.safeDownCast(model.getForceSet().get(ligament_names{j}));

    lig.set_force_length_curve(Fl_new);

%     Fl_c = lig.get_force_length_curve();
%     Fl_s = SimmSpline.safeDownCast(Fl_c);
%     n=Fl_s.getSize();
%     for i=1:length(x_vec)
%         Fl_s.setX(i-1,x_vec(i));
%         Fl_s.setY(i-1,y_vec(i));
%     end
%     for i=length(x_vec)+1:n
%         Fl_s.deletePoint(i-1);
%     end

end

x_vec = [-5 0.998 0.999 1, 1.01:0.02:1.15,1.16,1.19,1.2,1.21,5];
f_plantarfascia = f_getPlantarFasciaStiffnessModelCasADiFunction('Natali2010','ls',0.146);
y_vec = full(f_plantarfascia(x_vec*0.146))/60;

y_vec(y_vec<0) = 0;
y_vec(isnan(y_vec(:))) = 0;
y_vec(y_vec>1e3) = 1e3;

Fl_new = SimmSpline();
Fl_new.setName("stress_strain_curve")
for i=1:length(x_vec)
    Fl_new.addPoint(x_vec(i),y_vec(i));
end

% figure
% plot(x_vec,y_vec,'.')

lig = Ligament.safeDownCast(model.getForceSet().get('PlantarFascia_r'));
lig.set_force_length_curve(Fl_new);

lig = Ligament.safeDownCast(model.getForceSet().get('PlantarFascia_l'));
lig.set_force_length_curve(Fl_new);


% % model.initSystem;
% % model.print(ModelPath2);


