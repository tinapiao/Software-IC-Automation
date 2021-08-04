import os
import time
# import bag package
import bag
from bag.io import read_yaml
#import scripts_dsn.diffamp_simple as diffamp
# import BAG demo Python modules
import xbase_demo.core as demo_core
import xbase_demo.demo_layout.core as layout_core
import bag_testbenches.scripts_dsn.inverter as diffamp

from bag_testbenches.verification.mos.query import MOSDBDiscrete

# TEST: create/update template/grid database
import laygo

start_time=time.time()

# load circuit specifications from file
#spec_fname = os.path.join(os.environ['BAG_WORK_DIR'], 'specs_demo/demo.yaml')
#top_specs = read_yaml(spec_fname)

# obtain BagProject instance
local_dict = locals()
#if 'bprj' in local_dict:
if False:
    print('using existing BagProject')
    bprj = local_dict['bprj']
else:
    print('creating BagProject')
    bprj = bag.BagProject()


#test updating schematic and netlist_info -- 2021/01/05 DL
# print('importing netlist from virtuoso')
# bprj.import_design_library('demo_templates')
# print('netlist import done')

# # TEST: create/update template/grid database
# laygen = laygo.GridLayoutGenerator(config_file="laygo_config.yaml") #change physical grid resolution

#     imp.find_module('bag')
#     #bag import
#     print("import from BAG")
#     import bag
#     prj = bag.BagProject()
#     db=laygen.import_BAG(prj, utemplib, append=False)


# # construct template
# laygen.construct_template_and_grid(db, utemplib, layer_boundary=laygen.layers['prbnd'])
# #display and save
# #laygen.templates.display()
# #laygen.grids.display()
# laygen.templates.export_yaml(filename=laygen.tech+'_microtemplates_dense_templates.yaml')
# laygen.grids.export_yaml(filename=laygen.tech+'_microtemplates_dense_grids.yaml')

#diffamp.run_main()
diffamp.run_main(bprj)

end_time=time.time()
time_diff=end_time-start_time

print("\nThe total execution time is %.2f seconds" %round(time_diff,2) )

