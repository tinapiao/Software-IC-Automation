# -*- coding: utf-8 -*-

"""This script designs a simple diff amp with gain/bandwidth spec for BAG CICC paper."""

import math
import pprint

import yaml
import numpy as np
import scipy.optimize as sciopt

from bag.core import BagProject
from bag.io import read_yaml, open_file
from bag.io.sim_data import load_sim_file
from bag.util.search import BinaryIterator, minimize_cost_golden_float
from bag.simulation.core import DesignManager

from bag_testbenches_ec.verification_ec.mos.query import MOSDBDiscrete


def get_db(spec_file, intent, interp_method='spline', sim_env='tt'):
    # initialize transistor database from simulation data
    mos_db = MOSDBDiscrete([spec_file], interp_method=interp_method)
    # set process corners
    mos_db.env_list = [sim_env]
    # set layout parameters
    mos_db.set_dsn_params(intent=intent)
    return mos_db


def design_input(specs):
    """Find operating point that meets the given vstar spec."""
    db = specs['in_db']
    voutcm = specs['voutcm']
    vstar = specs['vimax']
    vdst = specs['vdst_min']
    in_type = specs['in_type']

    if in_type == 'nch':
        vb = 0
        vtail = vdst
    else:
        vb = specs['vdd']
        vtail = vb - vdst

    return db.query(vbs=vb - vtail, vds=voutcm - vtail, vstar=vstar)


def design_load(specs, input_op):
    """Design load.
    Sweep vgs.  For each vgs, compute gain and max bandwidth.  If
    both gain and BW specs are met, pick operating point that minimizes
    gamma_r * gm_r
    """
    db = specs['load_db']
    sim_env = specs['sim_env']
    vout = specs['voutcm']
    vgs_res = specs['vgs_res']
    gain_min = specs['gain_min']
    bw = specs['bw']
    in_type = specs['in_type']

    if in_type == 'nch':
        vs = specs['vdd']
    else:
        vs = 0

    gm_fun = db.get_function('gm', env=sim_env)
    gds_fun = db.get_function('gds', env=sim_env)
    cdd_fun = db.get_function('cdd', env=sim_env)
    gamma_fun = db.get_function('gamma', env=sim_env)
    ib_fun = db.get_function('ibias', env=sim_env)

    vgs_idx = db.get_fun_arg_index('vgs')
    vgs_min, vgs_max = ib_fun.get_input_range(vgs_idx)
    num_points = int(np.ceil((vgs_max - vgs_min) / vgs_res)) + 1

    gm_i = input_op['gm']
    itarg = input_op['ibias']
    gds_i = input_op['gds']
    cdd_i = input_op['cdd']

    vgs_best = None
    metric_best = float('inf')
    gain_max = 0
    bw_max = 0
    vgs_vec = np.linspace(vgs_min, vgs_max, num_points, endpoint=True)
    bw_list, gain_list, gamma_list, gm_list, metric_list = [], [], [], [], []
    for vgs_val in vgs_vec:
        farg = db.get_fun_arg(vgs=vgs_val, vds=vout - vs, vbs=0)
        scale = itarg / ib_fun(farg)
        gm_r = gm_fun(farg) * scale
        gds_r = gds_fun(farg) * scale
        cdd_r = cdd_fun(farg) * scale
        gamma_r = gamma_fun(farg)

        bw_cur = (gds_r + gds_i) / (cdd_i + cdd_r) / 2 / np.pi
        gain_cur = gm_i / (gds_r + gds_i)
        metric_cur = gamma_r * gm_r
        bw_list.append(bw_cur)
        gain_list.append(gain_cur)
        metric_list.append(metric_cur)
        gamma_list.append(gamma_r)
        gm_list.append(gm_r)
        if gain_cur >= gain_min and bw_cur >= bw:
            if metric_cur < metric_best:
                metric_best = metric_cur
                vgs_best = vgs_val
        else:
            gain_max = max(gain_max, gain_cur)
            bw_max = max(bw_max, bw_cur)

    if vgs_best is None:
        raise ValueError('No solution.  max gain = %.4g, '
                         'max bw = %.4g' % (gain_max, bw_max))

    import matplotlib.pyplot as plt
    f, ax_list = plt.subplots(5, sharex=True)
    ax_list[0].plot(vgs_vec, np.asarray(bw_list) / 1e9)
    ax_list[0].set_ylabel('max Bw (GHz)')
    ax_list[1].plot(vgs_vec, gain_list)
    ax_list[1].set_ylabel('gain (V/V)')
    ax_list[2].plot(vgs_vec, gamma_list)
    ax_list[2].set_ylabel(r'$\gamma_r$')
    ax_list[3].plot(vgs_vec, np.asarray(gm_list) * 1e3)
    ax_list[3].set_ylabel(r'$g_{mr}$ (mS)')
    ax_list[4].plot(vgs_vec, np.asarray(metric_list) * 1e3)
    ax_list[4].set_ylabel(r'$\gamma_r\cdot g_{mr}$ (mS)')
    ax_list[4].set_xlabel('Vgs (V)')
    plt.show(block=False)

    result = db.query(vbs=0, vds=vout - vs, vgs=vgs_best)
    scale = itarg / result['ibias']
    return scale, result


