let( ( (libName "tsmcN65") libId libPath encSkillPath srcSkillPath modelPath file element tools)
  libId = ddGetObj( libName )
  if( ddIsId( libId ) then
    libPath = ddGetObjReadPath( libId )

    printf( "Initializing from libInit.il for library %s...\n" libName )
    encSkillPath = strcat( libPath "/../skill")

loadContext(prependInstallPath("etc/context/pCellGen.cxt"))

;;;load TSMC PDK pcell cxt file
    filePath = sprintf(nil "%s/pcode1.cxt" encSkillPath)
        when( isFile(filePath)
            printf( "   --  %s\n" filePath )
            loadContext(sprintf(nil "/%s" filePath))
            )

    filePath = sprintf(nil "%s/pcode2.cxt" encSkillPath)
        when( isFile(filePath)
            printf( "   --  %s\n" filePath )
            loadContext(sprintf(nil "/%s" filePath))
            )

; load .cdsenv file

  filePath = sprintf(nil "%s/.cdsenv" libPath)
  when( isFile(filePath) 
     printf("Loading cdsenv file  '%s'\n" filePath)
     envLoadFile(filePath)
  ) ; ** if isFile **

; load encrypted skill files
    foreach( file setof(element getDirFiles(encSkillPath) 
                          equal(".il" index(element ".il"))
                    )
      printf( "   --  %s\n" file )
      load( strcat( encSkillPath sprintf(nil "/%s" file)))
    )
    
; load encrypted skill files
    foreach( file setof(element getDirFiles(encSkillPath) 
                          equal(".cb" index(element ".cb"))
                    )
      printf( "   --  %s\n" file )
      load( strcat( encSkillPath sprintf(nil "/%s" file)))
    )

; load encrypted skill files
    foreach( file setof(element getDirFiles(encSkillPath) 
                          equal(".ile" index(element ".ile"))
                    )
      printf( "   --  %s\n" file )
      load( strcat( encSkillPath sprintf(nil "/%s" file)))
    )

; load encrypted callback files
    foreach( file setof(element getDirFiles(encSkillPath) 
                          equal(".cbe" index(element ".cbe"))
                    )
      printf( "   --  %s\n" file )
      load( strcat( encSkillPath sprintf(nil "/%s" file)))
    )

; load new cxt file for v1.0c 
    filePath = sprintf(nil "%s/tsmcN65gp_v1d0c.cxt" encSkillPath)
        when( isFile(filePath)
            printf( "   --  %s\n" filePath )
            loadContext(sprintf(nil "/%s" filePath))
            )                     

; load new cxt file
    filePath = sprintf(nil "%s/tsmcN65_newAMS.cxt" encSkillPath)
        when( isFile(filePath)
            printf( "   --  %s\n" filePath )
            loadContext(sprintf(nil "/%s" filePath))
            )                     

; load new cxt file
    filePath = sprintf(nil "%s/tsmcN65_newRTMOM.cxt" encSkillPath)
        when( isFile(filePath)
            printf( "   --  %s\n" filePath )
            loadContext(sprintf(nil "/%s" filePath))
            )                     

; load new cxt file
    filePath = sprintf(nil "%s/tsmcN65GP_v1d0.cxt" encSkillPath)
        when( isFile(filePath)
            printf( "   --  %s\n" filePath )
            loadContext(sprintf(nil "/%s" filePath))
            )                     


; load cxt files
    foreach( file setof(element getDirFiles(encSkillPath) 
                          equal(".cxt" index(element ".cxt"))
                    )
      unless(file =="tsmcN65GP_v1d0.cxt" || file =="tsmcN65_newRTMOM.cxt" || file =="tsmcN65_newAMS.cxt" || file =="tsmcN65gp_v1d0c.cxt" || file =="pcode1.cxt" || file =="pcode2.cxt"
      printf( "   --  %s\n" file )
      loadContext( strcat( encSkillPath sprintf(nil "/%s" file)))
    )
    )


; load new cxt file
    filePath = sprintf(nil "%s/tsmcN65GP_v1d0.cxt" encSkillPath)
        when( isFile(filePath)
            printf( "   --  %s\n" filePath ) 
            loadContext(sprintf(nil "/%s" filePath)) 
            )                      

; load new cxt file
    filePath = sprintf(nil "%s/tsmcN65_newRTMOM.cxt" encSkillPath)
        when( isFile(filePath)
            printf( "   --  %s\n" filePath )
            loadContext(sprintf(nil "/%s" filePath))
            )                     

; load new cxt file
    filePath = sprintf(nil "%s/tsmcN65_newAMS.cxt" encSkillPath)
        when( isFile(filePath)
            printf( "   --  %s\n" filePath )
            loadContext(sprintf(nil "/%s" filePath))
            )                     


    filePath = sprintf(nil "%s/pdkParamTable.il" encSkillPath)
    when( isFile(filePath)
	printf("Loading PDK Param Table  '%s'\n" filePath)
        PasLoadPdkParams(libName filePath)
    )

    filePath = sprintf(nil "%s/display.drf" getWorkingDir())
    if( isFile( filePath) then
       printf("Loading Working place Display File '%s'\n" filePath)
    else
       filePath = sprintf(nil "%s/../display.drf" libPath)
       when( isFile(filePath)
           when( isCallable( 'drLoadDrf)
               printf("Loading PDK Display File '%s'\n" filePath)
               drLoadDrf(filePath)
           )
       )
    )

;   setup spectre model files, sections
    if(isContextLoaded("schView") then

    foreach( sim list( 'ams 'UltraSim 'spectre)
       envSetVal("asimenv.startup" "simulator" 'string sprintf(nil "%s" sim))    
      tools = envGetAvailableTools()
;      if(member("spectre" tools) then
      if(member(sprintf(nil "%s" sim) tools) then
;        asiSetEnvOptionVal(asiGetTool('spectre) "modelFiles"
       asiSetEnvOptionVal(asiGetTool(sim) "modelFiles"
         list(
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_bip")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_33")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_mim")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_dnw")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_18")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_bip_npn")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_33")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfrtmom")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_mos_cap_25")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_18")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_disres")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_res")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_na")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfmos_33")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_hvt")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfmvar")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfmos_18")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_na")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_na33")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_lvt")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfres_sa")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_na33")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_esd")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfmim")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_25od33")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_25od33")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_mos_cap")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_25")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_25ud18")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_25")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfmos")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_25ud18")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_na25od33")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfjvar")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfmos_25")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rtmom")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_na25od33")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_dio_na25")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfres_rpo")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_hvt")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfind")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_rfmvar_25")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_na25")
	list(strcat( libPath "/../models/spectre/crn65gplus_2d5_lk_v1d0.scs") "tt_lvt")

            )
        )
     )
     if( member("eldoD" envGetAvailableTools()) then
       asiSetEnvOptionVal(asiGetTool('eldoD) "modelFiles"
         list(
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_bip")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_33")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_mim")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_dnw")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_18")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_bip_npn")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_33")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfrtmom")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_mos_cap_25")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_18")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_disres")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_res")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_na")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfmos_33")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_hvt")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfmvar")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfmos_18")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_na")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_na33")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_lvt")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfres_sa")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_na33")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_esd")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfmim")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_25od33")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_25od33")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_mos_cap")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_25")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_25ud18")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_25")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfmos")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_25ud18")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_na25od33")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfjvar")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfmos_25")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rtmom")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_na25od33")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_dio_na25")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfres_rpo")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_hvt")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfind")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_rfmvar_25")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_na25")
	list(strcat( libPath "/../models/eldo/crn65gplus_2d5_lk_v1d0.eldo") "tt_lvt")

            )
       )
     )
     if(member("hspiceD" tools) then
       asiSetEnvOptionVal(asiGetTool('hspiceD) "modelFiles"
  	list(
       	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_bip")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_33")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_mim")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_dnw")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_18")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_bip_npn")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_33")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfrtmom")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_mos_cap_25")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_18")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_disres")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_res")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_na")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfmos_33")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_hvt")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfmvar")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfmos_18")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_na")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_na33")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_lvt")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfres_sa")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_na33")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_esd")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfmim")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_25od33")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_25od33")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_mos_cap")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_25")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_25ud18")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_25")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfmos")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_25ud18")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_na25od33")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfjvar")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfmos_25")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rtmom")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_na25od33")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_dio_na25")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfres_rpo")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_hvt")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfind")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_rfmvar_25")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_na25")
	list(strcat( libPath "/../models/hspice/crn65gplus_2d5_lk_v1d0.l") "tt_lvt")
  	)
       ) ; asiSet...
     )
;     if(member("hspiceS" tools) then
;       asiSetEnvOptionVal(asiGetTool('hspiceS) "modelPath" strcat(libPath "/../models/hspice") )
;       asiSetEnvOptionVal(asiGetTool('hspiceS) "includeFile" "hspice.mdl")
;     )
    )
)
;  if(getd('ADSsim) then
;     asiSetEnvOptionVal(asiGetTool('ADSsim) "modelFiles"
;        list(
;list(strcat( libPath "/../models/crn90lp_inc.net") "")
;     
;	)
;     )
;    );end ADS if     
;auCdlPrintEmptySUBCKT = 't
;auCdlCDFPinCntrl = 't
if( isCallable('hiCreateMenuItem) then 
    when( isCallable('tsmcPdkAddCIWPulldown) 
        tsmcPdkAddCIWPulldown() 
    ) 
 ) 
procedure( tsmcCdfFormInitCB( cdfgData "g" )

    when( boundp( 'schObjPropForm ) && schObjPropForm->cellName
        schObjPropForm->cellName->editable = nil  ;  <----  turn off (Default)
    )
)

)
)


