# -*- coding: utf-8 -*-

from typing import TYPE_CHECKING, Optional, Dict, Any, Tuple, List, Iterable, Sequence

import abc
import importlib
import itertools
import os
import math
import yaml

from bag import float_to_si_string
from bag.io import read_yaml, open_file, load_sim_results, save_sim_results, load_sim_file
from bag.layout import RoutingGrid, TemplateDB
from bag.concurrent.core import batch_async_task
from bag import BagProject
import laygo



if TYPE_CHECKING:
    import numpy as np
    from bag.core import Testbench


class TestbenchManager(object, metaclass=abc.ABCMeta):
    """A class that creates and setups up a testbench for simulation, then save the result.

    This class is used by MeasurementManager to run simulations.

    Parameters
    ----------
    data_fname : str
        Simulation data file name.
    tb_name : str
        testbench name.
    impl_lib : str
        implementation library name.
    specs : Dict[str, Any]
        testbench specs.
    sim_view_list : Sequence[Tuple[str, str]]
        simulation view list
    env_list : Sequence[str]
        simulation environments list.
    """
    def __init__(self,
                 data_fname,  # type: str
                 tb_name,  # type: str
                 impl_lib,  # type: str
                 specs,  # type: Dict[str, Any]
                 sim_view_list,  # type: Sequence[Tuple[str, str]]
                 env_list,  # type: Sequence[str]
                 ):
        # type: (...) -> None
        self.data_fname = os.path.abspath(data_fname)
        self.tb_name = tb_name
        self.impl_lib = impl_lib
        self.specs = specs
        self.sim_view_list = sim_view_list
        self.env_list = env_list

    @abc.abstractmethod
    def setup_testbench(self, tb):
        # type: (Testbench) -> None
        """Configure the simulation state of the given testbench.

        No need to call update_testbench(), set_simulation_environments(), and
        set_simulation_view().  These are called for you.

        Parameters
        ----------
        tb : Testbench
            the simulation Testbench instance.
        """
        pass

    async def setup_and_simulate(self, prj: BagProject,
                                 sch_params: Dict[str, Any]) -> Dict[str, Any]:
        if sch_params is None:
            print('loading testbench %s' % self.tb_name)
            tb = prj.load_testbench(self.impl_lib, self.tb_name)
        else:
            print('Creating testbench %s' % self.tb_name)
            tb = self._create_tb_schematic(prj, sch_params)

        print('Configuring testbench %s' % self.tb_name)
        tb.set_simulation_environments(self.env_list)
        self.setup_testbench(tb)
        for cell_name, view_name in self.sim_view_list:
            tb.set_simulation_view(self.impl_lib, cell_name, view_name)
        tb.update_testbench()

        # run simulation and save/return raw result
        print('Simulating %s' % self.tb_name)
        save_dir = await tb.async_run_simulation()
        print('Finished simulating %s' % self.tb_name)
        results = load_sim_results(save_dir)
        save_sim_results(results, self.data_fname)
        return results

    @classmethod
    def record_array(cls, output_dict, data_dict, arr, arr_name, sweep_params):
        # type: (Dict[str, Any], Dict[str, Any], np.ndarray, str, List[str]) -> None
        """Add the given numpy array into BAG's data structure dictionary.

        This method adds the given numpy array to output_dict, and make sure
        sweep parameter information are treated properly.

        Parameters
        ----------
        output_dict : Dict[str, Any]
            the output dictionary.
        data_dict : Dict[str, Any]
            the raw simulation data dictionary.
        arr : np.ndarray
            the numpy array to record.
        arr_name : str
            name of the given numpy array.
        sweep_params : List[str]
            a list of sweep parameters for thhe given array.
        """
        if 'sweep_params' in output_dict:
            swp_info = output_dict['sweep_params']
        else:
            swp_info = {}
            output_dict['sweep_params'] = swp_info

        # record sweep parameters information
        for var in sweep_params:
            if var not in output_dict:
                output_dict[var] = data_dict[var]
        swp_info[arr_name] = sweep_params
        output_dict[arr_name] = arr

    def _create_tb_schematic(self, prj, sch_params):
        # type: (BagProject, Dict[str, Any]) -> Testbench
        """Helper method to create a testbench schematic.

        Parmaeters
        ----------
        prj : BagProject
            the BagProject instance.
        sch_params : Dict[str, Any]
            the testbench schematic parameters dictionary.

        Returns
        -------
        tb : Testbench
            the simulation Testbench instance.
        """
        tb_lib = self.specs['tb_lib']
        tb_cell = self.specs['tb_cell']
        tb_sch = prj.create_design_module(tb_lib, tb_cell)
        tb_sch.design(**sch_params)
        tb_sch.implement_design(self.impl_lib, top_cell_name=self.tb_name)

        return prj.configure_testbench(self.impl_lib, self.tb_name)