def design_amp(specs, input_op, load_op, load_scale):
    fstart = specs['fstart']
    fstop = specs['fstop']
    vsig = specs['vsig']
    temp = specs['noise_temp']
    snr_min = specs['snr_min']
    bw = specs['bw']
    cload = specs['cload']
    vdd = specs['vdd']
    vdst = specs['vdst_min']
    in_type = specs['in_type']
    k = 1.38e-23

    gm_i = input_op['gm']
    gds_i = input_op['gds']
    gamma_i = input_op['gamma']
    cdd_i = input_op['cdd']
    gm_l = load_op['gm'] * load_scale
    gds_l = load_op['gds'] * load_scale
    cdd_l = load_op['cdd'] * load_scale
    gamma_l = load_op['gamma']

    snr_linear = 10.0 ** (snr_min / 10)
    gds_tot = gds_i + gds_l
    cdd_tot = cdd_i + cdd_l
    gain = gm_i / gds_tot
    noise_const = gm_i / (gamma_i * gm_i + gamma_l * gm_l)
    print(gm_i, gm_l, gamma_i, gamma_l, noise_const)
    # get scale factor for BW-limited case
    scale_bw = max(1, 2 * np.pi * bw * cload / (gds_tot - 2 * np.pi * bw * cdd_tot))
    if fstart < 0:
        noise_const *= vsig ** 2 * gain / (4 * k * temp)
        cload_tot = snr_linear / noise_const
        rout = 1 / (2 * np.pi * bw * cload_tot)
        scale_noise = 1 / (gds_tot * rout)
        if scale_noise < scale_bw:
            print('BW-limited, scale_bw = %.4g, scale_noise = %.4g' % (scale_bw, scale_noise))
            # we are BW-limited, not noise limited
            scale = scale_bw
            cload_add = 0
        else:
            print('noise-limited.')
            scale = scale_noise
            cload_add = cload_tot - scale * (cdd_i + cdd_l) - cload
    else:
        noise_const *= vsig ** 2 / (16 * k * temp * (fstop - fstart))
        gm_final = snr_linear / noise_const
        scale_noise = gm_final / gm_i
        if scale_noise < scale_bw:
            print('BW-limited, scale_bw = %.4g, scale_noise = %.4g' % (scale_bw, scale_noise))
            # we are BW-limited, not noise limited
            scale = scale_bw
        else:
            print('noise-limited.')
            scale = scale_noise

        cload_add = 0

    # get number of segments
    seg_in = int(np.ceil(scale))
    print(seg_in, load_scale)
    seg_load = int(np.ceil(seg_in * load_scale))
    # recompute amplifier performance
    gm_i *= seg_in
    gds_i *= seg_in
    cdd_i *= seg_in
    gm_l = load_op['gm'] * seg_load
    gds_l = load_op['gds'] * seg_load
    cdd_l = load_op['cdd'] * seg_load

    gds_tot = gds_i + gds_l
    cdd_tot = cdd_i + cdd_l
    if in_type == 'nch':
        vincm = vdst + input_op['vgs']
    else:
        vincm = vdd - vdst + input_op['vgs']
    amp_specs = dict(
        ibias=input_op['ibias'] * seg_in * 2,
        gain=gm_i / gds_tot,
        bw=gds_tot / (2 * np.pi * (cload + cload_add + cdd_tot)),
        vincm=vincm,
        cload=cload + cload_add,
    )

    return seg_in, seg_load, amp_specs


