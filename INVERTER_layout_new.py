
import math
import os
import pprint
import matplotlib.pyplot as plt
import yaml
import numpy as np
import scipy.optimize as sciopt
import scipy.interpolate as interp
import numpy as np
import h5py
from bag.core import BagProject
from bag.io import read_yaml, open_file
from bag.io.sim_data import load_sim_file
from bag.util.search import BinaryIterator, minimize_cost_golden_float
from bag.simulation.core import DesignManager
from bag.data import load_sim_results, save_sim_results, load_sim_file

from bag_testbenches_ec.verification_ec.mos.query import MOSDBDiscrete
from bag import float_to_si_string
from bag.io import read_yaml, open_file, load_sim_results, save_sim_results, load_sim_file
from bag.layout import RoutingGrid, TemplateDB
from bag.concurrent.core import batch_async_task
from bag import BagProject
import laygo

def round_up_to_even(f):
    return math.ceil(f / 2.) * 2

def INVERTER_layout_new(fan_factor, number_fan, num_finger_p1, num_finger_n1):
    laygen = laygo.GridLayoutGenerator(config_file="laygo_config.yaml")
    # template and grid load
    utemplib = laygen.tech + '_invertertemplates'
    laygen.load_template(filename=utemplib + '_templates.yaml', libname=utemplib)
    laygen.load_grid(filename=utemplib + '_grids.yaml', libname=utemplib)
    laygen.templates.sel_library(utemplib)
    laygen.grids.sel_library(utemplib)

    # user inputs
    n_or_p = 'n'
    input_list = []
    # library & cell creation
    laygen.add_library('AN_INVERTER_496')
    laygen.add_cell('INVERTER_lch_60n')

    # grid variables
    pb = 'placement_basic'
    rg12 = 'route_M1_M2_cmos'
    rg23 = 'route_M2_M3_cmos'
    rg34 = 'route_M3_M4_cmos'
    rgnw = 'route_nwell'

    #insert our code here
  #pmos count fingers

    pmos_num_eachfan = ['' for i in range(number_fan)]
    pmos_index_first_eachfan= ['' for i in range(number_fan)]
    pmos_num_tot = 0
    for i in range(number_fan):
        if (i == 0):
            pmos_num_eachfan[i] = int(num_finger_p1 )
        else:
            pmos_num_eachfan[i] = math.ceil((num_finger_p1 / (fan_factor ** i)) )
        pmos_num_tot = pmos_num_tot + pmos_num_eachfan[i]
    pmos_num_eachfan.reverse()    
    #print('tot finger pmos',pmos_num_tot)
      #pmos finger placment even case
    print('pmos_num_eachfan:',pmos_num_eachfan)
    pmos_row_layout_tot=[]  
    
    for index,num_each_stage in enumerate (pmos_num_eachfan):
        pmos_each_row_layout=[]
        if num_each_stage%2==0:
            num_each_stage=int(num_each_stage/2)
            pmos_each_row_layout=['' for i in range (num_each_stage)]
            for i in range(num_each_stage):
                if i==0:
                    if index==0:
                        pmos_each_row_layout[i]=laygen.relplace(templatename=['inverter_two_finger_p'],gridname=pb,xy=[0,0], direction='right') 
                    else:
                        pmos_each_row_layout[i]=laygen.relplace(templatename=['inverter_two_finger_p'],gridname=pb,xy=[8,0], refobj=pmos_row_layout_tot[index-1][-1], direction='right')         
                else:
                                 
                        pmos_each_row_layout[i]=laygen.relplace(templatename=['inverter_two_finger_p'],gridname=pb,xy=[0,0], refobj=pmos_each_row_layout[i-1], direction='right')             
                                   
            pmos_row_layout_tot.append(pmos_each_row_layout)
            print('pmos_row_layout_tot:',pmos_row_layout_tot)

    #pmos finger placment odd case     
        else:
            if num_each_stage==3:
               num_each_stage=1 
            elif num_each_stage==5:
                num_each_stage=2
            else:
                num_each_stage=int(2+((num_each_stage-5)/2)) 
       
            pmos_each_row_layout=['' for i in range (num_each_stage)]
            
            
            if num_each_stage==1:
                if index==0:
                    pmos_each_row_layout[0]= laygen.relplace(templatename=['inverter_three_finger_p'],gridname=pb,xy=[0,0], direction='right') 
                else:
                    pmos_each_row_layout[0]= laygen.relplace(templatename=['inverter_three_finger_p'],gridname=pb,xy=[8,0], refobj=pmos_row_layout_tot[index-1][-1], direction='right') 
                    
            elif num_each_stage==2:
                if index==0:
                    pmos_each_row_layout[0]= laygen.relplace(templatename=['inverter_three_finger_p'],gridname=pb,xy=[0,0], direction='right')  
                    pmos_each_row_layout[1]= laygen.relplace(templatename=['inverter_three_finger_p'],gridname=pb,xy=[-1,0], refobj=pmos_each_row_layout[0], direction='right')   
                else:
                    pmos_each_row_layout[0]= laygen.relplace(templatename=['inverter_three_finger_p'],gridname=pb,xy=[8,0], refobj=pmos_row_layout_tot[index-1][-1], direction='right') 
                    pmos_each_row_layout[1]= laygen.relplace(templatename=['inverter_three_finger_p'],gridname=pb,xy=[-1,0], refobj=pmos_each_row_layout[0], direction='right') 
                          

            else:
                for i in range(num_each_stage):
                    if i==0:
                        if index==0:
                            pmos_each_row_layout[i]= laygen.relplace(templatename=['inverter_three_finger_p'],gridname=pb,xy=[0,0], direction='right') 
                        else:
                            pmos_each_row_layout[i]= laygen.relplace(templatename=['inverter_three_finger_p'],gridname=pb,xy=[8,0], refobj=pmos_row_layout_tot[index-1][-1], direction='right') 
                    elif i==1:
                        pmos_each_row_layout[i]= laygen.relplace(templatename=['inverter_three_finger_p'],gridname=pb,xy=[-1,0], refobj=pmos_each_row_layout[i-1], direction='right')    
                    else:
                        pmos_each_row_layout[i]=laygen.relplace(templatename=['inverter_two_finger_p'],gridname=pb,xy=[0,0], refobj=pmos_each_row_layout[i-1], direction='right')
      
            pmos_row_layout_tot.append(pmos_each_row_layout)
            
    #nmos finger caclulation
    nmos_num_eachfan = ['' for i in range(number_fan)]
    nmos_index_first_eachfan= ['' for i in range(number_fan)]
    nmos_num_tot = 0
    for i in range(number_fan):
        if (i == 0):
            nmos_num_eachfan[i] = int(num_finger_n1 )
        else:
            nmos_num_eachfan[i] = math.ceil((num_finger_n1 / (fan_factor ** i)) )
        nmos_num_tot = nmos_num_tot + nmos_num_eachfan[i]
    nmos_num_eachfan.reverse()    
    #print('tot finger nmos',nmos_num_tot)
      #nmos finger placment even case
    print('nmos_num_eachfan:',nmos_num_eachfan)
    nmos_row_layout_tot=[]  
    
    for index,num_each_stage in enumerate (nmos_num_eachfan):
        nmos_each_row_layout=[]

         #nmos even case
        if num_each_stage%2==0:
            num_each_stage=int(num_each_stage/2)
            nmos_each_row_layout=['' for i in range (num_each_stage)]
           
            for i in range(num_each_stage):
                if i==0:
                    if index==0:
