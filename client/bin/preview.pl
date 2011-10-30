#! /usr/bin/perl -w

use CGI::Carp qw(fatalsToBrowser);
use Cwd;

my $pwd = cwd . "/";
print "$pwd";
system('mf', 'adj.mf');
system('gftodvi', 'adj.2602gf');
system('dvipng', 'adj.dvi');

open FH, $pwd . "adj1.png" or die "couldn't open file";
print "Content-type: image/png\n\n";
while(<FH>) {
  print;
}
close FH;

