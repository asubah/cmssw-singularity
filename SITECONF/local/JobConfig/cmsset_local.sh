#!/bin/sh
if [ -z $CVS_RSH ]
then
    export CVS_RSH=ssh
fi

export VO_CMS_SW_DIR=/data/cmssw
