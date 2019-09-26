function [buttonAreas, button_width, button_height] = drawButtons(mainWindow, win_rect, nButtons)

% draw the buttons and return their coordinates.
% these coordinates will be used later to test whether a click
% has been made on the button, and which button it is. 
% ic 2019

% default 4 buttons
if nargin==2
    nButtons = 4;
end

% buttonwidth 
total_width = win_rect(3); % dimension of the screen in x
button_width = .25*(total_width/nButtons); %we want the button to take half the space of a nButton'th of the screen

% where do we position the buttons?
button_xStart = linspace(0, total_width, nButtons+2);
% relax
button_xStart = button_xStart(2:end-1);

% nice rectangle buttons
button_height = button_width/2;

% where do we position the buttons?
total_height = win_rect(4);
button_yStart = (total_height/2) + button_height;

%{
Instead of filling one rectangle, you can also specify a list of multiple
rectangles to be filled - this is much faster when you need to draw many
rectangles per frame. To fill n rectangles, provide "rect" as a 4 rows by n
columns matrix, each column specifying one rectangle, e.g., rect(1,5)=left
border of 5th rectange, rect(2,5)=top border of 5th rectangle, rect(3,5)=right
border of 5th rectangle, rect(4,5)=bottom border of 5th rectangle. If the
rectangles should have different colors, then provide "color" as a 3 or 4 row by
n column matrix, the i'th column specifiying the color of the i'th rectangle. 
%}

colors = [0 0 255;
    0 255 0;
    255 0 0;
    0 255 255]';

buttonAreas = zeros(nButtons,4);
for button = 1:nButtons
buttonAreas(1, button) = button_xStart(button) - button_width/2; % left of button
buttonAreas(2, button) = button_yStart - button_height/2;        % top of button
buttonAreas(3, button) = button_xStart(button) + button_width/2; % right of button
buttonAreas(4, button) = button_yStart + button_height/2;        % bottom of button
end

% Draw the square to the screen. For information on the command used in
% this line see Screen FillRect?
    
Screen('FillRect', mainWindow, colors, buttonAreas);
    
% Draw the button labels
for button= 1:nButtons
    % draw the button's text label
    if button<nButtons
        DrawFormattedText2(num2str(button), 'win',mainWindow,...
            'sx', buttonAreas(1, button) + button_width/2,...
            'sy', buttonAreas(2, button) + button_height/2,...
            'xalign','center',...
            'yalign','center',...
            'baseColor',[255 255 255]);
    else
        DrawFormattedText2(sprintf('%d +', button), 'win',mainWindow,...
            'sx', buttonAreas(1, button) + button_width/2,...
            'sy', buttonAreas(2, button) + button_height/2,...
            'xalign','center',...
            'yalign','center',...
            'baseColor',[255 255 255]);
    end        
end
