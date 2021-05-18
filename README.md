# EEG Music-listening Experiment Dataset

## Description of the dataset
This dataset contains recordings of EEG during music-listening from an experiment conducted at the School of Music Studies of the Aristotle University of Thessaloniki (AUTh). Twenty AUTh students (mean(std) age: 22.7 (+/- 2.8) y.o.; 10 females; 6 without any musical training) were invited to participate in a personalized music-listening experiment.

The experiment followed a passive music-listening design and consisted of two stages:  
1. the songs playlist compilation and 
2. the “actual” music-listening during which the brain activity was recorded in strict association with the playlist.

## Ratings assignment and song selection
Participants were initially guided to compile their own personalised playlists. For each playlist, in accordance with the participant’s musical taste, the selected songs had to be uniformly distributed among the following three numerically-ranked categories: 
- 1 or low rating: “This song is OK, but nothing special”, 
- 3 or medium rating: “I like this song and would listen again”, 
- 5 or high rating: “this song belongs to my favourites”. 

During the preparatory phase of the experiment, every participant worked closely with an assistant to prepare his personalized playlist by allocating 10 songs in each of the three ranked groups (1,3,5). An 80-second audio thumbnail extract was carefully selected for each song, focusing on the verse-chorus summarization and following a section-transition strategy to capture its “hook”.

## Recording information
Brainwave data were then acquired using Emotiv EPOC+ mobile EEG recording headset (http://emotiv.com). The experiment started with the recording of resting-state EEG activity for each participant (70s), followed by the random playback of all 30 songs with a 10-second silence period in-between. Consequently, the resulting dataset consisted of 30 music-listening EEG trials with a duration of 80s for each participant. The participants were instructed to sit comfortably and enjoy the music, while a short break of 2-3 minutes was induced half-way (without removing the EEG headset) for their convenience. 

## Citation
When using this dataset, please site the original publication:

**Bakas, S., Adamos, D. A., & Laskaris, N. (2021)**.*On the estimate of Music Appraisal from surface EEG :  a dynamic-network approach based on Cross-Sensor PAC measurements. Journal of neural engineering*, 10.1088/1741-2552/abffe6. Advance online publication. https://doi.org/10.1088/1741-2552/abffe6

## Pre-processing
The preprocessing of the raw EEG signals was carried out in Matlab. The raw EEG multichannel signals were filtered within the 1-45 Hz range using a zero-phase band-pass filter (3rd order Butterworth). To remove artifactual activity from eyes, muscle and cardiac interference we resorted to independent component analysis (ICA) . Artifact suppression was carried out separately for each trial, based on an in-house implementation of wavelet-enhanced ICA (wICA). Specifically, the independent components (ICs), derived of the multichannel signal were detected by employing ICA with the use of the EEGLAB  Matlab toolbox. Subsequently, wavelet decomposition based on wavelets of the biorthogonal family and wavelet shrinkage with a hard threshold based on false discovery rate were applied to each one of the ICs. The multichannel signal was then reconstructed based on the artifact-free ICs. 

## Dataset contents
The dataset consists of 20 mat files, each one containing the data of a single subject. Specifically, for each mat (e.g. music_listening_experiment_s01.mat):
- **EEG_Rest** (*n_sensors × n_time_points* double): 70s of resting state EEG for the subject
- **EEG_Songs** (*n_songs × n_sensors × n_time_points* double): 80s of music-listening EEG  for each song for the subject
- **song_ratings** (*1 × n_songs* double): subjective liking ratings assigned by the subject for each song
- **Fs** (double): the sampling frequency of the EEG (i.e. 128 Hz)
- **sensor_info** (struct): information about the EEG sensors used:
  - **labels** (*n_sensors × 1* cell): sensor labels according to the international 10-20 system
  - **loc** (*n_sensors × 2* double): sensor coordinates in the 2D plane
