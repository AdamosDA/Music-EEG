% Demo demonstating the utility of the music-listening EEG dataset first presented in
% "On the estimate of Music Appraisal from surface EEG :
%  a dynamic-network approach based on Cross-Sensor PAC measurements".
% Dataset: 30 music-listening EEG trials of a 20 subjects
%          and their corresponding liking scores as assigned by the
%          subject
% Demo steps:
% 			 1) load dataset
% 			 2) common reference
% 			 3) calculate-plot PSD
% 			 4) train and evaluate simple classifier
% Stylianos Bakas 2021 (https://orcid.org/0000-0003-1054-0169)


%%_______   Create Dataset from all subjects
clear;
Nsubjects=20;
for subj_id=1:Nsubjects
    filename=sprintf('music_listening_experiment_s%.2d.mat',subj_id);
    load(filename);
    EEG_Songs_all(subj_id,:,:,:) = EEG_Songs;
    EEG_Rest_all(subj_id,:,:) = EEG_Rest;
    song_ratings_all(subj_id,:) = song_ratings;
    clearvars EEG_Songs EEG_Rest song_ratings
end

% load numnumber of subjects(20), songs (30), sensors (14) and samples (80s * 128Hz = 10240)
[Nsubjects, Nsongs,Nsensors,N_time_song] = size(EEG_Songs_all);
% select a subject (e.g. subject 4)
subj_id = 4;
subject_trials = squeeze(EEG_Songs_all(subj_id,:,:,:));
subject_ratings = song_ratings_all(subj_id,:);

%%_______   Preprocesing : rereferencing
%Common Reference
for i_song=1:size(subject_trials,1) % loop over songs
    singleSong_EEG = squeeze(subject_trials(i_song,:,:)); %single trial
    singleSong_EEG = singleSong_EEG-repmat(mean(singleSong_EEG),14,1); % common-rereferencing
    subject_trials(i_song,:,:) = singleSong_EEG; end
	
%%_______   Calculate and plot PSD
% Calculate PSD
Trial_PSD=[]; for i_song=1:size(subject_trials,1) % loop over songs
    singleSong_EEG = squeeze(subject_trials(i_song,:,:)); %single trial
    [Px,Faxis] = pwelch(singleSong_EEG',128,100,256,Fs,'onesided'); %Welch method
    Px = Px'; Px = Px(:,3:91); Faxis = Faxis(3:91); Song_PSD =Px;  % Isolate frequency content in the [1-45]Hz range
    Trial_PSD(i_song,:,:) = Song_PSD; end
%Calculate the average PSD profile for the high and low rating trials
high_rating_mean_PSD = squeeze(mean(Trial_PSD(subject_ratings==5,:,:),1));
low_rating_mean_PSD = squeeze(mean(Trial_PSD(subject_ratings==1,:,:),1));
%Calculate the relative difference between the mean PSD of the high and low
%rating songs
ft_relative_diff = 100* (high_rating_mean_PSD - low_rating_mean_PSD) ./ low_rating_mean_PSD;
%Plot the relative chang
imagesc(ft_relative_diff);
%Plot horizontal lines to illustrate the frequency bands of brain rhythms
%delta(1-4Hz), theta(5-8Hz), alpha(8-13Hz), low beta(13-20Hz), 
%high beta(20-30Hz), gamma(30-45Hz) 
xline(0.5+3*2);xline(0.5+7*2);xline(0.5+12*2);xline(0.5+19*2);xline(0.5+29*2);xline(0.5+44*2);
%Create and center colorbar
colormap(jet); 
cbar = colorbar; caxis([-max(max(abs(ft_relative_diff))),+max(max(abs(ft_relative_diff)))]);
%Label colorbar
ylabel(cbar,'Relative magnitude change (%)','fontsize',13,'fontweight','normal');
cbar.FontSize=11;
%Label axes
set(gca,'ytick',1:14)
set(gca,'yTickLabel',{'AF3','F7','F3','FC5','T7','P7','01','02','P8','T8','FC6','F4','F8','AF4'},'fontsize',11)
ylabel('Sensor','fontsize',13)
set(gca,'xtick',[0.5,0.5+2*3,0.5+2*7,0.5+2*12,0.5+2*19,0.5+2*29,0.5+2*44])
set(gca,'xTickLabel',[1,4,8,13,20,30,45],'fontsize',11)
xlabel('Frequency (Hz)','fontsize',13)
box off; grid off ;axis square ;set(gcf,'color','white');

%%_______   Standard Feature Screening with RELIEFF and Regression SVM based on PSD-representation         
%This part is indicative about the potential to model the likeness from the data
Predictors=reshape(Trial_PSD,size(Trial_PSD,1),14*89);  %Reshape to create a feature vector (PSD) for each trial
[RANKS,Scores] = relieff(Predictors,subject_ratings',5,'method','regression'); %RELIEFF to rank features
sel_list=find(Scores>0);selDATA=Predictors(:,sel_list); %keep only features with a positive RELIEFF score
mdl = fitrsvm(selDATA,subject_ratings,'crossval','on','KFold',5,'standardize','on'); %Train and validate a simple SVM (5-fold cross validation)
MSE =(kfoldLoss(mdl)); % calcuate Mean Squared Error 
MAE=sqrt(MSE); % calcuate Mean Absolute Error 
disp(['MAE, MSE of the example simple SVM model based on PSD: ', num2str(MAE), ', ', num2str(MSE)])
