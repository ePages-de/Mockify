package TypeTests;
use strict;

sub new {
    my $Class = shift;
    my $self = bless({},$Class);
    return $self;
}
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
    my $MandatoryLeadingZero = '[0]+.[0]*';
    my $MandatoryDecimalZero = '[0]*.[0]+';
    my $FloatZero = "($MandatoryLeadingZero|$MandatoryDecimalZero)";

    if( $Value =~ /^$Sign$FloatZero$/ ) {
        $IsInteger = 1;
    }

    return $IsInteger;
}
1;
