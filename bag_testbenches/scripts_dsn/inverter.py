# -*- coding: utf-8 -*-

"""This script designs a simple diff amp with gain/bandwidth spec for BAG CICC paper."""

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
import sys
import configparser
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

def design_amp(amp_specs, Iteration):
    
    #add on one new input cin
    Rin = amp_specs['Input_Resistance_ohm']
    swing = amp_specs['swing_min_mV']
    #bw_min is signal frequency
    bw_min = amp_specs['bw_min_GHz']*pow(10,9)
    cload = amp_specs['cload_fF']* pow(10,-15)
    cin = amp_specs['cin_fF']* pow(10,-15)

# CHANGE: new fan_out from our calculation
    
    tau = 1/bw_min
    rout = tau/(cload*8)
    
    # if rout > Rin:
    #     raise ValueError('Signal can be passed safely without a INVERTER buffer')
    
    rout_p = rout*2
    rout_n = rout*2
    #finger_p = 100/(rout_p/102) #102 ohms for 100 fingers
    finger_p = 100/(rout_p/125)
    '''63ohms for 100finger'''
    seg_pmos1 = math.ceil(finger_p)  #totalM for PMOS
    finger_n=100/(rout_n/60)
    seg_nmos1 = math.ceil(finger_n) #totalM for NMOS
    
    #rout_real = (100/seg_load)*63
    #I_tail = (swing/rout_real)*pow(10,-3)*1.5
    #seg_tail = round_up_to_even((I_tail/(2*pow(10,-3)))*40*1.7)
    """Idc = 4mA"""
    #seg_in = round_up_to_even((2/(pow(rout_real,2)*I_tail*1.5*pow(10,-4)*(20/6))))
    Cn = (seg_nmos1+seg_pmos1) * (5/12)*pow(10,-15) #psh commented out due to not use anywhere in the function 
    R_n = tau/(Cn*8)
    
    
    #comment their cml fanout 
    # fan_out = R_n/rout_real
    fan_out = cload/Cn
  
    
    seg_pmos2=math.ceil(seg_pmos1/fan_out)
    seg_nmos2=math.ceil(seg_nmos1/fan_out)
    # fan_out=Cn/cin   #inital fanout
    if fan_out < 1:
        raise ValueError('User input is out of the range')
    # CHANGE: we use cload/cin
    #N = math.ceil(math.log(cload/Cn)/math.log(fan_out))
    N=2
    # N = math.ceil(math.log(Rin/rout)/math.log(fan_out))
    if Iteration > 0:
        N = round_up_to_even(N + Iteration)
        fan_out = math.exp(math.log(cload / cin) / N)
        
        # fan_out = math.exp(math.log(Rin/rout) / N)
    if fan_out < 1:
        N = 2
    if N >= 10:
        N = 8
        print('input is out of range, using maximum 9 stages')
        fan_out = math.exp(math.log(cload/cin)/9)
        #fan_out = math.exp(math.log(Rin/rout)/9)
    return dict(
        #seg_in=seg_in,
        #seg_load=seg_load,
        #seg_tail=seg_tail,
        seg_pmos1=seg_pmos1,
        seg_nmos1=seg_nmos1,

        seg_pmos2=seg_pmos2,
        seg_nmos2=seg_nmos2,
        N=N,
        fan_out=fan_out
    )

def round_up_to_even(f):
    return math.ceil(f / 2.) * 2

def design(amp_dsn_specs, amp_char_specs_fname, amp_char_specs_out_fname,N_iteration):
    nch_config = amp_dsn_specs['nch_config']
    pch_config = amp_dsn_specs['pch_config']

    print('create transistor database')
    nch_db = MOSDBDiscrete([nch_config])
    pch_db = MOSDBDiscrete([pch_config])

    nch_db.set_dsn_params(**amp_dsn_specs['nch'])
    pch_db.set_dsn_params(**amp_dsn_specs['pch'])

    result = design_amp(amp_dsn_specs, N_iteration)
    if result is None:
        raise ValueError('No solution.')
    pprint.pprint(result)
    # update characterization spec file
    amp_char_specs = read_yaml(amp_char_specs_fname)
    seg_dict = amp_char_specs['layout_params']['seg_dict1']
    seg_dict2= amp_char_specs['layout_params']['seg_dict2']
    #for key in ('in', 'load', 'tail'):
    for key in('pmos1','nmos1'):
        seg_dict[key] = result['seg_' + key]
    for key in('pmos2','nmos2'):
        seg_dict2[key] = result['seg_' + key]
    amp_char_specs['layout_params']['fan_out'] = result['fan_out']
    amp_char_specs['layout_params']['N'] = result['N']
    amp_char_specs['Testbench']['Rin'] = amp_dsn_specs['Input_Resistance_ohm']
    amp_char_specs['Testbench']['CL'] = amp_dsn_specs['cload_fF']*pow(10,-15)
    amp_char_specs['Testbench']['BW'] = amp_dsn_specs['bw_min_GHz']*pow(10,9)
    amp_char_specs['Testbench']['Vin'] = amp_dsn_specs['swing_min_mV']*pow(10,-3)
    #add on the new input cin
    amp_char_specs['Testbench']['Cin'] = amp_dsn_specs['cin_fF']*pow(10,-15)

    with open_file(amp_char_specs_out_fname, 'w') as f:
        yaml.dump(amp_char_specs, f)

    return result


