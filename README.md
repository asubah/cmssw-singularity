# Singularity Container for CMSSW
*Note*: This is still being worked on.

This project is about making a Singularity/Apptainer container to run the CMSSW workflow outside the CERN system without needing the internet.

# Building the Container
To build the container, you need to set the `SINGULARITY_TMPDIR` environment variable. If the container image is too big for `/tmp`, it won't work.

```bash
export SINGULARITY_TMPDIR=~/.tmp
# or
export APPTAINER_TMPDIR=~/.tmp
sudo -E apptainer build cmssw-almalinux-8.sif cmssw-almalinux-8.sdf
```

# Using the Container
Here's how to use the container to run the CMSSW limited workflow. The goal is to make it work like it does on lxplus or other CERN systems.

We'll use two directories:

- `./squid`: This folder has the squid.conf file and will store the cached data later.
- `./lhapdfsets`: This folder has [LHADPF](https://lhapdf.hepforge.org/index.html) sets for the workflow.

```bash
apptainer shell --bind ./squid/:/squid --bind ./lhapdfsets/:/lhapdfsets cmssw-almalinux-8.sif
```

We're using Squid to cache requests data so we can run things later without the internet.
```bash
# Create the cache directories (do this only once).
squid -f /squid/squid.conf -z

# Start the Squid server
squid -f /squid/squid.conf

# (Optional) Check if Squid is running
ps aux | grep squid
```

Next, follow the regular CMSSW steps:
```bash
source /data/cmssw/cmsset_default.sh
cmsrel CMSSW_13_0_0
mkdir CMSSW_13_0_0/run
cd CMSSW_13_0_0/run/
cmsenv
```

If you have a grid certificate in ~/.globus, use it to connect to the grid. If not, skip this.
```bash
voms-proxy-init --rfc --voms cms
```

Running `cmsenv` will reset `LHAPDF_DATA_PATH`. Hence, set it after running cmsenv:
```bash
export LHAPDF_DATA_PATH=/lhapdfsets
```

Then, run the workflow:
```bash
runTheMatrix.py -j 4 -t 2 --nStreams 2 -l limited
```

After you've run it on a machine with internet access, just package up the container image, the ./squid directory, and any other necessary files. Move them to an offline machine, and they should work correctly.

# Results
When you run using the grid certificate, you should see the following output:
```
4.22_RunCosmics2011A Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN  - time date Sat Jul 29 09:28:48 2023-date Sat Jul 29 09:28:12 2023; exit: 1 0 0 0 0
4.53_RunPhoton2012B Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN  - time date Sat Jul 29 09:28:15 2023-date Sat Jul 29 09:28:12 2023; exit: 1 0 0 0
5.1_TTbarFS Step0-PASSED Step1-PASSED  - time date Sat Jul 29 09:29:38 2023-date Sat Jul 29 09:28:13 2023; exit: 0 0
7.3_CosmicsSPLoose2018 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 09:32:08 2023-date Sat Jul 29 09:28:13 2023; exit: 0 0 0 0 0
8.0_BeamHalo Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 09:30:35 2023-date Sat Jul 29 09:28:16 2023; exit: 0 0 0 0 0
9.0_Higgs200ChargedTaus Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Sat Jul 29 09:34:04 2023-date Sat Jul 29 09:28:49 2023; exit: 0 0 0 0
25.0_TTbar Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 09:35:24 2023-date Sat Jul 29 09:29:38 2023; exit: 0 0 0 0 0
135.4_ZEEFS_13 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Sat Jul 29 09:33:18 2023-date Sat Jul 29 09:30:36 2023; exit: 0 0 0 0
136.731_RunSinglePh2016B Step0-PASSED Step1-FAILED Step2-NOTRUN Step3-NOTRUN  - time date Sat Jul 29 09:34:50 2023-date Sat Jul 29 09:32:08 2023; exit: 0 21504 0 0
136.7611_RunJetHT2016EreMINIAOD Step0-PASSED Step1-FAILED Step2-NOTRUN  - time date Sat Jul 29 09:37:00 2023-date Sat Jul 29 09:33:19 2023; exit: 0 21504 0
136.793_RunDoubleEG2017C Step0-PASSED Step1-FAILED Step2-NOTRUN Step3-NOTRUN  - time date Sat Jul 29 09:35:47 2023-date Sat Jul 29 09:34:04 2023; exit: 0 21504 0 0
136.8311_RunJetHT2017FreMINIAOD Step0-PASSED Step1-PASSED Step2-PASSED  - time date Sat Jul 29 09:41:26 2023-date Sat Jul 29 09:34:51 2023; exit: 0 0 0
136.874_RunEGamma2018C Step0-PASSED Step1-FAILED Step2-NOTRUN Step3-NOTRUN  - time date Sat Jul 29 09:37:08 2023-date Sat Jul 29 09:35:24 2023; exit: 0 21504 0 0
136.88811_RunJetHT2018DreMINIAODUL Step0-PASSED Step1-FAILED Step2-NOTRUN  - time date Sat Jul 29 09:38:14 2023-date Sat Jul 29 09:35:48 2023; exit: 0 21504 0
138.4_PromptCollisions2021 Step0-PASSED Step1-PASSED Step2-PASSED  - time date Sat Jul 29 09:45:34 2023-date Sat Jul 29 09:37:01 2023; exit: 0 0 0
138.5_ExpressCollisions2021 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Sat Jul 29 09:45:53 2023-date Sat Jul 29 09:37:09 2023; exit: 0 0 0 0
139.001_RunMinimumBias2021 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Sat Jul 29 09:47:22 2023-date Sat Jul 29 09:38:15 2023; exit: 0 0 0 0
140.53_RunHI2011 Step0-PASSED Step1-FAILED Step2-NOTRUN  - time date Sat Jul 29 09:43:51 2023-date Sat Jul 29 09:41:27 2023; exit: 0 21504 0
140.56_RunHI2018 Step0-PASSED Step1-FAILED Step2-NOTRUN  - time date Sat Jul 29 09:46:10 2023-date Sat Jul 29 09:43:51 2023; exit: 0 21504 0
158.01_HydjetQB12ppRECOin2018reMINIAOD Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Sat Jul 29 09:45:36 2023-date Sat Jul 29 09:45:35 2023; exit: 1 0 0
1306.0_SingleMuPt1_UP15 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Sat Jul 29 09:49:19 2023-date Sat Jul 29 09:45:37 2023; exit: 0 0 0 0
1330.0_ZMM_13 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 09:50:30 2023-date Sat Jul 29 09:45:54 2023; exit: 0 0 0 0 0
2018.1_TTbarFS_13_UP18 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Sat Jul 29 09:49:00 2023-date Sat Jul 29 09:46:10 2023; exit: 0 0 0 0
101.0_SingleElectronE120EHCAL Step0-PASSED  - time date Sat Jul 29 09:48:25 2023-date Sat Jul 29 09:47:23 2023; exit: 0
312.0_Pyquen_ZeemumuJets_pt10_2760GeV_2021 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Sat Jul 29 10:08:28 2023-date Sat Jul 29 09:48:25 2023; exit: 0 0 0 0
25202.0_TTbar_13 Step0-PASSED Step1-FAILED Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN  - time date Sat Jul 29 09:51:13 2023-date Sat Jul 29 09:49:01 2023; exit: 0 23808 0 0 0
1000.0_RunMinBias2011A Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN  - time date Sat Jul 29 09:49:30 2023-date Sat Jul 29 09:49:20 2023; exit: 1 0 0 0 0
1001.0_RunMinBias2011A Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN Step5-NOTRUN Step6-NOTRUN Step7-NOTRUN Step8-NOTRUN Step9-NOTRUN Step10-NOTRUN  - time date Sat Jul 29 09:49:40 2023-date Sat Jul 29 09:49:31 2023; exit: 1 0 0 0 0 0 0 0 0 0 0
10024.0_TTbar_13+2017 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED Step5-PASSED  - time date Sat Jul 29 09:57:14 2023-date Sat Jul 29 09:49:40 2023; exit: 0 0 0 0 0 0
10042.0_ZMM_13+2017 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED Step5-PASSED  - time date Sat Jul 29 09:56:47 2023-date Sat Jul 29 09:50:30 2023; exit: 0 0 0 0 0 0
10824.0_TTbar_13+2018 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED Step5-PASSED  - time date Sat Jul 29 09:58:18 2023-date Sat Jul 29 09:51:13 2023; exit: 0 0 0 0 0 0
11634.0_TTbar_14TeV+2021 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:05:35 2023-date Sat Jul 29 09:56:47 2023; exit: 0 0 0 0 0
11634.7_TTbar_14TeV+2021_trackingMkFit Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Sat Jul 29 10:05:08 2023-date Sat Jul 29 09:57:14 2023; exit: 0 0 0 0
11634.911_TTbar_14TeV+2021_DD4hep Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:10:48 2023-date Sat Jul 29 09:58:18 2023; exit: 0 0 0 0 0
11634.914_TTbar_14TeV+2021_DDDDB Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:14:08 2023-date Sat Jul 29 10:05:09 2023; exit: 0 0 0 0 0
11834.0_TTbar_14TeV+2021PU Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Sat Jul 29 10:31:57 2023-date Sat Jul 29 10:05:36 2023; exit: 0 0 0 0
12434.0_TTbar_14TeV+2023 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:17:50 2023-date Sat Jul 29 10:08:29 2023; exit: 0 0 0 0 0
13234.0_TTbar_14TeV+2021FS Step0-PASSED Step1-PASSED Step2-PASSED  - time date Sat Jul 29 10:14:01 2023-date Sat Jul 29 10:10:48 2023; exit: 0 0 0
13434.0_TTbar_14TeV+2021FSPU Step0-PASSED Step1-FAILED Step2-NOTRUN  - time date Sat Jul 29 10:16:57 2023-date Sat Jul 29 10:14:02 2023; exit: 0 21504 0
20834.0_TTbar_14TeV+2026D88 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:28:11 2023-date Sat Jul 29 10:14:08 2023; exit: 0 0 0 0 0
20834.75_TTbar_14TeV+2026D88_HLT75e33 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED Step5-PASSED  - time date Sat Jul 29 10:33:15 2023-date Sat Jul 29 10:16:58 2023; exit: 0 0 0 0 0 0
20834.76_TTbar_14TeV+2026D88_HLTwDIGI75e33 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:31:37 2023-date Sat Jul 29 10:17:51 2023; exit: 0 0 0 0 0
20896.0_CloseByPGun_CE_E_Front_120um+2026D88 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:38:38 2023-date Sat Jul 29 10:28:12 2023; exit: 0 0 0 0 0
20900.0_CloseByPGun_CE_H_Coarse_Scint+2026D88 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:41:21 2023-date Sat Jul 29 10:31:37 2023; exit: 0 0 0 0 0
21034.999_TTbar_14TeV+2026D88PU_PMXS1S2PR Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:54:39 2023-date Sat Jul 29 10:31:57 2023; exit: 0 0 0 0 0
23234.0_TTbar_14TeV+2026D94 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Sat Jul 29 10:45:53 2023-date Sat Jul 29 10:33:16 2023; exit: 0 0 0 0 0
250202.181_TTbar13TeVPUppmx2018 Step0-PASSED Step1-FAILED Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN  - time date Sat Jul 29 10:41:07 2023-date Sat Jul 29 10:38:39 2023; exit: 0 23808 0 0 0
2500.601_NANOmc126X Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Sat Jul 29 10:41:10 2023-date Sat Jul 29 10:41:08 2023; exit: 1 0 0
42 31 30 27 18 4 0 0 0 0 0 tests passed, 6 10 0 0 0 0 0 0 0 0 0 failed
```

If you're not using the grid certificate, you should expect the following output:
```
4.22_RunCosmics2011A Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN  - time date Tue Jul 25 15:08:33 2023-date Tue Jul 25 15:08:32 2023; exit: 1 0 0 0 0
4.53_RunPhoton2012B Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN  - time date Tue Jul 25 15:08:33 2023-date Tue Jul 25 15:08:33 2023; exit: 1 0 0 0
5.1_TTbarFS Step0-PASSED Step1-PASSED  - time date Tue Jul 25 15:10:20 2023-date Tue Jul 25 15:08:33 2023; exit: 0 0
7.3_CosmicsSPLoose2018 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:13:00 2023-date Tue Jul 25 15:08:34 2023; exit: 0 0 0 0 0
8.0_BeamHalo Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:11:14 2023-date Tue Jul 25 15:08:34 2023; exit: 0 0 0 0 0
9.0_Higgs200ChargedTaus Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Tue Jul 25 15:14:52 2023-date Tue Jul 25 15:08:35 2023; exit: 0 0 0 0
25.0_TTbar Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:17:25 2023-date Tue Jul 25 15:10:21 2023; exit: 0 0 0 0 0
135.4_ZEEFS_13 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Tue Jul 25 15:14:27 2023-date Tue Jul 25 15:11:14 2023; exit: 0 0 0 0
136.731_RunSinglePh2016B Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN  - time date Tue Jul 25 15:13:00 2023-date Tue Jul 25 15:13:00 2023; exit: 1 0 0 0
136.7611_RunJetHT2016EreMINIAOD Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Tue Jul 25 15:13:00 2023-date Tue Jul 25 15:13:00 2023; exit: 1 0 0
136.793_RunDoubleEG2017C Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN  - time date Tue Jul 25 15:13:01 2023-date Tue Jul 25 15:13:01 2023; exit: 1 0 0 0
136.8311_RunJetHT2017FreMINIAOD Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Tue Jul 25 15:13:02 2023-date Tue Jul 25 15:13:01 2023; exit: 1 0 0
136.874_RunEGamma2018C Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN  - time date Tue Jul 25 15:13:02 2023-date Tue Jul 25 15:13:02 2023; exit: 1 0 0 0
136.88811_RunJetHT2018DreMINIAODUL Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Tue Jul 25 15:13:03 2023-date Tue Jul 25 15:13:02 2023; exit: 1 0 0
138.4_PromptCollisions2021 Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Tue Jul 25 15:13:03 2023-date Tue Jul 25 15:13:03 2023; exit: 1 0 0
138.5_ExpressCollisions2021 Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN  - time date Tue Jul 25 15:13:04 2023-date Tue Jul 25 15:13:03 2023; exit: 1 0 0 0
139.001_RunMinimumBias2021 Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN  - time date Tue Jul 25 15:13:04 2023-date Tue Jul 25 15:13:04 2023; exit: 1 0 0 0
140.53_RunHI2011 Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Tue Jul 25 15:13:04 2023-date Tue Jul 25 15:13:04 2023; exit: 1 0 0
140.56_RunHI2018 Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Tue Jul 25 15:13:05 2023-date Tue Jul 25 15:13:05 2023; exit: 1 0 0
158.01_HydjetQB12ppRECOin2018reMINIAOD Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Tue Jul 25 15:13:06 2023-date Tue Jul 25 15:13:05 2023; exit: 1 0 0
1306.0_SingleMuPt1_UP15 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Tue Jul 25 15:17:12 2023-date Tue Jul 25 15:13:06 2023; exit: 0 0 0 0
1330.0_ZMM_13 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:19:32 2023-date Tue Jul 25 15:14:27 2023; exit: 0 0 0 0 0
2018.1_TTbarFS_13_UP18 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Tue Jul 25 15:17:58 2023-date Tue Jul 25 15:14:53 2023; exit: 0 0 0 0
101.0_SingleElectronE120EHCAL Step0-PASSED  - time date Tue Jul 25 15:18:14 2023-date Tue Jul 25 15:17:12 2023; exit: 0
312.0_Pyquen_ZeemumuJets_pt10_2760GeV_2021 Step0-FAILED Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN  - time date Tue Jul 25 15:20:50 2023-date Tue Jul 25 15:17:25 2023; exit: 23808 0 0 0
25202.0_TTbar_13 Step0-PASSED Step1-FAILED Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN  - time date Tue Jul 25 15:23:48 2023-date Tue Jul 25 15:17:58 2023; exit: 0 23808 0 0 0
1000.0_RunMinBias2011A Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN  - time date Tue Jul 25 15:18:15 2023-date Tue Jul 25 15:18:15 2023; exit: 1 0 0 0 0
1001.0_RunMinBias2011A Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN Step5-NOTRUN Step6-NOTRUN Step7-NOTRUN Step8-NOTRUN Step9-NOTRUN Step10-NOTRUN  - time date Tue Jul 25 15:18:16 2023-date Tue Jul 25 15:18:16 2023; exit: 1 0 0 0 0 0 0 0 0 0 0
10024.0_TTbar_13+2017 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED Step5-PASSED  - time date Tue Jul 25 15:26:18 2023-date Tue Jul 25 15:18:16 2023; exit: 0 0 0 0 0 0
10042.0_ZMM_13+2017 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED Step5-PASSED  - time date Tue Jul 25 15:26:14 2023-date Tue Jul 25 15:19:32 2023; exit: 0 0 0 0 0 0
10824.0_TTbar_13+2018 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED Step5-PASSED  - time date Tue Jul 25 15:29:16 2023-date Tue Jul 25 15:20:50 2023; exit: 0 0 0 0 0 0
11634.0_TTbar_14TeV+2021 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:34:12 2023-date Tue Jul 25 15:23:49 2023; exit: 0 0 0 0 0
11634.7_TTbar_14TeV+2021_trackingMkFit Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED  - time date Tue Jul 25 15:36:11 2023-date Tue Jul 25 15:26:14 2023; exit: 0 0 0 0
11634.911_TTbar_14TeV+2021_DD4hep Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:39:39 2023-date Tue Jul 25 15:26:18 2023; exit: 0 0 0 0 0
11634.914_TTbar_14TeV+2021_DDDDB Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:38:37 2023-date Tue Jul 25 15:29:17 2023; exit: 0 0 0 0 0
11834.0_TTbar_14TeV+2021PU Step0-PASSED Step1-FAILED Step2-NOTRUN Step3-NOTRUN  - time date Tue Jul 25 15:41:28 2023-date Tue Jul 25 15:34:12 2023; exit: 0 23808 0 0
12434.0_TTbar_14TeV+2023 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:45:24 2023-date Tue Jul 25 15:36:11 2023; exit: 0 0 0 0 0
13234.0_TTbar_14TeV+2021FS Step0-PASSED Step1-PASSED Step2-PASSED  - time date Tue Jul 25 15:41:13 2023-date Tue Jul 25 15:38:38 2023; exit: 0 0 0
13434.0_TTbar_14TeV+2021FSPU Step0-PASSED Step1-FAILED Step2-NOTRUN  - time date Tue Jul 25 15:44:45 2023-date Tue Jul 25 15:39:39 2023; exit: 0 23808 0
20834.0_TTbar_14TeV+2026D88 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:57:05 2023-date Tue Jul 25 15:41:13 2023; exit: 0 0 0 0 0
20834.75_TTbar_14TeV+2026D88_HLT75e33 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED Step5-PASSED  - time date Tue Jul 25 15:58:49 2023-date Tue Jul 25 15:41:28 2023; exit: 0 0 0 0 0 0
20834.76_TTbar_14TeV+2026D88_HLTwDIGI75e33 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 16:00:10 2023-date Tue Jul 25 15:44:46 2023; exit: 0 0 0 0 0
20896.0_CloseByPGun_CE_E_Front_120um+2026D88 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 15:56:32 2023-date Tue Jul 25 15:45:25 2023; exit: 0 0 0 0 0
20900.0_CloseByPGun_CE_H_Coarse_Scint+2026D88 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 16:06:14 2023-date Tue Jul 25 15:56:33 2023; exit: 0 0 0 0 0
21034.999_TTbar_14TeV+2026D88PU_PMXS1S2PR Step0-PASSED Step1-FAILED Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN  - time date Tue Jul 25 16:06:07 2023-date Tue Jul 25 15:57:05 2023; exit: 0 23808 0 0 0
23234.0_TTbar_14TeV+2026D94 Step0-PASSED Step1-PASSED Step2-PASSED Step3-PASSED Step4-PASSED  - time date Tue Jul 25 16:11:37 2023-date Tue Jul 25 15:58:50 2023; exit: 0 0 0 0 0
250202.181_TTbar13TeVPUppmx2018 Step0-PASSED Step1-FAILED Step2-NOTRUN Step3-NOTRUN Step4-NOTRUN  - time date Tue Jul 25 16:06:47 2023-date Tue Jul 25 16:00:11 2023; exit: 0 23808 0 0 0
2500.601_NANOmc126X Step0-DAS_ERROR Step1-NOTRUN Step2-NOTRUN  - time date Tue Jul 25 16:06:09 2023-date Tue Jul 25 16:06:08 2023; exit: 1 0 0
30 24 23 22 17 4 0 0 0 0 0 tests passed, 18 5 0 0 0 0 0 0 0 0 0 failed
```
