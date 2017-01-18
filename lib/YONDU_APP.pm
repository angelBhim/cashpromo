#!/usr/bin/perl

use strict;
use warnings;

package YONDU_APP;

sub new
{
  my $class = shift;
  my $self = {};
  bless $self, $class;
  $self->{'debug'} = 0;
  $self->{'cp'}{'id'} = 'egg';
  $self->{'cp'}{'uid'} = 'egg';
  $self->{'cp'}{'pass'} = '3Jgiyk4J';
  return $self;
}

sub set_debug
{
  my ($self, $debug) = @_;
  $self->{'debug'} = $debug;
  return $self;
}

sub set_cp_login
{
  my ($self, $id, $uid, $pass) = @_;
  $self->{'cp'}{'id'} = $id;
  $self->{'cp'}{'uid'} = $uid;
  $self->{'cp'}{'pass'} = $pass;
  return $self;
}

sub set_service
{

  my ($self, $service, $serviceid) = @_;
  $self->{'service'}{'name'} = $service;
  $self->{'service'}{'id'} = $serviceid;
  return $self;
}

sub set_service_id
{
  my ($self, $service, $serviceid) = @_;
  $self->{'service'}{$service} = $serviceid;
  return $self;
}

sub set_config
{
  my ($self, $type, $ac, $akey, $skey, $filedir, $sc, $charge, $trans, $mtype) = @_;
  $self->{'config'}{$type}{'ac'} = $ac;
  $self->{'config'}{$type}{'sc'} = $sc;
  $self->{'config'}{$type}{'akey'} = $akey;
  $self->{'config'}{$type}{'skey'} = $skey;
  $self->{'config'}{$type}{'charge'} = $charge;
  $self->{'config'}{$type}{'trans'} = $trans;
  $self->{'config'}{$type}{'mtype'} = $mtype;
  $self->{'config'}{$type}{'filedir'} = $filedir;
  mkdir $filedir;
  return $self;
}

sub set_reply
{
  my ($self, $type, $message) = @_;
  $self->{'replies'}{$type} = $message;
  return $self;
}

sub set_apps_log
{
  my ($self, $logdir) = @_;
  mkdir $logdir;
  $self->{'apps_log'} = $logdir;
  return $self;
}

sub set_trans_log
{
  my ($self, $logdir) = @_;
  mkdir $logdir;
  $self->{'trans_log'} = $logdir;
  return $self;
}

sub get_service_id
{
  my ($self, $service) = @_;
  return $self->{'service'}{$service};
}

sub send_sms
{
  my ($self, $msisdn, $type, $identifier, $message) = @_;
  my $sid = $self->{'service'}{'id'};
  my $service = $self->{'service'}{'name'};

  my $cpid = $self->{'cp'}{'id'};
  my $cpuid = $self->{'cp'}{'uid'};
  my $cppass = $self->{'cp'}{'pass'};

  my $ac = $self->{'config'}{$type}{'ac'};
  my $sc = $self->{'config'}{$type}{'sc'};
  my $akey = $self->{'config'}{$type}{'akey'};
  my $skey = $self->{'config'}{$type}{'skey'};
  my $charge = $self->{'config'}{$type}{'charge'};
  my $trans = $self->{'config'}{$type}{'trans'};
  my $filedir = $self->{'config'}{$type}{'filedir'};
  chomp $message;

  my $txnid = $self->get_trans_id("$service.$identifier.$msisdn", "", ".");
  my $fileid = $self->get_trans_id($service.".".$msisdn);
  my $filedata = "$ac|$sc|$msisdn|$txnid|$akey|$skey|$cpid|$cpuid|$cppass|$charge|$service:$identifier|$message";
  my $filepath = "$filedir/$fileid.txt";
  chomp $filedata;

  if ($self->{'debug'}) {
    print "$filedata\n";
  }
  else {
    print "$filedata --> $filepath\n";
    $self->log_apps($msisdn, $filedata, $filepath);

    open(my $fh, '>', $tfilepath) or die "Could not open file '$tfilepath' $!";
    print $fh "$filedata\n";
    close $fh;

    use File::Copy qw(move);
    move $tfilepath, $filepath;
  }
}