def INVERTER_Create(prj, specs_fname):

    sim = DesignManager(prj, specs_fname)
    #Creat schematic and Layout
    sim.characterize_designs(generate=True, measure=True, load_from_file=False)
    # simulate and report result
    result_data,Swing,FT,RT = simulate_INVERTER(prj,specs_fname)
    # post-process simulation results
    BW = plot_data(result_data)

    return Swing,FT,RT,BW

def process_tb_tran(tb_results, plot=True):
    result_list = split_data_by_sweep(tb_results, ['vout_tran'])

    tvec = tb_results['time']
    plot_data_list = []
    for label, res_dict in result_list:
        cur_vout = res_dict['vout_tran']

        plot_data_list.append((label, cur_vout))

    if plot:
        plt.figure()
        plt.title('Vout vs Time')
        plt.ylabel('Vout (V)')
        plt.xlabel('Time (s)')

        for label, cur_vout in plot_data_list:
            if label:
                plt.plot(tvec, cur_vout, label=label)
            else:
                plt.plot(tvec, cur_vout)

        if len(result_list) > 1:
            plt.legend()


def split_data_by_sweep(results, var_list):
    sweep_names = results['sweep_params'][var_list[0]][:-1]
    combo_list = []
    for name in sweep_names:
        combo_list.append(range(results[name].size))

    if combo_list:
        idx_list_iter = product(*combo_list)
    else:
        idx_list_iter = [[]]

    ans_list = []
    for idx_list in idx_list_iter:
        cur_label_list = []
        for name, idx in zip(sweep_names, idx_list):
            swp_val = results[name][idx]
            if isinstance(swp_val, str):
                cur_label_list.append('%s=%s' % (name, swp_val))
            else:
                cur_label_list.append('%s=%.4g' % (name, swp_val))

        if cur_label_list:
            label = ', '.join(cur_label_list)
        else:
            label = ''

        cur_idx_list = list(idx_list)
        cur_idx_list.append(slice(None))

        cur_results = {var: results[var][cur_idx_list] for var in var_list}
        ans_list.append((label, cur_results))

    return ans_list
def process_tb_dc(tb_results, plot=True):
    result_list = split_data_by_sweep(tb_results, ['vin', 'vout'])

    plot_data_list = []
    for label, res_dict in result_list:
        cur_vin = res_dict['vin']
        cur_vout = res_dict['vout']

        cur_vin, vin_arg = np.unique(cur_vin, return_index=True)
        cur_vout = cur_vout[vin_arg]
        vout_fun = interp.InterpolatedUnivariateSpline(cur_vin, cur_vout)
        vout_diff_fun = vout_fun.derivative(1)

        print('%s, gain=%.4g' % (label, vout_diff_fun([0])))
        plot_data_list.append((label, cur_vin, cur_vout, vout_diff_fun(cur_vin)))

    if plot:
        f, (ax1, ax2) = plt.subplots(2, sharex='all')
        ax1.set_title('Vout vs Vin')
        ax1.set_ylabel('Vout (V)')
        ax2.set_title('Gain vs Vin')
        ax2.set_ylabel('Gain (V/V)')
        ax2.set_xlabel('Vin (V)')

        for label, vin, vout, vdiff in plot_data_list:
            if label:
                ax1.plot(cur_vin, cur_vout, label=label)
                ax2.plot(cur_vin, vout_diff_fun(cur_vin), label=label)
            else:
                ax1.plot(cur_vin, cur_vout)
                ax2.plot(cur_vin, vout_diff_fun(cur_vin))

        if len(result_list) > 1:
            ax1.legend()
            ax2.legend()


