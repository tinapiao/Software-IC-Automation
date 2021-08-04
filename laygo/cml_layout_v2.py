
#import math
#import laygo
#import numpy as np

def CML_layout(fan_factor,number_fan,number_finger_al,number_finger,number_finger_cm):

	# initialize
	laygen = laygo.GridLayoutGenerator(config_file="laygo_config.yaml")
	# template and grid load
	utemplib = laygen.tech+'_cmltemplates'
	laygen.load_template(filename=utemplib+'_templates.yaml', libname=utemplib)
	laygen.load_grid(filename=utemplib+'_grids.yaml', libname=utemplib)
	laygen.templates.sel_library(utemplib)
	laygen.grids.sel_library(utemplib)


	# user inputs
	n_or_p = 'n'
	input_list= []
	input_list.append(number_finger)
	input_list.append(number_finger_al)
	input_list.append(number_finger_cm)

	# library & cell creation
	laygen.add_library('cml')
	laygen.add_cell('cml_test')


	# grid variables
	pb = 'placement_basic'
	rg12 = 'route_M1_M2_cmos'
	rg23 = 'route_M2_M3_cmos'
	rg34 = 'route_M3_M4_cmos'
	rgnw = 'route_nwell'


	# placements parameters
	al_row_layout = ['' for i in range(number_finger_al*number_fan)]
	dp_row_layout = ['' for i in range(number_finger*number_fan)]
	cm_ref_layout = ['' for i in range(int(number_finger_cm/2))]
	cm_row_layout = ['' for i in range(int(number_finger_cm/2)*number_fan)]
	max_finger = max(number_finger_al,number_finger,number_finger_cm)+2
	guardring_n = ['' for i in range(max_finger*number_fan)]
	guardring_p = ['' for i in range(max_finger*number_fan)]
	

	# placements
	# always place reference current mirror first
	for i in range(int(number_finger_cm/2)):
		if (i==0):
			cm_ref_layout[0] = laygen.relplace(templatename=['currentmirror_ref_n'], gridname=pb)
		else:
			cm_ref_layout[i] = laygen.relplace(templatename=['currentmirror_ref_n'], gridname=pb, refobj=cm_ref_layout[i-1], direction='right')

	# if finger number of current mirror is the greatest
	if (number_finger_cm>=number_finger and number_finger_cm>=number_finger_al):
		# current mirror placement	
		for i in range(int(number_fan*number_finger_cm/2)):
			if (i==0):
				cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb, refobj=cm_ref_layout[-1], xy=[2,0], direction='right')
			elif (((2*i)%number_finger_cm)==0 and i!=0):
				cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb, refobj=cm_row_layout[i-1], xy=[number_finger_cm+4,0], direction='right')
			else:
				cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb, refobj=cm_row_layout[i-1], direction='right')
		# diff pair placement
		for i in range(number_fan*number_finger):
			if (i==0):
				dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb, refobj=cm_ref_layout[0], direction='top')
			elif (((2*i)%number_finger)==0 and i!=0):
				dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb, refobj=dp_row_layout[i-1], xy=[number_finger_cm-number_finger+2,0], direction='right')
			else:
				dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb, refobj=dp_row_layout[i-1], direction='right')
		# active load placement
		for i in range(number_finger_al*number_fan):
			if (i==0):
				al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb, refobj=cm_ref_layout[0], xy=[0,1], direction='top')
			elif (((2*i)%number_finger_al)==0 and i!=0):
				al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb, refobj=al_row_layout[i-1], xy=[number_finger_cm-number_finger_al+2,0], direction='right')
			else:
				al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb, refobj=al_row_layout[i-1], direction='right')

	# if finger number of diff pair is the greatest
	elif (number_finger>=number_finger_cm and number_finger>=number_finger_al):
		# diff pair placement
		for i in range(number_fan*number_finger):
			if (i==0):
				dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb, refobj=cm_ref_layout[0], direction='top')
			elif (((2*i)%number_finger)==0 and i!=0):
				dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb, refobj=dp_row_layout[i-1], xy=[2,0], direction='right')
			else:
				dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb, refobj=dp_row_layout[i-1], direction='right')
		# current mirror placement	
		for i in range(int(number_fan*number_finger_cm/2)):
			if (i==0):
				cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb, refobj=cm_ref_layout[-1], xy=[number_finger-number_finger_cm+2,0], direction='right')
			elif (((2*i)%number_finger_cm)==0 and i!=0):
				cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb, refobj=cm_row_layout[i-1], xy=[number_finger-number_finger_cm+number_finger+4,0], direction='right')
			else:
				cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb, refobj=cm_row_layout[i-1], direction='right')
		# active load placement
		for i in range(number_finger_al*number_fan):
			if (i==0):
				al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb, refobj=cm_ref_layout[0], xy=[0,1], direction='top')
			elif (((2*i)%number_finger_al)==0 and i!=0):
				al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb, refobj=al_row_layout[i-1], xy=[number_finger-number_finger_al+2,0], direction='right')
			else:
				al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb, refobj=al_row_layout[i-1], direction='right')

	# if finger number of active load is the greatest
	else:
		# active load placement
		for i in range(number_finger_al*number_fan):
			if (i==0):
				al_row_layout[0] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb, refobj=cm_ref_layout[0], xy=[0,1], direction='top')
			elif (((2*i)%number_finger_al)==0 and i!=0):
				al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb, refobj=al_row_layout[i-1], xy=[2,0], direction='right')
			else:
				al_row_layout[i] = laygen.relplace(templatename=['activeload_two_finger_p'], gridname=pb, refobj=al_row_layout[i-1], direction='right')
		# diff pair placement
		for i in range(number_fan*number_finger):
			if (i==0):
				dp_row_layout[0] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb, refobj=cm_ref_layout[0], direction='top')
			elif (((2*i)%number_finger)==0 and i!=0):
				dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb, refobj=dp_row_layout[i-1], xy=[number_finger_al-number_finger+2,0], direction='right')
			else:
				dp_row_layout[i] = laygen.relplace(templatename=['diffpair_two_finger_n'], gridname=pb, refobj=dp_row_layout[i-1], direction='right')
		# current mirror placement	
		for i in range(int(number_fan*number_finger_cm/2)):
			if (i==0):
				cm_row_layout[0] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb, refobj=cm_ref_layout[-1], xy=[number_finger_al-number_finger_cm+2,0], direction='right')
			elif (((2*i)%number_finger_cm)==0 and i!=0):
				cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb, refobj=cm_row_layout[i-1], xy=[number_finger_al-number_finger_cm+number_finger_al+4,0], direction='right')
			else:
				cm_row_layout[i] = laygen.relplace(templatename=['currentmirror_single_n'], gridname=pb, refobj=cm_row_layout[i-1], direction='right')

	# Guard Ring placement
	for i in range(max_finger*number_fan):
		if (i==0):
			guardring_n[i] = laygen.relplace(templatename=['guard_ring_nwell'], gridname=pb, refobj=al_row_layout[0], direction='top')
			guardring_p[i] = laygen.relplace(templatename=['guard_ring_psub'], gridname=pb, refobj=cm_ref_layout[0], direction='bottom')
		else:
			guardring_n[i] = laygen.relplace(templatename=['guard_ring_nwell'], gridname=pb, refobj=guardring_n[i-1], direction='right')
			guardring_p[i] = laygen.relplace(templatename=['guard_ring_psub'], gridname=pb, refobj=guardring_p[i-1], direction='right')


	# routes    
	# current mirror self routing
	idc = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg23, refobj0=cm_ref_layout[0][0].pins['D'], refobj1=cm_ref_layout[0][0].pins['D'], via0=[0,0])
	vss = laygen.route(xy0=[0, 0], xy1=[1, 0], gridname0=rg12, refobj0=cm_ref_layout[0][0].pins['S0'], refobj1=cm_ref_layout[0][0].pins['S0'])
	laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=cm_ref_layout[0][0].pins['S0'], refobj1=cm_row_layout[-1][0].pins['S1'])
	laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=cm_ref_layout[0][0].pins['G'], refobj1=cm_row_layout[-1][0].pins['G'])
	for i in range(int(number_finger_cm/2)-1):
		laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23, refobj0=cm_ref_layout[i][0].pins['D'], refobj1=cm_ref_layout[i+1][0].pins['D'], via0=[0,0], via1=[0,0])
	for i in range(number_fan):
		for j in range(int(number_finger_cm/2)-1):
			laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23, refobj0=cm_row_layout[i*int(number_finger_cm/2)+j][0].pins['D'], refobj1=cm_row_layout[i*int(number_finger_cm/2)+j+1][0].pins['D'], via0=[0,0], via1=[0,0])

	# diff pair routing
	# diff pair two inputs and two outputs
	for i in range(2*number_fan):
		if (i==0):
			inp = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=dp_row_layout[0][0].pins['G'], refobj1=dp_row_layout[0][0].pins['G'], via0=[0,0])
		elif (i==1):
			inm = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=dp_row_layout[int(number_finger/2)][0].pins['G'], refobj1=dp_row_layout[int(number_finger/2)][0].pins['G'], via0=[0,0])
		else:
			laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=dp_row_layout[i*int(number_finger/2)][0].pins['G'], refobj1=dp_row_layout[i*int(number_finger/2)][0].pins['G'], via0=[0,0])
	outm = laygen.route(xy0=[0, 0], xy1=[0, 2], gridname0=rg23, refobj0=dp_row_layout[-int(number_finger/2)-1][0].pins['D'], refobj1=dp_row_layout[-int(number_finger/2)-1][0].pins['D'], via0=[0,0])
	outp = laygen.route(xy0=[0, 0], xy1=[0, 2], gridname0=rg23, refobj0=dp_row_layout[-1][0].pins['D'], refobj1=dp_row_layout[-1][0].pins['D'], via0=[0,0])

	# diff pair gate and drain self connection
	for i in range(2*number_fan): 
		for j in range(int(number_finger/2)-1):
			laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=dp_row_layout[int(i*number_finger/2)+j][0].pins['G'], refobj1=dp_row_layout[int(i*number_finger/2)+j+1][0].pins['G'], via0=[0,0], via1=[0,0])
			laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23, refobj0=dp_row_layout[int(i*number_finger/2)+j][0].pins['D'], refobj1=dp_row_layout[int(i*number_finger/2)+j+1][0].pins['D'], via0=[0,0], via1=[0,0])

	# diff pair: drain of i connect to gate of i+1
	for i in range(2*number_fan-2):			
		for j in range(int(number_finger/2)-1):
			if (i%2==0):
				laygen.route(xy0=[0, -2], xy1=[0, -2], gridname0=rg34, refobj0=dp_row_layout[i*int(number_finger/2)+j][0].pins['D'], refobj1=dp_row_layout[i*int(number_finger/2)+j+1][0].pins['D'], via0=[0,0], via1=[0,0])
			else:
				laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg34, refobj0=dp_row_layout[i*int(number_finger/2)+j][0].pins['D'], refobj1=dp_row_layout[i*int(number_finger/2)+j+1][0].pins['D'], via0=[0,0], via1=[0,0])
		if (i%2==0):
			laygen.route(xy0=[0, -2], xy1=[-2, -2], gridname0=rg34, refobj0=dp_row_layout[i*int(number_finger/2)][0].pins['D'], refobj1=dp_row_layout[(i+2)*int(number_finger/2)][0].pins['D'], via0=[0,0], via1=[0,0])
			laygen.route(xy0=[-2, -2], xy1=[-2, -1], gridname0=rg23, refobj0=dp_row_layout[(i+2)*int(number_finger/2)][0].pins['D'], refobj1=dp_row_layout[(i+2)*int(number_finger/2)][0].pins['D'], via1=[0,0])
		else:
			laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg34, refobj0=dp_row_layout[i*int(number_finger/2)][0].pins['D'], refobj1=dp_row_layout[(i+2)*int(number_finger/2)][0].pins['D'], via0=[0,0], via1=[0,0])
			laygen.route(xy0=[-2, 0], xy1=[-2, -1], gridname0=rg23, refobj0=dp_row_layout[(i+2)*int(number_finger/2)][0].pins['D'], refobj1=dp_row_layout[(i+2)*int(number_finger/2)][0].pins['D'], via1=[0,0])

	# diff pair source self connection
	for i in range(number_fan): 
		laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=dp_row_layout[i*number_finger][0].pins['S0'], refobj1=dp_row_layout[i*number_finger+number_finger-1][0].pins['S1'])
	# diff pair source connect to current mirror drain
	for i in range(number_fan):
		laygen.route(xy0=[0, 0], xy1=[0, 3], gridname0=rg23, refobj0=cm_row_layout[i*int(number_finger_cm/2)][0].pins['D'], refobj1=cm_row_layout[i*int(number_finger_cm/2)][0].pins['D'], via1=[0,0])
	# diff pair drain connect to active load
	for i in range(2*number_fan):
		laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23, refobj0=dp_row_layout[i*int(number_finger/2)][0].pins['D'], refobj1=al_row_layout[i*int(number_finger_al/2)][0].pins['D'])

	# active load routing
	# active load connect to VDD
	vdd = laygen.route(xy0=[0, 0], xy1=[1, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['S0'], refobj1=al_row_layout[0][0].pins['S0'])
	laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['S0'], refobj1=al_row_layout[-1][0].pins['S1'])
	# active load gate self connection
	vbias = laygen.route(xy0=[0, 0], xy1=[-2, 0], gridname0=rg12, refobj0=al_row_layout[0][0].pins['G'], refobj1=al_row_layout[0][0].pins['G'], via0=[0,0])
	for i in range(number_finger_al*number_fan-1): 
		laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg12, refobj0=al_row_layout[i][0].pins['G'], refobj1=al_row_layout[i+1][0].pins['G'], via0=[0,0], via1=[0,0])
	# active load drain self connection
	for i in range(2*number_fan): 
		for j in range(int(number_finger_al/2)-1):
			laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rg23, refobj0=al_row_layout[int(i*number_finger_al/2)+j][0].pins['D'], refobj1=al_row_layout[int(i*number_finger_al/2)+j+1][0].pins['D'], via0=[0,0], via1=[0,0])

	# Guard Ring routing
	for i in range(number_finger_al*number_fan):
		laygen.route(xy0=[0, 0], xy1=[0, 5], gridname0=rg12, refobj0=al_row_layout[i][0].pins['S0'], refobj1=al_row_layout[i][0].pins['S0'])
		laygen.route(xy0=[0, 0], xy1=[0, 5], gridname0=rg12, refobj0=al_row_layout[i][0].pins['S1'], refobj1=al_row_layout[i][0].pins['S1'])
	laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rgnw, refobj0=al_row_layout[0][0].pins['S0'], refobj1=guardring_n[0][0].pins['nwell'])
	laygen.route(xy0=[0, 0], xy1=[0, 0], gridname0=rgnw, refobj0=al_row_layout[0][0].pins['S0'], refobj1=al_row_layout[-1][0].pins['S1'])
	for i in range(int(number_finger_cm/2)):
		laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_ref_layout[i][0].pins['S0'], refobj1=cm_ref_layout[i][0].pins['S0'])
		laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_ref_layout[i][0].pins['S1'], refobj1=cm_ref_layout[i][0].pins['S1'])
	for i in range(int(number_finger_cm/2)*number_fan):
		laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_row_layout[i][0].pins['S0'], refobj1=cm_row_layout[i][0].pins['S0'])
		laygen.route(xy0=[0, 0], xy1=[0, -7], gridname0=rg12, refobj0=cm_row_layout[i][0].pins['S1'], refobj1=cm_row_layout[i][0].pins['S1'])


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

if __name__ == '__main__':
	import math
	import laygo
	import numpy as np
	current_list = CML_layout(2,3,4,8,4)