sub send_charging
{
  my ($self, $msisdn, $type, $identifier) = @_;
  my $sid = $self->{'service'}{'id'};
  my $service = $self->{'service'}{'name'};

  my $cpid = $self->{'cp'}{'id'};
  my $cpuid = $self->{'cp'}{'uid'};
  my $cppass = $self->{'cp'}{'pass'};

  my $ac = $self->{'config'}{$type}{'ac'};
  my $akey = $self->{'config'}{$type}{'akey'};
  my $charge = $self->{'config'}{$type}{'charge'};
  my $trans = $self->{'config'}{$type}{'trans'};
  my $filedir = $self->{'config'}{$type}{'filedir'};

  my $txnid = $self->get_trans_id($service.".".$identifier.".".$msisdn, "", ".");
  my $fileid = $self->get_trans_id($service.".".$msisdn);
  my $filedata = "$ac|1|$msisdn|$txnid|$akey||$cpid|$cpuid|$cppass|$charge|$service:$identifier|";
  my $filepath = "$filedir/$fileid.txt";
  my $tfilepath = "$filedir/.$fileid.txt";
  chomp $filedata;

  if ($self->{'debug'}) {
    print "$filedata\n";
  }
  else {
    print "$filedata --> $filepath\n";
    $self->log_apps($msisdn, $filedata, $filepath);

    open(my $fh, '>', $tfilepath) or die "Could not open file '$tfilepath' $!";
    print $fh "$filedata\n";
    close $fh;

    use File::Copy qw(move);
    move $tfilepath, $filepath;
  }
}

sub send_sms_dmp
{
  my ($self, $msisdn, $type, $identifier, $message) = @_;
  my $sid = $self->{'service'}{'id'};
  my $service = $self->{'service'}{'name'};

  my $cpid = $self->{'cp'}{'id'};
  my $cpuid = $self->{'cp'}{'uid'};
  my $cppass = $self->{'cp'}{'pass'};

  my $ac = $self->{'config'}{$type}{'ac'};
  my $sc = $self->{'config'}{$type}{'sc'};
  my $akey = $self->{'config'}{$type}{'akey'};
  my $skey = $self->{'config'}{$type}{'skey'};
  my $charge = $self->{'config'}{$type}{'charge'};
  my $trans = $self->{'config'}{$type}{'trans'};
  my $mtype = $self->{'config'}{$type}{'mtype'};
  my $filedir = $self->{'config'}{$type}{'filedir'};
  chomp $message;

  $sid = $self->get_pre_zeroes($sid, 4);
  my $txnid = $self->get_trans_id($trans.$sid.$msisdn, $mtype);
  my $fileid = $self->get_trans_id("$service.$msisdn");
  my $filedata = "$ac|$sc|$msisdn|$txnid|$akey|$skey|$cpid|$cpuid|$cppass|$charge|$service:$identifier|$message";
  my $filepath = "$filedir/$fileid.txt";
  my $tfilepath = "$filedir/.$fileid.txt";
  chomp $filedata;

  if ($self->{'debug'}) {
    print "$filedata\n";
  }
  else {
    print "$filedata --> $filepath\n";
    $self->log_apps($msisdn, $filedata, $filepath);

    open(my $fh, '>', $tfilepath) or die "Could not open file '$tfilepath' $!";
    print $fh "$filedata\n";
    close $fh;

    use File::Copy qw(move);
    move $tfilepath, $filepath;
  }
}

