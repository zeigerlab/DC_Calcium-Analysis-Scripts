%3/18/15: Added code to generate a multi-page PDF with the Z_F traces (with
%red peaks and, if whisker stim, the grey bars).  So, no longer have
% to manually enlarge each figure of traces, save as PDF, then compile the
% pages.  I used the DC_multiPagePDF function that Daniel wrote, which is
% in the DC_calcium folder.  That function was already being used in the
% DC_calcium data preview.

%3/19/15: Added more comments in the section calculating significance. Also
%changed sigframenum to 4 (was previously 6) and added explanation for why.
%Also added GUI inputs for # lag frames, # of scrambles, and percentile for
%calculating stim response significance.

%3/25/15: Added code + GUI option to extract ZF data for just the first m
%and last n stims (used for examining habituation in evoked activity

%10/3/15: Added firstset/lastset stim overlay plotting

%11/18/15: Updated stims significance section with new code from Daniel
%(scrambling of epochs instead of just every frame, to preserve events)

function varargout = CH_Analyze2_Control(badframes,outputs,deleted,corrbins,roiselect,...
        fullFfile,experimenttype,baselineframes,fullxlsfile,numberofstims,...
        pulsesperstim,stimduration,timebetweenstims,lagframes,numscrambles,...
        percentile,firstsetstims,lastsetstims,spontisoframes)
%This is adapted from DCLW_Analyze_Control2 (05/28/2014 version) Keep ROI
%selection and data analysis as seperate functions so can be run separately
%Load F file
load(fullFfile); %loads saved F data and others from Dombeck's code


if outputs(5)==1
% ~~This section added on 10/16/14 to make this code import the workspace
% from DC_Calcium_CH
    F=zeros(size(ROI_list,2),size(ROI_list(1,1).fmean,1));
    for i=1:size(ROI_list,2)
        F(i,:)=(ROI_list(1,i).fmean);
    end
    %transpose the matrix to get old format
    F=F';
    % ~~End 10/16/14 addition
end


transpose(roiselect);
if roiselect~=0 %use only the good ROIs
    F=F(:,roiselect);
end

Fsize=size(F);
%Load Excel File

%Sad day in science.  Need to do something about the zero's in the F
%matrix, because those are problematic for calculating Z_F.  First find the
%number of 0's; if greater than 5% of the frames are 0, then the entire
%column of F gets knocked out as NaN.

%For the remaining ROIs (with <5% of frames as F value 0), in F matrix,
% replace all 0's with NaN.
%Then find minimum for each column (ROI), and replace the NaN's in each
%column with that minumum you found.

zerocount=zeros(1,Fsize(2));
for q=1:Fsize(2)
    for qq=1:Fsize(1)
        if F(qq,q)==0;
            zerocount(q)=zerocount(q)+1;
            F(qq,q)=NaN;
        end  
    end
    if zerocount(q)>(0.05*Fsize(1))
        F(:,q)=NaN;
    end
end

columnmins=zeros(1,Fsize(2));
for p=1:Fsize(2)
    columnmins(p) = min(F(:,p));
end

for q=1:Fsize(2)
    for qq=1:Fsize(1)
        if isnan(F(qq,q))
            F(qq,q)=columnmins(q);
        end     
    end
end


%-----------Calculate Baseline F for each ROI (all experiment
%types)------------------------
basecalc=zeros(1,Fsize(1)-baselineframes+1);
Fbaseline=zeros(1,Fsize(2));
blueframes=zeros(Fsize(1),Fsize(2));
greyframes=zeros(Fsize(1),Fsize(2));
mindex=zeros(1,Fsize(2));
%Fbaseline=median(F);
for j=1:Fsize(2)  %calculate baseline by using median
    for i=1:Fsize(1)-baselineframes+1 %find 10 seconds of baseline. RECALC based on framerate
        basecalc(i)=std(F(i:i+baselineframes-1,j)); %checks STD for all values

    end
    [~,mindex(j)]=min(basecalc); %calculate the position of lowest deviation for baseline
    Fbaseline(j)=mean(F(mindex(j):mindex(j)+baselineframes-1,j));
    Fbaselinedev(j)=std(F(mindex(j):mindex(j)+baselineframes-1,j)); %Added on 7/25/14
    blueframes((mindex(j):mindex(j)+baselineframes-1),j)=1;
    disp(['Calculating Baseline: ', (num2str(100*j/Fsize(2))), '%']);
end

%----------------End Calculate Baseline F--------------------------------

%Changes on 7/25/14: Previous display method was plotting dF/F with the
%"baseline" calculated as mean of 10 quietest seconds (80 frames,
%established in GUI), with threshold for significance of dF based on MAD of
%entire range of data.  New modified Z-score method after talking with
%Dario: now use standard deviation for the 10 quietest seconds as well, and
%calculate Z_F for all data where Z_F = (F(t) - mean of baseline
%period)/std(baseline period).  Threshold is now set to a [modified]
%Z-score of 3, with significance (red frames) set to 6 consecutive frames
%above threshold.

%--------------Calculate Z_F for each ROI (all experiment
%types)-------------------------------
Z_F=zeros(Fsize(1),Fsize(2)); %Renamed "Z_F" from previous "dF" (7/25/14)
for i=1:Fsize(1)
    for j=1:Fsize(2)
        if F(i,j)==0   
            Z_F(i,j)=0; %set to 0 if no data available; but shouldn't be any more 0's at this point 
        else
%             dF(i,j)=100*(F(i,j)-Fbaseline(j))/(Fbaseline(j));
            Z_F(i,j)=(F(i,j)-Fbaseline(j))/(Fbaselinedev(j)); %New on 7/25/14
        end
    end
end

%----------End Calculate Z_F for each ROI-------------------------------

%--------------Calculate significance for each ROI-----------------------
% maddF=mad(Z_F,1); sigdF=3*maddF; %threshold equal to 3*MAD
sigdF=zeros(size(Z_F,1)); %New on 7/25/14
sigdF=sigdF+3; %New on 7/25/14; sets threshold for significance as Z_F of 3
sigframes=zeros(size(Z_F,1),size(Z_F,2));
activeframes=zeros(size(Z_F,1),size(Z_F,2));
redframes=zeros(size(Z_F,1),size(Z_F,2));
activeROI=zeros(1,size(Z_F,2)); 
sigframenum=4;  %Set this on 3/19/15.

%Check if activity is above threshold in all frames for all ROIs
for j=1:size(Z_F,2) %Going col by col (ROI by ROI)
    for i=1:size(Z_F,1) %Going row by row (frame by frame)
        if Z_F(i,j)>sigdF(1,j) %if Z_F>3, set above in sigdF=sigdF+3
            sigframes(i,j)=1; %1 means that frame in that ROI is above threshold
        end
    end
end

%Check for 4+ consecutive significant frames. Before 3/19/15,
%sigframenum=6.  This was chosen because it looks good in the trace
%display. But since sigframenum will be used to determine what an "active"
%ROI is, changed to more generous sigframenum=4 (4 frames = about 0.5 sec
%at 8 Hz). This is a little more more generous and will hopefully be a
%failsafe, to prevent any ROI with just teensy blip(s) of activity from
%slipping through the cracks.  (Granted, this is highly unlikely with
%GCaMP6's long
% decay time, which was reported as well over 1 second for 1 action
%potential, as shown in the Chen 2013 paper's Figure 1.  So, setting
%sigframenum=4 or sigframenum=6 are both very safe.)

for j=1:size(Z_F,2) %Going col by col (ROI by ROI)
    for i=1:size(Z_F,1) %Going row by row (frame by frame)
        sigcount=0;
        if sigframes(i,j)==1 %For every instance where sigframe=1, 
            sigcount=sigcount+1; 
            %If the currently indexed frame + k (where k is 1-5 for
            %sigframenum=6) is less than the total # of frames, AND current
            %frame + k is an active frame, then add 1 to sigcount
            for k=1:sigframenum-1
                if ((i+k <= size(Z_F,1)) && (sigframes(i+k,j)==1))
                    sigcount=sigcount+1;
                end
            end
            if sigcount==sigframenum
                activeframes(i:i+sigframenum-1,j)=1; 
                %if you have sigframenum of consecutive active frames, then
                %set those frames to 1 in the activeframes matrix (same
                %dimensions as Z_F)
            end
        end
    end
end

%For trace display purposes, want to show the significant frames as red via
%redframes, but also want to mark as red some frames before and after the
%significant frames, or else only the tips of each peak would be shown as
%red. So, let's also mark as red the 3 frames before and the 8 frames after
%any set of sigframenum consecutive active frames.
for j=1:size(Z_F,2) 
    for i=1:size(Z_F,1)
        if activeframes(i,j)==1 && (i+8 <= size(Z_F,1)) && (i-3 > 0)
            redframes(i-3:i+8,j)=1; 
        end
    end
end
sumactive=sum(activeframes,1); %creates row vector containing, for each ROI (column),
%the number of instances of sigframenum consecutive active frames
%(previously denoted by activeframes=1).
for j=1:size(Z_F,2) 
    if sumactive(j)>=1;
        activeROI(1,j)=1; %populating row vector wherein each value will represent 
        %whether that ROI has sigframenum consecutive active frames or not
    end
end


%calculates the percentage of cells above threshold vs time These
%calculations depend on the value you chose for sigframenum!!!
activepercentline=sum(sigframes,2)/size(Z_F,2)*100;
activepercentsigline=sum(activeframes,2)/size(Z_F,2)*100;
activepercentredline=sum(redframes,2)/size(Z_F,2)*100;

%Now, moving from Z_F to activeROIZ_F. DEFINITION OF ACTIVE ROI = ROI with
%sigframenum consecutive active frames. Want to create a matrix without
%"inactive" ROI's, and without any columns of NaN's that resultedfrom the
%previous heuristic to deal with any ROI's with too many zero values for
%the F matrix.

%3/19/15: Based on analysis during the past few weeks, it seems that all
%ROI's (columns) from Z_F that have values (i.e. are not empty) end up in
%activeROIZ_F.  I.e. it doesn't seem like there are really any "inactive"
%ROIs based on the sigframenum=6 criterion. This is not surprising since
%ROIs are visually selected because they probably show some activity
%(unless you are using a separate red channel like Ruby that is not
%activity-dependent).

%Create a matrix of active ROI numbers
activeROIn=zeros(1,sum(activeROI)); %Creates row vector of zero's, one for 
%each active ROI
ROIcount=0; 
for j=1:size(Z_F,2) %Going col by col (ROI by ROI)
    if activeROI(1,j)==1 %If the indexed ROI is active, add 1 to ROIcount, 
        %and populate activeROIn with that ROI number.
        ROIcount=ROIcount+1;
        activeROIn(1,ROIcount)=j;
    end
end

%Now transfer Z_F values from Z_F to activeROIZ_F. This is where any
%columns of zeros, or inactive ROIs, get filtered out.
activeROIZ_F=zeros(size(Z_F,1),size(activeROIn,2)); %Number of columns matches
%number of ROIs, not the column dimension of Z_F.
for j=1:size(activeROIn,2)
    for i=1:size(Z_F,1)
        activeROIZ_F(i,j)=Z_F(i,activeROIn(j));
    end
end

%Now create a matrix activeredframes that is redframes for just active
%ROI's.
activeredframes=zeros(size(Z_F,1),size(activeROIn,2));
for j=1:size(activeROIn,2)
    for i=1:size(Z_F,1)
        activeredframes(i,j)=redframes(i,activeROIn(j));
    end
end


%--------------End Calculate significance for each ROI-------------------



%------------Correlation Calculation Code-------------------

%Runs for all experiment types version for MATLAB 2012a
% [Rcorr,Pcorr]=corrcoef(Z_F,'Mode','pearson','rows','all'); %this version for MATLAB 2014a
[Rcorr,Pcorr]=corrcoef(Z_F,'rows','all'); %this version for MATLAB 2012a
Rsize=size(Rcorr,1);
Rcorrcolumn=zeros((Rsize^2-Rsize)/2,1); %makes an empty column matrix for R values
Rcount=1;
for i=1:Rsize-1
    for j=i+1:Rsize
        Rcorrcolumn(Rcount)=Rcorr(j,i);
        Rcount=Rcount+1;
    end
end
RcorrcolumnNoZeros=nonzeros(Rcorrcolumn); %Added on 01/08/15, finally.  Because having column's of NaN in Z_F
% results in intermittent zero's in the correlations.

%---------End Correlation Calculation Code-------------------



%----------------PARSE EXCEL DATA FOR INTERMITTENT WHISKER
%STIM--------------

if experimenttype==1
    framerate=1/.128; %because for straight spontaneous, there is no xls from which to pull acquisition info
    % But if want to chop Z_F based on stim timing, need to read xls in
    if outputs(6)==1 % if want to chop spont based on stim timing
%         [xlsdata,~,~]=xlsread(fullxlsfile,'B:B'); Works only on Windows
        xlsdata=csvread(fullxlsfile,0,1); %For Mac use csv file
        displacement=xlsdata(1);
            %framerate=(Fsize(1)+deleted)/(xlsdata(2)-xlsdata(1));
            stimendtimes=xlsdata(5:(numberofstims+4)); %pulls stim end times depending on 
        %how many stims there were (user inputted into GUI)
        stimendframes = stimendtimes*framerate - displacement*framerate;
        stimdurationframes = stimduration*framerate;
        stimstartframes = stimendframes - stimdurationframes;
        disp(['Length of stim in frames: ', (num2str(stimdurationframes))]); 
    end
end

if experimenttype==2 %intermittent stim
%     [xlsdata,~,~]=xlsread(fullxlsfile,'B:B'); %pulls column of stim end times from xls
    xlsdata=csvread(fullxlsfile,0,1); %For Mac use csv file
end

if experimenttype==3 %chronic stim
%     [xlsdata,~,~]=xlsread(fullxlsfile,'B:B');
    xlsdata=csvread(fullxlsfile,0,1); %For Mac use csv file
end

if experimenttype==2
    displacement=xlsdata(1);
        framerate=(Fsize(1)+deleted)/(xlsdata(2)-xlsdata(1));
    stimendtimes=xlsdata(5:(numberofstims+4)); %pulls stim end times depending on 
        %how many stims there were (user inputted into GUI)
    stimendframes = stimendtimes*framerate - displacement*framerate;
    stimdurationframes = stimduration*framerate;
    stimstartframes = stimendframes - stimdurationframes;
    disp(['Length of stim in frames: ', (num2str(stimdurationframes))]); 
        %The above is a check; should be ~7.8
end

stimdurationframes = ceil(stimduration*framerate);
  
%     if framerate/./framerate > 1.02*xlsdata(26)
%         disp 'Warning: Calculated framerate is greater than 2%+ of input
%         framerate.' disp 'Check for deleted frames in video file or a
%         mismatch of F file and XLS file.'
%     end if 1/framerate < .98*xlsdata(26)
%         disp 'Warning: Calculated framerate is less than 2%+ of input
%         framerate.' disp 'Check for deleted frames in video file or a
%         mismatch of F file and XLS file.'
%     end


    
%--------------Calculate averages for Z_F and active ROI Z_F'ss----Added
%1/9/15-------------------
    
    ZFaverage = mean(Z_F);
    activeROIZFavg = mean(activeROIZ_F);
    
if experimenttype==1
    % Calculate average Z_Fs for isolated spont frames
    % Changed from Z_F to activeROIZ_F on Dec 9
    isolatedZF = activeROIZ_F(spontisoframes(1):spontisoframes(end),:);
    isolatedZFavg = mean(isolatedZF);
end
    
%--------------------------------------------------------------------------


%--------Isolate the Z_F data for the two user-defined ranges of ROIs ----
% Added 3/25/15

%   firstsetstims and lastsetstims are row vectors containing the desired
%   stim #'s

%Found error on Dec 9: need to add the timebetweenstims for the last stim
%in each set!!

if outputs(6)==1 || outputs(7)==1
    firstsetstartframe = ceil(stimstartframes(firstsetstims(1)));
    %Edited the below line on Dec 9
    firstsetendframe = ceil(stimendframes(firstsetstims(end)) + framerate*timebetweenstims);
    lastsetstartframe = ceil(stimstartframes(lastsetstims(1)));
    lastsetendframe = ceil(stimendframes(lastsetstims(end)) + framerate*timebetweenstims);
%     stimstartframes %Used these outputs to check when writing this code
%     stimendframes firstsetstartframe firstsetendframe lastsetstartframe
%     lastsetendframe
    
%     firstsetZ_F =
%     zeros(firstsetendframe-firstsetstartframe+1,size(activeROIn,2));
%     lastsetZ_F =
%     zeros(lastsetendframe-lastsetstartframe+1,size(activeROIn,2));
    
    %Changed from Z_F to activeROIZ_F on Dec 9
    %-----Chop activeROIZ_F (all ROIs)
    ZF_firstset = activeROIZ_F(firstsetstartframe:firstsetendframe,:);
    ZF_lastset = activeROIZ_F(lastsetstartframe:lastsetendframe,:);
    ZFavg_firstset = mean(ZF_firstset);
    ZFavg_lastset = mean(ZF_lastset);
    ZF_firstsetMed = median(ZFavg_firstset);
    ZF_lastsetMed = median(ZFavg_lastset);
    
    responsesisolated = zeros(1,4);
    responsesisolated(1,1) = firstsetstims(1);
    responsesisolated(1,2) = firstsetstims(end);
    responsesisolated(1,3) = lastsetstims(1);
    responsesisolated(1,4) = lastsetstims(end);
end



%%%%%%%%%%%%%%%%%%%  OUTPUTS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------OUTPUT RAW Z_F AND CORRS DATA IN EXCEL----------------------------------- 
%Note that redframes / "Active Frames %" depends entirely on sigframenum. If you actually want to run
%further analyses with this particular output, need to choose sigframenum
%very carefully. Updated to single-Excel file output (instead of two files)
%on 3/24/15

if outputs(1)==1
    
%     xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],Z_F,'ZF');
%     xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],activeROIZ_F,'ActiveROIZF');
% %     xlswrite([fullFfile(1:end-4) '_ZF_Corrs'
% %     '.xls'],sum(redframes,1)/Fsize(1)*100,'ActiveFrames%');
%     xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],ZFaverage,'AvgZF');
%     xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],activeROIZFavg,'ActiveROIAvgZF');
%     xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],Rcorrcolumn,'PearsonCorrs');
%     xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],RcorrcolumnNoZeros,'CorrsNoZeros');
    csvwrite([fullFfile(1:end-4) '_ZF_Corrs'  '.csv'],activeROIZ_F,1,1);
