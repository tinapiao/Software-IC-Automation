 
This document is to provide SPICE circuit simulation parameters for the TSMC 65-nm CMOS 
mixed-signal/RF low power salicide CU LOW-K SPICE models(1P9M 1.0V/2.5V) applications. 
Cadence Spectre (version 6.0.2.247 or later version), Synopsys Hspice (version H2006.03 or
2007.03-SP1 later) and Mentor Graphic¡¦s Eldo (v6.6_1.1 and later version) tools are used
to verify & QA the BSIM4 models. Accuracy & QA in other simulators are not guaranteed.

**********************************************
*             TSMC SPICE MODEL               *
**********************************************
PROCESS :  65nm Mixed Signal RF SALICIDE Low-K IMD (1.0/2.5/over-drive 3.3V) (CRN65GPLUS) 
MODEL   :  BSIM4 ( V4.5 )
DOC. NO.:  T-N65-CM-SP-018 
VERSION :  V1.0
DATE    :  Nov. 22, 2007
************************************************************************************************
This release note describes the features in model of CRN65G+ RF Spice model version 1.0
************************************************************************************************

Content

1. MOS MODEL
2. MIM CAPACITOR MODEL
3. SPIRAL INDUCTOR MODEL
4. MOS VARACTOR MODEL
5. JUNCTION VARACTOR MODEL
6. RF RESISTOR MODEL
7. RTMOM CAPACITOR MODEL
8. MIM CAPACITOR MODEL
9. RAW DATA
10. UPDATE HISTORY


=========================================================================================================================
(1) MOS MODEL
    (a) 1.0V Standard Vt MOS MODEL

	.lib RF_MOS

         Model name       NF               L (um)           Wf (um)
                       low   high        low    high      low    high
       -----------------------------------------------------------------
         nmos_rf        1     32         0.06    0.24     0.6    6.0
       -----------------------------------------------------------------
         pmos_rf        1     32         0.06    0.24     0.6    6.0
       -----------------------------------------------------------------
         pmos_rf_nw     1     32         0.06    0.24     0.6    6.0
       -----------------------------------------------------------------
       **NF: Finger number
       **Wf: Width per finger


    (b) 1.8V MOS MODEL

         .lib RF_MOS_18

         Model name           NF               L (um)           Wf (um)
                           low   high        low    high      low    high
       -------------------------------------------------------------------
         nmos_rf_18        1     32         0.26    0.38     1.    10.00
       -------------------------------------------------------------------
         pmos_rf_18        1     32         0.26    0.38     1.    10.00
       -------------------------------------------------------------------
         pmos_rf_18_nw     1     32         0.26    0.38     1.    10.00
       -------------------------------------------------------------------
       **NF: Finger number
       **Wf: Width per finger

    (c) 2.5V MOS MODEL

         .lib RF_MOS_25

         Model name           NF               L (um)           Wf (um)
                           low   high        low    high      low    high
       -------------------------------------------------------------------
         nmos_rf_25        1     32         0.28    0.50     1.    10.00
       -------------------------------------------------------------------
         pmos_rf_25        1     32         0.28    0.50     1.    10.00
       -------------------------------------------------------------------
         pmos_rf_25_nw     1     32         0.28    0.50     1.    10.00
       -------------------------------------------------------------------
       **NF: Finger number
       **Wf: Width per finger

    (d) 3.3V MOS MODEL

         .lib RF_MOS_33

         Model name           NF               L (um)           Wf (um)
                           low   high        low    high      low    high
       -------------------------------------------------------------------
         nmos_rf_33        1     32         0.5    0.70     1.    10.00
       -------------------------------------------------------------------
         pmos_rf_33        1     32         0.4    0.70     1.    10.00
       -------------------------------------------------------------------
         pmos_rf_33_nw     1     32         0.4    0.70     1.    10.00
       -------------------------------------------------------------------
       **NF: Finger number
       **Wf: Width per finger

