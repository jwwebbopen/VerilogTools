#!/usr/bin/env perl

#******************************************************************
# vim:ts=8:sw=8:expandtab:cindent
#******************************************************************
#
# ver_inst.pl module
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
# Verilog HDL Tools Module
#
#  This utility is intended to make instantiation in verilog 
#  easier using a good editor, such as VI.
#
#  As long as you set the top line to correctly point to your 
#  perl binary, and place this script in a directory in your 
#  path, you can invoke it from VI. Simply use the !! command 
#  and call this script with the filename you wish to instantiate.  
#  
#  	!! ver_inst.pl -i -f adder.v
#  	
#  The script will retrieve the module definition from the file 
#  you specify and provide the instantiation for you in the 
#  current file at the cursor position.
#
#  The Verilog HDL module must use an ANSI-C style module 
#  declaration. For instance, if adder.v contains the following 
#  definition:
#
#  	module adder (// *** Inputs ***
#		      input	wire		a, 
#		      input	wire		b, 
#
#		      // *** Outputs ***
#		      output	wire		sum, 
#		      output	wire		carry
#		     );
#
#  Then this is what the script will insert in your editor 
#  for you:
#
#  	adder adder (.a (a),
#  		     .b (b),
#  		     .sum (sum),
#  		     .carry (carry));
#
#  The keyword "module" must be left justified in the verilog file
#  you are instantiating to work.
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

#******************************************************************
# CPAN Modules
#******************************************************************
use strict;
use warnings;
use Getopt::Std;

#******************************************************************
# Custom Modules
#******************************************************************
use VerilogTools qw( printModInst );

#******************************************************************
# Constants and Variables:
#******************************************************************
my (%verH, $ver_rH);
my (%opts)=();
my ($file);
my ($debug);

#******************************************************************
# Retrieve command line argument
#******************************************************************
getopts('hvif:',\%opts);

my $optslen = scalar( keys %opts );
print("Number of Options on Command-Line: $optslen\n") if $opts{v};
# check for valid combination of command-line arguments
if ( $opts{h} || !$opts{f} || !($opts{i}) || ($optslen eq "0") ) {
    print_usage();
    exit;
}

# parse command-line arguments
$file  = $opts{f};
$debug = $opts{v};

#******************************************************************
# Make Date int MM/DD/YYYY
#******************************************************************
my $year      = 0;
my $month     = 0;
my $day       = 0;
($day, $month, $year) = (localtime)[3,4,5];

#******************************************************************
# Grab username from PC:
#******************************************************************
my $author= "$^O user";
if ($^O =~ /mswin/i) { 
    $author= $ENV{USERNAME} if defined $ENV{USERNAME};
} else { 
    $author = getlogin();
}

#******************************************************************
# Initialize Verilog Hash:
#******************************************************************
$verH{ 'username' } = $author;
$verH{ 'file' } = $file;
$verH{ 'day' } = $day;
$verH{ 'month' } = $month;
$verH{ 'year' } = $year;
$verH{ 'debug' } = $debug;

#******************************************************************
# Print Module Declaration:
#******************************************************************
if ($opts{i}) {
    $ver_rH = printModInst(\%verH);
    print("\n\n");
}

exit;
 
#******************************************************************
# Generic Error and Exit routine 
#******************************************************************
 
sub dienice {
    my($errmsg) = @_;
    print"$errmsg\n";
    exit;
}

sub print_usage {
    my ($usage);
    $usage = "\nUsage: $0 [-h] [-v] [-i] [-f <FILE>]\n";
    $usage .= "\n";
    $usage .= "\t-h\t\tPrint this help message.\n";
    $usage .= "\t-v\t\tVerbose: Print Debug Information.\n";
    $usage .= "\t-i\t\tGenerate Verilog HDL Instantiation.\n";
    $usage .= "\t-f <FILE>\tVerilog HDL input file.\n";
    $usage .= "\n";
    $usage .= "\tExample of Module Instantiation:\n";
    $usage .= "\t\t$0 -i -f sample.v \n";
    $usage .= "\n";
    print($usage);
    return;
}

