package TypeTests;
use strict;
use Scalar::Util qw ( blessed );
use base qw( Exporter );
our @EXPORT_OK = qw (
        IsInteger
        IsFloat
        IsString
    );

use Test::More;
#------------------------------------------------------------------------
sub new {
    my $Class = shift;
    my $self = bless({},$Class);
    return $self;
}
#------------------------------------------------------------------------
sub IsInteger {
    my ( $Value ) = @_;

    my $IsInteger = 0;
    my $Sign = '[-+]?'; # + or - or nothing

    if( $Value =~ /^$Sign\d+$/ ) {
        $IsInteger = 1;
    }

    return $IsInteger;
}
#------------------------------------------------------------------------
sub IsFloat {
    my ( $Value ) = @_;

    my $IsFloat = 0;

    my $OptionalSign = '[-+]?';
    my $NumberOptions = '(?=\d|\.\d)\d*(\.\d*)?';
    my $OptionalExponent = '([eE][-+]?\d+)?';
    my $FloatRegex = sprintf('%s%s%s', $OptionalSign, $NumberOptions, $OptionalExponent);

    if ( $Value =~ /^$FloatRegex$/ ){
        $IsFloat = 1;
    }

    return $IsFloat;
}
#------------------------------------------------------------------------
sub IsString {
    my ( $Value ) = @_;

    my $IsString = 0;

    if ( defined $Value ){ 
        if( $Value =~ /[\w\s]/ || $Value eq ''){
            $IsString = 1;
        }
        # exclude all "types"
        my $ValueType = ref($Value);
        if( defined $ValueType && $ValueType ne '' )  {
            $IsString = 0;
        }
    }

    return $IsString;
}

#------------------------------------------------------------------------
sub isArrayReference {
    my $self = shift;
    my ( $aValue ) = @_;

    my $IsArray = 0;

    if ( ref($aValue) eq 'ARRAY' ) {
        $IsArray = 1;
    }

    return $IsArray;
}

#------------------------------------------------------------------------
sub isHashReference {
    my $self = shift;
    my ( $hValue ) = @_;

    my $IsHash = 0;

    if ( ref($hValue) eq 'HASH' ) {
        $IsHash = 1;
    }

    return $IsHash;
}

#------------------------------------------------------------------------
sub isObjectReference {
    my $self = shift;
    my ( $Value ) = @_;

    my $IsObject = 0;

    if( blessed( $Value ) ) {
        $IsObject = 1;
    }

    return $IsObject;
}

#------------------------------------------------------------------------
sub _regExFloat {
    my $self = shift;

    my $OptionalSign = '[-+]?';
    my $NumberOptions = '(?=\d|\.\d)\d*(\.\d*)?';
    my $OptionalExponent = '([eE][-+]?\d+)?';
    my $FloatRegex = sprintf('%s%s%s', $OptionalSign, $NumberOptions, $OptionalExponent);

    return $FloatRegex;
}

#------------------------------------------------------------------------
sub _regExInteger {
    my $self = shift;

    my $OptionalSign = '[-+]?';
    my $Numbers = '[0-9]+';

    my $FloatRegex = sprintf('%s%s', $OptionalSign, $Numbers );

    return $FloatRegex;
}
1;
