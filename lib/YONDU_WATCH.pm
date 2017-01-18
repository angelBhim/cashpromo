#!/usr/bin/perl

use strict;
use warnings;

package YONDU_WATCH;

sub new
{
  my $class = shift;
  my $self = {};
  bless $self, $class;
  return $self;
}

sub set_lookup_dir
{
  my ($self, $dir) = @_;
  $self->{'lookup_dir'} = $dir;
  mkdir $dir;
  return $self;
}

sub set_status_dir
{
  my ($self, $dir) = @_;
  $self->{'status_dir'} = $dir;
  mkdir $dir;
  return $self;
}

sub set_endpoint_url
{
  my ($self, $url) = @_;
  $self->{'endpoint'} = $url;
  return $self;
}

sub set_callback_url
{
  my ($self, $url) = @_;
  $self->{'callback'} = $url;
  return $self;
}

sub set_service_call
{
  my ($self, $service, $function) = @_;
  $self->{$service} = $function;
  return $self;
}

sub set_start_time
{
  my ($self, $time) = @_;
  $self->{'stime'} = $time;
  return $self;
}

sub set_end_time
{
  my ($self, $time) = @_;
  $self->{'etime'} = $time;
  return $self;
}

sub set_watchers_log
{
  my ($self, $logdir) = @_;
  $self->{'watchers_log'} = $logdir;
  mkdir $logdir;
  return $self;
}

sub process
{
  my ($self) = @_;
  use LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  $ua->env_proxy;

  my $lookupdir = $self->{'lookup_dir'};
  my $statusdir = $self->{'status_dir'};
  my $endpoint = $self->{'endpoint'};
  my $callback = $self->{'callback'};
  my $stime = $self->{'stime'};
  my $etime = $self->{'etime'};
  my ($url, $ac, $sc, $msisdn, $txnid, $akey, $skey, $charge, $identifier, $message, $response, $service, $txntype, $code, $error, $status, $time, $cpid, $cpuid, $cppass) = '';

  print "running watcher: $lookupdir\n";
  while (1)
  { # loop
    $time = $self->get_date("%H%M%S");
    next if ($stime && $stime>=$time);
    next if ($etime && $etime<=$time);

    opendir(my $dh, $lookupdir) || die "can't opendir $lookupdir: $!";
    while (my $file = readdir $dh)
    {
      next if ($file =~ /^\./);
      print "$lookupdir/$file\n";
      open (my $fh, '<', "$lookupdir/$file") or die "can't open < $lookupdir/$file: $!";
      while (my $data = <$fh>)
      {
        chomp $data;
        print "$data\n";
        next if (!$data);

        ($ac, $sc, $msisdn, $txnid, $akey, $skey, $cpid, $cpuid, $cppass, $charge, $identifier, $message) = split(/\|/, $data, 12);
        ($service, $txntype) = split(/\:/, $identifier, 2);

        $url = "$endpoint?CSP_Txid=$txnid&CP_Id=$cpid&CP_UserId=$cpuid&CP_Password=$cppass&SUB_R_Mobtel=$msisdn&SUB_C_Mobtel=$msisdn&SMS_MsgTxt=$message&SMS_Msgdata=&SMS_SourceAddr=$ac&ShortCode=$ac&SUB_DeviceType=NOKIA2100&SUB_Device_Details=&CSP_ContentType=TM&CSP_A_Keyword=$akey&CSP_S_Keyword=$skey&CSP_ChargeIndicator=$charge&CSP_Remarks=";
        print "$url\n";

        $response = $ua->get($url);
        ($code, $error) = split(/\s+/, $response->status_line, 2);
        $status = 'failed';
        $status = 'success' if ($response->is_success);
        print "$status: ".$response->status_line."\n";  # or whatever
        $self->log_watchers($msisdn, $ac, $service, $data, $url, "$code $error");

        $self->dump_status($data, $code, $error) if ($statusdir);

        next if (!$callback); # submit to status
        $url = "$callback?ERRORCODE=$code&CSP_Txid=$txnid";
        print "$url\n";

        $response = $ua->get($url);
        ($code, $error) = split(/\s+/, $response->status_line, 2);
        $status = 'failed';
        $status = 'success' if ($response->is_success);
        print "$status: ".$response->status_line."\n";  # or whatever
        $self->log_watchers($msisdn, $ac, $service, $data, $url, "$code $error");

      }
      close $fh;
      unlink "$lookupdir/$file";
    }
    closedir $dh;
    sleep 1;
  }
}

