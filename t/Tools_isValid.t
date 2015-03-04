package t::Tools_isValid;
use base t::TestBase;
use strict;
use Tools;
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

    my $Tools = Tools->new();
    ok($Tools->isValid('abc'),"$SubTestName - tests if string is valid");
    ok($Tools->isValid(123),"$SubTestName - tests if int is valid");
    ok($Tools->isValid(1.23),"$SubTestName - tests if float is valid");
    ok($Tools->isValid({'key'=> 'value'}),"$SubTestName - tests if hash pointer is valid");
    ok($Tools->isValid(['element1','element2']),"$SubTestName - tests if array pointer is valid");
    ok($Tools->isValid(bless({},'Class')),"$SubTestName - tests if object pointer is valid");

    return;
}

#------------------------------------------------------------------------
sub isObjectReference_negativPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $Tools = Tools->new();
    my $False = 0;
    is($Tools->isValid(), $False,"$SubTestName - tests if no parameter is not valid");
    is($Tools->isValid(''), $False,"$SubTestName - tests if empty string is not valid");
    is($Tools->isValid(undef), $False,"$SubTestName - tests if undef is not valid");
    is($Tools->isValid({}), $False,"$SubTestName - tests if empty hash is not valid");
    is($Tools->isValid([]), $False,"$SubTestName - tests if empty array is not valid");
    my @TestArray = undef;
    is($Tools->isValid(\@TestArray), $False,"$SubTestName - tests if undef array is not valid");
    my %TestHash = undef;
    is($Tools->isValid(\%TestHash), $False,"$SubTestName - tests if undef hash is not valid");
    my $TestScalar = undef;
    is($Tools->isValid($TestScalar), $False,"$SubTestName - tests if undef scalar is not valid");
    return;
}

__PACKAGE__->RunTest();
1;