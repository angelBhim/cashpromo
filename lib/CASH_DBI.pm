use strict;
use warnings;
use DBI;
use Data::Dumper qw(Dumper);


package CASH_DBI;



sub get_new_subscriber {
  my @subs;
  my ($dbname, $host, $dbport) = @_;


  my $dsn = "DBI:mysql:database=$dbname;host=$host->{'host'};port=$dbport";
  my $dbh = DBI->connect($dsn, $host->{'username'}, $host->{'password'});

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

  return $host;

}


1;
