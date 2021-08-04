#!/usr/bin/env perl 


if(@ARGV==0){

	print "\n\nUsage: estc.pl <raphael_table> <temperature_parameter_table> <patterns> <width> <spacing> <length> <temperature>\n";

        print STDOUT<<"NOTE"

	Patterns: 

		layer1_layer2_layer3

	layer1  : ground plane over layer2
	layer2  : major layer 
	layer3  : ground plane under layer2
	Width   : layer2's width
	Spacing : under test spacing between two parallel layer2 wires.
           	  when layer1 and layer3 are not used, layer2 is over field oxide.
        length  : layer2's length.
	temperature: Valid range : -40 C ~ 125 C .
	###########################################################################

	Example of temperature table:

		M9  tc1=3.506e-3  tc2=-3.60e-7	
		M8  tc1=3.506e-3  tc2=-3.60e-7
		M7  tc1=3.077e-3  tc2=-1.14e-7	
		M6  tc1=3.077e-3  tc2=-1.14e-7	
		M5  tc1=3.077e-3  tc2=-1.14e-7	
		M4  tc1=3.077e-3  tc2=-1.14e-7	
		M3  tc1=3.077e-3  tc2=-1.14e-7	
		M2  tc1=3.077e-3  tc2=-1.14e-7	
		M1  tc1=2.92e-3   tc2=-1.22e-7	
		PO1 tc1=5.97e-5   tc2=7.4e-7	
		OD  tc1=3.25e-3   tc2=4.23e-7	
		

NOTE
;
    exit(-1);

}elsif(@ARGV != 7){
	print "ERROR:: error input ! \n Ex. estc.pl <raphael_table> <temp_table> <patterns> <width> <spacing> <length> <temperature>\n";
	exit(-1);
}


## Main section##

Read_raphael_table();
Read_temperature_table();
Estimation($ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5], $ARGV[6]);

#for($i=0; $i<=1000;$i++){
# 	Estimation($ARGV[2], $ARGV[3], $ARGV[4]+$i*0.001, $ARGV[5], $ARGV[6]);
#}



