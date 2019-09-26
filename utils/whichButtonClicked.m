function button_pressed = whichButtonClicked(mx, my, buttonAreas)

button_pressed = 0;
for button = 1:4
    if mx >= buttonAreas(1, button) ...         % left of button
                && my >= buttonAreas(2, button) ... % top of button
                && mx <= buttonAreas(3, button) ... % right of button
                && my <= buttonAreas(4, button)     % bottom of button

        % we found a button click!
        button_pressed = button;
        break;    
    end
end