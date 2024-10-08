#########################################################################################
# Package       HiPi::Interface::ENER002
# Description:  compatibility
# Copyright    : Copyright (c) 2013-2017 Mark Dootson
# License      : This is free software; you can redistribute it and/or modify it under
#                the same terms as the Perl 5 programming language system itself.
#########################################################################################

package HiPi::Interface::ENER002;

#########################################################################################

use strict;
use warnings;

use parent qw( HiPi::Interface::EnergenieSwitch );

our $VERSION = '0.59';

sub new {
    my $class = shift;
    my $self = $class->SUPER::new( @_ );
    return $self;
}

1;

__END__
