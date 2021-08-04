; Technology File cds_ff_mpt


;********************************
; CONTROLS
;********************************
controls(
 techVersion("1.0")

 techParams(
 ;( parameter           value             )
 ;( ----------          -----             )
  ( minFingerCountInGroup	7               )
  ( minSupportingFingerCount	2               )
  ( minFingerCountInProtrusion	2               )
  ( minFingerCountInValley	4               )
 ) ;techParams

 viewTypeUnits(
 ;( viewType            userUnit       dbuperuu           )
 ;( --------            --------       --------           )
  ( maskLayout     	"micron"       	2000            )
  ( schematic      	"inch"         	160             )
  ( schematicSymbol	"inch"         	160             )
  ( netlist        	"inch"         	160             )
  ( hierDesign     	"micron"       	2000            )
 ) ;viewTypeUnits

 mfgGridResolution(
      ( 0.001000 )
 ) ;mfgGridResolution

 processFamily(
      "cds_ff_mpt"
 ) ;processFamily

 processNode(0.01)

) ;controls


;********************************
; LAYER DEFINITION
;********************************
layerDefinitions(

 techPurposes(
 ;( PurposeName               Purpose#   Abbreviation   [Attributes] )
 ;( -----------               --------   ------------   ------------ )
 ;User-Defined Purposes:
  ( dummy                     1000       DMY          
    'parent "customFill")
  ( fin                       12000      fin          )
  ( SADPEnds                  20000      SADPE        )
  ( fin48                     30000      F48          
    'parent "annotation")
  ( global                    30030      GG48         
    'parent "annotation")
  ( poly86                    30100      PP86         
    'parent "annotation")
  ( poly90                    30110      PP90         
    'parent "annotation")
  ( poly94                    30120      PP94         
    'parent "annotation")
  ( poly102                   30130      PP102        
    'parent "annotation")
  ( poly104                   30140      PP104        
    'parent "annotation")
  ( localWSP                  40000      WSP          
    'parent "annotation")
  ( edge                      99900      edge         )
 ) ;techPurposes

 techLayers(
 ;( LayerName                 Layer#     Abbreviation   [#Masks] )
 ;( ---------                 ------     ------------   -------- )
 ;User-Defined Layers:
  ( BuriedNWell               3          DNW          )
  ( NWell                     5          NW           )
  ( Active                    10         ACT          )
  ( CutActive                 11         CACT         )
  ( FinArea                   12         FA           )
  ( CellBoundary              13         CB           )
  ( Psvt                      15         PP           )
  ( Nsvt                      16         NP           )
  ( TrimFin                   18         TF           )
  ( Poly                      20         PO           )
  ( CutPoly                   21         CPO          )
  ( PPitch                    22         PP           )
  ( LiPo                      25         LiPo         )
  ( LiAct                     40         LiAct        )
  ( V0                        50         V0           )
  ( M1                        60         M1           2        )
  ( CutM1                     64         CM1          )
  ( CutM1Mask1                65         CM1MSK1      )
  ( CutM1Mask2                66         CM1MSK2      )
  ( V1                        70         V1           4        )
  ( M2                        80         M2           2        )
  ( CutM2                     85         CM2          )
  ( CutM2Mask1                86         CM2MSK1      )
  ( CutM2Mask2                87         CM2MSK2      )
  ( V2                        90         V2           4        )
  ( M3                        100        M3           2        )
  ( CutM3                     102        CM3          )
  ( CutM3Mask1                103        CM3MSK1      )
  ( CutM3Mask2                104        CM3MSK2      )
  ( V3                        105        V3           4        )
  ( M4                        110        M4           )
  ( V4                        115        V4           )
  ( M5                        120        M5           )
  ( V5                        125        V5           )
  ( M6                        130        M6           )
  ( V6                        135        V6           )
  ( M7                        140        M7           )
  ( VT                        145        VT           )
  ( MT                        150        MT           )
  ( CMT                       99900      CMT          )
  ( m1res                     99901      m1res        )
  ( m2res                     99902      m2res        )
  ( m3res                     99903      m3res        )
  ( m4res                     99904      m4res        )
  ( m5res                     99905      m5res        )
  ( m6res                     99906      m6res        )
  ( m7res                     99907      m7res        )
  ( mtres                     99908      mtres        )
  ( nwstires                  99912      nwstires     )
  ( nwodres                   99913      nwodres      )
  ( diffres                   99914      diffres      )
  ( pcres                     99915      pcres        )
  ( diodmy                    99916      diodmy       )
  ( ThickOx                   99918      THOX         )
  ( Nlvt                      99920      NLVT         )
  ( Nhvt                      99921      NHVT         )
  ( Plvt                      99930      PLVT         )
  ( Phvt                      99931      PHVT         )
  ( SaB                       99932      SAB          )
  ( NPNdummy                  99933      NPNdummy     )
  ( mimW                      99934      mimW         )
  ( mimL                      99935      mimL         )
 ) ;techLayers

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
  ( BuriedNWell  drawing      DNWELLD          t t t t t )
  ( NWell        drawing      nwell            t t t t t )
  ( NWell        net          nwell_net        t t t nil nil )
  ( NWell        boundary     nwell_boundary   t t t nil nil )
  ( ThickOx      drawing      thox             t t t t t )
  ( Active       drawing      active           t t t t t )
  ( Active       net          Oxide_net        t t t nil nil )
  ( Active       boundary     Oxide_boundary   t t t nil nil )
  ( Active       fin          fin              nil nil nil nil nil )
  ( Active       SADPEnds     SADPEnds         nil nil nil nil nil )
  ( Active       dummy        active           t t t t t )
  ( CutActive    drawing      cutActive        t t t t t )
  ( TrimFin      drawing      cutFin           nil nil nil nil nil )
  ( CellBoundary global       GFG              t t t t t )
  ( FinArea      fin48        FB               t t t t t )
  ( Psvt         drawing      PP               t t t t t )
  ( Psvt         net          pplus_net        t t t nil nil )
  ( Psvt         boundary     Pimp_boundary    t t t nil nil )
  ( Plvt         drawing      plvt             t t t t t )
  ( Plvt         net          plvt_net         t t t nil nil )
  ( Plvt         boundary     plvt_boundary    t t t nil nil )
  ( Phvt         drawing      phvt             t t t t t )
  ( Phvt         net          phvt_net         t t t nil nil )
  ( Phvt         boundary     phvt_boundary    t t t nil nil )
  ( Nsvt         drawing      NP               t t t t t )
  ( Nsvt         net          nplus_net        t t t nil nil )
  ( Nsvt         boundary     Nimp_boundary    t t t nil nil )
  ( Nlvt         drawing      nlvt             t t t t t )
  ( Nlvt         net          nlvt_net         t t t nil nil )
  ( Nlvt         boundary     nlvt_boundary    t t t nil nil )
  ( Nhvt         drawing      nhvt             t t t t t )
  ( Nhvt         net          nhvt_net         t t t nil nil )
  ( Nhvt         boundary     nhvt_boundary    t t t nil nil )
  ( CutPoly      drawing      cutPoly          t t t t t )
  ( Poly         drawing      poly             t t t t t )
  ( Poly         net          Poly_net         t t t nil nil )
  ( Poly         boundary     Poly_boundary    t t t nil nil )
  ( Poly         dummy        polyDummy        t t t t t )
  ( Poly         edge         polyEdge         t t t t t )
  ( PPitch       poly86       CPP              t t t t t )
  ( PPitch       poly90       CPP              t t t t t )
  ( PPitch       poly94       CPP              t t t t t )
  ( PPitch       poly102      CPP              t t t t t )
  ( PPitch       poly104      CPP              t t t t t )
  ( SaB          drawing      sab              t t t t t )
  ( LiPo         drawing      lipo             t t t t t )
  ( LiPo         track        lipo             nil nil t t nil )
  ( LiPo         net          lipo_net         t t t nil nil )
  ( LiPo         boundary     lipo_boundary    t t t nil nil )
  ( LiPo         grid         lipo             t nil nil nil nil )
  ( LiPo         blockage     lipo             t nil t t nil )
  ( LiAct        drawing      liact            t t t t t )
  ( LiAct        track        liact            nil nil t t nil )
  ( LiAct        net          liact_net        t t t nil nil )
  ( LiAct        boundary     liact_boundary   t t t nil nil )
  ( LiAct        grid         liact            t nil nil nil nil )
  ( LiAct        blockage     liact            t nil t t nil )
  ( V0           drawing      v0               t t t t t )
  ( V0           net          v0_net           t t t nil nil )
  ( V0           boundary     v0_boundary      t t t nil nil )
  ( V0           grid         defaultPacket    t t t t t )
  ( V0           blockage     defaultPacket    t t t t t )
  ( V0           fill         defaultPacket    t t t t t )
  ( M1           drawing      m1               t t t t t )
  ( M1           net          m1_net           t t t nil nil )
  ( M1           boundary     m1_boundary      t t t nil nil )
  ( M1           track        m1               nil nil t t nil )
  ( M1           pin          m1               t t t t t )
  ( M1           grid         m1               t t nil t t )
  ( M1           blockage     m1               t t nil t t )
  ( M1           fill         m1               t t nil t t )
  ( CutM1        drawing      cutM1            t t t t t )
  ( CutM1Mask1   drawing      cutM1            t t t t t )
  ( CutM1Mask2   drawing      cutM1            t t t t t )
  ( V1           drawing      v1               t t t t t )
  ( V1           net          v1_net           t t t nil nil )
  ( V1           boundary     v1_boundary      t t t nil nil )
  ( V1           grid         defaultPacket    t t t t t )
  ( V1           blockage     v1               t t nil t t )
  ( V1           fill         v1               t t nil t t )
  ( M2           drawing      m2               t t t t t )
  ( M2           net          m2_net           t t t nil nil )
  ( M2           boundary     m2_boundary      t t t nil nil )
  ( M2           track        m2               nil nil t t nil )
  ( M2           pin          m2               t t t t t )
  ( M2           grid         m2               t t nil t t )
  ( M2           blockage     m2               t t nil t t )
  ( M2           fill         m2               t t nil t t )
  ( CutM2        drawing      cutM2            t t t t t )
  ( CutM2Mask1   drawing      cutM2            t t t t t )
  ( CutM2Mask2   drawing      cutM2            t t t t t )
  ( V2           drawing      v2               t t t t t )
  ( V2           net          v2_net           t t t nil nil )
  ( V2           boundary     v2_boundary      t t t nil nil )
  ( V2           grid         v2               t nil nil nil nil )
  ( V2           blockage     v2               t nil nil t nil )
  ( V2           fill         v2               t t nil t t )
  ( M3           drawing      m3               t t t t t )
  ( M3           net          m3_net           t t t nil nil )
  ( M3           boundary     m3_boundary      t t t nil nil )
  ( M3           track        m3               nil nil t t nil )
  ( M3           pin          m3               t t t t t )
  ( M3           grid         m3               t nil nil nil nil )
  ( M3           blockage     m3               t nil nil t nil )
  ( M3           fill         m3               t t nil t nil )
  ( CutM3        drawing      cutM3            t t t t t )
  ( CutM3Mask1   drawing      cutM3            t t t t t )
  ( CutM3Mask2   drawing      cutM3            t t t t t )
  ( V3           drawing      v3               t t t t t )
  ( V3           net          v3_net           t t t nil nil )
  ( V3           boundary     v3_boundary      t t t nil nil )
  ( V3           grid         v3               t nil nil nil nil )
  ( V3           blockage     v3               t nil nil t nil )
  ( V3           fill         v3               t t nil t t )
  ( M4           drawing      m4               t t t t t )
  ( M4           net          m4_net           t t t nil nil )
  ( M4           boundary     m4_boundary      t t t nil nil )
  ( M4           track        m4               nil nil t t nil )
  ( M4           pin          m4               t t t t t )
  ( M4           grid         m4               t nil nil nil nil )
  ( M4           blockage     m4               t nil nil t nil )
  ( M4           fill         m4               t t nil t nil )
  ( V4           drawing      v4               t t t t t )
  ( V4           net          v4_net           t t t nil nil )
  ( V4           boundary     v4_boundary      t t t nil nil )
  ( V4           grid         v4               t nil nil nil nil )
  ( V4           fill         defaultPacket    t t t t t )
  ( V4           blockage     v4               t nil nil t nil )
  ( M5           drawing      m5               t t t t t )
  ( M5           net          m5_net           t t t nil nil )
  ( M5           boundary     m5_boundary      t t t nil nil )
  ( M5           track        m5               nil nil t t nil )
  ( M5           pin          m5               t t t t t )
  ( M5           grid         m5               t nil nil nil nil )
  ( M5           blockage     m5               t nil nil t nil )
  ( M5           fill         m5               t t nil t nil )
  ( V5           drawing      v5               t t t t t )
  ( V5           net          v5_net           t t t nil nil )
  ( V5           boundary     v5_boundary      t t t nil nil )
  ( V5           grid         v5               t nil nil nil nil )
  ( V5           fill         v5               t t nil t nil )
  ( V5           blockage     v5               t nil nil t nil )
  ( M6           drawing      m6               t t t t t )
  ( M6           net          m6_net           t t t nil nil )
  ( M6           boundary     m6_boundary      t t t nil nil )
  ( M6           track        m6               nil nil t t nil )
  ( M6           pin          m6               t t t t t )
  ( M6           grid         m6               t nil nil nil nil )
  ( M6           blockage     m6               t nil nil t nil )
  ( M6           fill         m6               t t nil t nil )
  ( V6           drawing      v6               t t t t t )
  ( V6           net          v6_net           t t t nil nil )
  ( V6           boundary     v6_boundary      t t t nil nil )
  ( V6           grid         v6               t nil nil nil nil )
  ( V6           fill         v6               t t nil t nil )
  ( V6           blockage     v6               t nil nil t nil )
  ( M7           drawing      mx               t t t t t )
  ( M7           net          m7_net           t t t nil nil )
  ( M7           boundary     m7_boundary      t t t nil nil )
  ( M7           track        m7               nil nil t t nil )
  ( M7           pin          mx               t t t t t )
  ( M7           grid         m7               t nil nil nil nil )
  ( M7           blockage     m7               t nil nil t nil )
  ( M7           fill         m7               t t nil t nil )
  ( CMT          drawing      defaultPacket    t t t t t )
  ( CMT          grid         defaultPacket    t nil nil nil nil )
  ( CMT          blockage     defaultPacket    t nil t t nil )
  ( VT           drawing      v7               t t t t t )
  ( VT           net          v7_net           t t t nil nil )
  ( VT           boundary     v7_boundary      t t t nil nil )
  ( VT           grid         v7               t nil nil nil nil )
  ( VT           fill         v7               t t nil t nil )
  ( VT           blockage     v7               t nil nil t nil )
  ( MT           drawing      m8               t t t t t )
  ( MT           net          m8_net           t t t nil nil )
  ( MT           boundary     m8_boundary      t t t nil nil )
  ( MT           track        m8               nil nil t t nil )
  ( MT           pin          m8               t t t t t )
  ( MT           grid         m8               t nil nil nil nil )
  ( MT           blockage     m8               t nil nil t nil )
  ( MT           fill         m8               t t nil t nil )
  ( m1res        drawing      resm1            t t t t t )
  ( m2res        drawing      resm2            t t t t t )
  ( m3res        drawing      resm3            t t t t t )
  ( m4res        drawing      resm4            t t t t t )
  ( m5res        drawing      resm5            t t t t t )
  ( m6res        drawing      resm6            t t t t t )
  ( m7res        drawing      resm7            t t t t t )
  ( mtres        drawing      resmt            t t t t t )
  ( nwstires     drawing      resnwsti         t t t t t )
  ( nwodres      drawing      resnwod          t t t t t )
  ( diffres      drawing      resdiff          t t t t t )
  ( pcres        drawing      respc            t t t t t )
  ( diodmy       drawing      dmydio           t t t t t )
  ( NPNdummy     drawing      dmynpn           t t t t t )
  ( mimW         drawing      dmymimw          t t t t t )
  ( mimL         drawing      dmymiml          t t t t t )
  ( text         drawing      text             t t t t t )
 ) ;techDisplays

 techLayerProperties(
 ;( PropName               Layer1 [ Layer2 ]            PropValue )
 ;( --------               ------ ----------            --------- )
  ( techCstId              Poly                           "CDS.PO.A.0" )
  ( techCstText            Poly                           "Poly (not CPO) max area" )
 ) ;techLayerProperties

 techDerivedLayers(
 ;( DerivedLayerName          #          composition  )
 ;( ----------------          ------     ------------ )
  ( localInt                  6000       ( LiPo       'or     LiAct     ))
  ( badV0LI                   6001       ( V0         'avoiding  localInt  ))
  ( badV0M1                   6002       ( V0         'not    M1        ))
  ( badV1M1                   7001       ( V1         'not    M1        ))
  ( badV1M2                   7002       ( V1         'not    M2        ))
  ( badV2M2                   7011       ( V2         'not    M2        ))
  ( badV2M3                   7012       ( V2         'not    M3        ))
  ( badV3M3                   7021       ( V3         'not    M3        ))
  ( badV3M4                   7022       ( V3         'not    M4        ))
  ( badV4M4                   7031       ( V4         'not    M4        ))
  ( badV4M5                   7032       ( V4         'not    M5        ))
  ( badV5M5                   7041       ( V5         'not    M5        ))
  ( badV5M6                   7042       ( V5         'not    M6        ))
  ( badV6M6                   7051       ( V6         'not    M6        ))
  ( badV6M7                   7052       ( V6         'not    M7        ))
  ( badVTM7                   7061       ( VT         'not    M7        ))
  ( badVTMT                   7062       ( VT         'not    MT        ))
  ( bulkActive                10002      ( Active     'select  drawing   ))
  ( cutSubstrate              10003      ( substrate  'not    NWell     ))
  ( Gate                      10011      ( Poly       'and    Active    ))
  ( PolyNotCut                10012      ( Poly       'not    CutPoly   ))
  ( PolyNotRes                10013      ( Poly       'not    pcres     ))
  ( AllCutActive              10020      ( TrimFin    'or     CutActive ))
  ( ActiveNotCut              10021      ( Active     'not    CutActive ))
  ( ActiveNotGate             10022      ( Active     'not    Poly      ))
  ( trueActive                10023      ( Active     'not    AllCutActive))
  ( activeInterConn           10024      ( trueActive 'not    Poly      ))
  ( HvActive                  10027      ( Active     'and    ThickOx   ))
  ( NwellStiRes               10028      ( NWell      'touching  nwstires  ))
  ( NwellOdRes                10029      ( NWell      'touching  nwodres   ))
  ( NtypeImp                  11001      ( Nsvt       'or     Nlvt      ))
  ( NImplant                  11002      ( NtypeImp   'or     Nhvt      ))
  ( PtypeImp                  11005      ( Psvt       'or     Plvt      ))
  ( PImplant                  11006      ( PtypeImp   'or     Phvt      ))
  ( badImplant                11010      ( NImplant   'and    PImplant  ))
  ( Implant                   11015      ( NImplant   'or     PImplant  ))
  ( badActive                 11102      ( Active     'not    Implant   ))
  ( badPoly                   11103      ( Poly       'not    Implant   ))
  ( PActive                   11115      ( trueActive 'and    PImplant  ))
  ( NActive                   11116      ( trueActive 'and    NImplant  ))
  ( NWNotRes1                 11202      ( NWell      'not    nwstires  ))
  ( NWNotRes2                 11204      ( NWell      'not    nwodres   ))
  ( ActiveNotRes1             11206      ( Active     'not    diffres   ))
  ( ActiveNotRes2             11208      ( Active     'not    nwodres   ))
  ( preFin                    12001      ( Active     'select  fin      ))
  ( Fin                       12003      ( preFin     'not    TrimFin   ))
  ( finGate                   12004      ( Poly       'and    Fin       ))
  ( M1Mask1                   13000      ( M1         'color  mask1Color))
  ( M1Mask2                   13002      ( M1         'color  mask2Color))
  ( M1NotCut                  13004      ( M1         'not    CutM1     ))
  ( M1NotCutMask1             13006      ( M1Mask1    'not    CutM1Mask1))
  ( M1NotCutMask2             13008      ( M1Mask2    'not    CutM1Mask2))
  ( M1NotRes                  13009      ( M1         'not    m1res     ))
  ( M2Mask1                   13010      ( M2         'color  mask1Color))
  ( M2Mask2                   13012      ( M2         'color  mask2Color))
  ( M2NotCut                  13014      ( M2         'not    CutM2     ))
  ( M2NotCutMask1             13016      ( M2Mask1    'not    CutM2Mask1))
  ( M2NotCutMask2             13018      ( M2Mask2    'not    CutM2Mask2))
  ( M2NotRes                  13019      ( M2         'not    m2res     ))
  ( M3Mask1                   13020      ( M3         'color  mask1Color))
  ( M3Mask2                   13022      ( M3         'color  mask2Color))
  ( M3NotCut                  13024      ( M3         'not    CutM3     ))
  ( M3NotCutMask1             13026      ( M3Mask1    'not    CutM3Mask1))
  ( M3NotCutMask2             13028      ( M3Mask2    'not    CutM3Mask2))
  ( M3NotRes                  13029      ( M3         'not    m3res     ))
  ( M4NotRes                  13030      ( M4         'not    m4res     ))
  ( M5NotRes                  13032      ( M5         'not    m5res     ))
  ( M6NotRes                  13034      ( M6         'not    m6res     ))
  ( M7NotRes                  13036      ( M7         'not    m7res     ))
  ( MTNotRes                  13038      ( MT         'not    mtres     ))
  ( CB                        20000      ( CellBoundary 'select  global    ))
  ( FB48                      20001      ( FinArea    'select  fin48     ))
 ) ;techDerivedLayers

) ;layerDefinitions


;********************************
; LAYER RULES
;********************************
layerRules(

 functions(
 ;( layer                       function        [maskNumber]	[attributes])
 ;( -----                       --------        ------------	------------)
  ( BuriedNWell              	"recognition"	10           )
  ( NWell                    	"nwell"     	20           )
  ( ThickOx                  	"recognition"	30           )
  ( Active                   	"diff"      	40           )
  ( Nsvt                     	"nplus"     	50           )
  ( Nlvt                     	"nplus"     	60           )
  ( Nhvt                     	"nplus"     	70           )
  ( Psvt                     	"pplus"     	80           )
  ( Plvt                     	"pplus"     	90           )
  ( Phvt                     	"pplus"     	100          )
  ( FinArea                  	"recognition"	110          )
  ( TrimFin                  	"recognition"	120          )
  ( CutActive                	"trim"      	130		'trims ((Active ActiveNotCut) ))
  ( Poly                     	"poly"      	140          )
  ( PPitch                   	"recognition"	150          )
  ( CutPoly                  	"trim"      	160		'trims ((Poly PolyNotCut) ))
  ( LiAct                    	"li"        	180          )
  ( LiPo                     	"li"        	190          )
  ( V0                       	"cut"       	200          )
  ( M1                       	"metal"     	210          )
  ( CutM1                    	"trim"      	220		'trims ((M1 M1NotCut) ))
  ( CutM1Mask1               	"trim"      	222		'trims ((M1 M1NotCutMask1) ))
  ( CutM1Mask2               	"trim"      	224		'trims ((M1 M1NotCutMask2) ))
  ( V1                       	"cut"       	230          )
  ( M2                       	"metal"     	240          )
  ( CutM2                    	"trim"      	250		'trims ((M2 M2NotCut) ))
  ( CutM2Mask1               	"trim"      	260		'trims ((M2 M2NotCutMask1) ))
  ( CutM2Mask2               	"trim"      	270		'trims ((M2 M2NotCutMask2) ))
  ( V2                       	"cut"       	300          )
  ( M3                       	"metal"     	325          )
  ( CutM3                    	"trim"      	330		'trims ((M3 M3NotCut) ))
  ( CutM3Mask1               	"trim"      	335		'trims ((M3 M3NotCutMask1) ))
  ( CutM3Mask2               	"trim"      	340		'trims ((M3 M3NotCutMask2) ))
  ( V3                       	"cut"       	350          )
  ( M4                       	"metal"     	400          )
  ( V4                       	"cut"       	450          )
  ( M5                       	"metal"     	500          )
  ( V5                       	"cut"       	550          )
  ( M6                       	"metal"     	600          )
  ( V6                       	"cut"       	650          )
  ( M7                       	"metal"     	700          )
  ( CMT                      	"mimcap"    	710          )
  ( VT                       	"cut"       	750          )
  ( MT                       	"metal"     	800          )
  ( pcres                    	"recognition"	900          )
  ( diffres                  	"recognition"	905          )
  ( nwodres                  	"recognition"	910          )
  ( nwstires                 	"recognition"	915          )
  ( m1res                    	"recognition"	920          )
  ( m2res                    	"recognition"	925          )
  ( m3res                    	"recognition"	930          )
  ( m4res                    	"recognition"	935          )
  ( m5res                    	"recognition"	940          )
  ( m6res                    	"recognition"	945          )
  ( m7res                    	"recognition"	950          )
  ( mtres                    	"recognition"	955          )
 ) ;functions

 routingDirections(
 ;( layer                       direction     )
 ;( -----                       ---------     )
  ( LiPo                     	"vertical"   )
  ( LiAct                    	"vertical"   )
  ( M1                       	"horizontal" )
  ( M2                       	"vertical"   )
  ( M3                       	"horizontal" )
  ( M4                       	"vertical"   )
  ( M5                       	"horizontal" )
  ( M6                       	"vertical"   )
  ( M7                       	"horizontal" )
  ( MT                       	"vertical"   )
 ) ;routingDirections

 snapPatternDefs(
; (name (tx_layer tx_purpose)
;   'step              g_step
;   'stepDirection     {"horizontal" | "vertical"}
;   ['offset           g_offset]
;   ['snappingLayers   ( ('layer tx_layer 'enclosures l_enclosures ['purposes l_purposes])  ) ]
;   ['trackWidth       g_trackWidth]
;   ['trackGroups      ( ('count x_trackCount 'space n_spacing)  ) ]
;   ['type             {"local" | "global"}]
; )
; ( -------------------------------------------------------------------------- )
  (GFG          ("CellBoundary" "global")
     'step                 0.048
     'stepDirection        "vertical"
     'offset               0.024
     'snappingLayers       (('layer "FinArea" 'enclosures (0.007) 'purposes ("fin48"))('layer "Active" 'enclosures (0.007))('layer "CutActive" 'enclosures (0.024))('layer "TrimFin" 'enclosures (0.024)))
     'type                 "global"
  )
  (GPG86        ("PPitch" "poly86")
     'step                 0.086
     'stepDirection        "horizontal"
     'snappingLayers       (('layer "Poly" 'enclosures (0.009) 'purposes ("drawing" "dummy")))
     'type                 "local"
  )
  (GPG90        ("PPitch" "poly90")
     'step                 0.09
     'stepDirection        "horizontal"
     'snappingLayers       (('layer "Poly" 'enclosures (0.009 0.01) 'purposes ("drawing" "dummy")))
     'type                 "local"
  )
  (GPG94        ("PPitch" "poly94")
     'step                 0.094
     'stepDirection        "horizontal"
     'snappingLayers       (('layer "Poly" 'enclosures (0.009 0.01 0.012) 'purposes ("drawing" "dummy")))
     'type                 "local"
  )
  (GPG102       ("PPitch" "poly102")
     'step                 0.102
     'stepDirection        "horizontal"
     'snappingLayers       (('layer "Poly" 'enclosures (0.009 0.01 0.012 0.014) 'purposes ("drawing" "dummy")))
     'type                 "local"
  )
  (GPG104       ("PPitch" "poly104")
     'step                 0.104
     'stepDirection        "horizontal"
     'snappingLayers       (('layer "Poly" 'enclosures (0.009 0.01 0.012 0.015) 'purposes ("drawing" "dummy")))
     'type                 "local"
  )
  (FB48         ("FinArea" "fin48")
     'step                 0.048
     'stepDirection        "vertical"
     'offset               0.007
     'snappingLayers       (('layer "Active" 'enclosures (0.007))('layer "CutActive" 'enclosures (0.024))('layer "TrimFin" 'enclosures (0.024)))
     'trackWidth           0.014
     'type                 "local"
  )

 ) ;snapPatternDefs

 cutClasses(
 ;( layerName    )
 ;(   (cutClassName                                        (width length)) )
 ;( ---------------------------------------------------------------------- )
  (V1          
      (Default          'numCuts       1      (0.032 0.032))
      (Rect             'numCuts       2      (0.064 0.032))
  )
  (V2          
      (Default          'numCuts       1      (0.032 0.032))
      (Rect             'numCuts       2      (0.064 0.032))
  )
  (V3          
      (Default          'numCuts       1      (0.032 0.032))
      (Rect             'numCuts       2      (0.064 0.032))
  )
 ) ;cutClasses

) ;layerRules


;********************************
; VIADEFS
;********************************
viaDefs(

 standardViaDefs(
 ;( viaDefName	layer1	layer2	(cutLayer cutWidth cutHeight [resistancePerCut]) 
 ;   (cutRows	cutCol	(cutSpace)	[(l_cutPattern)]) 
 ;   (layer1Enc) (layer2Enc)	(layer1Offset)	(layer2Offset)	(origOffset) 
 ;   [implant1	 (implant1Enc)	[implant2	(implant2Enc) [well/substrate]]]) 
 ;( -------------------------------------------------------------------------- ) 
  ( M1_LiPo     	LiPo        M1          	("V0" 0.032 0.032)
     (1 1 (0.042 0.042))
     (-0.001 0.014)	(0.04 0.0)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( M1_LiAct    	LiAct       M1          	("V0" 0.032 0.032)
     (1 1 (0.042 0.042))
     (-0.001 0.018)	(0.0 0.04)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( LiPo_Poly   	Poly        LiPo        	("LiPo" 0.03 0.06)
     (1 1 (0.036 0.036))
     (-0.006 0.01)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( Li_PActive  	Active      LiAct       	("LiAct" 0.03 0.068)
     (1 1 (0.046 0.046))
     (0.019 -0.003)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
     Psvt        	(0.045 0.065)
  )
  ( Li_NActive  	Active      LiAct       	("LiAct" 0.03 0.068)
     (1 1 (0.046 0.046))
     (0.019 -0.003)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
     Nsvt        	(0.045 0.065)
  )
  ( Li_NWell    	Active      LiAct       	("LiAct" 0.03 0.068)
     (1 1 (0.046 0.046))
     (0.019 -0.003)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
     Nsvt        	(0.045 0.065)	NWell       	(0.065 0.065)	NWell          
  )
  ( Li_Substrate	Active      LiAct       	("LiAct" 0.03 0.068)
     (1 1 (0.046 0.046))
     (0.019 -0.003)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
     Psvt        	(0.045 0.065)	nil         	nil	substrate      
  )
  ( M2_M1       	M1          M2          	("V1" 0.032 0.032)
     (1 1 (0.042 0.042))
     (0.0 0.0)	(0.01 0.01)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( M3_M2       	M2          M3          	("V2" 0.032 0.032)
     (1 1 (0.042 0.042))
     (0.0 0.0)	(0.01 0.01)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( M4_M3       	M3          M4          	("V3" 0.032 0.032)
     (1 1 (0.042 0.042))
     (0.0 0.0)	(0.01 0.01)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( M5_M4       	M4          M5          	("V4" 0.042 0.042)
     (1 1 (0.064 0.064))
     (0.0 0.0)	(0.01 0.01)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( M6_M5       	M5          M6          	("V5" 0.042 0.042)
     (1 1 (0.064 0.064))
     (0.0 0.0)	(0.01 0.01)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( M7_M6       	M6          M7          	("V6" 0.064 0.064)
     (1 1 (0.084 0.084))
     (0.0 0.0)	(0.01 0.01)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( MT_M7       	M7          MT          	("VT" 0.1 0.1)
     (1 1 (0.12 0.12))
     (0.0 0.0)	(0.01 0.01)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
  ( MT_CMT      	CMT         MT          	("VT" 0.1 0.1)
     (1 1 (0.12 0.12))
     (0.0 0.0)	(0.01 0.01)	(0.0 0.0)	(0.0 0.0)	(0.0 0.0)
  )
 ) ;standardViaDefs

 customViaDefs(
  ;( viaDefName libName cellName viewName layer1 layer2 resistancePerCut)
  ;(--------------------------------------------------------------------)
   ( subTap  cds_ff_mpt subTap layout Active M1 0.0)
   ( nwellTap  cds_ff_mpt nwellTap layout Active M1 0.0)
   ( diffConn  cds_ff_mpt diffConn layout Active M1 0.0)
   ( polyConn  cds_ff_mpt polyConn layout Poly M1 0.0)
 ) ;customViaDefs

) ;viaDefs



;********************************
; CONSTRAINT GROUPS
;********************************
constraintGroups(

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "CBWidth"	nil    nil    'and

    spacings(
     ( allowedWidthRanges         "CB"	'measureVertical	'stepSize  0.048	(">= 0.24")  'ref  "CDS.CB.0"  'description  "Chip/Cell Boundary must be a multiple of Fin Pitch (48n)." )
     ( allowedWidthRanges         "CB"	'measureHorizontal	(">= 0.2") )
    ) ;spacings
  ) ;CBWidth

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "V0_CG"	nil    nil    'and

    spacings(
     ( minViaSpacing              "V0"	0.032  'ref  "V0.SP.1"  'description  "V0 minSpacing" )
    ) ;spacings

    spacingTables(
    ;( constraint 		layer1 		    [layer2]
    ;   (( index1Definitions    [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;( --------------------------------------------)
     ( minOppExtension           "LiAct"	"V0"	
	(( "width"   nil  nil  )  )
	 (
	   0.03      ( (-0.001 0.018) )
	   0.04      ( (0.003 0.018) )
	   0.05      ( (0.008 0.018) )
	)  'ref  "V0.E,1a, V0.E.1b, V0.E.1c"  'description  "LiAct extension around V0"
     )
     ( minOppExtension           "LiPo"	"V0"	
	(( "width"   nil  nil  )  )
	 (
	   0.03      ( (-0.001 0.014) )
	   0.04      ( (0.004 0.012) )
	   0.05      ( (0.009 0.009) )
	)  'ref  "V0.E,2a, V0.E.2b, V0.E.2c"  'description  "LiPo extension around V0"
     )
     ( minOppExtension           "M1"	"V0"	
	(( "width"   nil  nil  )  )
	 (
	   0.0       ( (0.0 0.04) (0.009 0.024) )
	)  'ref  "V0.E.3a, V0.E.3b"  'description  "M1 extension around V0"
     )
    ) ;spacingTables
  ) ;V0_CG

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "M1X_CG"	nil    nil    'and

    spacings(
     ( minEndOfLineSpacing        "M1"	'distance  0.015	'width  0.05	'otherEndWidth  0.05	'endToEndSpace  0.064	'sameMask	0.064  'ref  "M1.SP.4.1"  'description  "M1 [w<.050] EOL sameMask spacing violation" )
    ) ;spacings

    spacingTables(
    ;( constraint 		layer1 		    [layer2]
    ;   (( index1Definitions    [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;( --------------------------------------------)
     ( minSpacing                "M1"	
	(( "width"   nil  nil 	 "length"   nil   nil  )	'sameMask	0.048 )
	(
	   (0.0       	0.32      )	0.048     
	   (0.1       	0.32      )	0.072     
	   (0.1       	0.75      )	0.072     
	   (0.1       	1.5       )	0.072     
	   (0.75      	0.32      )	0.072     
	   (0.75      	0.75      )	0.112     
	   (0.75      	1.5       )	0.112     
	   (1.5       	0.32      )	0.072     
	   (1.5       	0.75      )	0.112     
	   (1.5       	1.5       )	0.22      
	)  'ref  "M1.SP.2.1, M1.SP.2.2, M1.SP.2.3, M1.SP.2.4"  'description  "M1 minimum Space Based on sameMask Width and Length"
     )
     ( minSpacing                "M1"	
	(( "width"   nil  nil 	 "length"   nil   nil  )	0.032 )
	(
	   (0.0       	0.32      )	0.032     
	   (0.1       	0.32      )	0.032     
	   (0.1       	0.75      )	0.032     
	   (0.1       	1.5       )	0.032     
	   (0.75      	0.32      )	0.032     
	   (0.75      	0.75      )	0.032     
	   (0.75      	1.5       )	0.032     
	   (1.5       	0.32      )	0.032     
	   (1.5       	0.75      )	0.032     
	   (1.5       	1.5       )	0.032     
	)  'ref  "M1.SP.1,1"  'description  "M1 minimum Space Based on diffMask Width and Length"
     )
    ) ;spacingTables

    spacings(
     ( minEndOfLineSpacing        "M2"	'distance  0.015	'width  0.05	'otherEndWidth  0.05	'endToEndSpace  0.064	'sameMask	0.064  'ref  "M2.SP.4.1"  'description  "M2 [w<.050] EOL sameMask spacing violation" )
    ) ;spacings

    spacingTables(
    ;( constraint 		layer1 		    [layer2]
    ;   (( index1Definitions    [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;( --------------------------------------------)
     ( minSpacing                "M2"	
	(( "width"   nil  nil 	 "length"   nil   nil  )	'sameMask	0.048 )
	(
	   (0.0       	0.32      )	0.048     
	   (0.1       	0.32      )	0.072     
	   (0.1       	0.75      )	0.072     
	   (0.1       	1.5       )	0.072     
	   (0.75      	0.32      )	0.072     
	   (0.75      	0.75      )	0.112     
	   (0.75      	1.5       )	0.112     
	   (1.5       	0.32      )	0.072     
	   (1.5       	0.75      )	0.112     
	   (1.5       	1.5       )	0.22      
	)  'ref  "M2.SP.2.1, M2.SP.2.2, M2.SP.2.3, M2.SP.2.4"  'description  "M2 minimum Space Based on sameMask Width and Length"
     )
     ( minSpacing                "M2"	
	(( "width"   nil  nil 	 "length"   nil   nil  )	0.032 )
	(
	   (0.0       	0.32      )	0.032     
	   (0.1       	0.32      )	0.032     
	   (0.1       	0.75      )	0.032     
	   (0.1       	1.5       )	0.032     
	   (0.75      	0.32      )	0.032     
	   (0.75      	0.75      )	0.032     
	   (0.75      	1.5       )	0.032     
	   (1.5       	0.32      )	0.032     
	   (1.5       	0.75      )	0.032     
	   (1.5       	1.5       )	0.032     
	)  'ref  "M2.SP.1.1"  'description  "M2 minimum Space Based on diffMask Width and Length"
     )
    ) ;spacingTables

    spacings(
     ( minEndOfLineSpacing        "M3"	'distance  0.015	'width  0.05	'otherEndWidth  0.05	'endToEndSpace  0.064	'sameMask	0.064  'ref  "M3.SP.4.1"  'description  "M3 [w<.050] EOL sameMask spacing violation" )
    ) ;spacings

    spacingTables(
    ;( constraint 		layer1 		    [layer2]
    ;   (( index1Definitions    [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;( --------------------------------------------)
     ( minSpacing                "M3"	
	(( "width"   nil  nil 	 "length"   nil   nil  )	'sameMask	0.048 )
	(
	   (0.0       	0.32      )	0.048     
	   (0.1       	0.32      )	0.072     
	   (0.1       	0.75      )	0.072     
	   (0.1       	1.5       )	0.072     
	   (0.75      	0.32      )	0.072     
	   (0.75      	0.75      )	0.112     
	   (0.75      	1.5       )	0.112     
	   (1.5       	0.32      )	0.072     
	   (1.5       	0.75      )	0.112     
	   (1.5       	1.5       )	0.22      
	)  'ref  "M3.SP.2.1, M3.SP.2.2, M3.SP.2.3, M3.SP.2.4"  'description  "M3 minimum Space Based on sameMask Width and Length"
     )
     ( minSpacing                "M3"	
	(( "width"   nil  nil 	 "length"   nil   nil  )	0.032 )
	(
	   (0.0       	0.32      )	0.032     
	   (0.1       	0.32      )	0.032     
	   (0.1       	0.75      )	0.032     
	   (0.1       	1.5       )	0.032     
	   (0.75      	0.32      )	0.032     
	   (0.75      	0.75      )	0.032     
	   (0.75      	1.5       )	0.032     
	   (1.5       	0.32      )	0.032     
	   (1.5       	0.75      )	0.032     
	   (1.5       	1.5       )	0.032     
	)  'ref  "M3.SP.1.1"  'description  "M3 minimum Space Based on diffMask Width and Length"
     )
    ) ;spacingTables

    spacings(
     ( minEndOfLineSpacing        "M4"	'distance  0.015	'width  0.05	'otherEndWidth  0.05	'endToEndSpace  0.064	0.064  'ref  "M4.SP.4.1"  'description  "M4 [w<.050] EOL spacing violation" )
    ) ;spacings

    spacingTables(
    ;( constraint 		layer1 		    [layer2]
    ;   (( index1Definitions    [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;( --------------------------------------------)
     ( minSpacing                "M4"	
	(( "width"   nil  nil 	 "length"   nil   nil  )	0.048 )
	(
	   (0.0       	0.32      )	0.048     
	   (0.1       	0.32      )	0.072     
	   (0.1       	0.75      )	0.072     
	   (0.1       	1.5       )	0.072     
	   (0.75      	0.32      )	0.072     
	   (0.75      	0.75      )	0.112     
	   (0.75      	1.5       )	0.112     
	   (1.5       	0.32      )	0.072     
	   (1.5       	0.75      )	0.112     
	   (1.5       	1.5       )	0.22      
	)  'ref  "M4.SP.2.1, M4.SP.2.2, M4.SP.2.3, M4.SP.2.4"  'description  "M4 minimum Space Based on Width and Length"
     )
    ) ;spacingTables
  ) ;M1X_CG

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "V1X_CG"	nil    nil    'and

    spacingTables(
    ;( constraint 		layer1 		    [layer2]
    ;   (( index1Definitions    [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;( --------------------------------------------)
     ( minNumCut                 "V1"	
	(( "width" nil nil )	'cutClass  0.032	'distanceWithin  0.064	 )
         (
            0.032     1         
            0.0965    2         
            0.3       4         
            1.0       8         
         )  'ref  "CDS V1.MNC"  'description  "You need more V1 cut shapes, for this width, at least "
     )
     ( minOppExtension           "M1"	"V1"	
	(( "width"   nil  nil  ) 'cutClass  (0.064 0.032)	'endSide	 )
	 (
	   0.0       ( (0.02 0.0) )
	   0.05      ( (0.012 0.009) )
	   0.052     ( (0.01 0.01) )
	   0.106     ( (0.01 0.0) )
	)  'ref  "M1BX.E.2.1, M1BX.E.2.2, M1BX.E.2.3, M1BX.E.2.4"  'description  "M1 extension around rectangular V1"
     )
     ( minQuadrupleExtension     "M1"	"V1"	
	(( "width"   nil  nil  ) 'cutClass  0.032	 )
	 (
	   0.0        ( (0.04 0.04 0.0 0.0) )
	   0.036      ( (0.002 0.002 0.034 0.05) )
	   0.052      ( (0.028 0.028 0.01 0.01) )
	   0.068      ( (0.018 0.018 0.018 0.018) )
	)  'ref  "M1BX.E.1.1, M1BX.E.1.2, M1BX.E.1.3, M1BX.E.1.4"  'description  "Invalid M1 extension around square V1"
     )
     ( minOppExtension           "M2"	"V1"	
	(( "width"   nil  nil  ) 'cutClass  (0.064 0.032)	'endSide	 )
	 (
	   0.0       ( (0.02 0.0) )
	   0.05      ( (0.012 0.009) )
	   0.052     ( (0.01 0.01) )
	   0.106     ( (0.01 0.0) )
	)  'ref  "M2TX.E.2.1, M2TX.E.2.2, M2TX.E.2.3, M2TX.E.2.4"  'description  "M2 extension around rectangular V1"
     )
     ( minQuadrupleExtension     "M2"	"V1"	
	(( "width"   nil  nil  ) 'cutClass  0.032	 )
	 (
	   0.0        ( (0.04 0.04 0.0 0.0) )
	   0.036      ( (0.002 0.002 0.034 0.05) )
	   0.052      ( (0.028 0.028 0.01 0.01) )
	   0.068      ( (0.018 0.018 0.018 0.018) )
	)  'ref  "M2TX.E.1.1, M2TX.E.1.2, M2TX.E.1.3, M2TX.E.1.4"  'description  "Invalid M2 extension around square V1"
     )
     ( minNumCut                 "V2"	
	(( "width" nil nil )	'cutClass  0.032	'distanceWithin  0.064	 )
         (
            0.032     1         
            0.0965    2         
            0.3       4         
            1.0       8         
         )  'ref  "CDS V2.MNC"  'description  "You need more V2 cut shapes, for this width, at least "
     )
     ( minOppExtension           "M2"	"V2"	
	(( "width"   nil  nil  ) 'cutClass  (0.064 0.032)	'endSide	 )
	 (
	   0.0       ( (0.02 0.0) )
	   0.05      ( (0.012 0.009) )
	   0.052     ( (0.01 0.01) )
	   0.106     ( (0.01 0.0) )
	)  'ref  "M2BX.E.2.1, M2BX.E.2.2, M2BX.E.2.3, M2BX.E.2.4"  'description  "M2 extension around rectangular V2"
     )
     ( minQuadrupleExtension     "M2"	"V2"	
	(( "width"   nil  nil  ) 'cutClass  0.032	 )
	 (
	   0.0        ( (0.04 0.04 0.0 0.0) )
	   0.036      ( (0.002 0.002 0.034 0.05) )
	   0.052      ( (0.028 0.028 0.01 0.01) )
	   0.068      ( (0.018 0.018 0.018 0.018) )
	)  'ref  "M2BX.E.1.1, M2BX.E.1.2, M2BX.E.1.3, M2BX.E.1.4"  'description  "Invalid M2 extension around square V2"
     )
     ( minOppExtension           "M3"	"V2"	
	(( "width"   nil  nil  ) 'cutClass  (0.064 0.032)	'endSide	 )
	 (
	   0.0       ( (0.02 0.0) )
	   0.05      ( (0.012 0.009) )
	   0.052     ( (0.01 0.01) )
	   0.106     ( (0.01 0.0) )
	)  'ref  "M3TX.E.2.1, M3TX.E.2.2, M3TX.E.2.3, M3TX.E.2.4"  'description  "M3 extension around rectangular V2"
     )
     ( minQuadrupleExtension     "M3"	"V2"	
	(( "width"   nil  nil  ) 'cutClass  0.032	 )
	 (
	   0.0        ( (0.04 0.04 0.0 0.0) )
	   0.036      ( (0.002 0.002 0.034 0.05) )
	   0.052      ( (0.028 0.028 0.01 0.01) )
	   0.068      ( (0.018 0.018 0.018 0.018) )
	)  'ref  "M3TX.E.1.1, M3TX.E.1.2, M3TX.E.1.3, M3TX.E.1.4"  'description  "Invalid M3 extension around square V2"
     )
     ( minNumCut                 "V3"	
	(( "width" nil nil )	'cutClass  0.032	'distanceWithin  0.064	 )
         (
            0.032     1         
            0.0965    2         
            0.3       4         
            1.0       8         
         )  'ref  "CDS V3.MNC"  'description  "You need more V3 cut shapes, for this width, at least "
     )
     ( minOppExtension           "M3"	"V3"	
	(( "width"   nil  nil  ) 'cutClass  (0.064 0.032)	'endSide	 )
	 (
	   0.0       ( (0.02 0.0) )
	   0.05      ( (0.012 0.009) )
	   0.052     ( (0.01 0.01) )
	   0.106     ( (0.01 0.0) )
	)  'ref  "M3BX.E.2.1, M3BX.E.2.2, M3BX.E.2.3, M3BX.E.2.4"  'description  "M3 extension around rectangular V3"
     )
     ( minQuadrupleExtension     "M3"	"V3"	
	(( "width"   nil  nil  ) 'cutClass  0.032	 )
	 (
	   0.0        ( (0.04 0.04 0.0 0.0) )
	   0.036      ( (0.002 0.002 0.034 0.05) )
	   0.052      ( (0.028 0.028 0.01 0.01) )
	   0.068      ( (0.018 0.018 0.018 0.018) )
	)  'ref  "M3BX.E.1.1, M3BX.E.1.2, M3BX.E.1.3, M3BX.E.1.4"  'description  "Invalid M3 extension around square V3"
     )
     ( minOppExtension           "M4"	"V3"	
	(( "width"   nil  nil  ) 'cutClass  (0.064 0.032)	'endSide	 )
	 (
	   0.0       ( (0.02 0.0) )
	   0.05      ( (0.012 0.009) )
	   0.052     ( (0.01 0.01) )
	   0.106     ( (0.01 0.0) )
	)  'ref  "M4TX.E.2.1, M4TX.E.2.2, M4TX.E.2.3, M4TX.E.2.4"  'description  "M4 extension around rectangular V3"
     )
     ( minQuadrupleExtension     "M4"	"V3"	
	(( "width"   nil  nil  ) 'cutClass  0.032	 )
	 (
	   0.0        ( (0.04 0.04 0.0 0.0) )
	   0.036      ( (0.002 0.002 0.034 0.05) )
	   0.052      ( (0.028 0.028 0.01 0.01) )
	   0.068      ( (0.018 0.018 0.018 0.018) )
	)  'ref  "M4TX.E.1.1, M4TX.E.1.2, M4TX.E.1.3, M4TX.E.1.4"  'description  "Invalid M4 extension around square V3"
     )
    ) ;spacingTables
  ) ;V1X_CG

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "TAP_CG"	nil    nil    'and

    orderedSpacings(
     ( minExtensionDistance       "Poly"	"V0"		0.009  'description  "For Tap" )
   )

    spacings(
     ( minViaSpacing      "V0"    'horizontal  'overLayer "Active" 0.044 'description  "For Tap minSpacing")
    ) ;spacings

  ) ;TAP_CG

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "minCutClassSpacingSingleVx"	nil    nil    'and

    spacingTables(
    ;( constraint 		layer1 		    [layer2]
    ;   (( index1Definitions    [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;( --------------------------------------------)
     ( minCutClassSpacing        "V1"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge))  nil 
	   "cutClass"   nil  nil  )	'sameMask	'paraOverlap  -1	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.080	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.080
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.080      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.080
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.080
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.080     
	)  'ref  "VIA1X.SP.2"
     )
     ( minCutClassSpacing        "V1"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'sameMask 'paraOverlap  0.001	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.080	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.080
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.080      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.080
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.080
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.080     
	       
	)  'ref  "VIA1X.SP.2"
     )
     ( minCutClassSpacing        "V1"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'paraOverlap  -1	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.042	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.042
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.042      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.042
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.042
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.042     
	       
	)  'ref  "VIA1X.SP.1"
     )
     ( minCutClassSpacing        "V1"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'paraOverlap  0.001	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.042	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.042
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.042      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.042
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.042
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.042     
	       
	)  'ref  "VIA1X.SP.1"
     )
    ( minCutClassSpacing        "V2"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'sameMask 'paraOverlap  -1	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.080	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.080
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.080      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.080
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.080
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.080     
	       
	)  'ref  "VIA1X.SP.2"
     )
     ( minCutClassSpacing        "V2"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'sameMask 'paraOverlap  0.001	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.080	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.080
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.080      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.080
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.080
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.080     
	       
	)  'ref  "VIA1X.SP.2"
     )
    ( minCutClassSpacing        "V2"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'paraOverlap  -1	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.042	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.042
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.042      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.042
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.042
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.042     
	       
	)  'ref  "VIA1X.SP.1"
     )
     ( minCutClassSpacing        "V2"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'paraOverlap  0.001	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.042	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.042
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.042      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.042
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.042
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.042     
	       
	)  'ref  "VIA1X.SP.1"
     )
     ( minCutClassSpacing        "V3"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'sameMask 'paraOverlap  -1	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.080	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.080
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.080      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.080
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.080
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.080     
	       
	)  'ref  "VIA1X.SP.2"
     )
     ( minCutClassSpacing        "V3"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'sameMask 'paraOverlap  0.001	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.080	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.080
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.080      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.080
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.080
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.080      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.080      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.080      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.080      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.080     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.080     
	       
	)  'ref  "VIA1X.SP.2"
     )
     ( minCutClassSpacing        "V3"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'paraOverlap  -1	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.042	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.042
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.042      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.042
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.042
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.042     
	       
	)  'ref  "VIA1X.SP.1"
     )
     ( minCutClassSpacing        "V3"	
	(( "cutClass"   ("Default" ("Rect" 'shortEdge) ("Rect" 'longEdge) )  nil 
	   "cutClass"   nil  nil  )	'paraOverlap  0.001	 )
	(
	   (("Default" 'shortEdge)         ("Default" 'shortEdge)        )      0.042	
	   (("Default" 'shortEdge)         ("Default" 'longEdge)         )	0.042
	   (("Default" 'shortEdge)         ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'shortEdge)         ("Rect" 'longEdge)      	 )	0.042      
	   (("Default" 'longEdge)          ("Default" 'shortEdge)        )	0.042
	   (("Default" 'longEdge)          ("Default" 'longEdge)         )	0.042
	   (("Default" 'longEdge)          ("Rect" 'shortEdge)     	 )	0.042      
	   (("Default" 'longEdge)          ("Rect" 'longEdge)      	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'shortEdge)      	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'shortEdge)     	 )	0.042      
	   (("Rect" 'shortEdge)      	   ("Rect" 'longEdge)      	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Default" 'shortEdge)        )	0.042      
	   (("Rect" 'longEdge)       	   ("Default" 'longEdge)         )	0.042      
	   (("Rect" 'longEdge)       	   ("Rect" 'shortEdge)     	 )	0.042     
	   (("Rect" 'longEdge)       	   ("Rect" 'longEdge)      	 )	0.042     
	       
	)  'ref  "VIA1X.SP.1"
     )
  ) ;spacingTables
 ) ;minCutClassSpacingSingleVx

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "virtuosoDefaultSetup"	nil

    interconnect(
     ( validLayers   (MT  M7  M6  M5  M4  M3  M2  M1  LiAct  LiPo  Poly  ) )
     ( validVias     (subTap  nwellTap  diffConn  polyConn  M2_M1  M3_M2  M4_M3  M5_M4  M6_M5  M7_M6  MT_M7  ) )
    ) ;interconnect
  ) ;virtuosoDefaultSetup

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "virtuosoDefaultExtractorSetup"	nil

    interconnect(
     ( validLayers   (MT  MTNotRes  CMT  MTNotRes  VT  M7  M7NotRes  V6  M6NotRes  M6  V5  M5  M5NotRes  V4  M4  M4NotRes  V3  M3  M3NotRes  M3NotCut  M3NotCutMask1  M3NotCutMask2  V2  M2  M2NotRes  M2NotCut  M2NotCutMask1  M2NotCutMask2  V1  M1  M1NotRes  M1NotCut  M1NotCutMask1  M1NotCutMask2  V0  LiAct  LiPo  Poly  Gate  PolyNotCut  PolyNotRes  Active  ActiveNotCut  ActiveNotGate  ActiveNotRes1  ActiveNotRes2  Psvt  Nsvt  NWell  NWNotRes1  NWNotRes2  cutSubstrate  substrate  ) )
    ) ;interconnect
  ) ;virtuosoDefaultExtractorSetup

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "wireEditorDefaultSetup"	nil

    interconnect(
     ( validLayers   (MT  M7  M6  M5  M4  M3  M2  M1  LiAct  LiPo  Poly  ) )
     ( validVias     (subTap  nwellTap  diffConn  polyConn  M2_M1  M3_M2  M4_M3  M5_M4  M6_M5  M7_M6  MT_M7  ) )
    ) ;interconnect
  ) ;wireEditorDefaultSetup

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "createViaDefaultSetup"	nil

    interconnect(
     ( validVias     (subTap  nwellTap  diffConn  polyConn  M2_M1  M3_M2  M4_M3  M5_M4  M6_M5  M7_M6  MT_M7  ) )
    ) ;interconnect
  ) ;createViaDefaultSetup

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "abstractDefaultSetup"	nil    "LEFDefaultRouteSpec"

    interconnect(
     ( validLayers   (MT M7 M6 M6 M4 M3 M2 M1) )
     ( validVias     (MT_M7 M7_M6 M6_M5 M5_M4 M4_M3 M3_M2 M2_M1) )
    ) ;interconnect

    routingGrids(
     ( horizontalPitch            "M1"	0.064 )
     ( verticalPitch              "M1"	0.064 )
     ( horizontalOffset           "M1"	0.0 )
     ( verticalOffset             "M1"	0.0 )
     ( horizontalPitch            "M2"	0.064 )
     ( verticalPitch              "M2"	0.064 )
     ( horizontalOffset           "M2"	0.032 )
     ( verticalOffset             "M2"	0.032 )
     ( horizontalPitch            "M3"	0.064 )
     ( verticalPitch              "M3"	0.064 )
     ( horizontalOffset           "M3"	0.032 )
     ( verticalOffset             "M3"	0.032 )
     ( horizontalPitch            "M4"	0.080 )
     ( verticalPitch              "M4"	0.080 )
     ( horizontalOffset           "M4"	0.040 )
     ( verticalOffset             "M4"	0.040 )
     ( horizontalPitch            "M5"	0.126 )
     ( verticalPitch              "M5"	0.126 )
     ( horizontalOffset           "M5"	0.063 )
     ( verticalOffset             "M5"	0.063 )
     ( horizontalPitch            "M6"	0.126 )
     ( verticalPitch              "M6"	0.126 )
     ( horizontalOffset           "M6"	0.063 )
     ( verticalOffset             "M6"	0.063 )
     ( horizontalPitch            "M7"	0.160 )
     ( verticalPitch              "M7"	0.160 )
     ( horizontalOffset           "M7"	0.080 )
     ( verticalOffset             "M7"	0.080 )
     ( horizontalPitch            "MT"	0.260 )
     ( verticalPitch              "MT"	0.260 )
     ( horizontalOffset           "MT"	0.130 )
     ( verticalOffset             "MT"	0.130 )
    ) ;routingGrids
  ) ;abstractDefaultSetup

 ;( group	[override]	[definition]	[operator] )
 ;( -----	----------	------------	---------- )
  ( "foundry"	nil

    interconnect(
     ( errorLayer    badActive  'ref  "OXIDE.C.1"  'description  "Active must be covered by either N+ or P+" )
     ( errorLayer    badImplant  'ref  "IMP.X.1"  'description  "N implant can not overalp P implant" )
     ( errorLayer    badV0LI  'ref  "V0.C.1"  'description  "V0 must interact with either LiPo or LiAct" )
     ( errorLayer    badV0M1  'ref  "V0.C.2"  'description  "V0 must be contained in M1" )
     ( errorLayer    badV1M1  'ref  "V1.C.1"  'description  "V1 must be contained in M1" )
     ( errorLayer    badV1M2  'ref  "V1.C.2"  'description  "V1 must be contained in M2" )
     ( errorLayer    badV2M2  'ref  "V2.C.1"  'description  "V2 must be contained in M2" )
     ( errorLayer    badV2M3  'ref  "V2.C.2"  'description  "V2 must be contained in M3" )
     ( errorLayer    badV3M3  'ref  "V3.C.1"  'description  "V3 must be contained in M3" )
     ( errorLayer    badV3M4  'ref  "V3.C.2"  'description  "V3 must be contained in M4" )
     ( errorLayer    badV4M4  'ref  "V4.C.1"  'description  "V4 must be contained in M4" )
     ( errorLayer    badV4M5  'ref  "V4.C.2"  'description  "V4 must be contained in M5" )
     ( errorLayer    badV5M5  'ref  "V5.C.1"  'description  "V5 must be contained in M5" )
     ( errorLayer    badV5M6  'ref  "V5.C.2"  'description  "V5 must be contained in M6" )
     ( errorLayer    badV6M6  'ref  "V6.C.1"  'description  "V6 must be contained in M6" )
     ( errorLayer    badV6M7  'ref  "V6.C.2"  'description  "V6 must be contained in M7" )
     ( errorLayer    badVTM7  'ref  "VT.C.1"  'description  "VT must be contained in M7" )
     ( errorLayer    badVTMT  'ref  "VT.C.2"  'description  "VT must be contained in MT" )
    ) ;interconnect

    spacings(
     ( snapGridVertical           "GFG" )
     ( allowedPRBoundaryDimensions 'stepSize  0.048	'vertical	(">= 0.048")  'ref  "CDS.prBndry.h"  'description  "Vertically facing edges of PRBoundary spacing must be a multiple of 48n." )
     ( minPRBoundaryInteriorHalo  "Active"	'vertical	'stepSize  0.048	0.065  'ref  "CDS.prBndry.EN"  'description  "PRBoundary must enlose active by at least 65n and with steps of 48n." )
    ) ;spacings
	memberConstraintGroups(
 	; listed in order of precedence
 	; -----------------------------
       "CBWidth" "TAP_CG" "V0_CG" "M1X_CG" "V1X_CG" "minCutClassSpacingSingleVx"
	); memberConstraintGroups

    spacings(
     ( allowedWidthRanges         "Fin"	'measureVertical	(0.014)  'ref  "CDS.fin.W"  'description  "Fin width must be" )
     ( allowedWidthRanges         "Fin"	'measureHorizontal	(">=0.048")  'ref  "CDS.fin.L"  'description  "Minimum Fin length" )
    ) ;spacings

    spacingTables(
    ;( constraint 		layer1 		    [layer2]
    ;   (( index1Definitions    [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;( --------------------------------------------)
     ( allowedSpacingRanges      "Fin"	
	(( "width" nil nil )	 )
         (
            0.014     (0.034)   
         )  'ref  "CDS.fin.S.1"  'description  "Fin spacing must be"
     )
     ( rectShapeDir              "Fin"	
	(( "width" nil nil )	 )
         (
            0.014     "horizontal"
         )  'ref  "CDS.Fin.Dir.1"  'description  "Fin must be horizontal"
     )
     ( allowedLengthRanges       "Fin"	
	(( "width" nil nil )	 )
         (
            0.014     (">= 0.048")
         )  'ref  "CDS.fin.l.1"  'description  "Fin length must be at least"
     )
    ) ;spacingTables

    spacings(
     ( minWidth                   "BuriedNWell"	0.8  'ref  "NBL.W.1"  'description  "Buried Nwell minimum width" )
     ( minSpacing                 "BuriedNWell"	2.0  'ref  "NBL.SP.1"  'description  "Buried Nwell minimum spacing" )
     ( minSpacing                 "BuriedNWell"	"NWell"		2.2  'ref  "NBL.SE.1"  'description  "Buried Nwell to Nwell minimum spacing" )
     ( minSpacing                 "BuriedNWell"	"Active"		1.2  'ref  "NBL.SE.2"  'description  "Buried Nwell to Active minimum spacing" )
     ( minWidth                   "NWell"	0.146  'ref  "NW.W.1"  'description  "NWell minimum width" )
     ( minSpacing                 "NWell"	0.162  'ref  "NW.SP.1"  'description  "NWell minimum spacing" )
     ( minArea                    "NWell"	0.03  'ref  "NW.A.1"  'description  "NWell minimum area" )
     ( minHoleArea                "NWell"	0.18  'ref  "NW.EA.1"  'description  "NWell minimum area" )
     ( minSpacing                 "NWell"	"Active"		0.16  'ref  "NW.SE.1"  'description  "Nwell to Active minimum spacing" )
     ( minSpacing                 "NWell"	"ThickOx"		0.24  'ref  "NW.SE.2"  'description  "Nwell to Thick Active minimum spacing" )
     ( minSpacing                 "NWell"	"NwellStiRes"		0.3  'ref  "NWR.S.1"  'description  "Nwell to Nwell (in resistor) minimum spacing" )
     ( minSpacing                 "NWell"	"NwellOdRes"		0.3  'ref  "NWR.S.1"  'description  "Nwell to Nwell (in resistor) minimum spacing" )
     ( allowedWidthRanges         "Active"	'measureVertical	'stepSize  0.048	(">= 0.062")  'ref  "OXIDE.W.1"  'description  "Active allowed width in Y direction" )
     ( allowedWidthRanges         "Active"	'measureHorizontal	(">= 0.068")  'ref  "OXIDE.W.2"  'description  "Active allowed width in X direction" )
     ( allowedSpacingRanges       "Active"	'vertical	'stepSize  0.048	(">= 0.13")  'ref  "OXIDE.SP.1"  'description  "Active allowed space in Y direction" )
     ( minSpacing                 "Active"	'horizontal	0.018  'ref  "OXIDE.SP.2"  'description  "Active allowed space in X direction" )
     ( allowedWidthRanges         "FB48"	'measureVertical	'stepSize  0.048	(">= 0.062")  'ref  "FB48.W.1"  'description  "Fin allowed width in Y direction" )
     ( allowedWidthRanges         "FB48"	'measureHorizontal	(">= 0.096")  'ref  "FB48.W.2"  'description  "Fin allowed width in X direction" )
     ( allowedSpacingRanges       "FB48"	'vertical	'stepSize  0.048	(">= 0.034")  'ref  "FB48.SP.1"  'description  "Fin Boundary (48nm pitch) spacing (0.034 + nx0.048)" )
     ( minWidth                   "ThickOx"	'vertical	0.124  'ref  "OXIDETHK.W.1"  'description  "Thick Active minimum width in Y direction" )
     ( minWidth                   "ThickOx"	'horizontal	0.158  'ref  "OXIDETHK.W.2"  'description  "Thick Active minimum width in X direction" )
     ( minSpacing                 "ThickOx"	'vertical	0.068  'ref  "OXIDETHK.SP.1"  'description  "Thick Active minimum space in Y direction" )
     ( minSpacing                 "ThickOx"	'horizontal	0.064  'ref  "OXIDETHK.SP.2"  'description  "Thick Active minimum space in X direction" )
     ( minSpacing                 "ThickOx"	"Active"		'vertical	0.099  'ref  "OXIDETHK.SE.1"  'description  "Thick Active to Active minimum space in Y direction" )
     ( minSpacing                 "ThickOx"	"Active"		'horizontal	0.109  'ref  "OXIDETHK.SE.2"  'description  "Thick Active to Active minimum space in X direction" )
     ( minWidth                   "SaB"	0.042  'ref  "SIPROT.W.1"  'description  "Salicide Block minimum width" )
     ( minSpacing                 "SaB"	0.044  'ref  "SIPROT.SP.1"  'description  "Salicide Block minimum space" )
     ( minSpacing                 "SaB"	"V0"		0.009  'ref  "SIPROT.SE.1"  'description  "Salicide Block to Contact minimum space" )
     ( minSpacing                 "SaB"	"Active"		0.012  'ref  "SIPROT.SE.2"  'description  "Salicide Block to Active minimum space" )
     ( minSpacing                 "SaB"	"Poly"		0.022  'ref  "SIPROT.SE.3"  'description  "Salicide Block to Poly minimum space" )
     ( minArea                    "SaB"	0.0042  'ref  "SIPROT.A.1"  'description  "Salicide Block minimum area" )
     ( minWidth                   "Nsvt"	'exceptPointTouch	0.052  'ref  "NIMP.W.1"  'description  "Nsvt minimum width must be at least" )
     ( minSpacing                 "Nsvt"	0.024  'ref  "NIMP.SP.1"  'description  "Nsvt minimum spacing must be at least" )
     ( minArea                    "Nsvt"	0.017  'ref  "NIMP.A.1"  'description  "Nsvt minimum area must be at least" )
     ( minSpacing                 "Nsvt"	"PActive"		0.045  'ref  "NIMP.SE.1"  'description  "Nsvt to P+ Active spacing must be at least" )
     ( minWidth                   "Nhvt"	'exceptPointTouch	0.052  'ref  "NHVT.W.1"  'description  "NHVT minimum width must be at least" )
     ( minSpacing                 "Nhvt"	0.052  'ref  "NHVT.SP.1"  'description  "NHVT minimum spacing must be at least" )
     ( minArea                    "Nhvt"	0.03  'ref  "NHVT.A.1"  'description  "NHVT minimum area must be at least" )
     ( minSpacing                 "Nhvt"	"PActive"		0.045  'ref  "NHVT.SE.1"  'description  "NHVT to P+ Active spacing must be at least" )
     ( minWidth                   "Nlvt"	'exceptPointTouch	0.052  'ref  "NLVT.W.1"  'description  "NLVT minimum width must be at least" )
     ( minSpacing                 "Nlvt"	0.052  'ref  "NLVT.SP.1"  'description  "NLVT minimum spacing must be at least" )
     ( minArea                    "Nlvt"	0.03  'ref  "NLVT.A.1"  'description  "NLVT minimum area must be at least" )
     ( minSpacing                 "Nlvt"	"PActive"		0.045  'ref  "NLVT.SE.1"  'description  "NLVT to P+ Active spacing must be at least" )
     ( minWidth                   "Psvt"	'exceptPointTouch	0.052  'ref  "PIMP.W.1"  'description  "Psvt minimum width must be at least" )
     ( minSpacing                 "Psvt"	0.052  'ref  "PIMP.SP.1"  'description  "Psvt minimum spacing must be at least" )
     ( minArea                    "Psvt"	0.017  'ref  "PIMP.A.1"  'description  "Psvt minimum area must be at least" )
     ( minSpacing                 "Psvt"	"NActive"		0.045  'ref  "PIMP.SE.1"  'description  "Psvt to N+ Active spacing must be at least" )
     ( minWidth                   "Phvt"	'exceptPointTouch	0.052  'ref  "PHVT.W.1"  'description  "PHVT minimum width must be at least" )
     ( minSpacing                 "Phvt"	0.052  'ref  "PHVT.SP.1"  'description  "PHVT minimum spacing must be at least" )
     ( minArea                    "Phvt"	0.03  'ref  "PHVT.A.1"  'description  "PHVT minimum area must be at least" )
     ( minSpacing                 "Phvt"	"NActive"		0.045  'ref  "PHVT.SE.1"  'description  "PHVT to N+ Active spacing must be at least" )
     ( minWidth                   "Plvt"	'exceptPointTouch	0.052  'ref  "PLVT.W.1"  'description  "PLVT minimum width must be at least" )
     ( minSpacing                 "Plvt"	0.052  'ref  "PLVT.SP.1"  'description  "PLVT minimum spacing must be at least" )
     ( minArea                    "Plvt"	0.03  'ref  "PLVT.A.1"  'description  "PLVT minimum area must be at least" )
     ( minSpacing                 "Plvt"	"NActive"		0.045  'ref  "PLVT.SE.1"  'description  "PLVT to N+ Active spacing must be at least" )
     ( allowedWidthRanges         "Poly"	'measureVertical	(">= 0.08")  'ref  "POLY.W.1"  'description  "Poly allowed width in Y direction" )
     ( allowedWidthRanges         "Poly"	'measureHorizontal	(0.018 0.02 0.024 0.028 ">= 0.03")  'ref  "POLY.W.2"  'description  "Poly allowed width in X direction" )
     ( maxWidth                   "Poly"	0.24  'ref  "POLY.W.3"  'description  "Poly width can not exceed" )
     ( maxLength                  "Poly"	10.0  'ref  "POLY.W.4"  'description  "Poly length can not exceed" )
     ( allowedWidthRanges         "LiPo"	'measureHorizontal	(0.03 0.04 0.05)  'ref  "LIPO.W.1"  'description  "LiPo width in the X direction" )
     ( allowedWidthRanges         "LiPo"	'measureVertical	(">=0.040")  'ref  "LIPO.W.1"  'description  "Minimum LiPo Length in the Y direction" )
     ( maxLength                  "LiPo"	5.0  'ref  "LIPO.W.2"  'description  "LiPo max length" )
     ( minSpacing                 "LiPo"	0.034  'ref  "LIPO.SP.1"  'description  "LiPo minimum spacing must be at least" )
     ( minSpacing                 "LiPo"	"Poly"		0.03  'ref  "LIPO.SE.1"  'description  "LiPo spacing to Poly must be at least" )
     ( minSpacing                 "LiPo"	"LiAct"		0.013  'ref  "LIPO.SE.2"  'description  "LiPo spacing to LiAct must be at least" )
     ( minSpacing                 "LiPo"	"Active"		0.045  'ref  "LIPO.SE.3"  'description  "LiPo spacing to Active must be at least" )
     ( allowedWidthRanges         "LiAct"	'measureHorizontal	(0.03 0.04 0.05)  'ref  "LIACT.W.1"  'description  "LiAct width in the X direction" )
     ( allowedWidthRanges         "LiAct"	'measureVertical	(">= 0.068")  'ref  "LIACT.W.1"  'description  "LiAct length in the Y direction" )
     ( maxLength                  "LiAct"	5.0  'ref  "LIACT.W.5"  'description  "LiAct max length" )
     ( minSpacing                 "LiAct"	0.046  'ref  "LIACT.SP.1"  'description  "LiAct spacing must be at least" )
     ( minSpacing                 "LiAct"	"Active"		0.04  'ref  "LIACT.SE.7"  'description  "LiAct spacing to Active must be at least" )
     ( minWidth                   "V0"	0.032  'ref  "VO.W.1"  'description  "V0 minimum width" )
     ( maxWidth                   "V0"	0.032  'ref  "VO.W.1"  'description  "V0 maximum width" )
     ( minSpacing                 "V0"	"LiAct"		'crossingAllowed	0.012  'ref  "V0.SE.1"  'description  "V0 minimum spacing to LiAct must be at least" )
     ( minSpacing                 "V0"	"LiPo"		'crossingAllowed	0.030  'ref  "V0.SE.2"  'description  "V0 minimum spacing to LiPo must be at least" )
     ( minSpacing                 "V0"	"Poly"		'crossingAllowed	0.018  'ref  "V0.SE.3"  'description  "V0 minimum spacing to Poly must be at least" )
     ( allowedWidthRanges         "M1"	(0.032 0.048 ">=0.062")  'ref  "M1.W.1"  'description  "M1 width" )
     ( minWidth                   "M1"	0.032  'ref  "M1.W.1"  'description  "M1 min width" )
     ( maxWidth                   "M1"	2.0  'ref  "M1.W.2"  'description  "M1 max width" )
     ( minArea                    "M1"	0.006176  'ref  "M1.A.1"  'description  "M1 minimum area" )
     ( minProtrusionSpacing       "M1"	'width  0.08	'length  0.3	'excludeSpacing  "[0.068 0.085]"	'protrusionLength  0.068	'within  0.1	
	(
	   short         0.032     
	   long          0.048     
	   between       0.032     
	)
      'ref  "CDS M1.S.2"  'description  "M1 minimum spacing to protrusion" )
     ( forbiddenEdgePitchRange    "M1"	'width  0.04	'prl  0.12	"[0.15 0.16]"  'ref  "CDS M1.S.3.1"  'description  "Forbidden edge pitch range for M1" )
     ( forbiddenProximitySpacing  "M1"	'width  0.16	'prl  0.14	'withinRange  "[0.11 0.75]"	"[0.06 0.068]"  'ref  "CDS M1.S.3.2"  'description  "Forbidden spacing for M1" )
     ( minHoleWidth               "M1"	0.032  'ref  "CDS.M1.H.1"  'description  "M1 hole width must be at least" )
     ( allowedWidthRanges         "V1"	'measureHorizontal	(0.032 0.064)  'ref  "V1.W.1"  'description  "V1 width in the X direction" )
     ( allowedWidthRanges         "V1"	'measureVertical	(0.032 0.064)  'ref  "V1.W.1"  'description  "V1 width in the Y direction" )
     ( allowedWidthRanges         "M2"	(0.032 0.048 ">=0.062")  'ref  "M2.W.1"  'description  "M2 width" )
     ( minWidth                   "M2"	0.032  'ref  "M2.W.1"  'description  "M2 min width" )
     ( maxWidth                   "M2"	2.0  'ref  "M2.W.2"  'description  "M2 max width" )
     ( minArea                    "M2"	0.006176  'ref  "M2.A.1"  'description  "M2 minimum area" )
     ( minProtrusionSpacing       "M2"	'width  0.08	'length  0.3	'excludeSpacing  "[0.068 0.085]"	'protrusionLength  0.068	'within  0.1	
	(
	   short         0.032     
	   long          0.048     
	   between       0.032     
	)
      'ref  "CDS M2.S.2"  'description  "M2 minimum spacing to protrusion" )
     ( forbiddenEdgePitchRange    "M2"	'width  0.04	'prl  0.12	"[0.15 0.16]"  'ref  "CDS M2.S.3.1"  'description  "Forbidden edge pitch range for M2" )
     ( forbiddenProximitySpacing  "M2"	'width  0.16	'prl  0.14	'withinRange  "[0.11 0.75]"	"[0.06 0.068]"  'ref  "CDS M2.S.3.2"  'description  "Forbidden spacing for M2" )
     ( minHoleWidth               "M2"	0.032  'ref  "CDS.M2.H.1"  'description  "M2 hole width must be at least" )
     ( allowedWidthRanges         "V2"	'measureHorizontal	(0.032 0.064)  'ref  "V2.W.1"  'description  "V2 width in the X direction" )
     ( allowedWidthRanges         "V2"	'measureVertical	(0.032 0.064)  'ref  "V2.W.1"  'description  "V2 width in the Y direction" )
     ( allowedWidthRanges         "M3"	(0.032 0.048 ">=0.062")  'ref  "M3.W.1"  'description  "M3 width" )
     ( allowedWidthRanges         "M3"	'measureVertical	(0.032 0.064 ">=0.096")  'ref  "M3.W.1"  'description  "M3 width in the Y direction" )
     ( minWidth                   "M3"	0.032  'ref  "M3.W.1"  'description  "M3 min width" )
     ( maxWidth                   "M3"	2.0  'ref  "M3.W.2"  'description  "M3 max width" )
     ( minArea                    "M3"	0.006176  'ref  "M3.A.1"  'description  "M3 minimum area" )
     ( minProtrusionSpacing       "M3"	'width  0.08	'length  0.3	'excludeSpacing  "[0.068 0.085]"	'protrusionLength  0.068	'within  0.1	
	(
	   short         0.032     
	   long          0.048     
	   between       0.032     
	)
      'ref  "CDS M3.S.2"  'description  "M3 minimum spacing to protrusion" )
     ( forbiddenEdgePitchRange    "M3"	'width  0.04	'prl  0.12	"[0.15 0.16]"  'ref  "CDS M3.S.3.1"  'description  "Forbidden edge pitch range for M3" )
     ( forbiddenProximitySpacing  "M3"	'width  0.16	'prl  0.14	'withinRange  "[0.11 0.75]"	"[0.06 0.068]"  'ref  "CDS M3.S.3.2"  'description  "Forbidden spacing for M3" )
     ( minHoleWidth               "M3"	0.032  'ref  "CDS.M3.H.1"  'description  "M3 hole width must be at least" )
     ( allowedWidthRanges         "V3"	'measureHorizontal	(0.032 0.064)  'ref  "V3.W.1"  'description  "V3 width in the X direction" )
     ( allowedWidthRanges         "V3"	'measureVertical	(0.032 0.064)  'ref  "V3.W.1"  'description  "V3 width in the Y direction" )
     ( minWidth                   "M4"	0.032  'ref  "M4.W.1"  'description  "M4 minimum width must be at least" )
     ( maxWidth                   "M4"	2.0  'ref  "M4.W.2"  'description  "M4 max width" )
     ( minArea                    "M4"	0.006176  'ref  "M4.A.1"  'description  "M4 minimum area" )
     ( minProtrusionSpacing       "M4"	'width  0.08	'length  0.3	'excludeSpacing  "[0.068 0.085]"	'protrusionLength  0.068	'within  0.1	
	(
	   short         0.032     
	   long          0.048     
	   between       0.032     
	)
      'ref  "CDS M4.S.2"  'description  "M4 minimum spacing to protrusion" )
     ( forbiddenEdgePitchRange    "M4"	'width  0.04	'prl  0.12	"[0.15 0.16]"  'ref  "CDS M4.S.3.1"  'description  "Forbidden edge pitch range for M4" )
     ( forbiddenProximitySpacing  "M4"	'width  0.16	'prl  0.14	'withinRange  "[0.11 0.75]"	"[0.06 0.068]"  'ref  "CDS M4.S.3.2"  'description  "Forbidden spacing for M4" )
     ( minHoleWidth               "M4"	0.032  'ref  "CDS.M4.H.1"  'description  "M4 hole width must be at least" )
     ( minWidth                   "V4"	0.042  'ref  "V4.W.1"  'description  "V4 minimum width must be at least" )
     ( maxWidth                   "V4"	0.042  'ref  "V4.W.1"  'description  "V4 maximum width must be at least" )
     ( minSpacing                 "V4"	0.062  'ref  "V4.SP.1"  'description  "V4 minimum space must be at least" )
     ( viaSpacing                 "V4"	(3 0.078 0.078)  'ref  "V4.SP.2"  'description  "V4 with more than 3 adj. cut spacing must be at least" )
     ( minWidth                   "M5"	0.058  'ref  "M5.W.1"  'description  "M5 minimum width must be at least" )
     ( maxWidth                   "M5"	3.0  'ref  "M5.W.2"  'description  "M5 max width" )
     ( minArea                    "M5"	0.0082  'ref  "M5.A.1"  'description  "M5 minimum area" )
     ( minEndOfLineSpacing        "M5"	'width  0.0585	'distance  0.058	'endToEndSpace  0.074	'otherEndWidth  0.0585	0.074  'ref  "M5.SP.2.1"  'description  "M5 [w>0.058] EOL Spacing violation" )
     ( minWidth                   "V5"	0.042  'ref  "V5.W.1"  'description  "V5 minimum width must be at least" )
     ( maxWidth                   "V5"	0.042  'ref  "V5.W.1"  'description  "V5 maximum width must be at least" )
     ( minSpacing                 "V5"	0.062  'ref  "V5.SP.1"  'description  "V5 minimum space must be at least" )
     ( viaSpacing                 "V5"	(3 0.078 0.078)  'ref  "V5.SP.2"  'description  "V5 with more than 3 adj. cut spacing must be at least" )
     ( minWidth                   "M6"	0.058  'ref  "M6.W.1"  'description  "M6 minimum width must be at least" )
     ( maxWidth                   "M6"	3.0  'ref  "M6.W.2"  'description  "M6 max width" )
     ( minArea                    "M6"	0.0082  'ref  "M6.A.1"  'description  "M6 minimum area" )
     ( minEndOfLineSpacing        "M6"	'width  0.0585	'distance  0.058	'endToEndSpace  0.074	'otherEndWidth  0.0585	0.074  'ref  "M6.SP.2.1"  'description  "M6 [w>0.058] EOL Spacing violation" )
     ( minWidth                   "V6"	0.064  'ref  "V6.W.1"  'description  "V6 minimum width must be at least" )
     ( maxWidth                   "V6"	0.064  'ref  "V6.W.1"  'description  "V6 maximum width must be at least" )
     ( minSpacing                 "V6"	0.084  'ref  "V6.SP.1"  'description  "V6 minimum space must be at least" )
     ( viaSpacing                 "V6"	(3 0.1 0.1)  'ref  "V6.SP.2"  'description  "V6 with more than 3 adj. cut spacing must be at least" )
     ( minWidth                   "M7"	0.069  'ref  "M7.W.1"  'description  "M7 minimum width must be at least" )
     ( maxWidth                   "M7"	4.0  'ref  "M7.W.2"  'description  "M7 max width" )
     ( minArea                    "M7"	0.01  'ref  "M7.A.1"  'description  "M7 minimum area" )
     ( minEndOfLineSpacing        "M7"	'width  0.0695	'distance  0.09	'endToEndSpace  0.096	'otherEndWidth  0.0695	0.096  'ref  "M7.SP.2.1"  'description  "M7 [w>0.058] EOL Spacing violation" )
     ( minWidth                   "CMT"	0.26  'ref  "CMT.W.1"  'description  "CMT minimum width must be at least" )
     ( maxWidth                   "CMT"	3.6  'ref  "CMT.W.2"  'description  "CMT max width" )
     ( minSpacing                 "CMT"	1.0  'ref  "V6.SP.1"  'description  "V6 minimum space must be at least" )
     ( minWidth                   "VT"	0.1  'ref  "VT.W.1"  'description  "VT minimum width must be at least" )
     ( maxWidth                   "VT"	0.1  'ref  "VT.W.1"  'description  "VT maximum width must be at least" )
     ( minSpacing                 "VT"	0.12  'ref  "VT.SP.1"  'description  "VT minimum space must be at least" )
     ( viaSpacing                 "VT"	(3 0.16 0.16)  'ref  "VT.SP.2"  'description  "VT with more than 3 adj. cut spacing must be at least" )
     ( minWidth                   "MT"	0.22  'ref  "MT.W.1"  'description  "MT minimum width must be at least" )
     ( maxWidth                   "MT"	6.0  'ref  "MT.W.2"  'description  "MT max width" )
     ( minArea                    "MT"	0.0484  'ref  "MT.A.1"  'description  "MT minimum area" )
    ) ;spacings

    orderedSpacings(
     ( minOppExtension            "NWell"	"Active"		(0.021 0.021)  'ref  "NW E.1"  'description  "Nwell minimum enclosure of Active" )
     ( minOppExtension            "NWell"	"ThickOx"		(0.034 0.034)  'ref  "NW E.2"  'description  "Nwell minimum enclosure of Thick Active" )
     ( minExtensionDistance       "NWell"	"BuriedNWell"		0.24  'ref  "NW.E.3"  'description  "Nwell minimum enclosure of Buried Nwell" )
     ( minOverlapDistance         "BuriedNWell"	"NWell"		0.24  'ref  "NW.E.4"  'description  "Buried Nwell minimum overlap into Nwell" )
     ( minExtensionDistance       "Active"	"NwellStiRes"		0.021  'ref  "NWR.E.1"  'description  "Active minimum enclosure of Nwell(in resistor)" )
     ( minExtensionDistance       "Active"	"NwellOdRes"		0.021  'ref  "NWR.E.1"  'description  "Active minimum enclosure of Nwell(in resistor)" )
     ( minOppExtension            "FB48"	"Active"		'stepSizePair  (0.048 0.0)	'vertical	(0.048 0.017)  'ref  "FB48.E.1"  'description  "Need exact vertical fin enclosure (at least 1)." )
     ( minOppExtension            "CB"	"FB48"		'vertical	'stepSizePair  (0.048 0.0)	(0.017 0.02)  'ref  "CDS.FB48.EXT.2"  'description  "Vertical CellBoundary enclosure of FB48 needs to be an exact multiple of 48n." )
     ( minOppExtension            "ThickOx"	"Active"		'vertical	(0.031 0.045)  'ref  "OXIDETHK E.1"  'description  "Thick Active minimum enclosure of Active" )
     ( minExtensionDistance       "SaB"	"Active"		0.012  'ref  "SIPROT E.1"  'description  "Salicide Block minimum extension of Active" )
     ( minExtensionDistance       "Active"	"SaB"		0.012  'ref  "SIPROT E.2"  'description  "Active minimum extension of Salicide Block" )
     ( minExtensionDistance       "SaB"	"Poly"		0.012  'ref  "SIPROT E.3"  'description  "Salicide Block minimum extension of Poly" )
     ( minOppExtension            "Nsvt"	"Poly"		(0.045 0.065)  'ref  "NIMP.EN.1"  'description  "Nsvt enclosure of Poly 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Nsvt"	"Active"		(0.045 0.065)  'ref  "NIMP.EN.2"  'description  "Nsvt enclosure of Active 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Nhvt"	"Poly"		(0.045 0.065)  'ref  "NHVT.EN.1"  'description  "NHVT enclosure of Poly 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Nhvt"	"Active"		(0.045 0.065)  'ref  "NHVT.EN.2"  'description  "NHVT enclosure of Active 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Nlvt"	"Poly"		(0.045 0.065)  'ref  "NLVT.EN.1"  'description  "NLVT enclosure of Poly 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Nlvt"	"Active"		(0.045 0.065)  'ref  "NLVT.EN.2"  'description  "NLVT enclosure of Active 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Psvt"	"Poly"		(0.045 0.065)  'ref  "PIMP.EN.1"  'description  "Psvt enclosure of Poly 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Psvt"	"Active"		(0.045 0.065)  'ref  "PIMP.EN.2"  'description  "Psvt enclosure of Active 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Phvt"	"Poly"		(0.045 0.065)  'ref  "PHVT.EN.1"  'description  "PHVT enclosure of Poly 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Phvt"	"Active"		(0.045 0.065)  'ref  "PHVT.EN.2"  'description  "PHVT enclosure of Active 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Plvt"	"Poly"		(0.045 0.065)  'ref  "PLVT.EN.1"  'description  "PLVT enclosure of Poly 0.045 (at least one corner 0.065)" )
     ( minOppExtension            "Plvt"	"Active"		(0.045 0.065)  'ref  "PLVT.EN.2"  'description  "PLVT enclosure of Active 0.045 (at least one corner 0.065)" )
     ( minExtensionDistance       "Poly"	"Active"		'vertical	0.048  'ref  "POLY.E.1"  'description  "Vertical Poly must extend past Active area by at least" )
     ( minOverlapDistance         "LiPo"	"Poly"		0.016  'ref  "LIPO.E.1"  'description  "LiPo must at least overalp Poly by" )
     ( minExtensionDistance       "Poly"	"LiPo"		0.01  'coincidentAllowed  'ref  "LIPO.E.2"  'description  "Poly must extend past LiPo area by at least" )
     ( minExtensionDistance       "Active"	"LiAct"		'horizontal	0.014  'ref  "LIACT.E.1."  'description  "Active extension past LIACT must be at least" )
     ( minOppExtension            "Active"	"V0"		(0.018 0.015)  'ref  "V0.E.X"  'description  "Active minimum enclosure of V0" )
     ( minOppExtension            "M4"	"V4"		(0.008 0.008)  'ref  "V4.E.1"  'description  "Metal4 minimum enclosure of V4" )
     ( minOppExtension            "M5"	"V4"		(0.008 0.008)  'ref  "M5.E.1"  'description  "Metal5 minimum enclosure of V4" )
     ( minOppExtension            "M5"	"V5"		(0.008 0.008)  'ref  "V5.E.1"  'description  "Metal5 minimum enclosure of V5" )
     ( minOppExtension            "M6"	"V5"		(0.008 0.008)  'ref  "M6.E.1"  'description  "Metal6 minimum enclosure of V5" )
     ( minOppExtension            "M6"	"V6"		(0.015 0.015)  'ref  "V6.E.1"  'description  "Metal6 minimum enclosure of V6" )
     ( minOppExtension            "M7"	"V6"		(0.015 0.015)  'ref  "M6.E.1"  'description  "Metal7 minimum enclosure of V6" )
     ( minOppExtension            "M7"	"VT"		(0.03 0.03)  'ref  "VT.E.1"  'description  "Metal7 minimum enclosure of VT" )
     ( minOppExtension            "M7"	"CMT"		(0.04 0.04)  'ref  "CMT.E.2"  'description  "Metal7 minimum enclosure of CMT" )
     ( minOppExtension            "CMT"	"VT"		(0.08 0.08)  'ref  "CMT.E.1"  'description  "CMT minimum enclosure of VT" )
     ( minOppExtension            "MT"	"VT"		(0.06 0.06)  'ref  "MT.E.1"  'description  "MT minimum enclosure of VT" )
    ) ;orderedSpacings

    spacingTables(
    ;( constraint 		layer1 		    [layer2]
    ;   (( index1Definitions    [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;( --------------------------------------------)
     ( minSpacing                "Poly"	
	(( "width" nil nil )	0.068 )
         (
            0.0       0.068     
            0.08      0.12      
            0.16      0.2       
         )  'ref  "POLY.SP.1, POLY.SP.2, POLY.SP.3"
     )
     ( allowedLengthRanges       "LiAct"	
	(( "width" nil nil )	 )
         (
            0.03      (">= 0.062")
            0.04      (">= 0.072")
            0.05      (">= 0.082")
         )  'ref  "LIACT.W.2,LIACT.W.3,LIACT.W.4"  'description  "Invalid length for LiAct[w]"
     )
     ( rectShapeDir              "LiAct"	
	(( "width" nil nil )	 )
         (
            0.03      "vertical"
            0.04      "vertical"
            0.05      "any"     
         )  'ref  "LIACT.Dir"  'description  "LiAct rectangular shape has restricted direction"
     )
     ( minSpacing                "LiAct"	"Poly"	
	(( "width"   nil  nil 	 "width"   nil   nil  )	 )
	(
	   (0.03      	0.018     )	0.019     
	   (0.03      	0.02      )	0.02      
	   (0.03      	0.024     )	0.02      
	   (0.03      	0.028     )	0.022     
	   (0.03      	0.03      )	0.022     
	   (0.03      	0.08      )	0.07      
	   (0.04      	0.018     )	0.04      
	   (0.04      	0.02      )	0.04      
	   (0.04      	0.024     )	0.04      
	   (0.04      	0.028     )	0.04      
	   (0.04      	0.03      )	0.04      
	   (0.04      	0.08      )	0.07      
	   (0.05      	0.018     )	0.045     
	   (0.05      	0.02      )	0.045     
	   (0.05      	0.024     )	0.045     
	   (0.05      	0.028     )	0.045     
	   (0.05      	0.04      )	0.045     
	   (0.05      	0.08      )	0.07      
	)  'ref  "LIACT.SE.1, LIACT.SE.2, LIACT.SE.3, LIACT.SE.4, LIACT.SE.5, LIACT.SE.6"  'description  "LiAct[w] spacing to Poly[w]"
     )
     ( minNumCut                 "V4"	
	(( "width" nil nil )	'distanceWithin  0.08	 )
         (
            0.032     1         
            0.042     1         
            0.1       2         
            0.3       4         
            1.0       8         
         )  'ref  "V4.MNC"  'description  "You need more V4 cut shapes, for this width, at least "
     )
     ( minNumCut                 "V5"	
	(( "width" nil nil )	'distanceWithin  0.08	 )
         (
            0.042     1         
            0.1       2         
            0.3       4         
            1.0       8         
         )  'ref  "V5.MNC"  'description  "You need more V5 cut shapes, for this width, at least "
     )
     ( minNumCut                 "V6"	
	(( "width" nil nil )	'distanceWithin  0.16	 )
         (
            0.058     1         
            0.064     1         
            0.15      2         
            0.6       4         
            1.3       8         
         )  'ref  "V6.MNC"  'description  "You need more V6 cut shapes, for this width, at least "
     )
     ( minNumCut                 "VT"	
	(( "width" nil nil )	'distanceWithin  0.2	 )
         (
            0.16      1         
            0.5       2         
            1.0       4         
            2.0       8         
         )  'ref  "VT.MNC"  'description  "You need more VT cut shapes, for this width, at least "
     )
     ( minSpacing                "M5"	
	(( "width" nil nil )	0.068 )
         (
            0.0       0.068     
            0.06      0.08      
            0.09      0.1       
         )  'ref  "M5.SP.1.1, M5.SP.1.2, M5.SP.1.3"
     )
     ( minSpacing                "M6"	
	(( "width" nil nil )	0.068 )
         (
            0.0       0.068     
            0.06      0.08      
            0.09      0.1       
         )  'ref  "M6.SP.1.1, M6.SP.1.2, M6.SP.1.3"
     )
     ( minSpacing                "M7"	
	(( "width" nil nil )	0.09 )
         (
            0.0       0.09      
            0.5       0.12      
            1.0       0.4       
         )  'ref  "M7.SP.1.1, M7.SP.1.2, M7.SP.1.3"
     )
     ( minSpacing                "MT"	
	(( "width" nil nil )	0.2 )
         (
            0.0       0.2       
            0.75      0.35      
            1.5       0.55      
            2.5       0.75      
            3.5       1.25      
         )  'ref  "MT.SP.1.1, MT.SP.1.2, MT.SP.1.3, MT.SP.1.4, MT.SP.1.5"
     )
    ) ;spacingTables

    spacings(
     ( minWidth                   "TrimFin"	0.048  'ref  "CDS.TrimFin.W.1"  'description  "Width for TrimFin shape must be at least" )
    ) ;spacings

    orderedSpacings(
     ( minOppExtension            "TrimFin"	"Fin"		(0.017 0.017)  'ref  "CDS.TrimFin.EX.1"  'description  "TrimFin Shape must extendend past fins by at least" )
    ) ;orderedSpacings

    spacings(
     ( minSpacing                 "TrimFin"	0.044  'ref  "CDS.TrimFin.S.1"  'description  "Spacing for TrimFin shape must be at least" )
     ( allowedWidthRanges         "CutActive"	'measureVertical	'stepSize  0.048	(">= 0.082")  'ref  "CUTACTIVE.W.1"  'description  "CutActive allowed width in Y direction" )
     ( allowedWidthRanges         "CutActive"	'measureHorizontal	(0.018 0.02 0.024 0.028 0.03)  'ref  "CUTACTIVE.W.2"  'description  "CutActive allowed width in X direction" )
     ( minSpacing                 "CutActive"	0.068  'ref  "CUTACTIVE.SP.1"  'description  "CutActive minimum spacing must be at least" )
     ( minSpacing                 "CutActive"	"Active"		0.068  'ref  "CUTACTIVE.SE.1"  'description  "CutActive spacing to cut Poly must be at least" )
     ( allowedWidthRanges         "CutPoly"	'measureHorizontal	(">=0.060")  'ref  "CUTPOLY.W.1"  'description  "CutPoly allowed horizontal dimension" )
     ( allowedWidthRanges         "CutPoly"	'measureVertical	(0.06 0.07 0.1 0.12)  'ref  "CUTPOLY.W.2"  'description  "CutPoly allowed vertical dimension" )
     ( maxLength                  "CutPoly"	3.0  'ref  "CUTPOLY.W.3"  'description  "Maximum length for CutPoly" )
     ( minSpacing                 "CutPoly"	0.09  'ref  "CUTPOLY.S.1"  'description  "CutPoly minimum spacing must be at least" )
     ( minSpacing                 "CutPoly"	"trueActive"		0.02  'ref  "CUTPOLY.SE.1"  'description  "CutPoly spacing to true Active must be at least" )
     ( minSpacing                 "CutPoly"	"LiPo"		0.019  'ref  "CUTPOLY.SE.2"  'description  "LiPo spacing to cut Poly must be at least" )
    ) ;spacings

    orderedSpacings(
     ( minExtensionDistance       "CutActive"	"Active"		0.01  'coincidentAllowed  'ref  "CUTACTIVE.E.1"  'description  "CutActive must extend past Active by at least 0.01" )
     ( minExtensionDistance       "CutPoly"	"Poly"		0.034  'coincidentAllowed  'ref  "CUTPOLY.E.1"  'description  "CutPoly must extend past poly by at least 0.034" )
    ) ;orderedSpacings

    spacings(
     ( gateOrientation            "Gate"	"vertical"  'ref  "CDS Gate.Orient"  'description  "Gate must be vertical" )
    ) ;spacings

    spacings(
    ;( constraint		layer1		[layer2]	value  )
    ;( ----------		------		--------	-----  )
     ( minExtensionVDistance      "Active"	"Fin"	0.0 )
     ( minExtensionHDistance      "Active"	"Fin"	0.044 )
    ) ;spacings

    spacingTables(
    ;( constraint		layer1	[layer2]
    ;   (( index1Definitions     [index2Defintions]) [defaultValue] )
    ;   ( table) )
    ;(--------------------------------------------------)
     ( "allowedWidthForPitch"	"Poly"
	(( "pitch"	nil  nil ) )
	(
	   0.086 (0.018)
	   0.09 (0.018 0.02)
	   0.094 (0.018 0.02 0.024)
	   0.102 (0.018 0.02 0.024 0.028)
	   0.104 (0.018 0.02 0.024 0.028 0.03)
	)
     )
    ) ;spacingTables
  ) ;foundry
) ;constraintGroups


;********************************
; DEVICES
;********************************
devices(
tcCreateCDSDeviceClass()

tcCreateDeviceClass( "layout" "cdsGuardRing"
    ; class parameters
    (    (pinName "B1")
	 (classVersion nil) 
         (vfoGRImpl "vfoAdvGuardRing")
	 (enclosureClass "vfoSfEnclosureClass")
	 (vfoProtocolClass "vfoAdvSfImplClass") 
         (hilightLpp (quote ("annotate" "drawing")))
         (mainLpp (quote ("y2" "drawing")))
         (modelLpp (quote ("y0" "drawing")))
         (metalLayer nil)
         (contLayer nil)
         (tmpLpp (quote ("instance" "drawing")))
         (diffLayer nil)
         (guardRingType nil)
	 (termName "B")
    )
    ; formal parameters
    (
         (xDiffEnclCont 0.0)
	 (yDiffEnclCont 0.0)
         (xMetEnclCont 0.0)
	 (yMetEnclCont 0.0)
         (xContSpacing 0.0)
	 (yContSpacing 0.0)
         (xContWidth 0.0)
	 (yContWidth 0.0)
	 (shapeData "nil")
	 (shapeType "none")
         (decompositionMode (if (getShellEnvVar "FGR_USE_ALIGNCUTS") "alignCuts" "fill45-path-poly"))
	 (hide_keepouts t)
	 (fillStyle "distribute")
         (fillClass "vfoSfFillSafe")
	 (debug 0)
	 (do_something t)
         (formalVersion 0)
	 (keepOuts nil)
	 (horizontalSegWidth 0.0)
 	 (verticalSegWidth 0.0)
 	 (verticalPitch 0.0)
 	 (horizontalPitch 0.0)
	 (minHorizontalSegLength 0.0)
	 (minVerticalSegLength 0.0)
 	 (topMetal "M1")
    )
    ; IL codes specifying geometry
    
    (eval 
	(quote 
	    (if 
		(vfoIsSuperMaster tcCellView) 
		(progn 
		    (dbCreateLabel tcCellView modelLpp 
			(range 0 0) "superMaster"
			"lowerLeft" "R0" "roman" 1.0
		    ) 
		    (vfoSetProtocolClassName tcCellView 
			(concat vfoProtocolClass)
		    )
		) 
		(let 
		    ((result 
			    (errset 
				(when 
				    t 
				    (vfoGRGeometry 
					(makeInstance 
					    (or 
						(findClass 
						    (concat vfoGRImpl "_ver_" formalVersion)
						) 
						(error "SKILL Class %L does not exist:" 
						    (concat vfoGRImpl "_ver_" formalVersion)
						)
					    )
                                            ?cv tcCellView 
					    ?keepOuts keepOuts 
					    ?formalVersion formalVersion 
					    ?do_something do_something
					    ?debug debug 
					    ?fillClass fillClass 
					    ?fillStyle fillStyle 
					    ?hide_keepouts hide_keepouts 
					    ?decompositionMode decompositionMode
					    ?shapeType shapeType 
					    ?shapeData shapeData 
                                            ?xContWidth xContWidth 
					    ?yContWidth yContWidth 
					    ?xContSpacing xContSpacing 
					    ?yContSpacing yContSpacing 
                                            ?xMetEnclCont xMetEnclCont 
					    ?yMetEnclCont yMetEnclCont 
					    ?xDiffEnclCont xDiffEnclCont
					    ?yDiffEnclCont yDiffEnclCont 
                                            ?vfoGRImpl vfoGRImpl 
					    ?modelLpp modelLpp 
					    ?tmpLpp tmpLpp 
					    ?hilightLpp hilightLpp 
                                            ?mainLpp mainLpp 
					    ?vfoProtocolClass vfoProtocolClass 
					    ?enclosureClass enclosureClass
					    ?termName termName 
					    ?pinName pinName 
					    ?metalLayer metalLayer 
					    ?contLayer contLayer 
					    ?diffLayer diffLayer
					    ?guardRingType guardRingType 
					    ?classVersion classVersion   
                                            ?horizontalSegWidth horizontalSegWidth 
					    ?verticalSegWidth verticalSegWidth 
					    ?verticalPitch verticalPitch 
					    ?horizontalPitch horizontalPitch
					    ?minHorizontalSegLength minHorizontalSegLength
					    ?minVerticalSegLength minVerticalSegLength
			                    ?topMetal topMetal
					)
				    )
				) t
			    )
			) msg
		    )
		    (setq msg
			(getqq errset errset)
		    )
		    (unless result
			(dbCreateLabel tcCellView
			    (quote
				("marker" "error")
			    )
			    (range 0 0)
			    (sprintf nil "%L" msg)
			    "lowerLeft" "R0" "roman" 1.0
			) 
			(error "%L/%L" 
			    (getSGq tcCellView cellName) msg
			)
		    )
		)
	    )
	)
    )
)

tcDeclareDevice( "layout" "cdsGuardRing" "NGR"
    ( (classVersion 1)
      (enclosureClass "vfoSfEnclosureClass")
      (vfoProtocolClass "vfoAdvSfImplClass")
      (hilightLpp (quote ("annotate" "drawing")))
      (vfoGRImpl "cds_ff_mptFgrGuardRing")
      (mainLpp (quote ("Active" "drawing")))
      (modelLpp (quote ("y0" "drawing")))
      (metalLayer (quote ("M1" "drawing")))
      (contLayer (quote ("y2" "drawing")))
      (tmpLpp (quote ("instance" "drawing")))
      (diffLayer (quote ("Active" "drawing")))
      (guardRingType "N")
      (termName "FGRTerm")
      (pinName "FGRPin")
    )
    (
      (yDiffEnclCont 0.000000)
      (xDiffEnclCont 0.000000)
      (yMetEnclCont 0.000000)
      (xMetEnclCont 0.000000)
      (yContSpacing 0.001000)
      (xContSpacing 0.001000)
      (yContWidth 0.032000)
      (xContWidth 0.032000)
      (shapeData "nil")
      (shapeType "none")
      (decompositionMode "fill45-path-poly")
      (hide_keepouts t)
      (fillStyle "distribute")
      (fillClass "vfoSfFillSafe")
      (debug 0)
      (do_something t)
      (formalVersion 0)
      (keepOuts (quote nil))
      (horizontalSegWidth 0.048)
      (verticalSegWidth 0.172)
      (verticalPitch 0.048)
      (horizontalPitch 0.086)
      (minHorizontalSegLength 0.258)
      (minVerticalSegLength 0.384)
      (topMetal "M1")
    )
)

tcDeclareDevice( "layout" "cdsGuardRing" "PGR"
    ( (classVersion 1)
      (enclosureClass "vfoSfEnclosureClass")
      (vfoProtocolClass "vfoAdvSfImplClass")
      (hilightLpp (quote ("annotate" "drawing")))
      (vfoGRImpl "cds_ff_mptFgrGuardRing")
      (mainLpp (quote ("Active" "drawing")))
      (modelLpp (quote ("y0" "drawing")))
      (metalLayer (quote ("M1" "drawing")))
      (contLayer (quote ("y2" "drawing")))
      (tmpLpp (quote ("instance" "drawing")))
      (diffLayer (quote ("Active" "drawing")))
      (guardRingType "P") 
      (termName "FGRTerm")
      (pinName "FGRPin")
    )
    (
      (yDiffEnclCont 0.000000)
      (xDiffEnclCont 0.000000)
      (yMetEnclCont 0.000000)
      (xMetEnclCont 0.000000)
      (yContSpacing 0.001000)
      (xContSpacing 0.001000)
      (yContWidth 0.032000)
      (xContWidth 0.032000)
      (shapeData "nil")
      (shapeType "none")
      (decompositionMode "fill45-path-poly")
      (hide_keepouts t)
      (fillStyle "distribute")
      (fillClass "vfoSfFillSafe")
      (debug 0)
      (do_something t)
      (formalVersion 0)
      (keepOuts (quote nil))
      (horizontalSegWidth 0.048)
      (verticalSegWidth 0.172)
      (verticalPitch 0.048)
      (horizontalPitch 0.086)
      (minHorizontalSegLength 0.258)
      (minVerticalSegLength 0.384)
      (topMetal "M1")
    )
)

;		    (viewName	deviceName	propName	propValue)
tfcDefineDeviceProp((layout	NGR	vfoProtocolClass	"vfoAdvSfImplClass"))
tfcDefineDeviceProp((layout	PGR	vfoProtocolClass	"vfoAdvSfImplClass"))

) ;devices
