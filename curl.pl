#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper qw(Dumper);
use LWP::Simple;
use JSON qw( decode_json );

# snowflakes   
# my $url = "http://10.177.128.143:8080/snowflakes/sf/transaction-api/save-transaction?accountId={$accountId}&accountPassword={$pwd}&
	# productCode=SSCJO367&mobileNumber={$msisdn}&amount={$amount}";

my $url = 'http://www.mocky.io/v2/588176082500008815c9edf1'; 
my $json = get( $url );
die "Could not get $url!" unless defined $json;

my $decoded_json = decode_json( $json );

print Dumper $decoded_json;

print "DETAILS: ",
      $decoded_json->{'transid'},
      "\n";
