function instructions = defineInstructions
% overview instructions
instructions{1} = ['Welcome to the post-scanning memory task!', ...
'\n\nIn this session, you will see approximately 300 images in 5 blocks (you will get 4 breaks).', ...
'\nPlease try your best to be as accurate as possible. Your data will be extremely helpful!', ...
'\nIn this task, you will be presented with a series of images, MOST of which you saw in the scanner and SOME of which are new.',...
'\n\nFor each image, you will first be asked to indicate whether or not you saw it along with your confidence.',...
'\nFor the images you saw, you will also be asked to indicate how many times you saw it and approximately when (in which session).'];
% instructions for phase 1
instructions{2} = ['First, you will see an image in the center of the screen.', ...
'\nYour task is indicate whether you have seen the image before, as you did in the scan sessions.', ...
'\nImportantly, this time you will also indicate your confidence.', ...
'\nFor this question, you will use the number keys. Try make your response as quickly and accurately as you can.', ...
'\n\nPress 1 if you have high confidence you have not seen it before. [High New]',...
'\n\nPress 2 if you have medium confidence you have not seen it before. [Med New]',...
'\n\nPress 3 if you have low confidence you have not seen it before. [Low New]',...
'\n\nPress 4 if you have low confidence you have seen it before. [Low Old]',...
'\n\nPress 5 if you have medium confidence you have seen it before. [Med Old]',...
'\n\nPress 6 if you have high confidence you have seen it before. [High Old]',...
];
% instructions for phase 2
instructions{3} = ['If you indicate that you have seen the image before, you will next be asked to indicate how many times you saw it.', ...
'\nIf you are unsure, just make your best guess. For this question, you will use the mouse.', ...
'\n\nClick 1 if you have seen it once.', ...
'\n\nClick 2 if you have seen it twice.', ...
'\n\nClick 3 if you have seen it three times.', ...
'\n\nClick 4+ if you have seen it four or more times.'];
% instructions for phase 3
instructions{4} = ['Lastly, you will be asked to indicate when you saw the image for the FIRST time.', ...
'\nYou will see a timeline organized by session where the highest number on the right is the last scan session you completed.', ...
'\nYour task will be to indicate which session you saw it in FIRST. If you only saw it once, just indicate that session.', ...
'\nTo make your selection, you will use the mouse to move a cone along the timeline.', ...
'\nThe center of the cone should reflect your best guess of the first session you saw it.', ...
'\nThe width of the cone should reflect your uncertainty. The narrower the width, the more confident you should be in your selection.', ...
'\nTo increase your uncertainty, you can move the mouse up so that the width of the cone increases.', ...
'\nTo decrease your uncertainty, you can move the mouse down so that the width of the cone shrinks.', ...
'\nNote, it is fine if the cone extends slightly beyond the boundaries of the timeline.', ...
'\nOnce you have placed the cone on your best guess along the timeline, click the mouse to select that location.', ...
'\nEven if you are unsure, it is very important that you try to respond with your best guess.', ...
'\nAfter you make this response, the task will move on to the next image.'];
% display the right instructions according to the phase 