def design_tail(specs, itarg, seg_min):
    """Find smallest tail transistor that biases the differential amplifier."""
    db = specs['in_db']
    sim_env = specs['sim_env']
    vds = specs['vdst_min']
    in_type = specs['in_type']

    if in_type == 'pch':
        vds *= -1

    ib_fun = db.get_function('ibias', env=sim_env)
    vgs_idx = db.get_fun_arg_index('vgs')
    vgs_min, vgs_max = ib_fun.get_input_range(vgs_idx)

    # binary search on number of fingers.
    seg_tail_iter = BinaryIterator(seg_min, None, step=2)
    while seg_tail_iter.has_next():
        seg_tail = seg_tail_iter.get_next()

        def fun_zero(vgs):
            farg = db.get_fun_arg(vgs=vgs, vds=vds, vbs=0)
            return ib_fun(farg) * seg_tail - itarg

        val_min = fun_zero(vgs_min)
        val_max = fun_zero(vgs_max)
        if val_min > 0 and val_max > 0:
            # smallest possible current > itarg
            seg_tail_iter.down()
        elif val_min < 0 and val_max < 0:
            # largest possbile current < itarg
            seg_tail_iter.up()
        else:
            vbias = sciopt.brentq(fun_zero, vgs_min, vgs_max)  # type: float
            seg_tail_iter.save_info(vbias)
            seg_tail_iter.down()

    seg_tail = seg_tail_iter.get_last_save()
    if seg_tail is None:
        raise ValueError('No solution for tail.')
    vgs_opt = seg_tail_iter.get_last_save_info()

    tail_op = db.query(vbs=0, vds=vds, vgs=vgs_opt)
    return seg_tail, tail_op


def run_main():
    interp_method = 'spline'
    sim_env = 'tt'
    nmos_spec = 'specs_mos_char/nch_w0d5.yaml'
    pmos_spec = 'specs_mos_char/pch_w0d5.yaml'
    intent = 'lvt'

    nch_db = get_db(nmos_spec, intent, interp_method=interp_method,
                    sim_env=sim_env)
    pch_db = get_db(pmos_spec, intent, interp_method=interp_method,
                    sim_env=sim_env)

    specs = dict(
        in_type='pch',
        sim_env=sim_env,
        in_db=pch_db,
        load_db=nch_db,
        cload=10e-13,
        vgs_res=5e-3,
        vdd=1.2,
        voutcm=0.6,
        vdst_min=0.2,
        vimax=0.25,
        gain_min=3.0,
        bw=1e10,
        snr_min=50,
        vsig=0.05,
        fstart=1.4e9,
        fstop=1.6e9,
        # fstart=-1,
        # fstop=-1,
        noise_temp=300,
    )

    input_op = design_input(specs)
    load_scale, load_op = design_load(specs, input_op)
    seg_in, seg_load, amp_specs = design_amp(specs, input_op, load_op, load_scale)
    seg_tail, tail_op = design_tail(specs, amp_specs['ibias'], seg_in * 2)
    print('amplifier performance:')
    pprint.pprint(amp_specs)
    for name, seg, op in (('input', seg_in, input_op),
                          ('load', seg_load, load_op),
                          ('tail', seg_tail, tail_op)):
        print('%s seg = %d' % (name, seg))
        print('%s op:' % name)
        pprint.pprint(op)


