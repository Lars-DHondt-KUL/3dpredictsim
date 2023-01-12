

idx_x = [1,4,7,10,13,16]; % 19,22,25,28,31,34
idx_y = idx_x + 1;
idx_z = idx_y + 1;

%
load(ResultsFile{1},'R')
GRF_x = sum(R.GRFs_separate(:,idx_x),2);
GRF_y = sum(R.GRFs_separate(:,idx_y),2);
GRF_z = sum(R.GRFs_separate(:,idx_z),2);

GRFs1 = [GRF_x,GRF_y,GRF_z];

diff1 = R.GRFs(:,1:3) - GRFs1;


%
load(ResultsFile{2},'R')
GRF_x = sum(R.GRFs_separate(:,idx_x),2);
GRF_y = sum(R.GRFs_separate(:,idx_y),2);
GRF_z = sum(R.GRFs_separate(:,idx_z),2);

GRFs2 = [GRF_x,GRF_y,GRF_z];

diff2 = R.GRFs(:,1:3) - GRFs2;



%%

figure
tiledlayout('flow')
iswing1 = find(GRFs1(:,2)<(GRFs1(1,2)));
iswing2 = find(GRFs2(:,2)<(GRFs2(1,2)));

tmp = 'xyz';
for i=1:3
    nexttile
    plot(GRFs1(:,i))
    hold on
    plot(GRFs2(:,i))
    xlabel('gait cycle')
    title(['GRF ' tmp(i)])
end

for i=1:3
    nexttile
    plot(GRFs1(iswing1,i))
    hold on
    plot(GRFs2(iswing2,i))
    xlabel('swing')
end

legend({'soft contact','stiff contact'},'Location','best')