=========================================================================================================================
(2) MIM CAPACITOR MODEL :

     HF model:
          1.0fF MiM_Cap w/i underground metal for 1PXM 4<=X<=9
          1.5fF MiM_Cap w/i underground metal for 1PXM 4<=X<=9
          2.0fF MiM_Cap w/i underground metal for 1PXM 4<=X<=9

     ## library files:

     1. The MIM capacitors with underground metal are modeled with sub-circuit 'mimcap_um_sin_rf'
        a. mimflag=1  for 1.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=1 for mismatch
        b. mimflag=2  for 1.5fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=2 for mismatch
        c. mimflag=3  for 2.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=3 for mismatch
     2. The MIM capacitors without underground metal are modeled with sub-circuit 'mimcap_woum_sin_rf'
        a. mimflag=1  for 1.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=1 for mismatch
        b. mimflag=2  for 1.5fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=2 for mismatch
        c. mimflag=3  for 2.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=3 for mismatch
     3. The UTM direct contact MIM capacitors with underground metal are modeled with sub-circuit 'mimcap_um_sin_udc_rf'
        a. mimflag=1  for 1.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=1 for mismatch
        b. mimflag=2  for 1.5fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=2 for mismatch
        c. mimflag=3  for 2.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=3 for mismatch
     4. The UTM direct contact MIM capacitors without underground metal are modeled with sub-circuit 'mimcap_woum_sin_udc_rf'
        a. mimflag=1  for 1.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=1 for mismatch
        b. mimflag=2  for 1.5fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=2 for mismatch
        c. mimflag=3  for 2.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=3 for mismatch


     Model name            	lt(um)            wt(um)
                           	low    high       low    high
     -------------------------------------------------------------
     mimcap_um_sin_rf          4     100         4     100
     mimcap_woum_sin_rf        4     100         4     100
     mimcap_um_sin_udc_rf      4     100         4     100
     mimcap_woum_sin_udc_rf    4     100         4     100
     ------------------------------------------------------------
            **lt: length dimension of top metal (CTM)
            **wt: width dimension of top metal (CTM)
            **lay: the number of metal layer under MIM, ex. for MIM is between M7 and M8, lay=7
            **lt >= wt
            **MIM is between Mz and Mx      

=========================================================================================================================
(3) SPIRAL INDUCTOR MODEL :

    HSPICE LEVEL 49:

      ## library files: 
      models are applied in: 
      spiral_std_mu_z, spiral_sym_mu_z, spiral_sym_ct_mu_z -- from 1P5M to 1P9M. UTM(34K) is used for the core inductor.
      spiral_std_mza_a, spiral_sym_mza_a, spiral_sym_ct_mza_a, spiral_std_mu_a, spiral_sym_mu_a, spiral_sym_ct_mu_a-- from 1P3M to 1P8M, Mz and ALRDL or Mu and ALRDL are used for the core inductor.

     The Inductors are modeled with sub-circuit 'spiral_std_xxx' and 'spiral_sym_xxx' and 'spiral_sym_ct_xxx', xxx represents the process of inductor, described above. 
      mu_z represents M1 + (lay-3)*Mx + Mz + Mu
      mza_a represents M1 + (lay-2)*Mx + Mz + ALRDL, mu_a is the same with mza_a

      .subckt spiral_std_mu_z    : Standard model with space=2~4um(w=3um~30um) for Inductance varies with turn(1/4 turn increments) and radius
      .subckt spiral_sym_mu_z    : Symmetric model with space=2~4um(w=3um~30um) for Inductance varies with turn(integral turn increments) and radius
      .subckt spiral_sym_ct_mu_z : Center-tap model with space=2~4um(w=3um~30um) for Inductance varies with turn(integral turn increments) and radius
      .subckt spiral_std_mza_a   : Standard model with space=2~4um(w=7.5um~30um) for Inductance varies with turn(1/4 turn increments) and radius
      .subckt spiral_sym_mza_a   : Symmetric model with space=2~4um(w=7.5um~30um) for Inductance varies with turn(integral turn increments) and radius
      .subckt spiral_sym_ct_mza_a: Center-tap model with space=2~4um(w=7.5um~30um) for Inductance varies with turn(integral turn increments) and radius
      .subckt spiral_std_mu_a   : Standard model with space=2~4um(w=6.2um~30um) for Inductance varies with turn(1/4 turn increments) and radius
      .subckt spiral_sym_mu_a   : Symmetric model with space=2~4um(w=6.2um~30um) for Inductance varies with turn(integral turn increments) and radius
      .subckt spiral_sym_ct_mu_a: Center-tap model with space=2~4um(w=6.2um~30um) for Inductance varies with turn(integral turn increments) and radius

     Parameter,gdis, is the distance between core inductor and the guard-ring. Please note that the coupling with other devices should be taken cared by designer, especially 
     gdis = 10u. This coupling with other devices isn't counted in this model.

         Model name                   turn          rad (um)        gdis(um)
                                    low   high     low   high     low    high
     ---------------------------------------------------------------------
     spiral_std_mu_z     W=3~30um   0.5   5.5      15 *    90      10u     50u
     ---------------------------------------------------------------------
     spiral_sym_mu_z     W=3~30um    1     6       15 *    90      10u     50u
      --------------------------------------------------------------------
     spiral_sym_ct_mu_z  W=3~30um    1     5       15 *    90      10u     50u
      --------------------------------------------------------------------
     spiral_std_mza_a    W=7.5~30um 0.5   5.5      15 *    90      10u     50u
     ---------------------------------------------------------------------
     spiral_sym_mza_a    W=7.5~30um  1     6       15 *    90      10u     50u
      --------------------------------------------------------------------
     spiral_sym_ct_mza_a W=7.5~30um  1     5       15 *    90      10u     50u
      --------------------------------------------------------------------
     spiral_std_mu_a     W=6.2~30um 0.5   5.5      15 *    90      10u     50u
     ---------------------------------------------------------------------
     spiral_sym_mu_a     W=6.2~30um  1     6       15 *    90      10u     50u
      --------------------------------------------------------------------
     spiral_sym_ct_mu_a  W=6.2~30um  1     5       15 *    90      10u     50u
      --------------------------------------------------------------------
      * when width is larger than 20um, radius is limited within 20um~90um
      ** center-tapped inductor can only be used in differetial model.


