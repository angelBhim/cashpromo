
use strict;
use warnings;

use lib 'lib';
use Data::Dumper qw(Dumper);

use CASH_DBI;
use Helper;

my @cash;



foreach my $config (sort keys %hosts) {
	push(@cash, CASH_DBI::get_new_subscriber(\%{$hosts{$config}}));
}


my @winners;

# choose winner
for (my $i = 0; $i<2; $i++) {
    push(@winners, $cash[rand @cash]);
}

print Dumper(@cash);
