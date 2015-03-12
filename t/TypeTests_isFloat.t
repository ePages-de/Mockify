package t::TypeTests_isFloat;
use base t::TestBase;
use strict;
use TypeTests;
use Test::More;

#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->_isFloat_positivPath();
    $self->_isFloat_negativPath();
    return;
}


#------------------------------------------------------------------------
sub _isFloat_positivPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();

    #brute force testing ON
    ok($TypeTests->isFloat(-1.12E-34),"$SubTestName - tests if -1.12E-34 is a float - true");
    ok($TypeTests->isFloat(-1.12E+34),"$SubTestName - tests if -1.12E+34 is a float - true");
    ok($TypeTests->isFloat(+1.12E-34),"$SubTestName - tests if +1.12E-34 is a float - true");
    ok($TypeTests->isFloat(+1.12E+34),"$SubTestName - tests if +1.12E+34 is a float - true");
    ok($TypeTests->isFloat(1.12E-34),"$SubTestName - tests if 1.12E-34 is a float - true");
    ok($TypeTests->isFloat(1.12E+34),"$SubTestName - tests if 1.12E+34 is a float - true");

    ok($TypeTests->isFloat(-.12E-34),"$SubTestName - tests if -.12E-34 is a float - true");
    ok($TypeTests->isFloat(-.12E+34),"$SubTestName - tests if -.12E+34 is a float - true");
    ok($TypeTests->isFloat(+.12E-34),"$SubTestName - tests if +.12E-34 is a float - true");
    ok($TypeTests->isFloat(+.12E+34),"$SubTestName - tests if +.12E+34 is a float - true");
    ok($TypeTests->isFloat(.12E-34),"$SubTestName - tests if .12E-34 is a float - true");
    ok($TypeTests->isFloat(.12E+34),"$SubTestName - tests if .12E+34 is a float - true");

    ok($TypeTests->isFloat(-1.E-34),"$SubTestName - tests if -1.E-34 is a float - true");
    ok($TypeTests->isFloat(-1.E+34),"$SubTestName - tests if -1.E+34 is a float - true");
    ok($TypeTests->isFloat(+1.E-34),"$SubTestName - tests if +1.E-34 is a float - true");
    ok($TypeTests->isFloat(+1.E+34),"$SubTestName - tests if +1.E+34 is a float - true");
    ok($TypeTests->isFloat(1.E-34),"$SubTestName - tests if 1.E-34 is a float - true");
    ok($TypeTests->isFloat(1.E+34),"$SubTestName - tests if 1.E+34 is a float - true");

    ok($TypeTests->isFloat(-1.12e-34),"$SubTestName - tests if -1.12e-34 is a float - true");
    ok($TypeTests->isFloat(-1.12e+34),"$SubTestName - tests if -1.12e+34 is a float - true");
    ok($TypeTests->isFloat(+1.12e-34),"$SubTestName - tests if +1.12e-34 is a float - true");
    ok($TypeTests->isFloat(+1.12e+34),"$SubTestName - tests if +1.12e+34 is a float - true");
    ok($TypeTests->isFloat(1.12e-34),"$SubTestName - tests if 1.12e-34 is a float - true");
    ok($TypeTests->isFloat(1.12e+34),"$SubTestName - tests if 1.12e+34 is a float - true");

    ok($TypeTests->isFloat(-.12e-34),"$SubTestName - tests if -.12e-34 is a float - true");
    ok($TypeTests->isFloat(-.12e+34),"$SubTestName - tests if -.12e+34 is a float - true");
    ok($TypeTests->isFloat(+.12e-34),"$SubTestName - tests if +.12e-34 is a float - true");
    ok($TypeTests->isFloat(+.12e+34),"$SubTestName - tests if +.12e+34 is a float - true");
    ok($TypeTests->isFloat(.12e-34),"$SubTestName - tests if .12e-34 is a float - true");
    ok($TypeTests->isFloat(.12e+34),"$SubTestName - tests if .12e+34 is a float - true");

    ok($TypeTests->isFloat(-1.e-34),"$SubTestName - tests if -1.e-34 is a float - true");
    ok($TypeTests->isFloat(-1.e+34),"$SubTestName - tests if -1.e+34 is a float - true");
    ok($TypeTests->isFloat(+1.e-34),"$SubTestName - tests if +1.e-34 is a float - true");
    ok($TypeTests->isFloat(+1.e+34),"$SubTestName - tests if +1.e+34 is a float - true");
    ok($TypeTests->isFloat(1.e-34),"$SubTestName - tests if 1.e-34 is a float - true");
    ok($TypeTests->isFloat(1.e+34),"$SubTestName - tests if 1.e+34 is a float - true");

    ok($TypeTests->isFloat(-1.12),"$SubTestName - tests if -1.12 is a float - true");
    ok($TypeTests->isFloat(+1.12),"$SubTestName - tests if +1.12 is a float - true");
    ok($TypeTests->isFloat(1.12),"$SubTestName - tests if 1.12 is a float - true");

    ok($TypeTests->isFloat(-.12),"$SubTestName - tests if -.12 is a float - true");
    ok($TypeTests->isFloat(+.12),"$SubTestName - tests if +.12 is a float - true");
    ok($TypeTests->isFloat(.12),"$SubTestName - tests if .12 is a float - true");

    ok($TypeTests->isFloat(-1.),"$SubTestName - tests if -1. is a float - true");
    ok($TypeTests->isFloat(+1.),"$SubTestName - tests if +1. is a float - true");
    ok($TypeTests->isFloat(1.),"$SubTestName - tests if 1. is a float - true");
    #brute force testing OFF ;-)

    ok($TypeTests->isFloat(1),"$SubTestName - tests the integer is also a float - true");
    ok($TypeTests->isFloat(-1),"$SubTestName - tests the integer is also a float - true");

    return;
}

#------------------------------------------------------------------------
sub _isFloat_negativPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;

    is($TypeTests->isFloat(), $False, "$SubTestName - tests empty parameters");
    is($TypeTests->isFloat('abc'), $False, "$SubTestName - tests abc is not a float");
    is($TypeTests->isFloat('123,123e-123'), $False, "$SubTestName - tests 123,123e-123 is not a float");
    is($TypeTests->isFloat('12.234ae-12'), $False, "$SubTestName - tests 12.234ae-12 is not a float");
    is($TypeTests->isFloat('12.234e-'), $False, "$SubTestName - tests 12.234ae-12 is not a float");
    is($TypeTests->isFloat('.'), $False, "$SubTestName - tests '.' is not a float");
    is($TypeTests->isFloat({'some' => 'thing'}), $False,"$SubTestName - tests hash pointer - false");
    is($TypeTests->isFloat(['some' , 'thing']), $False,"$SubTestName - tests array pointer - false");
    is($TypeTests->isFloat(bless({},'object')), $False, "$SubTestName - tests object pointer - false");

    return;
}

__PACKAGE__->RunTest();
1;
