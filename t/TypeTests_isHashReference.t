package t::TypeTests_isHashReference;
use base t::TestBase;
use strict;
use TypeTests;
use Test::More;

#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->isHashReference_positivPath();
    $self->isHashReference_negativPath();
    return;
}

#------------------------------------------------------------------------
sub isHashReference_positivPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();

    ok($TypeTests->isHashReference({}),"$SubTestName - tests with empty hash ref - true");
    ok($TypeTests->isHashReference({'some' => 'elments'}),"$SubTestName - tests hash ref with some elments - true");
    my %TestHash = ('key1' => 'value1', 'key2' => 'value2');
    ok($TypeTests->isHashReference(\%TestHash),"$SubTestName - tests direct de-referencing of hash - true");
    return;
}

#------------------------------------------------------------------------
sub isHashReference_negativPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;

    is($TypeTests->isHashReference(), $False, "$SubTestName - tests empty parameter - false");
    is($TypeTests->isHashReference(123), $False, "$SubTestName - tests with integer - false");
    is($TypeTests->isHashReference(12.3), $False, "$SubTestName - tests with float - false");
    is($TypeTests->isHashReference('string'), $False, "$SubTestName - tests with string - false");
    is($TypeTests->isHashReference(['some', 'thing']), $False, "$SubTestName - tests with array ref - false");
    is($TypeTests->isHashReference(bless({},'object')), $False, "$SubTestName - tests with object ref - false");
    my %TestHash = ('key1' => 'value1', 'key2' => 'value2');
    is($TypeTests->isHashReference(%TestHash), $False, "$SubTestName - tests with direct hash - false");

    return;
}

__PACKAGE__->RunTest();
1;
