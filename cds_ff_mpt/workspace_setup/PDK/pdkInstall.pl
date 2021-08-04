#!/usr/bin/env perl 
#$Id: pdkInstall.pl,v 1.1 2006/04/14 05:53:01 csyangh Exp $
#

use FileHandle;
STDOUT->autoflush();

$pdkCFG="pdkInstall.cfg";
###$pdkLOG="pdkInstall.log";

$VERSION="V1.0a";
#open(LOG,">tsmcPdkInstall.log") or die "*** Error : Cannot open installation log file \"install.log\".\n";
open (STDOUT, "| tee tsmcPdkInstall.log");
# Revision history:
#      V1.0aP	4/20/2004	initial release
#

#Global: $instFromDir,$instToDir,@srcPackLst,$selProc,@metalLst,
if($ARGV[4]){
  if(-e "$ARGV[4]"){
    print "install path : $ARGV[4] : is exist. Abort Install!!\n";
    exit;
  }
  system("mkdir $ARGV[4]");
  system("cp -rf CCI Assura Calibre *.lib display.drf models pdkInstall* skill Techfile tsmcN65 ./$ARGV[4]/");
  chdir("./$ARGV[4]/");
  system("pdkInstall.pl $ARGV[0] $ARGV[1] $ARGV[2] $ARGV[3]");
  exit;
}


my @procType;
push(@procType,"LO");
push(@procType,"MM");
push(@procType,"RF");
open(CFG,$pdkCFG) || die("Can't open configuration file for installation - $pdkCFG");

my $device="";
my @mmDevice;
my @rfDevice;
my @device33; #3.3V devices
my @device25; #2.5V devices (including od/ud)
open(DEVLIST,"./Techfile/dev.list") || die("Can't open install device list file for installation.");
while(<DEVLIST>){
  chomp $_;
  if(/^RF\s+(\S+)/i){
    push(@rfDevice,$1);
  }elsif(/^MM\s+(\S+)/i){
    push(@mmDevice,$1);
  }elsif(/^25\s+(\S+)/i){
    push(@device25,$1);
  }elsif(/^33\s+(\S+)/i){
    push(@device33,$1);
  }
}
#Recover all IO devices
foreach $device (@device25){
  if( -e "./Techfile/devTmp/$device"){
      system("rm -rf ./tsmcN65/$device ");
      print "mv ./Techfile/devTmp/$device ./tsmcN65/ \n";
      system("mv ./Techfile/devTmp/$device ./tsmcN65/ ");
  }
}
foreach $device (@device33){
  if( -e "./Techfile/devTmp/$device"){
      system("rm -rf ./tsmcN65/$device ");
      print "mv ./Techfile/devTmp/$device ./tsmcN65/ \n";
      system("mv ./Techfile/devTmp/$device ./tsmcN65/ ");
  }
}

