# -*- coding: utf-8 -*-

import pprint

import bag
import numpy as np
import yaml

lib_name = 'adc_sar_templates'
cell_name = 'sar_doubleSA_bb'
impl_lib = 'adc_sar_generated'

params = dict(
    lch=16e-9,
    pw=4,
    nw=4,
    sa_m=8,
    sa_m_rst=4,
    sa_m_rgnn=4,
    sa_m_buf=8,
    drv_m_list=[2,2,2,2,2,2,4,8],
    ckgen_m=2, 
    ckgen_fo=2, 
    ckgen_ndelay=1, 
    ckgen_fast=True, 
    logic_m=1, 
    num_inv_bb=1, 
    fsm_m=1, 
    ret_m=2, 
    ret_fo=2, 
    device_intent='fast',
    c_m=1,
    rdx_array=[1,2,4,8,16,32,64,128],
    num_bits=9,
    )
load_from_file=True
yamlfile_spec="adc_sar_spec.yaml"
yamlfile_size="adc_sar_size.yaml"
if load_from_file==True:
    with open(yamlfile_spec, 'r') as stream:
        specdict = yaml.load(stream)
    with open(yamlfile_size, 'r') as stream:
        sizedict = yaml.load(stream)
    #params['sa_m']=sizedict['salatch_m']
    #params['sa_m_rst']=sizedict['salatch_m_rst']
    #params['sa_m_rgnn']=sizedict['salatch_m_rgnn']
    #params['sa_m_buf']=sizedict['salatch_m_buf']
    params['sa_m']=sizedict['salatch']['m']
    params['sa_m_d']=sizedict['salatch']['m_d']
    params['sa_m_rst']=sizedict['salatch']['m_rst']
    params['sa_m_rst_d']=sizedict['salatch']['m_rst_d']
    params['sa_m_rgnn']=sizedict['salatch']['m_rgnn']
    params['sa_m_rgnp_d']=sizedict['salatch']['m_rgnp_d']
    params['sa_m_buf']=sizedict['salatch']['m_buf']
    params['doubleSA']=sizedict['salatch']['doubleSA']
    params['vref_sf_m_mirror'] = sizedict['sourceFollower_vref']['m_mirror']
    params['vref_sf_m_bias'] = sizedict['sourceFollower_vref']['m_bias']
    params['vref_sf_m_off'] = sizedict['sourceFollower_vref']['m_off']
    params['vref_sf_m_in'] = sizedict['sourceFollower_vref']['m_in']
    params['vref_sf_m_bias_dum'] = sizedict['sourceFollower_vref']['m_bias_dum']
    params['vref_sf_m_in_dum'] = sizedict['sourceFollower_vref']['m_in_dum']
    params['vref_sf_m_byp'] = sizedict['sourceFollower_vref']['m_byp']
    params['vref_sf_m_byp_bias'] = sizedict['sourceFollower_vref']['m_byp_bias']
    params['vref_sf_bias_current'] = sizedict['sourceFollower_vref']['bias_current']
    params['vref_sf']=specdict['use_vref_sf']
    params['drv_m_list']=sizedict['capdrv']['m_list']
    params['logic_m']=sizedict['sarlogic']['m']
    params['num_inv_bb']=sizedict['sarlogic']['num_inv_bb']
    params['fsm_m']=sizedict['sarfsm']['m']
    params['ret_m']=sizedict['sarret']['m']
    params['ret_fo']=sizedict['sarret']['fo']
    params['ckgen_m']=sizedict['sarclkgen']['m']
    params['ckgen_fo']=sizedict['sarclkgen']['fo']
    params['ckgen_ndelay']=sizedict['sarclkgen']['ndelay']
    params['ckgen_fast']=sizedict['sarclkgen']['fast']
    params['ckgen_fastest']=sizedict['sarclkgen']['fastest']
    params['c_m']=sizedict['capdac']['c_m']
    params['rdx_array']=specdict['rdx_array']
    params['num_bits']=specdict['n_bit']
    params['lch']=sizedict['lch']
    params['pw']=sizedict['pw']
    params['nw']=sizedict['nw']
    params['device_intent']=sizedict['device_intent']

print('creating BAG project')
prj = bag.BagProject()

# create design module and run design method.
print('designing module')
dsn = prj.create_design_module(lib_name, cell_name)
print('design parameters:\n%s' % pprint.pformat(params))
dsn.design(**params)

# implement the design
print('implementing design with library %s' % impl_lib)
dsn.implement_design(impl_lib, top_cell_name=cell_name, erase=True)