=========================================================================================================================
(4) MOS VARACTOR MODEL : 
  
     ## library files:
     
      Model name          W                L               Group      Branch  
      -------------------------------------------------------------------------
       moscap_rf      0.4um<=W<=3.2um  0.2um<=L<=3.2um    1<=G<=16    2<=B<=64          
       moscap_rf25    0.4um<=W<=3.2um  0.4um<=L<=3.2um    1<=G<=16    2<=B<=64      
       moscap_rf_nw   0.4um<=W<=3.2um  0.2um<=L<=3.2um    1<=G<=16    2<=B<=64           
       moscap_rf25_nw 0.4um<=W<=3.2um  0.4um<=L<=3.2um    1<=G<=16    2<=B<=64 
      -------------------------------------------------------------------------

=========================================================================================================================
(5) JUNCTION VARACTOR MODEL :

  HSPICE LEVEL 49:
  
     ## library files:
           
      Model name      L(um)         W(um)(w)       Finger(nr)  
      ---------------------------------------------------
       xjvar        0.15 ~ 1        10 ~ 60         1 ~ 64  
       xjvar_nw     0.15 ~ 1        10 ~ 60         1 ~ 64     
      ---------------------------------------------------

=========================================================================================================================
(6) RF RESISTOR MODEL - HSPICE
	
      	Model name	
      	----------------------------------------------------------------------
      	rppolyl_rf       P+Poly w/i silicide  2um<=W<=10um,  0.3um<=L<=150um, 1<=sqr<=150
      	rppolys_rf       P+Poly w/i silicide  0.15um<=W<2um,  0.3um<=L<=150um, 1<=sqr<=150
      	rppolywo_rf	 P+Poly w/o silicide  0.4um<=W<=10um,  0.8um<=L<=25um,     1<=sqr<=20

=========================================================================================================================
(7) RTMOM CAPACITOR MODEL :
        --------------------------------------------------
           N65 RF RTMOM                                                                                            
           parameter range: nv : 6~288, nh : 6~288                                                                 
                            nv and nh should be even fingers                                                       
                            w(width):0.1u ~0.16u                                                                   
                            s(spacing):0.1u ~0.16u                                                                 
                            stm(start metal layer):M1,M2,M3,M4,M5 (M2,M3,M4,M5 are inter metals (Mx thk=0.22um))   
                            spm(stop metal layer):M3,M4,M5,M6,M7 (M3,M4,M5,M6,M7 are inter metals (Mx thk=0.22um)) 
                            Total metal is at least 3 layers stacked with ploy shield                              
                            mismatchflag=0 for no mismatch                                                         
                            mismatchflag=1 for mismatch                                                            
        --------------------------------------------------
           N65 BB RTMOM                                                                                            
           parameter range: nv : 6~288, nh : 6~288                                                                 
                            nv and nh should be even fingers                                                       
                            w(width):0.1u ~0.16u                                                                  
                            s(spacing):0.1u ~0.16u                                                                 
                            stm(start metal layer):M1,M2,M3,M4,M5 (M2,M3,M4,M5 are inter metals (Mx thk=0.22um))   
                            spm(stop metal layer):M3,M4,M5,M6,M7 (M3,M4,M5,M6,M7 are inter metals (Mx thk=0.22um)) 
                            Total metal is at least 3 layers stacked with ploy shield                              
                            mismatchflag=0 for no mismatch                                                         
                            mismatchflag=1 for parallel                                                            
        --------------------------------------------------
           N65 BB 5T RTMOM FOR MULTI-X-COUPLE MISMATCH APPLICATION                                                                                        *
           parameter range: nv : 6~288, nh : 6~288                                                                 
                            nv and nh should be even fingers                                                       
                            w(width):0.1u ~0.16u                                                                   
                            s(spacing):0.1u ~0.16u                                                                 
                            stm(start metal layer):M1,M2,M3,M4,M5 (M2,M3,M4,M5 are inter metals (Mx thk=0.22um))   
                            spm(stop metal layer):M3,M4,M5,M6,M7 (M3,M4,M5,M6,M7 are inter metals (Mx thk=0.22um)) 
                            Total metal is at least 3 layers stacked with ploy shield                              
                            mismatchflag=0 for no mismatch                                                         
                            mismatchflag=1 for multi-x-couple                                                      

