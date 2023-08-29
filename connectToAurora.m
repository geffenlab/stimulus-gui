function s = connectToAurora(fs,channelsIn,channelsOut)


deviceT = 'Speakers (2- Lynx LT-TB3)';

devList = PsychPortAudio('GetDevices');
windowsDSIdx = find(cell2mat(cellfun(@(X)contains(X,'WASAPI'),{devList(:).HostAudioAPIName},'UniformOutput',false)));
playbackIdx = find(cell2mat(cellfun(@(X)contains(X,deviceT),{devList(:).DeviceName},'UniformOutput',false)));
playbackIdx = intersect(playbackIdx,windowsDSIdx);

if ~isempty(channelsOut) && isempty(channelsIn)
s = PsychPortAudio('Open', devList(playbackIdx).DeviceIndex,...
    1,... % mode: 1 (sound playback only)
    3,... % 3 might have caused problems... reqlatencyclass: 1... how aggressive to lower latency
    fs,... % freq: fs
    length(channelsOut),... % channels: 4
    [],... % buffersize: default
    [],... % suggestedLatency: default
    channelsOut); % selectchannels
status = PsychPortAudio('GetStatus', s);
realFS = status.SampleRate;

elseif ~isempty(channelsOut) && ~isempty(channelsIn)

end

if realFS~=fs
    disp('Sample rate of soundcard is not as requested')
end