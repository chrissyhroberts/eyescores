#!/usr/bin/env perl

#need to add visual acuity options
#need to amend the review list to include all options and to make it omittable

#Date/time (automatic stamp if possible?)
#Cluster number 
#Age
#Trachoma Survey ID
#Disease classification in left eye (1=healthy, 2=TF, 3=TI, 4=TS, 5=TT, 6=CO, 7=other ocular trauma or disease [exclude])
#Photo ID
#Sample ID

########################################################################################################
##################                                                               #######################
##################                           EYESCORES                           #######################
##################                          v.4.00 BETA                          #######################
##################          									                 #######################
########################################################################################################
########################################################################################################
########################################################################################################
##################                                                               #######################
################## Eyescores is a tool for collecting samples for use in         #######################
################## ophthalmological studies. See the readme file for more details#######################
################## use perl 5.14.1 or above                                      #######################
##################                                                               #######################
##################  requires subroutine paths to eyefi card folder to be set     #######################
##################                                                               #######################
##################  Dependencies                                                 #######################
##################            Software :    PDFTK       ImageMagick              #######################
##################                                                               #######################
##################  Perl Modules                                                 #######################
##################            perl/Tk      Tk::Photo    Tk::JPEG                 #######################
##################            Tk::Pane     PDF::API2    GPS::Garmin              #######################
##################            Crypt::OpenSSL::RSA       MIME::Base64             #######################
##################                                                               #######################
##################  Garmin device should be in host mode                         #######################
##################                                                               #######################
########################################################################################################
########################################################################################################
#    Eyescores : A generalised tool for data and sample collection in studies of the eye
#    Copyright (C) 2012 Chrissy h. Roberts. London School of Hygiene and Tropical Medicine
#
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#   Contact : 
#               Chrissy h. Roberts. 
#				chrissyhroberts@yahoo.co.uk
#				Clinical Research Department, London School of Hygiene, Keppel St. London WC1E 7HT
#
########################################################################################################
#####################################          DEFINE MODULES         ##################################
########################################################################################################
# Change log.
#	v.4.00 : 	
#				amended on the fly encryption to cover names and village only
#				added on the fly encryption to personal data, requires different pem key for encode and decode.
#				totally secure encryption from all but the most keen eyes
#
#				Fixed a bug where the data file got right eye fornix number twice (i.e. also in left eye fornix field)
#				Added automatic backup to pen drive or usb drive of pdf, flatfile and database
#				Added optional righteye and lefteye swabs
#
#
########################################################################################################
#use warnings; 					#can be useful for debugging but normally hash out.
#use strict;
use POSIX "strftime";	#gets epoch time for use in assigning date and time stamps
#use GPS::Garmin;		#not implemented yet.
use PDF::API2;			#for generating PDF files
use Tk;					#Perl toolkit, provides GUI elements for picview and grading tool
use Tk::JPEG;			#Allows Perl toolkit to work with JPEG images
use Tk::Pane;			#Allows perl toolkit to use panes/frames when displaying 
use Cwd;				#Gets current working directory
use File::Copy;			#Allows perl based copy function to circumvent system calls
use Crypt::OpenSSL::RSA;	#For encryption, open SSL framework, requires an SSL pair to be generated
use MIME::Base64;		#support for SSL module
########################################################################################################
########################################################################################################
#####################################      DEFINE path for backup drive    #############################
########################################################################################################

my $backuppath = "E:/edc_backups/"; #Hash out if using a MAC
#my $backuppath = "/Volumes/EDC_BACKUPS/edc_backups/"; #Hash out if using a PC



########################################################################################################
########################################################################################################
########################################################################################################
#####################################      DEFINE Global variables    ##################################
########################################################################################################

our (	

		%output_count,%output_value,%output_encrypt,$countofvariables,@listofphotosbig,@listofphotossmall

	);


########################################################################################################
########################################################################################################
#######################################         INITIAL STATUS         #################################
########################################################################################################

my $countrycode = "ET-"; #base country codes on ISO 3166-1 alpha-2 code
my $dir = getcwd(); 										#Gets current working directory from shell #
$countofvariables = 1000;

##########################################################################################################
######################################    Encryption     #################################################
########################################################################################################

my $public_key = "$dir/ENCRYPTION_KEY/public.pem";
#sets path to public.pem, the encryption key (Open SSL)




########################################################################################################
##########		If using standalone EYEFI server (bundled with eyescores)
########################################################################################################
########################################################################################################
#Order to initialise eyefi server should be de-hashed if you wish to use the standalone eyefi server (not recommended)
#system("open -a terminal"); 
#system ("python $dir/eyefiserver/EyeFiServer.py -c DefaultSettings.ini &");
#system("open -a terminal"); 
########################################################################################################

&topmenu;                                                                # Runs the topmenu at startup #

