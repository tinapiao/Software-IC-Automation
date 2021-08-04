#! /usr/local/bin/tcsh -f

#source /tools/flexlm/flexlm.cshrc


setenv SPECTRE_DEFAULTS -E
setenv CDS_Netlisting_Mode "Analog"

# setup virtuoso
#setenv CDS_INST_DIR /tools/cadence/ICADV/ICADV123
setenv CDS_INST_DIR  /CMC/tools/cadence/IC617_lnx86
#setenv MMSIM_HOME   /tools/cadence/MMSIM/MMSIM151
setenv MMSIM_HOME    /CMC/tools/cadence/MMSIM15.10.385_lnx86
#setenv CDSHOME      $CDS_INST_DIR
setenv CDSHOME      /CMC/tools/cadence/IC617_lnx86
setenv PVSHOME      /CMC/tools/cadence/PVS-ISR4.15.24.000_lnx86
setenv QRC_HOME     /CMC/tools/cadence/EXT15.14.000_lnx86
#setenv QRC_HOME    /tools/cadence/EXT/EXT151
#setenv IUSHOME      /tools/cadence/INCISIV/INCISIVE152
setenv IUSHOME      /CMC/tools/cadence/INCISIVE15.20.054_lnx86 
setenv AMSHOME      $IUSHOME

set path = ( ${MMSIM_HOME}/tools/bin \
    ${CDS_INST_DIR}/tools/bin \
    ${CDS_INST_DIR}/tools/dfII/bin \
    ${CDS_INST_DIR}/tools/plot/bin \
    ${PVSHOME}/tools/bin \
    ${QRC_HOME}/tools/bin \
    $path \
     )

### Setup BAG
source .cshrc_bag