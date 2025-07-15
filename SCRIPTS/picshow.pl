#!/usr/bin/env perl
use Tk;
use Tk::JPEG;
use Tk::Pane;
use strict;
use warnings;
use strict;
use Tk;
use Tk::JPEG;
use File::Copy;
		
chomp(my @file = @ARGV);
		
&show;
sub show{
my $Main = MainWindow->new;
my $button = $Main->Button(-text => 'CLOSE', -command => \&exit);
$button->pack;
my $text_box = $Main->Scrolled( 'Text',
				-scrollbars => 'osoe',  -width => 640, -height => 480,)
    ->pack( -expand => 1,
	    -fill => 'both',
	    -side => 'top',
	    -anchor => 'w',
	    );

my $inline_img_1 = $text_box->Photo( '-format' => 'jpeg',
				     -file => $file[0]
				     );
$text_box->imageCreate( 'end', -image => $inline_img_1 );

$text_box->insert( 'end', "\n" );


MainLoop;
}
print "done";
unlink "temp.JPG";