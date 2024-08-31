#!/usr/bin/perl

use Data::Dumper;
# sort keys
$Data::Dumper::Sortkeys = 1;
#use strict;

## buffer flush
#$|++;

use HiPi qw( :hilink );
use HiPi::Huawei::E3531;
use Getopt::Long;

my $pass    = "admin";
my $gw      = '192.168.8.1' ;
my $output  = "/dev/stdout";

GetOptions (
            "pass=s" => \$pass,
            "gw=s"      => \$gw,
            "output=s"  => \$output,
            )
or die("Error in command line arguments\n");

print "pass $pass, gw $gw\n";

my $hilink = HiPi::Huawei::E3531->new( 
    ip_address => $gw,
    timeout => 4,
    );

print "=> login\n";
my $response = $hilink->login('admin',$pass );
print Data::Dumper->Dump( [  \$response ] );

print "=> get_basic_info\n";
my $response = $hilink->get_basic_info();
print Data::Dumper->Dump( [  \$response ] );
#
#$response = $hilink->disconnect_modem();
#print Data::Dumper->Dump( [  \$response ] );
##

print "=> get_status\n";
my $response = $hilink->get_status();
print Data::Dumper->Dump( [  \$response ] );

print "=> get_device_info\n";
$response = $hilink->get_device_info();
print Data::Dumper->Dump( [  \$response ] );

# GET some resources in loop

foreach my $resource
    ((
    'api/wlan/basic-settings',
    'api/net/network',
    'api/net/net-mode-list',
    'api/net/net-mode',
    'api/device/signal',
    'api/net/current-plmn',
    'api/wlan/basic-settings',
    'api/monitoring/status', 
    'api/dialup/connection',
    ))
{
    print "=> $resource\n";
    my $response = $hilink->generic_get( $resource, $xml );
    print Data::Dumper->Dump( [  \$response ] );
}

### apn start
$resource='api/dialup/profiles';
    print "=> $resource\n";
    my $response = $hilink->generic_get( $resource, $xml );

$CurrentProfile=${response}->{CurrentProfile};
print "= detected CurrentProfile '$CurrentProfile'\n";

if ($CurrentProfile=~/\d+/)
    {
    print "=> Current APN settings\n";
    foreach $i (( @{ $response->{Profiles} } ))
        {
        if ($i->{Index}  eq $CurrentProfile)
            {
            print Data::Dumper->Dump( [ $i  ] );
            }
        }
    }

### apn end

print "=> logout\n";
$response = $hilink->logout();
print Data::Dumper->Dump( [  \$response ] );

