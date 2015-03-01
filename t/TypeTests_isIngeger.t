package t::TypeTests_isInteger;
use base t::TestBase;
use strict;
use TypeTests;
use Test::More;

#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->isInteger_positivPath();
    $self->isInteger_negativPath();
    $self->isInteger_specialIssues();
    return;
}

#------------------------------------------------------------------------
sub isInteger_positivPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();

    ok($TypeTests->isInteger(2), "$SubTestName - tests positiv integer - true");
    ok($TypeTests->isInteger(-2), "$SubTestName - tests negativ integer - true");
    ok($TypeTests->isInteger(0), "$SubTestName - tests zero - true");
    ok($TypeTests->isInteger(-0), "$SubTestName - tests negativ zero - true");
 
    return;
}

#------------------------------------------------------------------------
sub isInteger_negativPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;

    is($TypeTests->isInteger(), $False, "$SubTestName - tests empty parameter - false");
    is($TypeTests->isInteger(4.123), $False, "$SubTestName - tests positiv float - false");
    is($TypeTests->isInteger(-0.123), $False, "$SubTestName - tests negativ float - false");
    is($TypeTests->isInteger('a'), $False, "$SubTestName - tests string - false");
    is($TypeTests->isInteger(''), $False, "$SubTestName - tests empty string - false");
    is($TypeTests->isInteger({'some' => 'thing'}), $False, "$SubTestName - tests hash pointer - false");
    is($TypeTests->isInteger(['some', 'thing']), $False, "$SubTestName - tests array pointer - false");
    is($TypeTests->isInteger(bless({},'object')), $False, "$SubTestName - tests object pointer - false");

    return;
}

#------------------------------------------------------------------------
sub isInteger_specialIssues {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;
    #I didn't found a way to distinguish between integers as string and normal integers. So this has to be ok.
    ok($TypeTests->isInteger('2'), "$SubTestName - tests positiv integer as string - true");
    ok($TypeTests->isInteger('-2'), "$SubTestName - tests positiv integer as string - true");
    ok($TypeTests->isInteger('0'), "$SubTestName - tests zero as string - true");
    ok($TypeTests->isInteger('-0'), "$SubTestName - tests negativ zero as string - true"); 

    #I didn't found a way to distinguish between float-zero and integer-zero. So this has to be ok.
    ok($TypeTests->isInteger(0.0), "$SubTestName - tests zero float - true");
    ok($TypeTests->isInteger(00.0000), "$SubTestName - tests multiple zeros float - true");
    ok($TypeTests->isInteger(-0.0), "$SubTestName - tests negativ zero float - true");

    # BUT since '0.0' (as String) would't be accepted as integer, I have to straighten this behavior in isInteger to ensure stable results.
    ok($TypeTests->isInteger('0.0'), "$SubTestName - tests zero float as string - true");
    ok($TypeTests->isInteger('-0.0'), "$SubTestName - tests negativ zero float as string- true");
    ok($TypeTests->isInteger('.0'), "$SubTestName - tests zero float as string without leading 0 - true");
    ok($TypeTests->isInteger('.0'), "$SubTestName - tests negativ zero float as string without leading 0 - true");
    ok($TypeTests->isInteger('0.'), "$SubTestName - tests negativ zero float as string without subsequent 0 - true");
    ok($TypeTests->isInteger('-0.'), "$SubTestName - tests negativ zero float as string without subsequent 0 - true");
    is($TypeTests->isInteger('.'), $False, "$SubTestName - tests only the decimal point - false");
    ok($TypeTests->isInteger('00.0000'), "$SubTestName - tests multiple zeros float as string - true");
    ok($TypeTests->isInteger('-00.0000'), "$SubTestName - tests negativ multiple zeros float as string - true");
    is($TypeTests->isInteger('0.0a'), $False, "$SubTestName - tests zero float with letter - false");
    is($TypeTests->isInteger('a0.0'), $False, "$SubTestName - tests zero float with letter - false");
    is($TypeTests->isInteger('0a.0'), $False, "$SubTestName - tests zero float with letter - true");

    return;
}

__PACKAGE__->RunTest();
1;
