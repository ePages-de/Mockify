package t::TypeTests_isObjectReference;
use base t::TestBase;
use strict;
use TypeTests;
use Test::More;

#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->isObjectReference_positivPath();
    $self->isObjectReference_negativPath();
    return;
}


#------------------------------------------------------------------------
sub isObjectReference_positivPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();

    my $TestObject = bless({},'Object::Test');
    ok($TypeTests->isObjectReference($TestObject), "$SubTestName - tests if object will be detected");

    return;
}

#------------------------------------------------------------------------
sub isObjectReference_negativPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;

    is($TypeTests->isObjectReference(), $False, "$SubTestName - tests empty parameter - false");
    is($TypeTests->isObjectReference(123), $False, "$SubTestName - tests with integer - false");
    is($TypeTests->isObjectReference(12.3), $False, "$SubTestName - tests with float - false");
    is($TypeTests->isObjectReference('string'), $False, "$SubTestName - tests with string - false");
    is($TypeTests->isObjectReference(['some', 'thing']), $False, "$SubTestName - tests with array ref - false");
    is($TypeTests->isObjectReference({'some'=> 'thing'}), $False, "$SubTestName - tests with hash ref - false");

    return;
}

__PACKAGE__->RunTest();
1;