my $inProc=0;
my $voltage="";
my $selVolt="";
my %definedVar;
while(<CFG>){
   chomp;
   s/^\s*//;
   s/\s*$//;
   (/^\/\//)&& next;
   (/^\s*$/)&& next;
   if(/^#SRC_LIST\s*:\s*(.*)/){
	$arglst = $1;
	$arglst =~ s/^\s*//;
	$arglst =~ s/\s*$//;
#        @srcPackLst=split(/\s+/,$arglst);
   }elsif(/^#PROC\s*=\s*\"(.*)\"/) {
	$inProc=1;
	$procName=$1;
	push @metalLst,$procName;
   }elsif(/^#VOLTAGE\s*=\s*\"(.*)\"/) {
	$inProc=1;
	$procName=$1;
	$procName=~ /\s*1\.0V\s*\/\s*(\S+)\s*/;
	$voltage = $1;
	#print "select voltage = $voltage\n";
	push @voltLst,$procName;  #Select 2.5V/3.3V
   }elsif(/^#MIMCAP\s*=\s*\"(.*)\"/) {
	$inProc=1;
	$procName=$1;
	push @mimLst,$procName;  #Select 1p5/2p0 MIMCAP
   }elsif( $_ =~ /^#EXEC\s+(\S+)/){
	$inProc=1;
	$procName=$1;
   }elsif(/^#END_PROC/){
	$inProc=0;
	$voltage="";
   }elsif($inProc == 1){
        if($voltage ne ""){
	  push @{$voltage},$_;
	}else{
	  push @{$procName},$_;
	}
   }else{
	print "Extra line in $pdkCFG - $_ \n";
   }#if
}#while
close(CFG);

###(-e $pdkLOG) && system("rm -rf $pdkLOG");
###open(LOG,">$pdkLOG")||die("Can't open log file for write - $pdkLOG \n");
Show_Banner();
Print_Choices();
Print_Confirm_Msg();
Exec_Commands();
###close(LOG);

$instFromDir= `pwd`;
chomp $instFromDir;
opendir(M,"models");
while($dir=readdir(M)){
	if(-e "models/$dir/temp.mdl"){ 
	  open(F,"models/$dir/temp.mdl"); 
	  open(D,">models/$dir/hspice.mdl");
	  while(<F>){
		s/tsmc_pdk_full_path/$instFromDir/;
		print D $_;
	  }
	  close(F);
	  close(D);
	}
}

##################
### Subroutine ###
##################

sub Show_Banner {
    my($title,$key)=();

$title=<<"!EOF_BANNER";

       - TSMC Process Ddesign Kit (PDK) Install Utility $VERSION -

    This perl script is used to install TSMC PDKs from the directory that 
contains the original distribution source files (a super-set of PDKs) to a 
specified destination directory according to the user specified options.

!EOF_BANNER

    print $title;
}


sub Print_Choices {
    my($metalOpt,$key1)=();
    my($procName,$i,$key)=();
    my($mimName,$l,$key2)=();
#    my($metName,$j,$key1,$deck_key2)=();

    
    print "*Avaliable process types are: \n";
    $l=0;
    foreach $procName (@procType){
	$l++;
        print "   $l - ",$procName,"\n";
    }
    print "Please enter your choice: (1,2...)\n";
    if($ARGV[0]){
      $key1=$ARGV[0];
    }else{
      $key1=<STDIN>;
    }
    chomp($key1);

    ($key1 != int($key1)) && die("Aborting Install.\n");
    (($key1 < 1) || ($key1 > 99)) && die("Aborting Install.\n");
    ($key1 > @procType) && die("Aborting Install.\n");
    $selProc=$procType[$key1-1];
#-------------------------
    print "*Avaliable voltages are: \n";
    $l=0;
    foreach $procName (@voltLst){
	$l++;
        print "   $l - ",$procName,"\n";
    }
    print "Please enter your choice: (1,2)\n";
    if($ARGV[1]){
      $key2=$ARGV[1];
    }else{
      $key2=<STDIN>;
    }
    chomp($key2);

    ($key2 != int($key2)) && die("Aborting Install.\n");
    (($key2 < 1) || ($key2 > 99)) && die("Aborting Install.\n");
    ($key2 > @voltLst) && die("Aborting Install.\n");
    $selVolt=$voltLst[$key2-1];
#-------------------------
    if($selProc ne "LO"){
	print "*Avaliable types of MiM cap are: \n";
	$l=0;
	foreach $mimName (@mimLst){
	    $l++;
            print "   $l - ",$mimName,"\n";
	}
	print "Please enter your choice: (1,2...)\n";
	if($ARGV[2]){
	  $key3=$ARGV[2];
	}else{
	  $key3=<STDIN>;
	}
	chomp($key3);

	($key3 != int($key3)) && die("Aborting Install.\n");
	(($key3 < 1) || ($key3 > 99)) && die("Aborting Install.\n");
	($key3 > @mimLst) && die("Aborting Install.\n");
	$selmim=$mimLst[$key3-1];
    }else{
        $selmim="";
    }
#-------------------------
    print "*Avaliable metal options are: \n";
    $i=0;
    foreach $metalOpt (@metalLst){
        if( (($selProc eq "LO") || ($selProc eq "MM" )) && ($metalOpt =~ /_\SX\SZ1U/i) ){
	   next;
	}
	$i++;
	print "   $i - ",$metalOpt,"\n";
    }
    print "*UTM inudctors include \"spiral_std_mu_z\", \"spiral_sym_mu_z\", and \"spiral_sym_ct_mu_z\".\n\n";
    print "                       \"spiral_std_mu_a\", \"spiral_sym_mu_a\", and \"spiral_sym_ct_mu_a\".\n\n";
    print "*Logic inductors include \"spiral_std_mza_a\", \"spiral_sym_mza_a\", \"spiral_sym_ct_mza_a\".\n\n";
    print "*For more information about inductor support, please refer to PDK_doc/ReleaseNote.txt\n\n";    
    print "Please enter your choice: (1,2...)\n";
    if($ARGV[3]){
      $key4=$ARGV[3];
    }else{
      $key4=<STDIN>;
    }
    chomp($key4);

    ($key4 != int($key4)) && die("Aborting Install.\n");
    (($key4 < 1) || ($key4 > 99)) && die("Aborting Install.\n");
    ($key4 > @metalLst) && die("Aborting Install.\n");
    if( ($selProc eq "LO") || ($selProc eq "MM" ) ){
      $selMetal=$metalLst[$key4*2-2];
    }else{
      $selMetal=$metalLst[$key4-1];
    }
    if($ARGV[4]){
      system("cp -rf Assura Calibre cds.lib display.drf models pdkInstall* skill Techfile tsmcN65 ./$ARGV[4]/");
      chdir("./$ARGV[4]/");
      system("pdkInstall.pl $ARGV[0] $ARGV[1] $ARGV[2] $ARGV[3]");
    }
}


sub Print_Confirm_Msg {
     my($key)=();

     print "Please confirm with your selction information: \n";
     print "*********************************************************\n";
     print "*** Select process : ",$selProc,"\n";
     print "*** Select voltage : ",$selVolt,"\n";
     if($selmim ne ""){
       print "*** Select MiM cap  : ",$selmim,"\n";
     }
     print "*** Select metal option : ",$selMetal,"\n";
     print "*********************************************************\n";
     print "Are these correct (y|n) ?\n";
     if($ARGV[2]){
        open(SETTING,">setting");
        if( !defined SETTING ){
          print "*** Error : Cannot create a setting file in PDK library, this may cause mal-function of utilities.\n";
        }else{
          $selVolt =~ /\s*1\.0V\s*\/\s*(\S+)\s*/;
          my $volt=$1;
          print SETTING "$selMetal\n";
          print SETTING "$volt\n";
          print SETTING "$selmim\n";
          print SETTING "$selProc\n";
          system("mv setting tsmcN65");
          close(SETTING);
        }
     }
     if(!$ARGV[2]){
     	$key=<STDIN>;
     	chomp($key);
    	(uc($key) ne "Y") && die("Aborting Install.\n");
	if(uc($key) eq "Y") {
	    open(SETTING,">setting");
	    if( !defined SETTING ){
	      print "*** Error : Cannot create a setting file in PDK library, this may cause mal-function of utilities.\n";
	    }else{
	      $selVolt =~ /\s*1\.0V\s*\/\s*(\S+)\s*/;
              my $volt=$1;
	      print SETTING "$selMetal\n";
	      print SETTING "$volt\n";
	      print SETTING "$selmim\n";
	      print SETTING "$selProc\n";
	      system("mv setting tsmcN65");
	      close(SETTING);
	    }
	}
     }
}


sub Exec_Commands {
    my($errFlag)=(0);
    my($cmd,$cmd2,$ret)=();

    if($selProc eq "RF"){ # install RF
      system("mv ./Techfile/devTmp/* ./tsmcN65/");
    }elsif($selProc eq "MM"){
      if(-e "./Techfile/devTmp/crtmom_mx"){
        system("mv ./Techfile/devTmp/crtmom_mx ./tsmcN65/");
      }
    }


    print "====== Installing pdk library ======\n";
    $selVolt =~ /\s*1\.0V\s*\/\s*(\S+)\s*/;
    $voltage=$1;
    #print "select voltage = $voltage\n";
    foreach $cmd2 (@{$voltage}) {
	print "Running \"$cmd2\" ......\n";
	if($cmd2=~/^mv\s+(\S+)\s+/){
	  if(-e "$1"){
	    $ret=system("$cmd2");
	  }
	}else{
	  $ret=system("$cmd2");
	}
	if ($ret == 0) {
	}else{
	    $errFlag=1;
	}
    }#foreach
    
    if($selmim ne ""){
	foreach $cmd2 (@{$selmim}) {
	    if( $cmd2=~/define\s+(\S+)/i){
	      #print "Define $1\n";
	      $definedVar{$1} = 1;
	    }elsif($cmd2=~/macro\s+(\S+)/){
	            print "Running \"$cmd2\" ......\n";
		    $macro=$1;
		    foreach $cmd2(@{$macro}){
			    print "	Running \"$cmd2\" ......\n";
			    if($cmd2=~/^mv\s+(\S+)\s+/){
			      if(-e "$1"){
			        $ret=system("$cmd2");
			      }
			    }else{
			      $ret=system("$cmd2");
			    }
		    }
	    }else{
	            print "Running \"$cmd2\" ......\n";
		    if($cmd2=~/^mv\s+(\S+)\s+/){
		      if(-e "$1"){
			$ret=system("$cmd2");
		      }
		    }else{
		      $ret=system("$cmd2");
		    }
	    }
	    if ($ret == 0) {
	    }else{
		$errFlag=1;
	    }
	}#foreach
    }
    foreach $cmd (@{$selMetal}) {
        my $ret=0;
	if($cmd=~/ifdef\s+(\S+)\s*\{([^\}]+)\}/i){
	  my $var = $1;
	  my $action = $2;
	  if( exists $definedVar{$var} ){
	      print "Running \"$action\" ......\n";
	      $ret=system("$action");
	  }
	}elsif($cmd=~/macro\s+(\S+)/){
	  $macro=$1;
	  print "Running macro\"$macro\" ......\n";
	  foreach my $tmp(@{$macro}){
	      print "	Running \"$tmp\" ......\n";
	      if($tmp=~/^mv\s+(\S+)\s+/){
		if(-e "$1"){
		  $ret=system("$tmp");
		}
	      }else{
		$ret=system("$tmp");
	      }
	  }
	}else{
	  print "Running \"$cmd\" ......\n";
	  if($tmp=~/^mv\s+(\S+)\s+/){
	    if(-e "$1"){
	      $ret=system("$tmp");
	    }
	  }else{
	    $ret=system("$cmd");
	  }
	}
	if ($ret == 0) {
#	    print "OK\n";
	}else{
#	    print "Failed !!!\n";
	    $errFlag=1;
	}
    }#foreach
    
    if( ($selProc eq "LO") || ($selProc eq "MM") ){
      #Remove RF device if install LO/MM
      foreach $device (@rfDevice){
	if( -e "./tsmcN65/$device"){
          if($device =~ /nmos_rf|pmos_rf|rp\S+_rf/){
	    system("mv ./tsmcN65/$device ./Techfile/devTmp/");
          }else{
	    system("rm -rf ./tsmcN65/$device");
          }
	}      
      }
      #Remove MM device if install LO
      if($selProc eq "LO"){  
	foreach $device (@mmDevice){
	  if( -e "./tsmcN65/$device"){
	    if($device eq "crtmom_mx"){
	      print "rm -rf ./tsmcN65/$device\n";
	      system("rm -rf ./tsmcN65/$device");
	    }else{
	      print "rm -rf ./tsmcN65/$device\n";
	      system("rm -rf ./tsmcN65/$device");
	    }
	  }
	}
      }
    }
    
    if($voltage =~ /3\.3/){  #Remove 2.5 devices if install 3.3V
      foreach $device (@device25){
	if( -e "./tsmcN65/$device"){
	    print "mv ./tsmcN65/$device ./Techfile/devTmp/\n";
	    system("mv ./tsmcN65/$device ./Techfile/devTmp/");
	}
      }
    }elsif($voltage =~ /2\.5/){  #Remove 3.3 devices if install 2.5V
      foreach $device (@device33){
	if( -e "./tsmcN65/$device"){
	    print "mv ./tsmcN65/$device ./Techfile/devTmp/\n";
	    system("mv ./tsmcN65/$device ./Techfile/devTmp/");
	}
      }
    }
    close(DEVLIST);
    
    if ($errFlag == 0) {
	 print "*Info: PDK installation completed.\n";
    }else{
	 print "*Info: PDK installation failed !!!\n";
    }#if
}
