

#from cml_layout import CML_layout
import cml_layout
if __name__ == '__main__':
	import math
#	import laygo
	import numpy as np
	current_list = cml_layout.CML_layout(1,8,4,6)
	for x in range(len(current_list)): 
		print (current_list[x])