#nmos_row_layout[i]=laygen.relplace(templatename=['inverter_two_finger_n'],gridname=pb,xy=[-1,-1], refobj=pmos_row_layout[int(pmos_num_tot/3)-1], direction='right') 
                        nmos_each_row_layout[i]=laygen.relplace(templatename=['inverter_two_finger_n'],gridname=pb,xy=[-2,-1], refobj=pmos_row_layout_tot[index][0], direction='right') 
                    else:
                        nmos_each_row_layout[i]=laygen.relplace(templatename=['inverter_two_finger_n'],gridname=pb,xy=[8,-1], refobj=pmos_row_layout_tot[index-1][-1], direction='right')         
                else:
                                 
                        nmos_each_row_layout[i]=laygen.relplace(templatename=['inverter_two_finger_n'],gridname=pb,xy=[0,0], refobj=nmos_each_row_layout[i-1], direction='right')             
                                   
            nmos_row_layout_tot.append(nmos_each_row_layout)
            print('nmos_row_layout_tot:',nmos_row_layout_tot)

    #nmos finger placment odd case     
        else:
            if num_each_stage==3:
               num_each_stage=1 
            elif num_each_stage==5:
                num_each_stage=2
            else:
                num_each_stage=int(2+((num_each_stage-5)/2)) 
       
            nmos_each_row_layout=['' for i in range (num_each_stage)]
            
            
            if num_each_stage==1:
                if index==0:
                    nmos_each_row_layout[0]= laygen.relplace(templatename=['inverter_three_finger_n'],gridname=pb,xy=[-2,-1], refobj=pmos_row_layout_tot[0][0], direction='right') 
                else:
                    nmos_each_row_layout[0]= laygen.relplace(templatename=['inverter_three_finger_n'],gridname=pb,xy=[8,-1], refobj=pmos_row_layout_tot[index-1][-1], direction='right') 
                    
            elif num_each_stage==2:
                if index==0:
                    nmos_each_row_layout[0]= laygen.relplace(templatename=['inverter_three_finger_n'],gridname=pb,xy=[-2,-1], refobj=pmos_row_layout_tot[0][0], direction='right')  
                    nmos_each_row_layout[1]= laygen.relplace(templatename=['inverter_three_finger_n'],gridname=pb,xy=[-1,0], refobj=nmos_each_row_layout[0], direction='right')   
                else:
                    nmos_each_row_layout[0]= laygen.relplace(templatename=['inverter_three_finger_n'],gridname=pb,xy=[8,-1], refobj=pmos_row_layout_tot[index-1][-1], direction='right') 
                    nmos_each_row_layout[1]= laygen.relplace(templatename=['inverter_three_finger_n'],gridname=pb,xy=[-1,0], refobj=nmos_each_row_layout[0], direction='right') 
                          

            else:
                for i in range(num_each_stage):
                    if i==0:
                        if index==0:
                            nmos_each_row_layout[i]= laygen.relplace(templatename=['inverter_three_finger_n'],gridname=pb,xy=[-2,-1], refobj=pmos_row_layout_tot[0][0], direction='right') 
                        else:
                            nmos_each_row_layout[i]= laygen.relplace(templatename=['inverter_three_finger_n'],gridname=pb,xy=[8,-1], refobj=pmos_row_layout_tot[index-1][-1], direction='right') 
                    elif i==1:
                        nmos_each_row_layout[i]= laygen.relplace(templatename=['inverter_three_finger_n'],gridname=pb,xy=[-1,0], refobj=nmos_each_row_layout[i-1], direction='right')    
                    else:
                        nmos_each_row_layout[i]=laygen.relplace(templatename=['inverter_two_finger_n'],gridname=pb,xy=[0,0], refobj=nmos_each_row_layout[i-1], direction='right')
      
            nmos_row_layout_tot.append(nmos_each_row_layout)




     #place guardring nwell and pwell
    guardring_n_row_layout=['' for i in range(int(pmos_num_tot*0.8))]
    guardring_p_row_layout=['' for i in range(int(pmos_num_tot*0.8))]
    for i in range(int(pmos_num_tot*0.8)):
        if i==0:
            guardring_n_row_layout[i]=laygen.relplace(templatename=['guard_ring_nwell'],gridname=pb,refobj=pmos_row_layout_tot[0][0],xy=[-3,1],direction='right')
            guardring_p_row_layout[i]=laygen.relplace(templatename=['guard_ring_psub'],gridname=pb,refobj=nmos_row_layout_tot[0][0],xy=[-4,-1],direction='right')
        else:
            guardring_n_row_layout[i]=laygen.relplace(templatename=['guard_ring_nwell'],gridname=pb,refobj=guardring_n_row_layout[i-1],direction='right')            
            guardring_p_row_layout[i]=laygen.relplace(templatename=['guard_ring_psub'],gridname=pb,refobj=guardring_p_row_layout[i-1],direction='right')
    

   
    #routing
    m2_vdd_list=['' for i in range (number_fan)]
    m1_left_top_list=['' for i in range (number_fan)]
    m1_right_top_list=['' for i in range (number_fan)]
    m2_p_in_list=['' for i in range (number_fan)]
    m2_p_out_list=['' for i in range (number_fan)]

    for index,each_stage in enumerate (pmos_row_layout_tot):
        m2_vdd_list[index]=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg12, refobj0=each_stage[0][0].pins['VDD'], refobj1=each_stage[-1][0].pins['VDD'],direction='x',endstyle0='extend',endstyle1='extend')
        
        m1_left_top_list[index]=laygen.route(xy0=[0,0],xy1=[0,0], gridname0=rg12, refobj0=each_stage[0][0].pins['VDD'],refobj1=guardring_n_row_layout[0][0].pins['nwell'], direction='y',via0=[0,0],endstyle0='extend',endstyle1='extend')

        m1_right_top_list[index]=laygen.route(xy0=[4,0],xy1=[0,0], gridname0=rg12,refobj0=each_stage[-1][0].pins['VDD'],refobj1=guardring_n_row_layout[0][0].pins['nwell'],direction='y',via0=[0,0],endstyle0='extend',endstyle1='extend')

        m2_p_out_list[index]=laygen.route(xy0=[0,0],xy1=[6,0],gridname0=rg23, refobj0=each_stage[0][0].pins['out'], refobj1=each_stage[-1][0].pins['out'],direction='x',endstyle0='extend',endstyle1='extend')


        if index==0:
            m2_p_in_list[index]=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg12, refobj0=each_stage[0][0].pins['in'], refobj1=each_stage[-1][0].pins['in'],direction='x',endstyle0='extend',endstyle1='extend')

        else:
            m2_p_in_list[index]=laygen.route(xy0=[-4,0],xy1=[4,0],gridname0=rg12, refobj0=each_stage[0][0].pins['in'], refobj1=each_stage[-1][0].pins['in'],direction='x', endstyle0='extend',endstyle1='extend')
        

    m2_vss_list=['' for i in range (number_fan)]
    m1_left_btm_list=['' for i in range (number_fan)]
    m1_right_btm_list=['' for i in range (number_fan)]
    m2_n_in_list=['' for i in range (number_fan)]
    m2_n_out_list=['' for i in range (number_fan)]
    m3_out_vertical_list=['' for i in range (number_fan)]
    m3_in_in_vertical_list=['' for i in range (number_fan)]
    connect_in_in_list=['' for i in range (number_fan)]
    connect_stage=['' for i in range (number_fan-1)]
    for index,each_stage in enumerate (nmos_row_layout_tot):
        if index==0:
            m2_vss_list[index]=laygen.route(xy0=[0,0],xy1=[5,0],gridname0=rg12, refobj0=each_stage[0][0].pins['VSS'], refobj1=each_stage[-1][0].pins['VSS'],direction='x',endstyle0='extend',endstyle1='extend')  
            m1_right_btm_list[index]=laygen.route(xy0=[5,0],xy1=[0,0], gridname0=rg12,refobj0=each_stage[-1][0].pins['VSS'],refobj1=guardring_p_row_layout[0][0].pins['psub'],direction='y',via0=[0,0],endstyle0='extend',endstyle1='extend')
        else:                
            m2_vss_list[index]=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg12, refobj0=each_stage[0][0].pins['VSS'], refobj1=each_stage[-1][0].pins['VSS'],direction='x',endstyle0='extend',endstyle1='extend')
            m1_right_btm_list[index]=laygen.route(xy0=[4,0],xy1=[0,0], gridname0=rg12,refobj0=each_stage[-1][0].pins['VSS'],refobj1=guardring_p_row_layout[0][0].pins['psub'],direction='y',via0=[0,0],endstyle0='extend',endstyle1='extend')

        m1_left_btm_list[index]=laygen.route(xy0=[0,0],xy1=[0,0], gridname0=rg12, refobj0=each_stage[0][0].pins['VSS'],refobj1=guardring_p_row_layout[0][0].pins['psub'], direction='y',via0=[0,0],endstyle0='extend',endstyle1='extend')

        m2_n_out_list[index]=laygen.route(xy0=[0,0],xy1=[int(2*(len(pmos_row_layout_tot[index])-len(each_stage)))+8,0],gridname0=rg23, refobj0=each_stage[0][0].pins['out'], refobj1=each_stage[-1][0].pins['out'],direction='x', endstyle0='extend',endstyle1='extend')

        if index!=number_fan-1 or index==0:        
            m3_in_in_vertical_list[index]=laygen.route(xy0=[8,0],xy1=[8,0],gridname0=rg23, refobj0=pmos_row_layout_tot[index][-1][0].pins['in'], refobj1=each_stage[-1][0].pins['in'],direction='y',via0=[0,0],via1=[0,0],endstyle0='extend',endstyle1='extend')
        
        if index!=number_fan-1:
            connect_stage[index]=laygen.route(xy0=[6,-3],xy1=[-2,0],gridname0=rg23, refobj0=pmos_row_layout_tot[index][-1][0].pins['out'], refobj1=pmos_row_layout_tot[index+1][0][0].pins['in'],direction='x', endstyle0='extend',endstyle1='extend', via0=[0,0],via1=[0,0])

        m3_out_vertical_list[index]=laygen.route(xy0=[6,0],xy1=[10,0],gridname0=rg23, refobj0=pmos_row_layout_tot[index][-1][0].pins['out'], refobj1=each_stage[-1][0].pins['out'],direction='y',via0=[0,0],via1=[0,0],endstyle0='extend',endstyle1='extend')       
 
         
        if index==0:
            m2_n_in_list[index]=laygen.route(xy0=[0,0],xy1=[5,0],gridname0=rg23, refobj0=each_stage[0][0].pins['in'], refobj1=each_stage[-1][0].pins['in'],direction='x',endstyle0='extend',endstyle1='extend')
            connect_in_in_list[index]=laygen.route(xy0=[0,0],xy1=[0,0],gridname0=rg23, refobj0=pmos_row_layout_tot[index][0][0].pins['in'], refobj1=each_stage[0][0].pins['in'],direction='y',via0=[0,0],via1=[0,0],endstyle0='extend',endstyle1='extend')
            
        else:
            m2_n_in_list[index]=laygen.route(xy0=[-2,0],xy1=[4,0],gridname0=rg23, refobj0=each_stage[0][0].pins['in'], refobj1=each_stage[-1][0].pins['in'],direction='x',endstyle0='extend',endstyle1='extend')       
            

    nwell=laygen.route(xy0=[-1,2],xy1=[4,-10],gridname0=rgnw, refobj0=guardring_n_row_layout[0][0].pins['nwell'], refobj1=guardring_n_row_layout[-1][0].pins['nwell'])
    

    #pin
    vdd_pin=laygen.pin(name='VDD', xy0=[0,3],xy1=[1,3], layer=laygen.layers['pin'][2],gridname=rg12)  
    vss_pin=laygen.pin(name='VSS', xy0=[0,-7],xy1=[1,-7], layer=laygen.layers['pin'][2],gridname=rg12) 
    in_n_pin=laygen.pin(name='in', xy0=[0,-5],xy1=[1,-5], layer=laygen.layers['pin'][2],gridname=rg12)  

    out_n_pin=laygen.pin(name='out',xy0=[20,0],xy1=[22,1], layer=laygen.layers['pin'][2], refobj=m2_n_out_list[-1],gridname=rg23)
    

 
