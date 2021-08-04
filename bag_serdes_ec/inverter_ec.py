
from __future__ import (absolute_import, division,
                        print_function, unicode_literals)
# noinspection PyUnresolvedReferences,PyCompatibility
from builtins import *

import os
import pkg_resources
import math
from typing import Dict, Union, List, Tuple, Any

from bag.design import Module


yaml_file = pkg_resources.resource_filename(__name__, os.path.join('netlist_info', 'inverter_ec.yaml'))
#change from inverter.yaml to inverter_ec.yaml

# noinspection PyPep8Naming
class bag_serdes_ec__inverter_ec(Module):
    """Module for library bag_serdes_ec cell inverter.

    A differential amplifier cell with many options used mainly for SERDES circuits
    """

    param_list = ['lch', 'w_dict1', 'w_dict2','th_dict', 'seg_dict1','seg_dict2','N','fan_out']

    def __init__(self, bag_config, parent=None, prj=None, **kwargs):
        Module.__init__(self, bag_config, yaml_file, parent=parent, prj=prj, **kwargs)
        for par in self.param_list:
            self.parameters[par] = None

    def design(self,
               lch=16e-9,  # type: float
               w_dict1=None,  # type: Dict[str, Union[float, int]]
               w_dict2=None,
               th_dict=None,  # type: Dict[str, str]
               seg_dict1=None,  # type: Dict[str, int]
               seg_dict2=None,
               #dum_info=None,  # type: List[Tuple[Any]]
               N = 1,
               fan_out = 1
               ):
        # type: (...) -> None

        local_dict = locals()
        for name in self.param_list:
            if name not in local_dict:
                raise ValueError('Parameter %s not specified.' % name)
            self.parameters[name] = local_dict[name]
        if N > 10:
           N = 10
        N = int(N)
        self.delete_instance_chain(N)
#################################LOAD#################################  
 
                ###########odd case###############
        fg = seg_dict1['pmos1']
        w = w_dict1['pmos1']
        th = th_dict['pmos']
        if N > 1:
         for e in self.instances:
           if e[:5] == 'XLOAD' and int(e[-1]) <= N and int(e[-1])%2==1:
               total_w = math.ceil(fg/pow(fan_out,(int(e[-1]))-1))
               width = str(0.0000002*total_w)
               self.instances[e].design(wf=width, l=lch, fingers=total_w, totalM=total_w, intent=th)  #totalM changed to nf
        #self.instances['XLOADP1'].design(wf=w, l=lch, totalM=fg, intent=th)
        if N==1:
            self.instances['XLOADN1'].design(wf=w, l=lch, fingers=fg, totalM=fg, intent=th)   #totalM changed to nf

                ###########even case###############
        fg1 = seg_dict2['pmos2']
        w = w_dict2['pmos2']
        th = th_dict['pmos']
        if N > 2:
         for e in self.instances:
           if e[:5] == 'XLOAD' and int(e[-1]) <= N and int(e[-1])%2==0:
               total_w = math.ceil(fg/pow(fan_out,(int(e[-1]))-1))
               width = str(0.0000002*total_w)
               self.instances[e].design(wf=width, l=lch, fingers=total_w, totalM=total_w, intent=th)  #totalM changed to nf
        #self.instances['XLOADP1'].design(wf=w, l=lch, totalM=fg, intent=th)
        if N==2:
            self.instances['XLOADN2'].design(wf=w, l=lch, fingers=fg1, totalM=fg1, intent=th)   #totalM changed to nf
     
################################TAIL########################################### 
        # fg = seg_dict['tail']
        # w = w_dict['tail']
        # th = th_dict['tail']
        # if N > 1:
        #  for e in self.instances:
        #     if e[:5] == 'XTAIL' and int(e[-1]) <= N:
        #        total_w = round_up_to_even(fg/pow(fan_out,(int(e[-1]))-1))
        #        width = str(0.0000002*total_w)
        #        self.instances[e].design(wf=width, l=lch, totalM=total_w, intent=th)

        # self.instances['XTAIL1'].design(wf=w, l=lch, totalM=fg, intent=th)
        # self.instances['XREF1'].design(wf=str(0.0000002*60), l=lch, totalM=60, intent=th)
###############################IN###############################################       
 
                ###########odd case###############
        fg = seg_dict1['nmos1']
        w = w_dict1['nmos1']
        th = th_dict['nmos']
        if N > 1 :
         for e in self.instances:
           if e[:3] == 'XIN' and int(e[-1]) <= N and int(e[-1])%2==1:
               total_w = math.ceil(fg/pow(fan_out,(int(e[-1]))-1))
               width = str(0.0000002*total_w)
               self.instances[e].design(wf=width, l=lch, fingers=total_w, totalM=total_w, intent=th)
        #self.instances['XINN1'].design(wf=w, l=lch, nf=fg, intent=th)
        if N==1:
            self.instances['XINP1'].design(wf=w, l=lch, fingers=fg, totalM=fg, intent=th)
                ###########odd case###############
        fg1 = seg_dict2['nmos2']
        w = w_dict2['nmos2']
        th = th_dict['nmos']
        if N > 2 :
         for e in self.instances:
           if e[:3] == 'XIN' and int(e[-1]) <= N and int(e[-1])%2==0:
               total_w = math.ceil(fg/pow(fan_out,(int(e[-1]))-1))
               width = str(0.0000002*total_w)
               self.instances[e].design(wf=width, l=lch, fingers=total_w, totalM=total_w, intent=th)
        #self.instances['XINN1'].design(wf=w, l=lch, nf=fg, intent=th)
        if N==2:
            self.instances['XINP2'].design(wf=w, l=lch, fingers=fg1, totalM=fg1,intent=th)
###################################PIN CONNECTIONS#########################
        in_dname = 'in'
        #self.reconnect_instance_terminal('XINP{}'.format(N), 'G', '%sp' % in_dname)
        #self.reconnect_instance_terminal('XLOADN{}'.format(N), 'G', '%sm' % in_dname)
        self.reconnect_instance_terminal('XINP{}'.format(N), 'G', '%s' % in_dname)
        self.reconnect_instance_terminal('XLOADN{}'.format(N), 'G', '%s' % in_dname)
def round_up_to_even(f):
    return math.ceil(f / 2.) * 2