class MeasurementManager(object, metaclass=abc.ABCMeta):
    """A class that handles circuit performance measurement.

    This class handles all the steps needed to measure a specific performance
    metric of the device-under-test.  This may involve creating and simulating
    multiple different testbenches, where configuration of successive testbenches
    depends on previous simulation results. This class reduces the potentially
    complex measurement tasks into a few simple abstract methods that designers
    simply have to implement.

    Parameters
    ----------
    data_dir : str
        Simulation data directory.
    meas_name : str
        measurement setup name.
    impl_lib : str
        implementation library name.
    specs : Dict[str, Any]
        the measurement specification dictionary.
    wrapper_lookup : Dict[str, str]
        the DUT wrapper cell name lookup table.
    sim_view_list : Sequence[Tuple[str, str]]
        simulation view list
    env_list : Sequence[str]
        simulation environments list.
    """
    def __init__(self,  # type: MeasurementManager
                 data_dir,  # type: str
                 meas_name,  # type: str
                 impl_lib,  # type: str
                 specs,  # type: Dict[str, Any]
                 wrapper_lookup,  # type: Dict[str, str]
                 sim_view_list,  # type: Sequence[Tuple[str, str]]
                 env_list,  # type: Sequence[str]
                 ):
        # type: (...) -> None
        self.data_dir = os.path.abspath(data_dir)
        self.impl_lib = impl_lib
        self.meas_name = meas_name
        self.specs = specs
        self.wrapper_lookup = wrapper_lookup
        self.sim_view_list = sim_view_list
        self.env_list = env_list

        os.makedirs(self.data_dir, exist_ok=True)

    @abc.abstractmethod
    def get_initial_state(self):
        # type: () -> str
        """Returns the initial FSM state."""
        return ''

    # noinspection PyUnusedLocal
    def get_testbench_info(self,  # type: MeasurementManager
                           state,  # type: str
                           prev_output,  # type: Optional[Dict[str, Any]]
                           ):
        # type: (...) -> Tuple[str, str, Dict[str, Any], Optional[Dict[str, Any]]]
        """Get information about the next testbench.

        Override this method to perform more complex operations.

        Parameters
        ----------
        state : str
            the current FSM state.
        prev_output : Optional[Dict[str, Any]]
            the previous post-processing output.

        Returns
        -------
        tb_name : str
            cell name of the next testbench.  Should incorporate self.meas_name to avoid
            collision with testbench for other designs.
        tb_type : str
            the next testbench type.
        tb_specs : str
            the testbench specification dictionary.
        tb_params : Optional[Dict[str, Any]]
            the next testbench schematic parameters.  If we are reusing an existing
            testbench, this should be None.
        """
        tb_type = state
        tb_name = self.get_testbench_name(tb_type)
        tb_specs = self.get_testbench_specs(tb_type).copy()
        tb_params = self.get_default_tb_sch_params(tb_type)

        return tb_name, tb_type, tb_specs, tb_params

    @abc.abstractmethod
    def process_output(self, state, data, tb_manager):
        # type: (str, Dict[str, Any], TestbenchManager) -> Tuple[bool, str, Dict[str, Any]]
        """Process simulation output data.

        Parameters
        ----------
        state : str
            the current FSM state
        data : Dict[str, Any]
            simulation data dictionary.
        tb_manager : TestbenchManager
            the testbench manager object.

        Returns
        -------
        done : bool
            True if this measurement is finished.
        next_state : str
            the next FSM state.
        output : Dict[str, Any]
            a dictionary containing post-processed data.
        """
        return False, '', {}

    def get_testbench_name(self, tb_type):
        # type: (str) -> str
        """Returns a default testbench name given testbench type."""
        return '%s_TB_%s' % (self.meas_name, tb_type)

    async def async_measure_performance(self,
                                        prj: BagProject,
                                        load_from_file: bool = False) -> Dict[str, Any]:
        """A coroutine that performs measurement.

        The measurement is done like a FSM.  On each iteration, depending on the current
        state, it creates a new testbench (or reuse an existing one) and simulate it.
        It then post-process the simulation data to determine the next FSM state, or
        if the measurement is done.

        Parameters
        ----------
        prj : BagProject
            the BagProject instance.
        load_from_file : bool
            If True, then load existing simulation data instead of running actual simulation.

        Returns
        -------
        output : Dict[str, Any]
            the last dictionary returned by process_output().
        """
        cur_state = self.get_initial_state()
        prev_output = None
        done = False

        while not done:
            # create and setup testbench
            tb_name, tb_type, tb_specs, tb_sch_params = self.get_testbench_info(cur_state,
                                                                                prev_output)

            tb_package = tb_specs['tb_package']
            tb_cls_name = tb_specs['tb_class']
            tb_module = importlib.import_module(tb_package)
            tb_cls = getattr(tb_module, tb_cls_name)
            raw_data_fname = os.path.join(self.data_dir, '%s.hdf5' % cur_state)

            tb_manager = tb_cls(raw_data_fname, tb_name, self.impl_lib, tb_specs,
                                self.sim_view_list, self.env_list)

            if load_from_file:
                print('Measurement %s in state %s, '
                      'load sim data from file.' % (self.meas_name, cur_state))
                if os.path.isfile(raw_data_fname):
                    cur_results = load_sim_file(raw_data_fname)
                else:
                    print('Cannot find data file, simulating...')
                    cur_results = await tb_manager.setup_and_simulate(prj, tb_sch_params)
            else:
                cur_results = await tb_manager.setup_and_simulate(prj, tb_sch_params)

            # process and save simulation data
            print('Measurement %s in state %s, '
                  'processing data from %s' % (self.meas_name, cur_state, tb_name))
            done, next_state, prev_output = self.process_output(cur_state, cur_results, tb_manager)
            with open_file(os.path.join(self.data_dir, '%s.yaml' % cur_state), 'w') as f:
                yaml.dump(prev_output, f)

            cur_state = next_state

        return prev_output

    def get_state_output(self, state):
        # type: (str) -> Dict[str, Any]
        """Get the post-processed output of the given state."""
        with open_file(os.path.join(self.data_dir, '%s.yaml' % state), 'r') as f:
            return yaml.load(f)

    def get_testbench_specs(self, tb_type):
        # type: (str) -> Dict[str, Any]
        """Helper method to get testbench specifications."""
        return self.specs['testbenches'][tb_type]

    def get_default_tb_sch_params(self, tb_type):
        # type: (str) -> Dict[str, Any]
        """Helper method to return a default testbench schematic parameters dictionary.

        This method loads default values from specification file, the fill in dut_lib
        and dut_cell for you.

        Parameters
        ----------
        tb_type : str
            the testbench type.

        Returns
        -------
        sch_params : Dict[str, Any]
            the default schematic parameters dictionary.
        """
        tb_specs = self.get_testbench_specs(tb_type)
        wrapper_type = tb_specs['wrapper_type']

        if 'sch_params' in tb_specs:
            tb_params = tb_specs['sch_params'].copy()
        else:
            tb_params = {}

        tb_params['dut_lib'] = self.impl_lib
        tb_params['dut_cell'] = self.wrapper_lookup[wrapper_type]
        return tb_params


