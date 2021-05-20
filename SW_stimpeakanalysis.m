%% This script will run stimulus-evoked analysis code (see below) on data from the single barrel stroke experiment
% Then it will concatenate all the data into a single structure for further
% animal and group level analysis

cd('/Users/wzeiger/Documents/Portera Lab/Data/GCaMP6 Imaging/SingleWhiskerStroke_Plucked_Analysis')
if exist('StimEvokedResponseData_All.mat')>0
    load('StimEvokedResponseData_All.mat')
else
end

[foldername] = uigetdir('','Select the folder with data analyzed files')
cd(foldername)
filelist=dir;

%% The main loop for opening each file and running analysis
for ii=1:size(filelist,1)
    ii
    if isempty(strfind(filelist(ii).name,'.mat'))==1
        continue
    end
    
    filename=filelist(ii).name;
    display(filename)
    load(filename)  

    %% Create a 3D Matrix of Z-scores, with each array showing peri-stimulus data for each stimulus delivered for each ROI
        timebetweenstims = 3;
        timeafterstim = timebetweenstims - 0.2; 
        framesafterstim = ceil(timeafterstim*framerate);

        timebeforestim = 1; %for now. Put in GUI for later so you can change the chopping lead time.
        framesbeforestim = ceil(timebeforestim*framerate);
        startchop = stimstartframes - framesbeforestim; %starts chop from 1 sec before stim start
        endchop = stimendframes + framesafterstim; 

        chopsize = 38;
        startchop = ceil(startchop);
        startchop(startchop<0)=1;
        endchop = startchop + chopsize;

        chopint = horzcat(startchop,endchop);

        %Now extract just the rows of deltaF for each stimulus, based on the
        %chop intervals

        ROIcount = size(activeROIZ_F,2); 
        %creates a 3D matrix of all 0's. 3 parameters: ROIs, stimulation (from
        %1 to numberofstims), frames (deltaF data)
        allstimsallROIs = zeros((chopsize(1)+1),numberofstims,ROIcount);
        allstimsallROIs_aframes=allstimsallROIs;
        %need chopsize(1)+1 because if one element in chopsize is 38, there are actually 39 frames

        activeframes = activeframes(:, any(activeframes, 1)); %get active frames just for active ROIs
        
        %Now indexing into this 3D matrix. Frames x Stims x ROI
        for j = 1:ROIcount %will create the number of matrices, i.e. # of ROIs
            for i = 1:numberofstims %establishes the matrix columns, i.e. the whisker stimulations
    %             numberofstims ROIcount i j size(allstimsallROIs)
    %             size(activeROIdF) size(chopint) chopint(i,1) chopint(i,2)
                allstimsallROIs(:,i,j) = (activeROIZ_F((chopint(i,1)):(chopint(i,2)),j));
                allstimsallROIs_aframes(:,i,j) = (activeframes((chopint(i,1)):(chopint(i,2)),j)); %Same chop for the activeframes data
                %establishes the matrix rows, i.e. the deltaF data from the
                %startchop to endchop for each whisker stimulation
            end  
        end
    %     disp(allstimsallROIs);
    %% Now separate these for responders and non-responders
        allstimsrespROIs=[];
        allstimsnonrespROIs=[];
        allstimsrespROIs_aframes=[];
        allstimsnonrespROIs_aframes=[];

    %     Separate out responders and non-responders
        for i=1:size(activeROIZ_F,2)
            if signal_percentile(1,i)<=0.01
                allstimsrespROIs=cat(3,allstimsrespROIs,allstimsallROIs(:,:,i));
                allstimsrespROIs_aframes=cat(3,allstimsrespROIs_aframes,allstimsallROIs_aframes(:,:,i));
            end
        end

        for i=1:size(activeROIZ_F,2)
            if signal_percentile(1,i)>0.01
                allstimsnonrespROIs=cat(3,allstimsnonrespROIs,allstimsallROIs(:,:,i));
                allstimsnonrespROIs_aframes=cat(3,allstimsnonrespROIs_aframes,allstimsallROIs_aframes(:,:,i));
            end
        end

        avgallstims = mean(allstimsallROIs,2);

    %% 
    %Chop these into just the period from stimulus onset to 1 sec after stimulus (frames 8-24)
    %Then use the peak finder algorithm to determine if there was a peak in
    %this period for each of the 20 stimuli.


    %------------Spont Peak Finding By Individual Cells for Each Stimulus---------------------
        %==========For Responders activity=============
        
        if isempty(allstimsrespROIs)==1 %If there are no responders, skip the analysis or it will create an error
            allstimsrespROIs_mean=[];
            allstimsrespROIs_AUC=[];
            PeaksRespFrame=[];
            PeaksRespAmp=[];
            PeaksRespMax=[];
            PeaksRespLatency=[];
            PeaksRespMax_mean=[];
            PeaksRespMax_meanallstims=[];
            PeaksRespLatency_mean=[];
            PrctStimActive_Resp=[];
        else
            allstimsrespROIs_mean=zeros(size(allstimsrespROIs,1),size(allstimsrespROIs,3));
            for i=1:size(allstimsrespROIs,3)
                allstimsrespROIs_mean(:,i)=mean(allstimsrespROIs(:,:,i),2);
            end
            allstimsrespROIs_AUC=trapz(allstimsrespROIs_mean(8:24,:));
                        
            PeaksRespFrame=NaN(10,20,size(allstimsrespROIs,3)); %3D matrix of all frames with peaks
            PeaksRespAmp=NaN(10,20,size(allstimsrespROIs,3)); %3D matrix of amplitude of all peaks
            PeaksRespMax=NaN(20,size(allstimsrespROIs,3)); %matrix of max peak amplitudes (stim x ROI)
            PeaksRespLatency=NaN(20,size(allstimsrespROIs,3)); %matrix of latency to max peak (stim x ROI)

            for j=1:size(allstimsrespROIs,3)
                for i=1:numberofstims
                    if sum(allstimsrespROIs_aframes(8:24,i,j))>0 %Only look for peaks if the cell was active in the stimulation period

                        %Find Peaks and Local Minima
                        [PeakMaxCalc,PeakAmpCalc]=peakfinder(allstimsrespROIs(:,i,j), 3, 3, 1, 0);

                        if isempty(PeakAmpCalc) == 0
                            PeaksRespFrame(1:size(PeakMaxCalc,1),i,j)=PeakMaxCalc; %Calculate all peaks from 1 sec before until 2.8 sec after stim
                            PeaksRespAmp(1:size(PeakAmpCalc,1),i,j)=PeakAmpCalc;
                            PeakAmpCalc=PeakAmpCalc(PeakMaxCalc>=8 & PeakMaxCalc<=24); %Isolate just peaks occurring from stim onset until +1 sec
                            PeakMaxCalc=PeakMaxCalc(PeakMaxCalc>=8 & PeakMaxCalc<=24);
                            if isempty(PeakAmpCalc) == 0 %If you try to do the following on empty vectors, you get an error, so skip if empty
                                PeaksRespMax(i,j)=max(PeakAmpCalc);
                                try
                                PeaksRespLatency(i,j)=PeakMaxCalc(PeakAmpCalc==max(PeakAmpCalc)); %Can error if two peaks are both max and equal
                                catch
                                [Y,I]=max(PeakAmpCalc); %If two peaks are max and equal, just take the first
                                PeaksRespLatency(i,j)=PeakMaxCalc(I);
                                end
                            else
                            end
                        else
                        end
                    else
                    end

                end
                        
            end

            PeaksRespMax_mean=mean(PeaksRespMax,1,'omitnan'); %Mean for only stims with a peak
            PeaksRespMax_meanallstims=sum(PeaksRespMax,1,'omitnan')/20; %Mean for all stims, setting no peak trials to 0.
            PeaksRespLatency_mean=mean(PeaksRespLatency,1,'omitnan');
            PrctStimActive_Resp=(sum((PeaksRespLatency>0),1))/20; 
            
        end
        
        


        %==========For Non-responders activity=============
        
        allstimsnonrespROIs_mean=zeros(size(allstimsnonrespROIs,1),size(allstimsnonrespROIs,3));
        for i=1:size(allstimsnonrespROIs,3)
            allstimsnonrespROIs_mean(:,i)=mean(allstimsnonrespROIs(:,:,i),2);
        end

        allstimsnonrespROIs_AUC=trapz(allstimsnonrespROIs_mean(8:24,:));
        
        PeaksNonRespFrame=NaN(10,20,size(allstimsnonrespROIs,3)); %3D matrix of all frames with peaks
        PeaksNonRespAmp=NaN(10,20,size(allstimsnonrespROIs,3)); %3D matrix of amplitude of all peaks
        PeaksNonRespMax=NaN(20,size(allstimsnonrespROIs,3)); %matrix of max peak amplitudes (stim x ROI)
        PeaksNonRespLatency=NaN(20,size(allstimsnonrespROIs,3)); %matrix of latency to max peak (stim x ROI)

        for j=1:size(allstimsnonrespROIs,3)
            for i=1:numberofstims
                if sum(allstimsnonrespROIs_aframes(8:24,i,j))>0 

                    %Find Peaks and Local Minima
                    [PeakMaxCalc,PeakAmpCalc]=peakfinder(allstimsnonrespROIs(:,i,j), 3, 3, 1, 0);

                    if isempty(PeakAmpCalc) == 0
                        PeaksNonRespFrame(1:size(PeakMaxCalc,1),i,j)=PeakMaxCalc;
                        PeaksNonRespAmp(1:size(PeakAmpCalc,1),i,j)=PeakAmpCalc;
                        PeakAmpCalc=PeakAmpCalc(PeakMaxCalc>=8 & PeakMaxCalc<=24);
                        PeakMaxCalc=PeakMaxCalc(PeakMaxCalc>=8 & PeakMaxCalc<=24);
                        if isempty(PeakAmpCalc) == 0
                            PeaksNonRespMax(i,j)=max(PeakAmpCalc);
                            try
                            PeaksNonRespLatency(i,j)=PeakMaxCalc(PeakAmpCalc==max(PeakAmpCalc));
                            catch
                                [Y,I]=max(PeakAmpCalc);
                                PeaksNonRespLatency(i,j)=PeakMaxCalc(I);
                            end
                        else
                        end
                    else
                    end
                else
                end

            end
        end

        PeaksNonRespMax_mean=mean(PeaksNonRespMax,1,'omitnan');
        PeaksNonRespMax_meanallstims=sum(PeaksNonRespMax,1,'omitnan')/20;
        PeaksNonRespLatency_mean=mean(PeaksNonRespLatency,1,'omitnan');
        PrctStimActive_NonResp=(sum((PeaksNonRespLatency>0),1))/20;
    %% 

    %Make a structure with a field for each variable
    S=struct('FileName',fullxlsfile,'allstimsallROIs',allstimsallROIs,...
        'allstimsrespROIs',allstimsrespROIs,...
        'allstimsnonrespROIs',allstimsnonrespROIs,...
        'allstimsrespROIs_AUC',allstimsrespROIs_AUC,'allstimsnonrespROIs_AUC',allstimsnonrespROIs_AUC,...
        'allstimsrespROIs_mean',allstimsrespROIs_mean,'allstimsnonrespROIs_mean',allstimsnonrespROIs_mean,...
        'PeaksRespFrame',PeaksRespFrame,'PeaksRespAmp',PeaksRespAmp,'PeaksRespMax',PeaksRespMax,...
        'PeaksRespMax_mean',PeaksRespMax_mean,'PeaksRespMax_meanallstims',PeaksRespMax_meanallstims,...
        'PeaksRespLatency',PeaksRespLatency,'PeaksRespLatency_mean',PeaksRespLatency_mean,...
        'PrctStimActive_Resp',PrctStimActive_Resp,'PeaksNonRespFrame',PeaksNonRespFrame,...
        'PeaksNonRespAmp',PeaksNonRespAmp,'PeaksNonRespMax',PeaksNonRespMax,...
        'PeaksNonRespMax_mean',PeaksNonRespMax_mean,'PeaksNonRespMax_meanallstims',PeaksNonRespMax_meanallstims,...
        'PeaksNonRespLatency',PeaksNonRespLatency,'PeaksNonRespLatency_mean',PeaksNonRespLatency_mean,...
        'PrctStimActive_NonResp',PrctStimActive_NonResp);
    
    if exist('StimEvokedResponseData')==0 %if it doesn't exist, create it
           StimEvokedResponseData=S;
    else
        StimEvokedResponseData=[StimEvokedResponseData,S]; %add data to data from the other files
    end
    
    clearvars -except StimEvokedResponseData filelist foldername ii
    
end

cd('/Users/wzeiger/Documents/Portera Lab/Data/GCaMP6 Imaging/SingleWhiskerStroke_Plucked_Analysis')
save('StimEvokedResponseData_All.mat','StimEvokedResponseData')



    