
use strict;
use warnings;
use Text::CSV;
use DateTime;
use LWP::Simple;
use JSON qw( decode_json );
use Data::Dumper qw(Dumper);

use lib 'lib';
use CASH_DBI;
use Helper;


my @list;
my $dt = DateTime->now;
my $ymd = $dt->ymd;

my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n"})
    or die "Cannot use CSV: " . Text::CSV->error_diag();

# open in append mode
open my $fh, ">>", "logs/$ymd" . "_winners.csv" or die "Failed to open file: $!";
$csv->print($fh, [ "msisdn", "service_id", "access_code", "status" ]);

# get all new subs
foreach my $config (sort keys %hosts) {
	push(@list, CASH_DBI::get_new_subscriber(\%{$hosts{$config}}));
}


for (my $i = 0; $i<3; $i++) {
	# choose winner
	my $win = $list[rand @list];
	my @details = split(/:+/, $win);
	
	# topup here
	my $res = topup(@details);
	push(@details, $res->{'responseMessage'});
    
    # write report
    $csv->print($fh, \@details);
}

close $fh;

sub topup {
	my (@details) = @_;
	my $url = 'http://www.mocky.io/v2/588176082500008815c9edf1'; 
	my $json = get( $url );
	die "Could not get $url!" unless defined $json;

	return decode_json( $json );
}
