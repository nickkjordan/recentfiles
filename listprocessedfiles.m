function [mainsacalgndirfiles rewardalgndirfiles stopsignalgndirfiles]= ...
    listprocessedfiles(aligneddir)


algndirfiles=dir(aligneddir);
filedates=cell2mat({algndirfiles(:).datenum});
[filedates,fdateidx] = sort(filedates,'descend');
algndirfiles = {algndirfiles(:).name};
algndirfiles=algndirfiles(fdateidx);
algndirfiles=algndirfiles';
algndirfiles = algndirfiles(~cellfun('isempty',strfind(algndirfiles,'mat')));
algndirfiles = algndirfiles(cellfun('isempty',strfind(algndirfiles,'2SH')));

mainsacalgndirfiles = algndirfiles ...
    (~cellfun('isempty',strfind(algndirfiles,'mainsacalign')));
rewardalgndirfiles = algndirfiles ...
    (~cellfun('isempty',strfind(algndirfiles,'rewardalign')));
stopsignalgndirfiles = algndirfiles ...
    (~cellfun('isempty',strfind(algndirfiles,'stopsignalign')));