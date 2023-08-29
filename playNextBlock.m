function playNextBlock(handles)

global nc pm %#ok<NUSED>

% [chanIn,chanOut] = getNidaqSettings(handles);


%% Add the listeners for continuous playback/acquisition (for nidaq card)
% if ~isempty(chanOut)
% %     nc.lh = addlistener(nc.s,'DataRequired',@(src,event)presentStimContNidaq_stimGUI(src,event,handles));
%     nc.s.ScansRequiredFcn = @(src,event)presentStimContNidaq_stimGUI(src,event,handles);
% end
% if ~isempty(chanIn)
% %     nc.la = addlistener(nc.s,'DataAvailable',@(src,event)acquireContNidaq_stimGUI(src,event,handles));
%     nc.s.d.ScansAvailableFcn = @(src,event)acquireContNidaq_stimGUI(src,event,handles);
% end
%% connect to soundcard if not connected
if ~isfield(nc,'s')
    fs = str2double(get(handles.samplerate,'String'));
    nc.s = connectToAurora(fs,[],1:8);
end
%% start counters
nc.counter = 1;

%% Get info about what to present
presInfo = prepPresInfo(handles);
nc.firstChunk = 1; % we have to do the first chunk separately to initiate the listener
nc.nBlocks = presInfo.nBlocks;
nc.nChunks = presInfo.nChunks(nc.blockN);
nc.stimFiles = presInfo.stimFiles(presInfo.blocks==nc.blockN);
nc.nFiles = length(nc.stimFiles);
nc.stimDur = presInfo.stimDur{nc.blockN};
nc.preStimSil = presInfo.preStimSil;

% create acquisition file
% if ~isempty(chanIn)
%     contents = cellstr(get(handles.listbox5,'String'));
%     projectSel = contents{get(handles.listbox5,'Value')}; %#ok<NASGU>
%     eval(sprintf('fn = [pm.saveFolder datestr(now,''yymmdd_HHMMSS'') ''_'' pm.mouse ''_'' projectSel ''_block%02d.txt''];',nc.blockN))
%     nc.fid = fopen(fn,'a'); % open file for acquired data
%     if ~exist(fn,'file')
%         set(handles.text35,'String',['File not opened!!!'])
%         keyboard
%     end
%     set(handles.edit7,'String',fn)
% else
%     set(handles.edit7,'String','No acquisition initiated.')
% end

presentStimContSoundcard_stimGUI(handles, presInfo)

%% fill initial buffer
% PsychPortAudio('FillBuffer', nc.s, presInfo.triggerAcquisition,1);
% PsychPortAudio('Start',nc.s,1); % present once
% set(handles.status,'String',sprintf('Presenting block %02d/%02d',nc.blockN,nc.nBlocks));
% 
% clear presInfo