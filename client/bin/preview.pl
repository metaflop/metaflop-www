#! /usr/bin/perl -w

use CGI::Carp qw(fatalsToBrowser);
use Cwd;

# save original stdout, temp. output to /dev/null
open my $saveout, ">&STDOUT";
open STDOUT, '>', "/dev/null";

# generate the font image
system('mf', 'adj.mf');
system('gftodvi', 'adj.2602gf');
system('dvipng', 'adj.dvi');

# restore original stdout
open STDOUT, ">&", $saveout;

# output the image
my $pwd = cwd . "/";
open FH, $pwd . "adj1.png" or die "couldn't open file";
print "Content-type: image/png\n\n";
while(<FH>) {
  print;
}
close FH;

