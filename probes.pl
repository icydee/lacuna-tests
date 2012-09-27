use lib '/data/Lacuna-Server/lib';

use strict;
use warnings;

use Data::Dumper;
use 5.010;
use DateTime;
use Lacuna;

my $empire_name     = 'icydee';
my $zone            = '0|0';

my $alliance_color = {
    905	=> '#1bbfe0',
     26 => '#e03c1b',
    150 => '#7ee01b',
    385 => '#7d1be0',
    376 => '#1b39e0',
    871 => '#e0c21b',
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
    print "probes.push({x:$x, y:$y});\n";
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
    print "stars.push({alliance: $a, x: $x, y: $y});\n";
}

# all colonies in this zone
my $planets = Lacuna->db->resultset('Map::Body')->search({
    empire_id   => {'!=' => undef},
    zone        => $zone,
});
my $num_colonies = $planets->count;
print "// There are $num_colonies colonies in zone $zone\n";
print "var colonies = new Array();\n";
while (my $planet = $planets->next) {
    # colonies.push({alliance: 905, x:-246, y: 525});
    my $a = $planet->empire->alliance_id || 0;
    if ($a) {
        $alliances->{$a} = $planet->empire->alliance;
    }
    my $x = $planet->x;
    my $y = $planet->y;
    print "colonies.push({alliance: $a, x: $x, y: $y});\n";
}


# display all known alliances.
print "var alliances = new Array();\n";
print "alliances[0] = {color : '#000000', name : 'un-allied'};\n";
foreach my $alliance_id (sort keys %$alliances) {
    my $ka          = $alliance_color->{$alliance_id};
    my $color       = defined $ka ? $ka : '#000000';
    my $alliance    = Lacuna->db->resultset('Alliance')->find($alliance_id);
    my $name        = $alliance->name;
    print "alliances[$alliance_id] = {color : '$color', name : '$name'};\n";
}
my $max_alliances = scalar keys %$alliances;
print "// there are $max_alliances alliances in zone $zone\n";
1;

