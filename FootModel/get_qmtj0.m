
import casadi.*

[pathRepo,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathRepo);

pathCasADiFunctions = [pathRepo,'/CasADiFunctions'];

CsV = hsv(length(ResultsFile));

for ires=1 %:length(ResultsFile)

load (ResultsFile{ires},'R')

imtj = find(strcmp(R.colheaders.joints,'mtj_angle_r'));
imtp = find(strcmp(R.colheaders.joints,'mtp_angle_r'));

if isempty(imtj)
    continue
end

PathDefaultFunc = fullfile(pathCasADiFunctions,R.S.CasadiFunc_Folders);

f_lLi_vLi_dM = Function.load(fullfile(PathDefaultFunc,'f_lLi_vLi_dM'));


l_PF0 = R.S.Foot.PF_slack_length;

q_mtp = SX.sym('q_mtp',1);
q_mtj = SX.sym('q_mtj',1);

[l_PF,~,~] =  f_lLi_vLi_dM([q_mtj,q_mtp],[0,0]);

f_PF = Function('f_PF',{q_mtj,q_mtp},{l_PF-l_PF0});

f_q_mtj = rootfinder('f_q_mtj','newton',f_PF);

q_mtj0 = full(f_q_mtj(R.Qs(:,imtj)*pi/180, R.Qs(:,imtp)*pi/180)*180/pi);

%%
if ires==1
    figure
    tiledlayout('flow')
end
x = 1:(100-1)/(size(R.Qs,1)-1):100;



nexttile(1)
plot(x,R.Qs(:,imtp),'Color',CsV(ires,:))
hold on
ylabel('MTPJ (°)')

nexttile(2)
plot(x,R.Qs(:,imtj),'Color',CsV(ires,:))
hold on
plot(x,q_mtj0,'--','Color',CsV(ires,:))
ylabel('MTJ (°)')

nexttile(3)
dl = (R.Qs(2:end,imtj)-R.Qs(1:end-1,imtj))*(x(2)-x(1));
plot((x(2:end)+x(1:end-1))/2,dl,'Color',CsV(ires,:))
hold on
ds = (q_mtj0(2:end)-q_mtj0(1:end-1))*(x(2)-x(1));
plot((x(2:end)+x(1:end-1))/2,ds,'--','Color',CsV(ires,:))
if ires==1
    yline(0,'k')
end

nexttile(4)

plot((x(2:end)+x(1:end-1))/2,dl-ds,'Color',CsV(ires,:))
hold on
plot((x(2:end)+x(1:end-1))/2,abs(dl)-abs(ds),'-.','Color',CsV(ires,:))

if ires==1
    yline(0,'k')
    ylabel('\Deltal - \Deltas')
end

end