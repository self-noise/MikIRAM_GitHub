function [RIR_metadata] = MikRIR_02_ErrorCheck_Fn__V5(RIR_metadata,RIR_params,optionSave)


% First of all, make sure the same device is selected for both input and
% output. This should change in future to allow different devices (playrec
% supports this already)
% if ~strcmp(RIR_metadata.interfaceName_Input,RIR_metadata.interfaceName_Output)
%     error('Error: Different output/input devices selected. Currently this utility requires the same input/output device.')
% end



% Create output path, to check if file already exists
temp6 = clock;
%thisDate = [num2str(temp6(1)) num2str(temp6(2)) num2str(temp6(3)) '_' num2str(temp6(4)) num2str(temp6(5))]; % Include 'time'

thisYear  = num2str(temp6(1));
thisMonth = temp6(2);
thisDay   = temp6(3);

% If month/day are only single character, add a leading zero
switch length(thisMonth)
    case 1
        thisMonth = ['0' num2str(thisMonth)];
    otherwise
        thisMonth = num2str(thisMonth);
end
switch length(thisDay)
    case 1
        thisDay = ['0' num2str(thisDay)];
    otherwise
        thisDay = num2str(thisDay);
end
thisDate = [thisYear '_' thisMonth '_' thisDay]; % Just date

RIR_metadata.dataFilename        = [thisDate '__' RIR_metadata.speaker '__'  ...
    RIR_metadata.srcLoc '__' RIR_metadata.recvrLoc '__' RIR_metadata.runlabel];
RIR_metadata.dataPath            = [RIR_metadata.location '/' RIR_metadata.dataFilename];
%RIR_metadata.location
%RIR_metadata.dataPath
A = exist(RIR_metadata.location);
B = exist([RIR_metadata.dataPath '.mat'],'file');
switch optionSave
    case 1
        switch A
            case 7
            otherwise
                error(['Error: Output folder (' RIR_metadata.location ') for data export does not yet exist. Please create appropriate folder(s), or ammend variable: RIR_metadata.location'])
        end
        
        switch B
            case 2
                disp(['Output datafile already exists ! (' RIR_metadata.dataFilename ')'])
                prompt = 'Do you wish to overwrite? (y/n)';
                x = input(prompt,'s');
                
                switch x
                    case 'y'
                    otherwise
                        error('Error: Measurement aborted.')
                end
        end
end


if length(RIR_metadata.channelNames)~=length(RIR_metadata.recChanList)
    error(['Error: You have specified ' num2str(length(RIR_metadata.recChanList)) ' input channels, but ' ...
        num2str(length(RIR_metadata.channelNames)) ' channel descriptions (text strings). Please correct and try again.'])
end

if RIR_params.f_End>(RIR_params.Fs/2)
    error(['Error: Upper frequency limit of your sweep (' num2str(RIR_params.f_End) 'Hz) is above the Nyquist limit for your chosen sampling rate of ' num2str(RIR_params.Fs) 'Hz. '...
        'Please adjust upper frequency limit or sampling rate.'])
end

end