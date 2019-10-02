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
sh100IDs = [3078,3172,3914,4424,4668,5584,6522,6802,7208, ...
       11636,11726,11797,11943,12923,13139,13614,15365,16345,...
       16617,17375,19437,21951,22880,23994,24531,24641,25112,...
       25372,25703,26459,27243,27436,28069,28350,28596,30396,...
       30408,31660,34830,35987,36975,36979,37225,38023,38487,...
       39370,40549,40847,42698,42852,43225,43676,43690,43819,...
       44845,45214,45596,45982,46373,47071,47294,50115,50756,...
       50812,51078,53053,53156,53371,54258,54362,54914,55679,...
       55969,56785,56912,56949,57554,59024,59995,61874,62210,...
       63183,63932,64499,65254,65800,66005,66977,67830,68340,...
       68742,68898,69814,69840,70194,70233,70506,71411,72016,...
       72720];
%{ 
OLD BUGGED ITEMS
[3450,5584,6200, 6522, 8110,11334,11522,11618,11726,11845,12309,...
    18544,20739,21219,21254,21602,22264,22496,22795,22994,23037,23716,25579,...
    25703,25742,26991,27243,28160,29838,30396,30431,31748,31802,31965,32773,...
    32911,34239,35744,36577,36732,36946,37222,38642,38830,38854,41098,41163,...
    41654,41815,42008,42225,42782,42981,43165,43225,43429,43620,43821,44145,...
    44706,45130,45633,45946,46151,46373,47294,47409,48803,50115,51522,51844,...
    52395,53053,53153,53156,53729,53774,53892,54362,55409,55670,56155,56868,...
    56912,57047,57839,59586,59700,59818,61123,61511,62545,64499,65800,66279,...
    66581,66837,68312,69008,70076];
%}
sh100IDs = sh100IDs(:);

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
%,disp(length(binitems));
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


