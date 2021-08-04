; Technology File cds_ff_mpt_wsp

;********************************
; CONTROLS
;********************************
controls(

 refTechLibs(
  "cds_ff_mpt"
 ) ;refTechLibs

) ;controls

;********************************
; LAYER DEFINITION
;********************************
layerDefinitions(

 techLayerPurposePriorities(
 ;layers are ordered from lowest to highest priority
 ;( LayerName                 Purpose    )
 ;( ---------                 -------    )
  ( BuriedNWell               drawing    )
  ( NWell                     drawing    )
  ( NWell                     net        )
  ( NWell                     boundary   )
  ( ThickOx                   drawing    )
  ( Active                    drawing    )
  ( Active                    net        )
  ( Active                    boundary   )
  ( Active                    fin        )
  ( Active                    SADPEnds   )
  ( Active                    dummy      )
  ( CutActive                 drawing    )
  ( TrimFin                   drawing    )
  ( CellBoundary              global     )
  ( FinArea                   fin48      )
  ( Psvt                      drawing    )
  ( Psvt                      net        )
  ( Psvt                      boundary   )
  ( Plvt                      drawing    )
  ( Plvt                      net        )
  ( Plvt                      boundary   )
  ( Phvt                      drawing    )
  ( Phvt                      net        )
  ( Phvt                      boundary   )
  ( Nsvt                      drawing    )
  ( Nsvt                      net        )
  ( Nsvt                      boundary   )
  ( Nlvt                      drawing    )
  ( Nlvt                      net        )
  ( Nlvt                      boundary   )
  ( Nhvt                      drawing    )
  ( Nhvt                      net        )
  ( Nhvt                      boundary   )
  ( CutPoly                   drawing    )
  ( Poly                      drawing    )
  ( Poly                      net        )
  ( Poly                      boundary   )
  ( Poly                      dummy      )
  ( Poly                      edge       )
  ( PPitch                    poly86     )
  ( PPitch                    poly90     )
  ( PPitch                    poly94     )
  ( PPitch                    poly102    )
  ( PPitch                    poly104    )
  ( M2                        localWSP   )
  ( M3                        localWSP   )
  ( M4                        localWSP   )
  ( M5                        localWSP   )
  ( SaB                       drawing    )
  ( LiPo                      drawing    )
  ( LiPo                      track      )
  ( LiPo                      net        )
  ( LiPo                      boundary   )
  ( LiPo                      grid       )
  ( LiPo                      blockage   )
  ( LiAct                     drawing    )
  ( LiAct                     track      )
  ( LiAct                     net        )
  ( LiAct                     boundary   )
  ( LiAct                     grid       )
  ( LiAct                     blockage   )
  ( V0                        drawing    )
  ( V0                        net        )
  ( V0                        boundary   )
  ( V0                        grid       )
  ( V0                        blockage   )
  ( V0                        fill       )
  ( M1                        drawing    )
  ( M1                        net        )
  ( M1                        boundary   )
  ( M1                        track      )
  ( M1                        pin        )
  ( M1                        grid       )
  ( M1                        blockage   )
  ( M1                        fill       )
  ( CutM1                     drawing    )
  ( CutM1Mask1                drawing    )
  ( CutM1Mask2                drawing    )
  ( V1                        drawing    )
  ( V1                        net        )
  ( V1                        boundary   )
  ( V1                        grid       )
  ( V1                        blockage   )
  ( V1                        fill       )
  ( M2                        drawing    )
  ( M2                        net        )
  ( M2                        boundary   )
  ( M2                        track      )
  ( M2                        pin        )
  ( M2                        grid       )
  ( M2                        blockage   )
  ( M2                        fill       )
  ( CutM2                     drawing    )
  ( CutM2Mask1                drawing    )
  ( CutM2Mask2                drawing    )
  ( V2                        drawing    )
  ( V2                        net        )
  ( V2                        boundary   )
  ( V2                        grid       )
  ( V2                        blockage   )
  ( V2                        fill       )
  ( M3                        drawing    )
  ( M3                        net        )
  ( M3                        boundary   )
  ( M3                        track      )
  ( M3                        pin        )
  ( M3                        grid       )
  ( M3                        blockage   )
  ( M3                        fill       )
  ( CutM3                     drawing    )
  ( CutM3Mask1                drawing    )
  ( CutM3Mask2                drawing    )
  ( V3                        drawing    )
  ( V3                        net        )
  ( V3                        boundary   )
  ( V3                        grid       )
  ( V3                        blockage   )
  ( V3                        fill       )
  ( M4                        drawing    )
  ( M4                        net        )
  ( M4                        boundary   )
  ( M4                        track      )
  ( M4                        pin        )
  ( M4                        grid       )
  ( M4                        blockage   )
  ( M4                        fill       )
  ( V4                        drawing    )
  ( V4                        net        )
  ( V4                        boundary   )
  ( V4                        grid       )
  ( V4                        fill       )
  ( V4                        blockage   )
  ( M5                        drawing    )
  ( M5                        net        )
  ( M5                        boundary   )
  ( M5                        track      )
  ( M5                        pin        )
  ( M5                        grid       )
  ( M5                        blockage   )
  ( M5                        fill       )
  ( V5                        drawing    )
  ( V5                        net        )
  ( V5                        boundary   )
  ( V5                        grid       )
  ( V5                        fill       )
  ( V5                        blockage   )
  ( M6                        drawing    )
  ( M6                        net        )
  ( M6                        boundary   )
  ( M6                        track      )
  ( M6                        pin        )
  ( M6                        grid       )
  ( M6                        blockage   )
  ( M6                        fill       )
  ( V6                        drawing    )
  ( V6                        net        )
  ( V6                        boundary   )
  ( V6                        grid       )
  ( V6                        fill       )
  ( V6                        blockage   )
  ( M7                        drawing    )
  ( M7                        net        )
  ( M7                        boundary   )
  ( M7                        track      )
  ( M7                        pin        )
  ( M7                        grid       )
  ( M7                        blockage   )
  ( M7                        fill       )
  ( CMT                       drawing    )
  ( CMT                       grid       )
  ( CMT                       blockage   )
  ( VT                        drawing    )
  ( VT                        net        )
  ( VT                        boundary   )
  ( VT                        grid       )
  ( VT                        fill       )
  ( VT                        blockage   )
  ( MT                        drawing    )
  ( MT                        net        )
  ( MT                        boundary   )
  ( MT                        track      )
  ( MT                        pin        )
  ( MT                        grid       )
  ( MT                        blockage   )
  ( MT                        fill       )
  ( m1res                     drawing    )
  ( m2res                     drawing    )
  ( m3res                     drawing    )
  ( m4res                     drawing    )
  ( m5res                     drawing    )
  ( m6res                     drawing    )
  ( m7res                     drawing    )
  ( mtres                     drawing    )
  ( nwstires                  drawing    )
  ( nwodres                   drawing    )
  ( diffres                   drawing    )
  ( pcres                     drawing    )
  ( diodmy                    drawing    )
  ( NPNdummy                  drawing    )
  ( mimW                      drawing    )
  ( mimL                      drawing    )
  ( text                      drawing    )
 ) ;techLayerPurposePriorities

 techDisplays(
 ;( LayerName    Purpose      Packet          Vis Sel Con2ChgLy DrgEnbl Valid )
 ;( ---------    -------      ------          --- --- --------- ------- ----- )
  ( M2           localWSP     m2WSP            t t nil t t )
  ( M3           localWSP     m3WSP            t t nil t t )
  ( M4           localWSP     m4WSP            t t nil t t )
  ( M5           localWSP     m5WSP            t t nil t t )
 ) ;techDisplays

 techDerivedLayers(
 ;( DerivedLayerName          #          composition  )
 ;( ----------------          ------     ------------ )
  ( M2WSP                     40000      ( M2           'select  localWSP  ))
  ( M3WSP                     40010      ( M3           'select  localWSP  ))
  ( M4WSP                     40020      ( M4           'select  localWSP  ))
  ( M5WSP                     40030      ( M5           'select  localWSP  ))
 ) ;techDerivedLayers

) ;layerDefinitions


;********************************
; LAYER RULES
;********************************
layerRules(

 widthSpacingPatterns(
; (t_name
;   ['offset           g_offset
;   ['repeatOffset]]
;   ['startingColor    g_color | 'shiftColor]
;   ['allowedRepeatMode {"none" | "steppedOnly" | "flippedOnly" }]
;   ['defaultRepeatMode {"stepped" | "flippedStartsWithOdd" | "defaultFlippedStartsWithEven"}]
;   'pattern           (
;      (['repeat       g_repeat
;       ['wireTypes    (l_wireTypes)]
;       ['colors       (l_colors)]]
;       'spec          (('width g_width 'space g_space ['color t_color] ['wireType wireType]) ...)
;      ) ...
;    )
; )
; ( -------------------------------------------------------------------------- )

  (minWidth    
    'offset             0.016
    'startingColor      "mask1Color"
    'pattern            (
       ('repeat         12
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
     )
  )

  (minWidthHalf
    'offset             0.016
    'startingColor      "mask1Color"
    'pattern            (
       ('repeat         6
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
     )
  )

  (minWidthDouble
    'offset             0.016
    'startingColor      "mask1Color"
    'pattern            (
       ('repeat         24
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
     )
  )

  ("2XWidth"   
    'offset             0.032
    'startingColor      "mask1Color"
    'pattern            (
       ('repeat         8
        'spec           (('width 0.064 'space 0.096 'wireType "2X" ))
       )
     )
  )

  (stdCell     
    'startingColor      "mask1Color"
    'pattern            (
       ('spec           (('width 0.096 'space 0.096 'wireType "3X" ))
       )
       ('repeat         9
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
       ('spec           (('width 0.032 'space 0.096 'wireType "1X" ))
       )
     )
  )

  (stdCellMultiWidth
    'shiftColor        
    'pattern            (
       ('spec           (('width 0.096 'space 0.096 'color "mask1Color" 'wireType "3X" ))
       )
       ('repeat         4
        'spec           (('width 0.032 'space 0.0 'color "mask2Color" 'wireType "1X" )
                         ('width 0.048 'space 0.064 'color "mask2Color" 'wireType "1.5X" )
                         ('width 0.032 'space 0.0 'color "mask1Color" 'wireType "1X" )
                         ('width 0.048 'space 0.0 'color "mask1Color" 'wireType "1.5X" )
                         ('width 0.064 'space 0.064 'color "mask1Color" 'wireType "2X" ))
       )
       ('spec           (('width 0.032 'space 0.0 'color "mask2Color" 'wireType "1X" )
                         ('width 0.048 'space 0.064 'color "mask2Color" 'wireType "1.5X" )
                         ('width 0.032 'space 0.096 'color "mask1Color" 'wireType "1X" ))
       )
     )
  )

  (stdCellHalf 
    'startingColor      "mask1Color"
    'pattern            (
       ('spec           (('width 0.096 'space 0.096 'wireType "3X" ))
       )
       ('repeat         3
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
       ('spec           (('width 0.032 'space 0.096 'wireType "1X" ))
       )
     )
  )

  (stdCellDouble
    'startingColor      "mask1Color"
    'pattern            (
       ('spec           (('width 0.096 'space 0.096 'wireType "3X" ))
       )
       ('repeat         21
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
       ('spec           (('width 0.032 'space 0.096 'wireType "1X" ))
       )
     )
  )

  (stdCellFlipped
    'offset             0.048
    'startingColor      "mask1Color"
    'allowedRepeatMode  "flippedOnly"
    'defaultRepeatMode  "flippedStartsWithOdd"
    'pattern            (
       ('spec           (('width 0.096 'space 0.096 'wireType "3X" ))
       )
       ('repeat         9
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
       ('spec           (('width 0.032 'space 0.096 'wireType "1X" ))
       )
     )
  )

  (diffTrackTopBottom
    'startingColor      "mask1Color"
    'allowedRepeatMode  "flippedOnly"
    'defaultRepeatMode  "flippedStartsWithOdd"
    'pattern            (
       ('spec           (('width 0.096 'space 0.096 'wireType "3X" ))
       )
       ('repeat         3
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
       ('spec           (('width 0.032 'space 0.48 'wireType "1X" ))
       )
       ('spec           (('width 0.048 'space 0.0 'wireType "1X" ))
       )
     )
  )

  (stdCellStepped
    'offset             0.048
    'startingColor      "mask1Color"
    'allowedRepeatMode  "steppedOnly"
    'defaultRepeatMode  "stepped"
    'pattern            (
       ('spec           (('width 0.096 'space 0.096 'wireType "3X" ))
       )
       ('repeat         9
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
       ('spec           (('width 0.032 'space 0.096 'wireType "1X" ))
       )
     )
  )

  (stdCellSingleHigh
    'offset             0.048
    'startingColor      "mask1Color"
    'allowedRepeatMode  "none"
    'pattern            (
       ('spec           (('width 0.096 'space 0.096 'wireType "3X" ))
       )
       ('repeat         9
        'spec           (('width 0.032 'space 0.064 'wireType "1X" ))
       )
       ('spec           (('width 0.032 'space 0.048 'wireType "1X" ))
       )
     )
  )

  (WSP1        
    'offset             0.016
    'repeatOffset      
    'pattern            (
       ('spec           (('width 0.032 'space 0.072 'color "mask1Color" 'wireType "1X" )
                         ('width 0.048 'space 0.088 'color "mask2Color" ))
       )
       ('repeat         3
        'spec           (('width 0.064 'space 0.088 'color "mask1Color" 'wireType "2X" )
                         ('width 0.048 'space 0.088 'color "mask2Color" ))
       )
       ('spec           (('width 0.064 'space 0.064 'color "mask1Color" 'wireType "2X" ))
       )
     )
  )

  (WSP2        
    'offset             0.032
    'repeatOffset      
    'pattern            (
       ('spec           (('width 0.064 'space 0.088 'wireType "2X" ))
       )
       ('repeat         3
        'spec           (('width 0.048 'space 0.072 )
                         ('width 0.032 'space 0.072 'wireType "1X" ))
       )
       ('spec           (('width 0.048 'space 0.072 )
                         ('width 0.032 'space 0.08 'wireType "1X" )
                         ('width 0.064 'space 0.064 'wireType "2X" ))
       )
     )
  )

 ) ;widthSpacingPatterns

 widthSpacingPatternGroups(
; (t_name
;   'members           (l_patternNames)
; )
; ( -------------------------------------------------------------------------- )
  (basic       
    'members            ("minWidth" "2XWidth")
  )

  (multiWSP    
    'members            ("WSP1" "WSP2")
  )

 ) ;widthSpacingPatternGroups

 widthSpacingSnapPatternDefs(
; (t_name (tx_layer tx_purpose)
;   'period            g_period
;   'direction         {"horizontal" | "vertical"}
;   ['offset           g_offset]
;   'snappingLayers    (('layer tx_layer ['purposes l_purposes]) ... )
;   ['patterns]        (l_patterns)
;   ['patternGroups]   (l_patternGroups)
;   'defaultActive     t_defaultActivePatternName
; )
; ( -------------------------------------------------------------------------- )

  (M2WSSPD      ("M2"  "localWSP")
    'period             0.768
    'direction          "vertical"
    'snappingLayers     (('layer "M2" ))
    'patterns           ("stdCell" "stdCellFlipped" "stdCellStepped" "stdCellSingleHigh" "diffTrackTopBottom" "stdCellMultiWidth")
    'patternGroups      ("basic" "multiWSP")
    'defaultActive      "minWidth"
  )

  (M2WSSPD_half   ("M2"  "localWSP")
    'period             0.384
    'direction          "vertical"
    'snappingLayers     (('layer "M2" ))
    'patterns           ("minWidthHalf" "stdCellHalf")
    'defaultActive      "minWidthHalf"
  )

  (M2WSSPD_double ("M2"  "localWSP")
    'period             1.536
    'direction          "vertical"
    'snappingLayers     (('layer "M2" ))
    'patterns           ("minWidthDouble" "stdCellDouble")
    'defaultActive      "minWidthDouble"
  )

  (M3WSSPD        ("M3"  "localWSP")
    'period             0.768
    'direction          "horizontal"
    'snappingLayers     (('layer "M3" ))
    'patternGroups      ("basic" "multiWSP")
    'defaultActive      "minWidth"
  )

  (M3WSSPD_double ("M3"  "localWSP")
    'period             1.536
    'direction          "horizontal"
    'snappingLayers     (('layer "M3" ))
    'patterns           ("minWidthDouble" "stdCellDouble")
    'defaultActive      "minWidthDouble"
  )

  (M4WSSPD        ("M4"  "localWSP")
    'period             0.768
    'direction          "vertical"
    'snappingLayers     (('layer "M4" ))
    'patternGroups      ("basic" "multiWSP")
    'defaultActive      "minWidth"
  )

  (M4WSSPD_singleHigh ("M4"  "localWSP")
    'period             0.768
    'direction          "vertical"
    'snappingLayers     (('layer "M4" ))
    'patterns           ("stdCellSingleHigh")
    'defaultActive      "stdCellSingleHigh"
  )

  (M5WSSPD        ("M5"  "localWSP")
    'period             0.768
    'direction          "horizontal"
    'snappingLayers     (('layer "M5" ))
    'patternGroups      ("basic" "multiWSP")
    'defaultActive      "minWidth"
  )

 ) ;widthSpacingSnapPatternDefs

 relatedSnapPatterns(
; (t_name
;   'snapPatternDefs     (
;     (t_snapPatternDefName
;       ['patterns       (l_patterns)]
;       ['patternGroups  (l_patternGroups)]
;     )
;   )
; )
; ( -------------------------------------------------------------------------- )
  (minWidthStack
    'snapPatternDefs    (
       (M2WSSPD           'patterns ("minWidth")
       )
       (M3WSSPD           'patterns ("minWidth")
       )
       (M4WSSPD           'patterns ("minWidth")
       )
       (M5WSSPD           'patterns ("minWidth")
       )
     )
  )

  ("1X_2X_Stack"
    'snapPatternDefs    (
       (M2WSSPD           'patternGroups ("basic")
       )
       (M3WSSPD           'patterns ("minWidth" "2XWidth")
       )
       (M4WSSPD           'patterns ("2XWidth")
       )
       (M5WSSPD           'patterns ("2XWidth")
       )
     )
  )

 ) ;relatedSnapPatterns

) ;layerRules


