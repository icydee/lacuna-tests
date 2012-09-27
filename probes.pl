use lib '/data/Lacuna-Server/lib';

use strict;
use warnings;

use Data::Dumper;
use 5.010;
use DateTime;
use Lacuna;

my $empire_name     = 'icydee';
my $zone            = '0|2';

my $known_alliances = {
    905	=> { colour => '#1bbfe0', name => 'unknown'},
     26 => { colour => '#e03c1b', name => 'Culture'},
    150 => { colour => '#7ee01b', name => 'unknown'},
    385 => { colour => '#7d1be0', name => 'unknown'},
    376 => { colour => '#1b39e0', name => 'unknown'},
    871 => { colour => '#e0c21b', name => 'unknown'},
};

my ($empire) = Lacuna->db->resultset('Empire')->search({name => $empire_name});
my $all_stars =  Lacuna->db->resultset('Map::Star')->search({
    zone => $zone,
})->count;

print "// There are $all_stars stars in zone $zone\n";

# probes in the zone.
my $probes_rs = Lacuna->db->resultset('Probes')->search({
    alliance_id     => $empire->alliance_id,
    'star.zone'     => $zone,
},{
    prefetch        => 'star',
});
my $num_probes = $probes_rs->count;
print "// There are $num_probes probes in zone $zone\n";
print "var probes = new Array();\n";
while (my $probe = $probes_rs->next) {
    # probes.push({x:-200, y:529});
    my $x = $probe->star->x;
    my $y = $probe->star->y;
#    print "probes.push({x:$x, y:$y});\n";
}

# stars siezed in the zone
my $stars = Lacuna->db->resultset('Map::Star')->search({
    'me.zone'   => $zone,
    station_id  => {'!=' => undef },
},{
    prefetch    => 'station',
});
my $alliances;
my $stars_siezed = $stars->count;
print "// There are $stars_siezed siezed stars in zone $zone\n";
print "var stars = new Array();\n";
while (my $star = $stars->next) {
    # stars.push({alliance: 376, x:   42, y: 518});
    my $alliance = $star->station->empire->alliance;
    $alliances->{$alliance->id} = $alliance;
    my $a = $alliance->id;
    my $x = $star->x;
    my $y = $star->y;
#    print "stars.push({alliance: $a_id, x: $x, y: $y});\n";
}

# display all known alliances.
foreach my $alliance_id (sort keys %$alliances) {
    my $ka = $known_alliances->{$alliance_id};
    if (not defined $ka) {
        $ka = $knows_alliances->{$alliance_id} = {
            colour  => '#000000',
            name    => $alliances->{$alliance_id}->name,
        }
    }
    
}
1;

