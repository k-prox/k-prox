#########################################################################################
# Package        HiPi::Graphics::Font5x7
# Copyright    : Perl Port Copyright (c) 2018 Mark Dootson
# License      : This is free software; you can redistribute it and/or modify it under
#                the same terms as the Perl 5 programming language system itself.
#
#########################################################################################

package HiPi::Graphics::Font5x7;

#########################################################################################
use strict;
use warnings;
use parent qw( Exporter );

our $VERSION ='0.81';

our @EXPORT_OK = qw(  font_5_x_7  );

our %EXPORT_TAGS = ( font => \@EXPORT_OK );

# 5x7 Font
my $font5x7 = {
    '32' => [0x00, 0x00, 0x00, 0x00, 0x00], # (space)
    '33' => [0x00, 0x00, 0x5f, 0x00, 0x00], # !
    '34' => [0x00, 0x07, 0x00, 0x07, 0x00], # "
    '35' => [0x14, 0x7f, 0x14, 0x7f, 0x14], # # 
    '36' => [0x24, 0x2a, 0x7f, 0x2a, 0x12], # $
    '37' => [0x23, 0x13, 0x08, 0x64, 0x62], # %
    '38' => [0x36, 0x49, 0x55, 0x22, 0x50], # &
    '39' => [0x00, 0x05, 0x03, 0x00, 0x00], # '
    '40' => [0x00, 0x1c, 0x22, 0x41, 0x00], # (
    '41' => [0x00, 0x41, 0x22, 0x1c, 0x00], # )
    '42' => [0x08, 0x2a, 0x1c, 0x2a, 0x08], # *
    '43' => [0x08, 0x08, 0x3e, 0x08, 0x08], # +
    '44' => [0x00, 0x50, 0x30, 0x00, 0x00], # ,
    '45' => [0x08, 0x08, 0x08, 0x08, 0x08], # -
    '46' => [0x00, 0x60, 0x60, 0x00, 0x00], # .
    '47' => [0x20, 0x10, 0x08, 0x04, 0x02], # /
    '48' => [0x3e, 0x51, 0x49, 0x45, 0x3e], # 0
    '49' => [0x00, 0x42, 0x7f, 0x40, 0x00], # 1
    '50' => [0x42, 0x61, 0x51, 0x49, 0x46], # 2
    '51' => [0x21, 0x41, 0x45, 0x4b, 0x31], # 3
    '52' => [0x18, 0x14, 0x12, 0x7f, 0x10], # 4
    '53' => [0x27, 0x45, 0x45, 0x45, 0x39], # 5
    '54' => [0x3c, 0x4a, 0x49, 0x49, 0x30], # 6
    '55' => [0x01, 0x71, 0x09, 0x05, 0x03], # 7
    '56' => [0x36, 0x49, 0x49, 0x49, 0x36], # 8
    '57' => [0x06, 0x49, 0x49, 0x29, 0x1e], # 9
    '58' => [0x00, 0x36, 0x36, 0x00, 0x00], # :
    '59' => [0x00, 0x56, 0x36, 0x00, 0x00], # ;
    '60' => [0x00, 0x08, 0x14, 0x22, 0x41], # <
    '61' => [0x14, 0x14, 0x14, 0x14, 0x14], # =
    '62' => [0x41, 0x22, 0x14, 0x08, 0x00], # >
    '63' => [0x02, 0x01, 0x51, 0x09, 0x06], # ?
    '64' => [0x32, 0x49, 0x79, 0x41, 0x3e], # @
    '65' => [0x7e, 0x11, 0x11, 0x11, 0x7e], # A
    '66' => [0x7f, 0x49, 0x49, 0x49, 0x36], # B
    '67' => [0x3e, 0x41, 0x41, 0x41, 0x22], # C
    '68' => [0x7f, 0x41, 0x41, 0x22, 0x1c], # D
    '69' => [0x7f, 0x49, 0x49, 0x49, 0x41], # E
    '70' => [0x7f, 0x09, 0x09, 0x01, 0x01], # F
    '71' => [0x3e, 0x41, 0x41, 0x51, 0x32], # G
    '72' => [0x7f, 0x08, 0x08, 0x08, 0x7f], # H
    '73' => [0x00, 0x41, 0x7f, 0x41, 0x00], # I
    '74' => [0x20, 0x40, 0x41, 0x3f, 0x01], # J
    '75' => [0x7f, 0x08, 0x14, 0x22, 0x41], # K
    '76' => [0x7f, 0x40, 0x40, 0x40, 0x40], # L
    '77' => [0x7f, 0x02, 0x04, 0x02, 0x7f], # M
    '78' => [0x7f, 0x04, 0x08, 0x10, 0x7f], # N
    '79' => [0x3e, 0x41, 0x41, 0x41, 0x3e], # O
    '80' => [0x7f, 0x09, 0x09, 0x09, 0x06], # P
    '81' => [0x3e, 0x41, 0x51, 0x21, 0x5e], # Q
    '82' => [0x7f, 0x09, 0x19, 0x29, 0x46], # R
    '83' => [0x46, 0x49, 0x49, 0x49, 0x31], # S
    '84' => [0x01, 0x01, 0x7f, 0x01, 0x01], # T
    '85' => [0x3f, 0x40, 0x40, 0x40, 0x3f], # U
    '86' => [0x1f, 0x20, 0x40, 0x20, 0x1f], # V
    '87' => [0x7f, 0x20, 0x18, 0x20, 0x7f], # W
    '88' => [0x63, 0x14, 0x08, 0x14, 0x63], # X
    '89' => [0x03, 0x04, 0x78, 0x04, 0x03], # Y
    '90' => [0x61, 0x51, 0x49, 0x45, 0x43], # Z
    '91' => [0x00, 0x00, 0x7f, 0x41, 0x41], # [
    '92' => [0x02, 0x04, 0x08, 0x10, 0x20], # \
    '93' => [0x41, 0x41, 0x7f, 0x00, 0x00], # ]
    '94' => [0x04, 0x02, 0x01, 0x02, 0x04], # ^
    '95' => [0x40, 0x40, 0x40, 0x40, 0x40], # _
    '96' => [0x00, 0x01, 0x02, 0x04, 0x00], # `
    '97' => [0x20, 0x54, 0x54, 0x54, 0x78], # a
    '98' => [0x7f, 0x48, 0x44, 0x44, 0x38], # b
    '99' => [0x38, 0x44, 0x44, 0x44, 0x20], # c
    '100' => [0x38, 0x44, 0x44, 0x48, 0x7f], # d
    '101' => [0x38, 0x54, 0x54, 0x54, 0x18], # e
    '102' => [0x08, 0x7e, 0x09, 0x01, 0x02], # f
    '103' => [0x08, 0x14, 0x54, 0x54, 0x3c], # g
    '104' => [0x7f, 0x08, 0x04, 0x04, 0x78], # h
    '105' => [0x00, 0x44, 0x7d, 0x40, 0x00], # i
    '106' => [0x20, 0x40, 0x44, 0x3d, 0x00], # j
    '107' => [0x00, 0x7f, 0x10, 0x28, 0x44], # k
    '108' => [0x00, 0x41, 0x7f, 0x40, 0x00], # l
    '109' => [0x7c, 0x04, 0x18, 0x04, 0x78], # m
    '110' => [0x7c, 0x08, 0x04, 0x04, 0x78], # n
    '111' => [0x38, 0x44, 0x44, 0x44, 0x38], # o
    '112' => [0x7c, 0x14, 0x14, 0x14, 0x08], # p
    '113' => [0x08, 0x14, 0x14, 0x18, 0x7c], # q
    '114' => [0x7c, 0x08, 0x04, 0x04, 0x08], # r
    '115' => [0x48, 0x54, 0x54, 0x54, 0x20], # s
    '116' => [0x04, 0x3f, 0x44, 0x40, 0x20], # t
    '117' => [0x3c, 0x40, 0x40, 0x20, 0x7c], # u
    '118' => [0x1c, 0x20, 0x40, 0x20, 0x1c], # v
    '119' => [0x3c, 0x40, 0x30, 0x40, 0x3c], # w
    '120' => [0x44, 0x28, 0x10, 0x28, 0x44], # x
    '121' => [0x0c, 0x50, 0x50, 0x50, 0x3c], # y
    '122' => [0x44, 0x64, 0x54, 0x4c, 0x44], # z
    '123' => [0x00, 0x08, 0x36, 0x41, 0x00], # {
    '124' => [0x00, 0x00, 0x7f, 0x00, 0x00], # |
    '125' => [0x00, 0x41, 0x36, 0x08, 0x00], # }
    '126' => [0x08, 0x08, 0x2a, 0x1c, 0x08], # ~
};

sub font_5_x_7 { return $font5x7; }


1;

__END__