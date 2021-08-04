import bag

# obtain BagProject instance
local_dict = locals()
if 'bprj' in local_dict:
    print('using existing BagProject')
    bprj = local_dict['bprj']
else:
    print('creating BagProject')
    bprj = bag.BagProject()

print('importing netlist from virtuoso')
bprj.import_design_library('demo_templates')
print('netlist import done')