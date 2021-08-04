from abs_templates_ec.analog_core import AnalogBase



class AmpSF(AnalogBase):
    """A template of a single transistor with dummies.

    This class is mainly used for transistor characterization or
    design exploration with config views.

    Parameters
    ----------
    temp_db : :class:`bag.layout.template.TemplateDB`
            the template database.
    lib_name : str
        the layout library name.
    params : dict[str, any]
        the parameter values.
    used_names : set[str]
        a set of already used cell names.
    kwargs : dict[str, any]
        dictionary of optional parameters.  See documentation of
        :class:`bag.layout.template.TemplateBase` for details.
    """

    def __init__(self, temp_db, lib_name, params, used_names, **kwargs):
        AnalogBase.__init__(self, temp_db, lib_name, params, used_names, **kwargs)
        self._sch_params = None

    @property
    def sch_params(self):
        return self._sch_params

    @classmethod
    def get_params_info(cls):
        """Returns a dictionary containing parameter descriptions.

        Override this method to return a dictionary from parameter names to descriptions.

        Returns
        -------
        param_info : dict[str, str]
            dictionary from parameter name to description.
        """
        return dict(
            lch='channel length, in meters.',
            w_dict='width dictionary.',
            intent_dict='intent dictionary.',
            fg_dict='number of fingers dictionary.',
            ndum='number of dummies on each side.',
            ptap_w='NMOS substrate width, in meters/number of fins.',
            ntap_w='PMOS substrate width, in meters/number of fins.',
            show_pins='True to draw pin geometries.',
        )

    def draw_layout(self):
        """Draw the layout of a transistor for characterization.
        """

        lch = self.params['lch']
        w_dict = self.params['w_dict']
        intent_dict = self.params['intent_dict']
        fg_dict = self.params['fg_dict']
        ndum = self.params['ndum']
        ptap_w = self.params['ptap_w']
        ntap_w = self.params['ntap_w']
        show_pins = self.params['show_pins']

        fg_amp = fg_dict['amp']
        fg_bias = fg_dict['bias']

        if fg_bias % 2 != 0 or fg_amp % 2 != 0:
            raise ValueError('fg_bias=%d and fg_amp=%d must all be even.' % (fg_bias, fg_amp))

        fg_half_bias = fg_bias // 2
        fg_half_amp = fg_amp // 2
        fg_half = max(fg_half_bias, fg_half_amp)
        fg_tot = (fg_half + ndum) * 2

        nw_list = [w_dict['bias'], w_dict['amp']]
        nth_list = [intent_dict['bias'], intent_dict['amp']]

        ng_tracks = [1, 3]
        nds_tracks = [1, 1]

        n_orient = ['R0', 'MX']

        self.draw_base(lch, fg_tot, ptap_w, ntap_w, nw_list,
                       nth_list, [], [],
                       ng_tracks=ng_tracks, nds_tracks=nds_tracks,
                       pg_tracks=[], pds_tracks=[],
                       n_orientations=n_orient,
                       )

        if (fg_amp - fg_bias) % 4 == 0:
            s_net, d_net = 'VDD', 'vout'
            aout, aoutb, nsdir, nddir = 'd', 's', 2, 0
        else:
            s_net, d_net = 'vout', 'VDD'
            aout, aoutb, nsdir, nddir = 's', 'd', 0, 2

        bias_col = ndum + fg_half - fg_half_bias
        amp_col = ndum + fg_half - fg_half_amp
        amp_ports = self.draw_mos_conn('nch', 1, amp_col, fg_amp, nsdir, nddir,
                                       s_net=s_net, d_net=d_net)
        bias_ports = self.draw_mos_conn('nch', 0, bias_col, fg_bias, 0, 2,
                                        s_net='', d_net='vout')

        vdd_tid = self.make_track_id('nch', 1, 'g', 0)
        vin_tid = self.make_track_id('nch', 1, 'g', 2)
        vout_tid = self.make_track_id('nch', 0, 'ds', 0)
        vbias_tid = self.make_track_id('nch', 0, 'g', 0)

        vin_warr = self.connect_to_tracks(amp_ports['g'], vin_tid)
        vout_warr = self.connect_to_tracks([amp_ports[aout], bias_ports['d']], vout_tid)
        vbias_warr = self.connect_to_tracks(bias_ports['g'], vbias_tid)
        vdd_warr = self.connect_to_tracks(amp_ports[aoutb], vdd_tid)
        self.connect_to_substrate('ptap', bias_ports['s'])

        vss_warrs, _ = self.fill_dummy()

        self.add_pin('VSS', vss_warrs, show=show_pins)
        self.add_pin('VDD', vdd_warr, show=show_pins)
        self.add_pin('vin', vin_warr, show=show_pins)
        self.add_pin('vout', vout_warr, show=show_pins)
        self.add_pin('vbias', vbias_warr, show=show_pins)

        self._sch_params = dict(
            lch=lch,
            w_dict=w_dict,
            intent_dict=intent_dict,
            fg_dict=fg_dict,
            dum_info=self.get_sch_dummy_info(),
        )