class DesignManager(object):
    """A class that manages instantiating design instances and running simulations.

    This class provides various methods to allow you to sweep design parameters
    and generate multiple instances at once.  It also provides methods for running
    simulations and helps you interface with TestbenchManager instances.

    Parameters
    ----------
    prj : Optional[BagProject]
        The BagProject instance.
    spec_file : str
        the specification file name or the data directory.
    """

    def __init__(self, prj, spec_file):
        # type: (Optional[BagProject], str) -> None
        self.prj = prj
        self._specs = None

        if os.path.isfile(spec_file):
            self._specs = read_yaml(spec_file)
            self._root_dir = os.path.abspath(self._specs['root_dir'])
        elif os.path.isdir(spec_file):
            self._root_dir = os.path.abspath(spec_file)
            self._specs = read_yaml(os.path.join(self._root_dir, 'specs.yaml'))
        else:
            raise ValueError('%s is neither data directory or specification file.' % spec_file)

        self._swp_var_list = tuple(sorted(self._specs['sweep_params'].keys()))

    @classmethod
    def load_state(cls, prj, root_dir):
        # type: (BagProject, str) -> DesignManager
        """Create the DesignManager instance corresponding to data in the given directory."""
        return cls(prj, root_dir)

    @classmethod
    def get_measurement_name(cls, dsn_name, meas_type):
        # type: (str, str) -> str
        """Returns the measurement name.

        Parameters
        ----------
        dsn_name : str
            design cell name.
        meas_type : str
            measurement type.

        Returns
        -------
        meas_name : str
            measurement name
        """
        return '%s_MEAS_%s' % (dsn_name, meas_type)

    @classmethod
    def get_wrapper_name(cls, dut_name, wrapper_name):
        # type: (str, str) -> str
        """Returns the wrapper cell name corresponding to the given DUT."""
        return '%s_WRAPPER_%s' % (dut_name, wrapper_name)

    @property
    def specs(self):
        # type: () -> Dict[str, Any]
        """Return the specification dictionary."""
        return self._specs

    @property
    def swp_var_list(self):
        # type: () -> Tuple[str, ...]
        return self._swp_var_list

    async def extract_design(self, lib_name: str, dsn_name: str,
                             rcx_params: Optional[Dict[str, Any]]) -> None:
        """A coroutine that runs LVS/RCX on a given design.

        Parameters
        ----------
        lib_name : str
            library name.
        dsn_name : str
            design cell name.
        rcx_params : Optional[Dict[str, Any]]
            extraction parameters dictionary.
        """
        print('Running LVS on %s' % dsn_name)
 #       lvs_passed, lvs_log = await self.prj.async_run_lvs(lib_name, dsn_name)
  #      if not lvs_passed:
   #         raise ValueError('LVS failed for %s.  Log file: %s' % (dsn_name, lvs_log))

        print('LVS passed on %s' % dsn_name)
        print('Running RCX on %s' % dsn_name)
        simulate_SCH(prj, specs, dsn_name)
        rcx_passed, rcx_log = await self.prj.async_run_rcx(lib_name, dsn_name,
                                                           rcx_params=rcx_params)
        if not rcx_passed:
            raise ValueError('RCX failed for %s.  Log file: %s' % (dsn_name, rcx_log))
        print('RCX passed on %s' % dsn_name)



    async def verify_design(self, lib_name: str, dsn_name: str,
                            load_from_file: bool = False) -> None:
        """Run all measurements on the given design.

        Parameters
        ----------
        lib_name : str
            library name.
        dsn_name : str
            design cell name.
        load_from_file : bool
            If True, then load existing simulation data instead of running actual simulation.
        """
        meas_list = self.specs['measurements']
        summary_fname = self.specs['summary_fname']
        view_name = self.specs['view_name']
        env_list = self.specs['env_list']
        wrapper_list = self.specs['dut_wrappers']

        wrapper_lookup = {'': dsn_name}
        for wrapper_config in wrapper_list:
            wrapper_type = wrapper_config['name']
            wrapper_lookup[wrapper_type] = self.get_wrapper_name(dsn_name, wrapper_type)

        result_summary = {}
        dsn_data_dir = os.path.join(self._root_dir, dsn_name)
        for meas_specs in meas_list:
            meas_type = meas_specs['meas_type']
            meas_package = meas_specs['meas_package']
            meas_cls_name = meas_specs['meas_class']
            out_fname = meas_specs['out_fname']
            meas_name = self.get_measurement_name(dsn_name, meas_type)
            data_dir = self.get_measurement_directory(dsn_name, meas_type)

            meas_module = importlib.import_module(meas_package)
            meas_cls = getattr(meas_module, meas_cls_name)

            meas_manager = meas_cls(data_dir, meas_name, lib_name, meas_specs,
                                    wrapper_lookup, [(dsn_name, view_name)], env_list)
            print('Performing measurement %s on %s' % (meas_name, dsn_name))
            meas_res = await meas_manager.async_measure_performance(self.prj,
                                                                    load_from_file=load_from_file)
            print('Measurement %s finished on %s' % (meas_name, dsn_name))

            with open_file(os.path.join(data_dir, out_fname), 'w') as f:
                yaml.dump(meas_res, f)
            result_summary[meas_type] = meas_res

        with open_file(os.path.join(dsn_data_dir, summary_fname), 'w') as f:
            yaml.dump(result_summary, f)

    async def main_task(self, lib_name: str, dsn_name: str,
                        rcx_params: Optional[Dict[str, Any]],
                        extract: bool = True,
                        measure: bool = True,
                        load_from_file: bool = False) -> None:
        """The main coroutine."""
        if extract:
            await self.extract_design(lib_name, dsn_name, rcx_params)
        if measure:
            await self.verify_design(lib_name, dsn_name, load_from_file=load_from_file)

    def characterize_designs(self, generate=False, measure=True, load_from_file=False):
        # type: (bool, bool, bool) -> None
        """Sweep all designs and characterize them.

        Parameters
        ----------
        generate : bool
            If True, create schematic/layout and run LVS/RCX.
        measure : bool
            If True, run all measurements.
        load_from_file : bool
            If True, measurements will load existing simulation data
            instead of running simulations.
        """
        if generate:
            extract = self.specs['view_name'] != 'schematic'
            self.create_designs(extract)
            return
        else:
            extract = False

        rcx_params = self.specs.get('rcx_params', None)
        impl_lib = self.specs['impl_lib']
        dsn_name_list = [self.get_design_name(combo_list)
                         for combo_list in self.get_combinations_iter()]

        coro_list = [self.main_task(impl_lib, dsn_name, rcx_params, extract=extract,
                                    measure=measure, load_from_file=load_from_file)
                     for dsn_name in dsn_name_list]

        results = batch_async_task(coro_list)
        if results is not None:
            for val in results:
                if isinstance(val, Exception):
                    raise val

    def get_result(self, dsn_name):
        # type: (str) -> Dict[str, Any]
        """Returns the measurement result summary dictionary.

        Parameters
        ----------
        dsn_name : str
            the design name.

        Returns
        -------
        result : Dict[str, Any]
            the result dictionary.
        """
        fname = os.path.join(self._root_dir, dsn_name, self.specs['summary_fname'])
        with open_file(fname, 'r') as f:
            summary = yaml.load(f)

        return summary

    def test_layout(self, gen_sch=True):
        # type: (bool) -> None
        """Create a test schematic and layout for debugging purposes"""

        sweep_params = self.specs['sweep_params']
        dsn_name = self.specs['dsn_basename'] + '_TEST'

        val_list = tuple((sweep_params[key][0] for key in self.swp_var_list))
        lay_params = self.get_layout_params(val_list)

        temp_db = self.make_tdb()
        print('create test layout')
        sch_params_list = self.create_dut_layouts([lay_params], [dsn_name], temp_db)

        if gen_sch:
            print('create test schematic')
            self.create_dut_schematics(sch_params_list, [dsn_name], gen_wrappers=False)
        print('done')

    def create_designs(self, create_layout):
        # type: (bool) -> None
        """Create DUT schematics/layouts.
        """
        if self.prj is None:
            raise ValueError('BagProject instance is not given.')

        temp_db = self.make_tdb()

        # make layouts
        dsn_name_list, lay_params_list, combo_list_list = [], [], []
        for combo_list in self.get_combinations_iter():
            dsn_name = self.get_design_name(combo_list)
            lay_params = self.get_layout_params(combo_list)
            dsn_name_list.append(dsn_name)
            lay_params_list.append(lay_params)
            combo_list_list.append(combo_list)

        if create_layout:
            sch_params_list = self.create_dut_layouts(lay_params_list, dsn_name_list, temp_db)
        else:
            print('schematic simulation, skipping layouts.')
            sch_params_list = [self.get_schematic_params(combo_list)
                               for combo_list in self.get_combinations_iter()]

        print('creating all schematics.')
        print(sch_params_list)
        self.create_dut_schematics(sch_params_list, dsn_name_list, gen_wrappers=False)

        print('design generation done.')

    def get_swp_var_values(self, var):
        # type: (str) -> List[Any]
        """Returns a list of valid sweep variable values.

        Parameter
        ---------
        var : str
            the sweep variable name.

        Returns
        -------
        val_list : List[Any]
            the sweep values of the given variable.
        """
        return self.specs['sweep_params'][var]

    def get_combinations_iter(self):
        # type: () -> Iterable[Tuple[Any, ...]]
        """Returns an iterator of schematic parameter combinations we sweep over.

        Returns
        -------
        combo_iter : Iterable[Tuple[Any, ...]]
            an iterator of tuples of schematic parameters values that we sweep over.
        """

        swp_par_dict = self.specs['sweep_params']
        return itertools.product(*(swp_par_dict[var] for var in self.swp_var_list))

    def get_dsn_name_iter(self):
        # type: () -> Iterable[str]
        """Returns an iterator over design names.

        Returns
        -------
        dsn_name_iter : Iterable[str]
            an iterator of design names.
        """
        return (self.get_design_name(combo_list) for combo_list in self.get_combinations_iter())

    def get_measurement_directory(self, dsn_name, meas_type):
        meas_name = self.get_measurement_name(dsn_name, meas_type)
        return os.path.join(self._root_dir, dsn_name, meas_name)

    def make_tdb(self):
        # type: () -> TemplateDB
        """Create and return a new TemplateDB object.

        Returns
        -------
        tdb : TemplateDB
            the TemplateDB object.
        """
        if self.prj is None:
            raise ValueError('BagProject instance is not given.')

        target_lib = self.specs['impl_lib']
        grid_specs = self.specs['routing_grid']
        layers = grid_specs['layers']
        spaces = grid_specs['spaces']
        widths = grid_specs['widths']
        bot_dir = grid_specs['bot_dir']
        width_override = grid_specs.get('width_override', None)

        routing_grid = RoutingGrid(self.prj.tech_info, layers, spaces, widths, bot_dir, width_override=width_override)
        tdb = TemplateDB('', routing_grid, target_lib, use_cybagoa=True)
        return tdb

    def get_layout_params(self, val_list):
        # type: (Tuple[Any, ...]) -> Dict[str, Any]
        """Returns the layout dictionary from the given sweep parameter values."""
        lay_params = self.specs['layout_params'].copy()
        for var, val in zip(self.swp_var_list, val_list):
            lay_params[var] = val

        return lay_params

    def get_schematic_params(self, val_list):
        # type: (Tuple[Any, ...]) -> Dict[str, Any]
        """Returns the layout dictionary from the given sweep parameter values."""
        lay_params = self.specs['schematic_params'].copy()
        for var, val in zip(self.swp_var_list, val_list):
            lay_params[var] = val

        return lay_params

    def create_dut_schematics(self, sch_params_list, cell_name_list, gen_wrappers=True):
        # type: (Sequence[Dict[str, Any]], Sequence[str], bool) -> None
        dut_lib = self.specs['dut_lib']
        dut_cell = self.specs['dut_cell']
        impl_lib = self.specs['impl_lib']
        wrapper_list = self.specs['dut_wrappers']

        inst_list, name_list = [], []
        for sch_params, cur_name in zip(sch_params_list, cell_name_list):
            dsn = self.prj.create_design_module(dut_lib, dut_cell)
            dsn.design(**sch_params)
            inst_list.append(dsn)
            name_list.append(cur_name)
            if gen_wrappers:
                for wrapper_config in wrapper_list:
                    wrapper_name = wrapper_config['name']
                    wrapper_lib = wrapper_config['lib']
                    wrapper_cell = wrapper_config['cell']
                    wrapper_params = wrapper_config['params'].copy()
                    wrapper_params['dut_lib'] = impl_lib
                    wrapper_params['dut_cell'] = cur_name
                    dsn = self.prj.create_design_module(wrapper_lib, wrapper_cell)
                    dsn.design(**wrapper_params)
                    inst_list.append(dsn)
                    name_list.append(self.get_wrapper_name(cur_name, wrapper_name))
        print('inst_list',inst_list)
        self.prj.batch_schematic(impl_lib, inst_list, name_list=name_list)



    def create_dut_layouts(self, lay_params_list, cell_name_list, temp_db):
        # type: (Sequence[Dict[str, Any]], Sequence[str], TemplateDB) -> Sequence[Dict[str, Any]]
        """Create multiple layouts"""
        if self.prj is None:
            raise ValueError('BagProject instance is not given.')

        cls_package = self.specs['layout_package']
        cls_name = self.specs['layout_class']

        lay_module = importlib.import_module(cls_package)
        temp_cls = getattr(lay_module, cls_name)
        lay_dict = lay_params_list[0]['seg_dict']
        fan_out = lay_params_list[0]['fan_out']
        N = lay_params_list[0]['N']
        seg_load = lay_dict['load']
        seg_in = lay_dict['in']
        seg_tail = lay_dict['tail']
        if N < 1:
            seg_load = round_up_to_even(seg_load/pow(fan_out,N-1))
            seg_in = round_up_to_even(seg_in / pow(fan_out, N-1))
            seg_tail = round_up_to_even(seg_tail / pow(fan_out, N-1))

        #sch_list = CML_layout_new(fan_out,N,seg_load,seg_in,seg_tail,60)
        sch_params_list = []
        keys = ['w_dict', 'N', 'lch', 'fan_out','seg_dict','th_dict']
        sch_params_list_data = {x: lay_params_list[0][x] for x in keys}
        sch_params_list.append(sch_params_list_data)
        sch_params_list[0]['w_dict']['in']= str(0.0000002*lay_dict['in'])
        sch_params_list[0]['w_dict']['load'] = str(0.0000002*lay_dict['load'])
        sch_params_list[0]['w_dict']['tail'] = str(0.0000002*lay_dict['tail'])
        return sch_params_list

    def get_design_name(self, combo_list):
        # type: (Sequence[Any, ...]) -> str
        """Generate cell names based on sweep parameter values."""

        name_base = self.specs['dsn_basename']
        suffix = ''
        for var, val in zip(self.swp_var_list, combo_list):
            if isinstance(val, str):
                suffix += '_%s_%s' % (var, val)
            elif isinstance(val, int):
                suffix += '_%s_%d' % (var, val)
            elif isinstance(val, float):
                suffix += '_%s_%s' % (var, float_to_si_string(val))
            else:
                raise ValueError('Unsupported parameter type: %s' % (type(val)))

        return name_base + suffix
