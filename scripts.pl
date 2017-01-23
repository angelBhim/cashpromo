
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
print Dumper(\@cash) ."\n";



# localhost
# $hosts{'2910'}{'host'} = 'localhost'; #public
# $hosts{'2910'}{'username'} = 'root';
# $hosts{'2910'}{'password'} = 'root';
# $hosts{'2910'}{'service_id'} = '5716';

# liway
# $hosts{'2910'}{'host'} = '23.253.177.142'; #public
# $hosts{'2910'}{'username'} = 'dmp_push';
# $hosts{'2910'}{'password'} = 'Liwad!mypus!h';
# $hosts{'2910'}{'service_id'} = '5723';
#
#
# foreach my $host (sort keys %hosts) {
#   print $hosts{$hosts}{'host'};
# }

#