def process_tb_ac(tb_results, plot=True):
    result_list = split_data_by_sweep(tb_results, ['gain'])

    freq = tb_results['freq']
    log_freq = np.log10(freq)
    plot_data_list = []
    for label, res_dict in result_list:
        cur_vout = res_dict['gain']
        cur_mag = 20 * np.log10(np.abs(cur_vout))  # type: np.ndarray
        cur_ang = np.angle(cur_vout, deg=True)

        # interpolate log-log plot
        mag_fun = interp.InterpolatedUnivariateSpline(log_freq, cur_mag)
        ang_fun = interp.InterpolatedUnivariateSpline(log_freq, cur_ang)
        # find 3db and unity gain frequency
        dc_gain = cur_mag[0]
        lf0 = log_freq[0]
        lf1 = log_freq[-1]
        try:
            lf_3db = sciopt.brentq(lambda x: mag_fun(x) - (dc_gain - 3), lf0, lf1)  # type: float
            freq_3db = 10.0 ** lf_3db
        except ValueError:
            freq_3db = -1
        try:
            # noinspection PyTypeChecker
            lf_unity = sciopt.brentq(mag_fun, lf0, lf1)  # type: float
            freq_unity = 10.0 ** lf_unity
        except ValueError:
            lf_unity = 0
            freq_unity = -1

        # find phase margin
        if freq_unity > 0:
            # noinspection PyTypeChecker
            pm = 180 + ang_fun(lf_unity) - ang_fun(lf0)
        else:
            pm = 360

        print('%s, f_3db=%.4g, f_unity=%.4g, phase_margin=%.4g' % (label, freq_3db, freq_unity, pm))
        plot_data_list.append((label, cur_mag, cur_ang))

    if plot:
        f, (ax1, ax2) = plt.subplots(2, sharex='all')
        ax1.set_title('Magnitude vs Frequency')
        ax1.set_ylabel('Magnitude (dB)')
        ax2.set_title('Phase vs Frequency')
        ax2.set_ylabel('Phase (Degrees)')
        ax2.set_xlabel('Frequency (Hz)')

        for label, cur_mag, cur_ang in plot_data_list:
            if label:
                ax1.semilogx(freq, cur_mag, label=label)
                ax2.semilogx(freq, cur_ang, label=label)
            else:
                ax1.semilogx(freq, cur_mag)
                ax2.semilogx(freq, cur_ang)

        if len(result_list) > 1:
            ax1.legend()
            ax2.legend()
    return freq_3db

def plot_data(results_dict, plot=True):
    #process_tb_dc(results_dict, plot=plot)
    BW = process_tb_ac(results_dict, plot=plot)
    process_tb_tran(results_dict, plot=plot)

    if plot:
        plt.show()

    return BW
def simulate_INVERTER(prj,specs):
    view_name = 'schematic'  #specs['view_name']
    sim_envs = ['tt']             #specs['sim_envs']
    Outspecs = read_yaml(specs)
    tb_params = Outspecs['Testbench']
    data_dir = 'demo_data'
    impl_lib = 'AN_INVERTER_496'
    gen_cell = 'INVERTER_lch_60n'
    tb_gen_cell = 'INVERTER_tb'
    results_dict = {}
        # setup testbench ADEXL state
    print('setting up testbench')
    tb = prj.configure_testbench('AN_INVERTER_496', 'INVERTER_tb')
        # set testbench parameters values
    for key, val in tb_params.items():
        tb.set_parameter(key, val)
        # commit changes to ADEXL state back to database
    tb.set_simulation_view(impl_lib, gen_cell, view_name)
        # set process corners
    tb.set_simulation_environments(sim_envs)
    tb.update_testbench()
    print('running simulation')
    tb.run_simulation()
        # import simulation results to Python
    print('simulation done, load results')
    results = load_sim_results(tb.save_dir)
    #below result file is to see FT,RT AND SWING of the adexl file
    with open('result_0109_psh.txt',"w") as f:
        f.write(str(results))
    
    #print('inverter.py.results_xs',results)
        # save simulation data as HDF5 format
    save_sim_results(results, os.path.join(data_dir, '%s.hdf5' % tb_gen_cell))
    fname = 'demo_data/INVERTER_tb.hdf5'
    print('loading simulation data for %s' % tb_gen_cell)
    results_data = load_sim_file(fname)
    print('finish loading data')
    print('all simulation done')
    Swing, FT, RT = print_sim_datas(fname)
    return results_data, Swing, FT, RT


