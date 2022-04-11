function [] = PlotResultsComparison_3DSim(ResultsFile1,ResultsFile2,legNames)

Csv = hsv(3);

h = figure();
h.Name = 'Sim3D_ResultsComparison';
hTabGroup = uitabgroup;
% tab1 = uitab(hTabGroup, 'Title', 'Ankle 1');
% tab2 = uitab(hTabGroup, 'Title', 'Ankle 2');
tab1 = uitab(hTabGroup, 'Title', 'a E');
tab2 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab3 = uitab(hTabGroup, 'Title', 'a E');
tab4 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab5 = uitab(hTabGroup, 'Title', 'a E');
tab6 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab7 = uitab(hTabGroup, 'Title', 'a E');
tab8 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab9 = uitab(hTabGroup, 'Title', 'a E');
tab10 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab11 = uitab(hTabGroup, 'Title', 'a E');
tab12 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab13 = uitab(hTabGroup, 'Title', 'a E');
tab14 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab15 = uitab(hTabGroup, 'Title', 'a E');
tab16 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab17 = uitab(hTabGroup, 'Title', 'a E');
tab18 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab19 = uitab(hTabGroup, 'Title', 'a E');
tab20 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab21 = uitab(hTabGroup, 'Title', 'a E');
tab22 = uitab(hTabGroup, 'Title', 'l_M F_T');
tab23 = uitab(hTabGroup, 'Title', 'a E');
tab24 = uitab(hTabGroup, 'Title', 'l_M F_T');


set(h,'Color','w');

            
for j=1:3
if(j==1)
    [path,file,~] = fileparts(ResultsFile1);
    addpath(path);
    load(file);
%     legNames{1} = R.S.savename;
elseif(j==2)
   [path,file,~] = fileparts(ResultsFile2);
    addpath(path);
    load(file);
%     legNames{2} = R.S.savename;
end

Cs = Csv(j,:);

%     iSol = find(strcmp(R.colheaders.muscles,'soleus_r'));
%     iGas = find(strcmp(R.colheaders.muscles,'lat_gas_r'));
%     iGas2 = find(strcmp(R.colheaders.muscles,'med_gas_r'));
%     iTib = find(strcmp(R.colheaders.muscles,'tib_ant_r'));
%     if isempty(iGas)
%         iGas = find(strcmp(R.colheaders.muscles,'gaslat_r'));
%     end
%     if isempty(iGas2)
%         iGas2 = find(strcmp(R.colheaders.muscles,'gasmed_r'));
%     end
%     if isempty(iTib)
%         iTib = find(strcmp(R.colheaders.muscles,'tibant_r'));
%     end
%     mVect = {'Soleus','Gas-lat','Gas-med','Tib-ant'};
%     
%     iM = [iSol iGas iGas2 iTib];
    

mVect = {'Glut med 1','Glut med 2','Glut med 3',...
        'Glut min 1','Glut min 2','Glut min 3','Semimem',...
        'Semiten','bifemlh','Bic fem sh','Sar','Add long',...
        'Add brev','Add mag 1','Add mag 2','Add mag 3','TFL',...
        'Pect','Grac','Glut max 1','Glut max 2','Glut max 3',......
        'Iliacus','Psoas','Quad fem','Gem','Peri',...
        'Rect fem','Vas med','Vas int','Vas lat','Med gas',...
        'Lat gas','Soleus','Tib post','Flex dig','Flex hal',...
        'Tib ant','Per brev','Per long','Per tert','Ext dig',...
        'Ext hal','Ercspn','Intobl','Extobl'};
