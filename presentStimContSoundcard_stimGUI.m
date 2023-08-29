function presentStimContSoundcard_stimGUI(handles, presInfo)

global nc pm

fs = presInfo.fs;

%% Use psychportaudio scheduling to buffer whole stimulus

% Turn on use schedule
PsychPortAudio('UseSchedule', nc.s, 1);

% get audio
audiodata = presInfo.triggerAcquisition(:,1:fs);

% create buffer with 1 second of audio data
buffer = PsychPortAudio('CreateBuffer', nc.s, audiodata);

% Fill playbuffer with content of buffer:
PsychPortAudio('AddToSchedule', nc.s, buffer);

% Start playback in 2 seconds from now, 2 repetitions, wait for start:
PsychPortAudio('Start', nc.s);

nc.counter = nc.counter + 1;

%% Present the pres stimulus silence
for ii = 2:presInfo.triggerChunks % we skip the first second of data since these are used to create the buffers

    % load in 1 second of audiodata
    audiodata = presInfo.triggerAcquisition(:,(fs*(ii-1))+1:(fs*ii));

    % create buffer with audio data
    buffer = PsychPortAudio('CreateBuffer', nc.s, audiodata);

    % Fill playbuffer with content of buffer:
    PsychPortAudio('AddToSchedule', nc.s, buffer);

    nc.counter = nc.counter + 1;
end

%% Present the stim files
blockFiles = presInfo.stimFiles(presInfo.blocks==nc.blockN);
dur = zeros(length(blockFiles),1);
for jj = 1:length(blockFiles)
    info = audioinfo(blockFiles{jj});
    dur(jj) = info.TotalSamples/fs;
end


for ii = 1:length(blockFiles)

    for jj = 1:ceil(dur(ii))
        audiodata = audioread(blockFiles{ii},...
            [((jj-1)*fs + 1), jj*fs]); % read in 1 second chunks

        % create buffer with audio data
        buffer = PsychPortAudio('CreateBuffer', nc.s, audiodata');

        % % Streaming refill with content of buffer. Append the content to the
        % % currently playing sound stream:
        % PsychPortAudio('FillBuffer', nc.s, buffer, 1);

        % Fill playbuffer with content of buffer:
        PsychPortAudio('AddToSchedule', nc.s, buffer);

        nc.counter = nc.counter + 1;
    end

end


%% wrap up this block
status = PsychPortAudio('GetStatus', nc.s);
while status.Active==1
    status = PsychPortAudio('GetStatus', nc.s);
end
disp('FINISHED PRESENTING')

% save everything
exptInfo.mouse = nc.mouse;
exptInfo.stimFiles = nc.stimFiles;
b = unique(exptInfo.stimFiles);
for ii = 1:length(b)
    try
        a = load([b{ii}(1:end-4) '_stimInfo.mat']);
        exptInfo.stimInfo{ii} = a; %.stimInfo;
    catch
        exptInfo.stimInfo{ii} = 'Could not find stimInfo';
    end
end
exptInfo.preStimSilence = nc.preStimSil;
exptInfo.fsStim = fs;
exptInfo.presParams = nc;
exptInfo.presDirs = pm;
if isfield(pm,'saveFolder')
    fn = strcat(pm.saveFolder,string(datetime('now'),'yyyyMMdd_HHmmss'), '_exptInfo.mat');
    save(fn,'exptInfo');
else
    warning('WARNING: no save folder specified, saving in default location: _M001\n');
    fn = strcat('D:\data\',pm.mouse,'\',string(datetime('now'),'yyyyMMdd_HHmmss'), '_exptInfo.mat');
end
set(handles.status,'String',['Block ' num2str(nc.blockN) ' of ' num2str(nc.nBlocks) ' saved'])
nc.blockN = nc.blockN+1;

%% NOW ADD IN A NEW FUNCTION, 'PLAYNEXTBLOCK'
if nc.blockN <= nc.nBlocks
    disp('Press enter to start the next block...');
    pause();
    playNextBlock(handles);
end



