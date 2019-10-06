function data = run_nsd_memory(tsvFilepath)
% data = run_nsd_memory(tsvFilepath)
%
% runs 'final' episodic memory test for NSD experiment.
%
% jbh&ic 9/17/19

%% get info about subject
if ~exist('tsvFilepath','var')||isempty(tsvFilepath)
    [tfn, tfp] = uigetfile('.tsv', 'Please select subject''s most recent responses.tsv file:');
    tsvFilepath = fullfile(tfp,tfn);
end
fprintf('\nLoading in response file... ');
if strcmp(tsvFilepath,'debug')
    resp = tdfread('./debug/responses.tsv');
    resp.SUBJECT(:) = 99;
else
    resp = tdfread(tsvFilepath); %
end
fprintf('Done.\n');

% hard code path to stim file?
%stimFilepath = fullfile('Z:','hulacon','shared','nsd','nsddata_stimuli','stimuli','nsd','nsd_stimuli.hdf5');
stimFilepath = strrep(which('run_nsd_memory.m'),'run_nsd_memory.m','nsd_stimuli.hdf5');

%% add utils functions
addpath('utils')

% set up specific subject info

output_dir = fullfile('results',sprintf('subj-%02d',resp.SUBJECT(1)));
if not(exist(output_dir,'dir'))
    mkdir(output_dir)
end
% set up parameters (display, etc)
outputfile = fullfile(output_dir,'results.mat');
outputtsv = fullfile(output_dir,'nsdmemoryresponses.tsv');

if exist(outputtsv,'file')
    initwf = 'x';
    while ~ismember(initwf,{'w' 'a'})
        initwf = input('\nTSV FILE AREADY EXISTS! Overwrite (w) or append (a)?: ','s');
    end
    if strcmp(initwf,'w')
        delete(outputtsv);
    end
end


%% load in images
fprintf('\nLoading images...');
if resp.SUBJECT(1)==99 % debug
    load('debug/stim_info.mat');
else
    
    [stimIDVec, stimCat]= select_stimuli(resp);
    numStim = length(stimIDVec);
    stimCell = cell(numStim,1);
    % stim
    for ii = 1:numStim
        stimCell{ii} = permute(h5read(stimFilepath,'/imgBrick',[1 1 1 stimIDVec(ii)],[3 425 425 1]),[3 2 1]);
    end
end
fprintf(' Done.\n');


%% initialize, etc
%set random seed to be sub specific
s = RandStream('mt19937ar','Seed',resp.SUBJECT(1));
RandStream.setGlobalStream(s);

% save the seed!
params.seed = s;

% boilerplate
%ListenChar(2);  % this seemed to cause various PT incompatibilities, so KK removed it
% HideCursor;
GetSecs;

% platform-independent responses
KbName('UnifyKeyNames');

whereAreWe = 'someWhereSafe';

% get device info
devices = PsychHID('Devices');
for dd = 1:length(devices)
    if strcmp(devices(dd).product,'Apple Internal Keyboard / Trackpad')
        whereAreWe = 'inAnApple';
        switch devices(dd).usageName
            %             case 'Mouse'
            %                 mouseDevNum = dd;
            case 'Keyboard'
                kbDevNum = dd;
        end   
    end
end

% double check that we are somewhere safe.
if strcmp(whereAreWe, 'someWhereSafe')
    kbDevNum = -1;
end


%% Set-up Display information
SN = 0; % assumes not dual display ;
sDim = Screen('Rect',SN);
screenY=sDim(4);
screenX=sDim(3);
centerY=screenY/2;
centerX=screenX/2;
instructiondelay = 10;  %1 for development

backColor = 127;
textColor = 0;

screenRect = sDim;

