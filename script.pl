#!/usr/bin/perl

use strict;
use warnings;

use lib '/var/www/html/lib';
use YONDU_DBI;
use YONDU_APP;

our $tm_piso = new YONDU_APP;
require '/var/www/html/perl/apps/sample-config.pl';
require '/var/www/html/apps/sample-replies.pl';

my $subType = '';
$subType = $ARGV[0];
die "Missing sub type parameter: inday, pera, luv, takot, hart" if (!$subType);

my $serviceId = $tm_piso->{'service'}{$subType};
$tm_piso->set_service_id('id', $serviceId);
push_ultra($serviceId);

sub push_ultra
{
  my ($serviceId) = @_;
  my $date = $tm_piso->get_date('%Y-%m-%d 00:00:00');
  my @subs = YONDU_DBI::list_credit_subscribers($serviceId);
  #my @subs = ('9175144723');
  #my @subs = ('9265601907');
  my $total = scalar(@subs);
  print "total: $total\n";
  my $ctr = 1;
  my $content = '';
  my $today = $tm_piso->get_date('%Y-%m-%d %H:%M:%S');
  foreach my $msisdn (@subs)
  {
    $ctr = 1 if ($ctr>20);
    $content =  $tm_piso->{'replies'}{"push_content_$subType"};
    $content =~ s/<TODAY>/$today/;
    $tm_piso->send_sms_dmp($msisdn, "ultra$subType$ctr", "push_ultra_$subType", $content);
    #$tm_piso->send_charging_dmp($msisdn, "ultra$subType$ctr", "push_ultra_$subType");
    $ctr++;
  }
}



1;
