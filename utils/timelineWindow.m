function timelineWindow(mainWindow,timelineArea, months, monthTicks)


% Draw the square to the screen. For information on the command used in
% this line see Screen FillRect?
Screen('FillRect', mainWindow, 255, timelineArea);

nmonths = length(months);

% Draw the month ticks
for monthI= 1:nmonths

    % draw the tick line
    Screen('DrawLine', mainWindow, 0, monthTicks(monthI), timelineArea(4)-10, monthTicks(monthI), timelineArea(4), 2);

    % draw the month's text label
    DrawFormattedText2(months{monthI}, 'win',mainWindow,...
        'sx', monthTicks(monthI),...
        'sy', timelineArea(4)+10,...
        'xalign','center',...
        'yalign','center',...
        'baseColor',[255 255 255]);
end