sub topmenu {
			#PRINT THE FRONT PAGE
			system ("clear");
			system ("cls");

#			print "GPS : $gpsconnected\n";
			print"
###################################################
########               EYESCORES             ######
######## ophthalmological Sample Collection  ######
########                v.4.00   beta        ######
###################################################
#                                                 #
#  Copyright (C) 2012 Chrissy h. Roberts          #
#  This program comes with ABSOLUTELY NO WARRANTY # 
#                                                 #
#  This is free software, and you are welcome to  #
#  redistribute it under certain conditions;      #
#  see license.txt for more details               #
###################################################
";
sleep 2;
system ("clear");
			system ("cls");

			print "GPS : $gpsconnected\n";
			print"
###################################################
########               EYESCORES             ######
######## ophthalmological Sample Collection  ######
########                v.4.00  beta         ######
###################################################
###################################################
# Please Choose one of the following              #
#                                                 #
# 1)	Collect a new sample                      #
# 2)	Fill out an error monitoring form         #
# q)	Quit                                      #
###################################################

Option :  ";
			
			
			#Get A choice from the menu;
			$topmenuchoice = 0;
			while ($topmenuchoice !~ /^[1-2|q]$/i){
												chomp ($topmenuchoice = <STDIN>);
												if ($topmenuchoice !~ /^[1-2|q]$/i){print "Try again :  "};
												};
			if ($topmenuchoice =~ /^1$/){&option1};
			if ($topmenuchoice =~ /^2$/){&option2};
			if ($topmenuchoice =~ /^q$/){&optionq};

			}
########################################################################################################
########################################################################################################
########################################################################################################
########################################################################################################
########################################################################################################
#####################################       OPTION 1 : New SAMPLE      #################################
########################################################################################################
# This section defines the data that will be collected for each sample                                 # 
# With care you can reorder the things that happen, but do take care							       #
# Encrypt with tag "E", remove encryption "e"													       #																				       #
########################################################################################################

sub option1 	{

######### initial data, record id, 


&printheader;	
print"\n\nGetting basic data\n\n";
print "Event is : ";
&getidfromdate;
print "\n\n";



&printheader;




#consentform

{
&printheader;
}

&selector("e","timepoint","What time point is this?","PREOP","PERIOP","6_MONTHS_POSTOP","12_MONTHS_POSTOP");
print $output_value{"timepoint"};

&doubleentry("e","Individual_Number","Indvidual Number (BP-0000 to BP-1000)?  :  ","Re-enter Indvidual Number (BP-0000 to BP-1000)?  :  ",'^((BP-)[0-9][0-9][0-9][0-9])$') ;

#photo_block full face
{
&doubleentry("e","full_face_photograph","\n FACE: Now take a photo of the full face\nWhat is the frame number DSC_ (xxxx)\n\n:  ","\n Re-enter the frame number DSC_ (xxxx)\n\n:  ",'^(\d{4})$');
$output_value{"full_face_photograph"} = "DSC_".$output_value{"full_face_photograph"}.".JPG";
$output_value{"full_face_photograph"} = &photorenameandmove($id,"FACE",$output_value{"full_face_photograph"},$output_value{"timepoint"},$output_value{"Individual_Number"});
&appendtophoto($output_value{"full_face_photograph"},$id,$output_value{"Individual_Number"},$output_value{"timepoint"},"FACE");
}

#photo_block TT
{
&doubleentry("e","TT_photograph_right","\n TT: Now take a photo of the RIGHT EYE TT\nWhat is the frame number DSC_ (xxxx)\n\n:  ","\n Re-enter the frame number DSC_ (xxxx)\n\n:  ",'^(\d{4})$');
$output_value{"TT_photograph_right"} = "DSC_".$output_value{"TT_photograph_right"}.".JPG";
$output_value{"TT_photograph_right"} = &photorenameandmove($id,"RIGHT_TT",$output_value{"TT_photograph_right"},$output_value{"timepoint"},$output_value{"Individual_Number"});
&appendtophoto($output_value{"TT_photograph_right"},$id,$output_value{"Individual_Number"},$output_value{"timepoint"},"RIGHT_TT");
}

#photo_block cornea
{
&doubleentry("e","Cornea_photograph_right","\n CORNEA: Now take a photo of the RIGHT EYE  cornea\nWhat is the frame number DSC_ (xxxx)\n\n:  ","\n Re-enter the frame number DSC_ (xxxx)\n\n:  ",'^(\d{4})$');
$output_value{"Cornea_photograph_right"} = "DSC_".$output_value{"Cornea_photograph_right"}.".JPG";
$output_value{"Cornea_photograph_right"} = &photorenameandmove($id,"RIGHT_CORNEA",$output_value{"Cornea_photograph_right"},$output_value{"timepoint"},$output_value{"Individual_Number"});
&appendtophoto($output_value{"Cornea_photograph_right"},$id,$output_value{"Individual_Number"},$output_value{"timepoint"},"RIGHT_CORNEA");
}

#photo_block tarsus
{
&doubleentry("e","Tarsus_photograph_right","\n TARSUS: Now take a photo of the RIGHT EYE  tarsus\nWhat is the frame number DSC_ (xxxx)\n\n:  ","\n Re-enter the frame number DSC_ (xxxx)\n\n:  ",'^(\d{4})$');
$output_value{"Tarsus_photograph_right"} = "DSC_".$output_value{"Tarsus_photograph_right"}.".JPG";
$output_value{"Tarsus_photograph_right"} = &photorenameandmove($id,"RIGHT_TARSUS",$output_value{"Tarsus_photograph_right"},$output_value{"timepoint"},$output_value{"Individual_Number"});
&appendtophoto($output_value{"Tarsus_photograph_right"},$id,$output_value{"Individual_Number"},$output_value{"timepoint"},"RIGHT_TARSUS");
}


#photo_block TT
{
&doubleentry("e","TT_photograph_left","\n TT: Now take a photo of the LEFT EYE TT\nWhat is the frame number DSC_ (xxxx)\n\n:  ","\n Re-enter the frame number DSC_ (xxxx)\n\n:  ",'^(\d{4})$');
$output_value{"TT_photograph_left"} = "DSC_".$output_value{"TT_photograph_left"}.".JPG";
$output_value{"TT_photograph_left"} = &photorenameandmove($id,"LEFT_TT",$output_value{"TT_photograph_left"},$output_value{"timepoint"},$output_value{"Individual_Number"});
&appendtophoto($output_value{"TT_photograph_left"},$id,$output_value{"Individual_Number"},$output_value{"timepoint"},"LEFT_TT");
}

#photo_block cornea
{
&doubleentry("e","Cornea_photograph_left","\n CORNEA: Now take a photo of the LEFT EYE cornea\nWhat is the frame number DSC_ (xxxx)\n\n:  ","\n Re-enter the frame number DSC_ (xxxx)\n\n:  ",'^(\d{4})$');
$output_value{"Cornea_photograph_left"} = "DSC_".$output_value{"Cornea_photograph_left"}.".JPG";
$output_value{"Cornea_photograph_left"} = &photorenameandmove($id,"LEFT_CORNEA",$output_value{"Cornea_photograph_left"},$output_value{"timepoint"},$output_value{"Individual_Number"});
&appendtophoto($output_value{"Cornea_photograph_left"},$id,$output_value{"Individual_Number"},$output_value{"timepoint"},"LEFT_CORNEA");
}

#photo_block tarsus
{
&doubleentry("e","Tarsus_photograph_left","\n TARSUS: Now take a photo of the LEFT EYE tarsus\nWhat is the frame number DSC_ (xxxx)\n\n:  ","\n Re-enter the frame number DSC_ (xxxx)\n\n:  ",'^(\d{4})$');
$output_value{"Tarsus_photograph_left"} = "DSC_".$output_value{"Tarsus_photograph_left"}.".JPG";
$output_value{"Tarsus_photograph_left"} = &photorenameandmove($id,"LEFT_TARSUS",$output_value{"Tarsus_photograph_left"},$output_value{"timepoint"},$output_value{"Individual_Number"});
&appendtophoto($output_value{"Tarsus_photograph_left"},$id,$output_value{"Individual_Number"},$output_value{"timepoint"},"LEFT_TARSUS");
}

&reviewdata;		

}










