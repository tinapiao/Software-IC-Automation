;;
;; Get the Library Path
;;
  libPath = ddGetObjReadPath( ddGetObj( "cds_ff_mpt" ) )

;;; Sets the specified environment variable if it hasn't been already set 
;;; differently from its default value
procedure( envSetValIfDefault( tool var type value "ttsg" )
    when( and( envIsVal( tool var ) envGetVal( tool var ) == envGetDefVal( tool var ) )
	envSetVal( tool var type value )
    )
)

printf("\tLoading Environment Settings ...\n")
envSetValIfDefault("layoutXL" "setPPConn" 'boolean nil)
envSetValIfDefault("layout" "mppTemplate" 'string "N-Tap")
envSetValIfDefault("layout" "xSnapSpacing" 'float 0.001)
envSetValIfDefault("layout" "ySnapSpacing" 'float 0.001)
envSetValIfDefault("layout" "viaParamCalcMode" 'cyclic "minRules")
envSetValIfDefault("layout" "wireViaParamCalcMode" 'cyclic "minRules")
envSetValIfDefault("layoutXL" "initIOPinLayer" 'string "M1 drawing")
envSetValIfDefault("spectre.envOpts" "useAltergroup" 'boolean nil)
envSetValIfDefault("hspiceD.envOpts" "autoDisplay" 'boolean nil)
envSetValIfDefault("layoutXL" "lxGenerateInBoundary" 'boolean t)
envSetValIfDefault("layoutXL" "lxPositionMinSep" 'float 0.12)
envSetValIfDefault("layoutXL" "extractVerifyWellSubstrateConnections" 'boolean t)
envSetValIfDefault("layout" "keepGuardRingEndsConnected" 'boolean t)
envSetValIfDefault("layout" "fgrEnableAdvanceWrap" 'boolean t)
envSetValIfDefault("layout" "fgrPostEditPitchCorrection" 'boolean t)
setShellEnvVar("FGR_USE_MIN_SEG_LENGTH=t")

;;; Undefine VLS XL inductor parameters so that "l" parameter on FETs
;;; is not reduced --- see solution associated with CCR 942040
envSetVal( "layoutXL" "inductanceParamNames" 'string "" )
;;-envSetVal( "layoutXL" "sfactorNames" 'string "s S ns" )

;;
;; Append Simulator Model Paths
;;
when(isContextLoaded("schView") 
    file = strcat( libPath "/cds_ff_mpt_ModelMgmt.il" )
    ;;; Load required skill code
    when( and( !getd( 'cds_ff_mpt_AppendModelFile ) isReadable( file ) )
        printf("\tLoading Model Management File ...\n", file)
	load( file )
    )
    cds_ff_mpt_AppendModelFile( 
	'( "spectre" "UltraSim" "ams" )
	strcat( libPath "/../models/spectre/cds_ff_mpt.scs")
	"tt"
    )
)

;; Set the display units variable
;;
gLabelsNumNotation = 'suffix

;;
;; Set the circuit prospector pdk defualts
;;
;; For additional detailed information about Circuit Prospector, please see
;; the Cadence online help or SourceLink:
;;
;;     Virtuoso Unified Custom Constraints User Guide, Reference Manual
;;     Virtuoso Unified Custom Constraints Reference Manual
;;     Virtuoso Unified Custom Constraints SKILL API Commands
;;       
     ;; load custom library initialization file
     when( ddObj = ddGetObj(libName nil nil "libInitCktPro.il")
    printf("\tLoading %s/%s ... " libName ddObj~>name)
    if( errset(load(ddGetObjReadPath(ddObj))) then
       printf("done!\n")
    else
       success = nil
       printf("failed!\n")
    )
     ) ; ** when ddObj **

;;
;; Print this header in the CIW
;;
  printf("\n  *************************************************************
          \n  *              Cadence Design Systems, Inc.                 *
          \n  *                                                           *
          \n  *             Generic Finfet Multi Pattern PDK              *
          \n  *                     (cds_ff_mpt)                          *
          \n  *                                                           *
          \n  *************************************************************
          \n")

fp=infile(strcat(libPath "/../docs/VERSION"))
if(fp then
    while(gets(line fp) printf("\t%s\n" line))
    close(fp)
else
    printf("\tVersion File is not available\n")
)
