
%% get info about subject (check to see what is needed for this)

% set up parameters (display, etc)

%% initialize, etc
% boilerplate
ListenChar(2);
HideCursor;
GetSecs;

% platform-independent responses
KbName('UnifyKeyNames');

%% Set-up Display information
SN = 0; % assumes not dual display ;
sDim = Screen('Rect',SN);

screenX = sDim(3);
screenY = sDim(4);
centerX = (screenX/2);
centerY = (screenY/2);
backColor = 220; % TODO: match to nsd proper
textColor = 0; % TODO: match to nsd proper

screenRect = sDim;

% set some screen preferences
% Screen('BlendFunction', window.onScreen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('Preference','SkipSyncTests', 0);
Screen('Preference','VisualDebugLevel', 0);

mainWindow = Screen(SN,'OpenWindow',backColor,screenRect,32);

flipTime = Screen('GetFlipInterval',mainWindow);
Screen(mainWindow, 'TextFont', 'Arial');
Screen(mainWindow, 'TextSize', 18);
imgDim = 425; % assume 425x425 images
halfSize = imgDim/2; %
imageRect = [0,0,imgDim,imgDim];
centerImageRect = CenterRect(imageRect,screenRect);

% load in images

% trial loop


% confidence rating

% if old, then
% how many repetitions

% temporal position judgement

% save data