########################################################################################################
########################################################################################################
sub reviewdata {
system ("clear");
system ("cls");


print "###############################################################################\n";
print "#####  To amend data (cannot be undone) enter variable number (i.e. 1001) #####\n";
print "#####                To commit data (cannot be undone) press X            #####\n";
print "###############################################################################\n";

my %reverse = reverse %output_count;

foreach my $value (sort {$output_count{$a} cmp $output_count{$b} }
           keys %output_count)
{print "$output_count{$value}\t$value :\t$output_value{$value}\n"}


print "Do you want to commit this data? (Y/N) : ";
my $doyouwanttocommit = ".";
my $reviewoption = ".";

until($doyouwanttocommit =~ /^(Y|N)$/i){chomp ($doyouwanttocommit = <STDIN>)};

if ($doyouwanttocommit =~ /Y/i){ 
								&commit;
								exit;
								}

if ($doyouwanttocommit =~ /N/i){ 
								print "\n\nEnter the variable number of the field you wish to edit : ";
								until($reviewoption ~~ [values %output_count]){chomp ($reviewoption = <STDIN>)};
								print "\n\n\nYou wish to edit the variable $reverse{$reviewoption}\n";
								print "\n\n\nProceed with extreme caution\n";
								&getfreetextnoextras("e",$reverse{$reviewoption},"\nPlease enter the edited data : ");
								&reviewdata;
								}
				}



