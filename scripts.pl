
use strict;
use warnings;

use lib 'lib';
use Data::Dumper qw(Dumper);
use DBD::CSV;
use DateTime;
use CASH_DBI;
use Helper;


my @cash;
my $dt = DateTime->now;
my $ymd = $dt->ymd;


open (FH, ">>logs/$ymd" . "_winners.csv") or die "$!";
print FH "msisdn, access code ,  top up\
";


foreach my $config (sort keys %hosts) {
	push(@cash, CASH_DBI::get_new_subscriber(\%{$hosts{$config}}));
}



my @winners;

# choose winner
for (my $i = 0; $i<2; $i++) {
    push(@winners, $cash[rand @cash]);
}

print FH @cash;

print Dumper(@cash);


close(FH);