iM = [47:92];    
    
    for i=1:size(iM,2)
        ii = rem(i,4)+1;
        if(j==1)
            a1 = R.a;
            MetabB_Etot1 = R.MetabB.Etot;
            lMtilde1 = R.lMtilde;
            FT1 = R.FT;
        end
        
        if(j==3)    % plot differences
            if(i<5)
            axes('parent', tab1);
            elseif(i<9)
            axes('parent', tab3);    
            elseif(i<13)
            axes('parent', tab5);    
            elseif(i<17)
            axes('parent', tab7);
            elseif(i<21)
            axes('parent', tab9);
            elseif(i<25)
            axes('parent', tab11);
            elseif(i<29)
            axes('parent', tab13);
            elseif(i<33)
            axes('parent', tab15);    
            elseif(i<37)
            axes('parent', tab17);    
            elseif(i<41)
            axes('parent', tab19);    
            elseif(i<44)
            axes('parent', tab21);    
            else
            axes('parent', tab23);    
            end
        
            
        subplot(5,4,ii+4)
        plot((R.a(:,iM(i))-a1(:,iM(i))),'-','Color',Cs); hold on; grid on
        xlabel('% stride'); ylabel('\Delta activity');
        
        subplot(5,4,ii+8)
        plot((R.a(:,iM(i))-a1(:,iM(i)))./a1(:,iM(i)),'-','Color',Cs); hold on; grid on
        xlabel('% stride'); ylabel('\delta activity');
        
        subplot(5,4,ii+16)
        plot((R.MetabB.Etot(:,iM(i))-MetabB_Etot1(:,iM(i))),'-','Color',Cs); hold on; grid on;
        xlabel('% stride'); ylabel('\Delta Muscle metab power');
        
             if(i<5)
            axes('parent', tab2);
            elseif(i<9)
            axes('parent', tab4);    
            elseif(i<13)
            axes('parent', tab6);    
            elseif(i<17)
            axes('parent', tab8);
            elseif(i<21)
            axes('parent', tab10);
            elseif(i<25)
            axes('parent', tab12);
            elseif(i<29)
            axes('parent', tab14);
            elseif(i<33)
            axes('parent', tab16);    
            elseif(i<37)
            axes('parent', tab18);    
            elseif(i<41)
            axes('parent', tab20);    
            elseif(i<44)
            axes('parent', tab22);    
            else
            axes('parent', tab24);    
             end
            
        subplot(5,4,ii+4)
        plot((R.lMtilde(:,iM(i))-lMtilde1(:,iM(i))),'-','Color',Cs); hold on; grid on;
        xlabel('% stride'); ylabel('\Delta Norm fiber length');
        
        
         subplot(5,4,ii+8)
        plot((R.lMtilde(:,iM(i))-lMtilde1(:,iM(i)))./lMtilde1(:,iM(i)),'-','Color',Cs); hold on; grid on;
        xlabel('% stride'); ylabel('\delta Norm fiber length');
        
        subplot(5,4,ii+16)
        plot((R.FT(:,iM(i))-FT1(:,iM(i))),'-','Color',Cs); hold on; grid on;
        xlabel('% stride'); ylabel('\Delta Norm muscle force');
        
        else    % plot values
            if(i<5)
            axes('parent', tab1);
            elseif(i<9)
            axes('parent', tab3);    
            elseif(i<13)
            axes('parent', tab5);    
            elseif(i<17)
            axes('parent', tab7);
            elseif(i<21)
            axes('parent', tab9);
            elseif(i<25)
            axes('parent', tab11);
            elseif(i<29)
            axes('parent', tab13);
            elseif(i<33)
            axes('parent', tab15);    
            elseif(i<37)
            axes('parent', tab17);    
            elseif(i<41)
            axes('parent', tab19);    
            elseif(i<44)
            axes('parent', tab21);    
            else
            axes('parent', tab23);    
            end
            
        subplot(5,4,ii)
        plot(R.a(:,iM(i)),'-','Color',Cs); hold on;  title(mVect{i});
        xlabel('% stride'); ylabel('activity');
        
        if j==2 && ii==1
           legend(legNames) 
        end
        
        subplot(5,4,ii+12)
        plot(R.MetabB.Etot(:,iM(i)),'-','Color',Cs); hold on;
        xlabel('% stride'); ylabel('Muscle metab power');
        
             if(i<5)
            axes('parent', tab2);
            elseif(i<9)
            axes('parent', tab4);    
            elseif(i<13)
            axes('parent', tab6);    
            elseif(i<17)
            axes('parent', tab8);
            elseif(i<21)
            axes('parent', tab10);
            elseif(i<25)
            axes('parent', tab12);
            elseif(i<29)
            axes('parent', tab14);
            elseif(i<33)
            axes('parent', tab16);    
            elseif(i<37)
            axes('parent', tab18);    
            elseif(i<41)
            axes('parent', tab20);    
            elseif(i<44)
            axes('parent', tab22);    
            else
            axes('parent', tab24);    
             end
            
        subplot(5,4,ii)
        plot(R.lMtilde(:,iM(i)),'-','Color',Cs); hold on; title(mVect{i});
        xlabel('% stride'); ylabel('Norm fiber length');
        
        subplot(5,4,ii+12)
        plot(R.FT(:,iM(i)),'-','Color',Cs); hold on;
        xlabel('% stride'); ylabel('Norm muscle force');
        end
    end
    
   
    
end
    
    
    