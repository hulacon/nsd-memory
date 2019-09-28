function timelineWindow(mainWindow,timelineArea, sessions, sessionTicks)


% Draw the square to the screen. For information on the command used in
% this line see Screen('FillRect?')
Screen('FillRect', mainWindow, 240, timelineArea);

nsessions = length(sessions);

% Draw the month ticks
for sessionI= 1:nsessions

    % draw the tick line
    Screen('DrawLine', mainWindow, 0, sessionTicks(sessionI), timelineArea(4)-10, sessionTicks(sessionI), timelineArea(4), 2);

    % draw the month's text label
    DrawFormattedText2(num2str(sessions(sessionI)), 'win',mainWindow,...
        'sx', sessionTicks(sessionI),...
        'sy', timelineArea(4)+10,...
        'xalign','center',...
        'yalign','center',...
        'baseColor',[255 255 255]);
end