sub process_ultra
{
  my ($self) = @_;
  use LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  $ua->env_proxy;

  my $lookupdir = $self->{'lookup_dir'};
  my $statusdir = $self->{'status_dir'};
  my $endpoint = $self->{'endpoint'};
  my $callback = $self->{'callback'};
  my $stime = $self->{'stime'};
  my $etime = $self->{'etime'};
  my ($url, $ac, $sc, $msisdn, $txnid, $akey, $skey, $charge, $identifier, $message, $response, $service, $txntype, $code, $error, $status, $params, $datetime, $time, $cpid, $cpuid, $cppass) = '';

  print "running watcher ultra: $lookupdir\n";
  while (1)
  { # loop
    $time = $self->get_date("%H%M%S");
    next if ($stime && $stime>=$time);
    next if ($etime && $etime<=$time);

    opendir(my $dh, $lookupdir) || die "can't opendir $lookupdir: $!";
    while (my $file = readdir $dh)
    {
      next if ($file =~ /^\./);
      print "$lookupdir/$file\n";
      open (my $fh, '<', "$lookupdir/$file") or die "can't open < $lookupdir/$file: $!";
      while (my $data = <$fh>)
      {
        chomp $data;
        print "$data\n";
        next if (!$data);

        ($ac, $sc, $msisdn, $txnid, $akey, $skey, $cpid, $cpuid, $cppass, $charge, $identifier, $message) = split(/\|/, $data, 12);
        ($service, $txntype) = split(/\:/, $identifier, 2);

        $url = "$endpoint?CSP_Txid=$txnid&CP_Id=$cpid&CP_UserId=$cpuid&CP_Password=$cppass&SUB_R_Mobtel=$msisdn&CSP_A_Keyword=$akey&SUB_C_Mobtel=$msisdn&SMS_MsgTxt=&SMS_SourceAddr=$ac&ShortCode=$sc&CSP_S_Keyword=&SUB_DeviceType=NOKIA2100&SMS_Msgdata=&SUB_Device_Details=&CSP_ContentType=TM&CSP_ChargeIndicator=$charge&CSP_Remarks=";
        print "$url\n";

        $response = $ua->get($url);
        ($code, $error) = split(/\s+/, $response->status_line, 2);
        $status = 'failed';
        $status = 'success' if ($response->is_success);
        print "$status: ".$response->status_line."\n";  # or whatever
        $self->log_watchers($msisdn, $ac, $service, $data, $url, "$code $error");

        $self->dump_status($data, $code, $error) if ($statusdir);

        next if (!$callback); # submit to status
        $datetime = $self->get_date("%Y%m%d%H%M%S");
        $params = "type=0&status_code=0";
        $params = "type=1&status_code=1" if ($status eq 'failed');
        $params .= "&transid=$txnid&msisdn=$msisdn&status_message=$error&mdp_rcvd=$datetime&ctype=0";

        $url = "$callback?$params";
        print "$url\n";

        $response = $ua->get($url);
        ($code, $error) = split(/\s+/, $response->status_line, 2);
        $status = 'failed';
        $status = 'success' if ($response->is_success);
        print "$status: ".$response->status_line."\n";  # or whatever
        $self->log_watchers($msisdn, $ac, $service, $data, $url, "$code $error");

      }
      close $fh;
      unlink "$lookupdir/$file";
    }
    closedir $dh;
    sleep 1;
  }
}

