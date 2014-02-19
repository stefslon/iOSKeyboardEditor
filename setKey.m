function setKey(src,eventdata,fig,itable,ikey)
% disp('Clicked');
% global KeyOutput
KeyOutput   = getappdata(fig,'KeyOutput');
newChar     = inputdlg('New character:');
% ISSUE: check that cancel was not pressed
KeyOutput(itable).UCKeyOutput(ikey)     = newChar{1};
setappdata(fig,'KeyOutput',KeyOutput);

drawKeyboard(itable,fig);