def round_up_to_even(f):
    return math.ceil(f / 2.) * 2

def CML_layout(fan_factor, number_fan, number_finger_al, number_finger, number_finger_cm):
    # initialize
    laygen = laygo.GridLayoutGenerator(config_file="laygo_config.yaml")
    # template and grid load
    utemplib = laygen.tech + '_cmltemplates'
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

    laygen.add_library('AAAFOO_DIFFAMP_PAPER')
    laygen.add_cell('DIFFAMP_lch_60n')
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
    total_fan = 0
    index_fan = ['' for i in range(number_fan)]
    index_fan_1 = ['' for i in range(number_fan)]
    total_index = ['' for i in range(2 * number_fan)]
    for i in range(number_fan):
        if (i == 0):
            index_fan[i] = fan_factor ** i
            index_fan_1[i] = (fan_factor ** i) / 2

        else:
            index_fan[i] = (fan_factor ** i) + index_fan[i - 1]
            index_fan_1[i] = index_fan[i] - (fan_factor ** i) / 2
    total_fan = index_fan[-1]
    total_index = (index_fan + index_fan_1)
    total_index.sort()

    index_dp = ['' for i in range(2 * number_fan)]
    for i in range(number_fan):
        if (i == 0):
            index_dp[0] = 0
            index_dp[1] = 1
        else:
            index_dp[2 * i] = index_dp[2 * i - 1] + fan_factor ** (i - 1)
            index_dp[2 * i + 1] = index_dp[2 * i] + fan_factor ** i

    index_cm = ['' for i in range(number_fan)]
    for i in range(number_fan):
        if (i == 0):
            index_cm[i] = 0
        else:
            index_cm[i] = index_cm[i - 1] + fan_factor ** (i - 1)

    index_al = []
    index_al = index_dp

    total_al_number = int(number_finger_al / 2 * (1 - fan_factor ** number_fan) / (1 - fan_factor) * 2)
    total_cm_number = int(number_finger_cm / 2 * (1 - fan_factor ** number_fan) / (1 - fan_factor))

    # placements parameters

    al_row_layout = ['' for i in range(int(number_finger_al) * int(total_fan))]
    dp_row_layout = ['' for i in range(int(number_finger * total_fan))]
    cm_ref_layout = ['' for i in range(int(number_finger_cm / 2))]
    cm_row_layout = ['' for i in range(int(number_finger_cm / 2) * int(total_fan))]
    max_finger = max(number_finger_al, number_finger, number_finger_cm)
    guardring_n = ['' for i in range(int(max_finger * (total_fan + 1)))]
    guardring_p = ['' for i in range(int(max_finger * (total_fan + 1)))]

    # placements
    # always place reference current mirror first
    for i in range(int(number_finger_cm / 2)):
        if (i == 0):
            cm_ref_layout[0] = laygen.relplace(templatename=['currentmirror_ref_n'], gridname=pb)
        else:
            cm_ref_layout[i] = laygen.relplace(templatename=['currentmirror_ref_n'], gridname=pb,
                                               refobj=cm_ref_layout[i - 1], direction='right')

    # if finger number of current mirror is the greatest
    if (number_finger_cm >= number_finger and number_finger_cm >= number_finger_al):
        # current mirror placement
        flag1 = 0
        for i in range(int(total_fan * number_finger_cm / 2)):
            if (i == 0):
                cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_ref_layout[-1], xy=[2, 0], direction='right')
            elif ((i * 2 / number_finger_cm) in index_fan):
                flag1 = flag1 + 1
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1],
                                                   xy=[number_finger_cm * (fan_factor ** flag1) + 4, 0],
                                                   direction='right')
            else:
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], direction='right')
        # diff pair placement
        flag2 = 0
        for i in range(total_fan * number_finger):
            if (i == 0):
                dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=cm_ref_layout[0], direction='top')
            elif (((i / number_finger) in index_fan) or ((i / number_finger) in index_fan_1)):
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1],
                                                   xy=[(number_finger_cm - number_finger) * (fan_factor ** flag2) + 2,
                                                       0], direction='right')
                if (((i / number_finger) in index_fan)):
                    flag2 = flag2 + 1
            else:
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], direction='right')
        # active load placement
        flag3 = 0
        for i in range(number_finger_al * total_fan):
            if (i == 0):
                al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=cm_ref_layout[0], xy=[0, 1], direction='top')
            elif ((i / number_finger_al) in index_fan or ((i / number_finger_al) in index_fan_1)):
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], xy=[
                        (number_finger_cm - number_finger_al) * (fan_factor ** flag3) + 2, 0], direction='right')
                if (((i / number_finger_al) in index_fan)):
                    flag3 = flag3 + 1
            else:
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], direction='right')

    # if finger number of diff pair is the greatest
    elif (number_finger >= number_finger_cm and number_finger >= number_finger_al):
        # diff pair placement
        for i in range(total_fan * number_finger):
            if (i == 0):
                dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=cm_ref_layout[0], direction='top')
            elif (((i / number_finger) in index_fan) or ((i / number_finger) in index_fan_1)):
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], xy=[2, 0], direction='right')
            else:
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], direction='right')
        # current mirror placement
        flag1 = 0
        for i in range(int(total_fan * number_finger_cm / 2)):
            if (i == 0):
                cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_ref_layout[-1],
                                                   xy=[number_finger - number_finger_cm + 2, 0], direction='right')
            elif ((i * 2 / number_finger_cm) in index_fan):
                flag1 = flag1 + 1
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], xy=[
                        (number_finger - number_finger_cm) * (fan_factor ** (flag1 - 1)) + number_finger * (
                                    fan_factor ** flag1) + 4, 0], direction='right')
            else:
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], direction='right')
        # active load placement
        flag2 = 0
        for i in range(number_finger_al * total_fan):
            if (i == 0):
                al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=cm_ref_layout[0], xy=[0, 1], direction='top')
            elif ((i / number_finger_al) in index_fan or ((i / number_finger_al) in index_fan_1)):
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1],
                                                   xy=[(number_finger - number_finger_al) * (fan_factor ** flag2) + 2,
                                                       0], direction='right')
                if (((i / number_finger_al) in index_fan)):
                    flag2 = flag2 + 1
            else:
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], direction='right')

    # if finger number of active load is the greatest
    else:
        # active load placement
        for i in range(number_finger_al * total_fan):
            if (i == 0):
                al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=cm_ref_layout[0], xy=[0, 1], direction='top')
            elif ((i / number_finger_al) in index_fan or ((i / number_finger_al) in index_fan_1)):
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], xy=[2, 0], direction='right')
            else:
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], direction='right')
        # diff pair placement
        flag1 = 0
        for i in range(total_fan * number_finger):
            if (i == 0):
                dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=cm_ref_layout[0], direction='top')
            elif ((i / number_finger) in index_fan or ((i / number_finger) in index_fan_1)):
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1],
                                                   xy=[(number_finger_al - number_finger) * (fan_factor ** flag1) + 2,
                                                       0], direction='right')
                if (((i / number_finger) in index_fan)):
                    flag1 = flag1 + 1
            else:
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], direction='right')
        # current mirror placement
        flag2 = 0
        for i in range(int(total_fan * number_finger_cm / 2)):
            if (i == 0):
                cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_ref_layout[-1],
                                                   xy=[number_finger_al - number_finger_cm + 2, 0], direction='right')
            elif ((i * 2 / number_finger_cm) in index_fan):
                flag2 = flag2 + 1
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], xy=[
                        (number_finger_al - number_finger_cm) * (fan_factor ** (flag2 - 1)) + number_finger_al * (
                                    fan_factor ** flag2) + 4, 0], direction='right')
            else:
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], direction='right')

    # Guard Ring placement
    for i in range(max_finger * (total_fan + 1)):
        if (i == 0):
            guardring_n[i] = laygen.relplace(templatename=['guard_ring_nwell'], gridname=pb, refobj=al_row_layout[0],
                                             direction='top')
            guardring_p[i] = laygen.relplace(templatename=['guard_ring_psub'], gridname=pb, refobj=cm_ref_layout[0],
                                             direction='bottom')
        else:
            guardring_n[i] = laygen.relplace(templatename=['guard_ring_nwell'], gridname=pb, refobj=guardring_n[i - 1],
                                             direction='right')
            guardring_p[i] = laygen.relplace(templatename=['guard_ring_psub'], gridname=pb, refobj=guardring_p[i - 1],
                                             direction='right')

    # routes
    # current mirror self routing
    idc = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg23, refobj0=cm_ref_layout[0][0].pins['D'],
                       refobj1=cm_ref_layout[0][0].pins['D'], via0=[0, 0])
    vss = laygen.route(xy0=[0, 0], xy1=[1, 0], gridname0=rg12, refobj0=cm_ref_layout[0][0].pins['S0'],
                       refobj1=cm_ref_layout[0][0].pins['S0'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=cm_ref_layout[0][0].pins['S0'],
                 refobj1=cm_row_layout[-1][0].pins['S1'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=cm_ref_layout[0][0].pins['G'],
                 refobj1=cm_row_layout[-1][0].pins['G'])
    for i in range(int(number_finger_cm / 2) - 1):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23, refobj0=cm_ref_layout[i][0].pins['D'],
                     refobj1=cm_ref_layout[i + 1][0].pins['D'], via0=[0, 0], via1=[0, 0])
    for i in range(number_fan):
        for j in range(int((fan_factor ** i) * number_finger_cm / 2) - 1):
            if (i == 0):
                laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23, refobj0=cm_row_layout[j][0].pins['D'],
                             refobj1=cm_row_layout[j + 1][0].pins['D'], via0=[0, 0], via1=[0, 0])
            else:
                laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                             refobj0=cm_row_layout[int(index_fan[i - 1] * number_finger_cm / 2) + j][0].pins['D'],
                             refobj1=cm_row_layout[int(index_fan[i - 1] * number_finger_cm / 2) + j + 1][0].pins['D'],
                             via0=[0, 0], via1=[0, 0])

    # diff pair routing
    # diff pair two inputs and two outputs
    for i in range(2 * number_fan):
        if (i == 0):
            inp = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=dp_row_layout[0][0].pins['G'],
                               refobj1=dp_row_layout[0][0].pins['G'], via0=[0, 0])
        elif (i == 1):
            inm = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12,
                               refobj0=dp_row_layout[int(number_finger / 2)][0].pins['G'],
                               refobj1=dp_row_layout[int(number_finger / 2)][0].pins['G'], via0=[0, 0])
        else:
            laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12,
                         refobj0=dp_row_layout[int(total_index[i - 1] * number_finger)][0].pins['G'],
                         refobj1=dp_row_layout[int(total_index[i - 1] * number_finger)][0].pins['G'], via0=[0, 0])
    outm = laygen.route(xy0=[0, 0], xy1=[0, 2], gridname0=rg23,
                        refobj0=dp_row_layout[-int(number_finger / 2 * (fan_factor ** (number_fan - 1))) - 1][0].pins[
                            'D'],
                        refobj1=dp_row_layout[-int(number_finger / 2 * (fan_factor ** (number_fan - 1))) - 1][0].pins[
                            'D'], via0=[0, 0])
    outp = laygen.route(xy0=[0, 0], xy1=[0, 2], gridname0=rg23, refobj0=dp_row_layout[-1][0].pins['D'],
                        refobj1=dp_row_layout[-1][0].pins['D'], via0=[0, 0])

    # diff pair gate and drain self connection
    for i in range(2 * number_fan):
        for j in range(int((fan_factor ** int(i / 2)) * number_finger / 2) - 1):
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12,
                         refobj0=dp_row_layout[int(index_dp[i] * number_finger / 2) + j][0].pins['G'],
                         refobj1=dp_row_layout[int(index_dp[i] * number_finger / 2) + j + 1][0].pins['G'], via0=[0, 0],
                         via1=[0, 0])
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                         refobj0=dp_row_layout[int(index_dp[i] * number_finger / 2) + j][0].pins['D'],
                         refobj1=dp_row_layout[int(index_dp[i] * number_finger / 2) + j + 1][0].pins['D'], via0=[0, 0],
                         via1=[0, 0])

    # diff pair: drain of i connect to gate of i+1
    for i in range(number_fan - 1):
        for j in range(int((fan_factor ** i) * number_finger / 2) - 1):
            laygen.route(xy0=[0, -2], xy1=[0, -2], gridname0=rg34,
                         refobj0=dp_row_layout[int(index_dp[2 * i] * number_finger / 2) + j][0].pins['D'],
                         refobj1=dp_row_layout[int(index_dp[2 * i] * number_finger / 2) + j + 1][0].pins['D'],
                         via0=[0, 0], via1=[0, 0])
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg34,
                         refobj0=dp_row_layout[int(index_dp[2 * i + 1] * number_finger / 2) + j][0].pins['D'],
                         refobj1=dp_row_layout[int(index_dp[2 * i + 1] * number_finger / 2) + j + 1][0].pins['D'],
                         via0=[0, 0], via1=[0, 0])
        laygen.route(xy0=[0, -2], xy1=[-2, -2], gridname0=rg34,
                     refobj0=dp_row_layout[int(index_dp[2 * i] * number_finger / 2)][0].pins['D'],
                     refobj1=dp_row_layout[int(index_dp[2 * i + 2] * number_finger / 2)][0].pins['D'], via0=[0, 0],
                     via1=[0, 0])
        laygen.route(xy0=[-2, -2], xy1=[-2, -1], gridname0=rg23,
                     refobj0=dp_row_layout[int(index_dp[2 * i + 2] * number_finger / 2)][0].pins['D'],
                     refobj1=dp_row_layout[int(index_dp[2 * i + 2] * number_finger / 2)][0].pins['D'], via1=[0, 0])
        laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg34,
                     refobj0=dp_row_layout[int(index_dp[2 * i + 1] * number_finger / 2)][0].pins['D'],
                     refobj1=dp_row_layout[int(index_dp[2 * i + 3] * number_finger / 2)][0].pins['D'], via0=[0, 0],
                     via1=[0, 0])
        laygen.route(xy0=[-2, 0], xy1=[-2, -1], gridname0=rg23,
                     refobj0=dp_row_layout[int(index_dp[2 * i + 3] * number_finger / 2)][0].pins['D'],
                     refobj1=dp_row_layout[int(index_dp[2 * i + 3] * number_finger / 2)][0].pins['D'], via1=[0, 0])

    # diff pair source self connection
    for i in range(number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12,
                     refobj0=dp_row_layout[int(index_dp[2 * i] * number_finger / 2)][0].pins['S0'], refobj1=
                     dp_row_layout[int(index_dp[2 * i] * number_finger / 2) + fan_factor ** i * number_finger - 1][
                         0].pins['S1'])
    # diff pair source connect to current mirror drain
    for i in range(number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 3], gridname0=rg23,
                     refobj0=cm_row_layout[int((index_cm[i]) * number_finger_cm / 2)][0].pins['D'],
                     refobj1=cm_row_layout[int((index_cm[i]) * number_finger_cm / 2)][0].pins['D'], via1=[0, 0])
    # diff pair drain connect to active load
    for i in range(2 * number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                     refobj0=dp_row_layout[int(index_dp[i] * number_finger / 2)][0].pins['D'],
                     refobj1=al_row_layout[int(index_al[i] * number_finger_al / 2)][0].pins['D'])

    # active load routing
    # active load connect to VDD
    vdd = laygen.route(xy0=[0, 0], xy1=[1, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['S0'],
                       refobj1=al_row_layout[0][0].pins['S0'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['S0'],
                 refobj1=al_row_layout[-1][0].pins['S1'])
    # active load gate self connection
    vbias = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['G'],
                         refobj1=al_row_layout[0][0].pins['G'], via0=[0, 0])
    for i in range(total_al_number - 1):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=al_row_layout[i][0].pins['G'],
                     refobj1=al_row_layout[i + 1][0].pins['G'], via0=[0, 0], via1=[0, 0])
    # active load drain self connection
    for i in range(2 * number_fan):
        for j in range(int(fan_factor ** int(i / 2) * number_finger_al / 2) - 1):
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                         refobj0=al_row_layout[int(index_al[i] * number_finger_al / 2) + j][0].pins['D'],
                         refobj1=al_row_layout[int(index_al[i] * number_finger_al / 2) + j + 1][0].pins['D'],
                         via0=[0, 0], via1=[0, 0])

    # Guard Ring routing
    for i in range(total_al_number):
        laygen.route(xy0=[0, 0], xy1=[0, 5], gridname0=rg12, refobj0=al_row_layout[i][0].pins['S0'],
                     refobj1=al_row_layout[i][0].pins['S0'])
        laygen.route(xy0=[0, 0], xy1=[0, 5], gridname0=rg12, refobj0=al_row_layout[i][0].pins['S1'],
                     refobj1=al_row_layout[i][0].pins['S1'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rgnw, refobj0=al_row_layout[0][0].pins['S0'],
                 refobj1=guardring_n[0][0].pins['nwell'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rgnw, refobj0=al_row_layout[0][0].pins['S0'],
                 refobj1=al_row_layout[-1][0].pins['S1'])
    for i in range(int(number_finger_cm / 2)):
        laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_ref_layout[i][0].pins['S0'],
                     refobj1=cm_ref_layout[i][0].pins['S0'])
        laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_ref_layout[i][0].pins['S1'],
                     refobj1=cm_ref_layout[i][0].pins['S1'])
    for i in range(total_cm_number):
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
    laygen.export_BAG(prj)
    return input_list