sub process_silent
{
  my ($self) = @_;
  use LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  $ua->env_proxy;

  my $lookupdir = $self->{'lookup_dir'};
  my $statusdir = $self->{'status_dir'};
  my $endpoint = $self->{'endpoint'};
  my $callback = $self->{'callback'};
  my $stime = $self->{'stime'};
  my $etime = $self->{'etime'};
  my ($url, $ac, $sc, $msisdn, $txnid, $akey, $skey, $charge, $identifier, $message, $response, $service, $txntype, $code, $error, $status, $params, $datetime, $time, $cpid, $cpuid, $cppass) = '';

  print "running watcher silent: $lookupdir\n";
  while (1)
  { # loop
    $time = $self->get_date("%H%M%S");
    next if ($stime && $stime>=$time);
    next if ($etime && $etime<=$time);

    opendir(my $dh, $lookupdir) || die "can't opendir $lookupdir: $!";
    while (my $file = readdir $dh)
    {
      next if ($file =~ /^\./);
      print "$lookupdir/$file\n";
      open (my $fh, '<', "$lookupdir/$file") or die "can't open < $lookupdir/$file: $!";
      while (my $data = <$fh>)
      {
        chomp $data;
        print "$data\n";
        next if (!$data);

        ($ac, $sc, $msisdn, $txnid, $akey, $skey, $cpid, $cpuid, $cppass, $charge, $identifier, $message) = split(/\|/, $data, 12);
        ($service, $txntype) = split(/\:/, $identifier, 2);

        $url = "$endpoint?CSP_Txid=$txnid&CP_Id=$cpid&CP_UserId=$cpuid&CP_Password=$cppass&SUB_R_Mobtel=$msisdn&CSP_A_Keyword=$akey&SUB_C_Mobtel=$msisdn&SMS_MsgTxt=&SMS_SourceAddr=$ac&ShortCode=$sc&CSP_S_Keyword=&SUB_DeviceType=NOKIA2100&SMS_Msgdata=&SUB_Device_Details=&CSP_ContentType=TM&CSP_ChargeIndicator=$charge&CSP_Remarks=";
        print "$url\n";

        $response = $ua->get($url);
        ($code, $error) = split(/\s+/, $response->status_line, 2);
        $status = 'failed';
        $status = 'success' if ($response->is_success);
        print "$status: ".$response->status_line."\n";  # or whatever
        $self->log_watchers($msisdn, $ac, $service, $data, $url, "$code $error");

        $self->dump_status($data, $code, $error) if ($statusdir);

        next if (!$callback); # submit to status
        $datetime = $self->get_date("%Y%m%d%H%M%S");
        $params = "type=0&status_code=0";
        $params = "type=1&status_code=1" if ($status eq 'failed');
        $params .= "&transid=$txnid&msisdn=$msisdn&status_message=$error&mdp_rcvd=$datetime&ctype=0";

        $url = "$callback?$params";
        print "$url\n";

        $response = $ua->get($url);
        ($code, $error) = split(/\s+/, $response->status_line, 2);
        $status = 'failed';
        $status = 'success' if ($response->is_success);
        print "$status: ".$response->status_line."\n";  # or whatever
        $self->log_watchers($msisdn, $ac, $service, $data, $url, "$code $error");

      }
      close $fh;
      unlink "$lookupdir/$file";
    }
    closedir $dh;
    sleep 1;
  }
}

