%-------------------------------------------------------------------------%
% MikRIR_04_Acquire_Fn__V5.m
%-------------------------------------------------------------------------%
%
%
%
%-------------------------------------------------------------------------%
function [RIR_metadata,RIR_params,RIR_data] = MikRIR_04_Acquire_Fn__V5(RIR_metadata,RIR_params,RIR_data)

%-------------------------------------------------------------------------$
% Input signal setup
%-------------------------------------------------------------------------$
% Number of samples to record (make sure to include ring down)
if RIR_params.N_Averages>1
    RIR_params.N_RecSamples = max(size(RIR_data.sigRawFadePadRepClick)) + round(RIR_params.IR_duration*RIR_params.Fs);
else
    RIR_params.N_RecSamples = max(size(RIR_data.sigRawFadePadClick)) + round(RIR_params.IR_duration*RIR_params.Fs);   
end
%-------------------------------------------------------------------------$


%-------------------------------------------------------------------------$
% Channel playback and recording setup
%-------------------------------------------------------------------------$
% Search for the audio interface (e.g. Zoom F4), then add both its input
% and output channels
%-------------------------------------------------------------------------$

% RIR_metadata.audioSystem_Details = playrec('getDevices'); % List current hardware
% for nSystem = 1:length(RIR_metadata.audioSystem_Details)
%     testLog = strcmp(RIR_metadata.audioSystem_Details(nSystem).name, RIR_metadata.interfaceName);
%     switch testLog
%         case 1
%             Zoom_ID = RIR_metadata.audioSystem_Details(nSystem).deviceID;
%     end
% end
% RIR_params.devicePlay  = Zoom_ID; % Device ID of the playback system
% RIR_params.chansPlay   = RIR_metadata.playChanList;        % Max number of recording channels
% RIR_params.deviceRec   = Zoom_ID;            % Device ID of the recording system
% RIR_params.chansRec    = length(RIR_metadata.recChanList); % Max number of playback channels
%pageSize  = 0;       % Block size (0 for system default)
%RIR_params.pageSize  = 4096*4;   % Block size (0 for system default)
%-------------------------------------------------------------------------$


%-------------------------------------------------------------------------$
% Call playrec (via 'mikrec') to setup then run the measurement
%-------------------------------------------------------------------------$
playrecMode     = 'playrec';
Fs              = RIR_params.Fs;

devicePlay      = RIR_metadata.interfaceID_Play;
deviceRec       = RIR_metadata.interfaceID_Rec;

chansPlay       = RIR_metadata.N_chansPlay;
chansRec        = RIR_metadata.N_chansRec;

pageSize        = RIR_params.pageSize;

playChanList    = RIR_metadata.playChanList;
recChanList     = RIR_metadata.recChanList;

N_RecSamples    = RIR_params.N_RecSamples;

if RIR_params.N_Averages==1
    outputAudio     = RIR_data.sigRawFadePadClick;
elseif RIR_params.N_Averages>1
    outputAudio     = RIR_data.sigRawFadePadRepClick;
elseif RIR_params.N_Averages<1
    error('Error: Must have at least 1 measurement repetition')
end

% Short pause if required, to allow user to move around room if needed
pause(RIR_params.T_Wait)

% Then call the main playrec calling script
RIR_data.audioData = mikrec_V5(Fs, devicePlay, deviceRec, chansPlay, chansRec, pageSize, playrecMode, playChanList, recChanList, outputAudio, N_RecSamples);
%-------------------------------------------------------------------------$


%-------------------------------------------------------------------------$
% Deal with syncing, and averaging if required
%-------------------------------------------------------------------------$
% Pull out data right from 'start' of output (from trigger identified)
switch RIR_params.optionClick
    case 0
        RIR_data.audioData_Sync = RIR_data.audioData;
    case 1
        [~,indy]                = max(RIR_data.audioData(1:round(RIR_params.T_ClickPause*RIR_params.Fs),RIR_params.clickDetectChan));
        RIR_data.audioData_Sync = RIR_data.audioData(indy+round(RIR_params.T_ClickPause*RIR_params.Fs):end,:);
end
% Time domain averaging if needed: In either case the 'final' data is in
% "audioDataSyncAll"
% if RIR_params.N_Averages>1
%     hopSize = RIR_params.N_sigRawFadePad;
%     RIR_data.audioDataSyncAll = zeros(hopSize,RIR_params.chansRec);
%     for nAverage = 1:RIR_params.N_Averages
%         here                = (nAverage-1)*hopSize + 1;
%         there               = here + hopSize-1;
%         RIR_data.audioDataSyncAll    = RIR_data.audioDataSyncAll + RIR_data.audioDataSync(here:there,:);
%     end
% else
%     hopSize = RIR_params.N_sigRawFadePad;
%     RIR_data.audioDataSyncAll = RIR_data.audioDataSync(1:hopSize,:);
% end
%-------------------------------------------------------------------------$


end

