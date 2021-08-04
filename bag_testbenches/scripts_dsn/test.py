import sys
import os
import configparser

commands=str(sys.argv)
if len(sys.argv)>1:
    if '-h' in commands:
        print("\n-help   displays the usage of this script\n \n-config  displays the config option for users to fill in the required input parameters in a config file under the same directory as the script prior to running the script  \n\nCommand: python inverter_main.py -h -config <config file name.ini>\n\nIf no options are entered, the script will ask the user for inputs during execution.")

        print("\nBelow is the required format for the config file\n")
        print('[Inverter Input Parameters]\nR_in_ohms=<input>\nC_load_fF=<input>\nswing_min_mV=<input>\nbw_min_mV=<input>\nC_in_fF=<input>')
        sys.exit()
    if '-config' in commands:

        config = configparser.ConfigParser()
        config.read(sys.argv[2])

        input_list=config['Inverter Input Parameters']
        '''
        amp_dsn_specs['Input_Resistance_ohm']=input_list['R_in_ohms']
        amp_dsn_specs['cload_fF'] = input_list['C_load_fF'] 
        amp_dsn_specs['swing_min_mV'] = input_list['swing_min_mV']
        amp_dsn_specs['bw_min_GHz'] = input_list['bw_min_mV']
        amp_dsn_specs['cin_fF'] = input_list['C_in_fF']	
        '''
        a=float(input_list['R_in_ohms'])
        b=float(input_list['C_load_fF'])
        print("R_in ohms",a)
        print("C-load ff",b)
        print(a+b)

        
  
else:
    print('not config')
