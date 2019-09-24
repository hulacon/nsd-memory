function data = run_nsd_memory(tsvFilepath)
% data = run_nsd_memory(tsvFilepath)
% 
% runs 'final' episodic memory test for NSD experiment. 
%
% jbh&ic 9/17/19

%% get info about subject (check to see what is needed for this)
if ~exist('tsvFilepath','var')||isempty(tsvFilepath)
   [tfn, tfp] = uigetfile('.tsv', 'Please select subject''s most recent responses.tsv file:'); 
    tsvFilepath = fullfile(tfp,tfn);
end
fprintf('\nLoading in response file... ');
resp = tdfread(tsvFilepath); %
fprintf('Done.\n');

% hard code path to stim file?
stimFilepath = fullfile('Z:','hulacon','shared','nsd','nsddata_stimuli','stimuli','nsd','nsd_stimuli.hdf5');



%% initialize, etc
%set random seed to be sub specific
s = RandStream('mt19937ar','Seed',resp.SUBJECT(1));
RandStream.setGlobalStream(s);

% boilerplate
ListenChar(2);
HideCursor;
GetSecs;

% platform-independent responses
KbName('UnifyKeyNames');

%% Set-up Display information
SN = 0; % assumes not dual display ;
sDim = Screen('Rect',SN);

backColor = 220; % TODO: match to nsd proper
textColor = 0; % TODO: match to nsd proper

screenRect = sDim;

% set some screen preferences
% Screen('BlendFunction', window.onScreen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('Preference','SkipSyncTests', 0);
Screen('Preference','VisualDebugLevel', 0);

mainWindow = Screen(SN,'OpenWindow',backColor,screenRect,32);

Screen(mainWindow, 'TextFont', 'Arial');
Screen(mainWindow, 'TextSize', 18);
imgDim = 425; % assume 425x425 images
imageRect = [0,0,imgDim,imgDim];
centerImageRect = CenterRect(imageRect,screenRect);

%% load in images
stimIDVec = select_stimuli(resp);
numStim = length(stimIDVec);
stimCell = cell(numStim,1);
stim
for ii = 1:numStim
    stimCell{ii} = permute(h5read(stimFilepath,'/imgBrick',[1 1 1 ii],[3 425 425 1]),[3 2 1]);
end



%% trial loop


% confidence rating

% if old, then
% how many repetitions

% temporal position judgement

% save data

