package TypeTests;
use strict;
#------------------------------------------------------------------------
sub new {
    my $Class = shift;
    my $self = bless({},$Class);
    return $self;
}
#------------------------------------------------------------------------
sub testInteger {
    my $self = shift;
    my ( $Value ) = @_;

    my $IsInteger = 0;

    if( $Value =~ /^[-+]?\d+$/ ) {
        $IsInteger = 1;
    }

    #Float 0.0 and integer 0 can't be distinguished in perl.
    #But since '0.0' (as String) would't be accepted as integer, I have to straighten this behavior in testInteger to ensure stable results.
    my $Sign = '[-+]?'; # + or - or nothing
    my $MandatoryLeadingZero = '0+.0*';
    my $MandatoryDecimalZero = '0*.0+';
    my $FloatZero = "($MandatoryLeadingZero|$MandatoryDecimalZero)";

    if( $Value =~ /^$Sign$FloatZero$/ ) {
        $IsInteger = 1;
    }

    return $IsInteger;
}

#------------------------------------------------------------------------
sub isString {
    my $self = shift;
    my ( $Value ) = @_;

    my $IsString = 1;

    # exclude empty string
    if ( $Value eq ''){
        $IsString = 0;
    }
    # exclude if there only control characters
    if ( $Value =~ /^[\t|\r|\n|\f]+$/){
        $IsString = 0;
    }
    # exclude integer
    if ( $Value =~ /^[-+]?[0-9]+$/){
        $IsString = 0;
    }
    # exclude float
    if ( $Value =~ /^[-+]?[0-9]*\.[0-9]*$/){
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

1;
