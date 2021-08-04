# -*- coding: utf-8 -*-

import os

import yaml

from bag.core import BagProject

from serdes_ec.layout.qdr_hybrid.tap1 import Tap1Summer
from serdes_ec.layout.laygo.divider import DividerGroup


def run_main(prj):
    root_name = 'specs_test/serdes_ec/qdr_hybrid'
    test_fname = os.path.join(root_name, 'divider_group_info.yaml')
    if not os.path.isfile(test_fname):
        with open(os.path.join(root_name, 'tap1_summer.yaml'), 'r') as f:
            sum_specs = yaml.load(f)

        impl_lib = sum_specs['impl_lib']
        grid_specs = sum_specs['routing_grid']

        tdb = prj.make_template_db(impl_lib, grid_specs)
        summer = tdb.new_template(params=sum_specs['params'], temp_cls=Tap1Summer)
        div_info = dict(lat_row_info=summer.lat_row_info,
                        div_tr_info=summer.div_tr_info,
                        laygo_edger=summer.left_edge_info,
                        )

        with open(test_fname, 'w') as f:
            yaml.dump(div_info, f)
    else:
        with open(test_fname, 'r') as f:
            div_info = yaml.load(f)

    with open(os.path.join(root_name, 'divider_group.yaml'), 'r') as f:
        div_specs = yaml.load(f)

    div_specs['params'].update(div_info)
    prj.generate_cell(div_specs, DividerGroup, debug=True)
    # prj.generate_cell(div_specs, DividerGroup, gen_sch=True, debug=True)


if __name__ == '__main__':
    local_dict = locals()
    if 'bprj' not in local_dict:
        print('creating BAG project')
        bprj = BagProject()

    else:
        print('loading BAG project')
        bprj = local_dict['bprj']

    run_main(bprj)
