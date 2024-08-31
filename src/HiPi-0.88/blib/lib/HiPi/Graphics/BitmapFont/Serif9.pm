#########################################################################################
# Package        HiPi::Graphics::BitmapFont::Serif9
# Description  : Monochrome OLED Font
# License      : This is free software; you can redistribute it and/or modify it under
#                the same terms as the Perl 5 programming language system itself.
#########################################################################################

package HiPi::Graphics::BitmapFont::Serif9;

#########################################################################################

use utf8;
use strict;
use warnings;
use parent qw( HiPi::Graphics::BitmapFont);

our $VERSION ='0.01';

my $gap_width = 0;
my $char_height = 9;
my $line_spacing = 0;
my $name = 'Serif 9';
my $space_width = 3;
 
my $symbols = {
    '33' => {    # '!'
        'width'    => 1, 
        'xoffset'  => 1, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x80, ##  0
            0x80, ##  0
            0x80, ##  0
            0x00, ##   
            0x80, ##  0
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '34' => {    # '"'
        'width'    => 2, 
        'xoffset'  => 1, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xC0, ##  00
            0xC0, ##  00
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '35' => {    # '#'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x50, ##   0 0 
            0xF8, ##  00000
            0x50, ##   0 0 
            0xF8, ##  00000
            0xA0, ##  0 0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '36' => {    # '$'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0  
            0x60, ##   00 
            0xD0, ##  00 0
            0xE0, ##  000 
            0x50, ##   0 0
            0xD0, ##  00 0
            0x60, ##   00 
            0x00, ##  
        ], 
    }, 
    '37' => {    # '%'
        'width'    => 7, 
        'xoffset'  => 1, 
        'xadvance' => 9, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xE0, ##  000    
            0xB8, ##  0 000  
            0x54, ##   0 0 0 
            0x2A, ##    0 0 0
            0x0E, ##      000
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '38' => {    # '&'
        'width'    => 6, 
        'xoffset'  => 1, 
        'xadvance' => 8, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x70, ##   000  
            0x4C, ##   0  00
            0xA8, ##  0 0 0 
            0x98, ##  0  00 
            0x78, ##   0000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '39' => {    # '''
        'width'    => 1, 
        'xoffset'  => 1, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x80, ##  0
            0x80, ##  0
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '40' => {    # '('
        'width'    => 2, 
        'xoffset'  => 1, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##    
            0xC0, ##  00
            0x80, ##  0 
            0x80, ##  0 
            0x80, ##  0 
            0x80, ##  0 
            0x40, ##   0
            0x00, ##  
        ], 
    }, 
    '41' => {    # ')'
        'width'    => 2, 
        'xoffset'  => 1, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##    
            0x80, ##  0 
            0x40, ##   0
            0x40, ##   0
            0x40, ##   0
            0x40, ##   0
            0x80, ##  0 
            0x00, ##  
        ], 
    }, 
    '42' => {    # '*'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x20, ##    0  
            0x70, ##   000 
            0xA8, ##  0 0 0
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '43' => {    # '+'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x20, ##    0  
            0x20, ##    0  
            0xF8, ##  00000
            0x20, ##    0  
            0x20, ##    0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '44' => {    # ','
        'width'    => 1, 
        'xoffset'  => 1, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x80, ##  0
            0x80, ##  0
            0x00, ##  
        ], 
    }, 
    '45' => {    # '-'
        'width'    => 2, 
        'xoffset'  => 0, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xC0, ##  00
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '46' => {    # '.'
        'width'    => 1, 
        'xoffset'  => 1, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x80, ##  0
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '47' => {    # '/'
        'width'    => 3, 
        'xoffset'  => 0, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x20, ##    0
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x80, ##  0  
            0x80, ##  0  
            0x00, ##  
        ], 
    }, 
    '48' => {    # '0'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x60, ##   00 
            0x90, ##  0  0
            0x90, ##  0  0
            0x90, ##  0  0
            0x60, ##   00 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '49' => {    # '1'
        'width'    => 3, 
        'xoffset'  => 1, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0 
            0xC0, ##  00 
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '50' => {    # '2'
        'width'    => 4, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xF0, ##  0000
            0x10, ##     0
            0x20, ##    0 
            0x40, ##   0  
            0xF0, ##  0000
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '51' => {    # '3'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xF0, ##  0000
            0x60, ##   00 
            0x10, ##     0
            0x10, ##     0
            0xE0, ##  000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '52' => {    # '4'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x20, ##    0 
            0x60, ##   00 
            0xA0, ##  0 0 
            0xA0, ##  0 0 
            0xF0, ##  0000
            0x20, ##    0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '53' => {    # '5'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xE0, ##  000 
            0xE0, ##  000 
            0x10, ##     0
            0x10, ##     0
            0xE0, ##  000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '54' => {    # '6'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x70, ##   000
            0xE0, ##  000 
            0x90, ##  0  0
            0x90, ##  0  0
            0x60, ##   00 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '55' => {    # '7'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xF0, ##  0000
            0x20, ##    0 
            0x20, ##    0 
            0x40, ##   0  
            0x40, ##   0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '56' => {    # '8'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xF0, ##  0000
            0x70, ##   000
            0xA0, ##  0 0 
            0x90, ##  0  0
            0x70, ##   000
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '57' => {    # '9'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xE0, ##  000 
            0x90, ##  0  0
            0x70, ##   000
            0x10, ##     0
            0xE0, ##  000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '58' => {    # ':'
        'width'    => 1, 
        'xoffset'  => 1, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x80, ##  0
            0x00, ##   
            0x80, ##  0
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '59' => {    # ';'
        'width'    => 1, 
        'xoffset'  => 1, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x80, ##  0
            0x00, ##   
            0x80, ##  0
            0x80, ##  0
            0x00, ##  
        ], 
    }, 
    '60' => {    # '<'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x38, ##    000
            0xC0, ##  00   
            0x60, ##   00  
            0x18, ##     00
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '61' => {    # '='
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xF8, ##  00000
            0x00, ##       
            0xF8, ##  00000
            0x00, ##  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '62' => {    # '>'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xE0, ##  000  
            0x18, ##     00
            0x30, ##    00 
            0xC0, ##  00   
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '63' => {    # '?'
        'width'    => 3, 
        'xoffset'  => 1, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xE0, ##  000
            0x20, ##    0
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '64' => {    # '@'
        'width'    => 7, 
        'xoffset'  => 1, 
        'xadvance' => 9, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x38, ##    000  
            0x5C, ##   0 000 
            0xAA, ##  0 0 0 0
            0xAA, ##  0 0 0 0
            0x9C, ##  0  000 
            0x40, ##   0     
            0x30, ##    00   
        ], 
    }, 
    '65' => {    # 'A'
        'width'    => 6, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x20, ##    0   
            0x50, ##   0 0  
            0x50, ##   0 0  
            0x78, ##   0000 
            0x88, ##  0   0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '66' => {    # 'B'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x78, ##   0000
            0x48, ##   0  0
            0x70, ##   000 
            0x48, ##   0  0
            0x78, ##   0000
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '67' => {    # 'C'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x78, ##   0000
            0x80, ##  0    
            0x80, ##  0    
            0x80, ##  0    
            0x78, ##   0000
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '68' => {    # 'D'
        'width'    => 6, 
        'xoffset'  => 0, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x78, ##   0000 
            0x44, ##   0   0
            0x44, ##   0   0
            0x44, ##   0   0
            0x78, ##   0000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '69' => {    # 'E'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x78, ##   0000
            0x40, ##   0   
            0x70, ##   000 
            0x40, ##   0   
            0x78, ##   0000
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '70' => {    # 'F'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x70, ##   000 
            0x48, ##   0  0
            0x78, ##   0000
            0x40, ##   0   
            0x40, ##   0   
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '71' => {    # 'G'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x78, ##   0000
            0x80, ##  0    
            0x98, ##  0  00
            0x88, ##  0   0
            0x78, ##   0000
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '72' => {    # 'H'
        'width'    => 7, 
        'xoffset'  => 0, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x44, ##   0   0 
            0x44, ##   0   0 
            0x7C, ##   00000 
            0x44, ##   0   0 
            0x44, ##   0   0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '73' => {    # 'I'
        'width'    => 3, 
        'xoffset'  => 0, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '74' => {    # 'J'
        'width'    => 4, 
        'xoffset'  => -1, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x20, ##    0 
            0x20, ##    0 
            0x20, ##    0 
            0x20, ##    0 
            0x20, ##    0 
            0x20, ##    0 
            0xE0, ##  000 
        ], 
    }, 
    '75' => {    # 'K'
        'width'    => 6, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x48, ##   0  0 
            0x50, ##   0 0  
            0x60, ##   00   
            0x50, ##   0 0  
            0x48, ##   0  0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '76' => {    # 'L'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x40, ##   0   
            0x40, ##   0   
            0x40, ##   0   
            0x40, ##   0   
            0x70, ##   000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '77' => {    # 'M'
        'width'    => 8, 
        'xoffset'  => 0, 
        'xadvance' => 8, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x62, ##   00   0 
            0x66, ##   00  00 
            0x5A, ##   0 00 0 
            0x5A, ##   0 00 0 
            0x42, ##   0    0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '78' => {    # 'N'
        'width'    => 7, 
        'xoffset'  => 0, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x64, ##   00  0 
            0x64, ##   00  0 
            0x54, ##   0 0 0 
            0x4C, ##   0  00 
            0x44, ##   0   0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '79' => {    # 'O'
        'width'    => 6, 
        'xoffset'  => 1, 
        'xadvance' => 8, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x78, ##   0000 
            0x84, ##  0    0
            0x84, ##  0    0
            0x84, ##  0    0
            0x78, ##   0000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '80' => {    # 'P'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x78, ##   0000
            0x48, ##   0  0
            0x70, ##   000 
            0x40, ##   0   
            0x40, ##   0   
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '81' => {    # 'Q'
        'width'    => 6, 
        'xoffset'  => 1, 
        'xadvance' => 8, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x78, ##   0000 
            0x84, ##  0    0
            0x84, ##  0    0
            0x84, ##  0    0
            0x48, ##   0  0 
            0x38, ##    000 
            0x00, ##  
        ], 
    }, 
    '82' => {    # 'R'
        'width'    => 6, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x78, ##   0000 
            0x48, ##   0  0 
            0x70, ##   000  
            0x48, ##   0  0 
            0x48, ##   0  0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '83' => {    # 'S'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xF0, ##  0000
            0x80, ##  0   
            0x60, ##   00 
            0x10, ##     0
            0xF0, ##  0000
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '84' => {    # 'T'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x70, ##   000 
            0x20, ##    0  
            0x20, ##    0  
            0x20, ##    0  
            0x20, ##    0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '85' => {    # 'U'
        'width'    => 7, 
        'xoffset'  => 0, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x44, ##   0   0 
            0x44, ##   0   0 
            0x44, ##   0   0 
            0x44, ##   0   0 
            0x38, ##    000  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '86' => {    # 'V'
        'width'    => 6, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x88, ##  0   0 
            0x48, ##   0  0 
            0x50, ##   0 0  
            0x30, ##    00  
            0x20, ##    0   
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '87' => {    # 'W'
        'width'    => 8, 
        'xoffset'  => 0, 
        'xadvance' => 8, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x89, ##  0   0  0
            0x5A, ##   0 00 0 
            0x5A, ##   0 00 0 
            0x66, ##   00  00 
            0x24, ##    0  0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '88' => {    # 'X'
        'width'    => 6, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x48, ##   0  0 
            0x30, ##    00  
            0x20, ##    0   
            0x50, ##   0 0  
            0x08, ##      0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '89' => {    # 'Y'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x88, ##  0   0
            0x50, ##   0 0 
            0x20, ##    0  
            0x20, ##    0  
            0x20, ##    0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '90' => {    # 'Z'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0xF8, ##  00000
            0x10, ##     0 
            0x20, ##    0  
            0x40, ##   0   
            0xF0, ##  0000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '91' => {    # '['
        'width'    => 2, 
        'xoffset'  => 1, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##  
            0x80, ##  0 
            0x80, ##  0 
            0x80, ##  0 
            0x80, ##  0 
            0x80, ##  0 
            0x80, ##  0 
            0xC0, ##  00
            0x00, ##  
        ], 
    }, 
    '92' => {    # '\'
        'width'    => 3, 
        'xoffset'  => 0, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x80, ##  0  
            0x80, ##  0  
            0x80, ##  0  
            0x40, ##   0 
            0x40, ##   0 
            0x20, ##    0
            0x00, ##  
        ], 
    }, 
    '93' => {    # ']'
        'width'    => 2, 
        'xoffset'  => 1, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0
            0x40, ##   0
            0x40, ##   0
            0x40, ##   0
            0x40, ##   0
            0x40, ##   0
            0xC0, ##  00
            0x00, ##  
        ], 
    }, 
    '94' => {    # '^'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x60, ##   00  
            0x90, ##  0  0 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '95' => {    # '_'
        'width'    => 4, 
        'xoffset'  => 0, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xF0, ##  0000
        ], 
    }, 
    '96' => {    # '`'
        'width'    => 1, 
        'xoffset'  => 1, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##   
            0x80, ##  0
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '97' => {    # 'a'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xF0, ##  0000 
            0x70, ##   000 
            0x90, ##  0  0 
            0xF0, ##  0000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '98' => {    # 'b'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0   
            0x40, ##   0   
            0x70, ##   000 
            0x48, ##   0  0
            0x48, ##   0  0
            0x70, ##   000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '99' => {    # 'c'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x70, ##   000
            0x80, ##  0   
            0x80, ##  0   
            0x60, ##   00 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '100' => {    # 'd'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x10, ##     0 
            0x10, ##     0 
            0x70, ##   000 
            0x90, ##  0  0 
            0x90, ##  0  0 
            0x70, ##   000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '101' => {    # 'e'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x70, ##   000
            0xF0, ##  0000
            0x80, ##  0   
            0x60, ##   00 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '102' => {    # 'f'
        'width'    => 4, 
        'xoffset'  => 0, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x70, ##   000
            0x40, ##   0  
            0x40, ##   0  
            0x40, ##   0  
            0x40, ##   0  
            0x40, ##   0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '103' => {    # 'g'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x70, ##   000 
            0x90, ##  0  0 
            0x90, ##  0  0 
            0x70, ##   000 
            0x10, ##     0 
            0xE0, ##  000  
        ], 
    }, 
    '104' => {    # 'h'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0   
            0x40, ##   0   
            0x70, ##   000 
            0x50, ##   0 0 
            0x50, ##   0 0 
            0x50, ##   0 0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '105' => {    # 'i'
        'width'    => 3, 
        'xoffset'  => 0, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '106' => {    # 'j'
        'width'    => 3, 
        'xoffset'  => -1, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x20, ##    0
            0x20, ##    0
            0x20, ##    0
            0x20, ##    0
            0x20, ##    0
            0x20, ##    0
            0xE0, ##  000
        ], 
    }, 
    '107' => {    # 'k'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0   
            0x40, ##   0   
            0x50, ##   0 0 
            0x60, ##   00  
            0x50, ##   0 0 
            0x48, ##   0  0
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '108' => {    # 'l'
        'width'    => 3, 
        'xoffset'  => 0, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '109' => {    # 'm'
        'width'    => 7, 
        'xoffset'  => 0, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xFC, ##  000000 
            0x54, ##   0 0 0 
            0x54, ##   0 0 0 
            0x54, ##   0 0 0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '110' => {    # 'n'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xF0, ##  0000 
            0x50, ##   0 0 
            0x50, ##   0 0 
            0x50, ##   0 0 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '111' => {    # 'o'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x60, ##   00 
            0x90, ##  0  0
            0x90, ##  0  0
            0x60, ##   00 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '112' => {    # 'p'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x70, ##   000 
            0x48, ##   0  0
            0x48, ##   0  0
            0x70, ##   000 
            0x40, ##   0   
            0x40, ##   0   
        ], 
    }, 
    '113' => {    # 'q'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 6, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x70, ##   000 
            0x90, ##  0  0 
            0x90, ##  0  0 
            0x70, ##   000 
            0x10, ##     0 
            0x10, ##     0 
        ], 
    }, 
    '114' => {    # 'r'
        'width'    => 4, 
        'xoffset'  => 0, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xF0, ##  0000
            0x40, ##   0  
            0x40, ##   0  
            0x40, ##   0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '115' => {    # 's'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xE0, ##  000 
            0x80, ##  0   
            0x60, ##   00 
            0xE0, ##  000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '116' => {    # 't'
        'width'    => 4, 
        'xoffset'  => 0, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x40, ##   0  
            0x40, ##   0  
            0x40, ##   0  
            0x40, ##   0  
            0x60, ##   00 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '117' => {    # 'u'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x50, ##   0 0 
            0x50, ##   0 0 
            0x50, ##   0 0 
            0x70, ##   000 
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '118' => {    # 'v'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x80, ##  0    
            0x50, ##   0 0 
            0x60, ##   00  
            0x20, ##    0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '119' => {    # 'w'
        'width'    => 7, 
        'xoffset'  => 0, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x90, ##  0  0   
            0x74, ##   000 0 
            0x6C, ##   00 00 
            0x28, ##    0 0  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '120' => {    # 'x'
        'width'    => 4, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x50, ##   0 0
            0x60, ##   00 
            0x20, ##    0 
            0x50, ##   0 0
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '121' => {    # 'y'
        'width'    => 5, 
        'xoffset'  => 0, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x80, ##  0    
            0x50, ##   0 0 
            0x60, ##   00  
            0x20, ##    0  
            0x40, ##   0   
            0xC0, ##  00   
        ], 
    }, 
    '122' => {    # 'z'
        'width'    => 4, 
        'xoffset'  => 1, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xE0, ##  000 
            0x20, ##    0 
            0x40, ##   0  
            0xF0, ##  0000
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '123' => {    # '{'
        'width'    => 3, 
        'xoffset'  => 1, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x80, ##  0  
            0x40, ##   0 
            0x40, ##   0 
            0x20, ##    0
            0x00, ##  
        ], 
    }, 
    '124' => {    # '|'
        'width'    => 1, 
        'xoffset'  => 1, 
        'xadvance' => 3, 
        'bitmap'   => [ 
            0x00, ##  
            0x80, ##  0
            0x80, ##  0
            0x80, ##  0
            0x80, ##  0
            0x80, ##  0
            0x80, ##  0
            0x80, ##  0
            0x00, ##  
        ], 
    }, 
    '125' => {    # '}'
        'width'    => 3, 
        'xoffset'  => 1, 
        'xadvance' => 5, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0 
            0x40, ##   0 
            0x40, ##   0 
            0x20, ##    0
            0x40, ##   0 
            0x40, ##   0 
            0x80, ##  0  
            0x00, ##  
        ], 
    }, 
    '126' => {    # '~'
        'width'    => 5, 
        'xoffset'  => 1, 
        'xadvance' => 7, 
        'bitmap'   => [ 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0xC8, ##  00  0
            0x30, ##    00 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
    '176' => {    # '°'
        'width'    => 3, 
        'xoffset'  => 1, 
        'xadvance' => 4, 
        'bitmap'   => [ 
            0x00, ##  
            0x40, ##   0 
            0xC0, ##  00 
            0xC0, ##  00 
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
            0x00, ##  
        ], 
    }, 
};
 
my $kerning = {
    '33' => { },  # !
    '34' => { },  # "
    '35' => { },  # #
    '36' => { },  # $
    '37' => { },  # %
    '38' => { },  # &
    '39' => { },  # '
    '40' => { },  # (
    '41' => { },  # )
    '42' => { },  # *
    '43' => { },  # +
    '44' => { },  # ,
    '45' => { },  # -
    '46' => { },  # .
    '47' => { },  # /
    '48' => { },  # 0
    '49' => { },  # 1
    '50' => { },  # 2
    '51' => { },  # 3
    '52' => { },  # 4
    '53' => { },  # 5
    '54' => { },  # 6
    '55' => { },  # 7
    '56' => { },  # 8
    '57' => { },  # 9
    '58' => { },  # :
    '59' => { },  # ;
    '60' => { },  # <
    '61' => { },  # =
    '62' => { },  # >
    '63' => { },  # ?
    '64' => { },  # @
    '65' => { },  # A
    '66' => { },  # B
    '67' => { },  # C
    '68' => { },  # D
    '69' => { },  # E
    '70' => { },  # F
    '71' => { },  # G
    '72' => { },  # H
    '73' => { },  # I
    '74' => { },  # J
    '75' => { },  # K
    '76' => { },  # L
    '77' => { },  # M
    '78' => { },  # N
    '79' => { },  # O
    '80' => { '44' => -1, '46' => -1, },  # P
    '81' => { },  # Q
    '82' => { },  # R
    '83' => { },  # S
    '84' => { },  # T
    '85' => { },  # U
    '86' => { },  # V
    '87' => { },  # W
    '88' => { },  # X
    '89' => { },  # Y
    '90' => { },  # Z
    '91' => { },  # [
    '92' => { },  # \
    '93' => { },  # ]
    '94' => { },  # ^
    '95' => { },  # _
    '96' => { },  # `
    '97' => { },  # a
    '98' => { },  # b
    '99' => { },  # c
    '100' => { },  # d
    '101' => { },  # e
    '102' => { },  # f
    '103' => { },  # g
    '104' => { },  # h
    '105' => { },  # i
    '106' => { },  # j
    '107' => { },  # k
    '108' => { },  # l
    '109' => { },  # m
    '110' => { },  # n
    '111' => { },  # o
    '112' => { },  # p
    '113' => { },  # q
    '114' => { },  # r
    '115' => { },  # s
    '116' => { },  # t
    '117' => { },  # u
    '118' => { },  # v
    '119' => { },  # w
    '120' => { },  # x
    '121' => { },  # y
    '122' => { },  # z
    '123' => { },  # {
    '124' => { },  # |
    '125' => { },  # }
    '126' => { },  # ~
    '176' => { },  # °
};


sub new {
    my($class) = @_;
    
    my $self = $class->SUPER::new(
        name        => $name,
        char_height => $char_height,
        space_width => $space_width,
        gap_width   => $gap_width,
        symbols     => $symbols,
        kerning     => $kerning,
        line_spacing => $line_spacing,
        class       => 'hipi_2',
    );
    
    return $self;
}

1;

__END__
