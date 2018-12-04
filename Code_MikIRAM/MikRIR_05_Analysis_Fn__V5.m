function [RIR_metadata,RIR_params,RIR_data] = MikRIR_05_Analysis_Fn__V5(RIR_metadata,RIR_params,RIR_data)

%-------------------------------------------------------------------------%
% Basic frequency domain analysis
%-------------------------------------------------------------------------%
% The length of the output signal we ended up with
%RIR_data.N                   = max(size(RIR_data.audioDataSyncAll));
RIR_data.N                   = max(size(RIR_data.audioData_Sync));

% Zero pad the output up to twice its length, and take DFT
RIR_data.audioData_SyncPad  = [RIR_data.audioData_Sync;zeros(RIR_data.N,length(RIR_metadata.recChanList))];
RIR_data.audioData_dft      = fft(RIR_data.audioData_SyncPad);

% Difference in length between output signal and input signal
extraN                      = RIR_data.N-RIR_params.N_sigRawFadePad;

% Pad the input signals to same length as output (at least twice output
% length to ensure linear deconvolution, and make into matrix
RIR_data.sigRawFadePadPad    = [RIR_data.sigRawFadePad;zeros(RIR_data.N+extraN,1)];

% Compute DFT of raw signal, then send to regularised inversion if required
% for computation of inverse filter
switch RIR_params.optionKirkeby
    case 0
        RIR_data.invFilter_dft = 1./((1/sqrt(length(RIR_data.sigRawFadePad)))*fft(RIR_data.sigRawFadePadPad));
    case 1
        %[RIR_data.invFilter_dft,RIR_data.A_compensation] = regInverse((1/sqrt(length(RIR_data.sigRawFadePad)))*fft(RIR_data.sigRawFadePadPad),RIR_params.Fs,RIR_params.regInv_fLow,RIR_params.regInv_fHigh,...
        %    RIR_params.df_Kirkeby_low,RIR_params.beta_Pass_dB,RIR_params.beta_Limit_dB,RIR_params.T_SigLength,RIR_params.T_Fade);
        [RIR_data.invFilter_dft,RIR_data.A_compensation] = regInverse((1/sqrt(length(RIR_data.sigRawFadePad)))*fft(RIR_data.sigRawFadePadPad),RIR_params.Fs,RIR_params.f_Start,RIR_params.f_End,...
            RIR_params.df_Kirkeby_low,RIR_params.beta_Pass_dB,RIR_params.beta_Limit_dB,RIR_params.T_SigLength,RIR_params.T_Fade);
end

RIR_data.test = ifft(RIR_data.invFilter_dft);

% Create a matrix of identical columns, each containing the inverse filter
RIR_data.invFilter_dft_Mat  = repmat(RIR_data.invFilter_dft,[1,length(RIR_metadata.recChanList)]);

% Compute inverse filtering of each measured channel (deconvolution) to
% obtain frequency responses - these include distortion components (which
% can be windowed out below to create a clearer FR).
RIR_data.FR_whole           = RIR_data.audioData_dft.*RIR_data.invFilter_dft_Mat;

% Compute the impulse responses. Apply circular shift given by number
% of samples in the original sweep, which places main (1st order) IR near
% middle of deconvolved signal. From here it can be windowed out.
%RIR_data.IR = ifft(RIR_data.FR);
RIR_data.IR_whole           = circshift(ifft(RIR_data.FR_whole),RIR_params.N_sigRawFadePad);

% Make a copy of the raw (non-normalised) whole IR
RIR_data.IR_whole_raw = RIR_data.IR_whole;

% Normalise all measured signals (as a set) so that loudest is at +/- 1
peakVal = max(max(abs(RIR_data.IR_whole)));
RIR_data.IR_whole = RIR_data.IR_whole/peakVal;

% Window out the 1st order (i.e. "linear") component in the deconvolved IR
% Timing here is based on the 'click detect' channel (i.e. all are cut
% relative to the timing of the peak in this particular channel).
[RIR_metadata,RIR_params,RIR_data] = MikRIR_00_RIR_Cutter_Fn__V5(RIR_metadata,RIR_params,RIR_data);


    function [sigOut,A_compensation] = regInverse(sigIn,Fs,f_low,f_high,f_transition,beta_Pass_dB,beta_Limit_dB,T_SigLength,T_Fade)
        % To Add:        
        %   1) Make inversion work for odd N (currently only for even N)
        %       --> Though most times the signal coming in here is already double
        %       length (i.e. sure to be even length).
        % Inputs:
        %   sigIn        : DFT of a signal, from which we compute a regularised inverse
        %   Fs           : Sample rate
        %   beta_Pass_dB : dB level for passband (Default: -Inf)
        %   beta_Limit_dB: dB level for attenuated band (usually low/high freqs) (Default: 0)
        %   f_low        : Lower frequency (Hz) 'cut on' for passband (Default: 30Hz)
        %   f_high       : Upper frequency (Hz) 'cut off' for passband (Default: 20000Hz)
        %   f_transition : Transition width (Hz) for on/off regions of
        %   passband (Default: 20Hz) - Applies only to lower frequency
        %                              range. Upper frequency transition is auto-calculated based on fade out duration
        %   T_SigLength  : Raw sweep duration (e.g. 10s)
        %   T_Fade       : Fade out time (e.g. 0.1s)
        
        % Derived quantities
        N                = length(sigIn);        
        df               = Fs/N;        
        A_compensation   = zeros(N/2,1);
        beta_high        = 10^(beta_Limit_dB/20);
        beta_low         = 10^(beta_Pass_dB/20);
        f_low_bin        = floor(f_low/df);
        f_high_bin       = floor(f_high/df);        
        f_transition_bin = ceil(f_transition/df);                
        %f_lower_trans_start = floor(f_low*(((f_high/f_low)^(1/T_SigLength))^(T_Fade)));
        %f_transition_lower  = f_low - round(f_lower_trans_start);
        %f_transition_bin   = round(ceil(f_transition_lower/df))                
        
        f_upper_trans_start = floor(f_low*(((f_high/f_low)^(1/T_SigLength))^(T_SigLength-T_Fade)));
        f_transition_upper  = f_high - round(f_upper_trans_start);
        f_transition_bin2   = round(ceil(f_transition_upper/df)/2);                
        
        % Create compensation vector
        tranBand = flipud(beta_low+((beta_high-beta_low)/2)*(1 - cos(2*pi*(0:f_transition_bin-1)'/(2*f_transition_bin))));        
        tranBand2 = beta_low+((beta_high-beta_low)/2)*(1 - cos(2*pi*(0:f_transition_bin2-1)'/(2*f_transition_bin2)));        
        A_compensation(1:f_low_bin-1)                                             = beta_high;                
        A_compensation(f_low_bin:f_low_bin+f_transition_bin-1)                    = tranBand;        
        A_compensation(f_low_bin+f_transition_bin:f_high_bin-f_transition_bin2-1) = beta_low;               
        A_compensation(f_high_bin-f_transition_bin2:f_high_bin-1)                 = tranBand2;                
        A_compensation(f_high_bin:1 + N/2)                                        = beta_high;
        
        % Make upper half of compensation vector (maintain conjugate symmetry!)
        A_compensation = [A_compensation;flipud(A_compensation(2:end-1))];
        
        %fig10 = figure(10);
        %plot(A_compensation)
        %         % Derived quantities
        %         N                = length(sigIn);
        %         df               = Fs/N;
        %         A_compensation   = zeros(N/2,1);
        %         beta_high        = 10^(beta_Limit_dB/20);
        %         beta_low         = 10^(beta_Pass_dB/20);
        %         f_low_bin        = floor(f_low/df);
        %         f_high_bin       = floor(f_high/df);
        %         f_transition_bin = ceil(f_transition/df);
        %
        %         % Create compensation vector
        %         A_compensation(1:f_low_bin-1)                             = beta_high;
        %         A_compensation(f_low_bin:f_low_bin+f_transition_bin)      = linspace(beta_high,beta_low,f_transition_bin+1);
        %         A_compensation(f_low_bin+f_transition_bin+1:f_high_bin-1) = beta_low;
        %         A_compensation(f_high_bin:f_high_bin+f_transition_bin)    = linspace(beta_low,beta_high,f_transition_bin+1);
        %         A_compensation(f_high_bin+f_transition_bin+1:1 + N/2)     = beta_high;
        %
        %         % Make upper half of compensation vector (maintain conjugate symmetry!)
        %         A_compensation = [A_compensation;flipud(A_compensation(2:end-1))];
        
        % Apply Kirkeby's regularised inversion. Resulting signal is still in
        % frequency domain (should be conjugate symmetric!)
        sigOut = conj(sigIn)./((conj(sigIn).*sigIn) + A_compensation);
    end
end