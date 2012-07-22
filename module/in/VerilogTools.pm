package VerilogTools;

#******************************************************************
#
# VerilogTools module
#
#******************************************************************
#
# created on:	07/21/2012 
# created by:	jwwebb
# last edit on:	$DateTime: $ 
# last edit by:	$Author: $
# revision:	    $Revision: $
# comments:	    Generated
#
#******************************************************************
# Revision List:
#
#		1.0	07/21/2012	Initial release
# 
#******************************************************************
# VerilogTools Module
#
#  This utility is intended to create new Verilog modules, and 
#  test benches.
#
#******************************************************************
#
#  Copyright (c) 2012, Jeremy W. Webb 
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions 
#  are met: 
#
#  1. Redistributions of source code must retain the above copyright 
#     notice, this list of conditions and the following disclaimer. 
#  2. Redistributions in binary form must reproduce the above copyright 
#     notice, this list of conditions and the following disclaimer in 
#     the documentation and/or other materials provided with the 
#     distribution. 
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
#  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
#  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
#  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
#  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
#  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
#  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
#  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
#  DAMAGE.
#
#  The views and conclusions contained in the software and documentation 
#  are those of the authors and should not be interpreted as representing 
#  official policies, either expressed or implied, of the FreeBSD Project.
# 
#******************************************************************

use strict;
use warnings;
use diagnostics;
require Exporter;
use vars qw($VERSION @ISA @EXPORT ); 

our $VERSION     = '1.00';
our @ISA         = qw(Exporter);
our @EXPORT      = qw( printModInst
		       genTBTestFile
		       genUCFFile
		       genVerLowModule
		       genVerTopModule );

1;

sub getFile {
	#------------------------------------------------------------------------------ 
	# Get Verilog HDL File:
	#
	#  The sub-routine getFile() will open the Verilog HDL file 
	#  and read its contents into an array. It will also determine
	#  the file length. The following parameters are created
	#
	#	* filedata:		@vdataA
	#	* fileLen:		scalar(@vdataA)
	#
	#  Usage: $ver_rH = getFile(\%verH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my ($debug) = $verH{'debug'};   # Print out Debug Info.
	
	#------------------------------------------------------------------------------ 
	# Open the Verilog HDL file, and read the results into an array
	# for manipulating the data array. Strip new lines and carriage returns from 
	# remove string array, and initialize for loop variables. Close file when done.
	#------------------------------------------------------------------------------
	open(inF, "<", $verH{ 'file' }) or dienice ("$verH{ 'file' } open failed");
	my @vdataA = <inF>;
	close(inF);
	
	# Strip newlines
	foreach my $i (@vdataA) {
		chomp($i); # Remove any \n line-feeds.
	        $i =~ s/\r//g; # Remove any \r carriage-returns.
	}
	push (@{ $verH{ 'filedata' } }, @vdataA);
	
	#------------------------------------------------------------------------------ 
	# Determine number of lines, and set beginning for loop index.
	#------------------------------------------------------------------------------ 
	$verH{ 'fileLen' } = scalar(@{ $verH{ 'filedata' } }); # number of lines in Verilog file
	
	print("\n\n") if $debug;
	print("Total number of lines: $verH{ 'fileLen' }\n") if $debug;
	print("\n\n") if $debug;
		
	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;
}

sub parseFile {
	#------------------------------------------------------------------------------ 
	# Parse Verilog HDL File:
	#
	#  The sub-routine parseFile() will search through the 
	#  input Verilog HDL File and retrieve line numbers for 
	#  the following parameters:
	#
	#	* modFound:		'module'
	#	* pCFound:		');'
	#	* paramFound:		'#('
	#	* paramEndFound:	')'
	#	* endModFound:		'endmodule'
	#
	#  Usage: $ver_rH = parseFile(\%verH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	my ($modfound) = "";
	my ($pcfound) = "";
	my ($paramfound) = "";
	my ($paramendfound) = "";
	my ($endmodfound) = "";

	#------------------------------------------------------------------------------ 
	# Search through $file for keywords.
	#------------------------------------------------------------------------------
	my $j = -1; 
	for ($j=0; $j < $verH{ 'fileLen' }; $j++) {
		# Search for: 'module'
		if (${ $verH{ 'filedata' } }[$j] =~ m/^module/) {
			$modfound = $j;
			print("'module' Line Number: $modfound\n") if $debug;
		}
		# Search for: ');'
		if (($pcfound eq "") and (${ $verH{ 'filedata' } }[$j] =~ m/\x29\x3b/)) {
			$pcfound = $j;
			print("'\)\;' Line Number: $pcfound\n") if $debug;
		}
		# Search for: '#('
		if (($paramfound eq "") and (${ $verH{ 'filedata' } }[$j] =~ m/\x23\x28/)) {
			$paramfound = $j;
			print("'\#\(' Line Number: $paramfound\n") if $debug;
		}
		# Search for: ')'
		if (($paramfound ne "") and ($paramendfound eq "") and (${ $verH{ 'filedata' } }[$j] =~ m/\x29/)) {
			$paramendfound = $j;
			print("'\)' Line Number: $paramendfound\n") if $debug;
		}
		# Search for: 'endmodule'
		if (${ $verH{ 'filedata' } }[$j] =~ m/^endmodule/) {
			$endmodfound = $j;
			print("'endmodule' Line Number: $endmodfound\n") if $debug;
			$j = $verH{ 'fileLen' };
		}
	}
	
	$verH{ 'modFound' } = $modfound; 
	$verH{ 'pCFound' } = $pcfound;
	$verH{ 'paramFound' } = $paramfound;
	$verH{ 'paramEndFound' } = $paramendfound;
	$verH{ 'endModFound' } = $endmodfound;

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;
}

