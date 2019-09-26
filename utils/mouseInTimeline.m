function inside = mouseInTimeline(timelineArea, mx, my)

if mx >= timelineArea(1) ...         % left of button
        && my >= timelineArea(2) ... % top of button
        && mx <= timelineArea(3) ... % right of button
        && my <= timelineArea(4)     % bottom of button
    
    % the mouse in inside the timeline
    % draw the cone.
    inside = 1;
else
    % the mouse is outside the timeline
    % don't draw the cone.
    inside = 0;
end