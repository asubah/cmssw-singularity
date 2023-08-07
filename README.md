```bash
export APPTAINER_TMPDIR=~/.tmp
sudo -E apptainer build cmssw-almalinux-8.sif cmssw-almalinux-8.sdf
apptainer shell --bind ./squid/:/squid --bind ./lhapdfsets/:/lhapdfsets cmssw-almalinux-8.sif
squid -f /squid/squid.conf -z
squid -f /squid/squid.conf

source /data/cmssw/cmsset_default.sh
cmsrel CMSSW_13_0_0
mkdir CMSSW_13_0_0/run
cd CMSSW_13_0_0/run/
cmsenv
voms-proxy-init --rfc --voms cms
export LHAPDF_DATA_PATH=/lhapdfsets
time runTheMatrix.py -j 4 -t 2 --nStreams 2 -l limited
```
