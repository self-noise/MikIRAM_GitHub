%-------------------------------------------------------------------------%
% MikRIR_07_SaveData_Fn__V2.m
%-------------------------------------------------------------------------%
%
% Plotting function for the MikRIR room impulse response measurement
% package
%
%-------------------------------------------------------------------------%
function  [RIR_data_brief] = MikRIR_07_SaveData_Fn__V5(RIR_metadata,RIR_params,RIR_data,optionCustom)

%-------------------------------------------------------------------------%
% Save data if required
%-------------------------------------------------------------------------%
% RIR_data_brief.sigRawFadePad     = RIR_data.sigRawFadePad;
% RIR_data_brief.audioData_SyncPad = RIR_data.audioData_SyncPad;
% RIR_data_brief.FR                = RIR_data.FR;
% RIR_data_brief.IR                = RIR_data.IR;
% RIR_data_brief.IR_whole          = RIR_data.IR_whole;
% RIR_data_brief.invFilter_dft     = RIR_data.invFilter_dft;
% RIR_data_brief.A_compensation    = RIR_data.A_compensation;

%RIR_data = RIR_data_brief;

%RIR_metadata.dataPath
%savefig(RIR_metadata.plotFig,dataFilename,'compact')
%saveas(RIR_metadata.plotFig,RIR_metadata.dataPath,'epsc')
%saveas(RIR_metadata.plotFig,RIR_metadata.dataPath,'png')
%RIR_metadata.plotFig = 0;
switch optionCustom
    case 0
        save(RIR_metadata.dataPath,'RIR_metadata','RIR_params','RIR_data')
    case 1
        [file,path] = uiputfile([RIR_metadata.dataPath,'.mat'],'Save file name');
        RIR_metadata.dataFilename = file;
        RIR_metadata.dataPath = [path,file];
        save(RIR_metadata.dataPath,'RIR_metadata','RIR_params','RIR_data')        
end


disp('----------------------------------------')
disp(['Matlab (.MAT) datafile saved to disk.'])
disp(['Datafile folder path : ' RIR_metadata.location])
disp(['Datafile file name   : ' RIR_metadata.dataFilename '.mat'])
disp('----------------------------------------')
disp(['Impulse responses are each of duration: ' num2str(RIR_params.IR_duration) 's'])
disp(['Windowing out of final RIRs has been done based on peak finding in channel: ' num2str(RIR_params.clickDetectChan) ' (' RIR_metadata.channelNames{RIR_params.clickDetectChan} ')'])
disp('----------------------------------------')
end