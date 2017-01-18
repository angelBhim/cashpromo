#!/usr/bin/perl

$tm_piso->set_service('tm_piso', '3711');
$tm_piso->set_service_id('inday', '3711');
$tm_piso->set_service_id('pera', '3131');
$tm_piso->set_service_id('luv', '3141');
$tm_piso->set_service_id('takot', '3351');
$tm_piso->set_service_id('hart', '3712');

#$tm_piso->set_cp_login('EGG','EGG','T2rhEgBk');

#$tm_piso->set_debug(1);
#inday

for ( my $i=1; $i<=3; $i++){
  $tm_piso->set_config("silentinday$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/silent$i",'2864','Yes','99','111');
}

for ( my $i=1; $i<=20; $i++){
  $tm_piso->set_config("ultrainday$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/eggmt/out$i",'2864','Yes','UB','111');
}

#pera
for ( my $i=1; $i<=3; $i++){
  $tm_piso->set_config("silentpera$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/silent$i",'2864','Yes','99','111');
}

for ( my $i=1; $i<=20; $i++){
  $tm_piso->set_config("ultrapera$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/eggmt/out$i",'2864','Yes','UB','111');
}

#luv
for ( my $i=1; $i<=3; $i++){
  $tm_piso->set_config("silentluv$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/silent$i",'2864','Yes','99','111');
}

for ( my $i=1; $i<=20; $i++){
  $tm_piso->set_config("ultraluv$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/eggmt/out$i",'2864','Yes','UB','111');
}

#takot
for ( my $i=1; $i<=3; $i++){
  $tm_piso->set_config("silenttakot$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/silent$i",'2864','Yes','99','111');
}

for ( my $i=1; $i<=20; $i++){
  $tm_piso->set_config("ultratakot$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/eggmt/out$i",'2864','Yes','UB','111');
}

#hart
for ( my $i=1; $i<=3; $i++){
  $tm_piso->set_config("silenthart$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/silent$i",'2864','Yes','99','111');
}

for ( my $i=1; $i<=20; $i++){
  $tm_piso->set_config("ultrahart$i",'2864','2864EGGAYOS_PISO','PISO',"/home/xavier/gateway/2864/eggmt/out$i",'2864','Yes','UB','111');
}



$tm_piso->set_apps_log('/home/xavier/logs/2864/apps');
$tm_piso->set_trans_log('/home/xavier/logs/2864/trans');


1;