% This function simply cuts out the requested parts of a measured RIR
function [RIR_metadata,RIR_params,RIR_data] = MikRIR_00_RIR_Cutter_Fn__V5(RIR_metadata,RIR_params,RIR_data)

%disp('Cutter Fn called')

% First of all, find peak sample in 'click detect' channel
%   --> This is our standard reference point for 'cut' RIR extraction
[~,peakIndex]                = max(abs(RIR_data.IR_whole(:,RIR_params.clickDetectChan)));

samplesPre = RIR_params.IR_preCutSamples;
samplesDur = round(RIR_params.Fs*RIR_params.IR_duration);

%RIR_data.IR_winRange        = [peakIndex-100:peakIndex+(samplesDur)-1-100]';
RIR_data.IR_winRange        = [peakIndex-samplesPre:peakIndex+(samplesDur)-1-samplesPre]';

if RIR_data.IR_winRange(1) < 1
    error('Error: Pre-cut duration too long; shorten time and try again.')        
end 

% If requested cut IR duration goes beyond the end of our 'whole' IR, we
% will need to zero pad all measured RIRs
raw_IR_length = max(size(RIR_data.IR_whole));
if RIR_data.IR_winRange(end) > raw_IR_length
    N_Zeros = RIR_data.IR_winRange(end)-raw_IR_length-1;
    
    RIR_data.IR = RIR_data.IR_whole(RIR_data.IR_winRange(1):end,:);    
    zeroMat     = zeros(N_Zeros,length(RIR_metadata.recChanList));    
    
    %size(RIR_data.IR)
    %size(zeroMat)
    RIR_data.IR = [RIR_data.IR;zeroMat];
else
    % The usual case: Simply extract requested range with no error nor zero
    % padding required
    RIR_data.IR                 = RIR_data.IR_whole(RIR_data.IR_winRange,:);
end

% And make the 'linear' frequency response from the windowed RIR
RIR_data.FR                 = fft(RIR_data.IR);
end
