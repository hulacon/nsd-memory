
%% get info about subject (check to see what is needed for this)


%% add utils functions
addpath('utils')

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

[mainWindow, win_rect] = Screen(SN,'OpenWindow',backColor,screenRect,32);

flipTime = Screen('GetFlipInterval',mainWindow);
Screen(mainWindow, 'TextFont', 'Arial');
Screen(mainWindow, 'TextSize', 18);
imgDim = 425; % assume 425x425 images
halfSize = imgDim/2; %
imageRect = [0,0,imgDim,imgDim];
centerImageRect = CenterRect(imageRect,screenRect);

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

months = {'January','February','March','April','May','June','July','August','September','October'};
nmonths = length(months);

% find location for x ticks
timelineXlims = [timelineArea(1)+.15*screenX timelineArea(3)-.15*screenX];
monthTicks = linspace(timelineArea(1), timelineArea(3), nmonths+2);
monthTicks = monthTicks(2:end-1);

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


% trial loop

for imageI = 1:nimages
    
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
    
    
    
    % confidence rating
    
    WaitSecs(1)
    
    % do your response collection
    
    % this will need to be dynamically set depending on participant's response.
    old = true;
    
    
    % return to gray screen
    Screen('Flip', mainWindow);
    
    
    if old

        %% part 2: (only if not new): how many times?
        % if old, then
        % how many repetitions
        
        buttonAreas = drawButtons(mainWindow, win_rect);
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
        
        while notYetClicked
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
        timelineWindow(mainWindow,timelineArea, months, monthTicks); 
        
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
        
        while notYetClicked
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
                
                
                if ~IsEmptyRect(dRect)
                    
                    % draw the timeline window
                    timelineWindow(mainWindow,timelineArea, months, monthTicks); 

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
                break;
            end
        end

        
        
        WaitSecs(5)
        
        % return to gray screen
    	Screen('Flip', mainWindow); 
    end
     
    
    
    % temporal position judgement
    
    % save data

end   
Screen('CloseAll');
fclose('all');

