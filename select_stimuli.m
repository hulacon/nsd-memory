function [stimVec, stimCat] = select_stimuli(respData)
% [stimVec stimCat] = select_stimuli(respData)
%
% returns nsd 73k id for stimuli based on some criteria hard-coded within this
% function. respData can either be resp struct from run_nsd_memory or
% string of tsv file. will give prompt if left empty/unspecified
%
% stimCat refers to 0 novel, 1 shared 1000/sim, 2 other old
%
% jbh 9/23/19
%% get info about subject (check to see what is needed for this)
if ~exist('respData','var')||isempty(respData)
    [tfn, tfp] = uigetfile('.tsv', 'Please select subject''s most recent responses.tsv file:');
    respData = fullfile(tfp,tfn);
end

if ischar(respData)
    fprintf('\nLoading in response file... ');
    resp = tdfread(respData); %
    fprintf('Done.\n');
else
    resp = respData;
end

%% retrieve key vars, filter to things you care about
resp = add_resp_info(resp);
finalSess = max(resp.SESSION);
resp.NOSAMERUNREPS = and(resp.SAMERUNBEFORE~=1,resp.SAMERUNRECENT~=1);
resp = filter_resp(resp,'REP',2,'ISCORRECT',1,'HMCFFIRST',3,'HMCFRECENT',1); %only look at 3peats w/all correct resps
resp.FIRSTSESS = resp.SESSION-resp.SESSFIRST;
% lastSessAgo = finalSess-resp.SESSION;
% firstSessAgo = finalSess-firstSess;


%% plot bivariate hist to figure out sampling options
% [N,c]=hist3([firstSessAgo lastSessAgo]);
% xtxt = repmat(c{1},size(N,1),1);
% ytxt = repmat(c{2}',1,size(N,2));
% % figure;
% histEdge{1}=0:max(firstSessAgo);
% histEdge{2}=0:max(lastSessAgo);
% hist3([firstSessAgo lastSessAgo],'CdataMode','auto','Edges',histEdge);
% a=gca;
% a.CLim = [0 20];
% xlabel('First Sess Ago')
% ylabel('Last Sess Ago')
% c=colorbar;
% % c.Limits=[0 200];
% c.Label.String = 'Trials';
% % map = ones(20,3).*.6;
% % map(:,3) = .3:((.7)/19):1;
% map = colormap;
% map(1,:) = [1 0 0];
% colormap(map);
% view(2)
% title(sprintf('Subject %d',resp.SUBJECT(1)));
% % text(xtxt(:),ytxt(:),num2str(N(:)));



%% assign shared1000 based on what's needed for similarity task
% KENDRICK AND/OR IAN THIS IS WHERE YOU CAN PUT 73kID VECTOR OF 100 ITEMS
% YOU WANT:
sh100IDs = randsample(73000,100);


%% assign novel items
numNovelItems = 100;
allIDs = 1:73000;
novIDs = setdiff(allIDs',vertcat(sh100IDs,resp.x73KID));
novIDs = randsample(novIDs,numNovelItems);

%% selectively subsample
% set up to sample evenly from below bivariate bins. 
itemsPerBin = 20;
recentBinThresh = finalSess-7; % make sure half of items are taken from last 8 sessions
% recentBinThresh = ceil(finalSess/2);
% recentBinMid = finalSess-3; % make sure half of those items are taken from last 4 sessions
% olderBinMid = ceil((finalSess-recentBinThresh)/2); % break up the oldest last session - recentbinthresh into half
firstfactor = 'FIRSTSESS';
% firstfactorbins = {1:olderBinMid-1 olderBinMid:recentBinThresh-1 recentBinThresh:recentBinMid-1 recentBinMid:finalSess}; % four bin version
firstfactorbins = {1:recentBinThresh-1 recentBinThresh:finalSess}; % two bin version
secondfactor = 'UNIQUESESS12_21';
secondfactorbins = {0, 1, 2:3};
oldIDs = [];
% 
% % inspect
% edges = {1:finalSess,0:3};
% hist3([resp.(firstfactor) resp.(secondfactor)],'CdataMode','auto','Edges',edges)
% view(2); colorbar;
% map = colormap;
% map(1,:) = [1 0 0];
% colormap(map);


for ff = 1:length(firstfactorbins)
   for sf = 1:length(secondfactorbins)
        binresp = filter_resp(resp,firstfactor,firstfactorbins{ff},secondfactor,secondfactorbins{sf});
        binitems = binresp.x73KID;
%         disp(length(binitems));
        binitems = unique(binitems(~isnan(binitems))); % should already be non-nans and unique but just to be sure...
        binitems = setdiff(binitems,sh100IDs); % remove any from shared
        assert(length(binitems)>=itemsPerBin,'Sampling bin size too large!');
        oldIDs = vertcat(oldIDs,randsample(binitems,itemsPerBin));
   end
end


%% organize output
stimVec = vertcat(novIDs,sh100IDs,oldIDs);
stimCat = vertcat(zeros(size(novIDs)),ones(size(sh100IDs)),ones(size(oldIDs)).*2);



%% pseudo randomize squence

stimMat = horzcat(stimVec,stimCat);
miar = 99;
while miar > 3
   stimMat = Shuffle(stimMat,2);
   miar = maxInARow(stimMat(:,2));
end

stimVec = stimMat(:,1);
stimCat = stimMat(:,2);


% 
% %% inspect output
% oirv = ismember(resp.x73KID,oldIDs);
% oifirstsess = resp.FIRSTSESS(oirv);
% oinonsamerun = resp.NOSAMERUNREPS(oirv);
% oispacing = resp.UNIQUESESS(oirv);
% oisessdist = resp.SESSFIRST(oirv);

% %% ouput sorted stimvec
% stimVec = sort(unique(resp.x73KID));
% 
% %% debug mode
% stimVec = Shuffle(stimVec);
% stimVec = stimVec(1:100);
% 


