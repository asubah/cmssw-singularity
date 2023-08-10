#!/bin/csh
if ( ! $?CVS_RSH ) then
    setenv CVS_RSH ssh
endif

setenv VO_CMS_SW_DIR /data/cmssw