def print_sim_datas(fname):
    """Read simulation results from HDF5 file.

    Parameters
    ----------
    fname : str
        the file to read.

    Returns
    -------
    results : dict[str, any]
        the result dictionary.
    """
    if not os.path.isfile(fname):
        raise ValueError('%s is not a file.' % fname)

    Swing = 0
    with h5py.File(fname, 'r') as f:
        #print(list(f.keys()))
        for name in f:
            dset = f[name]
            dset_data = dset[()]
            #print('dset_data_xs',dset_data)
            if name == 'FallTime' :
                print('FallTime:', dset_data)
                FT = dset_data
            if name == 'RiseTime' :
                print('RiseTime:', dset_data)
                RT = dset_data
            if name == 'Vout_Swing_PP' :
                print('Output Swing:', dset_data)
                Swing = dset_data

    return Swing, FT, RT


def load_sim_data(specs, dsn_name):
    dsn_specs = specs[dsn_name]
    data_dir = dsn_specs['data_dir']
    gen_cell = dsn_specs['gen_cell']
    testbenches = dsn_specs['testbenches']

    results_dict = {}
    for name, info in testbenches.items():
        tb_gen_cell = '%s_%s' % (gen_cell, name)
        fname = os.path.join(data_dir, '%s.hdf5' % tb_gen_cell)
        print('loading simulation data for %s' % tb_gen_cell)
        results_dict[name] = load_sim_file(fname)

    print('finish loading data')
def run_main(prj):
    #add-on cin_fF in user_input.yaml
    amp_dsn_specs_fname = 'INVERTER_design_files/user_input.yaml'
    amp_char_specs_fname = 'INVERTER_design_files/INVERTER_char.yaml'
    amp_char_specs_out_fname = 'INVERTER_design_files/INVERTER_mod.yaml'
    amp_dsn_specs = read_yaml(amp_dsn_specs_fname)
    
    #add one line for cin_fF

    commands=str(sys.argv)
    #config option
    if len(sys.argv)>1:
        if '-h' in commands:
            print("\n-help   displays the usage of this script\n \n-config  displays the config option for users to fill in the required input parameters in a config file under the same directory as the script prior to running the script  \n\nCommand: python inverter_main.py -h -config <config file name.ini>\n\nIf no options are entered, the script will ask the user for inputs during execution.")

            print("\nBelow is the required format for the config file\n")
            print('[Inverter Input Parameters]\nR_in_ohms=<input>\nC_load_fF=<input>\nswing_min_mV=<input>\nbw_min_mV=<input>\nC_in_fF=<input>')
            sys.exit()

        if '-config' in commands:
            config = configparser.ConfigParser()
            config.read(sys.argv[2])

            input_list=config['Inverter Input Parameters']
            
            amp_dsn_specs['Input_Resistance_ohm']=float(input_list['R_in_ohms'])
            amp_dsn_specs['cload_fF'] = float(input_list['C_load_fF']) 
            amp_dsn_specs['swing_min_mV'] = float(input_list['swing_min_mV'])
            amp_dsn_specs['bw_min_GHz'] = float(input_list['bw_min_GHz'])
            amp_dsn_specs['cin_fF'] = float(input_list['C_in_fF'])	

    #not config option         
    else:
        amp_dsn_specs['Input_Resistance_ohm'] = float(input("Enter Input Resistance in Ohms: "))
        amp_dsn_specs['cload_fF'] = float(input("Enter Load Capacitance in fF: "))
        amp_dsn_specs['swing_min_mV'] = float(input("Enter clock signal peak to peak swing in mV: "))
        amp_dsn_specs['bw_min_GHz'] = float(input("Enter clock signal bandwidth in GHz: "))
        amp_dsn_specs['cin_fF'] = float(input("Enter Input Capacitance in fF: "))

    with open_file(amp_dsn_specs_fname, 'w') as f:
        yaml.dump(amp_dsn_specs, f)

    Input_Swing = amp_dsn_specs['swing_min_mV']* pow(10,-3)
    result = None
    done = False
    N = int(0)
    while not done:
        result = design(amp_dsn_specs, amp_char_specs_fname, amp_char_specs_out_fname,N)
        Swing, FT, RT, BW = INVERTER_Create(prj, amp_char_specs_out_fname)
        N = N + 2
        fan_out = result['fan_out']
        N_Stage = result['N']
        #seg_in = result['seg_in']
        #seg_load = result['seg_load']
        #seg_tail = result['seg_tail']
        seg_pmos1 = result['seg_pmos1']
        seg_nmos1 = result['seg_nmos1']
        #print('iteration_time_xs', N)


        if Swing > Input_Swing*0.90:
            print("INVERTER Schematic Passed. Now Creating INVERTER Layout")
            print("Fanout", fan_out)
            print("Number of Stages", N_Stage)
            print("PMOS fingers",seg_pmos1)
            print("NMOS fingers",seg_nmos1)
            INVERTER_layout_new(fan_out, N_Stage, seg_pmos1, seg_nmos1)
            print("Layout is done")
            print("All designs are done, Used total", N, "iteraion(s)")
            print("Here is the final report:")
            print('FallTime:', FT,"s")
            print('RiseTime:', RT, "s")
            print('3dB_Bandwidth', BW/pow(10,9), "GHz")
            print('Output Swing:', Swing, "V")
            return
        if N_Stage == 9:
            print('User Input is out of range, Requirements can not be met,')
            print("The best possible INVERTER schematic has been created, Now Creating INVERTER Layout")
            print("Fanout", fan_out)
            print("Number of Stages", N_Stage)
            print("PMOS fingers",seg_pmos1)
            print("NMOS fingers",seg_nmos1)
            INVERTER_layout_new(fan_out, N_Stage, seg_pmos1, seg_nmos1)
            print("Layout is done")
            print("All designs are done")
            print("Here is the final report:")
            print('User Input is out of range, Requirements can not be met. The best possible INVERTER designs have been created')
            print('FallTime:', FT,"s")
            print('RiseTime:', RT, "s")
            print('3dB_Bandwidth', BW/pow(10,9), "GHz")
            print('Output Swing:', Swing, "V")
            return
        if N == 1:
            print(N,"iteration is not enough, start the 2nd iteration")
        if N == 2:
            print(N, "iteration is not enough, start the 3rd iteration")
        if N > 2:
            print(N, "iteration is not enough, start the", N+1, "th iteration")