if __name__ == '__main__':
    run_main()
"""""def design_amp(amp_specs, nch_db, pch_db):
    sim_env = amp_specs['sim_env']
    vdd = amp_specs['vdd']
    vtail = amp_specs['vtail']
    vgs_res = amp_specs['vgs_res']
    gain_min = amp_specs['gain_min']
    bw_min = amp_specs['bw_min']
    cload = amp_specs['cload']

    w3db_min = 2 * np.pi * bw_min

    fun_ibiasn = nch_db.get_function('ibias', env=sim_env)
    fun_gmn = nch_db.get_function('gm', env=sim_env)
    fun_gdsn = nch_db.get_function('gds', env=sim_env)
    fun_cdn = nch_db.get_function('cdb', env=sim_env) + nch_db.get_function('cds', env=sim_env)

    fun_ibiasp = pch_db.get_function('ibias', env=sim_env)
    fun_gdsp = pch_db.get_function('gds', env=sim_env)
    fun_cdp = pch_db.get_function('cdd', env=sim_env)

    vgsn_idx = nch_db.get_fun_arg_index('vgs')
    vgsn_min, vgsn_max = fun_ibiasn.get_input_range(vgsn_idx)
    num_pts = int(math.ceil((vgsn_max - vgsn_min) / vgs_res))
    vgs_list = np.linspace(vgsn_min, vgsn_max, num_pts + 1).tolist()

    vgsp_idx = pch_db.get_fun_arg_index('vgs')
    vgsp_min, vgsp_max = fun_ibiasp.get_input_range(vgsp_idx)
    # sweep vgs, find best point
    performance = None
    for vgsn_cur in vgs_list:
        vout = vgsn_cur + vtail

        # get nmos SS parameters
        narg = nch_db.get_fun_arg(vgs=vgsn_cur, vds=vgsn_cur, vbs=vtail)
        ibiasn_unit = fun_ibiasn(narg)
        gmn_unit = fun_gmn(narg)
        gdsn_unit = fun_gdsn(narg)
        cdn_unit = fun_cdn(narg)

        # find vgsp
        def gain_fun1(vgsp_test):
            parg_test = pch_db.get_fun_arg(vgs=vgsp_test, vds=vout - vdd, vbs=0)
            ibiasp_unit_test = fun_ibiasp(parg_test)
            gdsp_unit_test = fun_gdsp(parg_test)
            return gmn_unit / ibiasn_unit / (gdsn_unit / ibiasn_unit + gdsp_unit_test / ibiasp_unit_test)

        result = minimize_cost_golden_float(gain_fun1, gain_min, vgsp_min, vgsp_max, tol=vgs_res / 10)
        opt_vgsp = result.x
        if opt_vgsp is None:
            print('vgsn = %.4g, max gain: %.4g' % (vgsn_cur, result.vmax))
            break

        # get pmos SS parameters
        parg = pch_db.get_fun_arg(vgs=opt_vgsp, vds=vout - vdd, vbs=0)
        ibiasp_unit = fun_ibiasp(parg)
        kp = ibiasn_unit / ibiasp_unit
        gdsp_unit = fun_gdsp(parg) * kp
        cdp_unit = fun_cdp(parg) * kp

        bw_intrinsic = (gdsp_unit + gdsn_unit) / (2 * np.pi * (cdp_unit + cdn_unit))
        # skip if we can never meet bandwidth requirement.
        if bw_intrinsic < bw_min:
            continue

        # compute total scale factor and number of input/load fingers
        bw_cur = 0
        seg_load = 0
        vbp = 0
        while bw_cur < bw_min:
            k = w3db_min * cload / (gdsp_unit + gdsn_unit - w3db_min * (cdn_unit + cdp_unit))

            seg_in = int(math.ceil(k / 2)) * 2
            seg_load = max(2, int(math.ceil(kp * k / 2)) * 2)
            # update kp and pmos SS parameters
            vbp, _ = find_load_bias(pch_db, vdd, vout, vgsp_min, vgsp_max, seg_in * ibiasn_unit, seg_load, fun_ibiasp)
            while vbp is None:
                seg_load += 2
                # update kp and pmos SS parameters
                vbp, _ = find_load_bias(pch_db, vdd, vout, vgsp_min, vgsp_max, seg_in * ibiasn_unit, seg_load, fun_ibiasp)
            kp = seg_load / seg_in

            parg = pch_db.get_fun_arg(vgs=vbp - vdd, vds=vout - vdd, vbs=0)
            gdsp_unit = fun_gdsp(parg) * kp
            cdp_unit = fun_cdp(parg) * kp

            # recompute gain/bandwidth
            bw_cur = (gdsp_unit + gdsn_unit) * seg_in / (2 * np.pi * (seg_in * (cdp_unit + cdn_unit) + cload))

        gain_cur = gmn_unit / (gdsp_unit + gdsn_unit)
        ibias_cur = seg_in * ibiasn_unit

        if performance is None or performance[0] > ibias_cur:
            performance = (ibias_cur, gain_cur, bw_cur, seg_in, seg_load, vgsn_cur, vbp)

    if performance is None:
        return None

    ibias_opt, gain_cur, bw_cur, seg_in, seg_load, vgs_in, vload = performance
    vio = vtail + vgs_in
    seg_tail, vbias = find_tail_bias(fun_ibiasn, nch_db, vtail, vgsn_min, vgsn_max, seg_in, ibias_opt)

    return dict(
        ibias=2 * ibias_opt,
        gain=gain_cur,
        bw=bw_cur,
        seg_in=seg_in,
        seg_load=seg_load,
        seg_tail=seg_tail,
        vtail=vbias,
        vindc=vio,
        voutdc=vio,
        vload=vload,
        vgs_in=vgs_in,
    )


def find_tail_bias(fun_ibiasn, nch_db, vtail, vgs_min, vgs_max, seg_tail_min, itarg):
    seg_tail_iter = BinaryIterator(seg_tail_min, None, step=2)
    while seg_tail_iter.has_next():
        seg_tail = seg_tail_iter.get_next()

        def fun_zero(vgs):
            narg = nch_db.get_fun_arg(vgs=vgs, vds=vtail, vbs=0)
            return fun_ibiasn(narg) * seg_tail - itarg

        if fun_zero(vgs_min) > 0:
            # smallest possible current > itarg
            seg_tail_iter.down()
        if fun_zero(vgs_max) < 0:
            # largest possible current < itarg
            seg_tail_iter.up()
        else:
            vbias = sciopt.brentq(fun_zero, vgs_min, vgs_max)  # type: float
            seg_tail_iter.save_info(vbias)
            seg_tail_iter.down()

    seg_tail = seg_tail_iter.get_last_save()
    vbias = seg_tail_iter.get_last_save_info()

    return seg_tail, vbias


def find_load_bias(pch_db, vdd, vout, vgsp_min, vgsp_max, itarg, seg_load, fun_ibiasp):
    def fun_zero(vbias):
        parg = pch_db.get_fun_arg(vgs=vbias - vdd, vds=vout - vdd, vbs=0)
        return fun_ibiasp(parg) * seg_load - itarg

    vbias_min = vdd + vgsp_min
    vbias_max = vdd + vgsp_max

    if fun_zero(vbias_max) > 0:
        # smallest possible current > itarg
        return None, -1
    if fun_zero(vbias_min) < 0:
        # largest possible current < itarg
        return None, 1

    vbias_opt = sciopt.brentq(fun_zero, vbias_min, vbias_max)  # type: float
    return vbias_opt, 0


def design(amp_dsn_specs, amp_char_specs_fname, amp_char_specs_out_fname):
    nch_config = amp_dsn_specs['nch_config']
    pch_config = amp_dsn_specs['pch_config']

    print('create transistor database')
    nch_db = MOSDBDiscrete([nch_config])
    pch_db = MOSDBDiscrete([pch_config])

    nch_db.set_dsn_params(**amp_dsn_specs['nch'])
    pch_db.set_dsn_params(**amp_dsn_specs['pch'])

    result = design_amp(amp_dsn_specs, nch_db, pch_db)
    if result is None:
        raise ValueError('No solution.')

    pprint.pprint(result)

    # update characterization spec file
    amp_char_specs = read_yaml(amp_char_specs_fname)
    # update bias
    var_dict = amp_char_specs['measurements'][0]['testbenches']['ac']['sim_vars']
    for key in ('vtail', 'vindc', 'voutdc'):
        var_dict[key] = result[key]
    for key in ('vdd', 'cload'):
        var_dict[key] = amp_dsn_specs[key]
    # update segments
    seg_dict = amp_char_specs['layout_params']['seg_dict']
    for key in ('in', 'load', 'tail'):
        seg_dict[key] = result['seg_' + key]

    with open_file(amp_char_specs_out_fname, 'w') as f:
        yaml.dump(amp_char_specs, f)

    return result


def simulate(prj, specs_fname):
    # simulate and report result
    sim = DesignManager(prj, specs_fname)
    sim.characterize_designs(generate=True, measure=True, load_from_file=False)
    # sim.test_layout(gen_sch=False)

    dsn_name = list(sim.get_dsn_name_iter())[0]
    summary = sim.get_result(dsn_name)
    fname = summary['ac']['gain_w3db_file']
    result = load_sim_file(fname)
    gain = result['gain_vout']
    w3db = result['w3db_vout']
    print('%s gain = %.4g' % (dsn_name, gain))
    print('%s w3db = %.4g' % (dsn_name, w3db))

    return gain, w3db


def run_main(prj):
    amp_dsn_specs_fname = 'specs_design_sample/diffamp_simple.yaml'
    amp_char_specs_fname = 'specs_char_sample/diffamp_simple.yaml'
    amp_char_specs_out_fname = 'specs_design_sample/diffamp_simple_mod.yaml'

    # simulate(prj, amp_char_specs_out_fname)
    # return

    amp_dsn_specs = read_yaml(amp_dsn_specs_fname)
    gain_min_orig = amp_dsn_specs['gain_min']
    bw_min_orig = amp_dsn_specs['bw_min']

    result = None
    done = False
    gain, w3db = 0, 0
    while not done:
        result = design(amp_dsn_specs, amp_char_specs_fname, amp_char_specs_out_fname)
        gain, w3db = simulate(prj, amp_char_specs_out_fname)

        if gain >= gain_min_orig and w3db >= bw_min_orig:
            done = True
        else:
            if gain < gain_min_orig:
                gain_expected = result['gain']
                gain_scale = gain / gain_expected
                amp_dsn_specs['gain_min'] = gain_min_orig / gain_scale
            if w3db < bw_min_orig:
                bw_expected = result['bw']
                bw_scale = w3db / bw_expected
                amp_dsn_specs['bw_min'] = bw_min_orig / bw_scale

    pprint.pprint(result)
    print('final gain = %.4g' % gain)
    print('final w3db = %.4g' % w3db)


if __name__ == '__main__':
    local_dict = locals()
    if 'bprj' not in local_dict:
        print('creating BAG project')
        bprj = BagProject()

    else:
        print('loading BAG project')
        bprj = local_dict['bprj']

    run_main(bprj)"""