%     csvwrite([fullFfile(1:end-4) '_ZF_Corrs'  '.csv'],activeROIZFavg,1,100);
%     csvwrite([fullFfile(1:end-4) '_ZF_Corrs'  '.csv'],RcorrcolumnNoZeros,3,100);
    
    
    
    
    if outputs(6)==1 %Added 3/25/15
%     	xlswrite([fullFfile(1:end-4) '_ZF_Corrs'
%     	'.xls'],firstsetZF,'ZF_FirstSetStims');
%         xlswrite([fullFfile(1:end-4) '_ZF_Corrs'
%         '.xls'],lastsetZF,'ZF_LastSetStims');
        xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],ZFavg_firstset,'AvgZF_FirstSetStims');
        xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],ZFavg_lastset,'AvgZF_LastSetStims');
        xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],responsesisolated,'SelectedStims');
        if experimenttype==1
            xlswrite([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'],isolatedZFavg,'IsolatedZFAvg');
        end
    end
    
%     DeleteEmptyExcelSheets([fullFfile(1:end-4) '_ZF_Corrs'  '.xls'])
    disp(['Excel file created: ' fullFfile(1:end-4) '_ZF_Corrs'  '.xls']);

%     DeleteEmptyExcelSheets([fullFfile(1:end-4) '_Corr_z2m'  '.xls'])
%     disp(['Excel file generated: ', fullFfile(1:end-4),'_Corr_z2m.xls']);
end
%----------End Output Raw Z_F and Corrs Data in Excel-------------------------------

    
%--------------ACTIVE ROIs Z_F PLOT--------------------------------------

if outputs(2)==1

    redline=zeros(size(activeROIZ_F,1),size(activeROIZ_F,2));
    blueline=zeros(size(activeROIZ_F,1),size(activeROIZ_F,2));
    greybar=zeros(size(activeROIZ_F,1),size(activeROIZ_F,2));


    for MOVIE = 1 %:initial.numberofmovies
 
        cellnumber=size(activeROIZ_F,2);
        figcount=1; %Added 3/18/15
        for page = 1:ceil (cellnumber/10)

            figure ((MOVIE*10) + page)
            figHandles(figcount)=gcf; %Added 3/18/15 to make multipagePDF work
            figcount=figcount+1; %Added 3/18/15 to make multipagePDF work
            plot_place=0;
            subplot(10,1,1);

            axis([0 size(activeROIZ_F,1) 0 1.2]);
            axis off;
            for b = ((page-1)*10)+1:((page-1)*10)+10 %position of the subplot based on ROI number
                if (b<=cellnumber)
                    plot_place = plot_place+1;
                    subplot (11,1,plot_place+1); %subplot(10,1,plot_place);

                    %plot specific ROIs in order of preferred direction
                    redcount=0;
                    bluecount=0;
                    greycount=0;

                    for m=1:numberofstims %for all the stims
                        greyframes(floor(stimstartframes(m)):floor(stimendframes(m)),b)=1;
                    end      

                    for j=1:size(activeredframes,2) %makes grey bars
                        greycount=greycount+1;
                        for i=1:size(activeredframes,1)
                            if greyframes(i,b)==1
                                maxZ_F=max(activeROIZ_F(:,b));
                                greybar(i,greycount)=maxZ_F;
                            else
                                greybar(i,greycount)=NaN;
                            end
                        end
                    end
%                     plot(greybar(:,b),'Color',[.9,.9,.9],'LineWidth',15); 
                    area(greybar(:,b),'FaceColor',[.9,.9,.9],'EdgeColor','none');
                    hold on;

                    hline = plot (activeROIZ_F (:,b,MOVIE)); %changed from deltaf_matrix to F(9/11/12) to dF(11/27/12)
                    set(hline,'Color',[0,0,0]);

                    for j=1:size(activeredframes,2)
                        redcount=redcount+1;
                        for i=1:size(activeredframes,1)
                            if activeredframes(i,b)==1
                                redline(i,redcount)=activeROIZ_F(i,b);
                            else
                                redline(i,redcount)=NaN;
                            end
                        end
                    end

                    %calculate blueline
                    for j=1:size(activeredframes,2)
                        bluecount=bluecount+1;
                        for i=1:size(activeredframes,1)
                            if blueframes(i,b)==1
                                blueline(i,bluecount)=activeROIZ_F(i,b);
                            else
                                blueline(i,bluecount)=NaN;
                            end
                        end
                    end

                   %activity time

                    plot(redline(:,b),'Color','red'); %spikes above threshold
                    %plot(blueline(:,b),'Color','green'); %baseline
                    %plot(3*activemaddF(:,b),'Color','blue'); %Cutoff line

                    hold off;

                    set(gca,'YTick',[]);
                    set(gca,'YColor',[1,1,1],'FontName','Helvetica');
                    % if (b<=cellnumber)

                    if roiselect~=0 %use only the good ROIs
                        ylabel(int2str(roiselect(b)),'Color',[0,0,0]);
                    else
                        ylabel(int2str(activeROIn(b)),'Color',[0,0,0]); %added by Lauren on 9/11/12

                    end
                    %end
                    axis tight;
                    box off;

                    if(plot_place==10||b==cellnumber)
                        set(gca,'XTick', 0:size(Z_F,1)/10:size(Z_F,1));
                        %timelabel=0:size(dF,1)/80:size(dF,1)*framerate;
                        %%wrong because 80 should be framerate*10
%                             framerateshort = round(framerate*100)/100;
                        timelabel=0:size(Z_F,1)/(framerate*10):size(Z_F,1)*framerate;
                        set(gca,'XTickLabel',timelabel);

                        hxlabel = xlabel('time (s)');
                        set(hxlabel,'FontName','Helvetica');

                    else
                        %set(hline,'Color',[0,0,0]);
                        set(gca,'XTick', []);
                        set(gca,'XColor',[1,1,1]);

                    end
                    %axis off title (['cell number: ' int2str(b)])
                end
            end


            set(gcf,'Color',[1,1,1]);


        end
        %----------Active Percent Plot:-------- This will create a "Figure
        %99" that shows the percent of ROIs that are active across the
        %frames.  With grey bars if whisker stim.
        figure(99)

        hold on
%         plot(greybar(:,1)+mean(activepercentsigline),'Color',[.9,.9,.9],'LineWidth',75);
        area(greybar(:,1),'FaceColor',[.9,.9,.9],'EdgeColor','none')
        plot(activepercentsigline,'Color',[0 0 0]);
        hold off


    end
        %Multi-page PDF generator code, added 3/18/15, from DC_calcium:
%         hackslash=strfind(fullFfile,filesep);
%         nameString=[fullFfile(hackslash(end)+1:end-4) '_traces'];
%         dirString=fullFfile(1:hackslash(end));
%         DC_multiPagePDF(figHandles, nameString, dirString)
%         close(figHandles)
%         disp(['PDF created: ' fullFfile(1:end-4) '_traces.pdf']);
%         open([fullFfile(1:end-4) '_traces.pdf']);
end
    
    %--------------End Active ROIs Z_F
    %Plot--------------------------------------

    
    
%%------------------Stim overlay plots-----------------
%Use this section to plot all responses and average response of the given
%ROIs to all however-many whisker stims, from 1 sec before stim start to a
%set time after stim end
    
if outputs(3)==1

    %Already generated variables earlier from xls file: framerate,
    %stimendtimes, stimendframes, stimdurationframes, stimstartframes Also
    %have timebetweenstims from GUI Note: stimendframes and stimstartframes
    %already take displacement into account

    %Chop length is from 1 second before stim to no more than
    %timebetweenstims after stim

    if timebetweenstims>3
        timeafterstim = 7.5; %this version for 10-second interval
    else
        timeafterstim = timebetweenstims - 0.2; %this version for 3-second interval;
        %subtract 0.2 sec to be safe;
    end
    framesafterstim = timeafterstim*framerate;
    
    timebeforestim = 1; %for now. Put in GUI for later so you can change the chopping lead time.
    framesbeforestim = ceil(timebeforestim*framerate);
    startchop = stimstartframes - framesbeforestim; %starts chop from 1 sec before stim start
    endchop = stimendframes + framesafterstim; 

    chopsize = ceil(endchop - startchop);
    startchop = ceil(startchop);
    startchop(startchop<0)=1;
    endchop = startchop + chopsize;

    chopint = horzcat(startchop,endchop);

    disp(chopint);
    disp(chopsize);

    %Now extract just the rows of deltaF for each stimulus, based on the
    %chop intervals

    ROIcount = size(activeROIZ_F,2);
    %creates a 3D matrix of all 0's. 3 parameters: ROIs, stimulation (from
    %1 to numberofstims), frames (deltaF data)
    allstimsallROIs = zeros((chopsize(1)+1),numberofstims,ROIcount); 
    %need chopsize(1)+1 because if one element in chopsize is 38, there are actually 39 frames
    
    %Now indexing into this 3D matrix.
    for j = 1:ROIcount %will create the number of matrices, i.e. # of ROIs
        for i = 1:numberofstims %establishes the matrix columns, i.e. the whisker stimulations
%             numberofstims ROIcount i j size(allstimsallROIs)
%             size(activeROIdF) size(chopint) chopint(i,1) chopint(i,2)
            allstimsallROIs(:,i,j) = (activeROIZ_F((chopint(i,1)):(chopint(i,2)),j));
            %establishes the matrix rows, i.e. the deltaF data from the
            %startchop to endchop for each whisker stimulation
        end  
    end
%     disp(allstimsallROIs);

    %In addition to the deltaF response of each ROI to each stimulation,
    %want the average responses of each ROI across all the stims
    avgallstims = mean(allstimsallROIs,2);

    %Now create a 2D matrix of zero's for plotting grey bars
    stimstartframes = ceil(stimstartframes);
    stimendframes = ceil(stimendframes);
    greyint = horzcat(stimstartframes,stimendframes);
    
%     First do a test plot of the average trace for just one ROI.  Say ROI
%     #1.
    
        figure('Color',[1 1 1]);
        
            %Plot the grey bar for stimulus #1
            greybar2 = NaN(chopsize(1),1);
            greybar2((ceil(framesbeforestim)+1):(ceil(framesbeforestim)+ceil(stimdurationframes)))=0;
            plot(greybar2(:,1),'Color',[255/255,204/255,204/255],'LineWidth',75); 
            hold on;
          
            %Plot the individual responses to each of the stimulations
            for test = 1:numberofstims
                plot(allstimsallROIs(:,test,1),'linewidth',2,'color',[.6 .6 .6]);
                hold on
            end

            %Now plot the average trace in the same subplot
            plot(avgallstims(:,1),'linewidth',3,'color','black');
            hold off
            
            set(gca,'XColor',[0,0,0],'FontName','Helvetica');
            tickrate=1; %put this into GUI
            xticks = linspace(1,ceil(framesbeforestim)+ceil(stimdurationframes)+ceil(framesafterstim),framerate*tickrate);
            xticklabels = linspace(-timebeforestim,stimduration+timeafterstim,(size(xticks,2)));
            set(gca,'XTick',xticks);
            set(gca,'XTickLabel',xticklabels);
            set(gca,'YTick',[]);
                               
    %Now, plot all the ROIs, with 24 ROIs per output page.  6 rows, 4
    %columns.
        i=1; %Start counter, which will keep ticking up
        for page = 1:ceil(ROIcount/24)
            page; %creates a page for each set of 24 ROIs
            figure('Name',['ROI Page ' num2str(page)],'Color',[1 1 1],'NumberTitle','off'); 
            %creates a figure for each set of 24 ROIs, so you keep the original single-ROI test plot.

            for plot_place = 1:24 %will go from 1 to 24 for each figure/page of 24 ROIs (#1-24, #25-48, etc)
                
                if i<=ROIcount
                    subplot(6,4,plot_place) %creates the desired grid of 24 mini plots per page 

                    greybar2 = NaN(chopsize(1),1);
                    maxZ_F=max(max(allstimsallROIs(:,:,i)));
                    greybar2((framesbeforestim+1):(framesbeforestim+stimdurationframes))=maxZ_F;
                    area(greybar2(:,1),'FaceColor',[255/255,204/255,204/255],'EdgeColor','none');
%                     plot(greybar2(:,1),'Color',[255/255,204/255,204/255],'LineWidth',75); 
                    hold on;

                    %Plot the individual responses to each of the
                    %stimulations
                    for a = 1:numberofstims
                        plot(allstimsallROIs(:,a,i),'linewidth',2,'color',[.6 .6 .6]);
                        hold on;
                    end

                    %Now plot the average trace in the same subplot
                    plot(avgallstims(:,i),'linewidth',3,'color','black');
   
                    ylabel(int2str(activeROIn(i)),'Color',[0,0,0]); %This labels the miniplot with the ROI number
                    i = i+1; %this ticker keeps on counting up, so that plot_place tracks with the ROI number

                    %formatting axes
                    set(gca,'YColor',[0,0,0],'FontName','Helvetica');
                    set(gca,'YTick', []);
                    axis tight; %sets axis limits to range of data

                    set(gca,'XColor',[0,0,0],'FontName','Helvetica');
                    tickrate=1; %put this into GUI
                    xticks = linspace(1,ceil(framesbeforestim)+ceil(stimdurationframes)+ceil(framesafterstim),framerate*tickrate);
                    xticklabels = linspace(-timebeforestim,stimduration+timeafterstim,(size(xticks,2)));
                    xticklabels = round(10*xticklabels)/10;
                    set(gca,'XTick',xticks);
                    set(gca,'XTickLabel',xticklabels);
                    set(gca,'YTick',[]);
                    
                    hxlabel = xlabel('time (s)');
                    set(hxlabel,'FontName','Helvetica');

                end
            end

        end
        hold off
end

      
    
%------------------End Stim overlay plots--------------------


%%------------------FIRST5/LAST5 STIM OVERLAY PLOTS-----------------
%Added 10/3/15
%Use this section to plot all responses and average response of the top 50%
%most active ROIs (Z-scores) to the first x and last y stims. Plotting from
%1 sec before stim start to 2 s after stim ends.
    
if outputs(7)==1

    %Already generated variables earlier from xls file: framerate,
    %stimendtimes, stimendframes, stimdurationframes, stimstartframes Also
    %have timebetweenstims from GUI Note: stimendframes and stimstartframes
    %already take displacement into account

    %Chop length is from 1 second before stim to no more than
    %timebetweenstims after stim

    if timebetweenstims>3
        timeafterstim = 7.5; %this version for 10-second interval
    else
        timeafterstim = timebetweenstims - 1; %this version for 3-second interval;
        %subtract 0.2 sec to be safe;
    end
    framesafterstim = timeafterstim*framerate;
    
    timebeforestim = 1; %for now. Put in GUI for later so you can change the chopping lead time.
    framesbeforestim = ceil(timebeforestim*framerate);
    startchop = stimstartframes - framesbeforestim; %starts chop from 1 sec before stim start
    endchop = stimendframes + framesafterstim; 
%     
%     firstsetendchop = firstsetendframe + framesafterstim; lastsetendchop
%     = lastsetendframe + framesafterstim;
%    
    chopsize = ceil(endchop - startchop);
    startchop = ceil(startchop);
    endchop = startchop + chopsize;

    chopint = horzcat(startchop,endchop); 
    %this is an m x 2 matrix with the start and end times for the chopping
    %around each of m stims.
    
    disp(chopint);
    disp(chopsize);
    
    set1chopint = chopint(firstsetstims(1):firstsetstims(end),:);
    set2chopint = chopint(lastsetstims(1):lastsetstims(end),:);

    %Now extract just the rows of ZF for each of x stimuli, based on the
    %chop intervals

    %Sort ROI Z_F data in order of highest to lowest average Z_F
    [sortedZFavg,testvar] = sort(activeROIZFavg,'ascend');
    sortedactiveZF = activeROIZ_F(:,testvar); 
    
    plotcount = ROIcount; %Only plotting the top 50% of ROIs based on Z_F
%     plotcount = ROIcount; %Plotting all of the ROI's.
    %create a 3D matrix of all 0's. 3 parameters: ROIs, stimulation (from 1
    %to numberofstims), frames (deltaF data)
    plotstims = firstsetstims(end);
    
    set1 = zeros((chopsize(1)+1),plotstims,plotcount); %need chopsize(1)+1 because if one element in chopsize is 38, there are actually 39 frames
    set1mads = zeros(plotcount,plotstims);
    set2 = zeros((chopsize(1)+1),plotstims,plotcount);
    set2mads = zeros(plotcount,plotstims);
    madsavg = zeros(plotcount,2);
    
    %Now indexing into this 3D matrix (set1 and set2).
    for j = 1:plotcount %will create the number of matrices, i.e. # of ROIs to be plotted
        for i = 1:plotstims %establishes the matrix columns, i.e. the first x whisker stimulations
%             numberofstims ROIcount i j size(allstimsallROIs)
%             size(activeROIdF) size(chopint) chopint(i,1) chopint(i,2)
            set1(:,i,j) = (sortedactiveZF((set1chopint(i,1)):(set1chopint(i,2)),j));
            %establishes the matrix rows, i.e. the ZF data from the
            %startchop to endchop for each whisker stimulation
            set1mads(j,i) = mad(set1(:,i,j),1);
        end
        madsavg(j,1) = mean(set1mads(j,:));
    end
    
	for j = 1:plotcount 
        for i = 1:plotstims 
            set2(:,i,j) = (sortedactiveZF((set2chopint(i,1)):(set2chopint(i,2)),j));
            set2mads(j,i) = mad(set2(:,i,j),1);
        end  
        madsavg(j,2) = mean(set2mads(j,:));
	end
%     disp(allstimsallROIs);

    %In addition to the deltaF response of each ROI to each stimulation,
    %want the average responses of each ROI within the first and second
    %sets of stims
    avgset1 = mean(set1,2);
    avgset2 = mean(set2,2);

    %Now create a 2D matrix of zero's for plotting grey bars
    stimstartframes = ceil(stimstartframes);
    stimendframes = ceil(stimendframes);
    greyint = horzcat(stimstartframes,stimendframes);
    
%     First do a test plot of the traces for just one ROI.  Say ROI #1 in
%     the sorted data.
    
        figure('Color',[1 1 1]);
        
            %Plot the grey bar for stimulus #1
            greybar2 = NaN(chopsize(1),1);
            greybar2((ceil(framesbeforestim)+1):(ceil(framesbeforestim)+ceil(stimdurationframes)))=0;
            plot(greybar2(:,1),'Color',[255/255,204/255,204/255],'LineWidth',100); 
            hold on;
          
            %Plot the individual responses to each of the stimulations
            for test = 1:plotstims
                plot(set2(:,test,1),'linewidth',1,'color',[.6 .6 .6]);
                hold on
            end

            %Now plot the average trace in the same subplot
            plot(avgset2(:,1),'linewidth',2,'color','black');
            hold off
            
            set(gca,'XColor',[0,0,0],'FontName','Helvetica');
            tickrate=1; %put this into GUI
            xticks = linspace(1,ceil(framesbeforestim)+ceil(stimdurationframes)+ceil(framesafterstim),timebeforestim+timeafterstim+stimduration+1);
            xticklabels = linspace(-timebeforestim,stimduration+timeafterstim,(size(xticks,2)));
            xticklabels = round(10*xticklabels)/10;
            set(gca,'XTick',xticks);
            set(gca,'XTickLabel',xticklabels);
            set(gca,'YTick',[]);
            
 
%     Now, plot all the ROIs, with the first set of stims in the first
%     column and second set of stims in the second column, 10 plots/page.
        
         i=1;
        for page = 1:ceil((plotcount*2)/10)
            page; %creates a page for each set of 10
            figure('Name',['ROI Page ' num2str(page)],'Color',[1 1 1],'NumberTitle','off'); 
            %creates a figure for each set of 10 ROIs, so you keep the original single-ROI test plot.
            
%             i=1;
            for plot_place = 1:2:10 %Start with left column (odd numbers)
                
                subplot(5,2,plot_place);
             
                if i<=plotcount

                    greybar2 = NaN(chopsize(1),1);
                    greybar2((framesbeforestim+1):(framesbeforestim+stimdurationframes))=0;
                    plot(greybar2(:,1),'Color',[255/255,204/255,204/255],'LineWidth',100); 
                    hold on;

                    %Plot the individual responses to each of the stims
                    %using 'set1' 
                    for a = 1:plotstims
                        plot(set1(:,a,i),'linewidth',1,'color',[.6 .6 .6]);
                        hold on
                    end

                    %Now plot the average trace in the same subplot
                    plot(avgset1(:,i),'linewidth',2,'color','black');
   
                    ylabel(int2str(activeROIn(i)),'Color',[0,0,0]); %This labels the miniplot with the ROI number
%                     i = i+1; %this ticker keeps on counting up, so that plot_place tracks with the ROI number
                
                                        %formatting axes
                    set(gca,'YColor',[0,0,0],'FontName','Helvetica');
                    set(gca,'YTick', []);
                    axis tight; %sets axis limits to range of data

                    set(gca,'XColor',[0,0,0],'FontName','Helvetica');
                    tickrate=1; %put this into GUI
                    xticks = linspace(1,ceil(framesbeforestim)+ceil(stimdurationframes)+ceil(framesafterstim),timebeforestim+timeafterstim+stimduration+1);
                    xticklabels = linspace(-timebeforestim,stimduration+timeafterstim,(size(xticks,2)));
                    xticklabels = round(10*xticklabels)/10;
                    set(gca,'XTick',xticks);
                    set(gca,'XTickLabel',xticklabels);
                    set(gca,'YTick',[]);

                    hxlabel = xlabel('time (s)');
                    set(hxlabel,'FontName','Helvetica');      
                end
                
                subplot(5,2,plot_place+1); %Now fill the right column of each page

                if i<=plotcount

                    greybar2 = NaN(chopsize(1),1);
                    greybar2((framesbeforestim+1):(framesbeforestim+stimdurationframes))=0;
                    plot(greybar2(:,1),'Color',[255/255,204/255,204/255],'LineWidth',100); 
                    hold on;

                    %Plot the individual responses to each of the stims
                    for a = 1:plotstims
                        plot(set2(:,a,i),'linewidth',1,'color',[.6 .6 .6]);
                        hold on
                    end

                    %Now plot the average trace in the same subplot
                    plot(avgset2(:,i),'linewidth',2,'color','black');
   
                    ylabel(int2str(activeROIn(i)),'Color',[0,0,0]); %This labels the miniplot with the ROI number
                    i = i+1; %this ticker keeps on counting up, so that plot_place tracks with the ROI number
           
                    %formatting axes
                    set(gca,'YColor',[0,0,0],'FontName','Helvetica');
                    set(gca,'YTick', []);
                    axis tight; %sets axis limits to range of data

                    set(gca,'XColor',[0,0,0],'FontName','Helvetica');
                    tickrate=1; %put this into GUI
                    xticks = linspace(1,ceil(framesbeforestim)+ceil(stimdurationframes)+ceil(framesafterstim),timebeforestim+timeafterstim+stimduration+1);
                    xticklabels = linspace(-timebeforestim,stimduration+timeafterstim,(size(xticks,2)));
                    xticklabels = round(10*xticklabels)/10;
                    set(gca,'XTick',xticks);
                    set(gca,'XTickLabel',xticklabels);
                    set(gca,'YTick',[]);

                    hxlabel = xlabel('time (s)');
                    set(hxlabel,'FontName','Helvetica');      
                   
                end
            end

        end
        hold off
        
    %Output average MADs: first column is averaged MADs for first __ stims,
    %second column is averaged MADs for last __ stims.
    xlswrite([fullFfile(1:end-4) '_overlays_' num2str(plotstims) '.xls'],madsavg,'AverageMADs');
    DeleteEmptyExcelSheets([fullFfile(1:end-4) '_overlays_' num2str(plotstims) '.xls'])
    disp(['Excel file created: ' fullFfile(1:end-4) '_overlays_' num2str(plotstims) '.xls']);
    
end

      
    
%------------------END FIRST5/LAST5 OVERLAY PLOTS--------------------



%-------------------Stim response significance-------------------

%Calculation code is taken from DC_signal_significance2
%UPDATED ON 11/20/15 WITH NEW VERSION
    
if outputs(4)==1

    %first need to generate "stimulus_trace" input based on the information
    %previously pulled from xls file
    
    stimulus_trace=zeros(size(activeROIZ_F,1),1);
    
    stimstartframes = ceil(stimstartframes);
    stimendframes = ceil(stimendframes);
    
    %For stimstartframes to stimendframes, set stimulus_trace value to 1.
    for c = 1:size(stimstartframes,1)
        stimulus_trace(stimstartframes(c):stimendframes(c))=1;
    end
    
    %Added 9/8/15
    ZFout=zeros(size(activeROIZ_F,1),size(activeROIZ_F,2),2);
    
    signal_traces=activeROIZ_F;
%     Z_F=[];
    
%     size(stimulus_trace) pause
%Used this to check that stimulus_trace was generating correctly
         
    %--start DC_signal_significance
%     function
%     [signal_corr,signal_delay,signal_percentile]=DC_signal_significance(stimulus_trace,signal_traces,maxlagframes,scrambles)
    %Why, hello there! This script was written by Daniel Cantu originally
    %to correlate whisker stimuli with fluorescent traces
    %    obtained with 2-photon imaging of GCaMP6S in the mouse barrel
    %    cortex. This is a flexible script and should be adaptable to
    %    comparing stimuli with various types of recorded output signals.
    %
    %The general function of this script is to take a set of fluorescent
    %signals and a single stimulus vector to which they were
    %    all subjected. Then, for each individual trace, it compares the
    %    trace to the stimulus and attempts to find the delay time between
    %    the stimulus and the recorded signal. The signal and stimulus
    %    traces are then aligned and the correlation between them is found.
    %    Then, this is repeated a number of times set by the user using
    %    many randomly-scrambled sets of data (1000+, generally). The
    %    correlation of the actual signal vs the array of scrambled signals
    %    are compared and the percentile rank of the actual amongst the
    %    scrambled is found. It's pretty cool.
    %
    %-----------Inputs------------
    %stimulus_trace is a column vector of the stimulus where 0 is no stimulus and 1 is a stimulus.
    %signal_traces is a matrix of the traces of your signal, which can be dF/F, Z-scores, raw F, etc.
    %    The format of this is that your individual traces are each in column vectors.
    %maxlagframes is the maximum number of frames your signal can lag behind the stimulus. This should definitely not be greater than
    %    the period between repeated presentations of a stimulus.
    %scrambles is the number of scrambles to perform and compare. 1,000 is generally a good number, but 10,000 works if you have time to spare
    %    and you happen to have a rather long signal and would, thus, like to try a large number of combinations.
    %threshold_value is the value of which a trace must pass in order to be
    %   considered significant (e.g. 3 for Z-score-based traces, 1 for stimulus trace).
    threshold_value = 3;
    %threshold_frames is the number of frames which a trace must pass in order
    %   to be considered significant. (6 for GCaMP6 8hz, at least 1 for stimlus trace)
    threshold_frames = 4; %based on sigframenum
    %before_frames is the number of frames to add before the initial passing of
    %   threshold, in order to find the true start of the epoch (3 for GCaMP6 8hz, 0 for stimulus trace)
    before_frames = 3;
    %after_frames is the number of frames to add after the final passing of threshold (8 for GCaMP6 8hz, 0 for stimulus trace)
    after_frames = 8;
    %reference is where you select what is going to be used for scrambling. Enter 'signal' for scrambling the signal trace,
    %    enter 'stim' for scrambling the stimulus trace. 
    reference = 'signal';
    %
    %-----------Outputs-----------
    %signal_corr is the correlation (R) of your signals to the stimulus in a matrix.
    %    These correlation numbers are bound to be low if you're comparing a square-pulse stimulus to long-tailed
    %    traces such as those produces by GCaMPs. What matters more is the comparison to scrambled data.
    %signal_delay are the delay times of your individual signals relative to the presentation of a stimulus in frames.
    %    If you get a mix of positive and negative values, you can use the absolute value to determine the magnitude of
    %    the delay. If presenting multiple stimuli that are spread apart, you should get a consistent sign in cells that
    %    are considered to be actually responsive. If you are analyzing delays, don't forget to exclude cells that aren't
    %    significantly correlated to the stimulus (relative to scrambles).
    %signal_percentile is the percentile rankings of your signal traces relative to the scrambled traces.
    %    Commonly accepted cut-offs for percentile are typically top 5% or 1% (0.05 or 0.01).
    %    This is non-parametric and does not assume normality. Yay!
    %    Since all traces are being compared internally to scrambled versions of themselves, differences in levels 
    %    of fluorescent calcium indicator between ROIs don't impact results. Woohoo! :)
    tic
    %matrix initialization
    signal_delay=zeros(1,size(signal_traces,2));
    signal_corr=zeros(1,size(signal_traces,2)); 
    signal_percentile=zeros(1,size(signal_traces,2));

    %pulling # lag frames and # scrambles from the GUI outputs
    maxlagframes=lagframes;
    scrambles=numscrambles;
    
    pcount = 0;
        %Added 9/2/15: subsetting signal delays for just the ROIs that are
        %"significant"
        signal_delay_sigp=NaN(1,size(signal_traces,2));

    for ROI=1:size(signal_traces,2) %Goes through each ROI's trace individually
        [Xa,Ya,signal_delay(ROI)]=alignsignals(stimulus_trace,signal_traces(:,ROI),maxlagframes); %Aligns signal and stimulus, finds delay time
        R=corrcoef(Xa(1:size(signal_traces,1)),Ya(1:size(signal_traces,1))); %finds correlation of aligned traces
        if length(R)==1
            signal_corr(ROI)=R(1,1); %Use this version for MATLAB 2014a
        else
            signal_corr(ROI)=R(2,1); %Use this version for older versions of MATLAB
        end 
        scram_corrs=zeros(1,scrambles+1); %resets scramble correlations to zeros, leaves a space at the end for comparing your trace
        if strcmp(reference,'signal')==1 
             %Performs epoch-based scrambling of Signal trace
            scram_traces=DC_epoch_scram(signal_traces(:,ROI),scrambles,threshold_value,threshold_frames,before_frames,after_frames);
            %Compares scrambled signal traces to stimulus
            for scram=1:scrambles %does all the scrambles
                [Xa,Ya,~]=alignsignals(stimulus_trace,scram_traces(:,scram),maxlagframes); %aligns by same parameters as original data
                R=corrcoef(Xa(1:size(signal_traces,1)),Ya(1:size(signal_traces,1))); %correlation of the scrambles are stored
                if length(R)==1
                    scram_corrs(scram)=R(1,1); 
                else
                    scram_corrs(scram)=R(2,1);
                end
            end
        elseif strcmp(reference,'stim')==1
            %Performs epoch-based scrambling of Stimulus trace
            scram_stim=DC_epoch_scram(stimulus_trace,scrambles,threshold_value,threshold_frames,before_frames,after_frames);
            %Compares scrambled stimuli traces to raw signal trace
            for scram=1:scrambles 
                [Xa,Ya,~]=alignsignals(scram_stim(:,scram),signal_traces(:,ROI),maxlagframes); %aligns by same parameters as original data
                R=corrcoef(Xa(1:size(signal_traces,1)),Ya(1:size(signal_traces,1))); %correlation of the scrambles are stored
                if length(R)==1
                    scram_corrs(scram)=R(1,1); 
                else
                    scram_corrs(scram)=R(2,1);
                end
            end
        else
            error('Error: must enter a valid string for input variable Reference!') %Error if incorrect string entered as input
        end
        scram_corrs(scrambles+1)=signal_corr(ROI); %throws your ROI of interest's correlation into the list and then finds its rank
        signal_percentile(ROI)=find(sort(scram_corrs,'descend')==signal_corr(ROI),1,'first')/size(scram_corrs,2); %percentile is calculated
        %    lower value for signal_percentile are more significant.
        disp(['Percent complete: ' num2str(ROI/size(signal_traces,2)*100)]);
        
        %Added 9/2/15
        if signal_percentile(ROI)<=percentile
            pcount = pcount+1;
            signal_delay_sigp(ROI)=signal_delay(ROI);
        else
            signal_delay_sigp(ROI)=1000;
        end
        
    end


    
    
%     ZFout(:,:,1)=activeROIZ_F;
%     ZFout(1,:,2)=signal_delay_sigp;
        % Or can sort activeROIZ_F by a vector (signal_delay_sigp), as long
        % as dimensions are ok?
        
    %----end DC_signal_significance
    
    %Tally the number of ROI's that have a significant percentile (value of
    %percentile pulled from GUI input)
    
    % 9/2/15: Integrated pcount into the previous for-loop
