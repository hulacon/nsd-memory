function stimVec = select_stimuli(respData)
% stimVec = select_stimuli(respData)
%
% returns nsd id for stimuli based on some criteria hard-coded within this
% function. respData can either be resp struct from run_nsd_memory or
% string of tsv file. will give prompt if left empty/unspecified
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
resp = filter_resp(resp,'REP',2,'ISCORRECT',1,'HMCFFIRST',3,'HMCFRECENT',1,'NOSAMERUNREPS',1);
firstSess = resp.SESSION-resp.SESSFIRST;
lastSessAgo = finalSess-resp.SESSION;
firstSessAgo = finalSess-firstSess;


%% plot bivariate hist to figure out sampling options
% [N,c]=hist3([firstSessAgo lastSessAgo]);
% xtxt = repmat(c{1},size(N,1),1);
% ytxt = repmat(c{2}',1,size(N,2));
% figure;
histEdge{1}=0:max(firstSessAgo);
histEdge{2}=0:max(lastSessAgo);
hist3([firstSessAgo lastSessAgo],'CdataMode','auto','Edges',histEdge);
a=gca;
a.CLim = [0 20];
xlabel('First Sess Ago')
ylabel('Last Sess Ago')
c=colorbar;
% c.Limits=[0 200];
c.Label.String = 'Trials';
% map = ones(20,3).*.6;
% map(:,3) = .3:((.7)/19):1;
map = colormap;
map(1,:) = [1 0 0];
colormap(map);
view(2)
title(sprintf('Subject %d',resp.SUBJECT(1)));
% text(xtxt(:),ytxt(:),num2str(N(:)));


%% selectively subsample


%% assign shared1000 based on what's needed for similarity task


%% assign novel items



%% ouput sorted stimvec
stimVec = sort(unique(resp.x73KID));

%% debug mode
stimVec = Shuffle(stimVec);
stimVec = stimVec(1:100);



