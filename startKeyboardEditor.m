function startKeyboardEditor
%
%   Stefan Slonevskiy
%   2012
%   2014
%
%   Modify iOS UCHR files
%
%   Modified files go to:
%   /System/Library/KeyboardLayouts/USBKeyboardLayouts.bundle/uchrs
%
%   UCHR spec:
%   https://developer.apple.com/library/mac/documentation/Carbon/reference/Unicode_Utilities_Ref/uu_app_uchr/uu_app_uchr.html
%
%   

feature('DefaultCharacterSet','UTF-8');

%% Default values
figWidth    = 950;
figHeight   = 350;


%% Create figure
useFig    = figure( ...
    'Toolbar','none', ...
    'Menubar','none', ...
    'NumberTitle','off', ...
    'DockControls','off', ...
    'Resize','off', ...
    'Name','Keyboard Editor');

setappdata(useFig,'fileIn','');
setappdata(useFig,'KeyToCharTable',[]);
setappdata(useFig,'KeyOutput',[]);

set(useFig,'Color','white');
set(useFig,'Position',[100 100 figWidth figHeight]);

useAx   = axes('Visible','off');
axis([0 figWidth 0 figHeight]);
set(useAx,'Position',[0 0 1 1]);


%% Create menu items
fileMenu(1)     = uimenu('Label','File');

fileMenu(2)     = uimenu(fileMenu(1), ...
    'Label','Load Keyboard');
fileMenu(3)     = uimenu(fileMenu(1), ...
    'Label','Save Keyboard', ...
    'Enable','off');
fileMenu(4)     = uimenu(fileMenu(1), ...
    'Label','Quit', ...
    'Callback',@(e,s)close(useFig),...
    'Separator','on', ...
    'Accelerator','Q');

keyMenu(1)     = uimenu('Label','Keyboard');

keyMenu(2)     = uimenu(keyMenu(1), ...
    'Label','Save Keyboard Layout Picture', ...
    'Callback',@saveImage);

%% Setup menu items' callbacks
set(fileMenu(2),'Callback',{@loadKeyboard,useFig,fileMenu});
set(fileMenu(3),'Callback',{@saveKeyboard,useFig,fileMenu});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadKeyboard(e,s,useFig,fileMenu)
[fileIn,pathIn]     = uigetfile({'*.uchr','Unicode Keyboard File (*.uchr)'}, 'Select a keyboard file to load');
if isequal(fileIn,0),
    return
else
    [KeyToCharTable,KeyOutput] = readUchr(fullfile(pathIn,fileIn));
    
    setappdata(useFig,'fileIn',fullfile(pathIn,fileIn));
    setappdata(useFig,'KeyToCharTable',KeyToCharTable);
    setappdata(useFig,'KeyOutput',KeyOutput);
    
    set(fileMenu(3),'Enable','on');
    drawKeyboard(5,useFig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveKeyboard(e,s,useFig,fileMenu)
[fileOut,pathOut]     = uiputfile({'*.uchr','Unicode Keyboard File (*.uchr)'}, 'Save keyboard file to');
if isequal(fileOut,0),
    return
else

    fileIn          = getappdata(useFig,'fileIn');
    KeyOutput       = getappdata(useFig,'KeyOutput');
    KeyToCharTable  = getappdata(useFig,'KeyToCharTable');

    writeUchr(fileIn,fullfile(pathOut,fileOut),KeyToCharTable,KeyOutput);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveImage(e,s)
[fileOut,pathOut]     = uiputfile({'*.png','PNG Image (*.png)'}, 'Save keyboard layout picture to');
if isequal(fileOut,0),
    return
else
    imgData     = getframe;
    imwrite(imgData.cdata,fullfile(pathOut,fileOut),'png');
end



% fprintf('After done editing, call writeUchr to commit changes to UCHR file.\n');

