#!/usr/bin/perl
use strict;
use warnings;

use HiPi::Interface::MicroDotPHAT;

my $phat = HiPi::Interface::MicroDotPHAT->new();

print q(Scrolling Text
Scrolls a message across the screen.
Usage: scrolling_text.pl "your message"
Press Ctrl+C to exit.
);

my $text = $ARGV[0] || "Fifteen men on the dead man's chest       ";

$phat->write_string( $text );

$phat->show;

while (1) {
    $phat->scroll;
    $phat->show;
    $phat->sleep_milliseconds( 50 );
}


1;
