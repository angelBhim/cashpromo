#!/usr/bin/perl

use strict;
use warnings;
use DBI;

use Data::Dumper qw(Dumper);

my $dbport = '3306';
my $dbname = 'Dmp_Transaction';
my %hosts;

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

# SHEENA
# $hosts{'2910'}{'host'} = '23.253.196.161'; #public
# $hosts{'2910'}{'username'} = 'dmp_push'; 
# $hosts{'2910'}{'password'} = 'sh3ena29I0';
# $hosts{'2910'}{'service_id'} = '57246';

# # MELANIE
# $hosts{'2161'}{'host'} = '166.78.207.237'; #public
# $hosts{'2161'}{'username'} = 'dmp_push';
# $hosts{'2161'}{'password'} = 'gDg3mPush36g';
# $hosts{'2161'}{'service_id'} = '5764';

# $hosts{'2624'}{'host'} = '166.78.207.237'; #public
# $hosts{'2624'}{'username'} = 'dmp_push';
# $hosts{'2624'}{'password'} = 'gDg3mPush36g';
# $hosts{'2624'}{'service_id'} = '5765';

# # RIA
# $hosts{'2864'}{'host'} = '23.253.196.163'; #public
# $hosts{'2864'}{'username'} = 'dmp_push';
# $hosts{'2864'}{'password'} = '2910r!aPush';
# $hosts{'2949'}{'service_id'} = '5858';

# $hosts{'2949'}{'host'} = '23.253.196.163'; #public
# $hosts{'2949'}{'username'} = 'dmp_push';
# $hosts{'2949'}{'password'} = '2910r!aPush';
# $hosts{'2949'}{'service_id'} = '5859';

# # KITIN
# $hosts{'2123'}{'host'} = '10.208.152.24'; #public 
# $hosts{'2123'}{'username'} = 'dmp_push';
# $hosts{'2123'}{'password'} = 'shGcAr6mL3adPu';
# $hosts{'2123'}{'service_id'} = '5718';
my @list = get_new_subscriber();
my @winners;

# choose winner
for (my $i = 0; $i<2; $i++) {
    push(@winners, $list[rand @list]);
}
print Dumper(@list);
sub get_new_subscriber {
    my @subs;
    
    foreach my $host (sort keys %hosts) {
        my $dsn = "DBI:mysql:database=$dbname;host=$hosts{$host}{'host'};port=$dbport";
        my $dbh = DBI->connect($dsn, $hosts{$host}{'username'}, $hosts{$host}{'password'});
        
        if ($dbh) {
            my $sql = "SELECT msisdn, service_id, $host as ac FROM Dmp_Transaction.subscribers a WHERE 1 AND a.`active` = 1 
                AND DATE(a.`sub_on`) >= (CURDATE() - INTERVAL 1 DAY) AND a.`service_id` IN (
                    SELECT service_id FROM Dmp_Content.`services` ds 
                        LEFT JOIN Dmp_Content.`shortcodes` dsc 
                        ON ds.`shortcode_id` = dsc.`shortcode_id` 
                        WHERE ds.service_active = 1 AND ds.is_cashagana = 1 
                        AND dsc.`shortcode_name` = $host) LIMIT 3;";

            my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
            $sth->execute() or die "execution failed: $dbh->errstr()";
            # print $sth->rows. " rows found.\n";

            while (my $ref = $sth->fetchrow_hashref()) {
                push(@subs, $ref->{'msisdn'}."|".$ref->{'service_id'}."|".$ref->{'ac'});
            }
            
            $sth->finish;
        }
    }
    return @subs;
}


1;