;********************************
; CONSTRAINT GROUPS
;********************************
constraintGroups(

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "wspRegions"	nil    nil    'and

    spacings(
     ( allowedWidthRanges         "M2WSP"	'measureVertical	'stepSize  0.768	(">= 0.768") )
     ( allowedWidthRanges         "M2WSP"	'measureHorizontal	(">= 0.032") )
     ( allowedWidthRanges         "M3WSP"	'measureHorizontal	'stepSize  0.768	(">= 0.768") )
     ( allowedWidthRanges         "M3WSP"	'measureVertical	(">= 0.032") )
     ( allowedWidthRanges         "M4WSP"	'measureVertical	'stepSize  0.768	(">= 0.768") )
     ( allowedWidthRanges         "M4WSP"	'measureHorizontal	(">= 0.032") )
     ( allowedWidthRanges         "M5WSP"       'measureHorizontal      'stepSize  0.768        (">= 0.768") )
     ( allowedWidthRanges         "M5WSP"       'measureVertical        (">= 0.032") )
    ) ;spacings
  ) ;wspRegions

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "foundry"	nil

    memberConstraintGroups(
    ; listed in order of precedence
    ; -----------------------------
    "wspRegions"
    ); memberConstraintGroups

    spacings(
     ( snapGridVertical           ("GFG" "M2WSSPD" "M4WSSPD") )
     ( snapGridHorizontal         ("GPG86" "GPG90" "M3WSSPD" "M5WSSPD") )
    ) ;spacings

  ) ;foundry
) ;constraintGroups