sub Read_raphael_table
{
open(TABLE,"$ARGV[0]");
$Rs = 0;

while(<TABLE>){

	s/\s+\-\s+/\-/g;
	if($_ =~ / Rs /){
		$Rs = 1;
	}

	if( $_ =~ /Ohm\/um/){		
		$res_unit = '(Ohm/um)';
	}

	if( $_ =~ /Ohm\/sq/){		
		$res_unit = '(Ohm/sq)';
	}

	if(/Structure\s+(\S+)\s+\S+\s+(\S+)/){
		$flag = 1;
		$str  = $1;
		$pat  = $2;
		if($pat =~ /\(\s*OD\s*\)/){
			$skipit=1;
		}else{
			$skipit=0;
		}
		$pat =~ s/(\(FOX\)|\(OD\))//g;
		@list=split(/\-/,$pat);
		if($str=~ /A/){
			$pat=$list[0];
			$pat2=$list[1]; 
			$pat3=();
		}elsif($str=~/B/){
			$pat=$list[1];
			$pat2=$list[2];
			$pat3=$list[0];
		}
	}

	if($skipit==1){
		next;
	}

	if($pat =~ /^PO/){
		if(/^\s*[0-9]\S*/){
			if($Rs eq 0){
				$_ =~ s/^\s+//;
				@list=split(/\s+/,$_);
				if(!/\|/){
					$cap  = $list[2]; 
					$coup = $list[3];
					$bott = $list[4];
					$Cb_a = $list[5];
					$Cfb  = $list[6];
					$top  = $list[7];
					$Ct_a = $list[8];
					$Cft  = $list[9];
					$Csum = $list[10];
				}elsif($list[1]=~ s/\|//){
					$cap  = $list[4];
					$coup = $list[5];	
					$bott = $list[6];
					$Cb_a = $list[7];
					$Cfb  = $list[8];
					$top  = $list[9];
					$Ct_a = $list[10];
					$Cft  = $list[11];
					$Csum = $list[12];
				}else{
					$cap  = $list[5];
					$coup = $list[6];	
					$bott = $list[7];
					$Cb_a = $list[8];
					$Cfb  = $list[9];
					$top  = $list[10];
					$Ct_a = $list[11];
					$Cft  = $list[12];
					$Csum = $list[13];
				}
			}

			if($str eq "A"){
				$Csum = $top;
			}

			if($Rs eq 1){
				$_ =~ s/^\s+//;
				@list=split(/\s+/,$_);
				if(!/\|/){
					$res  = $list[2];
					$cap  = $list[3]; 
					$coup = $list[4];
					$bott = $list[5];
					$Cb_a = $list[6];
					$Cfb  = $list[7];
					$top  = $list[8];
					$Ct_a = $list[9];
					$Cft  = $list[10];
					$Csum = $list[11];
				}elsif($list[1]=~ s/\|//){
					$res  = $list[4];
					$cap  = $list[5];
					$coup = $list[6];	
					$bott = $list[7];
					$Cb_a = $list[8];
					$Cfb  = $list[9];	
					$top  = $list[10];
					$Ct_a = $list[11];
					$Cft  = $list[12];
					$Csum = $list[13];
				}else{
					$res  = $list[5];
					$cap  = $list[6];
					$coup = $list[7];	
					$bott = $list[8];
					$Cb_a = $list[9];
					$Cfb  = $list[10];
					$top  = $list[11];
					$Ct_a = $list[12];
					$Cft  = $list[13];
					$Csum = $list[14];
				}
			}
			if($str eq "A"){
				$Csum = $top;
			}
			$width = $list[0];
			$dis   = $list[1];
			$total_pat=$pat3.$pat.$pat2;
			$cap_table{$total_pat}{$width}{$dis}  = $cap;
			$res_table{$total_pat}{$width}{$dis}  = $res;
			$coup_table{$total_pat}{$width}{$dis} = $coup;
			$bott_table{$total_pat}{$width}{$dis} = $bott;
			$Cb_a_table{$total_pat}{$width}{$dis} = $Cb_a;
			$Cfb_table{$total_pat}{$width}{$dis}  = $Cfb;
			$top_table{$total_pat}{$width}{$dis}  = $top;
			$Ct_a_table{$total_pat}{$width}{$dis} = $Ct_a;   
			$Cft_table{$total_pat}{$width}{$dis}  = $Cft;
			$Csum_table{$total_pat}{$width}{$dis} = $Csum;	
			$max_width{$total_pat}                = $width;
                        $max_dis{$total_pat}                  = $dis;
			if($flag == 1){
				$min_width{$total_pat} = $width;
				$min_dis{$total_pat}   = $dis;
				$flag = 0;	
		        }
		}
	}else {
		## // modify  to suit for older cap table file
		if(/^\s*\d+\S+/){
		       s/^\s*//,$_; 
		       @list=split(/\s+/,$_);
		       if($Rs eq 0)
		       {
			       $temp1  = $list[0];
			       $temp2  = $list[1];
			       $temp3  = $list[2];
			       $temp4  = $list[3];
			       $temp5  = $list[4];
			       $temp6  = $list[5];
			       $temp7  = $list[6];
			       $temp8  = $list[7];
			       $temp9  = $list[8];
			       $temp10 = $list[9];
			       $temp11 = $list[10];		
		       }else {
			       $temp1  = $list[0];
			       $temp2  = $list[1];
			       $temp3  = $list[2];
			       $temp4  = $list[3];	
			       $temp5  = $list[4];
			       $temp6  = $list[5];
			       $temp7  = $list[6];
			       $temp8  = $list[7];
			       $temp9  = $list[8];
			       $temp10 = $list[9];	
			       $temp11 = $list[10];
			       $temp12 = $list[11];
			       $temp13 = $list[12];	
			       $temp14 = $list[13];				
			       $temp15 = $list[14];						
		       }

		       if($temp3 ne "|")
		       {
				$width = $temp1;	
				$dis   = $temp2;
				$cap   = $temp3;
				$coup  = $temp4;
				$bott  = $temp5;
				$Cb_a  = $temp6;
				$Cfb   = $temp7;	
				$top   = $temp8;
			        $Ct_a  = $temp9;					          		
				$Cft   = $temp10;	
				$Csum  = $temp11;
			}else{
				$width = $temp1;
				$dis   = $temp2;
			  	$res   = $temp6;
				$cap   = $temp7;
			        $coup  = $temp8;
				$bott  = $temp9;
				$Cb_a  = $temp10;
				$Cfb   = $temp11;	
				$top   = $temp12;
			        $Ct_a  = $temp13;					          		
				$Cft   = $temp14;
				$Csum  = $temp15;	
			}
			if($str eq "A"){
				$Csum = $top;
			}
    			
			$total_pat = $pat3.$pat.$pat2;
			$cap_table{$total_pat}{$width}{$dis}  = $cap;
			$res_table{$total_pat}{$width}{$dis}  = $res;
			$coup_table{$total_pat}{$width}{$dis} = $coup;
			$bott_table{$total_pat}{$width}{$dis} = $bott;
			$Cb_a_table{$total_pat}{$width}{$dis} = $Cb_a;
			$Cfb_table{$total_pat}{$width}{$dis}  = $Cfb;
			$top_table{$total_pat}{$width}{$dis}  = $top;
			$Ct_a_table{$total_pat}{$width}{$dis} = $Ct_a;   
			$Cft_table{$total_pat}{$width}{$dis}  = $Cft;
			$Csum_table{$total_pat}{$width}{$dis} = $Csum;	
			$max_width{$total_pat}                = $width;
                        $max_dis{$total_pat}                  = $dis;

			if($flag == 1){
				$min_width{$total_pat} = $width;
				$min_dis{$total_pat}   = $dis;
				$flag = 0;	
		        }
		}	
	}
}
close(TABLE);
}



