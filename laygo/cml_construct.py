import laygo
#import logging; logging.basicConfig(level=logging.DEBUG)

laygen = laygo.GridLayoutGenerator(config_file="laygo_config.yaml") #change physical grid resolution
workinglib = 'cml'
utemplib = laygen.tech+'_cmltemplates'

laygen.add_library(workinglib)
laygen.sel_library(workinglib)

#bag import, if bag does not exist, gds import
import imp
try:
    imp.find_module('bag')
    #bag import
    print("import from BAG")
    import bag
    prj = bag.BagProject()
    db=laygen.import_BAG(prj, utemplib, append=False)
except ImportError:
    #gds import
    print("import from GDS")
    db = laygen.import_GDS(laygen.tech+'_cmltemplates.gds', layermapfile=laygen.tech+".layermap", append=False)

#construct template
laygen.construct_template_and_grid(db, utemplib, layer_boundary=laygen.layers['prbnd'])

#display and save
#laygen.templates.display()
#laygen.grids.display()
laygen.templates.export_yaml(filename=laygen.tech+'_cmltemplates_templates.yaml')
laygen.grids.export_yaml(filename=laygen.tech+'_cmltemplates_grids.yaml')
