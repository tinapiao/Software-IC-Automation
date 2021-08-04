procedure( tsmcN65_updateCDFs(libList cellList deviceList @optional (resUpdate "old setting") (capUpdate "old setting"))
  let((libId cellId repName cvId cv cdfgData cnt tmpCell cellName check checkDev tmpDevice)
    cnt=0
    ;;For different library
    if(resUpdate == "old setting" then
      printf("update resistors with old setting\n")
      resUpdate = 0
    else
      if(resUpdate == "l_&_w" then
        printf("update resistors with mode l_&_w\n")
        resUpdate = 2
      else
        printf("update resistors with mode Res_&_w\n")
        resUpdate = 1
      )
    )
    if(capUpdate == "old setting" then
      printf("update capacitors with old setting\n")
      capUpdate = 0
    else
      if(capUpdate == "c_&_w" then
        printf("update capacitors with mode c_&_w\n")
        capUpdate = 1
      else
        printf("update capacitors with mode l_&_w\n")
        capUpdate = 2
      )
    )
    foreach(libName libList
    libId = ddGetObj(libName)
    if(cellList == list() then
      cellList = libId~>cells~>name
    )
    foreach(cellId libId~>cells
      ;; Only the cells in cellList will be upDate***
      cellName = ddGetObjName(cellId)
      check = nil
      foreach(tmpCell cellList
        if(cellName == tmpCell then
          check = t
        )
      )
      if(check == t then
      foreach(repName cellId~>views~>name
        if(repName == "schematic" || repName == "layout" then
          libId = ddGetObj(libName)
          cvId = dbOpenCellView(libId cellId~>name repName nil "a")
          printf("%s %s\n" cvId~>cellName repName)
          foreach(inst cvId~>instances
            checkDev = nil
            if(!(deviceList == list()) then
            foreach(tmpDevice deviceList
              if(inst~>cellName == tmpDevice then
                checkDev = t
              )
            )
            else
              checkDev = t
            )
            if(inst~>libName == "tsmcN65" && checkDev == t then
              ; added to avoid PasCdfCommitValue error
              cdfgData = cdfGetInstCDF(inst)
              when(cdfgData~>formInitProc
                initProc = stringToSymbol(cdfgData~>formInitProc)
                when(isCallable(initProc)
                  errset(apply(initProc list(cdfgData)))
                )
              );when cdfData
              if( inst~>cellName == "crtmom" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_crtmom_5m_T1CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "crtmom_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_crtmom_mx_6mCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "crtmom_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_crtmom_rf_6m_T1CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "dnwpsub" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_dnwpsubCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_invCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "inv_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_inv_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "mimcap" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  _mimcap_CB( 'c )
                )
                (2
                  _mimcap_CB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    _mimcap_CB( 'c )
                  else
                    _mimcap_CB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "mimcap_3t" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  tsmcN65_mimcap_3tCB( 'c )
                )
                (2
                  tsmcN65_mimcap_3tCB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    tsmcN65_mimcap_3tCB( 'c )
                  else
                    tsmcN65_mimcap_3tCB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "mimcap_udc" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  _mimcap_udc_6m_1p0_CB( 'c )
                )
                (2
                  _mimcap_udc_6m_1p0_CB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    _mimcap_udc_6m_1p0_CB( 'c )
                  else
                    _mimcap_udc_6m_1p0_CB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "mimcap_udc_3t" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  _mimcap_udc_3t_6m_1p0_CB( 'c )
                )
                (2
                  _mimcap_udc_3t_6m_1p0_CB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    _mimcap_udc_3t_6m_1p0_CB( 'c )
                  else
                    _mimcap_udc_3t_6m_1p0_CB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "mimcap_um_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  _mimcap_um_rf_6m_1p0_CB( 'c )
                )
                (2
                  _mimcap_um_rf_6m_1p0_CB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    _mimcap_um_rf_6m_1p0_CB( 'c )
                  else
                    _mimcap_um_rf_6m_1p0_CB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "mimcap_um_udc_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  tsmcN65_mimcap_um_rf_6m_1p0_udcCB( 'c )
                )
                (2
                  tsmcN65_mimcap_um_rf_6m_1p0_udcCB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    tsmcN65_mimcap_um_rf_6m_1p0_udcCB( 'c )
                  else
                    tsmcN65_mimcap_um_rf_6m_1p0_udcCB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "mimcap_woum_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  tsmcN65_mimcap_woum_rfCB( 'c )
                )
                (2
                  tsmcN65_mimcap_woum_rfCB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    tsmcN65_mimcap_woum_rfCB( 'c )
                  else
                    tsmcN65_mimcap_woum_rfCB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "mimcap_woum_udc_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  tsmcN65_mimcap_woum_rf_6m_1p0_udcCB( 'c )
                )
                (2
                  tsmcN65_mimcap_woum_rf_6m_1p0_udcCB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    tsmcN65_mimcap_woum_rf_6m_1p0_udcCB( 'c )
                  else
                    tsmcN65_mimcap_woum_rf_6m_1p0_udcCB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "moscap_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_moscap_rfCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "moscap_rf25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_moscap_rf25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "moscap_rf25_nw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_moscap_rf25_nwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "moscap_rf_nw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_moscap_rf_nwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand2_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand2_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand3_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand3_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nand4_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nand4_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nchCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnw_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnwod33_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnwod33x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnwud18_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnwud18x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_dnwx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25od33_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25od33x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25ud18_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25ud18x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_25x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_dnw_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_dnwx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_hvt_dnw_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_hvt_dnwx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_hvt_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_hvtx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_lvt_dnw_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_lvt_dnwx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_lvt_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_lvtx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_naCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na25_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na25od33_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na25od33x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na25x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_na_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_na_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nch_nax" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nch_naCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nchx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nchCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndioCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndio_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndio_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndio_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio_esd" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndio_esdCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndio_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndio_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio_na" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndio_naCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio_na25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndio_na25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "ndio_na25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_ndio_na25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmos_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nmos_rfCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmos_rf_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nmos_rf25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmos_rf_25_nodnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_nmos_rf_25_nodnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmos_rf_25_nodnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_nmos_rf_25od33_nodnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmos_rf_25_nodnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_nmos_rf_25ud18_nodnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmos_rf_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nmos_rf25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmos_rf_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nmos_rf25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmos_rf_nodnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_nmos_rf_nodnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmoscap" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_nmoscap_gp_CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nmoscap_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_nmoscap_25_gp_CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor2_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor2_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor3_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor3_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nor4_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_nor4_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "npn" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_npnCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "npn_mis" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_npn_misCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "nwdio" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_nwdioCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "parasitic_rc" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmc_estiRC_raphael()
                  cnt++
              );if
              if( inst~>cellName == "parasitic_rc_3T" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmc_estiRC_raphael()
                  cnt++
              );if
              if( inst~>cellName == "pass" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_passCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pass_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pass_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pchCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25od33_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25od33x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25ud18_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25ud18x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_25x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_hvt_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_hvtx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_lvt_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_lvtx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pch_macx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pch_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pchx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pchCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pdio" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_pdioCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pdio_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_pdio_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pdio_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_pdio_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pdio_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_pdio_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pdio_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_pdio_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pdio_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_pdio_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pmos_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pmos_rfCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pmos_rf_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pmos_rf25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pmos_rf_25_nw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_pmos_rf_25_nwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pmos_rf_25_nwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_pmos_rf_25od33_nwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pmos_rf_25_nwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_pmos_rf_25ud18_nwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pmos_rf_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pmos_rf25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pmos_rf_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_pmos_rf18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pmos_rf_nw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_pmos_rf_nwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pnp" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_pnpCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pnp_mis" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_pnp_misCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "pwdnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN90_pwdnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "rm1" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm1_CB( 'res )
                )
                (2
                  tsmcN65lo_rm1_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm1_CB( 'res )
                  else
                    tsmcN65lo_rm1_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm10" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm10a_CB( 'res )
                )
                (2
                  tsmcN65lo_rm10a_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm10a_CB( 'res )
                  else
                    tsmcN65lo_rm10a_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm10a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm10a_CB( 'res )
                )
                (2
                  tsmcN65lo_rm10a_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm10a_CB( 'res )
                  else
                    tsmcN65lo_rm10a_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm2" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm2x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm2x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm2x_CB( 'res )
                  else
                    tsmcN65lo_rm2x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm2x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm2x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm2x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm2x_CB( 'res )
                  else
                    tsmcN65lo_rm2x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm3" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm3x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm3x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm3x_CB( 'res )
                  else
                    tsmcN65lo_rm3x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm3x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm3x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm3x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm3x_CB( 'res )
                  else
                    tsmcN65lo_rm3x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm4" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm4x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm4x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm4x_CB( 'res )
                  else
                    tsmcN65lo_rm4x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm4x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm4x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm4x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm4x_CB( 'res )
                  else
                    tsmcN65lo_rm4x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm5" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm5z_CB( 'res )
                )
                (2
                  tsmcN65lo_rm5z_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm5z_CB( 'res )
                  else
                    tsmcN65lo_rm5z_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm5x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm5x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm5x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm5x_CB( 'res )
                  else
                    tsmcN65lo_rm5x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm5z" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm5z_CB( 'res )
                )
                (2
                  tsmcN65lo_rm5z_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm5z_CB( 'res )
                  else
                    tsmcN65lo_rm5z_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm6" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm6x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm6x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm6x_CB( 'res )
                  else
                    tsmcN65lo_rm6x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm6x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm6x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm6x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm6x_CB( 'res )
                  else
                    tsmcN65lo_rm6x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm6z" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm6z_CB( 'res )
                )
                (2
                  tsmcN65lo_rm6z_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm6z_CB( 'res )
                  else
                    tsmcN65lo_rm6z_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm7" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm7a_CB( 'res )
                )
                (2
                  tsmcN65lo_rm7a_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm7a_CB( 'res )
                  else
                    tsmcN65lo_rm7a_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm7a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm7a_CB( 'res )
                )
                (2
                  tsmcN65lo_rm7a_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm7a_CB( 'res )
                  else
                    tsmcN65lo_rm7a_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm7x" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm7x_CB( 'res )
                )
                (2
                  tsmcN65lo_rm7x_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm7x_CB( 'res )
                  else
                    tsmcN65lo_rm7x_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm7z" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm7z_CB( 'res )
                )
                (2
                  tsmcN65lo_rm7z_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm7z_CB( 'res )
                  else
                    tsmcN65lo_rm7z_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm8" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm8z_CB( 'res )
                )
                (2
                  tsmcN65lo_rm8z_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm8z_CB( 'res )
                  else
                    tsmcN65lo_rm8z_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm8a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm8a_CB( 'res )
                )
                (2
                  tsmcN65lo_rm8a_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm8a_CB( 'res )
                  else
                    tsmcN65lo_rm8a_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm8z" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm8z_CB( 'res )
                )
                (2
                  tsmcN65lo_rm8z_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm8z_CB( 'res )
                  else
                    tsmcN65lo_rm8z_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm9" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm9z_CB( 'res )
                )
                (2
                  tsmcN65lo_rm9z_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm9z_CB( 'res )
                  else
                    tsmcN65lo_rm9z_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm9a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm9a_CB( 'res )
                )
                (2
                  tsmcN65lo_rm9a_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm9a_CB( 'res )
                  else
                    tsmcN65lo_rm9a_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rm9z" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rm9z_CB( 'res )
                )
                (2
                  tsmcN65lo_rm9z_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rm9z_CB( 'res )
                  else
                    tsmcN65lo_rm9z_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnod" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rnodCB( 'res )
                )
                (2
                  tsmcN65_rnodCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rnodCB( 'res )
                  else
                    tsmcN65_rnodCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnod_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnod_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rnod_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnod_m_CB( 'res )
                  else
                    tsmcN65lo_rnod_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnod_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnod_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rnod_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnod_m_CB( 'res )
                  else
                    tsmcN65lo_rnod_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnodwo" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rnodwoCB( 'res )
                )
                (2
                  tsmcN65_rnodwoCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rnodwoCB( 'res )
                  else
                    tsmcN65_rnodwoCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnodwo_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnodwo_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rnodwo_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnodwo_m_CB( 'res )
                  else
                    tsmcN65lo_rnodwo_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnodwo_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnodwo_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rnodwo_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnodwo_m_CB( 'res )
                  else
                    tsmcN65lo_rnodwo_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnpoly" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rnpolyCB( 'res )
                )
                (2
                  tsmcN65_rnpolyCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rnpolyCB( 'res )
                  else
                    tsmcN65_rnpolyCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnpoly_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnpoly_mCB( 'res )
                )
                (2
                  tsmcN65lo_rnpoly_mCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnpoly_mCB( 'res )
                  else
                    tsmcN65lo_rnpoly_mCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnpoly_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnpoly_mCB( 'res )
                )
                (2
                  tsmcN65lo_rnpoly_mCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnpoly_mCB( 'res )
                  else
                    tsmcN65lo_rnpoly_mCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnpolywo" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rnpolywoCB( 'res )
                )
                (2
                  tsmcN65_rnpolywoCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rnpolywoCB( 'res )
                  else
                    tsmcN65_rnpolywoCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnpolywo_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnpolywo_mCB( 'res )
                )
                (2
                  tsmcN65lo_rnpolywo_mCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnpolywo_mCB( 'res )
                  else
                    tsmcN65lo_rnpolywo_mCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnpolywo_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnpolywo_mCB( 'res )
                )
                (2
                  tsmcN65lo_rnpolywo_mCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnpolywo_mCB( 'res )
                  else
                    tsmcN65lo_rnpolywo_mCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnwod" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rnwod_CB( 'res )
                )
                (2
                  tsmcN65_rnwod_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rnwod_CB( 'res )
                  else
                    tsmcN65_rnwod_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnwod_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnwod_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rnwod_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnwod_m_CB( 'res )
                  else
                    tsmcN65lo_rnwod_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnwod_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnwod_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rnwod_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnwod_m_CB( 'res )
                  else
                    tsmcN65lo_rnwod_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnwsti" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rnwsti_CB( 'res )
                )
                (2
                  tsmcN65_rnwsti_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rnwsti_CB( 'res )
                  else
                    tsmcN65_rnwsti_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnwsti_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnwsti_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rnwsti_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnwsti_m_CB( 'res )
                  else
                    tsmcN65lo_rnwsti_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rnwsti_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rnwsti_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rnwsti_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rnwsti_m_CB( 'res )
                  else
                    tsmcN65lo_rnwsti_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rpod" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rpodCB( 'res )
                )
                (2
                  tsmcN65_rpodCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rpodCB( 'res )
                  else
                    tsmcN65_rpodCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rpod_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rpod_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rpod_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rpod_m_CB( 'res )
                  else
                    tsmcN65lo_rpod_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rpod_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rpod_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rpod_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rpod_m_CB( 'res )
                  else
                    tsmcN65lo_rpod_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rpodwo" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rpodwoCB( 'res )
                )
                (2
                  tsmcN65_rpodwoCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rpodwoCB( 'res )
                  else
                    tsmcN65_rpodwoCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rpodwo_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rpodwo_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rpodwo_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rpodwo_m_CB( 'res )
                  else
                    tsmcN65lo_rpodwo_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rpodwo_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rpodwo_m_CB( 'res )
                )
                (2
                  tsmcN65lo_rpodwo_m_CB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rpodwo_m_CB( 'res )
                  else
                    tsmcN65lo_rpodwo_m_CB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rppoly" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rppolyCB( 'res )
                )
                (2
                  tsmcN65_rppolyCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rppolyCB( 'res )
                  else
                    tsmcN65_rppolyCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rppoly_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rppoly_mCB( 'res )
                )
                (2
                  tsmcN65lo_rppoly_mCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rppoly_mCB( 'res )
                  else
                    tsmcN65lo_rppoly_mCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rppoly_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rppoly_mCB( 'res )
                )
                (2
                  tsmcN65lo_rppoly_mCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rppoly_mCB( 'res )
                  else
                    tsmcN65lo_rppoly_mCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rppoly_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  tsmcN65lo_rppoly_rfCB( 'c )
                )
                (2
                  tsmcN65lo_rppoly_rfCB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    tsmcN65lo_rppoly_rfCB( 'c )
                  else
                    tsmcN65lo_rppoly_rfCB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "rppolywo" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65_rppolywoCB( 'res )
                )
                (2
                  tsmcN65_rppolywoCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65_rppolywoCB( 'res )
                  else
                    tsmcN65_rppolywoCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rppolywo_m" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rppolywo_mCB( 'res )
                )
                (2
                  tsmcN65lo_rppolywo_mCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rppolywo_mCB( 'res )
                  else
                    tsmcN65lo_rppolywo_mCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rppolywo_mx" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case(resUpdate
                (1
                  tsmcN65lo_rppolywo_mCB( 'res )
                )
                (2
                  tsmcN65lo_rppolywo_mCB( 'l )
                )
                (0
                  if(cdfgData->ResCalc->value == "Res_&_w" then 
                    tsmcN65lo_rppolywo_mCB( 'res )
                  else
                    tsmcN65lo_rppolywo_mCB( 'l )
                  )
                )
              );
                  cnt++
              );if
              if( inst~>cellName == "rppolywo_rf" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)

              case( capUpdate
                (1
                  tsmcN65lo_rppolywo_rfCB( 'c )
                )
                (2
                  tsmcN65lo_rppolywo_rfCB( 'l )
                )
                (0
                  if(cdfgData->entryMode->value == "c_&_w" then 
                    tsmcN65lo_rppolywo_rfCB( 'c )
                  else
                    tsmcN65lo_rppolywo_rfCB( 'l )
                  )
                )
              )
                  cnt++
              );if
              if( inst~>cellName == "spiral_std_mu_a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_spiral_std_mu_aCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "spiral_std_mu_z" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_spiral_std_mu_zCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "spiral_std_mza_a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_spiral_std_mza_aCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "spiral_sym_ct_mu_a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_spiral_sym_ct_mu_aCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "spiral_sym_ct_mu_z" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_spiral_sym_ct_mu_zCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "spiral_sym_ct_mza_a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_spiral_sym_ct_mza_aCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "spiral_sym_mu_a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_spiral_sym_mu_aCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "spiral_sym_mu_z" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_spiral_sym_mu_zCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "spiral_sym_mza_a" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_spiral_sym_mza_aCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_triCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25_dnwod33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25_dnwod33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25_dnwod33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25_dnwod33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25_dnwud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25_dnwud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25_dnwud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25_dnwud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25od33" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25od33CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25od33_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25od33_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25ud18" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25ud18CB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_25ud18_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_25ud18_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_hvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_hvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_hvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_hvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_hvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_hvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_hvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_hvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_lvt" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_lvtCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_lvt_dnw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_lvt_dnwCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_lvt_dnw_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_lvt_dnw_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_lvt_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_lvt_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "tri_mac" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65lo_tri_macCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "xjvar" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_xjvarCB( 'model )
                  cnt++
              );if
              if( inst~>cellName == "xjvar_nw" then
                cdfgData=cdfGetInstCDF(inst)
                printf("Update the CDF of %s(%s) on %L\n"
                                inst~>name inst~>cellName inst~>xy)
                tsmcN65_xjvar_nwCB( 'model )
                  cnt++
              );if
            );inst~>libName
          );inst
          if(repName == "schematic" then schCheck(cvId))
          dbSave(cvId)
          dbClose(cvId)
        ); sch/lay
      );view
      );if the check is true.
    ); cell
    ); for different lib
    printf("Total number of callback triggered %L.\n" cnt)
  ); let
);procedure