sub process_kannel
{
  my ($self) = @_;
  use LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  $ua->env_proxy;

  my $lookupdir = $self->{'lookup_dir'};
  my $statusdir = $self->{'status_dir'};
  my $endpoint = $self->{'endpoint'};
  my $callback = $self->{'callback'};
  my $stime = $self->{'stime'};
  my $etime = $self->{'etime'};
  my ($url, $ac, $sc, $msisdn, $txnid, $akey, $skey, $charge, $identifier, $message, $response, $service, $txntype, $code, $error, $status, $params, $datetime, $time, $cpid, $cpuid, $cppass) = '';

  print "running watcher kannel: $lookupdir\n";
  while (1)
  { # loop
    $time = $self->get_date("%H%M%S");
    next if ($stime && $stime>=$time);
    next if ($etime && $etime<=$time);

    opendir(my $dh, $lookupdir) || die "can't opendir $lookupdir: $!";
    while (my $file = readdir $dh)
    {
      next if ($file =~ /^\./);
      print "$lookupdir/$file\n";
      open (my $fh, '<', "$lookupdir/$file") or die "can't open < $lookupdir/$file: $!";
      while (my $data = <$fh>)
      {
        chomp $data;
        print "$data\n";
        next if (!$data);

        print "$data\n";
        ($ac, $sc, $msisdn, $txnid, $akey, $skey, $cpid, $cpuid, $cppass, $charge, $identifier, $message) = split(/\|/, $data, 12);
        ($service, $txntype) = split(/\:/, $identifier, 2);

        $url = "$endpoint?username=tester&password=foobar&from=$ac&to=0$msisdn&text=$message&dlr-mask=8&dlr-url=http%3A%2F%2Flocalhost%2Fdmp%2Fprocess%2Fapi%2Fstatus.php%3Ftype%3D2%26transid%3D$txnid%26msisdn%3D$msisdn%26status_code%3D0%26status_message%3DOK%26mdp_rcvd%3D$datetime%26ctype%3D1";
        print "$url\n";

        $response = $ua->get($url);
        ($code, $error) = split(/\s+/, $response->status_line, 2);
        $status = 'failed';
        $status = 'success' if ($response->is_success);
        print "$status: ".$response->status_line."\n";  # or whatever
        $self->log_watchers($msisdn, $ac, $service, $data, $url, "$code $error");

        $self->dump_status($data, $code, $error) if ($statusdir);

        next if (!$callback); # submit to status
        $datetime = $self->get_date("%Y%m%d%H%M%S");
        $params = "type=0&status_code=0";
        $params = "type=1&status_code=1" if ($status eq 'failed');
        $params .= "&transid=$txnid&msisdn=$msisdn&status_message=$error&mdp_rcvd=$datetime&ctype=0";

        $url = "$callback?$params";
        print "$url\n";

        $response = $ua->get($url);
        ($code, $error) = split(/\s+/, $response->status_line, 2);
        $status = 'failed';
        $status = 'success' if ($response->is_success);
        print "$status: ".$response->status_line."\n";  # or whatever
        $self->log_watchers($msisdn, $ac, $service, $data, $url, "$code $error");

      }
      close $fh;
      unlink "$lookupdir/$file";
    }
    closedir $dh;
    sleep 1;
  }
}

sub process_status
{
  my ($self) = @_;
  use LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  $ua->env_proxy;

#  use lib '/home/xavier/apps/2684/ikonek';
#  use ikonek;
#  use base 'Exporter';
#  our @EXPORT = qw(ikonek_status);
#  require '/home/xavier/apps/2684/ikonek/ikonek-app.pl';

  my $lookupdir = $self->{'lookup_dir'};
  my $statusdir = $self->{'status_dir'};
  my $endpoint = $self->{'endpoint'};
  my $callback = $self->{'callback'};
  my $stime = $self->{'stime'};
  my $etime = $self->{'etime'};
  my ($url, $ac, $sc, $msisdn, $txnid, $akey, $skey, $charge, $identifier, $message, $response, $service, $txntype, $code, $error, $status, $params, $datetime, $time, $cpid, $cpuid, $cppass, $function) = '';

  print "running watcher status: $lookupdir\n";
  while (1)
  { # loop
    $time = $self->get_date("%H%M%S");
    next if ($stime && $stime>=$time);
    next if ($etime && $etime<=$time);

    opendir(my $dh, $lookupdir) || die "can't opendir $lookupdir: $!";
    while (my $file = readdir $dh)
    {
      next if ($file =~ /^\./);
      print "$lookupdir/$file\n";
      open (my $fh, '<', "$lookupdir/$file") or die "can't open < $lookupdir/$file: $!";
      while (my $data = <$fh>)
      {
        chomp $data;
        print "$data\n";
        next if (!$data);

        ($ac, $sc, $msisdn, $txnid, $akey, $skey, $charge, $identifier, $code, $error) = split(/\|/, $data, 10);
        ($service, $txntype) = split(/\:/, $identifier, 2);

        $function = $self->{$service};
        $self->log_watchers($msisdn, $ac, $service, $data, $function, "$code $error");

        print "$function: $msisdn, $ac, $service, $data, $function, $code $error\n";
        next if (!$function);
        &{\&$function}($msisdn, $txntype, $code, $error, $data, $file);
#        ikonek_status($msisdn, $txntype, $code, $error, $data, $file);
      }
      close $fh;
      unlink "$lookupdir/$file";
    }
    closedir $dh;
    sleep 1;
  }
}