sub send_charging_dmp
{
  my ($self, $msisdn, $type, $identifier) = @_;
  my $sid = $self->{'service'}{'id'};
  my $service = $self->{'service'}{'name'};

  my $cpid = $self->{'cp'}{'id'};
  my $cpuid = $self->{'cp'}{'uid'};
  my $cppass = $self->{'cp'}{'pass'};

  my $ac = $self->{'config'}{$type}{'ac'};
  my $akey = $self->{'config'}{$type}{'akey'};
  my $charge = $self->{'config'}{$type}{'charge'};
  my $trans = $self->{'config'}{$type}{'trans'};
  my $mtype = $self->{'config'}{$type}{'mtype'};
  my $filedir = $self->{'config'}{$type}{'filedir'};

  $sid = $self->get_pre_zeroes($sid, 4);
  my $txnid = $self->get_trans_id($trans.$sid.$msisdn, $mtype);
  my $fileid = $self->get_trans_id($service.".".$msisdn);
  my $filedata = "$ac|1|$msisdn|$txnid|$akey||$cpid|$cpuid|$cppass|$charge|$service:$identifier|";
  my $filepath = "$filedir/$fileid.txt";
  my $tfilepath = "$filedir/.$fileid.txt";
  chomp $filedata;

  if ($self->{'debug'}) {
    print "$filedata\n";
  }  
  else {
    print "$filedata --> $filepath\n";
    $self->log_apps($msisdn, $filedata, $filepath);

    open(my $fh, '>', $tfilepath) or die "Could not open file '$tfilepath' $!";
    print $fh "$filedata\n";
    close $fh;

    use File::Copy qw(move);
    move $tfilepath, $filepath;
  }
}

sub send_sms_notif
{
  my ($self, $msisdn, $type, $identifier, $total, $message) = @_;
  my $sid = $self->{'service'}{'id'};
  my $service = $self->{'service'}{'name'};

  my $ac = $self->{'config'}{$type}{'ac'};
  my $sc = $self->{'config'}{$type}{'sc'};
  my $akey = $self->{'config'}{$type}{'akey'};
  my $skey = $self->{'config'}{$type}{'skey'};
  my $charge = $self->{'config'}{$type}{'charge'};
  my $trans = $self->{'config'}{$type}{'trans'};
  my $filedir = $self->{'config'}{$type}{'filedir'};
  chomp $message;
  $message .= "\btotal: $total\bidentifier: $identifier";

  my $txnid = $self->get_trans_id("$service.$identifier.$msisdn", "", ".");
  my $fileid = $self->get_trans_id($service.".".$msisdn);
  my $filedata = "$ac|$sc|$msisdn|$txnid|$akey|$skey|$charge|$service:$identifier|$message";
  my $filepath = "$filedir/$fileid.txt";
  my $tfilepath = "$filedir/.$fileid.txt";

  chomp $filedata;
  print "$filedata --> $filepath\n";
  $self->log_apps($msisdn, $filedata, $filepath);

  open(my $fh, '>', $tfilepath) or die "Could not open file '$tfilepath' $!";
  print $fh "$filedata\n";
  close $fh;

  use File::Copy qw(move);
  move $tfilepath, $filepath;
}

sub get_pre_zeroes
{
  my ($self, $num, $len) = @_;
  $num = '0'.$num while (length($num)<$len);
  return $num;
}

sub get_trans_id
{
  # use POSIX qw(strftime);
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

sub log_apps
{
  my ($self, $msisdn, $filedata, $filepath) = @_;
  my $service = $self->{'service'}{'name'};
  my $logdir = $self->{'apps_log'};
  my $logfile = $self->get_date('%Y%m%d');
  my $logdate = $self->get_date();

  my $logpath = "$logdir/$logfile-$service-apps.log";
  my $logdata = "$logdate -- $msisdn -- $filedata --> $filepath";
  open(my $fh, '>>', $logpath) or die "Could not open file '$logpath' $!";
  print $fh "$logdata\n";
  close $fh;
}

sub log_trans
{
  my ($self, $msisdn, $filedata, $filepath) = @_;
  my $service = $self->{'service'}{'name'};
  my $logdir = $self->{'trans_log'};
  my $logfile = $self->get_date('%Y%m%d');
  my $logdate = $self->get_date();

  my $logpath = "$logdir/$logfile-$service-trans.log";
  my $logdata = "$logdate -- $msisdn -- $filedata <-- $filepath";
  open(my $fh, '>>', $logpath) or die "Could not open file '$logpath' $!";
  print $fh "$logdata\n";
  close $fh;
}



1;
