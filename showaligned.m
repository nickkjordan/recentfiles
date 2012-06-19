function showaligned(condition,filenb)

aligneddir='/Users/Frank/Desktop/monkeylab/data/processed/aligned/';
mstart=1000;
mstop=500;
fsigma=12;

[mainsacalgndirfiles rewardalgndirfiles stopsignalgndirfiles]= ...
    listprocessedfiles(aligneddir);

msunderscores=strfind(mainsacalgndirfiles,'_');
rewunderscores=strfind(rewardalgndirfiles,'_');
stsunderscores=strfind(stopsignalgndirfiles,'_');

for i=1:length(msunderscores)
finddelim=cell2mat(strfind(mainsacalgndirfiles(i),'_')); 
filename= cell2mat(mainsacalgndirfiles(i));
originalfile(i,1)=mat2cell(filename(1:finddelim(2)-2)); %-2 because we want remove last number
end

for j=1:length(stsunderscores)
finddelim=cell2mat(strfind(stopsignalgndirfiles(j),'_')); 
filename= cell2mat(stopsignalgndirfiles(j));
originalfile(j+i,1)=mat2cell(filename(1:finddelim(2)-2)); 
end

% for j=1:length(rewunderscores)
% finddelim=cell2mat(strfind(rewardalgndirfiles(j),'_')); 
% filename= cell2mat(rewardalgndirfiles(j));
% originalfile(j+i,1)=mat2cell(filename(1:finddelim(2)-1));
% end


uniquefiles=unique(originalfile);

unqunderscores=strfind(uniquefiles,'_');

for i=1:length(unqunderscores)
finddelim=cell2mat(strfind(uniquefiles(i),'_')); 
filename= cell2mat(uniquefiles(i));
recdepth(i,1)=str2num(filename(finddelim+1:end)); %-2 because we want remove last number
end

deepfiles=uniquefiles(find(recdepth>2200));

switch condition
    case 'sac'
load(cat(2,aligneddir,cell2mat(mainsacalgndirfiles(filenb))));
    case 'rew'
load(cat(2,aligneddir,cell2mat(rewardalgndirfiles(filenb))));
    case 'stop'
load(cat(2,aligneddir,cell2mat(stopsignalgndirfiles(filenb))));
end

if size(dataaligned,2)==1
    
            rasters=dataaligned(1).rasters;
            aidx=dataaligned(1).alignidx;
            trialidx=dataaligned(1).trials;
            timefromtrig=dataaligned(1).timefromtrig;
            eyeh=dataaligned(1).eyeh;
            eyev=dataaligned(1).eyev;
            eyevel=dataaligned(1).eyevel;
            allgreyareas=dataaligned(1).allgreyareas;
            amplitudes=dataaligned(1).amplitudes;
            peakvels=dataaligned(1).peakvels;
            peakaccs=dataaligned(1).peakaccs;
            curdir=dataaligned(1).dir;
    
     
      % adjust temporal axis
        start = aidx - mstart;
        stop = aidx + mstop;
        if start < 1
            start = 1;
        end;
        if stop > length( rasters )
            stop = length( rasters );
        end;
        
    
        trials = size(rasters,1);   
        isnantrial=zeros(1,size(rasters,1));
        
        axis([0 stop-start+1 0 size(rasters,1)]);
        hold on
        for j=1:size(rasters,1) %plotting rasters trial by trial
        spiketimes=find(rasters(j,start:stop)); %converting from a matrix representation to a time collection, within selected time range
            if isnan(sum(rasters(j,start:stop)))
                isnantrial(j)=1;
            end
        plot([spiketimes;spiketimes],[ones(size(spiketimes))*j;ones(size(spiketimes))*j-1],'k-')
        end
        hold off
        set(gca,'TickDir','out'); % draw the tick marks on the outside
        set(gca,'YTick', []); % don't draw y-axis ticks
        set(gca,'YDir','reverse');
        set(gca,'YColor',get(gcf,'Color')); % hide the y axis
        box off
     
        %get the current axes
        axrasters= gca;
        
        % write that directions are collapsed
        curdir='all_collapsed';

        s1 = sprintf( 'Trials for %s direction, n = %d trials.', curdir, trials); %num2str( aligncodes(i) )
        title( s1 );
        
        
        % restrict sdf to time window
