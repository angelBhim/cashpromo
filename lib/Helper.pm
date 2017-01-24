package Helper;


use strict;
use warnings;
use Exporter;

our @ISA = 'Exporter';
our @EXPORT = qw(%hosts);



our %hosts;

# localhost
# $hosts{'2910'}{'host'} = 'localhost'; #public
# $hosts{'2910'}{'username'} = 'root';
# $hosts{'2910'}{'password'} = 'root';
# $hosts{'2910'}{'service_id'} = '5716';

# # liway
# $hosts{'2910'}{'host'} = '10.208.155.74';  #private
# $hosts{'2910_liway'}{'host'} = '23.253.177.142'; #public
# $hosts{'2910_liway'}{'username'} = 'dmp_push';
# $hosts{'2910_liway'}{'password'} = 'Liwad!mypus!h';
# $hosts{'2910_liway'}{'service_id'} = '5723';
# $hosts{'2910_liway'}{'access_code'} = '2910';

# # SHEENA
# # $hosts{'2910'}{'host'} = '10.176.160.187'; #private
$hosts{'2910_sheena'}{'host'} = '23.253.196.161'; #public
$hosts{'2910_sheena'}{'username'} = 'dmp_push';
$hosts{'2910_sheena'}{'password'} = 'sh3ena29I0';
$hosts{'2910_sheena'}{'service_id'} = '57246';
$hosts{'2910_sheena'}{'access_code'} = '2910';

# MELANIE
# $hosts{'2161'}{'host'} = '10.178.20.75';   #private
# $hosts{'2161_melanie'}{'host'} = '166.78.207.237'; #public
# $hosts{'2161_melanie'}{'username'} = 'dmp_push';
# $hosts{'2161_melanie'}{'password'} = 'gDg3mPush36g';
# $hosts{'2161_melanie'}{'service_id'} = '5764';
# $hosts{'2161_melanie'}{'access_code'} = '2161';

# $hosts{'2624'}{'host'} = '10.178.20.75';   #private
# $hosts{'2624_melanie'}{'host'} = '166.78.207.237'; #public
# $hosts{'2624_melanie'}{'username'} = 'dmp_push';
# $hosts{'2624_melanie'}{'password'} = 'gDg3mPush36g';
# $hosts{'2624_melanie'}{'service_id'} = '5765';
# $hosts{'2624_melanie'}{'access_code'} = '2624';

# # RIA
# # $hosts{'2864'}{'host'} = '10.208.4.239';  #private
# $hosts{'2864_ria'}{'host'} = '23.253.196.163'; #public
# $hosts{'2864_ria'}{'username'} = 'dmp_push';
# $hosts{'2864_ria'}{'password'} = '2910r!aPush';
# $hosts{'2864_ria'}{'service_id'} = '5858';
# $hosts{'2864_ria'}{'access_code'} = '2864';

# # $hosts{'2949'}{'host'} = '10.208.4.239';  #private
# $hosts{'2949_ria'}{'host'} = '23.253.196.163'; #public
# $hosts{'2949_ria'}{'username'} = 'dmp_push';
# $hosts{'2949_ria'}{'password'} = '2910r!aPush';
# $hosts{'2949_ria'}{'service_id'} = '5859';
# $hosts{'2949_ria'}{'access_code'} = '2949';

# # KITIN
# # $hosts{'2123'}{'host'} = '10.208.152.24'; #private
# $hosts{'2123_kitin'}{'host'} = '23.253.177.141'; #public
# $hosts{'2123_kitin'}{'username'} = 'dmp_push';
# $hosts{'2123_kitin'}{'password'} = 'shGcAr6mL3adPu';
# $hosts{'2123_kitin'}{'service_id'} = '5718';
# $hosts{'2123_kitin'}{'access_code'} = '5718';


1;