sub getModDecl {
	#------------------------------------------------------------------------------ 
	# Get Module Declaration from Verilog HDL File:
	#
	#  The sub-routine getModDecl() will search through the 
	#  input Verilog HDL File and extract the Module Declaration
	#  into an array. Push the array into the Verilog Hash.
	#
	#	* modFound:		'module'
	#	* pCFound:		');'
	#	* paramFound:		'#('
	#	* paramEndFound:	')'
	#	* endModFound:		'endmodule'
	#
	#  Usage: $ver_rH = getModDecl($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	#------------------------------------------------------------------------------ 
	# Push contents between 'module' and ending paren '\)\;' into an array.
	#------------------------------------------------------------------------------ 
	my ($k) = -1;
	my (@modDeclTmpA);
	my ($modFound) = $verH{ 'modFound' };		# "module" keyword found.
	my ($pCFound) = $verH{ 'pCFound' };		# ");" Parenthesis Found
	for ($k = $modFound; $k <= $pCFound; $k++) {
		push(@modDeclTmpA, ${ $verH{ 'filedata' } }[$k]);
	}
	
	#------------------------------------------------------------------------------ 
	# Clear out trailing comments and indentation spaces and tabs.
	#------------------------------------------------------------------------------ 
	foreach my $n (@modDeclTmpA) {
		$n =~ s/^.*?input/input/g;	#strip spaces up to input.
		$n =~ s/^.*?output/output/g;	#strip spaces up to output.
		$n =~ s/^.*?inout/inout/g;	#strip spaces up to inout.
		$n =~ s/\x2f\x2f.*//;		#strip any trailing //comment
		$n =~ s/\/\*.*\*\///;		#strip embedded comments
		$n =~ s/.*\x29\x3b/\x29\x3b/;	#strip spaces or tabs up to ");"
		#print("$n\n");
	}
	
	#------------------------------------------------------------------------------ 
	# Print out cleaned module declaration.
	#------------------------------------------------------------------------------ 
	foreach my $m (@modDeclTmpA) {
		if ($m =~ m/\S+/) {
			push(@{ $verH{ 'modDecl' } }, $m);
			print("$m\n") if $debug;
		}
	}
		
	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub getModName {
	#------------------------------------------------------------------------------ 
	# Get Module Name from Module Declaration:
	#
	#  The sub-routine getModName() will search through the 
	#  Module Declaration and extract the following information:
	#
	#	* modName
	#	* Parameterized: "yes" or "no"
	#
	#  Usage: $ver_rH = getModName($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	#------------------------------------------------------------------------------ 
	# Strip off the Module name:
	#------------------------------------------------------------------------------ 
	print("\n\n") if $debug;
	my ($crap1, $modname, $crap2) = (${ $verH{ 'modDecl' } }[0] =~ /(\S+\s+)(\S+)(.*)/);
	$verH{ 'modName' } = $modname;
	print("Module Name: $verH{ 'modName' }\n") if $debug;
	
	if (($verH{ 'paramFound' } eq "") or ($verH{ 'paramFound' } > $verH{ 'pCFound' }))  {
		$verH{ 'Parameterized' } = "no";
		print("Is this a parameterizable module? $verH{ 'Parameterized' }\n") if $debug;
	} else {
		$verH{ 'Parameterized' } = "yes";
		print("Is this a parameterizable module? $verH{ 'Parameterized' }\n") if $debug;
	}
		
	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub getModIO {
	#------------------------------------------------------------------------------ 
	# Get Module I/O from Module Declaration:
	#
	#  The sub-routine getModIO() will search through the 
	#  Module Declaration and extract the input, inout, and 
	#  output signal names. The following paramters are created:
	#
	#	* modIO
	#	* modIn
	#	* modOut
	#
	#  Usage: $ver_rH = getModIO($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	#------------------------------------------------------------------------------ 
	# Get Module Declaration:
	#
	#	* Store Module Declaration array in a temporary array.
	#	* Determine the number of ports.
	#
	#------------------------------------------------------------------------------ 
	my (@modDeclA) = @{ $verH{ 'modDecl' } }; # Module Decl for parsing ports.
	my (@paramA) = @{ $verH{ 'modDecl' } }; # Module Decl for parsing parameters.
	my ($modLen) = scalar(@modDeclA);

	#------------------------------------------------------------------------------ 
	# Get Inputs, InOuts, and Outputs and store each in their respective arrays.
	#------------------------------------------------------------------------------ 
	my ($line) = -1;
	my (@allportsonlyA);
	my ($allportsonlyA_Len);
	my (@allportsA);
	my ($allportsA_Len);

	# Push lines from the module declaration that match input, inout, or output into 
	# an arrays:
	for ($line = 1; $line < ($modLen-1); $line++) {
	        if ($modDeclA[$line] =~  m/\s*(input|output|inout).*/) {
			push(@allportsA, $modDeclA[$line]);
		}
	}

	$allportsA_Len = scalar(@allportsA);
	print("Port Length: $allportsA_Len\n") if $debug;

	@allportsonlyA = @allportsA;
	$allportsonlyA_Len = scalar(@allportsonlyA);
	print("Line Length: $allportsonlyA_Len\n") if $debug;

	# Strip off all information except the port name for all ports:
	foreach my $i (@allportsonlyA) {
		$i =~ s/\s*(input|output|inout)\s*//;
		$i =~ s/\s*signed\s*//;
		$i =~ s/\s*(reg|wire)\s*//;
		$i =~ s/\s*\x5b.*\x5d\s*//;
		$i =~ s/\s+$//;
		$i =~ s/,//;
		print("$i\n") if ($debug);
		
	}	
	for ($line = 1; $line < ($allportsA_Len-1); $line++) {
		print("Line: $allportsA[$line]\n") if $debug;
		print("Port: $allportsonlyA[$line]\n") if $debug;
	}

	#------------------------------------------------------------------------------ 
	# Get Parameters and Values. Calculate width of each port.
	#------------------------------------------------------------------------------ 
	my (%allportsHoH) = ();
	my ($param, $crap2, $paramval, $crap3);	
	my (%paramHoH) = (); # Parameter Hash: param = paramval.
	my ($msb, $colon, $lsb); # MSB:LSB.
	my ($width); # Port Width.
	my ($tempLine);
	my ($direction); # Port Direction: input, inout, or output.
	my ($wrl); # Wire, Register, or Logic.
	if ($verH{ 'Parameterized' } =~ m/yes/) {
	    foreach my $j (@paramA) {
	        if ($j =~ m/parameter/) {
	            $j =~ s/.*parameter\s+//;
	            ($param, $crap2, $paramval, $crap3) = ($j =~ /(\S+)(\s+=\s+)(\S+)([,\x29].*)/);
	            $paramHoH{ $param }{ 'parameter' } = $param;
	            $paramHoH{ $param }{ 'value' } = $paramval;
	            print("Parameter: $paramHoH{ $param }{ 'parameter' }\n") if $debug;
	            print("Parameter Value: $paramHoH{ $param }{ 'value' }\n") if $debug;
	        }
	    }
	    for ($line = 0; $line < ($allportsA_Len); $line++) {
	        if ($allportsA[$line] =~ m/\x5b/) {
                    # Determine port direction:
		    if ($allportsA[$line] =~ m/input/) {
			    $direction = "input";
		    } elsif ($allportsA[$line] =~ m/inout/) {
			    $direction = "inout";
		    } elsif ($allportsA[$line] =~ m/output/) {
			    $direction = "output";
		    }
		    if ($allportsA[$line] =~ m/wire/) {
			    $wrl = "wire";
		    } elsif ($allportsA[$line] =~ m/reg/) {
			    $wrl = "reg";
		    } elsif ($allportsA[$line] =~ m/logic/) {
			    $wrl = "logic";
		    }
	            $tempLine = $allportsA[$line];
	            $tempLine =~ s/\s+/ /g;
	            $tempLine =~ s/,//;
	            $tempLine =~ s/\s+$//;
	            $allportsA[$line] =~ s/.*\x5b//;
	            $allportsA[$line] =~ s/\x5d.*//;
	            ($msb, $colon, $lsb) = ($allportsA[$line] =~ /(\S+)(:)(\S+)/);
	            #print("MSB: $msb, LSB: $lsb\n");
	            for my $key ( sort(keys %paramHoH) ) {
	                #print("$key => $paramHoH{$key}{'value'}\n") if $debug;
	                if ($msb =~ m/$paramHoH{$key}{'parameter'}/) {
	                    print("Key: $paramHoH{$key}{'parameter'}\n") if $debug;
	                    print("Value: $paramHoH{$key}{'value'}\n") if $debug;
	                    my $param_minus_1 = ($paramHoH{$key}{'value'}-1);
			    if ($msb =~ /\x28/) {
		                    $msb =~ s/\x28$paramHoH{$key}{'parameter'}-1\x29/$param_minus_1/;
			    } else {
		                    $msb =~ s/$paramHoH{$key}{'parameter'}-1/$param_minus_1/;
			    }
	                }
	            }
	            $width = ($msb+1);
		    $allportsHoH{$allportsonlyA[$line]}{'port'} = $allportsonlyA[$line];
		    $allportsHoH{$allportsonlyA[$line]}{'width'} = $width;
		    $allportsHoH{$allportsonlyA[$line]}{'direction'} = $direction;
		    $allportsHoH{$allportsonlyA[$line]}{'wrl'} = $wrl;
	            print("Line: $tempLine, MSB: $msb, LSB: $lsb, Width: $width, Direction: $direction\n") if $debug;
	        } else {
                    # Determine port direction:
		    if ($allportsA[$line] =~ m/input/) {
			    $direction = "input";
		    } elsif ($allportsA[$line] =~ m/inout/) {
			    $direction = "inout";
		    } elsif ($allportsA[$line] =~ m/output/) {
			    $direction = "output";
		    }
		    if ($allportsA[$line] =~ m/wire/) {
			    $wrl = "wire";
		    } elsif ($allportsA[$line] =~ m/reg/) {
			    $wrl = "reg";
		    } elsif ($allportsA[$line] =~ m/logic/) {
			    $wrl = "logic";
		    }
	            $tempLine = $allportsA[$line];
	            $tempLine =~ s/\s+/ /g;
	            $tempLine =~ s/,//;
	            $tempLine =~ s/\s+$//;
	            $width = 1;
		    $allportsHoH{$allportsonlyA[$line]}{'port'} = $allportsonlyA[$line];
		    $allportsHoH{$allportsonlyA[$line]}{'width'} = $width;
		    $allportsHoH{$allportsonlyA[$line]}{'direction'} = $direction;
		    $allportsHoH{$allportsonlyA[$line]}{'wrl'} = $wrl;
	            print("Line: $tempLine, Width: $width, Direction: $direction\n") if $debug;
	        }
	    }
	    print("\n\n") if $debug;
	} else {
	    for ($line = 0; $line < ($allportsA_Len); $line++) {
	        if ($allportsA[$line] =~ m/\x5b/) {
                    # Determine port direction:
		    if ($allportsA[$line] =~ m/input/) {
			    $direction = "input";
		    } elsif ($allportsA[$line] =~ m/inout/) {
			    $direction = "inout";
		    } elsif ($allportsA[$line] =~ m/output/) {
			    $direction = "output";
		    }
		    if ($allportsA[$line] =~ m/wire/) {
			    $wrl = "wire";
		    } elsif ($allportsA[$line] =~ m/reg/) {
			    $wrl = "reg";
		    } elsif ($allportsA[$line] =~ m/logic/) {
			    $wrl = "logic";
		    }
	            $tempLine = $allportsA[$line];
	            $tempLine =~ s/(\s+)/ /;
	            $tempLine =~ s/,//;
	            $tempLine =~ s/\s+$//;
	            $allportsA[$line] =~ s/.*\x5b//;
	            $allportsA[$line] =~ s/\x5d.*//;
	            ($msb, $colon, $lsb) = ($allportsA[$line] =~ /(\S+)(:)(\S+)/);
	            $width = ($msb+1);
		    $allportsHoH{$allportsonlyA[$line]}{'port'} = $allportsonlyA[$line];
		    $allportsHoH{$allportsonlyA[$line]}{'width'} = $width;
		    $allportsHoH{$allportsonlyA[$line]}{'direction'} = $direction;
		    $allportsHoH{$allportsonlyA[$line]}{'wrl'} = $wrl;
	            print("Line: $tempLine, MSB: $msb, LSB: $lsb, Width: $width, Direction: $direction\n") if $debug;
	        } else {
                    # Determine port direction:
   		    if ($allportsA[$line] =~ m/input/) {
			    $direction = "input";
		    } elsif ($allportsA[$line] =~ m/inout/) {
			    $direction = "inout";
		    } elsif ($allportsA[$line] =~ m/output/) {
			    $direction = "output";
		    }
		    if ($allportsA[$line] =~ m/wire/) {
			    $wrl = "wire";
		    } elsif ($allportsA[$line] =~ m/reg/) {
			    $wrl = "reg";
		    } elsif ($allportsA[$line] =~ m/logic/) {
			    $wrl = "logic";
		    }
	            $tempLine = $allportsA[$line];
	            $tempLine =~ s/\s+/ /g;
	            $tempLine =~ s/,//;
	            $tempLine =~ s/\s+$//;
	            $width = 1;
		    $allportsHoH{$allportsonlyA[$line]}{'port'} = $allportsonlyA[$line];
		    $allportsHoH{$allportsonlyA[$line]}{'width'} = $width;
		    $allportsHoH{$allportsonlyA[$line]}{'direction'} = $direction;
		    $allportsHoH{$allportsonlyA[$line]}{'wrl'} = $wrl;
	            print("Line: $tempLine, Width: $width, Direction: $direction\n") if $debug;
	        }
	    }
	    print("\n\n") if $debug;
	}

	%{ $verH{ 'modParams' } } = %paramHoH;
	%{ $verH{ 'modIO' } } = %allportsHoH;

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub genModInst {
	#------------------------------------------------------------------------------ 
	# Generate Module Instantiation:
	#
	#  The sub-routine genModInst() will generate the Verilog HDL module 
	#  instantiation. An example module instantiation is shown below:
	#
	#		freq_meas   _freq_meas (.clk50mhz (clk50mhz),
	#					.rst_n (rst_n),
	#					.clk_in (clk_in),
	#					.cnt_rm_ref_lmt (cnt_rm_ref_lmt),
	#					.cnt_fm_ref_lmt (cnt_fm_ref_lmt),
	#					.rm_d1_out (rm_d1_out),
	#					.rm_d2_out (rm_d2_out),
	#					.rm_done (rm_done),
	#					.fm_d1_out (fm_d1_out),
	#					.fm_d2_out (fm_d2_out),
	#					.fm_done (fm_done));
	#
	#  Usage: $ver_rH = genModInst($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	#------------------------------------------------------------------------------ 
	# Get Module IO Ports Array:
	#
	#	* Assign to temporary array.
	#	* Determine number of IO Ports.
	#
	#------------------------------------------------------------------------------ 
	# Copy the Parameter Hash to a local hash:
	my (%allportsHoH) = %{ $verH{ 'modIO' } };
	my (@ioports) = ();
	my (@inports) = ();
	my (@outports) = ();
	# Push lines from the module declaration that match input, inout, or output into 
	# their respective arrays:
	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} =~ m/input/) {
			push(@inports, $allportsHoH{$key}{'port'});
		} elsif ($allportsHoH{$key}{'direction'} =~ m/inout/) {
			push(@ioports, $allportsHoH{$key}{'port'});
		} elsif ($allportsHoH{$key}{'direction'} =~ m/output/) {
			push(@outports, $allportsHoH{$key}{'port'});
		}
	}
	my ($numioports) = scalar(@ioports);
	my ($numinports) = scalar(@inports);
	my ($numoutports) = scalar(@outports);
	print("Number of IO Ports: $numioports\n") if $debug;
	print("Number of In Ports: $numinports\n") if $debug;
	print("Number of Out Ports: $numoutports\n") if $debug;

	#------------------------------------------------------------------------------ 
	# Get Module Name:
	#------------------------------------------------------------------------------ 
	my ($modname) = $verH{ 'modName' };

	if ( ($numinports eq 0) and ($numioports eq 0) and ($numoutports eq 0) ) {
		print("* Error: Cannot create instantiation of module '$modname'.\n  Verify module uses an ANSI-C Type Module Declaration.\n");
		exit;
	} else {
        
        	#------------------------------------------------------------------------------ 
        	# Print out Module Instantiation:
        	#------------------------------------------------------------------------------ 
        	my ($indent_spaces) = "";
                my ($modinst) = "";
        	$modinst = "//** Instantiate the $modname module **\n";
        	if ($verH{ 'Parameterized' } =~ m/yes/) {
        		#----------------------------------------------------------------------
        		# Assemble First Line of Instantiation:
        		#----------------------------------------------------------------------
        		# Copy the Parameter Hash to a local hash:
        		my (%paramHoH) = %{ $verH{ 'modParams' } };
        		# Determine number of parameters:
        		my ($paramHoH_Size) = 0;
        	        $paramHoH_Size += scalar keys %paramHoH;  # method 1: explicit scalar context
        		print("Size of Hash: $paramHoH_Size\n") if $debug;
        		# Start building up the first line of the instantiation:
        		my ($modinst_line1) = "$modname  #(";
        		for my $key ( sort(keys %paramHoH) ) {
        			print("Parameter Size Count: $paramHoH_Size\n") if $debug;
        			if ($paramHoH_Size <= 1) {
        				# If we're on the last parameter, 
        				# don't add a ", " (i.e., a comma followed by a space).
        				$modinst_line1 .= ".$paramHoH{$key}{'parameter'}($paramHoH{$key}{'value'})";
        			} else {
        				$modinst_line1 .= ".$paramHoH{$key}{'parameter'}($paramHoH{$key}{'value'}), ";
        			}
        			$paramHoH_Size -= 1;
        		}
        		$modinst_line1 .= ")  _$modname";
        		$modinst_line1 = sprintf("$modinst_line1    (");
        
        		#----------------------------------------------------------------------
        		# Determine number of indent spaces:
        		#
        		#	* Tab Space = 8
        		#	* Create string with correct numer of indent spaces.
        		#
        		#----------------------------------------------------------------------
        		my ($tmpinst_len) = length($modinst_line1);
        		print("Number of Indent Spaces: $tmpinst_len\n") if $debug;
        		my ($i) = 0;
        		my (@indent);
        		for ($i = 0; $i < $tmpinst_len; $i++) {
        			push(@indent, " ");
        		}
        		$indent_spaces = join("",@indent);
        		$modinst .= "$modinst_line1";
        	} else {
        		#----------------------------------------------------------------------
        		# Assemble First Line of Instantiation:
        		#----------------------------------------------------------------------
        		my ($modinst_line1) = "$modname        _$modname        (";
        
        		#----------------------------------------------------------------------
        		# Determine number of indent spaces:
        		#
        		#	* Tab Space = 8
        		#	* Assemble first line of Module Instantiation.
        		#	* Create string with correct numer of indent spaces.
        		#
        		#----------------------------------------------------------------------
        		my ($tmpinst_len) = length($modinst_line1);
        		print("Number of Indent Spaces: $tmpinst_len\n") if $debug;
        		my ($i) = 0;
        		my (@indent);
        		for ($i = 0; $i < $tmpinst_len; $i++) {
        			push(@indent, " ");
        		}
        		$indent_spaces = join("",@indent);
        		$modinst .= "$modinst_line1";
        	}


		# Sort In,I/O,Out Array of Net Names Alphabetically:
		@inports = sort(@inports);
		@ioports = sort(@ioports);
		@outports = sort(@outports);

		# Create Clock Hash:
		my (%clkH);
		my (%clk_rH);

		# Find clock net(s): 
		my (@clk_indexA) = ();
		my ($i) = 0;
		for ($i = 0; $i < $numinports; $i++) {
			if ($inports[$i] =~ m/clk/) {
				print("Clk Index: $i\n") if $debug;
				push(@clk_indexA, $i);
			}
		}
		push (@{ $clkH{ 'clk_indexA' } }, @clk_indexA);

		# Find min clk_net index:
		my (@clk_index_sortedA) = ();
		@clk_index_sortedA = sort {$a <=> $b} @clk_indexA;
		print("Clock Net (minimum index): ") if $debug;
		if (defined $clk_index_sortedA[0]) {
			print("$clk_index_sortedA[0]\n") if $debug;
		} else {
			print("NA\n") if $debug;
		}
		my ($clk_len) = scalar(@clk_index_sortedA);
		print("Number of Clock Nets: $clk_len\n") if $debug;
		push (@{ $clkH{ 'clk_index_sortedA' } }, @clk_index_sortedA);
		$clkH{ 'clk_indexA_Len' } = $clk_len;
		$clkH{ 'debug' } = $debug;

		# Print out the "clock inputs" in the instantiation:
		my ($c) = 0;
		for ($c = 0; $c < $clk_len; $c++) {
			if ($c eq 0) {
				$modinst .= ".$inports[$clk_index_sortedA[$c]] ($inports[$clk_index_sortedA[$c]]),\n";
			} else {
				$modinst .= "$indent_spaces.$inports[$clk_index_sortedA[$c]] ($inports[$clk_index_sortedA[$c]]),\n";
			}	
		}
		
		# Print out the remainder of the "inputs" in the instantiation:
		my ($j) = 0;
		for ($j = 0; $j < $numinports; $j++) {
			# Assign current index to clock hash:
			$clkH{ 'j' } = $j;

			# Check current index against all clock indices:
			if ((&checkClkIndex(\%clkH)) eq 0) {
				$modinst .= "$indent_spaces.$inports[$j] ($inports[$j]),\n";
			}	
		}

		# Print out the "inouts" in the instantiation:
		if ($numioports > 0) {
			$modinst .= "\n";
			for ($j = 0; $j < $numioports; $j++) {
				$modinst .= "$indent_spaces.$ioports[$j] ($ioports[$j]),\n";
			}
		}

		$modinst .= "\n";

		# Print out the "outputs" in the instantiation:
		for ($j = 0; $j < $numoutports; $j++) {
			if ($j eq ($numoutports-1)) {
				$modinst .= "$indent_spaces.$outports[$j] ($outports[$j]));\n";
			} else {
				$modinst .= "$indent_spaces.$outports[$j] ($outports[$j]),\n";
			}
		}
        
                $verH{ 'modInst' } = $modinst;
	}
        
	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub checkClkIndex {
	#------------------------------------------------------------------------------ 
	# Check Input Port Index Against Clock Indices:
	#
	#  The sub-routine checkClkIndex() will check the current input port index 
	#  against all identified clock indices. It will set a flag high if it matches,
	#  or leave it low if no match has occured.
	#
	#
	#  Usage: $clk_rH = checkClkIndex(\%clkH);
	#
	#------------------------------------------------------------------------------ 
	my ($clk_rH) = shift;	# Read in user's variable.

	my (%clkH) = %{ $clk_rH };
	my $len = $clkH{ 'clk_indexA_Len'};
	my $debug = $clkH{ 'debug' };
	my $index = $clkH{ 'j' };

    	my (@clk_index_sortedA);
	push(@clk_index_sortedA, @{$clkH{ 'clk_index_sortedA' }});

	print("Index: $index\n") if $debug;
	print("Clk Index Len: $len\n") if $debug;

	my ($cnt) = 0;
	my ($yes_or_no) = 0; # Default No
	my ($i) = 0;
	for ($i = 0; $i < $len; $i++) {
		if ($index eq $clk_index_sortedA[$i]) {
			$cnt += 1;
			print("Clk Index: $clk_index_sortedA[$i]\n") if $debug;
		}
	}
	if ($cnt > 0) {
		$yes_or_no = 1;
	}

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
	return $yes_or_no;
}

sub printModInst {
	#------------------------------------------------------------------------------ 
	# Print Module Instantiation:
	#
	#  The sub-routine printModInst() will print out the Verilog HDL module 
	#  instantiation. An example module instantiation is shown below:
	#
	#		freq_meas   _freq_meas (.clk50mhz (clk50mhz),
	#					.rst_n (rst_n),
	#					.clk_in (clk_in),
	#					.cnt_rm_ref_lmt (cnt_rm_ref_lmt),
	#					.cnt_fm_ref_lmt (cnt_fm_ref_lmt),
	#					.rm_d1_out (rm_d1_out),
	#					.rm_d2_out (rm_d2_out),
	#					.rm_done (rm_done),
	#					.fm_d1_out (fm_d1_out),
	#					.fm_d2_out (fm_d2_out),
	#					.fm_done (fm_done));
	#
	#  Usage: $ver_rH = printModInst($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	#------------------------------------------------------------------------------ 
	# Open $file and stuff it into an array.
	#------------------------------------------------------------------------------ 
	$ver_rH = getFile($ver_rH);

	#------------------------------------------------------------------------------ 
	# Search through $file for keywords.
	#------------------------------------------------------------------------------ 
	$ver_rH = parseFile($ver_rH);
	
	#------------------------------------------------------------------------------ 
	# Get Module Declaration:
	#------------------------------------------------------------------------------ 
	$ver_rH = getModDecl($ver_rH);
	
	#------------------------------------------------------------------------------ 
	# Get Module Name:
	#------------------------------------------------------------------------------ 
	$ver_rH = getModName($ver_rH);
	
	#------------------------------------------------------------------------------ 
	# Get Module I/O:
	#------------------------------------------------------------------------------ 
	$ver_rH = getModIO($ver_rH);

	#------------------------------------------------------------------------------ 
	# Generate Module Instantiation:
	#------------------------------------------------------------------------------ 
	$ver_rH = genModInst($ver_rH);

	%verH = %{ $ver_rH }; # De-reference Verilog hash.

        my $modinst = $verH{ 'modInst' };
	print("$modinst");

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub genTBTop {
	#------------------------------------------------------------------------------ 
	# Print Test Bench Top Module Header:
	#
	#  The sub-routine genTBTop() will generate the Verilog HDL test bench top module. 
	#
	#  Usage: $ver_rH = genTBTop($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my $file_v = $verH{'file'};
	my $tbTestFile = $verH{ 'tbTestFile' };
        my $modinst = $verH{ 'modInst' };
	my $day = $verH{'day'};
	my $month = $verH{'month'};
	my $username = $verH{'username'};
	my $year = $verH{'year'};
	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	# Fix month, day, year:
	my $monthR = $month+1;
	my $yearR = $year+1900;

	# Get Filename:
	# strip .v from filename
	my $file = $file_v;
        $file =~ s/\x2ev//;
        $file =~ s/\x2e//g;
        $file =~ s/\x2f//g;
	my $tbTopFile = join ".","top","v";

	#------------------------------------------------------------------------------ 
	# Generate Test Module Instantiation
	#------------------------------------------------------------------------------ 
	#------------------------------------------------------------------------------ 
	#------------------------------------------------------------------------------ 
	# Get Module IO Ports Array:
	#
	#	* Assign to temporary array.
	#	* Determine number of IO Ports.
	#
	#------------------------------------------------------------------------------ 
	# Copy the Parameter Hash to a local hash:
	my (%allportsHoH) = %{ $verH{ 'modIO' } };
	my (@ioports) = ();
	my (@clkports) = ();
	my (@inports) = ();
	my (@outports) = ();
	# Push lines from the module declaration that match input, inout, or output into 
	# their respective arrays:
	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} =~ m/input/) {
			if ($allportsHoH{$key}{'port'} =~ m/(clk|clock)/) {
				push(@inports, $allportsHoH{$key}{'port'});
				push(@clkports, $allportsHoH{$key}{'port'});
			} else {
				push(@outports, $allportsHoH{$key}{'port'});
			}
		} elsif ($allportsHoH{$key}{'direction'} =~ m/inout/) {
			push(@ioports, $allportsHoH{$key}{'port'});
		} elsif ($allportsHoH{$key}{'direction'} =~ m/output/) {
			push(@inports, $allportsHoH{$key}{'port'});
		}
	}
	my ($numioports) = scalar(@ioports);
	my ($numinports) = scalar(@inports);
	my ($numoutports) = scalar(@outports);
	print("Number of IO Ports: $numioports\n") if $debug;
	print("Number of In Ports: $numinports\n") if $debug;
	print("Number of Out Ports: $numoutports\n") if $debug;

	#------------------------------------------------------------------------------ 
	# Get Module Name:
	#------------------------------------------------------------------------------ 
	my ($modname) = $verH{ 'modName' };
	my $test_modname = join "_", "test", $modname;
	#------------------------------------------------------------------------------ 
	# Print out Module Instantiation:
	#------------------------------------------------------------------------------ 
	my ($indent_spaces) = "";
        my ($TestModInst) = "";
	$TestModInst = "//** Instantiate the Test module **\n";