% set some screen preferences
% Screen('BlendFunction', window.onScreen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('Preference','SkipSyncTests',1);
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference','TextRenderer',1);


[mainWindow, win_rect] = Screen(SN,'OpenWindow',backColor,screenRect,32);
% flipTime = Screen('GetFlipInterval',SN);
% flipTime = 0;

Screen(mainWindow, 'TextFont', 'Arial');
Screen(mainWindow, 'TextSize', 24);
imgDim = 425; % assume 425x425 images

% STIMULUS SIZE ISSUES (CHANGE AS NECESSARY):
screenwidth_cm = 33;
viewingdistance_cm = 53;
desiredwidth = 8.4;
monitorwidth_px = 1440;
screenwidth_deg = atan(screenwidth_cm/2/viewingdistance_cm)/pi*180*2;
imgorigsize_deg = imgDim/monitorwidth_px * screenwidth_deg;
scfactor = desiredwidth/imgorigsize_deg;  % scale factor necessary to achieve desired size

% keep a log of these.
params.screenwidth_cm = screenwidth_cm;
params.viewingdistance_cm = viewingdistance_cm;
params.desiredwidth = desiredwidth;
params.monitorwidth_px = monitorwidth_px;
params.imgorigsize_deg = imgorigsize_deg;
params.scfactor = scfactor;

imageRect = [0,0,round(scfactor*imgDim),round(scfactor*imgDim)];
centerImageRect = CenterRect(imageRect,screenRect);

% timing
maxdur = 30;             % max duration for confidence rating
maxrepdur = 30;          % max duration for repetition rating
maxtimelinedur = 30;     % max duration for timeline rating
isi = 1;

% keep these too.
params.maxdur = maxdur;
params.maxrepdur = maxrepdur;
params.maxtimelinedur = maxtimelinedur;
params.isi = isi;

% break info
nBlocks = 5; % 5 blocks
blkLen = numStim/nBlocks;
breakTrials = round(blkLen:blkLen:(numStim-blkLen));
block = 1;


%% timeline parameters
timelineimageRect = [0,0,imgDim/2,imgDim/2];
timelinecenterImageRect = CenterRect(timelineimageRect,screenRect);

imageyoffset = [0 .33*screenY 0 .33*screenY];
topImageRect = timelinecenterImageRect-imageyoffset;

% define the timeline arena space
timelineRect = [0 screenY*.3 screenX*.8 screenY*.9];
% Set the color of our square to full red. Color is defined by red green
% and blue components (RGB). So we have three numbers which
% define our RGB values. The maximum number for each is 1 and the minimum
% 0. So, "full red" is [1 0 0]. "Full green" [0 1 0] and "full blue" [0 0
% 1]. Play around with these numbers and see the result.
% rectColor = [0 0 0];
% Center the rectangle on the centre of the screen using fractional pixel
% values.
% For help see: CenterRectOnPointd
timelineArea = CenterRectOnPointd(timelineRect, centerX, centerY);
timelineArea = timelineArea + [0 .16*screenY 0 .16*screenY];

% let's save timelineArea coordinates;
params.timelineArea = timelineArea;

% this next line needs to be discovered from the latest behaviour file.
sessions = 1:max(resp.SESSION);
%months = {'January','February','March','April','May','June','July','August','September','October'};
nsessions= length(sessions);

params.sessions=sessions;

% find location for x ticks
% timelineXlims = [timelineArea(1)+.15*screenX timelineArea(3)-.15*screenX];
sessionTicks = linspace(timelineArea(1), timelineArea(3), nsessions+2);
sessionTicks = sessionTicks(2:end-1);

params.sessionTicks = sessionTicks;

% load in shadow (used in timeline)
[shadowdata, ~, alpha]= imread(fullfile('utils', 'shadow.png'));
shadowdata(:, :, 4) = alpha;

shadowtex = Screen('MakeTexture', mainWindow, shadowdata);
% ms_buttons=100;

% setup the alpha blending
Screen(mainWindow,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% keypress parameters
% response keys for the seen before confidence response
code1 = KbName('1!'); % 1
code2 = KbName('2@'); % 2
code3 = KbName('3#'); % 3
code4 = KbName('4$'); % 4
code5 = KbName('5%'); % 5
code6 = KbName('6^'); % 6
code7 = KbName('p'); % p
% space = KbName('space');

% define the keys we want
keys = zeros(1,256);
keys(code1)=1;
keys(code2)=1;
keys(code3)=1;
keys(code4)=1;
keys(code5)=1;
keys(code6)=1;
keys(code7)=1;
% spkey = zeros(1,256);
% spkey(space) = 1;


%% LOOPING THROUGH TRIALS
% create a queue for monitoring events.
KbQueueCreate(-1,keys);

instructions = defineInstructions();

% set up inline keys:
% if mod(resp.SUBJECT(1),2)
%oldans = [1 2 3];
oldans = [4 5 6];
recogkey ='1=High New   2=Med New   3=Low New   4=Low Old   5=Med Old   6=High Old';
% else
%     oldans = [4 5 6];
%     recogkey ='1=High New   2=Med New   3=Low New   4=Low Old   5=Med Old   6=High Old';
% end
instruxmoveon = 'Press any key to continue or ask the experimenter for assistance';

repkey = 'How many times did you see this image?';

tlkey = 'When was the FIRST session you saw this image?';

%% trial loop

for imageI = 1:numStim
    
    % take a break
    if ismember(imageI,breakTrials)
        WaitSecs(2);
        brkTxt = ['You have reached the end of a block, feel free to take a short break\n\n',...
            'Press any key when you are ready to continue'];
        DrawFormattedText(mainWindow, brkTxt,'center','center',textColor);
        Screen('Flip', mainWindow);
        KbWait(kbDevNum,3);
        block = block+1;
    end
    
    %% reset tsv output struct
    totsv = struct('SUBJECT',resp.SUBJECT(1),'SESSION',1,'BLOCK',block,...
        'TRIAL',imageI,'x73KID',stimIDVec(imageI),'TIME',nan,...
        'STIMCAT',stimCat(imageI),'RECOGBUTTON',nan,...
        'RECOGISCORR',nan,'RECOGRT',nan,'REPBUTTON',nan,'REPRT',nan,...
        'TLSESSEST',nan,'TLCONF',nan,'TLRT',nan);
    tflds = fieldnames(totsv);
    if imageI==1
        fid = fopen(outputtsv,'a');
        for tt = 1:length(tflds)
            fprintf(fid,sprintf('%s\t',tflds{tt}));
        end
        fprintf(fid,'\n');
        fclose(fid);
        
        
        % show instructions!
        for ss = 1:length(instructions)
            currInstrux = instructions{ss};
            [~,nY] = DrawFormattedText(mainWindow, currInstrux,'center','center',textColor);
            Screen('Flip', mainWindow);
            WaitSecs(instructiondelay);
            DrawFormattedText(mainWindow, currInstrux,'center','center',textColor);
            DrawFormattedText(mainWindow, instruxmoveon,'center',nY+50,textColor);
            Screen('Flip', mainWindow);
            KbWait(kbDevNum,3);
        end
        
        DrawFormattedText(mainWindow, 'Experiment starting...','center','center',textColor);
        Screen('Flip', mainWindow);
        WaitSecs(3);
    end
    
    %% reset vars
    HideCursor;
    button_clicked = NaN;
    confidence = NaN;
    session_estimate = NaN;
    answer = 0;
    responded = 0;
    mx = nan;
    my = nan;
    rt = nan;
    reprt = nan;
    tlrt = nan;
    
    % define that image's texture
    imagetex = Screen('MakeTexture', mainWindow, stimCell{imageI});
    
    %% part 1: old (responses from 1 to 6) or new
    
    % initiate the kb listener
    % start the keyboard reading queue
    KbQueueStart; % start the queue
    queuestart = GetSecs; % time stamp when the queue starts
    
    % draw the image
    Screen('DrawTexture', mainWindow, imagetex,[],centerImageRect,[],1);  % bilinear filtering
    DrawFormattedText(mainWindow, recogkey,'center',screenY-100,textColor);
    onset = Screen('Flip', mainWindow);
    totsv.TIME = now; % get timestamp at onset
    
    % do your response collection
    % handle isi and self paced response
    numquits = 0;
    while GetSecs - onset <= maxdur && not(responded)
        % check for answer this will make it self paced.
        [pressed, firstPress] = KbQueueCheck(kbDevNum);
        % if the subject answers during this delay, we get straight to
        % the feedback
        if pressed
            responded = 1;
            %             sca
            %             keyboard
            pressedCodes = find(firstPress);
            if pressedCodes(1)==code1
                answer = 1; %
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code2
                answer = 2; %
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code3
                answer = 3; %
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code4
                answer = 4; %
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code5
                answer = 5; %
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code6
                answer = 6; %
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code7
                responded = 0;
                answer = [];
                if numquits==5  % press p 5 times to quit without saving any data!
                  sca;
                  save(outputfile, 'params');
                  return;
                else
                  numquits = numquits + 1;
                end
            end
            % break out
            if answer
                % go back to grey
                Screen('Flip', mainWindow);
                break;
            end
        end
    end
    
%     max_offset = onset + maxdur - flipTime;
    
    % leave stim on for dur s, then flip grey back on
%     offset = Screen('Flip', mainWindow);
    Screen('Flip', mainWindow);
    
    % relax
    WaitSecs(.25)
    
    
    % this will need to be dynamically set depending on participant's response.
    if ismember(answer,oldans)
        old = true;
        oldresp = true;
    elseif answer == 0
        old = false;
        oldresp = nan;
    else
        old = false;
        oldresp = false;
    end
    %
    %     % return to gray screen
    %     Screen('Flip', mainWindow);
    %
    % if old we enter phase 2 and 3
    if old
        
        %% part 2: (only if not new): how many times?
        % if old, then
        % how many repetitions
        ShowCursor;
        buttonAreas = drawButtons(mainWindow, win_rect);
        % add texture
        Screen('DrawTexture', mainWindow, imagetex,[],topImageRect);
        DrawFormattedText(mainWindow, repkey,'center',topImageRect(4)+40,textColor);
        
        % Flip
        onset = Screen('Flip', mainWindow);
        
        % find the mouse
        [a,b]=WindowCenter(mainWindow);
        SetMouse(a,b,SN);
        
        % show the texture
        % Main mouse tracking loop
        mxold=0;
        myold=0;
        
        notYetClicked = true;
        ShowCursor;
        
        while notYetClicked && GetSecs<= onset + maxrepdur
            % We wait at least 10 ms each loop-iteration so that we
            % don't overload the system in realtime-priority:
            WaitSecs(0.01);
            
            % We only redraw if mouse has been moved:
            [mx, my, buttons]=GetMouse(SN);
            if (mx~=mxold || my~=myold)
                
                % redraw the buttons
                buttonAreas = drawButtons(mainWindow, win_rect);
                % add texture on top
                Screen('DrawTexture', mainWindow, imagetex,[],topImageRect);
                DrawFormattedText(mainWindow, repkey,'center',topImageRect(4)+40,textColor);
                
                % Flip
                Screen('Flip', mainWindow);
                
            end
            mxold=mx;
            myold=my;
            
            % Break out of loop on mouse click
            if find(buttons)
                
                % this stores the button that was clicked
                button_clicked = whichButtonClicked(mx, my, buttonAreas);
                if button_clicked
                    reprt = GetSecs-onset;
                    break;
                else
                  ShowCursor;
                end
            end
        end
        
        % Flip
        Screen('Flip', mainWindow);
        WaitSecs(.25);
        
        clear buttons
        
        
        %% part 3: timeline
        % choose on a timeline when you saw the image
        
        % draw the timeline window
        timelineWindow(mainWindow,timelineArea, sessions, sessionTicks);
        
        % add texture on top
        Screen('DrawTexture', mainWindow, imagetex,[],topImageRect);
        DrawFormattedText(mainWindow, tlkey,'center',topImageRect(4)+40,textColor);
        
        % Flip
        onset = Screen('Flip', mainWindow);
        
        % find the mouse
        [a,b]=WindowCenter(mainWindow);
        SetMouse(a,b,SN);
        
        % show the texture
        % Main mouse tracking loop
        mxold=0;
        myold=0;
        ShowCursor;
        
        notYetClicked = true;
        
        while notYetClicked && GetSecs<= onset + maxtimelinedur
            % We wait at least 10 ms each loop-iteration so that we
            % don't overload the system in realtime-priority:
            WaitSecs(0.01);
            
            % We only redraw if mouse has been moved:
            [mx, my, buttons]=GetMouse(SN);
            if (mx~=mxold || my~=myold)
                
                % scale in y
                ms = timelineArea(4) - my;
                
                % this is the current mouse position
                myrect=[mx-ms my mx+ms+1 my+ms+1]; % center dRect on current mouseposition
                
                dRect = ClipRect(myrect,timelineArea);
                
                
                if ~IsEmptyRect(dRect) && mouseInTimeline(timelineArea, mx, my)
                    
                    % draw the timeline window
                    timelineWindow(mainWindow,timelineArea, sessions, sessionTicks);
                    
                    % add texture on top
                    Screen('DrawTexture', mainWindow, imagetex,[],topImageRect);
                    
                    % add shadowtex on top
                    Screen('DrawTexture', mainWindow, shadowtex,[],myrect);
                    DrawFormattedText(mainWindow, tlkey,'center',topImageRect(4)+40,textColor);
                    
                    
                    % Show result on screen:
                    Screen('Flip', mainWindow);
                end
            end
            mxold=mx;
            myold=my;
            
            % Break out of loop on mouse click
            if find(buttons)
                
                % mx is now the position in x * relative to left of
                % timeline Area
                session_estimate = mx - timelineArea(1);
                
                % my is the level of confidence, expressed in %
                % relative to the size in y of the timeline area
                confidence = (my - timelineArea(2))/ (timelineArea(4)-timelineArea(2));
                
                tlrt = GetSecs - onset;
                break;
            end
        end
        
        % return to gray screen
        Screen('Flip', mainWindow);
    end
    
    prewriteTime = GetSecs;
    
    % collect responses
    params.oldornew(imageI).answer = answer;
    
    % which button did they pick?
    params.howmanytimes(imageI).ntimes = button_clicked;
    
    % output params for 3rd phase;
    params.timeline(imageI).confidence = confidence;
    params.timeline(imageI).session_estimate = session_estimate;
    params.timeline(imageI).mx = mx;
    params.timeline(imageI).my = my;
    
    % temporal position judgement
    
    % store data
    data.params = params;
    
    % write to tsv
    totsv.RECOGBUTTON = answer;
    totsv.RECOGISCORR = oldresp == stimCat(imageI)>0;
    totsv.RECOGRT = rt;
    totsv.REPBUTTON = button_clicked;
    totsv.REPRT = reprt;
    totsv.TLSESSEST = session_estimate;
    totsv.TLCONF = confidence;
    totsv.TLRT = tlrt;
    
%    fid = fopen(outputtsv,'a');
%    for tt = 1:length(tflds)
%        fprintf(fid,sprintf('%d\t',totsv.(tflds{tt})(1)));
%    end
%    fprintf(fid,'\n');
%    fclose(fid);
    valstowrite = [];
    for tt = 1:length(tflds)
        valstowrite(tt) = totsv.(tflds{tt})(1);
    end
    dlmwrite(outputtsv,valstowrite,'delimiter','\t','precision',20,'-append');
    
    % clear the KbQueue before next trial
    KbQueueStop;
    KbQueueFlush;
    
    %  isi
    WaitSecs(isi-(GetSecs-prewriteTime));
    
end


Screen('CloseAll');
fclose('all');

% final save of entire workspace except for stimuli
clear stimCell;
save(outputfile);
