function [fixcode fixoffcode tgtcode tgtoffcode saccode stopcode rewcode errcode1 errcode2 errcode3 errcode4] = taskfindecode(tasktype);

%define ecodes according to task
%add last number for direction

fixcode=[];
fixoffcode=[];
tgtcode=[];
tgtoffcode=[];
saccode=[];
stopcode=[];
rewcode=1030;
errcode1=17385;
errcode2=16386;
errcode3=16387;
errcode4=16388;

if strcmp(tasktype,'vg_saccades') %change in num_rex_trial the vg sac to differenciate optiloc ? It has errcd2
    fixcode=621;
    fixoffcode=661;
    tgtcode=681;
    tgtoffcode=103;
    saccode=701;
elseif strcmp(tasktype,'base2rem50')
    fixcode=[622,624,628];
    fixoffcode=[702,664,688];
    tgtcode=[662,684,668];
    tgtoffcode=[662,103,103];
    saccode=[722,704,708];
elseif strcmp(tasktype,'st_saccades')
    fixcode=622;
    fixoffcode=742;
    tgtcode=662;
    tgtoffcode=682;
    saccode=702;
elseif strcmp(tasktype,'gapstop')
    fixcode=[624,427];
    fixoffcode=[664,467];
    tgtcode=[684,487];
    tgtoffcode=[103 103];
    saccode=[704];
    stopcode=[507];
else
    disp('task type not recognized');
    return
end
% if nargout == 1
% end