sub Read_temperature_table
{
	open(TEMP,"$ARGV[1]");
	while(<TEMP>){
		$tem = $_;
		$tem = uc($tem);
		$tem =~ s/^\s+//;
		@list=split(/\s+/,$tem);
		for($i=0; $i<=$#list;$i++){
			if($list[$i] =~ /=/){
				@para=split(/\=/,$list[$i]);
					${$list[0]}{$para[0]} = $para[1];
			}		
		}
	}
	close(TEMP);
}


sub Estimation
{
        my $FOX="_FOX";
	my($pattern, $width, $spacing, $length, $temper )=@_;
	$pattern = uc($pattern);
	@list_p  = split(/\_/,$pattern);
        if(!($pattern =~ /_/)){
                $pattern = $pattern.$FOX;
        }
	$pattern =~ s/\_//g;

        if($max_width{$pattern}){
            if($max_width{$pattern}==$min_width{$pattern}){
                $max_width{$pattern}=30;
                $max_dis{$pattern}=15;
                $bottom_w = $min_width{$pattern};
                $top_w    = $max_width{$pattern};
                $bottom_s = $min_dis{$pattern};
                $top_s    = $max_dis{$pattern};
                $res_table{$pattern}{$max_width{$pattern}}{$max_dis{$pattern}} = $res_table{$pattern}{$min_width{$pattern}}{$min_dis{$pattern}};
                $res_table{$pattern}{$max_width{$pattern}}{$min_dis{$pattern}} = $res_table{$pattern}{$min_width{$pattern}}{$min_dis{$pattern}};
                $res_table{$pattern}{$min_width{$pattern}}{$max_dis{$pattern}} = $res_table{$pattern}{$min_width{$pattern}}{$min_dis{$pattern}};
                $cap_table{$pattern}{$max_width{$pattern}}{$max_dis{$pattern}} = $cap_table{$pattern}{$min_width{$pattern}}{$min_dis{$pattern}}*$max_width{$pattern}/$min_width{$pattern}*$min_dis{$pattern}/$max_dis{$pattern};
                $cap_table{$pattern}{$min_width{$pattern}}{$max_dis{$pattern}} = $cap_table{$pattern}{$min_width{$pattern}}{$min_dis{$pattern}}*$min_dis{$pattern}/$max_dis{$pattern};
                $cap_table{$pattern}{$max_width{$pattern}}{$min_dis{$pattern}} = $cap_table{$pattern}{$min_width{$pattern}}{$min_dis{$pattern}}*$max_width{$pattern}/$min_width{$pattern};
                $coup_table{$pattern}{$max_width{$pattern}}{$max_dis{$pattern}}= $coup_table{$pattern}{$min_width{$pattern}}{$min_dis{$pattern}}*$min_dis{$pattern}/$max_dis{$pattern};
                $coup_table{$pattern}{$max_width{$pattern}}{$min_dis{$pattern}}= $coup_table{$pattern}{$min_width{$pattern}}{$min_dis{$pattern}};
                $coup_table{$pattern}{$min_width{$pattern}}{$max_dis{$pattern}}= $coup_table{$pattern}{$min_width{$pattern}}{$min_dis{$pattern}}*$min_dis{$pattern}/$max_dis{$pattern};

            }
        }


	$min = $max_width{$pattern};
	foreach $k1 (sort keys %{$cap_table{$pattern}}){
		if($width >= $k1 && ($width - $k1) < $min ){
             		$min      = $width - $k1;
			$bottom_w = $k1;	
		}
	}



	$min = $max_width{$pattern};
	foreach $k1 (sort keys %{$cap_table{$pattern}}){	
		if($width <= $k1 && ( $k1 - $width) < $min ){
             		$min   = $k1 - $width;
			$top_w = $k1;	
		}
	}


	$min = $max_dis{$pattern};
	foreach $k1 (sort keys %{$cap_table{$pattern}}){	
		foreach $k2 (sort keys %{$cap_table{$pattern}{$k1}}){
			if($spacing >= $k2 && ($spacing - $k2) < $min ){
        	     		$min      = $spacing - $k2;
				$bottom_s = $k2;	
			}
		}
		last;
	}


	$min = $max_dis{$pattern};
	foreach $k1 (sort keys %{$cap_table{$pattern}}){	
		foreach $k2 (sort keys %{$cap_table{$pattern}{$k1}}){
			if($spacing <= $k2 && ( $k2 - $spacing) < $min ){
        	     		$min   = $k2 - $spacing;
				$top_s = $k2;	
			}
		}
		last;
	}


	if(!$max_width{$pattern}){
		print "\n\nERROR: This pattern doesn't exist in the raphael table or raphael table is not correct\.\n\n";      

	}elsif($width <= $max_width{$pattern} && $width >= $min_width{$pattern} && $spacing <= $max_dis{$pattern} && $spacing >= $min_dis{$pattern}){
	
		if( $Rs == 1){
			$sheet_R = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, res_table);

			if(!${$list_p[0]}{TC1} && !${$list_p[0]}{TC2}){
				print "       Warning :: TC1 and TC2 did not exist\n\n"; 
			}elsif(!${$list_p[0]}{TC1}){
				print "       Warning :: TC1 did not exist\n\n"; 	
			}elsif(!${$list_p[0]}{TC2}){
				print "       Warning :: TC2 did not exist\n\n"; 	
			}

			$sheet_R_with_temperature = $sheet_R * ( 1 + ${$list_p[0]}{TC1} * ($temper - 25) + ${$list_p[0]}{TC2} *($temper - 25)**2 );
			if( $res_unit =~ /Ohm\/um/ ){ 
				$Res = $sheet_R_with_temperature * $length;
			}else{
				$Res = $sheet_R_with_temperature * $length / $width;
			}
#			print "\n\tResistance of $pattern = $Res (Ohm)\n"; 
			print "$Res\n"; 
		}

		$Ctotal = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, cap_table);
		$Ct      = $Ctotal * $length * 1e-15;
