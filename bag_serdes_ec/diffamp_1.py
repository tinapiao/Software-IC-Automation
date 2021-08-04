
from __future__ import (absolute_import, division,
                        print_function, unicode_literals)
# noinspection PyUnresolvedReferences,PyCompatibility
from builtins import *

import os
import pkg_resources
import math
from typing import Dict, Union, List, Tuple, Any

from bag.design import Module


yaml_file = pkg_resources.resource_filename(__name__, os.path.join('netlist_info', 'diffamp.yaml'))


# noinspection PyPep8Naming
class bag_serdes_ec__diffamp_1(Module):
    """Module for library bag_serdes_ec cell diffamp.

    A differential amplifier cell with many options used mainly for SERDES circuits
    """

    param_list = ['lch', 'w_dict', 'th_dict', 'seg_dict','N','fan_out']

    def __init__(self, bag_config, parent=None, prj=None, **kwargs):
        Module.__init__(self, bag_config, yaml_file, parent=parent, prj=prj, **kwargs)
        for par in self.param_list:
            self.parameters[par] = None

    def design(self,
               lch=16e-9,  # type: float
               w_dict=None,  # type: Dict[str, Union[float, int]]
               th_dict=None,  # type: Dict[str, str]
               seg_dict=None,  # type: Dict[str, int]
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

        fg = seg_dict['load']
        w = w_dict['load']
        th = th_dict['load']
        if N > 1:
         for e in self.instances:
           if e[:5] == 'XLOAD' and int(e[-1]) <= N:
               total_w = round_up_to_even(fg/pow(fan_out,(int(e[-1]))-1))
               width = str(0.0000002*total_w)
               self.instances[e].design(wf=width, l=lch, totalM=total_w, intent=th)
        self.instances['XLOADP1'].design(wf=w, l=lch, totalM=fg, intent=th)
        self.instances['XLOADN1'].design(wf=w, l=lch, totalM=fg, intent=th)  
     
################################TAIL########################################### 
        fg = seg_dict['tail']
        w = w_dict['tail']
        th = th_dict['tail']
        if N > 1:
         for e in self.instances:
            if e[:5] == 'XTAIL' and int(e[-1]) <= N:
               total_w = round_up_to_even(fg/pow(fan_out,(int(e[-1]))-1))
               width = str(0.0000002*total_w)
               self.instances[e].design(wf=width, l=lch, totalM=total_w, intent=th)

        self.instances['XTAIL1'].design(wf=w, l=lch, totalM=fg, intent=th)
        self.instances['XREF1'].design(wf=str(0.0000002*60), l=lch, totalM=60, intent=th)
###############################IN###############################################       
        fg = seg_dict['in']
        w = w_dict['in']
        th = th_dict['in']
        if N > 1 :
         for e in self.instances:
           if e[:3] == 'XIN' and int(e[-1]) <= N:
               total_w = round_up_to_even(fg/pow(fan_out,(int(e[-1]))-1))
               width = str(0.0000002*total_w)
               self.instances[e].design(wf=width, l=lch, totalM=total_w, intent=th)
        self.instances['XINN1'].design(wf=w, l=lch, totalM=fg, intent=th)
        self.instances['XINP1'].design(wf=w, l=lch, totalM=fg, intent=th)

###################################PIN CONNECTIONS#########################
        in_dname = 'in'
        self.reconnect_instance_terminal('XINP{}'.format(N), 'G', '%sp' % in_dname)
        self.reconnect_instance_terminal('XINN{}'.format(N), 'G', '%sm' % in_dname)

def round_up_to_even(f):
    return math.ceil(f / 2.) * 2

