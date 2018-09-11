% Function gathers parameters and runs through a playrec output/input cycle
% SUPPORTS MONO ONLY (any channel is fine)
function audioData = mikrec_V5(Fs, devicePlay, deviceRec, chansPlay, chansRec, pageSize, playrecMode, playChanList, recChanList, outputAudio, N_RecSamples)


% Reset the playrec system if it is currently active
if playrec('isInitialised')
    playrec('reset');
end

% Check whether more than 1 channel of output is needed. If it is,
% replicate sweep across all channels
% if length(playChanList)>1 && length(recChanList)>1
%    outputAudio = repmat(outputAudio,[1,chansPlay]);
% end
%chansPlay
%chansRec
% Initialise playrec ready for the current measurement
playrec('init',Fs, devicePlay, deviceRec, chansPlay, chansRec, pageSize);

% Reset missed samples count
playrec('resetSkippedSampleCount');

% Call the actual play/record command to send/get audio data
%size(outputAudio)
%playChanList 
%recChanList
pageNumber = playrec(playrecMode, outputAudio, playChanList, N_RecSamples, recChanList);
%pageNumber = playrec('play', outputAudio, playChanList);

while ~playrec('isFinished', pageNumber)
    missedSamples = playrec('getSkippedSampleCount');
    pause(.2)
end

% Retrieve the audio data from the relevant 'page'
audioData = playrec('getRec', pageNumber);

% Warn user if something went funky
if missedSamples
    fprintf('\n%u samples were missed during playback and recording! Try to change the page size or re-run the playrec setup if this occurs again.\n\n', missedSamples)
else
    fprintf('\nPlayback & recording successfull\n\n')
end
clear rec