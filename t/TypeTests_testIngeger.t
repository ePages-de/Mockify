package t::TypeTests_testIngeger;
use base t::TestBase;
use strict;
use TypeTests;
use Test::More;

sub testPlan{
    my $self = shift;
    $self->testInteger();
    $self->testInteger_specialIssues();
    return;
}

sub testInteger {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;

    #positiv path
    ok($TypeTests->testInteger(2), "$SubTestName - tests positiv integer - true");
    ok($TypeTests->testInteger(-2), "$SubTestName - tests negativ integer - true");
    ok($TypeTests->testInteger(0), "$SubTestName - tests zero - true");
    ok($TypeTests->testInteger(-0), "$SubTestName - tests negativ zero - true");
 
    #negativ path
    is($TypeTests->testInteger(4.123), $False, "$SubTestName - tests positiv float - false");
    is($TypeTests->testInteger(-0.123), $False, "$SubTestName - tests negativ float - false");
    is($TypeTests->testInteger('a'), $False, "$SubTestName - tests string - false");
    is($TypeTests->testInteger({'some' => 'thing'}), $False, "$SubTestName - tests hash pointer - false");
    is($TypeTests->testInteger(['some', 'thing']), $False, "$SubTestName - tests array pointer - false");
    is($TypeTests->testInteger(bless({},'object')), $False, "$SubTestName - tests object pointer - false");

    return;
}

sub testInteger_specialIssues {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;
    #I didn't found a way to distinguish between integers as string and normal integers. So this has to be ok.
    ok($TypeTests->testInteger('2'), "$SubTestName - tests positiv integer as string - true");
    ok($TypeTests->testInteger('-2'), "$SubTestName - tests positiv integer as string - true");
    ok($TypeTests->testInteger('0'), "$SubTestName - tests zero as string - true");
    ok($TypeTests->testInteger('-0'), "$SubTestName - tests negativ zero as string - true"); 

    #I didn't found a way to distinguish between float-zero and integer-zero. So this has to be ok.
    ok($TypeTests->testInteger(0.0), "$SubTestName - tests zero float - true");
    ok($TypeTests->testInteger(00.0000), "$SubTestName - tests multiple zeros float - true");
    ok($TypeTests->testInteger(-0.0), "$SubTestName - tests negativ zero float - true");

    # BUT since '0.0' (as String) would't be accepted as integer, I have to straighten this behavior in testInteger to ensure stable results.
    ok($TypeTests->testInteger('0.0'), "$SubTestName - tests zero float as string - true");
    ok($TypeTests->testInteger('-0.0'), "$SubTestName - tests negativ zero float as string- true");
    ok($TypeTests->testInteger('.0'), "$SubTestName - tests zero float as string without leading 0 - true");
    ok($TypeTests->testInteger('.0'), "$SubTestName - tests negativ zero float as string without leading 0 - true");
    ok($TypeTests->testInteger('0.'), "$SubTestName - tests negativ zero float as string without subsequent 0 - true");
    ok($TypeTests->testInteger('-0.'), "$SubTestName - tests negativ zero float as string without subsequent 0 - true");
    is($TypeTests->testInteger('.'), $False, "$SubTestName - tests only the decimal point - false");
    ok($TypeTests->testInteger('00.0000'), "$SubTestName - tests multiple zeros float as string - true");
    ok($TypeTests->testInteger('-00.0000'), "$SubTestName - tests negativ multiple zeros float as string - true");
    is($TypeTests->testInteger('0.0a'), $False, "$SubTestName - tests zero float with letter - false");
    is($TypeTests->testInteger('a0.0'), $False, "$SubTestName - tests zero float with letter - false");
    is($TypeTests->testInteger('0a.0'), $False, "$SubTestName - tests zero float with letter - true");

    return;
}

__PACKAGE__->RunTest();
1;