if __name__ == '__main__':
    local_dict = locals()
    if 'bprj' not in local_dict:
        print('creating BAG project')
        bprj = BagProject()

    else:
        print('loading BAG project')
        bprj = local_dict['bprj']

    run_main(bprj)

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

      #pmos finger placment even case
    #print('pmos_num_eachfan:',pmos_num_eachfan)
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
            #print('pmos_row_layout_tot:',pmos_row_layout_tot)

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


     #nmos finger placment even case
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
            #print('nmos_row_layout_tot:',nmos_row_layout_tot)

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

        m2_n_out_list[index]=laygen.route(xy0=[0,0],xy1=[int(2*(len(pmos_row_layout_tot[index])-len(each_stage)))+7,0],gridname0=rg23, refobj0=each_stage[0][0].pins['out'], refobj1=each_stage[-1][0].pins['out'],direction='x', endstyle0='extend',endstyle1='extend')

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
    


    laygen.display()
    # export
    import bag
    prj = bag.BagProject()
    laygen.export_BAG(prj)
    return input_list


def simulate_SCH(prj, specs, dsn_name):
        view_name = specs['view_name']
        sim_envs = specs['sim_envs']
        dsn_specs = specs[dsn_name]

        data_dir = dsn_specs['data_dir']
        impl_lib = dsn_specs['impl_lib']
        gen_cell = dsn_specs['gen_cell']
        testbenches = dsn_specs['testbenches']

        results_dict = {}
        for name, info in testbenches.items():
            tb_params = info['tb_params']
            tb_gen_cell = '%s_%s' % (gen_cell, name)

            # setup testbench ADEXL state
            print('setting up %s' % tb_gen_cell)
            tb = prj.configure_testbench(impl_lib, tb_gen_cell)
            # set testbench parameters values
            for key, val in tb_params.items():
                tb.set_parameter(key, val)
            # set config view, i.e. schematic vs extracted
            tb.set_simulation_view(impl_lib, gen_cell, view_name)
            # set process corners
            tb.set_simulation_environments(sim_envs)
            # commit changes to ADEXL state back to database
            tb.update_testbench()
            # start simulation
            print('running simulation')
            tb.run_simulation()
            # import simulation results to Python
            print('simulation done, load results')
            results = load_sim_results(tb.save_dir)
            # save simulation data as HDF5 format
            save_sim_results(results, os.path.join(data_dir, '%s.hdf5' % tb_gen_cell))

            results_dict[name] = results

            print('all simulation done')

            return results_dict