########################################################################################################
########################################################################################################
sub commit	{


print "\nAre you sure you want to commit data - Cannot be undone (Y/N)? :  ";
my $commityn = ".";
until($commityn =~ /^(Y|N|NO|YES)$/i){chomp ($commityn = <STDIN>)};
if ($commityn =~ /^(N|No)$/i)	{&reviewdata}
if ($commityn =~ /^(Y|Yes)$/i)	

{
print "Big photos : @listofphotosbig\n";
print "Small photos : @listofphotossmall\n";

#encrypt data
foreach my $value (sort {$output_count{$a} cmp $output_count{$b} }
           keys %output_count)
{

if ($output_encrypt{$value} =~ /E/){$output_value{$value} = &encryptPublic ($public_key,$output_value{$value})};

}

########################################################################################################
# OUTPUT
# PRINTS OUT A Single line output to the master data file 													
#OPEN OUTPUT FILE FOR DATABASE FLATFILE
open OUTPUT, ">>$dir/DATA/data.txt" or die $!;
select OUTPUT;
																

# Use Hash (#) to remove unused variables from report. Refer to option one selections.	
# BUT actually, just leave this alone, you don't need to mess with it and it will only cause problems.

print "\n$id";

foreach my $value (sort {$output_count{$a} cmp $output_count{$b} }
           keys %output_count)
{print "\t$output_value{$value}"}


close OUTPUT;

#backup

copy ("$dir/DATA/data.txt", "$backuppath/$id.data.txt");

########################################################################################################
# OUTPUT
# OPEN OUTPUT FILE FOR single record FLATFILE
########################################################################################################
open FLATFILE, ">>$dir/DATA/FLATFILES/$id.txt" or die $!;
select FLATFILE;
print "\n$id";
															
#PRINTS OUT A FLATFILE FOR THE SAMPLE - Will omit optional modules that aren't selected.

foreach my $value (sort {$output_count{$a} cmp $output_count{$b} }
           keys %output_count)
{print "\n$value :\t$output_value{$value}"}


close FLATFILE;
#backup flatfile
copy ("$dir/DATA/FLATFILES/$id.txt", "$backuppath/$id.flatfile.txt");
########################################################################################################																
########################################################################################################																
#UPDATE LIST OF IDs for test of uniqueness
open ID, ">>$dir/DATA/ID.txt" or die $!;
select ID;
print"$id\n";
close ID;
select STDOUT;
########################################################################################################
#Generate a PDF of the flatfile and append small versions of photos

open FORPDF, "<$dir/DATA/FLATFILES/$id.txt";
chomp (my @textforpdf = <FORPDF>);
#print "Array is  @textforpdf";
my $pdf = PDF::API2->new();    			# Create a blank PDF file
my $page = $pdf->page();    			# Add a blank page
$page->mediabox('Letter');    			# Set the page size
my $font = $pdf->corefont('Arial');   	# Add a built-in font to the PDF
my $y = 750;
										# Add some text to the page
my $text = $page->text();
if ($encrypt==1){$text->font($font, 2)};
if ($encrypt==0){$text->font($font, 8)};
foreach (@textforpdf)	{
						$y = ($y - 10);
						$text->translate(50, $y);
						$text->text($_);
						}


my @photos;

foreach(@listofphotossmall){
				my $jpg = ("$dir/PHOTOS/IMAGESTORE/$_");
				print "\nattaching image $jpg to pdf\n";
				my $image = $pdf->image_jpeg($jpg);
				my $page = $pdf->page();
				$page->mediabox(0,0,$image->width, $image->height);
				$page->trimbox(0,0,$image->width, $image->height);
				my $gfx = $page->gfx;
				$gfx->image($image, 0, 0);
				}
#save PDF file
$pdf->saveas("$dir/DATA/PDF/$id.pdf");    # Save the PDF
copy ("$dir/DATA/PDF/$id.pdf", "$backuppath/$id.pdf");

#Delete small versions of photos
foreach(@listofphotossmall){unlink "$dir/PHOTOS/IMAGESTORE/$_"};
#move final photos to the appropriate folder for grading

foreach(@listofphotosbig){move ("$dir/PHOTOS/IMAGESTORE/$_" , "$dir/PHOTOS/IMAGESTORE/COMPLETE/$consentphoto")};

#restart the script for next sample
system ('eyescores_4.0beta.pl');
system ('./eyescores_4.0beta.pl');

}
			}
########################################################################################################
########################################################################################################
########################################################################################################
########################################################################################################
#Use a date and time stamp as the sample ID number
sub getidfromdate	{
					$time = strftime ("%y%m%d%H%M%S",localtime(time()));
					$id	= "$countrycode".$time;
					}
########################################################################################################
########################################################################################################
########################################################################################################
sub printheader 	{
					system ("clear");
					system ("cls");
					print"
#################################################
######               EYESCORES             ######
###### ophthalmological Sample Collection  ######
######              v.4.00 beta            ######
#################################################
Sample $id

";
					}

#####################################################################################################
########################################################################################################

sub encryptPublic {
  					my ($public_key,$string) = @_;
					my $key_string;
					open(PUB,$public_key) || die "$public_key: $!";
					read(PUB,$key_string,-s PUB); # Suck in the whole file
					close(PUB);
					my $public = Crypt::OpenSSL::RSA->new_public_key($key_string);
					my $output = encode_base64($public->encrypt($string));
					$output =~ s/\n//g;
					$output;
					}


########################################################################################################
sub singleentry	{				

				$countofvariables ++;
				&printheader;
				my$encrypt = shift(@_);
				my $variablename = shift(@_);
				my $question = shift(@_);
				my $regex = shift(@_);
				
				my $m = ".";
				my $n = ",";				
				$returnvalue =".";
				
				until($m =~ /$regex/i)
									{
									print "$question\n\nEnter Answer: ";
									chomp ($m = <STDIN>)
									};
				$output_count{$variablename} = $countofvariables;
				$output_value{$variablename} = $m;
				$output_encrypt{$variablename} = $encrypt;

					}