#                print "\tCapacitance of $pattern = $c (fF)\n\n"; 	
                print "$Ct\n"; 	
		print ""; 	
#		if( $Rs == 1){
#			print "\n\tRs = $sheet_R $res_unit\n\n";			
#			print "\tAdd temperature effect: Rs = $sheet_R_with_temperature $res_unit\n\n";			
#		}

		$Cc      = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, coup_table);
#		$Cbottom = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, bott_table);
#		$Cb_area = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, Cb_a_table);
#		$Cfb     = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, Cfb_table);
#		print "\tCtotal = $Ctotal (fF/um)\n\n\tCc = $Cc (fF/um)\n\n\tCbottom  = $Cbottom (fF/um)\n\n\tCb_area = $Cb_area (fF/um)\n\n\tCfb = $Cfb (fF/um)\n\n";
                $Cc=$Cc*$length * 1e-15;
		print "$Cc\n";

#		if($Cft_table{$pattern}{$bottom_w}{$bottom_s}){
#			$Ctop    = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, top_table);
#			$Ct_area = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, Ct_a_table);
#			$Cft     = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, Cft_table);
#			print "\tCtop = $Ctop (fF/um)\n\n\tCt_area = $Ct_area (fF/um)\n\n\tCft = $Cft (fF/um)\n\n";
#		}

