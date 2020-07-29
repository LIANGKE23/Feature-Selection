function plotFeat(FeatStat,FeatNames,num_on_bar,whichdataset)
% FeatStat: nx2 where n is the number of features.  
%     The second dimension is feature number and then score
% FeatNames: Names of all the features
% num_on_bar the number of features to show on the bar graph
if whichdataset == 1
        FeatIndex=FeatStat(:,1);   
        FeatScore=FeatStat(:,2);      
        
        % Get the list of missing indexes
        % FeatIndex		list of variables selected
        % notSel        list of indexes not present
        % nv            total number of variables
        nv=15500;
        notSel=[];
        for cnti=1:nv,
            selected=0;
            for cntj=1:length(FeatIndex)
              if FeatIndex(cntj)==cnti
                selected=1;
                break;
              end
            end
            if ~(selected)
              notSel=[notSel, cnti];
            end
        end
       
        % Append the missing indexes to the Feat index
        FeatStat=[FeatIndex' notSel; FeatScore' zeros(size(notSel))]';
        FeatStat=sortrows(FeatStat,1);
        FeatScore=FeatStat(:,2)'; 
        FeatStat=[];
%        Face=dlmread('data\Face.txt');
        Face=dlmread('data/Face.txt'); %on MAC
        % reshape data to display
        size(FeatScore);
        FeatListOD=FeatScore(1:7750);
        FeatListOD=reshape(FeatListOD,[125 62]);
        FeatListOD=[FeatListOD fliplr(FeatListOD)];
        mnOD=min(FeatListOD(:));
        mxOD=max(FeatListOD(:));        
        FeatListOD(FeatListOD<=0)=0;
        FeatListOD(1)=mnOD; FeatListOD(2)=mxOD;
                    
        FeatListHD=FeatScore(7751:end);
        FeatListHD=reshape(FeatListHD,[125 62]);
        FeatListHD=[FeatListHD fliplr(FeatListHD)];
        mnHD=min(FeatListHD(:));
        mxHD=max(FeatListHD(:));        
        FeatListHD(FeatListHD<=0)=0;
        FeatListHD(1)=mnHD; FeatListHD(2)=mxHD;
        FeatScore=[];


        figure;
        subplot(121);
            surf(flipud(Face+FeatListOD),flipud(FeatListOD),'facecolor','interp','edgecolor','interp','edgecolor','none')
            colorbar vert
            colormap jet;
            view(0,90)
            freezeColors;
            freezeColors(colorbar);
            hold on;
            imMask=imread('data/mask.jpg');
            surface(flipud(Face),(imMask),'FaceColor','texturemap',...
                    'EdgeColor','none',...
                    'CDataMapping','direct');
            colormap gray
            view(0,90);
            axis tight;
            imshow(imMask)
            view(0,90);
            hold off;
            title('OD features');
        subplot(122);
            surf(flipud(Face+FeatListHD),flipud(FeatListHD),'facecolor','interp','edgecolor','interp','edgecolor','none')
            colorbar vert
            colormap jet;
            view(0,90)
            freezeColors;
            freezeColors(colorbar);
            hold on;
            imMask=imread('data/mask.jpg');
            surface(flipud(Face),(imMask),'FaceColor','texturemap',...
                    'EdgeColor','none',...
                    'CDataMapping','direct');
            colormap gray
            view(0,90);
            axis tight;
            imshow(imMask)
            view(0,90);
            hold off;
            title('HD features');
            xlabel('You can also rotate these figures in 3D');
units=get(gcf,'units');
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'units',units);
elseif whichdataset == 2
    %% Sort top feature and plot on bar graph
    figure;
    FeatStat = sortrows(FeatStat,-2);
    barh(FeatStat(num_on_bar:-1:1,2));
    FeatNames = FeatNames(FeatStat(:,1));
    set(gca,'YTick', 1:num_on_bar,'YTickLabel',FeatNames(num_on_bar:-1:1),'FontSize', 14);
    ylim([.5,num_on_bar+.5]);
    grid on
    xlabel('Feature Criteria Score','FontSize', 18);
    ylabel('Features','FontSize', 18);
    title(sprintf('Top %d Ranked Features',num_on_bar),'FontSize', 20)

    %% Display Where on the brain the features are coming from
    figure;
    addpath(genpath('./brain_mapping'));
    three = ~cellfun(@isempty,regexp(FeatNames,'E[0-9][0-9][0-9]'));
    two = ~cellfun(@isempty,regexp(FeatNames,'E[0-9][0-9]'));
    loc = cell2mat(regexp(FeatNames,'E[0-9]'));

    % Create histogram for plot
    elect_hist = zeros(128,1);
    elect_score_hist = zeros(128,1);
    for i = 1:length(loc)
        elect = str2double(FeatNames{i}(loc(i)+1:loc(i)+three(i)+two(i)+1));
        elect_hist(elect) = elect_hist(elect)+FeatStat(i,1);
    end

    title('Sum of Feature Criteria Scores for Each Electrode','FontSize', 20)
    topoplot(elect_hist,'GSN-HydroCel-128.sfp','electrodes','labelpoint', 'verbose', 'off','shading','interp','whitebk', 'on','maplimits',[min(elect_hist) , max(elect_hist)]);
    colorbar;
    rmpath(genpath('./brain_mapping'));
end