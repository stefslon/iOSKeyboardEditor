function writeUchr(FILE_IN,FILE_OUT,KeyToCharTable,KeyOutput)
%
%
%
%   Commit changes back to UCHR file
%
%
%

% FILE_OUT    = 'RussianPhonetic2.uchr';

% Create a copy of an input file
copyfile(FILE_IN,FILE_OUT);

% Open copied file and start patching with new Unicode codes
fid     = fopen(FILE_OUT,'r+');

if fid<0,
    error('Could not open output UCHR file.');
end

for itable=1:length(KeyToCharTable.keyToCharTableOffsets),
    % KeyOutputT(itable)   = 
    %  readStuct(FILE_IN,UCKeyOutput,KeyToCharTable.keyToCharTableOffsets(itable));
    fseek(fid,KeyToCharTable.keyToCharTableOffsets(itable),'bof');
    fwrite(fid,KeyOutput(itable).UCKeyOutput,class(KeyOutput(itable).UCKeyOutput));
end

fclose(fid);
