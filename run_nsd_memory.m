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


%% add utils functions
addpath('utils')

% set up specific subject info

output_dir = fullfile('results','subj-01');
if not(exist(output_dir,'dir'))
    mkdir(output_dir)
end
% set up parameters (display, etc)
outputfile = fullfile(output_dir,'results.mat');
=======

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

[mainWindow, win_rect] = Screen(SN,'OpenWindow',backColor,screenRect,32);

Screen(mainWindow, 'TextFont', 'Arial');
Screen(mainWindow, 'TextSize', 18);
imgDim = 425; % assume 425x425 images
imageRect = [0,0,imgDim,imgDim];
centerImageRect = CenterRect(imageRect,screenRect);

dur = 3;
isi = 4;

% load in images
nimages = 1 ;
imagedata(1).image = imresize(imread(fullfile('stimuli', 'banana.png')),[imgDim, imgDim]);


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
rectColor = [0 0 0];        
% Center the rectangle on the centre of the screen using fractional pixel
% values.
% For help see: CenterRectOnPointd
timelineArea = CenterRectOnPointd(timelineRect, centerX, centerY);
timelineArea = timelineArea + [0 .16*screenY 0 .16*screenY];

% let's save timelineArea coordinates;
params.timelineArea = timelineArea;        
        
% this next line needs to be discovered from the latest behaviour file. 
sessions = 1:35;
%months = {'January','February','March','April','May','June','July','August','September','October'};
nsessions= length(sessions);

% find location for x ticks
timelineXlims = [timelineArea(1)+.15*screenX timelineArea(3)-.15*screenX];
sessionTicks = linspace(timelineArea(1), timelineArea(3), nsessions+2);
sessionTicks = sessionTicks(2:end-1);

% load in shadow (used in timeline)
[shadowdata, ~, alpha]= imread(fullfile('utils', 'shadow.png'));
shadowdata(:, :, 4) = alpha;

shadowtex = Screen('MakeTexture', mainWindow, shadowdata);
ms_buttons=100;

% setup the alpha blending
Screen(mainWindow,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% response keys for the seen before confidence response
code1 = KbName('1!'); % 1
code2 = KbName('2@'); % 2
code3 = KbName('3#'); % 3
code4 = KbName('4$'); % 2
code5 = KbName('5%'); % 2
code6 = KbName('6^'); % 2

% define the keys we want
keys = zeros(1,256);
keys(code1)=1;
keys(code2)=1;
keys(code3)=1;
keys(code4)=1;
keys(code5)=1;
keys(code6)=1;


%% LOOPING THROUGH TRIALS
% create a queue for monitoring events.
KbQueueCreate(-1,keys);

instructions = defineInstructions();


% add code to present instructions;
=======
%% load in images
stimIDVec = select_stimuli(resp);
numStim = length(stimIDVec);
stimCell = cell(numStim,1);
stim
for ii = 1:numStim
    stimCell{ii} = permute(h5read(stimFilepath,'/imgBrick',[1 1 1 ii],[3 425 425 1]),[3 2 1]);
end



%% trial loop

for imageI = 1:nimages
    
    button_clicked = NaN;
    confidence = NaN;
    session_estimate = NaN;
    answer = 0;
    responded = 0;
    
    % define that image's texture
    imagetex = Screen('MakeTexture', mainWindow, imagedata(imageI).image);
    
    %% part 1: old (responses from 1 to 6) or new
    
    % initiate the kb listener
    % start the keyboard reading queue
    KbQueueStart; % start the queue
    queuestart = GetSecs; % time stamp when the queue starts 
    
    
    % draw the image    
    Screen('DrawTexture', mainWindow, imagetex,[],centerImageRect);
    onset = Screen('Flip', mainWindow);
    
    requested_offset = onset + dur - flipTime;
    
    % leave stim on for dur s, then flip grey back on
    offset = Screen('Flip', mainWindow, requested_offset - flipTime/2);
    
    % do your response collection
    % handle isi and self paced response
    while GetSecs - onset <= isi - 2 * flipTime && not(responded)
        % check for answer this will make it self paced.
        [pressed, firstPress] = KbQueueCheck;
        % if the subject answers during this delay, we get straight to
        % the feedback
        if pressed
            responded = 1;
            pressedCodes = find(firstPress);
            if pressedCodes(1)==code1
                answer = 1; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code2
                answer = 2; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code3
                answer = 3; % 
            elseif pressedCodes(1)==code4                
                answer = 4; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code5
                answer = 5; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code6
                answer = 6; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            end
            % break out
            if answer
                % go back to grey
                Screen('Flip', mainWindow);
                break;
            end
        end
    end
    
    % one more second to respond       
    % if response didn't come during gap check one last time
    if not(responded)
        % check for answer
        [pressed, firstPress] = KbQueueCheck;
        if pressed
            pressedCodes = find(firstPress);
            if pressedCodes(1)==code1
                answer = 1; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code2
                answer = 2; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code3
                answer = 3; % 
            elseif pressedCodes(1)==code4                
                answer = 4; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code5
                answer = 5; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            elseif pressedCodes(1)==code6
                answer = 6; % 
                rt = firstPress(pressedCodes) - queuestart; % this rt is now relative to queue start, not stimonset
            end
        end
    end
    
    % relax    
    WaitSecs(.25)
        
    
    % this will need to be dynamically set depending on participant's response.
    if answer<4
        old = true;
    else
        old = false;
    end
        
    % return to gray screen
    Screen('Flip', mainWindow);
    
    % if old we enter phase 2 and 3
    if old

        %% part 2: (only if not new): how many times?
        % if old, then
        % how many repetitions
        
        buttonAreas = drawButtons(mainWindow, win_rect);
        % add texture on top
        Screen('DrawTexture', mainWindow, imagetex,[],topImageRect);
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
        
        while notYetClicked && GetSecs<= onset + isi - 2 * flipTime
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
                    break;
                end
            end
        end
        
        % Flip
        Screen('Flip', mainWindow);
        WaitSecs(1);
        
        clear buttons
        
        
        %% part 3: timeline
        % choose on a timeline when you saw the image
        
        % draw the timeline window
        timelineWindow(mainWindow,timelineArea, sessions, sessionTicks); 
        
        % add texture on top
        Screen('DrawTexture', mainWindow, imagetex,[],topImageRect);       
        
        % Flip
        Screen('Flip', mainWindow);
                
        % find the mouse
        [a,b]=WindowCenter(mainWindow);
        SetMouse(a,b,SN);
        
        % show the texture 
        % Main mouse tracking loop
        mxold=0;
        myold=0;
        
        notYetClicked = true;
        
        while notYetClicked && GetSecs<= onset + 4*isi - 2 * flipTime
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
                
                break;
            end
        end
        
        
        
        % which button did they pick?
        params.nrepeats(imageI) = button_clicked;
        
        % output params for 3rd phase;
        params.timeline(imageI).confidence = confidence;
        params.timeline(imageI).session_estimate = session_estimate;
        params.timeline(imageI).mx = mx;
        params.timeline(imageI).my = my;
        
        
        WaitSecs(5)
        
        % return to gray screen
    	Screen('Flip', mainWindow); 
    end
     
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
    
    % save data

end   
Screen('CloseAll');
fclose('all');

save(outputfile, 'params');