#	if ($verH{ 'Parameterized' } =~ m/yes/) {
#		#----------------------------------------------------------------------
#		# Assemble First Line of Instantiation:
#		#----------------------------------------------------------------------
#		# Copy the Parameter Hash to a local hash:
#		my (%paramHoH) = %{ $verH{ 'modParams' } };
#		# Determine number of parameters:
#		my ($paramHoH_Size) = 0;
#	        $paramHoH_Size += scalar keys %paramHoH;  # method 1: explicit scalar context
#		print("Size of Hash: $paramHoH_Size\n") if $debug;
#		# Start building up the first line of the instantiation:
#		my ($modinst_line1) = "$modname  #(";
#		for my $key ( keys %paramHoH ) {
#			print("Parameter Size Count: $paramHoH_Size\n") if $debug;
#			if ($paramHoH_Size <= 1) {
#				# If we're on the last parameter, 
#				# don't add a ", " (i.e., a comma followed by a space).
#				$modinst_line1 .= ".$paramHoH{$key}{'parameter'}($paramHoH{$key}{'value'})";
#			} else {
#				$modinst_line1 .= ".$paramHoH{$key}{'parameter'}($paramHoH{$key}{'value'}), ";
#			}
#			$paramHoH_Size -= 1;
#		}
#		$modinst_line1 .= ")  test";
#		$modinst_line1 = sprintf("$modinst_line1    (");
#
#		#----------------------------------------------------------------------
#		# Determine number of indent spaces:
#		#
#		#	* Tab Space = 8
#		#	* Create string with correct numer of indent spaces.
#		#
#		#----------------------------------------------------------------------
#		my ($tmpinst_len) = length($modinst_line1);
#		print("Number of Indent Spaces: $tmpinst_len\n") if $debug;
#		my ($i) = 0;
#		my (@indent);
#		for ($i = 0; $i < $tmpinst_len; $i++) {
#			push(@indent, " ");
#		}
#		$indent_spaces = join("",@indent);
#		$TestModInst .= "$modinst_line1";
#	} else {
		#----------------------------------------------------------------------
		# Assemble First Line of Instantiation:
		#----------------------------------------------------------------------
		my ($modinst_line1) = "$test_modname        test        (";

		#----------------------------------------------------------------------
		# Determine number of indent spaces:
		#
		#	* Tab Space = 8
		#	* Assemble first line of Module Instantiation.
		#	* Create string with correct numer of indent spaces.
		#
		#----------------------------------------------------------------------
		my ($tmpinst_len) = length($modinst_line1);
		print("Number of Indent Spaces: $tmpinst_len\n") if $debug;
		my ($i) = 0;
		my (@indent);
		for ($i = 0; $i < $tmpinst_len; $i++) {
			push(@indent, " ");
		}
		$indent_spaces = join("",@indent);
		$TestModInst .= "$modinst_line1";
