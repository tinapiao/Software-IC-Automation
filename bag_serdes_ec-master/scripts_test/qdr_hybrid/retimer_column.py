# -*- coding: utf-8 -*-

import yaml

from bag.core import BagProject

from serdes_ec.layout.qdr_hybrid.sampler import RetimerColumn


if __name__ == '__main__':
    with open('specs_test/serdes_ec/qdr_hybrid/retimer_column.yaml', 'r') as f:
        block_specs = yaml.load(f)

    local_dict = locals()
    if 'bprj' not in local_dict:
        print('creating BAG project')
        bprj = BagProject()

    else:
        print('loading BAG project')
        bprj = local_dict['bprj']

    bprj.generate_cell(block_specs, RetimerColumn, debug=True)
    # bprj.generate_cell(block_specs, RetimerColumn, gen_sch=True, run_lvs=True, debug=True)