%     pcount = 0; for d = 1:size(signal_percentile,2)
%         if signal_percentile(d)<percentile
%             pcount = pcount+1;
%         end
%     end
    
    
   
signal_percentile
pcount
percent_responsive=pcount/cellnumber

%Finally, put the outputs into an Excel file
%     xlswrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.xls'],signal_delay,'Signal delays');
%     xlswrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.xls'],signal_corr,'Signal corrs');
%     xlswrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.xls'],signal_percentile,'Signal percentiles');
%     xlswrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.xls'],pcount,'Significant ROIs');
%     xlswrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.xls'],signal_delay_sigp,'Sig ROI delays');
%     DeleteEmptyExcelSheets([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.xls'])
%     csvwrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.csv'],signal_delay,1,1);
%     csvwrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.csv'],signal_corr,2,1);
%     csvwrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.csv'],signal_percentile,3,1);
%     csvwrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.csv'],pcount,4,1);
%     csvwrite([fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.csv'],signal_delay_sigp,5,1);
%     disp(['CSV file created: ' fullFfile(1:end-4) '_stimrespsig_' num2str(scrambles) '_lag' num2str(maxlagframes) '_p' num2str(percentile) '.csv']);
 
end
    
%--------End stim response
%significance---------------------------------------------------


%-----SAVE OUTPUTS-----

 fullFname=[fullFfile(1:end-4) '_analyzed_'  '.mat'];
 save(fullFname);

end



