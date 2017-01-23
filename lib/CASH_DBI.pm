use strict;
use warnings;
use DBI;
use Data::Dumper qw(Dumper);

my $dbname = 'Dmp_Transaction';
my $dbport = '3306';

package CASH_DBI;



sub get_new_subscriber {
    my @subs;
    my ($host) = @_;


    my $dsn = "DBI:mysql:database=$dbname;host=$host->{'host'};port=$dbport";
    my $dbh = DBI->connect($dsn, $host->{'username'}, $host->{'password'});

    if ($dbh) {
        my $sql = "SELECT 
                    s.msisdn, s.service_id, $host->{'access_code'} AS ac
                    FROM
                        Dmp_Transaction.subscribers s
                            INNER JOIN
                        (SELECT 
                            a.msisdn
                        FROM
                            Dmp_Transaction.subscribers a
                        WHERE
                            1
                        GROUP BY a.msisdn
                        HAVING COUNT(a.msisdn) = 1) sa ON s.msisdn = sa.msisdn
                    WHERE
                        s.active = 1
                            AND DATE(s.sub_on) = (CURDATE() - INTERVAL 1 DAY)
                            AND s.service_id IN (SELECT 
                                service_id
                            FROM
                                Dmp_Content.`services` ds
                                    LEFT JOIN
                                Dmp_Content.`shortcodes` dsc ON ds.`shortcode_id` = dsc.`shortcode_id`
                            WHERE
                                ds.service_active = 1
                                    AND ds.is_cashagana = 1
                                    AND dsc.`shortcode_name` = $host->{'access_code'}) limit 3;";

        my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
        $sth->execute() or die "execution failed: $dbh->errstr()";
        # print $sth->rows. " rows found.\n";

        while (my $ref = $sth->fetchrow_hashref()) {
            push(@subs, $ref->{'msisdn'}."|".$ref->{'service_id'}."|".$ref->{'ac'});
            # print $ref->{'msisdn'};
        }

        $sth->finish;
    }
    return @subs;

}


1;
