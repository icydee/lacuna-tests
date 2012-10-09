use strict;
use warnings;

use GD;

my $im = GD::Image->new(500,250);

my $white = $im->colorAllocate(255,255,255);
my $black = $im->colorAllocate(0,0,0);
my $red   = $im->colorAllocate(255,0,0);

$im->transparent($white);
$im->interlaced('true');

$im->arc(50,50,95,75,0,360,$red);
$im->fill(50,50,$red);

binmode STDOUT;
print $im->png;