########################################################################################################
########################################################################################################
sub singleentrynoheader	{				

				$countofvariables ++;
				my$encrypt = shift(@_);
				my $variablename = shift(@_);
				my $question = shift(@_);
				my $regex = shift(@_);
				my $m = ".";
				my $n = ",";				
				$returnvalue =".";
				
				until($m =~ /$regex/i)
									{
									print "$question\n\nEnter Answer: ";
									chomp ($m = <STDIN>)
									};
				$output_count{$variablename} = $countofvariables;
				$output_value{$variablename} = $m;
				$output_encrypt{$variablename} = $encrypt;
						}

########################################################################################################
########################################################################################################
########################################################################################################
#send to this one with first entry question, second entry question, regex
sub doubleentry	{				
				&printheader;
				$countofvariables ++;
				my$encrypt = shift(@_);
				my $variablename = shift(@_);
				my $question = shift(@_);
				my $question2 = shift(@_);
				my $regex = shift(@_);
				my $m = ".";
				my $n = ",";				
				$returnvalue =".";
				
				my $match = 0;
				until ($match == 1)	{
									print "$question";
									until($m =~ /$regex/i){chomp ($m = <STDIN>)};
									system ('clear');
									system ('cls');
									&printheader;
									print "$question2";
									until($n =~ /$regex/i){chomp ($n = <STDIN>)};
									if ($m =~/$n/i)	{
													$m =~ tr/[a-z]/[A-Z]/;
													$match = 1;
													}
									else	{
											print "\n DOUBLE ENTERED VALUES ARE NOT IDENTICAL\nTRY AGAIN : ";
											$m = ".";
											$n = ",";
											}
									}
				$m;
				$output_count{$variablename} = $countofvariables;
				$output_value{$variablename} = $m;
				$output_encrypt{$variablename} = $encrypt;
				}
########################################################################################################
########################################################################################################
########################################################################################################

#send a list that has question, regex then all other values for list of answers
sub selector	{
				system ("clear");
				system ("cls");

$countofvariables ++;
my $encrypt = shift(@_);
my $variablename = shift(@_);
my $question = shift(@_);
my @currentlist = @_;
my $listlength = @currentlist;
my @range =1..$listlength;
my %answers;

foreach(@range)	{
				$answers{$_}=shift(@currentlist)
				}				

print "
########################################################################
$question
########################################################################
";
foreach(@range){print"# ($_) $answers{$_}\n"};
print "########################################################################\n
";



my $regex = join '|', map "\Q$_\E", @range; 

my $m;
				until($m =~ /$regex/i)
									{
									print "$question\n\nEnter Answer: ";
									chomp ($m = <STDIN>)
									};


			my $finalanswer = $answers{$m};
			
			if ($finalanswer =~ /other/i)	{
										print "\nYou selected 'OTHER', please enter more information or UNKNOWN :  ";
										chomp($finalanswer = <STDIN>);
										}

			$finalanswer =~ tr/[a-z]/[A-Z]/;
			$finalanswer;
			$output_count{$variablename} = $countofvariables;
			$output_value{$variablename} = $finalanswer;
			$output_encrypt{$variablename} = $encrypt;
				}

########################################################################################################
########################################################################################################
#Generic function for allowing a free wordcharacter, nonempty datum
sub getfreetext	{
				$countofvariables ++;
				&printheader;
				my $encrypt = shift(@_);
				my $variablename =  shift(@_);
				my $question =  shift(@_);
				print "$question";
				my $m = ".";
				until($m =~ /\w+/){chomp ($m = <STDIN>)};
				$m =~ tr/[a-z]/[A-Z]/;
				select STDOUT;
				$output_count{$variablename} = $countofvariables;
				$output_value{$variablename} = $m;
				$output_encrypt{$variablename} = $encrypt;
				}
########################################################################################################
#Generic function for allowing a free wordcharacter, nonempty datum
sub getfreetextnoextras	{
				my $encrypt = shift(@_);
				my $variablename =  shift(@_);
				my $question =  shift(@_);
				print "\n\n$question";
				my $m = ".";
				until($m =~ /\w+/){chomp ($m = <STDIN>)};
				$m =~ tr/[a-z]/[A-Z]/;
				select STDOUT;
				$output_value{$variablename} = $m;
				}
########################################################################################################
########################################################################################################
########################################################################################################
#send to this one with first entry question, second entry question, regex
sub doubleentrynocount	{				
				my $question = $_[0];
				my $question2 = $_[1];
				my $regex = $_[2];
				my $m = ".";
				my $n = ",";				
				$returnvalue =".";
				
				my $match = 0;
				until ($match == 1)	{
									print "$question";
									until($m =~ /$regex/i){chomp ($m = <STDIN>)};
									system ('clear');
									system ('cls');
									&printheader;
									print "$question2";
									until($n =~ /$regex/i){chomp ($n = <STDIN>)};
									if ($m =~/$n/i)	{
													$m =~ tr/[a-z]/[A-Z]/;
													$match = 1;
													}
									else	{
											print "\n DOUBLE ENTERED VALUES ARE NOT IDENTICAL\nTRY AGAIN : ";
											$m = ".";
											$n = ",";
											}
									}
				$m;
				}
