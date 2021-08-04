import os

# import bag package
import bag
from bag.io import read_yaml
#import scripts_dsn.diffamp_simple as diffamp
# import BAG demo Python modules
import xbase_demo.core as demo_core
import xbase_demo.demo_layout.core as layout_core
import bag_testbenches.scripts_dsn.CML as diffamp

from bag_testbenches.verification.mos.query import MOSDBDiscrete


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

#diffamp.run_main()
diffamp.run_main(bprj)