#	}

	# Sort In,I/O,Out Array of Net Names Alphabetically:
	@inports = sort(@inports);
	@ioports = sort(@ioports);
	@outports = sort(@outports);

	# Create Clock Hash:
	my (%clkH);
	my (%clk_rH);

	# Find clock net(s): 
	my (@clk_indexA) = ();
	my ($u) = 0;
	for ($u = 0; $u < $numinports; $u++) {
		if ($inports[$u] =~ m/clk/) {
			print("Clk Index: $u\n") if $debug;
			push(@clk_indexA, $u);
		}
	}
	push (@{ $clkH{ 'clk_indexA' } }, @clk_indexA);

	# Find min clk_net index:
	my (@clk_index_sortedA) = ();
	@clk_index_sortedA = sort {$a <=> $b} @clk_indexA;
	print("Clock Net (minimum index): ") if $debug;
	if (defined $clk_index_sortedA[0]) {
		print("$clk_index_sortedA[0]\n") if $debug;
	} else {
		print("NA\n") if $debug;
	}
	my ($clk_len) = scalar(@clk_index_sortedA);
	print("Number of Clock Nets: $clk_len\n") if $debug;
	push (@{ $clkH{ 'clk_index_sortedA' } }, @clk_index_sortedA);
	$clkH{ 'clk_indexA_Len' } = $clk_len;
	$clkH{ 'debug' } = $debug;

	# Print out the "clock inputs" in the instantiation:
	my ($c) = 0;
	for ($c = 0; $c < $clk_len; $c++) {
		if ($c eq 0) {
			$TestModInst .= ".$inports[$clk_index_sortedA[$c]] ($inports[$clk_index_sortedA[$c]]),\n";
		} else {
			$TestModInst .= "$indent_spaces.$inports[$clk_index_sortedA[$c]] ($inports[$clk_index_sortedA[$c]]),\n";
		}	
	}
	
	# Print out the remainder of the "inputs" in the instantiation:
	my ($v) = 0;
	for ($v = 0; $v < $numinports; $v++) {
		# Assign current index to clock hash:
		$clkH{ 'j' } = $v;

		# Check current index against all clock indices:
		if ((&checkClkIndex(\%clkH)) eq 0) {
			$TestModInst .= "$indent_spaces.$inports[$v] ($inports[$v]),\n";
		}	
	}

	# Print out the "inouts" in the instantiation:
	if ($numioports > 0) {
		$TestModInst .= "\n";
		for ($v = 0; $v < $numioports; $v++) {
			$TestModInst .= "$indent_spaces.$ioports[$v] ($ioports[$v]),\n";
		}
	}
	$TestModInst .= "\n";
	# Print out the "outputs" in the instantiation:
	for ($v = 0; $v < $numoutports; $v++) {
		if ($v eq ($numoutports-1)) {
			$TestModInst .= "$indent_spaces.$outports[$v] ($outports[$v]));\n";
		} else {
			$TestModInst .= "$indent_spaces.$outports[$v] ($outports[$v]),\n";
		}
	}

        $verH{ 'TestModInst' } = $TestModInst;

	#------------------------------------------------------------------------------ 
	# Generate: Clocks
	#------------------------------------------------------------------------------ 
	my ($clkgen1) = "";
	my ($clkgen2) = "";

	foreach my $i (@clkports) {
		$clkgen1 .= "  $i <= 1'b1;\n";	
		$clkgen2 .= "always #4 $i <= ~$i;\n";
	}
	
	$clkgen1 =~ s/\n$//;
	$clkgen2 =~ s/\n$//;

	#------------------------------------------------------------------------------ 
        # Generate the Input portion of the Module Declarations:
	#------------------------------------------------------------------------------ 
	#my (%allportsHoH) = %{ $verH{ 'modIO' } };
	my (@iolines) = ();
	my (@inlines) = ();
	my (@outlines) = ();
	my ($msb) = 0;
	my ($lsb) = 0;
	my ($templine) = "";
	# Push lines from the module declaration that match input, inout, or output into 
	# their respective arrays:
	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} eq "input") {
			print("Port: $allportsHoH{$key}{'port'}, Direction: $allportsHoH{$key}{'direction'}\n") if $debug;
		}
	}

	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'port'} =~ m/(clk|clock)/) {
			$templine = "reg             $allportsHoH{$key}{'port'};\n";
			push(@inlines, $templine);
			print("Clock: $templine\n") if $debug;
		}
	}

	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} eq "input") {
			if ($allportsHoH{$key}{'width'} > 1) {
				$msb = $allportsHoH{$key}{'width'};
				$msb -= 1;
				$templine = "wire  [$msb:$lsb]    $allportsHoH{$key}{'port'};\n";
				push(@inlines, $templine);
				print("Input: $templine\n") if $debug;
			} elsif(($allportsHoH{$key}{'width'} == 1) and !($allportsHoH{$key}{'port'} =~ m/(clk|clock)/)) {
				$templine = "wire            $allportsHoH{$key}{'port'};\n";
				push(@inlines, $templine);
				print("Input: $templine\n") if $debug;
			}
		} 
	}

	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} eq "inout") {
			if ($allportsHoH{$key}{'width'} > 1) {
				$msb = $allportsHoH{$key}{'width'};
				$msb -= 1;
				$templine = "wire  [$msb:$lsb]    $allportsHoH{$key}{'port'};\n";
				push(@iolines, $templine);
				print("InOut: $templine\n") if $debug;
			} else {
				$templine = "wire            $allportsHoH{$key}{'port'};\n";
				push(@iolines, $templine);
				print("InOut: $templine\n") if $debug;
			}
		} 
	}

	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} eq "output") {
			if ($allportsHoH{$key}{'width'} > 1) {
				$msb = $allportsHoH{$key}{'width'};
				$msb -= 1;
				$templine = "wire  [$msb:$lsb]    $allportsHoH{$key}{'port'};\n";
				push(@outlines, $templine);
				print("Output: $templine\n") if $debug;
			} else {
				$templine = "wire            $allportsHoH{$key}{'port'};\n";
				push(@outlines, $templine);
				print("Output: $templine\n") if $debug;
			}
		} 
	}

	my ($inDecl) = join("",@inlines);
	my ($ioDecl) = join("",@iolines);
	my ($outDecl) = join("",@outlines);

	print("\n\nInput Declarations: \n$inDecl") if $debug;
	print("InOut Declarations: \n$ioDecl") if $debug;
	print("Output Declarations: \n$outDecl\n") if $debug;

	#------------------------------------------------------------------------------ 
	# Build up Top-Level Test Bench File.
	#------------------------------------------------------------------------------ 
	my $tbTopBody=<<"EOF";