####hardcoded
   #  #place
    # inv_layout_p1=laygen.relplace(templatename=['inverter_two_finger_p'],gridname=pb,xy=[0,0], direction='right')
    # inv_layout_p2=laygen.relplace(templatename=['inverter_two_finger_p'],gridname=pb,xy=[0,0], refobj=inv_layout_p1, direction='right')
    # inv_layout_n1= laygen.relplace(templatename=['inverter_two_finger_n'],gridname=pb,xy=[-1,-1],refobj=inv_layout_p1,direction='right')
   
    # guardring_n1=laygen.relplace(templatename=['guard_ring_nwell'],gridname=pb,refobj=inv_layout_p1,xy=[-3,2],direction='right')
    # guardring_n2=laygen.relplace(templatename=['guard_ring_nwell'],gridname=pb,refobj=guardring_n1,direction='right')    
    # guardring_n3=laygen.relplace(templatename=['guard_ring_nwell'],gridname=pb,refobj=guardring_n2,direction='right')
    # guardring_n4=laygen.relplace(templatename=['guard_ring_nwell'],gridname=pb,refobj=guardring_n3,direction='right')

    # guardring_p1=laygen.relplace(templatename=['guard_ring_psub'],gridname=pb,refobj=inv_layout_p1,xy=[-3,-2],direction='right')
    # guardring_p2=laygen.relplace(templatename=['guard_ring_psub'],gridname=pb,refobj=guardring_p1,direction='right')    
    # guardring_p3=laygen.relplace(templatename=['guard_ring_psub'],gridname=pb,refobj=guardring_p2,direction='right')
    # guardring_p4=laygen.relplace(templatename=['guard_ring_psub'],gridname=pb,refobj=guardring_p3,direction='right')

      #route
    #pmos route,autmated, not hardcode

    #m2_route_list=['m2_vdd','m2_vss','m2_p_in','m2_n_in','m2_p_out','m2_p_out']
    #for i,each in enumerate(m2_route_list):
        
    # m2_vdd=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg12, refobj0=pmos_row_layout[0][0].pins['VDD'], refobj1=pmos_row_layout[pmos_num_tot-1][0].pins['VDD'],direction='x',endstyle0='extend',endstyle1='extend')

    # m2_vss=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg12, refobj0=nmos_row_layout[0][0].pins['VSS'], refobj1=nmos_row_layout[nmos_num_tot-1][0].pins['VSS'],direction='x',endstyle0='extend',endstyle1='extend')

    # m1_left_top=laygen.route(xy0=[0,0],xy1=[0,0], gridname0=rg12, refobj0=guardring_n_row_layout[0][0].pins['nwell'], refobj1=pmos_row_layout[0][0].pins['VDD'],direction='y',via1=[0,0],endstyle0='extend',endstyle1='extend')

    # m1_right_top=laygen.route(xy0=[0,0],xy1=[4,0], gridname0=rg12, refobj0=guardring_n_row_layout[pmos_num_tot+1][0].pins['nwell'], refobj1=pmos_row_layout[-1][0].pins['VDD'],direction='y',via1=[0,0],endstyle0='extend',endstyle1='extend')


    # m1_left_btm=laygen.route(xy0=[0,0],xy1=[0,0], gridname0=rg12,  refobj0=nmos_row_layout[0][0].pins['VSS'],refobj1=guardring_p_row_layout[0][0].pins['psub'],direction='y',via0=[0,0],endstyle0='extend',endstyle1='extend')

    # m1_right_btm=laygen.route(xy0=[4,0],xy1=[0,0], gridname0=rg12,  refobj0=nmos_row_layout[-1][0].pins['VSS'],refobj1=guardring_p_row_layout[-1][0].pins['psub'],direction='y',via0=[0,0],endstyle0='extend',endstyle1='extend')
   
    # m2_p_in=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg23, refobj0=pmos_row_layout[0][0].pins['in'], refobj1=pmos_row_layout[-1][0].pins['in'],direction='x',endstyle0='extend',endstyle1='extend')

    # m2_n_in=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg23, refobj0=nmos_row_layout[0][0].pins['in'], refobj1=nmos_row_layout[-1][0].pins['in'],direction='x',endstyle0='extend',endstyle1='extend')
    
    # #m3_connect_in=laygen.route(xy0=[3,0],xy1=[2,0],gridname0=rg23, refobj0=inv_layout_p1[0].pins['in'], refobj1=inv_layout_n1[0].pins['in'],via0=[0,0],via1=[0,0],direction='y')
    
    # m2_p_out=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg23, refobj0=pmos_row_layout[0][0].pins['out'], refobj1=pmos_row_layout[-1][0].pins['in'],direction='x',endstyle0='extend',endstyle1='extend')

    # m2_n_out=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg23, refobj0=nmos_row_layout[0][0].pins['out'], refobj1=nmos_row_layout[-1][0].pins['in'],direction='x',endstyle0='extend',endstyle1='extend')

    # #m3_connect_out_left=laygen.route(xy0=[0,0],xy1=[0,0],gridname0=rg23, refobj0=inv_layout_p1[0].pins['out'], refobj1=inv_layout_n1[0].pins['out'], via0=[0,0],via1=[0,0],direction='y')

    

   #  #route
    # m2_pmos=laygen.route(xy0=[0,0],xy1=[4,0], gridname0=rg12, refobj0=inv_layout_p1[0].pins['out'], refobj1=inv_layout_p2[0].pins['out'],direction='x',endstyle0='extend',endstyle1='extend')

    # m2_nmos=laygen.route(xy0=[-1,0],xy1=[5,0],gridname0=rg12, refobj0=inv_layout_n1[0].pins['out'], refobj1=inv_layout_n1[0].pins['out'],direction='x',endstyle0='extend',endstyle1='extend')

    # m2_vdd=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg12, refobj0=inv_layout_p1[0].pins['VDD'], refobj1=inv_layout_p2[0].pins['VDD'],direction='x',endstyle0='extend',endstyle1='extend')

    # m2_vss=laygen.route(xy0=[-1,0],xy1=[5,0],gridname0=rg12, refobj0=inv_layout_n1[0].pins['VSS'], refobj1=inv_layout_n1[0].pins['VSS'],direction='x',endstyle0='extend',endstyle1='extend')
    
    # m3_left=laygen.route(xy0=[0,0],xy1=[0,0],gridname0=rg23, refobj0=inv_layout_p1[0].pins['out'], refobj1=inv_layout_n1[0].pins['out'], via0=[0,0],via1=[0,0],direction='y')

    # m3_right=laygen.route(xy0=[4,0],xy1=[4,0],gridname0=rg23, refobj0=inv_layout_p2[0].pins['out'], refobj1=inv_layout_n1[0].pins['out'],via0=[0,0],via1=[0,0],direction='y')
    
    # m1_left_top=laygen.route(xy0=[0,0],xy1=[0,0], gridname0=rg12, refobj0=guardring_n1[0].pins['nwell'], refobj1=inv_layout_p1[0].pins['VDD'],direction='y',via1=[0,0],endstyle0='extend',endstyle1='extend')

    # m1_right_top=laygen.route(xy0=[0,0],xy1=[4,0], gridname0=rg12, refobj0=guardring_n4[0].pins['nwell'], refobj1=inv_layout_p2[0].pins['VDD'],direction='y',via1=[0,0],endstyle0='extend',endstyle1='extend')
   
    # m1_left_btm=laygen.route(xy0=[0,0],xy1=[0,0], gridname0=rg12,  refobj0=inv_layout_n1[0].pins['VSS'],refobj1=guardring_p1[0].pins['psub'],direction='y',via0=[0,0],endstyle0='extend',endstyle1='extend')
    # m1_right_btm=laygen.route(xy0=[4,0], gridname0=rg12,  refobj0=inv_layout_n1[0].pins['VSS'],refobj1=guardring_p4[0].pins['psub'],direction='y',via0=[0,0],endstyle0='extend',endstyle1='extend')
   
    
    # nwell=laygen.route(xy0=[-1,2],xy1=[8,0],gridname0=rgnw, refobj0=guardring_n1[0].pins['nwell'], refobj1=inv_layout_p2[0].pins['out'])
    
    # m2_p_in=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg23, refobj0=inv_layout_p1[0].pins['in'], refobj1=inv_layout_p2[0].pins['in'],direction='x',endstyle0='extend',endstyle1='extend')

    # m2_n_in=laygen.route(xy0=[0,0],xy1=[4,0],gridname0=rg23, refobj0=inv_layout_n1[0].pins['in'], refobj1=inv_layout_n1[0].pins['in'],direction='x',endstyle0='extend',endstyle1='extend')

    # m3_in=laygen.route(xy0=[3,0],xy1=[2,0],gridname0=rg23, refobj0=inv_layout_p1[0].pins['in'], refobj1=inv_layout_n1[0].pins['in'],via0=[0,0],via1=[0,0],direction='y')

    #  #pin
    #  #vss=laygen.route(xy0=[0,-1],xy1=[1,-1],gridname0=rg12, refobj0=inv_layout_n1[0].pins['out'], direction='x')
  
    # vdd_pin=laygen.pin(name='VDD', xy0=[0,3],xy1=[1,3], layer=laygen.layers['pin'][2],gridname=rg12)  
    # vss_pin=laygen.pin(name='VSS', xy0=[0,-7],xy1=[1,-7], layer=laygen.layers['pin'][2],gridname=rg12)  
    #  #in_p_pin=laygen.pin(name='inp', xy0=[0,2],xy1=[1,2], layer=laygen.layers['pin'][2],gridname=rg12)  
    # in_n_pin=laygen.pin(name='in', xy0=[0,-5],xy1=[1,-5], layer=laygen.layers['pin'][2],gridname=rg12)  
    #  #out_p_pin=laygen.pin(name='outp', xy0=[0,0],xy1=[1,0], layer=laygen.layers['pin'][2],gridname=rg12)
    # out_n_pin=laygen.pin(name='out', xy0=[0,-6],xy1=[1,-6], layer=laygen.layers['pin'][2],gridname=rg12)



    laygen.display()
    # export
    import bag
    prj = bag.BagProject()
    #print('prj_xs',prj)
    laygen.export_BAG(prj)
    return input_list

if __name__ == '__main__':
    import math
    import laygo
    import numpy as np
    import sys
    from bisect import bisect_left 
   

    #fanout=sys.argv[2]
    #print(fanout)
    #number_stage=sys.argv[4]
    #seg_p=sys.argv[6]
    #seg_n=sys.argv[8]

	#current_list = INVERTER_layout_new(1.5704,6,75,36)
    #current_list = INVERTER_layout_new(2.114,4,50,24)   
    #INVERTER_layout_new(float(fanout),int(number_stage),int(seg_p),int(seg_n))
    current_list = INVERTER_layout_new(4.99,2,16,8)   
