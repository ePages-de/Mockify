package t::TypeTests_isArrayReference;
use base t::TestBase;
use strict;
use TypeTests;
use Test::More;

#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->isArrayReference_positivPath();
    $self->isArrayReference_negativPath();
    return;
}

#------------------------------------------------------------------------
sub isArrayReference_positivPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();

    ok($TypeTests->isArrayReference([]),"$SubTestName - tests with empty array ref - true");
    ok($TypeTests->isArrayReference(['some', 'elments']),"$SubTestName - tests array ref with some elments - true");
    my @TestArray = qw (one two);
    ok($TypeTests->isArrayReference(\@TestArray),"$SubTestName - tests direct de-referencing of array - true");
    return;
}

#------------------------------------------------------------------------
sub isArrayReference_negativPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;

    is($TypeTests->isArrayReference(), $False, "$SubTestName - tests empty parameter - false");
    is($TypeTests->isArrayReference(123), $False, "$SubTestName - tests with integer - false");
    is($TypeTests->isArrayReference(12.3), $False, "$SubTestName - tests with float - false");
    is($TypeTests->isArrayReference('string'), $False, "$SubTestName - tests with string - false");
    is($TypeTests->isArrayReference({'some' => 'thing'}), $False, "$SubTestName - tests with hash ref - false");
    is($TypeTests->isArrayReference(bless({},'object')), $False, "$SubTestName - tests with object ref - false");
    my @TestArray = qw (one two);
    is($TypeTests->isArrayReference(@TestArray), $False, "$SubTestName - tests with direct array - false");

    return;
}

__PACKAGE__->RunTest();
1;