import os

# import bag package
import bag
from bag.io import read_yaml

# import BAG demo Python modules
import xbase_demo.core as demo_core
from xbase_demo.demo_layout.core import AmpSFSoln

# load circuit specifications from file
spec_fname = os.path.join(os.environ['BAG_WORK_DIR'], 'specs_demo/demo.yaml')
top_specs = read_yaml(spec_fname)

# obtain BagProject instance
local_dict = locals()
if 'bprj' in local_dict:
    print('using existing BagProject')
    bprj = local_dict['bprj']
else:
    print('creating BagProject')
    bprj = bag.BagProject()

demo_core.run_flow(bprj, top_specs, 'amp_sf_soln', AmpSF, run_lvs=True, lvs_only=True)

'''from bag.layout.routing import TrackID
from bag.layout.template import TemplateBase


class RoutingDemo(TemplateBase):
    def __init__(self, temp_db, lib_name, params, used_names, **kwargs):
        super(RoutingDemo, self).__init__(temp_db, lib_name, params, used_names, **kwargs)

    @classmethod
    def get_params_info(cls):
        return {}

    def draw_layout(self):
        # Metal 4 is horizontal, Metal 5 is vertical
        hm_layer = 6
        vm_layer = 5

        # add a horizontal wire on track 0, from X=0.1 to X=0.3
        warr1 = self.add_wires(hm_layer, 0, 0.1, 0.3)
        # print WireArray object
        print(warr1)
        # print lower, middle, and upper coordinate of wire.
        print(warr1.lower, warr1.middle, warr1.upper)
        # print TrackID object associated with WireArray
        print(warr1.track_id)

        # add a horizontal wire on track 1, from X=0.1 to X=0.3,
        # coordinates specified in resolution units
        warr2 = self.add_wires(hm_layer, 1, 100, 300, unit_mode=True)

        # add another wire on track 1, from X=0.35 to X=0.45
        warr2_ext = self.add_wires(hm_layer, 1, 350, 450, unit_mode=True)
        # connect wires on the same track, in this case warr2 and warr2_ext
        self.connect_wires([warr2, warr2_ext])

        # add a horizontal wire on track 2.5, from X=0.2 to X=0.4
        self.add_wires(hm_layer, 2.5, 200, 400, unit_mode=True)
        # add a horizontal wire on track 4, from X=0.2 to X=0.4, with 2 tracks wide
        warr3 = self.add_wires(hm_layer, 4, 200, 400, width=2, unit_mode=True)

        # add 3 parallel vertical wires starting on track 6 and use every other track
        warr4 = self.add_wires(vm_layer, 6, 100, 400, num=3, pitch=2, unit_mode=True)
        print(warr4)

        # create a TrackID object representing a vertical track
        tid = TrackID(vm_layer, 3, width=2, num=1, pitch=0)
        # connect horizontal wires to the vertical track
        warr5 = self.connect_to_tracks([warr1, warr3], tid)
        print(warr5)

        # add a pin on a WireArray
        self.add_pin('pin1', warr1)
        # add a pin, but make label different than net name.  Useful for LVS connect
        self.add_pin('pin2', warr2, label='pin2:')
        # add_pin also works for WireArray representing multiple wires
        self.add_pin('pin3', warr4)
        # add a pin (so it is visible in BAG), but do not create the actual layout
        # in OA.  This is useful for hiding pins on lower levels of hierarchy.
        self.add_pin('pin4', warr3, show=False)

        # set the size of this template
        top_layer = vm_layer
        num_h_tracks = 6
        num_v_tracks = 11
        # size is 3-element tuple of top layer ID, number of top
        # vertical tracks, and number of top horizontal tracks
        self.size = top_layer, num_v_tracks, num_h_tracks
        # print bounding box of this template
        print(self.bound_box)
        # add a M7 rectangle to visualize bounding box in layout
        self.add_rect('M7', self.bound_box)


import os

# import bag package
import bag
from bag.io import read_yaml

# import BAG demo Python modules
import xbase_demo.core as demo_core

# load circuit specifications from file
spec_fname = os.path.join(os.environ['BAG_WORK_DIR'], 'specs_demo/demo.yaml')
top_specs = read_yaml(spec_fname)

# obtain BagProject instance
local_dict = locals()
if 'bprj' in local_dict:
    print('using existing BagProject')
    bprj = local_dict['bprj']
else:
    print('creating BagProject')
    bprj = bag.BagProject()

demo_core.routing_demo(bprj, top_specs, RoutingDemo)'''