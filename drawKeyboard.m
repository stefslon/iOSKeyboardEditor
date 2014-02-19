function drawKeyboard(useTable,useFig)
%
%   drawKeyboard
%

% global KeyOutput
% 
% switch nargin
%     case 0
%         useFig      = 0;
%         useTable    = 5;
%     case 1
%         useFig      = 0;
%         useTable    = varargin{1};
%     otherwise
%         useTable    = varargin{1};
%         useFig      = varargin{2};
% end
        

% Pre-store key position along with their (Apple's) virtual key designation

% keyboardLayout  = [
%     0  1  2  3  4  5  6  7  8  9  10 11 12 13 0  0 ;
%     0  0  14 15 16 17 18 19 20 21 22 23 24 25 26 27;
%     0  0  28 29 30 31 32 33 34 35 36 37 38 39 0  0 ;
%     0  0  0  40 41 42 43 44 45 46 47 48 49 0  0  0 ;
%     0  0  -1 -2 -3 50 50 50 50 50 50 -1 -2 -3 0  0 ];

keyboardLayout  = [
    0  31 32 33 34 35 36 37 38 39 40 46 47 0  0  ;
    0  0  21 27  9 22 24 29 25 13 19 20 48 49 50 ;
    -2 -2  5 23  8 10 11 12 14 15 16 52 53 0  0  ;
    -1 -1 -1 30 28  7 26  6 18 17 55 56 57 -1 -1 ;
    0  0  -9 -3 -8 -4 -4 -4 -4 -4 -4 -8 -3 -7 0  ];
% -1 == Shift
% -2 == Caps Lock
% -3 == Alt
% -4 == Space Bar

statesMapText   = { ...
    'Eng',[1 1 1]; ...
    'Caps Lock',[0 1 0]; ...
    'Alt',[0 0 1]; ...
    'Shift + Alt',[1 0 1]; ...
    'Normal',[0 0 0]; ...
    'Shift',[1 0 0]; ...
    'N/A',[1 1 1] };

keyboardX   = 100;
keyboardY   = 100;

keyDefaultWidth     = 50;
keyDefaultCurve     = 7;
keyDefaultMargin    = 4;
textMargin          = 7;

figWidth    = 950;
figHeight   = 350;

% if useFig==0,
%     % Create new figure
%     useFig  = figure;
%     set(gcf,'Color','white');
%     set(gcf,'Position',[100 100 figWidth figHeight]);
%     
%     axis([0 figWidth 0 figHeight]);
%     axis off;
%     set(gca,'Position',[0 0 1 1]);
% else
%     % Clean existing figure
%     figure(useFig);
%     clf(useFig);
    useAx   = findobj(useFig,'Type','axes');
    cla(useAx);
    h   = findobj('style','pushbutton');
    delete(h);
    
%     axis([0 figWidth 0 figHeight]);
%     axis off;
%     set(gca,'Position',[0 0 1 1]);
% end

KeyOutput   = getappdata(useFig,'KeyOutput');


text(0,figHeight,sprintf(' Table Index %g (%s)',useTable,statesMapText{useTable,1}), ...
    'FontWeight','bold','VerticalAlignment','top');




% Parse through key codes and generate unicode characters
keyValues       = KeyOutput(useTable).UCKeyOutput;
keyIndex        = 1:length(keyValues);

idx             = keyValues==65535;
keyValues(idx)  = ' ';
%keyIndex(idx)   = [];

for ichar=1:length(keyIndex),
    %fprintf('%s --> %s\n', ...
    %    keyIndex(ichar), ...
    %    native2unicode(keyValues(ichar),'Unicode'));
    keyCode     = keyIndex(ichar);
    keyOutput   = typecast(swapbytes(keyValues(ichar)),'uint8');
    keyOutputH  = dec2hex(keyValues(ichar),4);
    %disp(cat(2,int2str(keyCode), ...
    %    ' --> ', ...
    %    native2unicode(keyOutput,'Unicode'), ...
    %    ' (0x',keyOutputH,')'));
    
    %CharTable.(['key_' int2str(keyCode)])   = native2unicode(keyOutput,'Unicode');
    %CharTables{useTable,keyCode}     = native2unicode(keyOutput,'Unicode');
    CharTables(useTable,keyCode)     = native2unicode(keyOutput,'Unicode');
    
end






bigKey  = [];

for irow=1:size(keyboardLayout,1),
    for icol=1:size(keyboardLayout,2),
        currentKey  = keyboardLayout(irow,icol);
        
        % figure out what text to put on the key
        keyBorder       = 2;
        newState        = statesMapText{useTable,2};
        keyCallback     = {@setKey,useFig,useTable,currentKey};
        if currentKey<=0,
            switch currentKey
                case -1
                    keyText     = 'Shift';
                    keyColor    = [0.8 0.8 0.8];
                    if newState(1)==1,
                        keyBorder       = 3;
                    end
                    newState(1)     = ~newState(1);
                case -2
                    keyText     = 'Caps Lock';
                    keyColor    = [0.8 0.8 0.8];
                    if newState(2)==1,
                        keyBorder       = 3;
                        capsPressed     = true;
                    end
                    newState(2)     = ~newState(2);
                case -3
                    keyText     = 'Alt';
                    keyColor    = [0.8 0.8 0.8];
                    if newState(3)==1,
                        keyBorder       = 3;
                        altPressed      = true;
                    end
                    newState(3)     = ~newState(3);
                case -4
                    keyText     = 'Space';
                    keyColor    = [0.6 0.6 0.6];
                otherwise
                    keyText     = '';
                    keyColor    = [0.6 0.6 0.6];
            end
            % find table index based on the state
            newTableIdx     = find(ismember(cat(1,statesMapText{:,2}),newState,'rows'));
            if ~isempty(newTableIdx),
                keyCallback = {@setKeyboard,useFig,newTableIdx};
            end
        else
            %keyText     = cat(2,int2str(currentKey),'. ',CharTables(useTable,currentKey));
            keyText     = CharTables(useTable,currentKey);
            keyColor    = 'w';
        end
        
        % figure out where to draw the key
        keyX    = (icol-1)*keyDefaultWidth + keyboardX;
        keyY    = figHeight - keyboardY - (irow-1)*keyDefaultWidth;
        
        if icol+1<=size(keyboardLayout,2) && ...
                keyboardLayout(irow,icol+1)==currentKey,
            if isempty(bigKey),
                bigKey      = [keyX keyY 2];
            else
                bigKey(3)   = bigKey(3)+1;
            end
        else
            if ~isempty(bigKey),
                % we have a big key going that needs to rendered here
                keyX        = bigKey(1);
                keyY        = bigKey(2);
                keyWidth    = bigKey(3)*keyDefaultWidth;
                keyHeight   = keyDefaultWidth;
                
                % reset big key flag
                bigKey      = [];
            else
                keyWidth    = keyDefaultWidth;
                keyHeight   = keyDefaultWidth;
            end
            
            % draw the key
            newKeyWidth     = keyWidth-keyDefaultMargin;
            newKeyHeight    = keyHeight-keyDefaultMargin;
            rectangle('Position',[keyX keyY newKeyWidth newKeyHeight],...
                'Curvature',[keyDefaultCurve/newKeyWidth keyDefaultCurve/newKeyHeight],...
                'LineWidth',keyBorder,'FaceColor',keyColor);
            
            hBtn    = uicontrol('Style','pushbutton', 'String', keyText, ...
                'Units','Pixels', ...
                'Position', ...
                [keyX+textMargin keyY+textMargin keyWidth-2*textMargin keyHeight-2*textMargin], ...
                'FontName','Arial Unicode MS', 'FontSize', 8, ...
                'BackgroundColor',keyColor,'HorizontalAlignment','left', ...
                'Callback',keyCallback);
            
        end
        
    end
end


% return;
% 
% 
% figure;
% 
% 
% % Create table layout picture
% numTotal    = size(CharTables,2);
% numPerCol   = 10;%floor(sqrt(numTotal));
% numTables   = size(CharTables,1);
% tblOffset   = ceil(sqrt(numTables));
% 
% 
% for itbl=1:numTables,
% 
%     all_x   = (mod((0:numTotal-1),numPerCol)*1.4 + mod(itbl-1,tblOffset)/tblOffset)*600/numPerCol;
%     all_y   = (floor((0:numTotal-1)/numPerCol)*1.4 + floor((itbl-1)/tblOffset)/tblOffset)*500/numPerCol;
%     %text(all_x,all_y,cellstr(CharTables(itbl,:).'),'FontSize',8);
%     
%     for ichr=1:numTotal,
%         if ~isempty(deblank(CharTables(itbl,ichr))),
%             uicontrol('Style','text', 'String', CharTables(itbl,ichr), ...
%                 'Units','Pixels','Position',[all_x(ichr) all_y(ichr) 15 15], ...
%                 'FontName','Arial Unicode MS', 'FontSize', 8)
%         end
%     end
%     
% end
% set(gca,'XLim',[-0.5 numPerCol+0.5]);
% set(gca,'YLim',[-0.5 numPerCol+0.5]);
% set(gca,'YDir','Reverse');
% 
% axis off
% 
% % dispTable   = '';
% % for itbl=1:numTables,
% %     all_x   = (mod((0:numTotal-1),numPerCol)*5 + mod(itbl-1,tblOffset))+1;
% %     all_y   = (floor((0:numTotal-1)/numPerCol)*5 + floor((itbl-1)/tblOffset))+1;
% %     for ichr=1:numTotal,
% %         if ~isempty(deblank(CharTables(itbl,ichr))),
% %             dispTable(all_x(ichr),all_y(ichr))  = deblank(CharTables(itbl,ichr));
% %         end
% %     end
% % end