%       if one wants to remove trials with NaNs :
%         sumall=sum(rasters(~isnantrial,start:stop));
%         sdf=spike_density(sumall,fsigma)./length(find(~isnantrial));
        % otherwise, replace them with 0s
        rasters(isnan(rasters))=0;
        sumall=sum(rasters(:,start:stop));
        sdf=spike_density(sumall,fsigma)./trials;

        %pdf = probability_density( sumall, fsigma ) ./ trials;
            
        % on top of raster plots
        axsdf = axes('Position',get(axrasters,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none');

        plot(sdf,'Color','b','LineWidth',3,'Parent',axsdf);
        axis([0 stop-start 0 200])
        set(gca,'Color','none','YAxisLocation','right','TickDir','out', ...
            'FontSize',8); %'Position',get(rasterh,'Position')
        
        patch([repmat((aidx-start),1,2) repmat((aidx-start)+10,1,2)], ...
        [get(gca,'YLim') fliplr(get(gca,'YLim'))], ...
        [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
   
    set(gcf, 'Position',[523    74   784   755]);  
    
else
    
    
    for i=1:length(dataaligned)
    
            rasters=dataaligned(i).rasters;
            aidx=dataaligned(i).alignidx;
            trialidx=dataaligned(i).trials;
            timefromtrig=dataaligned(i).timefromtrig;
            eyeh=dataaligned(i).eyeh;
            eyev=dataaligned(i).eyev;
            eyevel=dataaligned(i).eyevel;
            allgreyareas=dataaligned(i).allgreyareas;
            amplitudes=dataaligned(i).amplitudes;
            peakvels=dataaligned(i).peakvels;
            peakaccs=dataaligned(i).peakaccs;
            curdir=dataaligned(i).dir;
            
         % adjust temporal axis
        start = aidx - mstart;
        stop = aidx + mstop;
        if start < 1
            start = 1;
        end;
        if stop > length( rasters )
            stop = length( rasters );
        end;
        
        %plot the rasters
                      % if one wants to plots the whole trials, find the
                      % size of the longest trials as follow, and adjust
                      % axis accordingly
%                     testbin=size(rasters,2);
%                     while ~sum(rasters(:,testbin))
%                     testbin=testbin-1;
%                     end
        trials = size(rasters,1);   
        isnantrial=zeros(1,size(rasters,1));
        
subplot(2,length(dataaligned)/2,i);
        
        
        axis([0 stop-start+1 0 size(rasters,1)]);
        hold on
        for j=1:size(rasters,1) %plotting rasters trial by trial
        spiketimes=find(rasters(j,start:stop)); %converting from a matrix representation to a time collection, within selected time range
            if isnan(sum(rasters(j,start:stop)))
                isnantrial(j)=1;
            end
        plot([spiketimes;spiketimes],[ones(size(spiketimes))*j;ones(size(spiketimes))*j-1],'k-');
                % had a doubt about the number of spikes displayed. Twas due to
                % the stupid imagesc rasterplot, which doesn't scale properly at
                % small window sizes
                % spkcntstr=sprintf('number of spikes in raster %d trial %d is %d', i, j, length(spiketimes));
                % disp(spkcntstr);
        end
        hold off;
        set(gca,'TickDir','out'); % draw the tick marks on the outside
        set(gca,'YTick', []); % don't draw y-axis ticks
        set(gca,'YDir','reverse');
        %set(gca,'Color',get(gcf,'Color'))
        set(gca,'YColor',get(gcf,'Color')); % hide the y axis
        box off
        
        %get the current axes
        axrasters= gca;
        
        % finding current trial direction. 
        % Direction already flipped left/ right in find_saccades_3 line 183
        % (see rex_process > find_saccades_3)
        
        s1 = sprintf( 'Trials for %s direction, n = %d trials.', curdir, trials); %num2str( aligncodes(i) )
        title( s1 );
       

        
        % for histogram plot:
%         starth = ceil(start/binwidth);
%         stoph = floor(stop/binwidth);  
        %     h = spikehist(rasters,binwidth);
        %     bar( h(starth:stoph), 'k' );
        %     title( 'spike histogram' );
        %     ax2 = axis();
        %     ax2(2) = ceil( ax1(2) / binwidth );
        %     axis( ax2 );
        
        %% sdf plot
        % for kernel optimization, see : http://176.32.89.45/~hideaki/res/ppt/histogram-kernel_optimization.pdf
        
%       if one wants to remove trials with NaNs :
%           sumall=sum(rasters(~isnantrial,start:stop));
%           sdf=spike_density(sumall,fsigma)./length(find(~isnantrial)); %instead of number of trials

        % otherwise, replace them with 0s
        rasters(isnan(rasters))=0;
        sumall=sum(rasters(:,start:stop));
        sdf=spike_density(sumall,fsigma)./trials;
        
        %pdf = probability_density( sumall, fsigma ) ./ trials;

                % on top of raster plots
        axsdf = axes('Position',get(axrasters,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none');

        plot(sdf,'Color','b','LineWidth',3,'Parent',axsdf);

        axis([0 stop-start 0 200])
        set(gca,'Color','none','YAxisLocation','right','TickDir','out', ...
            'FontSize',8); %'Position',get(rasterh(i),'Position')
        
        patch([repmat((aidx-start),1,2) repmat((aidx-start)+10,1,2)], ...
        [get(gca,'YLim')-20 fliplr(get(gca,'YLim'))-20], ...
        [0 0 0 0],[1 0 0],'EdgeColor','none','FaceAlpha',0.5);
        

    end
    if length(dataaligned) == 2
        set(gcf, 'Position',[523    74   784   755]);  
    else
        set(gcf, 'Position',get(0,'Screensize'));
    end
 
end


        