/*****************************************************************

 $tbTopFile module

******************************************************************

 COMPANY Confidential Copyright © $yearR 

******************************************************************

 created on:	$monthR/$day/$yearR 
 created by:	$username
 last edit on:	\$DateTime: \$ 
 last edit by:	\$Author: \$
 revision:\t\t\$Revision: \$
 comments:\t\t Generated

******************************************************************
 //Project// (//Number//)

 This module tests the $file_v module.

******************************************************************/
`include "../../../$file_v"
`include "$tbTestFile"
`timescale        1ns/1ps

module top;  // top-level netlist to connect testbench to dut
  
timeunit 1ns; timeprecision 1ps;

// *** Input to UUT ***
$inDecl
// *** Inouts to UUT ***
$ioDecl
// *** Outputs from UUT ***
$outDecl

$modinst

$TestModInst


// clk generators
initial begin
$clkgen1
end

// Generate clock:
$clkgen2


endmodule


EOF

	$verH{ 'tbTopFile' } = $tbTopFile;
	$verH{ 'tbTopBody' } = $tbTopBody;

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub genTBTestHeader {
	#------------------------------------------------------------------------------ 
	# Print Test Bench Module Header:
	#
	#  The sub-routine printTBHeader() will print out the Verilog HDL test bench 
	#  module instantiation. 
	#
	#  Usage: $ver_rH = printTBHeader($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my $file_v = $verH{'file'};
	my $day = $verH{'day'};
	my $month = $verH{'month'};
	my $username = $verH{'username'};
	my $year = $verH{'year'};
	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	# Fix month, day, year:
	my $monthR = $month+1;
	my $yearR = $year+1900;

	# Get Filename:
	# strip .v from filename
	my $file = $file_v;
        $file =~ s/\x2ev//;
        $file =~ s/\x2e//g;
        $file =~ s/\x2f//g;
	my $test_file = join "_", "test", $file;
	my $tbTestFile = join ".",$test_file,"v";

	my $tbTestHead=<<"EOF";
/*****************************************************************

 $tbTestFile module

******************************************************************

 COMPANY Confidential Copyright © $yearR

******************************************************************

 created on:	$monthR/$day/$yearR 
 created by:	$username
 last edit on:	\$DateTime: \$ 
 last edit by:	\$Author: \$
 revision:\t\t\$Revision: \$
 comments:\t\t Generated

******************************************************************
 //Project// (//Number//)

 This module implements the test bench for the $file_v module.

	// enter detailed description here;


******************************************************************/
`timescale        1ns/1ps


