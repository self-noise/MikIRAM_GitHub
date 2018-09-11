%-------------------------------------------------------------------------%
% MikRIR_03_MakeSig_Fn__V5.m
%-------------------------------------------------------------------------%
%
%
%
%-------------------------------------------------------------------------%
function [RIR_metadata,RIR_params,RIR_data] = MikRIR_03_MakeSig_Fn__V5(RIR_metadata,RIR_params)

%-------------------------------------------------------------------------$
% Output signal setup
%-------------------------------------------------------------------------$
RIR_params.sigVolume   = 10^(RIR_params.sigVolumedBFS/20);
RIR_params.clickVolume = 10^(RIR_params.volumeClickdBFS/20);

switch RIR_params.signalType
    case 'logsweep'
        RIR_params.Ts      = 1/RIR_params.Fs;
        RIR_data.tVec    = [0:RIR_params.Ts:RIR_params.T_SigLength-RIR_params.Ts]';
        RIR_data.sigRaw  = RIR_params.sigVolume*chirp(RIR_data.tVec,RIR_params.f_Start,RIR_params.T_SigLength-RIR_params.Ts,RIR_params.f_End,'logarithmic',-90);
    case 'sine'
        Ts = 1/Fs;
        tEnd    = T_SigLength; tVec = 0:Ts:tEnd-Ts;
        f_Sine  = 8000;
        RIR_data.sigRaw   = sigVolume*sin(2*pi*f_Sine*tVec)';
    case 'file'
        [RIR_data.sigRaw,Fs2] = audioread(filenameInput);
        if Fs2~=Fs
            error(['Error: Input signal not sampled at ' num2str(Fs) 'kHz. Resample and reload, or change rate in this script.'])
        end
        RIR_data.sigRaw = RIR_params.sigVolume*RIR_data.sigRaw/max(abs(RIR_data.sigRaw));
end

% Apply fade in/out
switch RIR_params.T_Fade                 
    case 0
        RIR_data.sigRawFade              = RIR_data.sigRaw;
    otherwise
        N_Fade                           = round(RIR_params.T_Fade*RIR_params.Fs);
        windowFade                       = hann(N_Fade);
        [~,windowPeak]                   = max(windowFade);
        windowFade                       = windowFade(1:windowPeak);
        RIR_data.sigRawFade                       = RIR_data.sigRaw;
        RIR_data.sigRawFade(1:windowPeak)         = RIR_data.sigRawFade(1:windowPeak).*windowFade;
        RIR_data.sigRawFade(end-windowPeak+1:end) = RIR_data.sigRawFade(end-windowPeak+1:end).*flipud(windowFade);
end

% Apply zero padding to end, equal to the user's chosen IR duration
% Idea is that if the user specifies a 5s IR duration, we add 5s to
% sweep to ensure the response ringdown is fully captured. This can always
% be pruned later on if it's too long.
%RIR_data.sigRawFadePad = [RIR_data.sigRawFade;zeros(round(RIR_params.T_Pad*RIR_params.Fs),1)];
RIR_data.sigRawFadePad = [RIR_data.sigRawFade;zeros(round(RIR_params.IR_duration*RIR_params.Fs),1)];

% Total length of a single cycle of the zero-padded excitation signal,
% PRIOR to adding the click below
RIR_params.N_sigRawFadePad = length(RIR_data.sigRawFadePad);
RIR_params.T_sigRawFadePad = RIR_params.N_sigRawFadePad/RIR_params.Fs;

% Make signal with repetitions if needed, adding in a trigger pulse if
% required. Note that the added trigger and zeros will be removed in
% analysis after acquisition
switch RIR_params.optionClick
    case 1
        if RIR_params.N_Averages>1
            % Make a long vector of signal repetitions
            RIR_data.sigRawFadePadRepClick = repmat(RIR_data.sigRawFadePad,[RIR_params.N_Averages,1]);
            
            % Add a click at the start for post-sync
            RIR_data.sigRawFadePadRepClick = [RIR_params.clickVolume;zeros(round(RIR_params.T_ClickPause*Fs)-1,1);RIR_data.sigRawFadePadRepClick];
        else
            % Add a click at the start for post-sync
            RIR_data.sigRawFadePadClick    = [RIR_params.clickVolume;zeros(round(RIR_params.T_ClickPause*RIR_params.Fs)-1,1);RIR_data.sigRawFadePad]; 
        end
end

end