#		$Csum = Interpolation($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, Csum_table);

#		print "\tCsum = $Csum \%\n\n";
#		print "\n  $pattern\:  width=$width, spacing=$spacing, length=$length, temperature=$temper.\n";
#		print "           (Range of width is $min_width{$pattern} ~ $max_width{$pattern} , Range of space is $min_dis{$pattern} ~ $max_dis{$pattern}).\n";		
#		print "###############################################################################\n\n";
	}else{
		print "\n\n Range of width is $min_width{$pattern} ~ $max_width{$pattern} , Range of space is $min_dis{$pattern} ~ $max_dis{$pattern}\n\n";
		print "ERROR: Input parameters outside of the table\n";	
	}
}




sub Interpolation
{
	my($bottom_s, $top_s, $bottom_w, $top_w, $width, $spacing, $pattern, $hash)=@_;
	
	if( $bottom_s == $top_s && $bottom_w == $top_w){ 
		return ${$hash}{$pattern}{$top_w}{$bottom_s};

	}elsif($bottom_s == $top_s){
		$cap1 = (${$hash}{$pattern}{$top_w}{$bottom_s} - ${$hash}{$pattern}{$bottom_w}{$bottom_s}) / ($top_w- $bottom_w ) * ($width - $bottom_w) + ${$hash}{$pattern}{$bottom_w}{$bottom_s} ;
		return $cap1;

	}elsif($bottom_w == $top_w){
		$cap1 = (${$hash}{$pattern}{$top_w}{$top_s} - ${$hash}{$pattern}{$top_w}{$bottom_s}) / ($top_s - $bottom_s) * ($spacing - $bottom_s) + ${$hash}{$pattern}{$top_w}{$bottom_s};
		return $cap1;
	}else{
		$cap1 = (${$hash}{$pattern}{$top_w}{$bottom_s} - ${$hash}{$pattern}{$bottom_w}{$bottom_s}) / ($top_w- $bottom_w ) * ($width - $bottom_w) + ${$hash}{$pattern}{$bottom_w}{$bottom_s} ;
		$cap2 =((((${$hash}{$pattern}{$top_w}{$top_s} - ${$hash}{$pattern}{$top_w}{$bottom_s}) - 
          		(${$hash}{$pattern}{$bottom_w}{$top_s} - ${$hash}{$pattern}{$bottom_w}{$bottom_s})) 
		          / ($top_w- $bottom_w ) * ($width - $bottom_w)) + (${$hash}{$pattern}{$bottom_w}{$top_s} - 
         		${$hash}{$pattern}{$bottom_w}{$bottom_s})) / ($top_s - $bottom_s) * ($spacing - $bottom_s) + $cap1;
		return $cap2;
	}
}