sub get_trans_id
{
  my ($self, $prefix, $suffix, $delim) = @_;
  my $txnid = time().(10+int(rand(90))); # strftime "%Y%m%d%H%M%S", localtime;
  $delim = '' if (!$delim);
  $txnid = $prefix.$delim.$txnid if ($prefix);
  $txnid = $txnid.$delim.$suffix if ($suffix);
  return $txnid;
}

sub get_date
{
  use POSIX qw(strftime);
  my ($self, $format) = @_;
  $format = "%Y-%m-%d %H:%M:%S" if (!$format);
  my $date = strftime $format, localtime;
  return $date;
}

sub log_watchers
{
  my ($self, $msisdn, $ac, $service, $data, $url, $response) = @_;
  my $logdir = $self->{'watchers_log'};
  my $logfile = $self->get_date('%Y%m%d');
  my $logdate = $self->get_date();

  my $logpath = "$logdir/$logfile-$ac-watchers.log";
  my $logdata = "$logdate -- $msisdn -- $service -- $data --> $url -- $response";
  open(my $fh, '>>', $logpath) or die "Could not open file '$logpath' $!";
  print $fh "$logdata\n";
  close $fh;
}

sub log_status
{
  my ($self, $msisdn, $ac, $service, $data, $filepath) = @_;
  my $logdir = $self->{'watchers_log'};
  my $logfile = $self->get_date('%Y%m%d');
  my $logdate = $self->get_date();

  my $logpath = "$logdir/$logfile-$ac-watchers.log";
  my $logdata = "$logdate -- $msisdn -- $service -- $data <-- $filepath";
  open(my $fh, '>>', $logpath) or die "Could not open file '$logpath' $!";
  print $fh "$logdata\n";
  close $fh;
}

sub dump_status
{
  my ($self, $data, $code, $error) = @_;
  my ($ac, $sc, $msisdn, $txnid, $akey, $skey, $charge, $identifier, $message, $service, $txntype, $cpid, $cpuid, $cppass) = '';
  my $filedir = $self->{'status_dir'};

  ($ac, $sc, $msisdn, $txnid, $akey, $skey, $cpid, $cpuid, $cppass, $charge, $identifier, $message) = split(/\|/, $data, 12);
  ($service, $txntype) = split(/\:/, $identifier, 2);

  my $fileid = $self->get_trans_id($service.".".$msisdn);
  my $filedata = "$ac|$sc|$msisdn|$txnid|$akey|$skey|$charge|$identifier|$code|$error";
  my $filepath = "$filedir/$fileid.txt";
  my $tfilepath = "$filedir/.$fileid.txt";

  chomp $filedata;
  print "$filedata --> $filepath\n";
  $self->log_status($msisdn, $ac, $service, $filedata, $filepath);

  open(my $fh, '>', $tfilepath) or die "Could not open file '$tfilepath' $!";
  print $fh "$filedata\n";
  close $fh;

  use File::Copy qw(move);
  move $tfilepath, $filepath;
}




1;