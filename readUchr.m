function [KeyToCharTable,KeyOutput] = readUchr(FILE_IN)




% struct UCKeyboardTypeHeader {
%    UInt32 keyboardTypeFirst;
%    UInt32 keyboardTypeLast;
%    ByteOffset keyModifiersToTableNumOffset;
%    ByteOffset keyToCharTableIndexOffset;
%    ByteOffset keyStateRecordsIndexOffset;
%    ByteOffset keyStateTerminatorsOffset;
%    ByteOffset keySequenceDataIndexOffset;
% };
UCKeyboardTypeHeader.keyboardTypeFirst              = uint32(1);
UCKeyboardTypeHeader.keyboardTypeLast               = uint32(1);
UCKeyboardTypeHeader.keyModifiersToTableNumOffset   = uint32(1);
UCKeyboardTypeHeader.keyToCharTableIndexOffset      = uint32(1);
UCKeyboardTypeHeader.keyStateRecordsIndexOffset     = uint32(1);
UCKeyboardTypeHeader.keyStateTerminatorsOffset      = uint32(1);
UCKeyboardTypeHeader.keySequenceDataIndexOffset     = uint32(1);

% struct UCKeyLayoutFeatureInfo {
%    UInt16 keyLayoutFeatureInfoFormat;
%    UInt16 reserved;
%    UniCharCount maxOutputStringLength;
% };
UCKeyLayoutFeatureInfo.keyLayoutFeatureInfoFormat   = uint16(1);
UCKeyLayoutFeatureInfo.reserved                     = uint16(1);
UCKeyLayoutFeatureInfo.UniCharCount                 = uint32(1);

% struct UCKeyboardLayout {
%    UInt16 keyLayoutHeaderFormat;
%    UInt16 keyLayoutDataVersion;
%    ByteOffset keyLayoutFeatureInfoOffset;
%    ItemCount keyboardTypeCount;
%    UCKeyboardTypeHeader keyboardTypeList[1];
% };
UCKeyboardLayout.keyLayoutHeaderFormat      = uint16(1);
UCKeyboardLayout.keyLayoutDataVersion       = uint16(1);
UCKeyboardLayout.keyLayoutFeatureInfoOffset = uint32(1);
UCKeyboardLayout.keyboardTypeCount          = uint32(1);
UCKeyboardLayout.UCKeyboardTypeHeader       = UCKeyboardTypeHeader;
UCKeyboardLayout.UCKeyLayoutFeatureInfo     = UCKeyLayoutFeatureInfo;

% struct UCKeyModifiersToTableNum {
%    UInt16 keyModifiersToTableNumFormat;
%    UInt16 defaultTableNum;
%    ItemCount modifiersCount;
%    UInt8 tableNum[1];
% };
UCKeyModifiersToTableNum.keyModifiersToTableNumFormat   = uint16(1);
UCKeyModifiersToTableNum.defaultTableNum                = uint16(1);
UCKeyModifiersToTableNum.modifiersCount                 = uint32(1);
UCKeyModifiersToTableNum.tableNum                       = uint8(1);

% struct UCKeyToCharTableIndex {
%    UInt16 keyToCharTableIndexFormat;
%    UInt16 keyToCharTableSize;
%    ItemCount keyToCharTableCount;
%    ByteOffset keyToCharTableOffsets[1];
% };
% typedef struct UCKeyToCharTableIndex UCKeyToCharTableIndex;
UCKeyToCharTableIndex.keyToCharTableIndexFormat     = uint16(1);
UCKeyToCharTableIndex.keyToCharTableSize            = uint16(1);
UCKeyToCharTableIndex.keyToCharTableCount           = uint32(1);
UCKeyToCharTableIndex.keyToCharTableOffsets         = uint32(1);

% typedef UInt16 UCKeyOutput;
UCKeyOutput.UCKeyOutput     = uint16(1);



% FILE_IN     = 'RussianPhonetic.uchr';

% FILE    = 'EnglishStd.uchr';
% FILE    = 'Layout.rsrc';

UCKeyboardLayout    = readStuct(FILE_IN,UCKeyboardLayout,[]);

KeyModTable         = readStuct(FILE_IN, ...
    UCKeyModifiersToTableNum, ...
    UCKeyboardLayout.UCKeyboardTypeHeader.keyModifiersToTableNumOffset);
UCKeyModifiersToTableNum.tableNum   = repmat(UCKeyModifiersToTableNum.tableNum,1,KeyModTable.modifiersCount);
KeyModTable         = readStuct(FILE_IN, ...
    UCKeyModifiersToTableNum, ...
    UCKeyboardLayout.UCKeyboardTypeHeader.keyModifiersToTableNumOffset);

% Re-read, but this time get the right number of offsets
KeyToCharTable      = readStuct(FILE_IN,UCKeyToCharTableIndex,UCKeyboardLayout.UCKeyboardTypeHeader.keyToCharTableIndexOffset);
UCKeyToCharTableIndex.keyToCharTableOffsets     = repmat(UCKeyToCharTableIndex.keyToCharTableOffsets,1,KeyToCharTable.keyToCharTableCount);
KeyToCharTable      = readStuct(FILE_IN,UCKeyToCharTableIndex,UCKeyboardLayout.UCKeyboardTypeHeader.keyToCharTableIndexOffset);


% return


% global KeyOutput
clear KeyOutputT


UCKeyOutput.UCKeyOutput     = repmat(UCKeyOutput.UCKeyOutput,1,KeyToCharTable.keyToCharTableSize);
for itable=1:length(KeyToCharTable.keyToCharTableOffsets),
    % if itable-1 == KeyModTable.defaultTableNum,
    %     extraString     = ' (DEFAULT TABLE)';
    % else
    %     extraString     = '';
    % end
    % 
    % fprintf('--------------------------------------------------------------\n');
    % fprintf('Table %g%s\n',itable,extraString);
    % fprintf('--------------------------------------------------------------\n');

    KeyOutputT(itable)   = readStuct(FILE_IN,UCKeyOutput,KeyToCharTable.keyToCharTableOffsets(itable));
end
KeyOutput   = KeyOutputT;

% drawKeyboard;


% KeyOutput is what needs to be updated