########################################################################################################
#Generic function for allowing a yes no datum but returns a value
sub getyesnoanswer	{
					$countofvariables ++;
				my $encrypt = shift(@_);
				my $variablename =  shift(@_);
				my $question =  shift(@_);
				my $positive = shift(@_);
				my $negative = shift(@_);

					&printheader;
					print "Enter Y for Yes, N for No\n";

					print "\n$question : ";
					my $m = ".";
					until($m =~ /^(Y|N)$/i){chomp ($m = <STDIN>)};
					$m =~ tr/[a-z]/[A-Z]/;
					if ($m =~ /^(Y)$/)	{$m = $positive};
					if ($m =~ /^(N)$/)	{$m = $negative};
					select STDOUT;
				
				$output_count{$variablename} = $countofvariables;
				$output_value{$variablename} = $m;
				$output_encrypt{$variablename} = $encrypt;
					
					}
########################################################################################################
########################################################################################################
#Generic function for allowing a yes no datum
sub getyesnouncertain	{
					$countofvariables ++;
				my $encrypt = shift(@_);
				my $variablename =  shift(@_);
				my $question =  shift(@_);
				my $positive = shift(@_);
				my $negative = shift(@_);


					&printheader;
					print "Enter Y for Yes, N for No and U for Uncertain\n";
					my $question = $_[0];
					print "\n$question : ";
					my $m = ".";
					until($m =~ /^(Y|N|U)$/i){chomp ($m = <STDIN>)};
					$m =~ tr/[a-z]/[A-Z]/;
					if ($m =~ /^(Y)$/)	{$m = $positive};
					if ($m =~ /^(N)$/)	{$m = $negative};
					if ($m =~ /^(U)$/)	{$m = "UNCERTAIN"};

					select STDOUT;
				$output_count{$variablename} = $countofvariables;
				$output_value{$variablename} = $m;
				$output_encrypt{$variablename} = $encrypt;
					}
########################################################################################################
########################################################################################################