=========================================================================================================================
(8) MIM CAPACITOR MODEL :
     ## library files:

     1. The 2T base band MIM capacitors with sub-circuit 'mimcap_sin'
        a. mimflag=1 for 2T base band 1.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=1 for mismatch
        b. mimflag=2 for 2T base band 1.5fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=2 for mismatch
        c. mimflag=3 for 2T base band 2.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=3 for mismatch
     2. The 3T base band MIM capacitors with sub-circuit 'mimcap_sin_3t'
        a. mimflag=1 for 3T base band 1.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=1 for mismatch
        b. mimflag=2 for 3T base band 1.5fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=2 for mismatch
        c. mimflag=3 for 3T base band 2.0fF MIM capacitors ,and mismatchflag==0 for no mismatch mismatchflag=3 for mismatch

        Model name              lt             wt
                                low    high    low    high
        --------------------------------------------------
        mimcap_sin        (um)   2     100      2     100
        mimcap_sin_3t     (um)   2     100      2     100
        --------------------------------------------------
        **lt: length dimension of top metal (CTM) 
        **wt: width dimension of top metal (CTM) 
        **lay: the number of metal layer under MIM, ex. for MIM is between M7 and M8, lay=7
        **MIM is between Mz and Mx      

=========================================================================================================================
(9) RAW DATA :

      ## raw data files:

        1.  README                           : explain how to read the raw data format 
        2.  citi_MOS_SVT.zip                 : for 1.0V SVT N/PMOS GROUP
        3.  citi_MOS_IO25.zip                : for 2.5V N/PMOS GROUP 
        4.  citi_MIM.zip                     : for MIM_capacitor GROUP
        5.  citi_UDC_MIM.zip                 : for UTM direct contact MIM_capacitor GROUP
        6.  citi_Inductor.zip                : for Spiral_inductor GROUP
        7.  citi_MOSVAR_SVT_core_DNW.zip     : for 1.0V SVT MOS_varactor GROUP w/ DNW
        8.  citi_MOSVAR_SVT_core_NW.zip      : for 1.0V SVT MOS_varactor GROUP w/o DNW
        9.  citi_MOSVAR_SVT_IO_DNW.zip       : for 2.5V IO MOS_varactor GROUP w/ DNW
       10.  citi_MOSVAR_SVT_IO_NW.zip        : for 2.5V IO MOS_varactor GROUP w/o DNW
       11.  citi_XJVAR.zip                   : for Junction_varactor GROUP
       12.  citi_Res.zip                     : for resistor GROUP
       13.  citi_RTMOM.zip	             : for RTMOM_capacitor GROUP 

=========================================================================================================================
(10) UPDATE HISTORY :

*  1. crn65gplus_2d5_lk_v1d0p1 (10/05/2007) :  
*        1. Add the RF MOS model based on Si & CLN65G+ 1.0V/2.5V model v1.2
*           Si SVT     ---> N9K007 #2(NMOS), N9K007 #3(PMOS)
*	    Si IO 2.5V ---> N9K007 #21 (NMOS), N9K007 #23(PMOS)
*        2. Add the T-noise model for xxx_MAC devices based on Si SVT
*        3. Add RF MOSVAR model (SVT & 2.5V)
*        4. Add RF Resistor model 
*        5. Add RF Junction varactor model 
*        6. Add RF MIM model 
*        7. Add RF MOM model
*        8. Add RF INDUCTOR model
*
*  2. crn65gplus_2d5_lk_v1d0p2 (10/12/2007) : 
*        1. Update the BB RTMOM Model Corner from +/- 20% to +/- 15% 
*        2. Add the BB UDC MIMCAP Model
*        3. Update nch_25 xj & tnoimod
*                  pch_25 xj
*                  nch_33 rshg & xgl
*                  pch_33 rshg & xgl
*        4. Updated the flicker noise corner parameters: 
*                  a. modified the flicker noise corner model of Core and IO MOS
*                  b. fixed the flicker noise parameters of resistor                     
*                     
*  3. crn65gplus_2d5_lk_v1d0 (11/22/2007) :
*        1. Clone model card code from crn65gplus_2d5_lk_v1d0p2 and named as crn65gplus_2d5_lk_v1d0 
*        2. Update noiseflag definition of flicker noise model
*

         