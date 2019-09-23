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

% load in images

% trial loop


% confidence rating

% if old, then
% how many repetitions

% temporal position judgement

% save data

