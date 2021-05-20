# DC_Calcium-Analysis-Scripts
Matlab scripts for analysis of 2P Ca Imaging Data extracted using DC Calcium

The scripts contained in this repository were generated specifically to analyze calcium imaging fluorescence traces extracted using DC Calcium

1) CaImageRandomization.m can be used to randomize and blind 2P imaging data (tif files) for further analysis using DC_Calcium
2) CH_Analyze2.m can be used to import extracted fluoresence traces (from DC_Calcium) and associated stimulus timing info to determine stimulus-locking of individual cells
3) SW_stimpeakanalysis.m can be used after CH_Analyze2 to quantify information on sensory-evoked calcium transients (peak amplitude, latency to peak, % of stimuli with a peak response, etc).