EOF

	$verH{ 'tbTestFile' } = $tbTestFile;
	$verH{ 'tbTestHead' } = $tbTestHead;

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub genTBTestBody {
	#------------------------------------------------------------------------------ 
	# Print Test Bench Module Body:
	#
	#  The sub-routine printTBBody() will print out the body of the Verilog HDL 
	#  module test bench.
	#
	#  Usage: $ver_rH = printTBBody($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my $modname = $verH{ 'modName' };
	my $test_modname = join "_", "test", $modname;
	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	#----------------------------------------------------------------------
	# Determine number of indent spaces:
	#
	#	* Tab Space = 8
	#	* Create string with correct numer of indent spaces.
	#
	#----------------------------------------------------------------------
	my ($indent_spaces) = "";
	my ($modinst_line1) = "module    $test_modname        (/";
	my ($tmpinst_len) = length($modinst_line1);
	print("Number of Indent Spaces: $tmpinst_len\n") if $debug;
	my ($i) = 0;
	my (@indent);
	for ($i = 0; $i < $tmpinst_len; $i++) {
		push(@indent, " ");
	}
	$indent_spaces = join("",@indent);
	$indent_spaces =~ s/  //;
	my $indentCparen = $indent_spaces;
	$indentCparen =~ s/ //;

	#------------------------------------------------------------------------------ 
        # Generate the Input portion of the Module Declarations:
	#------------------------------------------------------------------------------ 
	my (%allportsHoH) = %{ $verH{ 'modIO' } };
	my (@iolines) = ();
	my (@inlines) = ();
	my (@outlines) = ();
	my ($msb) = 0;
	my ($lsb) = 0;
	my ($templine) = "";
	# Push lines from the module declaration that match input, inout, or output into 
	# their respective arrays:
	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'port'} =~ m/(clk|clock)/) {
			$templine = "$indent_spaces input   wire           $allportsHoH{$key}{'port'},\n";
			push(@inlines, $templine);
			print("Clock: $templine\n") if $debug;
		}
	}

	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} eq "input") {
			if ($allportsHoH{$key}{'width'} > 1) {
				$msb = $allportsHoH{$key}{'width'};
				$msb -= 1;
				$templine = "$indent_spaces output  reg  [$msb:$lsb]    $allportsHoH{$key}{'port'},\n";
				push(@outlines, $templine);
				print("Input: $templine\n") if $debug;
			} elsif(($allportsHoH{$key}{'width'} == 1) and !($allportsHoH{$key}{'port'} =~ m/(clk|clock)/)) {
				$templine = "$indent_spaces output  reg            $allportsHoH{$key}{'port'},\n";
				push(@outlines, $templine);
				print("Input: $templine\n") if $debug;
			}
		} 
	}

	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} eq "inout") {
			if ($allportsHoH{$key}{'width'} > 1) {
				$msb = $allportsHoH{$key}{'width'};
				$msb -= 1;
				$templine = "$indent_spaces inout   wire [$msb:$lsb]    $allportsHoH{$key}{'port'},\n";
				push(@iolines, $templine);
				print("InOut: $templine\n") if $debug;
			} else {
				$templine = "$indent_spaces inout   wire           $allportsHoH{$key}{'port'},\n";
				push(@iolines, $templine);
				print("InOut: $templine\n") if $debug;
			}
		} 
	}

	for my $key ( sort(keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} eq "output") {
			if ($allportsHoH{$key}{'width'} > 1) {
				$msb = $allportsHoH{$key}{'width'};
				$msb -= 1;
				$templine = "$indent_spaces input   wire [$msb:$lsb]    $allportsHoH{$key}{'port'},\n";
				push(@inlines, $templine);
				print("Output: $templine\n") if $debug;
			} else {
				$templine = "$indent_spaces input   wire           $allportsHoH{$key}{'port'},\n";
				push(@inlines, $templine);
				print("Output: $templine\n") if $debug;
			}
		} 
	}

	my ($inDecl) = join("",@inlines);
	my ($ioDecl) = join("",@iolines);
	my ($outDecl) = join("",@outlines);
	$outDecl =~ s/,\n$//;

	print("\n\nInput Declarations: \n$inDecl") if $debug;
	print("InOut Declarations: \n$ioDecl") if $debug;
	print("Output Declarations: \n$outDecl\n") if $debug;

	#------------------------------------------------------------------------------ 
        # Build up Test Bench Module Body:
	#------------------------------------------------------------------------------ 
	my $tbTestBody=<<"EOF";
module    $test_modname        (//** Inputs **
$inDecl
$indent_spaces //** InOuts **
$ioDecl
$indent_spaces //** Outputs **
$outDecl
$indentCparen );

// *** Local Variable Declarations ***
// Local Parameter Declarations:
// N/A
// Local Wire Declarations:
// N/A
// Local Register Declarations:
// N/A

// *** Local Integer Declarations ***
integer		results_file;	// for writing signal values

// initial block
initial
begin
	// initialize signals
        \$display("Initialize Signals");
	rst_n <= 0;

        \$display("Wait for 100 ns");
        #100
        CpuReset;
	
        // open results file, write header
	results_file=\$fopen("../out/top_results.txt");
	\$fdisplay(results_file, " $test_modname testbench results");
	\$fwrite(results_file, "\\n");
	DisplayHeader;
	
	// Add more test bench stuff here
	
	\$fclose(results_file);
	\$stop;
end

// Add more test bench stuff here as well

// Test Bench Tasks
task DisplayHeader;
  \$fdisplay(results_file,"                       data_in	data_out	");
  \$fdisplay(results_file,"                 ====================================");
endtask    

task CpuReset;
begin
	\@ (posedge clk);
	rst_n = 0;
	\@ (posedge clk);
	rst_n = 1;
	\@ (posedge clk);
end
endtask

endmodule

EOF

	$verH{ 'tbmodName' } = $test_modname;
	$verH{ 'tbTestBody' } = $tbTestBody;
 
	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub genTBTestFile {
	#------------------------------------------------------------------------------ 
	# Generate the Verilog HDL Test Bench:
	#
	#  The sub-routine genTBTestFile() will generate a set of Test Bench
	#  files based on the Verilog HDL module provided by the user. For 
	#  example, if the user provides a Verilog HDL module called 'mymodule'
	#  then the following files will be generated:
	#      
	#      - top.v
	#      - test_mymodule.v
	#  
	#  The file 'top.v' instantiates both the UUT (mymodule.v) and the 
	#  Test Bench (test_mymodule.v). All nets labeled with either 'clk' or
	#  'clock' will be generated using an always block in the following form:
	#  
	#      // clk generators
	#      initial begin
	#        clk <= 1'b1;
	#      end
	#      
	#      // Generate clock:
	#      always #4 clk <= ~clk;
	#  
	#  All nets in the 'mymodule.v' file are declared in the top.v file.
	#  
	#  The file 'test_mymodule.v' contains the same number of i/o as 
	#  'mymodule.v' with inputs and outputs swapped, except for clock 
	#  signals.
	#
	#  Usage: $ver_rH = genTBTestFile(\%verH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	#------------------------------------------------------------------------------ 
	# Open $file and stuff it into an array.
	#------------------------------------------------------------------------------ 
	$ver_rH = getFile($ver_rH);

	#------------------------------------------------------------------------------ 
	# Search through $file for keywords.
	#------------------------------------------------------------------------------ 
	$ver_rH = parseFile($ver_rH);
	
	#------------------------------------------------------------------------------ 
	# Get Module Declaration:
	#------------------------------------------------------------------------------ 
	$ver_rH = getModDecl($ver_rH);
	
	#------------------------------------------------------------------------------ 
	# Get Module Name:
	#------------------------------------------------------------------------------ 
	$ver_rH = getModName($ver_rH);
	
	#------------------------------------------------------------------------------ 
	# Get Module I/O:
	#------------------------------------------------------------------------------ 
	$ver_rH = getModIO($ver_rH);

	#------------------------------------------------------------------------------ 
	# Generate Module Instantiation:
	#------------------------------------------------------------------------------ 
	$ver_rH = genModInst($ver_rH);

	#------------------------------------------------------------------------------ 
	# Generate Header and Body of Test Bench File
	#------------------------------------------------------------------------------ 
	$ver_rH = genTBTestHeader($ver_rH);
	$ver_rH = genTBTestBody($ver_rH);
	$ver_rH = genTBTop($ver_rH);
	%verH = %{ $ver_rH }; # De-reference Verilog hash.

	#------------------------------------------------------------------------------ 
	# Get Filename, Header and Body of UCF File
	#------------------------------------------------------------------------------ 
	my $tbTestFile = $verH{ 'tbTestFile' };
	my $tbTestHead  = $verH{ 'tbTestHead' };;
	my $tbTestBody  = $verH{ 'tbTestBody' };;
	my $tbTopFile = $verH{ 'tbTopFile' };
	my $tbTopBody  = $verH{ 'tbTopBody' };;


	#------------------------------------------------------------------------------ 
	# Create File Handle for the new UCF file, and check for existing file.
	#------------------------------------------------------------------------------
	open(outF, ">", $tbTestFile) or dienice ("$tbTestFile open failed");
	
	#------------------------------------------------------------------------------ 
	# Print Header and Body to UCF File Handle
	#------------------------------------------------------------------------------ 
	printf(outF "$tbTestHead");
	printf(outF "$tbTestBody");
	printf(outF "\n\n");

	close(outF);

	#------------------------------------------------------------------------------ 
	# Create File Handle for the new UCF file, and check for existing file.
	#------------------------------------------------------------------------------
	open(out2F, ">", $tbTopFile) or dienice ("$tbTopFile open failed");
	
	#------------------------------------------------------------------------------ 
	# Print Header and Body to UCF File Handle
	#------------------------------------------------------------------------------ 
	printf(out2F "$tbTopBody");
	printf(out2F "\n\n");

	close(out2F);
	
	print("\n");	
	print("Test Bench File(s): $tbTestFile and $tbTopFile are ready for use.\n");
	print("\n");	

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;
}

sub genUCFHeader {
	#------------------------------------------------------------------------------ 
	# Print UCF File Header:
	#
	#  The sub-routine printUCFHeader() will print out the UCF File Header. 
	#
	#  Usage: $ver_rH = printUCFHeader($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my $file_v = $verH{'file'};
	my $day = $verH{'day'};
	my $month = $verH{'month'};
	my $username = $verH{'username'};
	my $year = $verH{'year'};
	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	# Fix month, day, year:
	my $monthR = $month+1;
	my $yearR = $year+1900;

	# Get Filename:
	# strip .v from filename
	my $file = $file_v;
        $file =~ s/\x2ev//;
        $file =~ s/\x2e//g;
        $file =~ s/\x2f//g;
	my $ucf_file = join ".",$file,"ucf";

	my $ucfhead=<<"EOF";
#******************************************************************
#
# $ucf_file module
#
#******************************************************************
#
# COMPANY Confidential Copyright © $yearR
#
#******************************************************************
#
# created on:	$monthR/$day/$yearR 
# created by:	$username
# last edit on:	\$DateTime: \$ 
# last edit by:	\$Author: \$
# revision:\t\t\$Revision: \$
# comments:\t\t Generated
#
# board name:		<board name> Board
# board number:		pxxx
# board revision:	A
# device mpn:		XCxxxx-4FGG484C
# 
#******************************************************************

#--------------------------------------
# T I M I N G   C O N S T R A I N T S
#--------------------------------------
# N/A

#--------------------------------------
# I P  C O R E  C O N S T R A I N T S
#--------------------------------------
# N/A

#-------------------------------------------------
# P L A C E  &  R O U T E  C O N S T R A I N T S
#-------------------------------------------------
# N/A

#---------------------------------------------------
# T I M I N G   I G N O R E  C O N S T R A I N T S
#---------------------------------------------------
# N/A

EOF

	$verH{ 'ucffile' } = $ucf_file;
	$verH{ 'ucfhead' } = $ucfhead;

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}


