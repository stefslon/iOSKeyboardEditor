function out_struct = readStuct(fileName,in_struct,start_offset)
%
%
%
%

out_struct  = in_struct;
fieldNames  = fieldnames(out_struct);

if ischar(fileName),
    fid     = fopen(fileName,'r');
else
    fid     = fileName;
end

if fid<1,
    error('Error reading file');
    return
end

if exist('start_offset','var') && ~isempty(start_offset),
    fseek(fid,start_offset,'bof');
end

for ifield=1:length(fieldNames),
    if ~isstruct(out_struct.(fieldNames{ifield})),
        fieldType   = class(out_struct.(fieldNames{ifield}));
        numFields   = size(out_struct.(fieldNames{ifield}));
        readVar     = fread(fid,numFields,fieldType);
        out_struct.(fieldNames{ifield})     = cast(readVar,fieldType);
    else
        out_struct.(fieldNames{ifield})     = readStuct(fid,out_struct.(fieldNames{ifield}));
    end
end

if ischar(fileName),
    fclose(fid);
end


% % Read header first
% headerForm      = fread(fid,1,'uint16');
% resVersion      = fread(fid,1,'uint16');
% offsetLayout    = fread(fid,1,'uint32');
% countHeaders    = fread(fid,1,'uint32');
% 
% keyFirst    = fread(fid,1,'uint32');
% keyLast     = fread(fid,1,'uint32');