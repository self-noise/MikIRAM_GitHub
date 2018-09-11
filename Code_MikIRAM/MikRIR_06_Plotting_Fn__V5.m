%-------------------------------------------------------------------------%
% MikRIR_06_Plotting_Fn__V2.m
%-------------------------------------------------------------------------%
%
% Plotting function for the MikRIR room impulse response measurement
% package
%
%-------------------------------------------------------------------------%
function  [RIR_metadata] = MikRIR_06_Plotting_Fn__V5(RIR_metadata,RIR_params,RIR_data)

tVec_pad1 = [0:RIR_params.Ts:RIR_params.Ts*(length(RIR_data.sigRawFadePad))-RIR_params.Ts]';
tVec_pad2 = [0:RIR_params.Ts:RIR_params.Ts*(length(RIR_data.audioData_Sync))-RIR_params.Ts]';
tVec_pad3 = [0:RIR_params.Ts:RIR_params.Ts*(length(RIR_data.IR))-RIR_params.Ts]';
tVec_pad4 = [0:RIR_params.Ts:RIR_params.Ts*(length(RIR_data.invFilter_dft))-RIR_params.Ts]';

% Frequency axis for plotting (original sweep/inverse filter response)
RIR_data.df1          = RIR_params.Fs/(max(size(RIR_data.sigRawFadePadPad)));
RIR_data.fAxis1       = [0:RIR_data.df1:RIR_params.Fs-RIR_data.df1]';

% Final measured RIR/FR
RIR_data.df          = RIR_params.Fs/(max(size(RIR_data.FR)));
RIR_data.fAxis       = [0:RIR_data.df:RIR_params.Fs-RIR_data.df]';


figline = 2;
figfont = 16;
RIR_metadata.plotFig = figure(1);
set(RIR_metadata.plotFig, 'Position', get(0,'Screensize'));

ax(1) = subplot(3,3,1);
hold on
grid on
plot(tVec_pad1,RIR_data.sigRawFadePad,'LineWidth',figline)
xlabel('Time (s)','FontSize',figfont)
ylabel('Amplitude','FontSize',figfont)
title('Logarithmic chirp (time domain)','FontSize',figfont)

ax(2) = subplot(3,3,2);
hold on
grid on
plot(tVec_pad2,RIR_data.audioData_Sync,'LineWidth',figline)
xlabel('Time (s)','FontSize',figfont)
ylabel('Amplitude','FontSize',figfont)
title('Raw sweep recordings (mics)','FontSize',figfont)
legend(RIR_metadata.channelNames)

ax(3) = subplot(3,3,3);
hold on
grid on
plot(tVec_pad4,ifft(RIR_data.invFilter_dft),'LineWidth',figline)
xlabel('Time (s)','FontSize',figfont)
ylabel('Amplitude','FontSize',figfont)
title('Inverse filter (time domain)','FontSize',figfont)

ax(4) = subplot(3,3,4);
%plot(RIR_data.fAxis1,20*log10(abs(fft(RIR_data.sigRawFadePadPad))),'LineWidth',figline)
semilogx(RIR_data.fAxis1,20*log10(abs(fft(RIR_data.sigRawFadePadPad))),'LineWidth',figline)
hold on
grid on
%plot(RIR_data.fAxis1,20*log10(abs(RIR_data.invFilter_dft)),'LineWidth',figline)
semilogx(RIR_data.fAxis1,20*log10(abs(RIR_data.invFilter_dft)),'LineWidth',figline)
xlabel('Frequency (Hz)','FontSize',figfont)
ylabel('Magnitude (dB)','FontSize',figfont)
title('Chirp & inverse filter in frequency domain','FontSize',figfont)
xlim([RIR_params.f_Start,RIR_params.f_End])
l1 = legend('Chirp spectrum','Inverse filter spectrum');
set(l1,'FontSize',figfont,'Location','South')

ax(5) = subplot(3,3,5);
%plot(RIR_data.fAxis,20*log10(abs(RIR_data.FR)),'LineWidth',2)
semilogx(RIR_data.fAxis,20*log10(abs(RIR_data.FR)),'LineWidth',2)
hold on
grid on
xlabel('Frequency (Hz)','FontSize',figfont)
ylabel('Magnitude (dB)','FontSize',figfont)
title('Room frequency responses (mag)','FontSize',figfont)
xlim([0,RIR_params.Fs/2])
legend(RIR_metadata.channelNames)

ax(6) = subplot(3,3,6);
semilogx(RIR_data.fAxis,unwrap(angle(RIR_data.FR)),'LineWidth',2)
hold on
grid on
xlabel('Frequency (Hz)','FontSize',figfont)
ylabel('Phase (unwrapped, radians)','FontSize',figfont)
title('Room frequency responses (phase)','FontSize',figfont)
xlim([0,RIR_params.Fs/2])
legend(RIR_metadata.channelNames)


ax(7) = subplot(3,3,7);
hold on
grid on
plot(tVec_pad4,RIR_data.IR_whole(:,1),'LineWidth',figline)
plot(tVec_pad4(RIR_data.IR_winRange),RIR_data.IR_whole(RIR_data.IR_winRange,1),'LineWidth',figline)
xlabel('Time (s)','FontSize',figfont)
ylabel('Amplitude','FontSize',figfont)
title('Room impulse responses (raw)','FontSize',figfont)
legend('Raw impulse response','Windowed impulse response')
set(ax,'FontSize',figfont)


ax(8) = subplot(3,3,8);
hold on
grid on
plot(tVec_pad3,RIR_data.IR,'LineWidth',figline)
xlabel('Time (s)','FontSize',figfont)
ylabel('Amplitude','FontSize',figfont)
title('Room impulse responses (windowed)','FontSize',figfont)
legend(RIR_metadata.channelNames)
xlim([0,RIR_params.IR_duration])
set(ax,'FontSize',figfont)
end