sub genUCFBody {
	#------------------------------------------------------------------------------ 
	# Print UCF Body:
	#
	#  The sub-routine printUCFBody() will print out the body of the UCF File.
	#
	#  Usage: $ver_rH = printUCFBody($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.


	#------------------------------------------------------------------------------ 
        # Build up Test Bench Module Body:
	#------------------------------------------------------------------------------ 

	my $ucfbody=<<"EOF";
#--------------------------------------
# P I N   A S S I G N M E N T S      
#--------------------------------------

EOF
	my (%allportsHoH) = %{ $verH{ 'modIO' } };
	my ($msb) = 0;
	my ($i) = 0;
	# Push lines from the module declaration that match input, inout, or output into 
	# their respective arrays:
	for my $key ( sort (keys %allportsHoH) ) {
		if ($allportsHoH{$key}{'direction'} =~ m/input/) {
			if ($allportsHoH{$key}{'width'} > 1) {
				$msb = $allportsHoH{$key}{'width'};
				for ($i = 0; $i < $msb; $i++) {
					$ucfbody .= "NET \"$allportsHoH{$key}{'port'}\[$i\]\"\t\tLOC = \"\" | IOSTANDARD = LVCMOS33;\n";
				}
			} else {
				$ucfbody .= "NET \"$allportsHoH{$key}{'port'}\"\t\tLOC = \"\" | IOSTANDARD = LVCMOS33;\n";
			}
		} elsif ($allportsHoH{$key}{'direction'} =~ m/inout/) {
			if ($allportsHoH{$key}{'width'} > 1) {
				$msb = $allportsHoH{$key}{'width'};
				for ($i = 0; $i < $msb; $i++) {
					$ucfbody .= "NET \"$allportsHoH{$key}{'port'}\[$i\]\"\t\tLOC = \"\" | IOSTANDARD = LVCMOS33;\n";
				}
			} else {
				$ucfbody .= "NET \"$allportsHoH{$key}{'port'}\"\t\tLOC = \"\" | IOSTANDARD = LVCMOS33;\n";
			}
		} elsif ($allportsHoH{$key}{'direction'} =~ m/output/) {
			if ($allportsHoH{$key}{'width'} > 1) {
				$msb = $allportsHoH{$key}{'width'};
				for ($i = 0; $i < $msb; $i++) {
					$ucfbody .= "NET \"$allportsHoH{$key}{'port'}\[$i\]\"\t\tLOC = \"\" | IOSTANDARD = LVCMOS33;\n";
				}
			} else {
				$ucfbody .= "NET \"$allportsHoH{$key}{'port'}\"\t\tLOC = \"\" | IOSTANDARD = LVCMOS33;\n";
			}
		}
	}

	$verH{ 'ucfbody' } = $ucfbody;
 
	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub genUCFFile {
	#------------------------------------------------------------------------------ 
	# Generate Xilinx UCF File:
	#
	#  The sub-routine genUCFFile() will generate a Xilinx User Constraints File (UCF)
	#  based on the Verilog HDL module provided by the user. For 
	#  example, if the user provides a Verilog HDL module called 'mymodule'
	#  then the following files will be generated:
	#  
	#      - mymodule.ucf
	#  
	#  The file 'mymodule.ucf' inserts net location and IO Standard declarations 
	#  for all I/O in 'mymodule.v'. The location keyword 'LOC' defaults to empty, 
	#  and the 'IOSTANDARD' defaults to 'LVCMOS33'.
	#
	#  Usage: $ver_rH = genUCFFile(\%verH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	#------------------------------------------------------------------------------ 
	# Open $file and stuff it into an array.
	#------------------------------------------------------------------------------ 
	$ver_rH = getFile($ver_rH);

	#------------------------------------------------------------------------------ 
	# Search through $file for keywords.
	#------------------------------------------------------------------------------ 
	$ver_rH = parseFile($ver_rH);
	
	#------------------------------------------------------------------------------ 
	# Get Module Declaration:
	#------------------------------------------------------------------------------ 
	$ver_rH = getModDecl($ver_rH);
	
	#------------------------------------------------------------------------------ 
	# Get Module Name:
	#------------------------------------------------------------------------------ 
	$ver_rH = getModName($ver_rH);
	
	#------------------------------------------------------------------------------ 
	# Get Module I/O:
	#------------------------------------------------------------------------------ 
	$ver_rH = getModIO($ver_rH);

	#------------------------------------------------------------------------------ 
	# Generate Header and Body of UCF File
	#------------------------------------------------------------------------------ 
	$ver_rH = genUCFHeader($ver_rH);
	$ver_rH = genUCFBody($ver_rH);
	%verH = %{ $ver_rH }; # De-reference Verilog hash.

	#------------------------------------------------------------------------------ 
	# Get Filename, Header and Body of UCF File
	#------------------------------------------------------------------------------ 
	my $ucf_file = $verH{ 'ucffile' };
	my $ucfhead  = $verH{ 'ucfhead' };;
	my $ucfbody  = $verH{ 'ucfbody' };;


	#------------------------------------------------------------------------------ 
	# Create File Handle for the new UCF file, and check for existing file.
	#------------------------------------------------------------------------------
	open(outF, ">", $ucf_file) or dienice ("$ucf_file open failed");
	
	#------------------------------------------------------------------------------ 
	# Print Header and Body to UCF File Handle
	#------------------------------------------------------------------------------ 
	printf(outF "$ucfhead");
	printf(outF "$ucfbody");
	printf(outF "\n\n");

	close(outF);
	
	print("\n");	
	print("UCF File: $ucf_file is ready for use.\n");
	print("\n");	

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;
}

sub genVerLowModule {
	#------------------------------------------------------------------------------ 
	# Generate Verilog Lower Module File:
	#
	#  The sub-routine genVerLowModule() will generate an empty lower-level 
	#  Verilog HDL module. A standard header is used containing an empty description 
	#  and the new module name. The module contains 3 input signals: clk, rst_n, 
	#  and data_in[15:0]. The module also contains 1 output signal: data_out[15:0].
	#
	#  Usage: $ver_rH = genVerLowModule($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my $file_v = $verH{'file'};
	my $day = $verH{'day'};
	my $month = $verH{'month'};
	my $username = $verH{'username'};
	my $year = $verH{'year'};
	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	# Fix month, day, year:
	my $monthR = $month+1;
	my $yearR = $year+1900;

	# Get Filename:
	# strip .v from filename
	my $modname = $file_v;
        $modname =~ s/\x2ev//;
        $modname =~ s/\x2e//g;
        $modname =~ s/\x2f//g;
	
	#----------------------------------------------------------------------
	# Determine number of indent spaces:
	#
	#	* Tab Space = 8
	#	* Create string with correct numer of indent spaces.
	#
	#----------------------------------------------------------------------
	my ($indent_spaces) = "";
	my ($modinst_line1) = "module    $modname        (/";
	my ($tmpinst_len) = length($modinst_line1);
	print("Number of Indent Spaces: $tmpinst_len\n") if $debug;
	my ($i) = 0;
	my (@indent);
	for ($i = 0; $i < $tmpinst_len; $i++) {
		push(@indent, " ");
	}
	$indent_spaces = join("",@indent);
	$indent_spaces =~ s/  //;
	my $indentCparen = $indent_spaces;
	$indentCparen =~ s/ //;


	my $verLowHead=<<"HEAD";
/*****************************************************************

 $file_v module

******************************************************************

 COMPANY Confidential Copyright © $yearR

******************************************************************

 created on:	$monthR/$day/$yearR 
 created by:	$username
 last edit on:	\$DateTime: \$ 
 last edit by:	\$Author: \$
 revision:\t\t\$Revision: \$
 comments:\t\t Generated

******************************************************************
 //Project// (//Number//)

 This module implements the ... in the //name// fpga.

	// enter detailed description here;


******************************************************************/
`timescale        1ns/1ps

module    $modname        (// *** Inputs ***
HEAD

	$verLowHead .= "$indent_spaces input	wire	     	clk,		// System Clock (xxx MHz)\n";
	$verLowHead .= "$indent_spaces input	wire	     	rst_n,		// System Reset (Active Low)\n";
	$verLowHead .= "$indent_spaces input	wire	[15:0]	data_in,	// Data In.\n";
	$verLowHead .= "\n";
	$verLowHead .= "$indent_spaces // *** Outputs ***\n";
	$verLowHead .= "$indent_spaces output	wire	[15:0]	data_out	// Data Out.\n";
	$verLowHead .= "$indentCparen );\n";
	$verLowHead .= "\n";
	$verLowHead .= "\n";
	$verLowHead .= "// *** Local Variable Declarations ***\n";
	$verLowHead .= "// Local Parameter Declarations:\n";
	$verLowHead .= "// N/A\n";
	$verLowHead .= "// Local Wire Declarations:\n";
	$verLowHead .= "// N/A\n";
	$verLowHead .= "// Local Register Declarations:\n";
	$verLowHead .= "// N/A\n";
	$verLowHead .= "\n";
	$verLowHead .= "endmodule\n";


	$verH{ 'verLowHead' } = $verLowHead;

	#------------------------------------------------------------------------------ 
	# Create File Handle for the new Verilog HDL file, and check for existing file.
	#------------------------------------------------------------------------------
	if (-e $file_v) {
		print("Oops! A file called '$file_v' already exists.\n");
		exit 1;
	} else {
		open(outF, ">", $file_v);
	
		#----------------------------------------------------------------------
		# Print Header and Body to UCF File Handle
		#----------------------------------------------------------------------
		printf(outF "$verLowHead");
		printf(outF "\n\n");

		close(outF);
	
		print("\nNew Verilog HDL File: $file_v is ready for use.\n\n");
	}

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}

sub genVerTopModule {
	#------------------------------------------------------------------------------ 
	# Generate Verilog Top-Level Module File:
	#
	#  The sub-routine genVerTopModule() will generate an empty top-level 
	#  Verilog HDL module. A standard header is used containing an empty description 
	#  and the new module name. The module contains 3 input signals: clk, rst_n, 
	#  and data_in[15:0]. The module also contains 1 output signal: data_out[15:0].
	#
	#  Usage: $ver_rH = genVerTopModule($ver_rH);
	#
	#------------------------------------------------------------------------------ 
	my ($ver_rH) = shift;	    # Read in user's variable.

	my (%verH) = %{ $ver_rH }; # De-reference Verilog hash.

	my $file_v = $verH{'file'};
	my $day = $verH{'day'};
	my $month = $verH{'month'};
	my $username = $verH{'username'};
	my $year = $verH{'year'};
	my ($debug) = $verH{'debug'};   # Print out Debug Info.

	# Fix month, day, year:
	my $monthR = $month+1;
	my $yearR = $year+1900;

	# Get Filename:
	# strip .v from filename
	my $modname = $file_v;
        $modname =~ s/\x2ev//;
        $modname =~ s/\x2e//g;
        $modname =~ s/\x2f//g;
	
	#----------------------------------------------------------------------
	# Determine number of indent spaces:
	#
	#	* Tab Space = 8
	#	* Create string with correct numer of indent spaces.
	#
	#----------------------------------------------------------------------
	my ($indent_spaces) = "";
	my ($modinst_line1) = "module    $modname        (/";
	my ($tmpinst_len) = length($modinst_line1);
	print("Number of Indent Spaces: $tmpinst_len\n") if $debug;
	my ($i) = 0;
	my (@indent);
	for ($i = 0; $i < $tmpinst_len; $i++) {
		push(@indent, " ");
	}
	$indent_spaces = join("",@indent);
	$indent_spaces =~ s/  //;
	my $indentCparen = $indent_spaces;
	$indentCparen =~ s/ //;

	my $verTopHead=<<"HEAD";
/*****************************************************************

 $file_v module

******************************************************************

 COMPANY Confidential Copyright © $yearR

******************************************************************

 created on:	$monthR/$day/$yearR 
 created by:	$username
 last edit on:	\$DateTime: \$ 
 last edit by:	\$Author: \$
 revision:\t\t\$Revision: \$
 comments:\t\t Generated

 board name:		//Name// Board
 board number:		pxxx
 board revision:	A
 device mpn:		XCxxxx-4FG676C
 
******************************************************************
 //Project// (//Number//)

 This module is the top level for the $modname FPGA
 on the ... board for the //Project//.

 This design performs the following functions:

	// enter functions here;

 The sub-modules included in this design are:

	// enter sub-modules here;

 The physical constraints file for the ... FPGA is in the 
 file:

	$modname.ucf

******************************************************************/
`timescale        1ns/1ps

module    $modname        (// *** Inputs ***
HEAD

	$verTopHead .= "$indent_spaces input	wire	     	clk,		// System Clock (xxx MHz)\n";
	$verTopHead .= "$indent_spaces input	wire	     	rst_n,		// System Reset (Active Low)\n";
	$verTopHead .= "$indent_spaces input	wire	[15:0]	data_in,	// Data In.\n";
	$verTopHead .= "\n";
	$verTopHead .= "$indent_spaces // *** Outputs ***\n";
	$verTopHead .= "$indent_spaces output	wire	[15:0]	data_out	// Data Out.\n";
	$verTopHead .= "$indentCparen );\n";
	$verTopHead .= "\n";
	$verTopHead .= "\n";
	$verTopHead .= "// *** Local Variable Declarations ***\n";
	$verTopHead .= "// Local Parameter Declarations:\n";
	$verTopHead .= "// N/A\n";
	$verTopHead .= "// Local Wire Declarations:\n";
	$verTopHead .= "// N/A\n";
	$verTopHead .= "// Local Register Declarations:\n";
	$verTopHead .= "// N/A\n";
	$verTopHead .= "\n";
	$verTopHead .= "endmodule\n";


	$verH{ 'verTopHead' } = $verTopHead;

	#------------------------------------------------------------------------------ 
	# Create File Handle for the new Verilog HDL file, and check for existing file.
	#------------------------------------------------------------------------------
	if (-e $file_v) {
		print("Oops! A file called '$file_v' already exists.\n");
		exit 1;
	} else {
		open(outF, ">", $file_v);
	
		#----------------------------------------------------------------------
		# Print Header and Body to UCF File Handle
		#----------------------------------------------------------------------
		printf(outF "$verTopHead");
		printf(outF "\n\n");

		close(outF);
	
		print("\nNew Verilog HDL File: $file_v is ready for use.\n\n");
	}

	#------------------------------------------------------------------------------ 
        #
        # Return data to user
        #
	#------------------------------------------------------------------------------ 
        return \%verH;

}



=pod

=head1 NAME

VerilogTools - Package to parse and create Verilog HDL files

=head1 VERSION

Version 1.0

=head1 SYNOPSIS

    use VerilogTools;

    #******************************************************************
    # Initialize Verilog Hash:
    #******************************************************************
    my (%verH, $ver_rH);
    $verH{ 'username' } = $author;
    $verH{ 'file' } = $file;
    $verH{ 'day' } = $day;
    $verH{ 'month' } = $month;
    $verH{ 'year' } = $year;
    $verH{ 'debug' } = $debug;

    # Generate Top-Level Module
    $ver_rH = genVerTopModule(\%verH);

    # Generate Low-Level Module
    $ver_rH = genVerLowModule(\%verH);

    # Generate Module Instantiateion
    $ver_rH = printModInst(\%verH);

    # Generate UCF File from Module
    $ver_rH = genUCFFile(\%verH);

    # Generate Test Benches
    $ver_rH = genTBTestFile(\%verH);

=head1 DESCRIPTION

The VerilogTools is used to generate or parse Verilog HDL files.

=head2 printModInst:

The sub-routine printModInst() will print out the Verilog HDL module 
instantiation. The Verilog HDL module must use an ANSI-C style module
declaration. An example module instantiation is shown below:

    mymodule        _mymodule  (.clk (clk),
				.data_in (data_in),
                                .rst_n (rst_n),

                                .data_out (data_out));

=head2 genTBTestFile:

The sub-routine genTBTestFile() will generate a set of Test Bench
files based on the Verilog HDL module provided by the user. For 
example, if the user provides a Verilog HDL module called 'mymodule'
then the following files will be generated:
    
    - top.v
    - test_mymodule.v

The file 'top.v' instantiates both the UUT (mymodule.v) and the 
Test Bench (test_mymodule.v). All nets labeled with either 'clk' or
'clock' will be generated using an always block in the following form:

    // clk generators
    initial begin
      clk <= 1'b1;
    end
    
    // Generate clock:
    always #4 clk <= ~clk;

All nets in the 'mymodule.v' file are declared in the top.v file.

The file 'test_mymodule.v' contains the same number of i/o as 
'mymodule.v' with inputs and outputs swapped, except for clock 
signals.

=head2 genUCFFile:

The sub-routine genUCFFile() will generate a Xilinx User Constraints File (UCF)
based on the Verilog HDL module provided by the user. For 
example, if the user provides a Verilog HDL module called 'mymodule'
then the following files will be generated:

    - mymodule.ucf

The file 'mymodule.ucf' inserts net location and IO Standard declarations 
for all I/O in 'mymodule.v'. The location keyword 'LOC' defaults to empty, 
and the 'IOSTANDARD' defaults to 'LVCMOS33'.

=head2 genVerLowModule:

The sub-routine genVerLowModule() will generate an empty lower-level Verilog HDL 
module. A standard header is used containing an empty description and the 
new module name. The module contains 3 input signals: clk, rst_n, and data_in[15:0].
The module also contains 1 output signal: data_out[15:0].

=head2 genVerTopModule:

The sub-routine genVerTopModule() will generate an empty top-level Verilog HDL 
module. A standard header is used containing an empty description and the 
new module name. The module contains 3 input signals: clk, rst_n, and data_in[15:0].
The module also contains 1 output signal: data_out[15:0].

=head2 EXPORT
 
None at the moment.

=head1 INSTALLATION

   perl Makefile.PL  # build the Makefile
   make              # build the package
   make install      # Install package

=head1 SEE ALSO

Example scripts can be accessed at the following website:

    * http://www.ece.ucdavis.edu/~jwwebb/ee/howto/using_perl_with_verilog.html

=head1 AUTHOR

Jeremy Webb, E<lt>jwwebb@ece.ucdavis.edu<gt>

=head1 BUGS

Please report any bugs or feature requests to the author.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Jeremy Webb

=cut
