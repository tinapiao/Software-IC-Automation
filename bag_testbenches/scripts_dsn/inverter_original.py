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

    Rin = amp_specs['Input_Resistance_ohm']
    swing = amp_specs['swing_min_mV']
    #bw_min is signal frequency
    bw_min = amp_specs['bw_min_GHz']*pow(10,9)
    cload = amp_specs['cload_fF']* pow(10,-15)

    tau = 1/bw_min
    rout = tau/(cload*8)
    if rout > Rin:
        raise ValueError('Signal can be passed safely without a INVERTER buffer')

    finger_load = 100/(rout/63)
    '''63ohms for 100finger'''
    seg_load = round_up_to_even(finger_load)
    rout_real = (100/seg_load)*63
    I_tail = (swing/rout_real)*pow(10,-3)*1.5
    seg_tail = round_up_to_even((I_tail/(2*pow(10,-3)))*40*1.7)
    """Idc = 4mA"""
    seg_in = round_up_to_even((2/(pow(rout_real,2)*I_tail*1.5*pow(10,-4)*(20/6))))
    Cn = seg_in * (1/3)*pow(10,-15)
    R_n = tau/(Cn*8)
    fan_out = R_n/rout_real
    if fan_out < 1:
        raise ValueError('User input is out of the range')
    N = math.ceil(math.log(Rin/rout_real)/math.log(fan_out))
    if Iteration > 0:
        N = N + Iteration
        fan_out = math.exp(math.log(Rin / rout_real) / N)
    if fan_out < 1:
        N = 1
    if N > 10:
        N = 9
        print('input is out of range, using maximum 9 stages')
        fan_out = math.exp(math.log(Rin/rout_real)/9)
    return dict(
        seg_in=seg_in,
        seg_load=seg_load,
        seg_tail=seg_tail,
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
    seg_dict = amp_char_specs['layout_params']['seg_dict']
    for key in ('in', 'load', 'tail'):
        seg_dict[key] = result['seg_' + key]
    amp_char_specs['layout_params']['fan_out'] = result['fan_out']
    amp_char_specs['layout_params']['N'] = result['N']
    amp_char_specs['Testbench']['Rin'] = amp_dsn_specs['Input_Resistance_ohm']
    amp_char_specs['Testbench']['CL'] = amp_dsn_specs['cload_fF']*pow(10,-15)
    amp_char_specs['Testbench']['BW'] = amp_dsn_specs['bw_min_GHz']*pow(10,9)
    amp_char_specs['Testbench']['Vin'] = amp_dsn_specs['swing_min_mV']*pow(10,-3)

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
        print(list(f.keys()))
        for name in f:
            dset = f[name]
            dset_data = dset[()]
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
    amp_dsn_specs_fname = 'INVERTER_design_files/user_input.yaml'
    amp_char_specs_fname = 'INVERTER_design_files/INVERTER_char.yaml'
    amp_char_specs_out_fname = 'INVERTER_design_files/INVERTER_mod.yaml'
    amp_dsn_specs = read_yaml(amp_dsn_specs_fname)

    amp_dsn_specs['Input_Resistance_ohm'] = float(input("Enter Input Resistance in Ohms: "))
    amp_dsn_specs['cload_fF'] = float(input("Enter Load Capacitance in fF: "))
    amp_dsn_specs['swing_min_mV'] = float(input("Enter clock signal peak to peak swing in mV: "))
    amp_dsn_specs['bw_min_GHz'] = float(input("Enter clock signal bandwidth in GHz: "))

    with open_file(amp_dsn_specs_fname, 'w') as f:
        yaml.dump(amp_dsn_specs, f)

    Input_Swing = amp_dsn_specs['swing_min_mV']* pow(10,-3)
    result = None
    done = False
    N = int(0)
    while not done:
        result = design(amp_dsn_specs, amp_char_specs_fname, amp_char_specs_out_fname,N)
        Swing, FT, RT, BW = INVERTER_Create(prj, amp_char_specs_out_fname)
        N = N + 1
        fan_out = result['fan_out']
        N_Stage = result['N']
        seg_in = result['seg_in']
        seg_load = result['seg_load']
        seg_tail = result['seg_tail']


        if Swing > Input_Swing*0.9:
            print("INVERTER Schematic Passed. Now Creating INVERTER Layout")
            print("FANOUT_XS", fan_out)
            print("nstage_XS", N_Stage)
            print("segin_XS", seg_in)
            print("segload_XS", seg_load)
            print("segtail_XS", seg_tail)
            INVERTER_layout_new(fan_out, N_Stage, seg_load, seg_in, seg_tail, 60)
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
            print("FANOUT_XS", fan_out)
            print("nstage_XS", N_Stage)
            print("segin_XS", seg_in)
            print("segload_XS", seg_load)
            print("segtail_XS", seg_tail)
            INVERTER_layout_new(fan_out, N_Stage, seg_load, seg_in, seg_tail, 60)
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


def INVERTER_layout_new(fan_factor, number_fan, number_finger_al, number_finger, number_finger_cm, number_finger_cm_ref):
    # initialize
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
    input_list.append(number_finger)
    input_list.append(number_finger_al)
    input_list.append(number_finger_cm)

    # library & cell creation
    laygen.add_library('AN_INVERTER_496')
    laygen.add_cell('INVERTER_lch_60n')

    # grid variables
    pb = 'placement_basic'
    rg12 = 'route_M1_M2_cmos'
    rg23 = 'route_M2_M3_cmos'
    rg34 = 'route_M3_M4_cmos'
    rgnw = 'route_nwell'

    # index_fan: end of current mirror of each group
    # index_fan_1: end of half group diff pair
    # index_dp: beginning of half group diff pair
    # index_al: beginning of half group active load
    # index_cm: beginning of current mirror of each group
    cm_num_eachfan = ['' for i in range(number_fan)]
    cm_index_first_eachfan = ['' for i in range(number_fan)]
    cm_num_tot = 0
    for i in range(number_fan):
        if (i == 0):
            cm_num_eachfan[i] = int(number_finger_cm / 2)
        else:
            cm_num_eachfan[i] = int(round_up_to_even(number_finger_cm / (fan_factor ** i)) / 2)
        cm_num_tot = cm_num_tot + cm_num_eachfan[i]
    cm_num_eachfan.sort()
    for i in range(number_fan):
        if (i == 0):
            cm_index_first_eachfan[i] = 0
        else:
            cm_index_first_eachfan[i] = cm_index_first_eachfan[i - 1] + cm_num_eachfan[i - 1]

    dp_num_half_fan = ['' for i in range(number_fan * 2)]
    dp_index_first_half_fan = ['' for i in range(number_fan * 2)]
    dp_index_first_half_fan_odd = ['' for i in range(number_fan)]
    dp_index_first_half_fan_even = ['' for i in range(number_fan)]
    dp_index_end_half_fan = ['' for i in range(number_fan * 2)]
    dp_num_tot = 0
    for i in range(number_fan):
        if (i == 0):
            dp_num_half_fan[i] = int(number_finger / 2)
            dp_num_half_fan[i + 1] = int(number_finger / 2)
        else:
            dp_num_half_fan[2 * i] = int(round_up_to_even(number_finger / (fan_factor ** i)) / 2)
            dp_num_half_fan[2 * i + 1] = int(round_up_to_even(number_finger / (fan_factor ** i)) / 2)
        dp_num_tot = dp_num_tot + dp_num_half_fan[2 * i] + dp_num_half_fan[2 * i + 1]
    dp_num_half_fan.sort()
    for i in range(number_fan * 2):
        if (i == 0):
            dp_index_first_half_fan[i] = 0
            dp_index_end_half_fan[i] = dp_num_half_fan[i] - 1
        else:
            dp_index_first_half_fan[i] = dp_index_first_half_fan[i - 1] + dp_num_half_fan[i - 1]
            dp_index_end_half_fan[i] = dp_index_end_half_fan[i - 1] + dp_num_half_fan[i]
    for i in range(number_fan):
        dp_index_first_half_fan_odd[i] = dp_index_first_half_fan[2 * i]
        dp_index_first_half_fan_even[i] = dp_index_first_half_fan[2 * i + 1]

    al_num_half_fan = ['' for i in range(number_fan * 2)]
    al_index_first_half_fan = ['' for i in range(number_fan * 2)]
    al_index_end_half_fan = ['' for i in range(number_fan * 2)]
    al_index_first_half_fan_odd = ['' for i in range(number_fan)]
    al_index_first_half_fan_even = ['' for i in range(number_fan)]
    al_num_tot = 0
    for i in range(number_fan):
        if (i == 0):
            al_num_half_fan[i] = int(number_finger_al / 2)
            al_num_half_fan[i + 1] = int(number_finger_al / 2)
        else:
            al_num_half_fan[2 * i] = int(round_up_to_even(number_finger_al / (fan_factor ** i)) / 2)
            al_num_half_fan[2 * i + 1] = int(round_up_to_even(number_finger_al / (fan_factor ** i)) / 2)
        al_num_tot = al_num_tot + al_num_half_fan[2 * i] + al_num_half_fan[2 * i + 1]
    al_num_half_fan.sort()
    for i in range(number_fan * 2):
        if (i == 0):
            al_index_first_half_fan[i] = 0
            al_index_end_half_fan[i] = al_num_half_fan[i] - 1
        else:
            al_index_first_half_fan[i] = al_index_first_half_fan[i - 1] + al_num_half_fan[i - 1]
            al_index_end_half_fan[i] = al_index_end_half_fan[i - 1] + al_num_half_fan[i]
    for i in range(number_fan):
        al_index_first_half_fan_odd[i] = al_index_first_half_fan[2 * i]
        al_index_first_half_fan_even[i] = al_index_first_half_fan[2 * i + 1]

    # placements parameters
    al_row_layout = ['' for i in range(al_num_tot)]
    dp_row_layout = ['' for i in range(dp_num_tot)]
    cm_ref_layout = ['' for i in range(int(number_finger_cm_ref / 2))]
    cm_row_layout = ['' for i in range(cm_num_tot)]
    max_finger = max(al_num_tot, dp_num_tot, cm_num_tot)
    guardring_n = ['' for i in range(max_finger + int(number_finger_cm_ref * 0.5) + number_fan * 4)]
    guardring_p = ['' for i in range(max_finger + int(number_finger_cm_ref * 0.5) + number_fan * 4)]

    # placements
    # always place reference current mirror first
    for i in range(int(number_finger_cm_ref / 2)):
        if (i == 0):
            cm_ref_layout[0] = laygen.relplace(templatename=['currentmirror_ref_n'], gridname=pb, xy=[-2, 0],
                                               direction='left')
        else:
            cm_ref_layout[i] = laygen.relplace(templatename=['currentmirror_ref_n'], gridname=pb,
                                               refobj=cm_ref_layout[i - 1], direction='left')

    # if finger number of current mirror is the greatest
    if (number_finger_cm >= 2 * number_finger and number_finger_cm >= 2 * number_finger_al):
        # current mirror placement
        flag1 = 0
        for i in range(int(cm_num_tot)):
            if (i == 0):
                cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_ref_layout[0], xy=[2, 0], direction='right')
            elif (i in cm_index_first_eachfan):
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], xy=[8, 0], direction='right')
                flag1 = flag1 + 1
            else:
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], direction='right')

        # if number_finger >= number_finger_al
        if (number_finger >= number_finger_al):
            # diff pair placement
            flag2 = 0
            for i in range(dp_num_tot):
                if (i in dp_index_first_half_fan_odd):
                    dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                       refobj=cm_row_layout[cm_index_first_eachfan[flag2]],
                                                       direction='top')
                    flag2 = flag2 + 1
                elif (i in dp_index_first_half_fan_even):
                    dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                       refobj=dp_row_layout[i - 1], xy=[2, 0], direction='right')
                else:
                    dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                       refobj=dp_row_layout[i - 1], direction='right')

            # active load placement
            flag3 = 0
            for i in range(al_num_tot):
                if (i in al_index_first_half_fan):
                    al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                       refobj=dp_row_layout[dp_index_first_half_fan[flag3]],
                                                       direction='top')
                    flag3 = flag3 + 1
                else:
                    al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                       refobj=al_row_layout[i - 1], direction='right')

        # if number_finger < number_finger_al
        else:
            # active load placement
            flag3 = 0
            for i in range(al_num_tot):
                if (i in al_index_first_half_fan_odd):
                    al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                       refobj=cm_row_layout[cm_index_first_eachfan[flag3]], xy=[0, 1],
                                                       direction='top')
                    flag3 = flag3 + 1
                elif (i in al_index_first_half_fan_even):
                    al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                       refobj=al_row_layout[i - 1], xy=[2, 0], direction='right')
                else:
                    al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                       refobj=al_row_layout[i - 1], direction='right')
            # diff pair placement
            flag2 = 0
            for i in range(dp_num_tot):
                if (i in dp_index_first_half_fan):
                    dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                       refobj=al_row_layout[al_index_first_half_fan[flag2]],
                                                       direction='bottom')
                    flag2 = flag2 + 1
                else:
                    dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                       refobj=dp_row_layout[i - 1], direction='right')



    # if finger number of diff pair is the greatest
    elif (2 * number_finger >= number_finger_cm and number_finger >= number_finger_al):
        # diff pair placement
        for i in range(dp_num_tot):
            if (i == 0):
                dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=cm_ref_layout[0], xy=[4, 0], direction='top')
            elif (i in dp_index_first_half_fan_odd):
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], xy=[8, 0], direction='right')
            elif (i in dp_index_first_half_fan_even):
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], xy=[2, 0], direction='right')
            else:
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], direction='right')

        # current mirror placement
        flag1 = 0
        for i in range(cm_num_tot):
            if (i in cm_index_first_eachfan):
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=dp_row_layout[dp_index_first_half_fan_odd[flag1]],
                                                   direction='bottom')
                flag1 = flag1 + 1
            else:
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], direction='right')

        # active load placement
        flag2 = 0
        for i in range(al_num_tot):
            if (i in al_index_first_half_fan):
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=dp_row_layout[dp_index_first_half_fan[flag2]],
                                                   direction='top')
                flag2 = flag2 + 1
            else:
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], direction='right')




    # if finger number of active load is the greatest
    else:
        # active load placement
        for i in range(al_num_tot):
            if (i == 0):
                al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=cm_ref_layout[0], xy=[4, 1], direction='top')
            elif (i in al_index_first_half_fan_odd):
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], xy=[8, 0], direction='right')
            elif (i in al_index_first_half_fan_even):
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], xy=[2, 0], direction='right')
            else:
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], direction='right')

        # diff pair placement
        flag1 = 0
        for i in range(dp_num_tot):
            if (i in dp_index_first_half_fan):
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=al_row_layout[al_index_first_half_fan[flag1]],
                                                   direction='bottom')
                flag1 = flag1 + 1
            else:
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], direction='right')

        # current mirror placement
        flag2 = 0
        for i in range(cm_num_tot):
            if (i in cm_index_first_eachfan):
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=dp_row_layout[dp_index_first_half_fan_odd[flag2]],
                                                   direction='bottom')
                flag2 = flag2 + 1
            else:
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], direction='right')

    # Guard Ring placement
    for i in range(max_finger + int(number_finger_cm_ref * 0.5) + number_fan * 4):
        if (i == 0):
            guardring_n[i] = laygen.relplace(templatename=['guard_ring_nwell'], gridname=pb,
                                             refobj=cm_ref_layout[int(number_finger_cm_ref / 2) - 1], xy=[0, 2],
                                             direction='top')
            guardring_p[i] = laygen.relplace(templatename=['guard_ring_psub'], gridname=pb,
                                             refobj=cm_ref_layout[int(number_finger_cm_ref / 2) - 1],
                                             direction='bottom')
        else:
            guardring_n[i] = laygen.relplace(templatename=['guard_ring_nwell'], gridname=pb, refobj=guardring_n[i - 1],
                                             direction='right')
            guardring_p[i] = laygen.relplace(templatename=['guard_ring_psub'], gridname=pb, refobj=guardring_p[i - 1],
                                             direction='right')

    # routes
    # current mirror self routing
    idc = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg23, refobj0=cm_ref_layout[-1][0].pins['D'],
                       refobj1=cm_ref_layout[-1][0].pins['D'], via0=[0, 0])
    vss = laygen.route(xy0=[0, 0], xy1=[1, 0], gridname0=rg12, refobj0=cm_ref_layout[-1][0].pins['S0'],
                       refobj1=cm_ref_layout[-1][0].pins['S0'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=cm_ref_layout[-1][0].pins['S0'],
                 refobj1=cm_row_layout[-1][0].pins['S1'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=cm_ref_layout[-1][0].pins['G'],
                 refobj1=cm_row_layout[-1][0].pins['G'])
    for i in range(int(number_finger_cm_ref / 2) - 1):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23, refobj0=cm_ref_layout[i][0].pins['D'],
                     refobj1=cm_ref_layout[i + 1][0].pins['D'], via0=[0, 0], via1=[0, 0])
    for i in range(number_fan):
        for j in range(cm_num_eachfan[i] - 1):
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                         refobj0=cm_row_layout[cm_index_first_eachfan[i] + j][0].pins['D'],
                         refobj1=cm_row_layout[cm_index_first_eachfan[i] + j + 1][0].pins['D'], via0=[0, 0],
                         via1=[0, 0])

    # diff pair routing
    # diff pair two inputs and two outputs
    for i in range(2 * number_fan):
        if (i == 0):
            inp = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=dp_row_layout[0][0].pins['G'],
                               refobj1=dp_row_layout[0][0].pins['G'], via0=[0, 0])
        elif (i == 1):
            inm = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12,
                               refobj0=dp_row_layout[dp_index_first_half_fan[i]][0].pins['G'],
                               refobj1=dp_row_layout[dp_index_first_half_fan[i]][0].pins['G'], via0=[0, 0])
        else:
            laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12,
                         refobj0=dp_row_layout[dp_index_first_half_fan[i]][0].pins['G'],
                         refobj1=dp_row_layout[dp_index_first_half_fan[i]][0].pins['G'], via0=[0, 0])
    outm = laygen.route(xy0=[0, 0], xy1=[0, 2], gridname0=rg23,
                        refobj0=dp_row_layout[dp_index_end_half_fan[-2]][0].pins['D'],
                        refobj1=dp_row_layout[dp_index_end_half_fan[-2]][0].pins['D'], via0=[0, 0])
    outp = laygen.route(xy0=[0, 0], xy1=[0, 2], gridname0=rg23, refobj0=dp_row_layout[-1][0].pins['D'],
                        refobj1=dp_row_layout[-1][0].pins['D'], via0=[0, 0])

    # diff pair gate and drain self connection
    for i in range(2 * number_fan):
        for j in range(dp_num_half_fan[i] - 1):
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12,
                         refobj0=dp_row_layout[dp_index_first_half_fan[i] + j][0].pins['G'],
                         refobj1=dp_row_layout[dp_index_first_half_fan[i] + j + 1][0].pins['G'], via0=[0, 0],
                         via1=[0, 0])
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                         refobj0=dp_row_layout[dp_index_first_half_fan[i] + j][0].pins['D'],
                         refobj1=dp_row_layout[dp_index_first_half_fan[i] + j + 1][0].pins['D'], via0=[0, 0],
                         via1=[0, 0])

    # diff pair: drain of i connect to gate of i+1
    for i in range(number_fan - 1):
        for j in range(dp_num_half_fan[2 * i] - 1):
            laygen.route(xy0=[0, -2], xy1=[0, -2], gridname0=rg34,
                         refobj0=dp_row_layout[dp_index_first_half_fan_odd[i] + j][0].pins['D'],
                         refobj1=dp_row_layout[dp_index_first_half_fan_odd[i] + j + 1][0].pins['D'], via0=[0, 0],
                         via1=[0, 0])
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg34,
                         refobj0=dp_row_layout[dp_index_first_half_fan_even[i] + j][0].pins['D'],
                         refobj1=dp_row_layout[dp_index_first_half_fan_even[i] + j + 1][0].pins['D'], via0=[0, 0],
                         via1=[0, 0])
        laygen.route(xy0=[0, -2], xy1=[-2, -2], gridname0=rg34,
                     refobj0=dp_row_layout[dp_index_first_half_fan_odd[i]][0].pins['D'],
                     refobj1=dp_row_layout[dp_index_first_half_fan_odd[i + 1]][0].pins['D'], via0=[0, 0], via1=[0, 0])
        laygen.route(xy0=[-2, -2], xy1=[-2, -1], gridname0=rg23,
                     refobj0=dp_row_layout[dp_index_first_half_fan_odd[i + 1]][0].pins['D'],
                     refobj1=dp_row_layout[dp_index_first_half_fan_odd[i + 1]][0].pins['D'], via1=[0, 0])
        laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg34,
                     refobj0=dp_row_layout[dp_index_first_half_fan_even[i]][0].pins['D'],
                     refobj1=dp_row_layout[dp_index_first_half_fan_even[i + 1]][0].pins['D'], via0=[0, 0], via1=[0, 0])
        laygen.route(xy0=[-2, 0], xy1=[-2, -1], gridname0=rg23,
                     refobj0=dp_row_layout[dp_index_first_half_fan_even[i + 1]][0].pins['D'],
                     refobj1=dp_row_layout[dp_index_first_half_fan_even[i + 1]][0].pins['D'], via1=[0, 0])

    # diff pair source self connection
    for i in range(number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12,
                     refobj0=dp_row_layout[dp_index_first_half_fan_odd[i]][0].pins['S0'],
                     refobj1=dp_row_layout[dp_index_end_half_fan[2 * i + 1]][0].pins['S1'])
    # diff pair source connect to current mirror drain
    for i in range(number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 3], gridname0=rg23,
                     refobj0=cm_row_layout[cm_index_first_eachfan[i]][0].pins['D'],
                     refobj1=cm_row_layout[cm_index_first_eachfan[i]][0].pins['D'], via1=[0, 0])
    # diff pair drain connect to active load
    for i in range(2 * number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                     refobj0=dp_row_layout[dp_index_first_half_fan[i]][0].pins['D'],
                     refobj1=al_row_layout[al_index_first_half_fan[i]][0].pins['D'])

    # active load routing
    # active load connect to VDD
    vdd = laygen.route(xy0=[0, 0], xy1=[1, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['S0'],
                       refobj1=al_row_layout[0][0].pins['S0'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['S0'],
                 refobj1=al_row_layout[-1][0].pins['S1'])
    # active load gate self connection
    vbias = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['G'],
                         refobj1=al_row_layout[0][0].pins['G'], via0=[0, 0])
    for i in range(al_num_tot - 1):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=al_row_layout[i][0].pins['G'],
                     refobj1=al_row_layout[i + 1][0].pins['G'], via0=[0, 0], via1=[0, 0])
    # active load drain self connection
    for i in range(2 * number_fan):
        for j in range(al_num_half_fan[i] - 1):
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                         refobj0=al_row_layout[al_index_first_half_fan[i] + j][0].pins['D'],
                         refobj1=al_row_layout[al_index_first_half_fan[i] + j + 1][0].pins['D'], via0=[0, 0],
                         via1=[0, 0])

    # Guard Ring routing
    for i in range(al_num_tot):
        laygen.route(xy0=[0, 0], xy1=[0, 5], gridname0=rg12, refobj0=al_row_layout[i][0].pins['S0'],
                     refobj1=al_row_layout[i][0].pins['S0'])
        laygen.route(xy0=[0, 0], xy1=[0, 5], gridname0=rg12, refobj0=al_row_layout[i][0].pins['S1'],
                     refobj1=al_row_layout[i][0].pins['S1'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rgnw, refobj0=guardring_n[0][0].pins['nwell'],
                 refobj1=al_row_layout[-1][0].pins['S1'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rgnw, refobj0=al_row_layout[0][0].pins['S0'],
                 refobj1=al_row_layout[-1][0].pins['S1'])
    for i in range(int(number_finger_cm_ref / 2)):
        laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_ref_layout[i][0].pins['S0'],
                     refobj1=cm_ref_layout[i][0].pins['S0'])
        laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_ref_layout[i][0].pins['S1'],
                     refobj1=cm_ref_layout[i][0].pins['S1'])
    for i in range(cm_num_tot):
        laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_row_layout[i][0].pins['S0'],
                     refobj1=cm_row_layout[i][0].pins['S0'])
        laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_row_layout[i][0].pins['S1'],
                     refobj1=cm_row_layout[i][0].pins['S1'])

    # pins
    laygen.pin(name='idc', layer=laygen.layers['pin'][2], refobj=idc, gridname=rg12)
    laygen.pin(name='vbias', layer=laygen.layers['pin'][2], refobj=vbias, gridname=rg12)
    laygen.pin(name='VSS', layer=laygen.layers['pin'][2], refobj=vss, gridname=rg12)
    laygen.pin(name='inp', layer=laygen.layers['pin'][2], refobj=inp, gridname=rg12)
    laygen.pin(name='inm', layer=laygen.layers['pin'][2], refobj=inm, gridname=rg12)
    laygen.pin(name='outp', layer=laygen.layers['pin'][3], refobj=outp, gridname=rg23)
    laygen.pin(name='outm', layer=laygen.layers['pin'][3], refobj=outm, gridname=rg23)
    laygen.pin(name='VDD', layer=laygen.layers['pin'][2], refobj=vdd, gridname=rg12)

    laygen.display()
    # export
    import bag
    prj = bag.BagProject()
    #print('prj_xs',prj)
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
