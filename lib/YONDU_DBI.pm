#!/usr/bin/perl

use strict;
use warnings;
use DBI;

package YONDU_DBI;

my $dbname = 'Dmp_Transaction';
my $dbhost = '10.208.4.239';
#my $dbuser = 'dmp_gw';
#my $dbpass = '3g6gWrIa';

#edited mseneres 122816
my $dbuser = 'dmp_push';
my $dbpass = '2910r!aPush';

my $dbport = '3306';

my $dsn = "DBI:mysql:database=$dbname;host=$dbhost;port=$dbport";
my $dbh = DBI->connect($dsn, $dbuser, $dbpass);


sub new
{
  my $class = shift;
  my $self = {};
  bless $self, $class;
  return $self;
}

sub subscribe
{
  my ($serviceId, $msisdn) = @_;
  my $sql = "INSERT INTO subscribers(msisdn, service_id, active) VALUES('$msisdn', '$serviceId', 1) ON DUPLICATE KEY UPDATE active=1";
    my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
  YONDU_DBI::log_sql($sql);
  return 1;
}

sub unsubscribe
{
  my ($serviceId, $msisdn) = @_;
  my $sql = "UPDATE subscribers SET active=0 WHERE msisdn='$msisdn' AND service_id='$serviceId' AND active=1";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
#  $return = $sth->fetchrow;
  YONDU_DBI::log_sql($sql);
  return 1; # $return;
}

sub unsubscribe_all
{
  my ($msisdn, $status) = @_;
  $status = '-2' if (!$status);
  my $sql = "UPDATE subscribers SET active=$status WHERE msisdn='$msisdn' AND active=1";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
  YONDU_DBI::log_sql($sql);
  return 1;
}

sub list_subscribe
{
  my ($serviceId) = @_;
  my $sql = "SELECT DISTINCT(msisdn) as msisdn FROM subscribers WHERE active=1 AND service_id='$serviceId'";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
  print $sth->rows . " rows found.\n";

  my @subs;
  while (my $ref = $sth->fetchrow_hashref()) {
    push(@subs, $ref->{'msisdn'});
  }
  $sth->finish;
  return @subs;
}

sub list_subscribe_per_msisdn
{
  my ($msisdn) = @_;
  my $sql = "SELECT dts.service_id, dcs.service_name FROM Dmp_Transaction.subscribers dts LEFT JOIN Dmp_Content.services AS dcs ON dcs.service_id = dts.service_id WHERE dts.active=1 AND dts.msisdn='$msisdn'";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
  print $sth->rows . " rows found.\n";

  my @subs;
  while (my $ref = $sth->fetchrow_hashref()) {
    push(@subs, $ref->{'service_name'});
  }
  $sth->finish;
  return @subs;
}

sub list_credit_subscribers
{
  my ($serviceId) = @_;
  my $sql = "SELECT DISTINCT(msisdn) AS msisdn FROM Dmp_Omnibus.omnibus_credit WHERE service_id='$serviceId'";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
  print $sth->rows . " rows found.\n";

  my @subs;
  while (my $ref = $sth->fetchrow_hashref()) {
    push(@subs, $ref->{'msisdn'});
  }
  $sth->finish;
  return @subs;
}

sub list_status
{
  my ($serviceId, $date, $trans, $status) = @_;
  my $sql = "SELECT DISTINCT(msisdn) FROM log_status_$date WHERE transid LIKE '".$trans.$serviceId."%' AND status_code='$status'";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
  print $sth->rows . " rows found.\n";

  my @subs;
  while (my $ref = $sth->fetchrow_hashref()) {
    push(@subs, $ref->{'msisdn'});
  }
  $sth->finish;
  return @subs;
}

sub is_subscribed
{
  my ($msisdn, $serviceId) = @_;
  my $strWhere = "active=1 AND msisdn='$msisdn'";
  $strWhere .= " AND service_id='$serviceId'" if ($serviceId);

  my $sql = "SELECT 1 FROM subscribers WHERE $strWhere";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";

  my $return = 0;
  $return = 1 if ($sth->rows);
  $sth->finish;
  return $return;
}

sub get_content
{
  my ($serviceId, $date) = @_;
  my $sql = "SELECT content FROM Dmp_Content.contents WHERE service_id='$serviceId' AND schedule_date='$date' ORDER BY id DESC LIMIT 1";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
  print $sth->rows . " rows found.\n";

  my $ref = $sth->fetchrow_hashref();
  my $content = $ref->{'content'};
  $sth->finish;
  return $content;
}

sub ikonek_add_credits
{
  my ($msisdn, $credits, $balance) = @_;
  $credits = 0 if (!$credits);
  $balance = 0 if (!$balance);
  my $sql = "INSERT INTO ikonek_credit(msisdn, credit, credit_date) VALUES('$msisdn', $credits, NOW()) ".
            "ON DUPLICATE KEY UPDATE credit = credit + $credits, balance = balance + $balance, credit_date=NOW()";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
  YONDU_DBI::log_sql($sql);
#  $credits = YONDU_DBI::ikonek_get_credits($msisdn);
  return 1;
}

sub ikonek_get_credits
{
  my ($msisdn) = @_;
  my ($return) = 0;
  my $sql = "SELECT credit FROM ikonek_credit WHERE msisdn=$msisdn";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";
  YONDU_DBI::log_sql($sql);
  $return = $sth->fetchrow_hashref();
  return $return->{'credit'};
}

sub execute_sql
{
  my ($sql) = @_;
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";

  my @arrSQL = split(" ",lc($sql));
  if ($arrSQL[0] eq "select")
  {
    print $sth->rows . " rows found.\n";
    my @arrData;
    while (my $ref = $sth->fetchrow_hashref()) {
      push(@arrData, $ref);
    }
    $sth->finish;
    return @arrData;
  }
  YONDU_DBI::log_sql($sql);
  return 1;
}

sub insert_push_transaction_status
{
  my ($service_id, $count) = @_;
  my $sql = "INSERT INTO push_transactions_status(service_id, base_count, push_status, push_time)
                    VALUES($service_id, $count, 1, CURRENT_TIMESTAMP);";
  my $sth = $dbh->prepare($sql) or die "prepare statement failed: $dbh->errstr()";
  $sth->execute() or die "execution failed: $dbh->errstr()";

  YONDU_DBI::log_sql($sql);
  return 1;
}

sub get_date
{
  use POSIX qw(strftime);
  my ($format) = @_;
  $format = "%Y-%m-%d %H:%M:%S" if (!$format);
  my $date = strftime $format, localtime;
  return $date;
}

sub log_sql
{
  my ($sql) = @_;
  my $logdir = '/home/xavier/logs/lib';
  my $logfile = YONDU_DBI::get_date('%Y%m%d');
  my $logdate = YONDU_DBI::get_date();

  my $logpath = "$logdir/$logfile-sql.log";
  my $logdata = "$logdate -- $sql";
  open(my $fh, '>>', $logpath) or die "Could not open file '$logpath' $!";
  print $fh "$logdata\n";
  close $fh;
}





1;