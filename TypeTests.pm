package TypeTests;
use strict;
use Scalar::Util qw ( blessed );
use base qw( Exporter );
our @EXPORT_OK = qw (
        IsInteger
        IsFloat
    );
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
sub isString {
    my $self = shift;
    my ( $Value ) = @_;

    my $IsString = 1;

    # exclude empty string
    if ( not defined $Value ){
        $IsString = 0;
    }
    # exclude if there only control characters
    if ( $Value =~ /^[\t|\r|\n|\f]+$/){
        $IsString = 0;
    }
    # exclude integer todo remove?
    my $RegExInteger = $self->_regExInteger();
    if ( $Value =~ /^$RegExInteger$/){
        $IsString = 0;
    }
    # exclude float todo remove?
    my $RegExFloat = $self->_regExFloat();
    if ( $Value =~ /^$RegExFloat$/){
        $IsString = 0;
    }
    # exclude complex types
    my $ValueRefenceType = ref($Value);
    if ( defined($ValueRefenceType) && $ValueRefenceType ne ''){
        $IsString = 0;
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