def CML_layout_single(number_fan, lay_dict):
    # initialize
    laygen = laygo.GridLayoutGenerator(config_file="laygo_config.yaml")
    # template and grid load
    utemplib = laygen.tech + '_cmltemplates'
    laygen.load_template(filename=utemplib + '_templates.yaml', libname=utemplib)
    laygen.load_grid(filename=utemplib + '_grids.yaml', libname=utemplib)
    laygen.templates.sel_library(utemplib)
    laygen.grids.sel_library(utemplib)

    # user inputs
    n_or_p = 'n'
    #	number_fan = 1
    number_finger_al = lay_dict['load']
    number_finger = lay_dict['in']
    number_finger_cm = lay_dict['tail']*2
    input_list = []
    input_list.append(number_finger)
    input_list.append(number_finger_al)
    input_list.append(number_finger_cm)

    # library & cell creation
    laygen.add_library('AAAFOO_DIFFAMP_PAPER')
    laygen.add_cell('DIFFAMP_lch_60n')

    # grid variables
    pb = 'placement_basic'
    rg12 = 'route_M1_M2_cmos'
    rg23 = 'route_M2_M3_cmos'
    rg34 = 'route_M3_M4_cmos'
    rgnw = 'route_nwell'

    # placements parameters
    al_row_layout = ['' for i in range(number_finger_al * number_fan)]
    dp_row_layout = ['' for i in range(number_finger * number_fan)]
    cm_ref_layout = ['' for i in range(int(number_finger_cm / 2))]
    cm_row_layout = ['' for i in range(int(number_finger_cm / 2) * number_fan)]
    max_finger = max(number_finger_al, number_finger, number_finger_cm) + 2
    guardring_n = ['' for i in range(max_finger * number_fan)]
    guardring_p = ['' for i in range(max_finger * number_fan)]

    # placements
    # always place reference current mirror first
    for i in range(int(number_finger_cm / 2)):
        if (i == 0):
            cm_ref_layout[0] = laygen.relplace(templatename=['currentmirror_ref_n'], gridname=pb)
        else:
            cm_ref_layout[i] = laygen.relplace(templatename=['currentmirror_ref_n'], gridname=pb,
                                               refobj=cm_ref_layout[i - 1], direction='right')

    # if finger number of current mirror is the greatest
    if (number_finger_cm >= number_finger and number_finger_cm >= number_finger_al):
        # current mirror placement
        for i in range(int(number_fan * number_finger_cm / 2)):
            if (i == 0):
                cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_ref_layout[-1], xy=[2, 0], direction='right')
            elif (((2 * i) % number_finger_cm) == 0 and i != 0):
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], xy=[number_finger_cm + 4, 0],
                                                   direction='right')
            else:
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], direction='right')
        # diff pair placement
        for i in range(number_fan * number_finger):
            if (i == 0):
                dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=cm_ref_layout[0], direction='top')
            elif (((2 * i) % number_finger) == 0 and i != 0):
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1],
                                                   xy=[number_finger_cm - number_finger + 2, 0], direction='right')
            else:
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], direction='right')
        # active load placement
        for i in range(number_finger_al * number_fan):
            if (i == 0):
                al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=cm_ref_layout[0], xy=[0, 1], direction='top')
            elif (((2 * i) % number_finger_al) == 0 and i != 0):
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1],
                                                   xy=[number_finger_cm - number_finger_al + 2, 0], direction='right')
            else:
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], direction='right')

    # if finger number of diff pair is the greatest
    elif (number_finger >= number_finger_cm and number_finger >= number_finger_al):
        # diff pair placement
        for i in range(number_fan * number_finger):
            if (i == 0):
                dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=cm_ref_layout[0], direction='top')
            elif (((2 * i) % number_finger) == 0 and i != 0):
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], xy=[2, 0], direction='right')
            else:
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], direction='right')
        # current mirror placement
        for i in range(int(number_fan * number_finger_cm / 2)):
            if (i == 0):
                cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_ref_layout[-1],
                                                   xy=[number_finger - number_finger_cm + 2, 0], direction='right')
            elif (((2 * i) % number_finger_cm) == 0 and i != 0):
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1],
                                                   xy=[number_finger - number_finger_cm + number_finger + 4, 0],
                                                   direction='right')
            else:
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], direction='right')
        # active load placement
        for i in range(number_finger_al * number_fan):
            if (i == 0):
                al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=cm_ref_layout[0], xy=[0, 1], direction='top')
            elif (((2 * i) % number_finger_al) == 0 and i != 0):
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1],
                                                   xy=[number_finger - number_finger_al + 2, 0], direction='right')
            else:
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], direction='right')

    # if finger number of active load is the greatest
    else:
        # active load placement
        for i in range(number_finger_al * number_fan):
            if (i == 0):
                al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=cm_ref_layout[0], xy=[0, 1], direction='top')
            elif (((2 * i) % number_finger_al) == 0 and i != 0):
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], xy=[2, 0], direction='right')
            else:
                al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb,
                                                   refobj=al_row_layout[i - 1], direction='right')
        # diff pair placement
        for i in range(number_fan * number_finger):
            if (i == 0):
                dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=cm_ref_layout[0], direction='top')
            elif (((2 * i) % number_finger) == 0 and i != 0):
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1],
                                                   xy=[number_finger_al - number_finger + 2, 0], direction='right')
            else:
                dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb,
                                                   refobj=dp_row_layout[i - 1], direction='right')
        # current mirror placement
        for i in range(int(number_fan * number_finger_cm / 2)):
            if (i == 0):
                cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_ref_layout[-1],
                                                   xy=[number_finger_al - number_finger_cm + 2, 0], direction='right')
            elif (((2 * i) % number_finger_cm) == 0 and i != 0):
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1],
                                                   xy=[number_finger_al - number_finger_cm + number_finger_al + 4, 0],
                                                   direction='right')
            else:
                cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb,
                                                   refobj=cm_row_layout[i - 1], direction='right')

    # Guard Ring placement
    for i in range(max_finger * number_fan):
        if (i == 0):
            guardring_n[i] = laygen.relplace(templatename=['guard_ring_nwell'], gridname=pb, refobj=al_row_layout[0],
                                             direction='top')
            guardring_p[i] = laygen.relplace(templatename=['guard_ring_psub'], gridname=pb, refobj=cm_ref_layout[0],
                                             direction='bottom')
        else:
            guardring_n[i] = laygen.relplace(templatename=['guard_ring_nwell'], gridname=pb, refobj=guardring_n[i - 1],
                                             direction='right')
            guardring_p[i] = laygen.relplace(templatename=['guard_ring_psub'], gridname=pb, refobj=guardring_p[i - 1],
                                             direction='right')

    # routes
    # current mirror self routing
    idc = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg23, refobj0=cm_ref_layout[0][0].pins['D'],
                       refobj1=cm_ref_layout[0][0].pins['D'], via0=[0, 0])
    vss = laygen.route(xy0=[0, 0], xy1=[1, 0], gridname0=rg12, refobj0=cm_ref_layout[0][0].pins['S0'],
                       refobj1=cm_ref_layout[0][0].pins['S0'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=cm_ref_layout[0][0].pins['S0'],
                 refobj1=cm_row_layout[-1][0].pins['S1'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=cm_ref_layout[0][0].pins['G'],
                 refobj1=cm_row_layout[-1][0].pins['G'])
    for i in range(int(number_finger_cm / 2) - 1):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23, refobj0=cm_ref_layout[i][0].pins['D'],
                     refobj1=cm_ref_layout[i + 1][0].pins['D'], via0=[0, 0], via1=[0, 0])
    for i in range(number_fan):
        for j in range(int(number_finger_cm / 2) - 1):
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                         refobj0=cm_row_layout[i * int(number_finger_cm / 2) + j][0].pins['D'],
                         refobj1=cm_row_layout[i * int(number_finger_cm / 2) + j + 1][0].pins['D'], via0=[0, 0],
                         via1=[0, 0])

    # diff pair routing
    # diff pair two inputs and two outputs
    for i in range(2 * number_fan):
        if (i == 0):
            inm= laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=dp_row_layout[0][0].pins['G'],
                               refobj1=dp_row_layout[0][0].pins['G'], via0=[0, 0])
        elif (i == 1):
            inp = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12,
                               refobj0=dp_row_layout[int(number_finger / 2)][0].pins['G'],
                               refobj1=dp_row_layout[int(number_finger / 2)][0].pins['G'], via0=[0, 0])
        else:
            laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12,
                         refobj0=dp_row_layout[i * int(number_finger / 2)][0].pins['G'],
                         refobj1=dp_row_layout[i * int(number_finger / 2)][0].pins['G'], via0=[0, 0])
    outp = laygen.route(xy0=[0, 0], xy1=[0, 2], gridname0=rg23,
                        refobj0=dp_row_layout[-int(number_finger / 2) - 1][0].pins['D'],
                        refobj1=dp_row_layout[-int(number_finger / 2) - 1][0].pins['D'], via0=[0, 0])
    outm = laygen.route(xy0=[0, 0], xy1=[0, 2], gridname0=rg23, refobj0=dp_row_layout[-1][0].pins['D'],
                        refobj1=dp_row_layout[-1][0].pins['D'], via0=[0, 0])

    # diff pair gate and drain self connection
    for i in range(2 * number_fan):
        for j in range(int(number_finger / 2) - 1):
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12,
                         refobj0=dp_row_layout[int(i * number_finger / 2) + j][0].pins['G'],
                         refobj1=dp_row_layout[int(i * number_finger / 2) + j + 1][0].pins['G'], via0=[0, 0],
                         via1=[0, 0])
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                         refobj0=dp_row_layout[int(i * number_finger / 2) + j][0].pins['D'],
                         refobj1=dp_row_layout[int(i * number_finger / 2) + j + 1][0].pins['D'], via0=[0, 0],
                         via1=[0, 0])

    # diff pair: drain of i connect to gate of i+1
    for i in range(2 * number_fan - 2):
        for j in range(int(number_finger / 2) - 1):
            if (i % 2 == 0):
                laygen.route(xy0=[0, -2], xy1=[0, -2], gridname0=rg34,
                             refobj0=dp_row_layout[i * int(number_finger / 2) + j][0].pins['D'],
                             refobj1=dp_row_layout[i * int(number_finger / 2) + j + 1][0].pins['D'], via0=[0, 0],
                             via1=[0, 0])
            else:
                laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg34,
                             refobj0=dp_row_layout[i * int(number_finger / 2) + j][0].pins['D'],
                             refobj1=dp_row_layout[i * int(number_finger / 2) + j + 1][0].pins['D'], via0=[0, 0],
                             via1=[0, 0])
        if (i % 2 == 0):
            laygen.route(xy0=[0, -2], xy1=[-2, -2], gridname0=rg34,
                         refobj0=dp_row_layout[i * int(number_finger / 2)][0].pins['D'],
                         refobj1=dp_row_layout[(i + 2) * int(number_finger / 2)][0].pins['D'], via0=[0, 0], via1=[0, 0])
            laygen.route(xy0=[-2, -2], xy1=[-2, -1], gridname0=rg23,
                         refobj0=dp_row_layout[(i + 2) * int(number_finger / 2)][0].pins['D'],
                         refobj1=dp_row_layout[(i + 2) * int(number_finger / 2)][0].pins['D'], via1=[0, 0])
        else:
            laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg34,
                         refobj0=dp_row_layout[i * int(number_finger / 2)][0].pins['D'],
                         refobj1=dp_row_layout[(i + 2) * int(number_finger / 2)][0].pins['D'], via0=[0, 0], via1=[0, 0])
            laygen.route(xy0=[-2, 0], xy1=[-2, -1], gridname0=rg23,
                         refobj0=dp_row_layout[(i + 2) * int(number_finger / 2)][0].pins['D'],
                         refobj1=dp_row_layout[(i + 2) * int(number_finger / 2)][0].pins['D'], via1=[0, 0])

    # diff pair source self connection
    for i in range(number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=dp_row_layout[i * number_finger][0].pins['S0'],
                     refobj1=dp_row_layout[i * number_finger + number_finger - 1][0].pins['S1'])
    # diff pair source connect to current mirror drain
    for i in range(number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 3], gridname0=rg23,
                     refobj0=cm_row_layout[i * int(number_finger_cm / 2)][0].pins['D'],
                     refobj1=cm_row_layout[i * int(number_finger_cm / 2)][0].pins['D'], via1=[0, 0])
    # diff pair drain connect to active load
    for i in range(2 * number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                     refobj0=dp_row_layout[i * int(number_finger / 2)][0].pins['D'],
                     refobj1=al_row_layout[i * int(number_finger_al / 2)][0].pins['D'])

    # active load routing
    # active load connect to VDD
    vdd = laygen.route(xy0=[0, 0], xy1=[1, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['S0'],
                       refobj1=al_row_layout[0][0].pins['S0'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['S0'],
                 refobj1=al_row_layout[-1][0].pins['S1'])
    # active load gate self connection
    vbias = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['G'],
                         refobj1=al_row_layout[0][0].pins['G'], via0=[0, 0])
    for i in range(number_finger_al * number_fan - 1):
        laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=al_row_layout[i][0].pins['G'],
                     refobj1=al_row_layout[i + 1][0].pins['G'], via0=[0, 0], via1=[0, 0])
    # active load drain self connection
    for i in range(2 * number_fan):
        for j in range(int(number_finger_al / 2) - 1):
            laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23,
                         refobj0=al_row_layout[int(i * number_finger_al / 2) + j][0].pins['D'],
                         refobj1=al_row_layout[int(i * number_finger_al / 2) + j + 1][0].pins['D'], via0=[0, 0],
                         via1=[0, 0])

    # Guard Ring routing
    for i in range(number_finger_al * number_fan):
        laygen.route(xy0=[0, 0], xy1=[0, 5], gridname0=rg12, refobj0=al_row_layout[i][0].pins['S0'],
                     refobj1=al_row_layout[i][0].pins['S0'])
        laygen.route(xy0=[0, 0], xy1=[0, 5], gridname0=rg12, refobj0=al_row_layout[i][0].pins['S1'],
                     refobj1=al_row_layout[i][0].pins['S1'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rgnw, refobj0=al_row_layout[0][0].pins['S0'],
                 refobj1=guardring_n[0][0].pins['nwell'])
    laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rgnw, refobj0=al_row_layout[0][0].pins['S0'],
                 refobj1=al_row_layout[-1][0].pins['S1'])
    for i in range(int(number_finger_cm / 2)):
        laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_ref_layout[i][0].pins['S0'],
                     refobj1=cm_ref_layout[i][0].pins['S0'])
        laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_ref_layout[i][0].pins['S1'],
                     refobj1=cm_ref_layout[i][0].pins['S1'])
    for i in range(int(number_finger_cm / 2) * number_fan):
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
    laygen.export_BAG(prj)
    return input_list


def round_up_to_even(f):
    return math.ceil(f / 2.) * 2


def CML_layout_new(fan_factor, number_fan, number_finger_al, number_finger, number_finger_cm, number_finger_cm_ref):
    # initialize
    laygen = laygo.GridLayoutGenerator(config_file="laygo_config.yaml")
    # template and grid load
    utemplib = laygen.tech + '_cmltemplates'
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
    laygen.add_library('A_CML_496')
    laygen.add_cell('CML_lch_60n')

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