###PHOTO STUFF
########################################################################################################
########################################################################################################
########################################################################################################
########################################################################################################
########################################################################################################
########################################################################################################
########################################################################################################
#############################          OPTION 2 : Error Monitoring form     ############################
########################################################################################################
sub option2	{
			#OPEN OUTPUT FILE FOR single record FLATFILE
			
			my (@listofflatfiles,$getidflatfile,$error,$user);
			@listofflatfiles = <$dir/DATA/FLATFILES/*>;

			$getidflatfile = ".";
			print "Please enter a sample ID number, or enter X to return to front page :  "; 
			until ($getidflatfile =~ /^(X)|(($countrycode)(1[1-9]|2[0-9])(0[1-9]|1[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])(0[0-9]|1[0-9]|2[0-3])([0-5][0-9][0-5][0-9]))$/i) 	{chomp($getidflatfile = <STDIN>)};
			$getidflatfile =~ tr/[a-z]/[A-Z]/;

			print "Got it";
			
			if ($getidflatfile =~ /^X$/i)	{&topmenu}
				
														 
			foreach (@listofflatfiles)	{
							if ($_ =~ $getidflatfile)	{
												$error = ".";
												$user = ".";
												print "...found.\n";
												open ERRORS, ">>$dir/DATA/FLATFILES/$getidflatfile.txt" or die $!;
												select ERRORS;
												print "\n\n\nRecorded error :  ";
												my $errortime = strftime ("%y_%m_%d__%H_%M_%S",localtime(time()));
												print "$errortime\n";
												select STDOUT;
												print "Please describe the nature of the error and steps that were taken to fix the problem \n\n:  ";
												until ($error =~ /\w+/){chomp ($error = <STDIN>)};
												print "Please enter your name :  ";
												until ($user =~ /\w+/){chomp ($user = <STDIN>)};
												select ERRORS;
												print "Error reported by $user.\n";
												print "Error : $error";
												close ERRORS;
												select STDOUT;
												print "\nError recorded.\n";
												sleep 1;
												
												#MAKE A PDF EMF
												
												my @textforpdf = ("$getidflatfile","Error report :",$errortime,"Reported Error :", $error,"User :",$user);

												my $pdf = PDF::API2->new();    # Create a blank PDF file
												my $page = $pdf->page();    # Add a blank page
												$page->mediabox('Letter');    # Set the page size
												my $font = $pdf->corefont('Arial');    # Add a built-in font to the PDF
												my $y = 750;
												# Add some text to the page
												my $text = $page->text();
												if ($encrypt==1){$text->font($font, 2)};
												if ($encrypt==0){$text->font($font, 8)};
												
												foreach (@textforpdf)	{
												$y = ($y - 10);
												$text->translate(50, $y);
												$text->text($_);
												}
												
												my $emffilename = ("EMF_"."$errortime"."_"."$getidflatfile".".pdf");
												print "EMF : $emffilename\n";
												$pdf->saveas("$dir/DATA/EMF/$emffilename");    # Save the PDF
												move ("$dir/DATA/PDF/$getidflatfile.pdf", "$dir/DATA/PDF/old.pdf");
												system ("pdftk $dir/DATA/PDF/old.pdf $dir/DATA/EMF/$emffilename cat output $dir/DATA/PDF/$getidflatfile.pdf");
												unlink ("$dir/DATA/PDF/old.pdf");
												copy ("$dir/DATA/EMF/$emffilename", "$backuppath/$emffilename");

												&topmenu;
														}
										}
										print "Sample datafile does not exist";
										sleep 1;
										&topmenu;
										
										
			}
########################################################################################################
########################################################################################################
########################################################################################################
################################         OPTION q : Quit               #################################
########################################################################################################
sub optionq{			
			print "\nAre you sure you want to quit (Y/N)? :  ";
								my $quit = ".";
								until($quit =~ /^(Y|N|NO|YES)$/i){chomp ($quit = <STDIN>)};
								if ($quit =~ /^(Y|Yes)$/i){exit};
								if ($quit =~ /^(N|No)$/i)	{
															$topmenuchoice = ".";
															&topmenu
															}
			}
########################################################################################################
########################################################################################################
########################################################################################################

########################################################################################################
sub age	{

		my $encrypt = shift(@_);
				system ('clear');
				system ('cls');
		&printheader;
		print "\n\nHow would you like to record age? \n\n1 : Date of Birth\n2 : Age in years\n3 : Year of birth\n4 : Age in Months (only if less than 1 year old)\n\n:  ";
		my $modeofageentry=0;
		until($modeofageentry =~ /^[1-4]$/){chomp($modeofageentry = <STDIN>);
											if ($modeofageentry !~ /^[1-4]$/){print "Please select a valid option (1-4) :"};
											} 	

		if ($modeofageentry =~ /1/){

									print "Enter date of birth (dd/mm/yyyy) :";
									$output_value{"dob"} = ".";
									$countofvariables ++;
									$output_value{"dob"} = "ND";
									until($output_value{"dob"} =~ /^(0[1-9]|[12][0-9]|3[01])[- \/.](0[1-9]|1[012])[- \/.](19|20)\d\d$/){chomp ($output_value{"dob"} = <STDIN>)}
									$output_count{"dob"} = $countofvariables;
									$output_encrypt{"dob"} = $encrypt;									

									$countofvariables ++;
									$output_value{"ageinyears"} = "ND";
									$output_count{"ageinyears"} = $countofvariables;
									$output_encrypt{"ageinyears"} = $encrypt;									

									$countofvariables ++;
									$output_value{"ageinmonths"} = "ND";
									$output_count{"ageinmonths"} = $countofvariables;
									$output_encrypt{"ageinmonths"} = $encrypt;									
									
									$countofvariables ++;
									$output_value{"yob"} = "ND";
									$output_count{"yob"} = $countofvariables;
									$output_encrypt{"yob"} = $encrypt;									


									}

		if ($modeofageentry =~ /2/){
									print "Enter ageinyears (0-119) :";

									$countofvariables ++;
									$output_value{"dob"} = "ND";
									$output_count{"dob"} = $countofvariables;
									$output_encrypt{"dob"} = $encrypt;									

									$output_value{"ageinyears"}=".";
									$countofvariables ++;
									until ($output_value{"ageinyears"} =~ /^([0-9]|[1-9][0-9]|1[0-1][0-9])$/)	{chomp($output_value{"ageinyears"} = <STDIN>)}
									$output_count{"ageinyears"} = $countofvariables;
									$output_encrypt{"ageinyears"} = $encrypt;									

									$countofvariables ++;
									$output_value{"ageinmonths"} = "ND";
									$output_count{"ageinmonths"} = $countofvariables;
									$output_encrypt{"ageinmonths"} = $encrypt;									

									$countofvariables ++;
									$output_value{"yob"} = "ND";
									$output_count{"yob"} = $countofvariables;
									$output_encrypt{"yob"} = $encrypt;									

									}
							
		if ($modeofageentry =~ /3/){

									$countofvariables ++;
									$output_value{"dob"} = "ND";
									$output_count{"dob"} = $countofvariables;
									$output_encrypt{"dob"} = $encrypt;									

									$countofvariables ++;
									$output_value{"ageinyears"} = "ND";
									$output_count{"ageinyears"} = $countofvariables;
									$output_encrypt{"ageinyears"} = $encrypt;									


									$countofvariables ++;
									$output_value{"ageinmonths"} = "ND";
									$output_count{"ageinmonths"} = $countofvariables;
									$output_encrypt{"ageinmonths"} = $encrypt;									



									$output_value{"yob"}=".";
									$countofvariables ++;
									print "Enter year of birth (1900-2019) :";
									$output_value{"yob"}=".";
									until ($output_value{"yob"} =~ /^([1][9]\d\d|20[0-1][0-9])$/)	{chomp($output_value{"yob"} = <STDIN>)}
									$output_count{"yob"} = $countofvariables;
									$output_encrypt{"yob"} = $encrypt;									
	
	
									}
		if ($modeofageentry =~ /4/){

									$countofvariables ++;
									$output_value{"dob"} = "ND";
									$output_count{"dob"} = $countofvariables;
									$output_encrypt{"dob"} = $encrypt;									

									$countofvariables ++;
									$output_value{"ageinyears"} = "ND";
									$output_count{"ageinyears"} = $countofvariables;
									$output_encrypt{"ageinyears"} = $encrypt;									

									$countofvariables ++;
									print "Enter Age in months (01-12) :";
									$output_value{"ageinmonths"}=".";
									until ($output_value{"ageinmonths"} =~ /^([0][1-9]|[1][0-1])$/)	{chomp($output_value{"ageinmonths"} = <STDIN>)}
									$output_count{"ageinmonths"} = $countofvariables;
									$output_encrypt{"ageinmonths"} = $encrypt;									

									$output_value{"yob"} = "ND";
									$output_count{"yob"} = $countofvariables;
									$output_encrypt{"yob"} = $encrypt;									

									}
		}
########################################################################################################
########################################################################################################
########################################################################################################

########################################################################################################
########################################################################################################
sub photorenameandmove {
						my $m;
						my $n;

						($m)=$_[0];
						($n)=$_[1];
						my $currentphoto =$_[2];
						my $studyphase =$_[3];
						my $indi =$_[4];

						my $isthepictureok = ".";
						my $newphotoname = ".";
						until ($isthepictureok =~ /^Y|Yes$/i){
			
			
																$isthepictureok = ".";
																print"\nLooking for photo $dir/PHOTOS/IMAGELANDINGBAY/$currentphoto... \n";
										#SET PATHS TO EYEFI CARD FOLDER
																my @files = <$dir/PHOTOS/IMAGELANDINGBAY/*>;
																my$photoexists ="0";				
																until ($photoexists == 1)	{
																							
																							@files = <$dir/PHOTOS/IMAGELANDINGBAY/*>;
																							foreach (@files){
																											if ($_ =~ $currentphoto)	{
																																		$photoexists=1;
																																		print "...found.\n"};
																											}
															
															if ($photoexists == 0) {
																					print "could not find $currentphoto\n\n";
																					$currentphoto = &doubleentrynocount ("What is the frame number of the $n eye/form? DSC-","\n\nEnter the frame number again  DSC-", '^(\d{4})$');
																					$currentphoto = "DSC_"."$currentphoto".".JPG";
																					#&photorenameandmove ($m,$n,$currentphoto);
																					}
															
																					$newphotoname = $m."_".$n."_".$studyphase."_".$indi."_".$currentphoto;
																							}

						system (qq+convert "$dir/PHOTOS/IMAGELANDINGBAY/$currentphoto" -resize 25% "$dir/PHOTOS/IMAGELANDINGBAY/temp.JPG"+);
						system ("perl $dir/SCRIPTS/picshow.pl $dir/PHOTOS/IMAGELANDINGBAY/temp.JPG");
						#system ("perl $dir/SCRIPTS/picshow.pl $dir/PHOTOS/IMAGELANDINGBAY/$currentphoto");

						print "Is the photo of sufficient quality? (Y/N) :  ";
						until($isthepictureok =~ /^Y|YES|N|NO$/i)	{chomp ($isthepictureok = <STDIN>)};
															if ($isthepictureok =~ /N|NO$/i){
																							$currentphoto =".";
																							print "please take another photo of the $n (eye/form): WHAT IS THE FRAME NUMBER ? DSC_";
																							until($currentphoto =~ /^(\d{4}$)/i)	{chomp ($currentphoto = <STDIN>)}
																							$currentphoto = "DSC_"."$currentphoto".".JPG";
																							}
	
															}
#						if ($isthepictureok =~ /^N|No$/i)	{
#															unlink "$dir/PHOTOS/IMAGELANDINGBAY/$currentphoto";
#															unlink "$dir/PHOTOS/IMAGELANDINGBAY/temp.JPG";
#															&photorenameandmove;
#															}
						if 	($isthepictureok =~ /^Y|Yes$/i){
															unlink "$dir/PHOTOS/IMAGELANDINGBAY/temp.JPG";
															print "renaming $currentphoto to $newphotoname\n";
															copy ("$dir/PHOTOS/IMAGELANDINGBAY/$currentphoto", "$dir/PHOTOS/IMAGELANDINGBAY/$newphotoname");
															unlink "$dir/PHOTOS/IMAGELANDINGBAY/$currentphoto";
															move ("$dir/PHOTOS/IMAGELANDINGBAY/$newphotoname" , "$dir/PHOTOS/IMAGESTORE/$newphotoname");
															print "\n$currentphoto renamed as $newphotoname and moved to imagestore\n";
															my $smallfilename = "small"."$newphotoname";
															system (qq+convert "$dir/PHOTOS/IMAGESTORE/$newphotoname" -resize 30% -quality 50 "$dir/PHOTOS/IMAGESTORE/$smallfilename"+);
															push (@listofphotossmall,"$smallfilename");
															push (@listofphotosbig,"$newphotoname");

															
#	my @photos = ($newphotoname,$smallfilename);
															}
						$newphotoname;						
						}
########################################################################################################
########################################################################################################

sub appendtophoto	{
					my $photo = shift(@_);
					my $id = shift(@_);
					unshift (@_,$id);
					my $printing = join(' | ', @_ );
																					print "$printing\n";
																					my $fullpath = "$dir/PHOTOS/IMAGESTORE/".$photo;
																					system(qq+convert "$fullpath" -background Orange -pointsize 40 label:"$printing"  -append "$fullpath"+);
																					$fullpath = "$dir/PHOTOS/IMAGESTORE/small".$photo;
																					system(qq+convert "$fullpath" -background Orange -pointsize 10 label:"$printing"  -append "$fullpath"+);
					}
########################################################################################################
