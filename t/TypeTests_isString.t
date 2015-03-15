package t::TypeTests_isString;
use base t::TestBase;
use strict;
use TypeTests;
use Test::More;

#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->isString_positivPath();
    $self->isString_negativPath();
    return;
}

#------------------------------------------------------------------------
sub isString_positivPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();

    ok($TypeTests->isString('abc'), "$SubTestName - tests string - true");
    ok($TypeTests->isString("a\tbc\n"), "$SubTestName - tests string with tabulator and return - true");
    ok($TypeTests->isString('123abc'), "$SubTestName - tests string with leading numbers - true");
    ok($TypeTests->isString('abc12.3'), "$SubTestName - tests string with float in the end- true");
    ok($TypeTests->isString('123 abc'), "$SubTestName - tests string with space and with leading numbers - true");
    ok($TypeTests->isString('abc 123'), "$SubTestName - tests string with space and numbers in the end- true");
    ok($TypeTests->isString(''),"$SubTestName - tests empty string - false");
    ok($TypeTests->isString(' '), "$SubTestName - tests white space - true");
    ok($TypeTests->isString('  '), "$SubTestName - tests multiple white spaces - true");
    ok($TypeTests->isString(' abc'), "$SubTestName - tests string leading white space - true");
    ok($TypeTests->isString('abc '), "$SubTestName - tests string trailing white space - true");
    ok($TypeTests->isString('-+;,.:#"\'!§%&()/öäüß€@'), "$SubTestName - tests special characters - true");

    return;
}

#------------------------------------------------------------------------
sub isString_negativPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;

    is($TypeTests->isString(), $False,"$SubTestName - tests empty parameter - false");
    is($TypeTests->isString("\n"), $False,"$SubTestName - tests only linux line break - false");
    is($TypeTests->isString("\r"), $False,"$SubTestName - tests only CR - false");
    is($TypeTests->isString("\t"), $False,"$SubTestName - tests only tabulator - false");
    is($TypeTests->isString("\n\r\t"), $False,"$SubTestName - tests only multiple controllers - false");
    is($TypeTests->isString(123), $False,"$SubTestName - tests integer - false");
    is($TypeTests->isString(-123), $False,"$SubTestName - tests negativ integer - false");
    is($TypeTests->isString('123'), $False,"$SubTestName - tests integer as string - false");
    is($TypeTests->isString('-123'), $False,"$SubTestName - tests negativ integer as string - false");
    is($TypeTests->isString(1234.56789), $False,"$SubTestName - tests float - false");
    is($TypeTests->isString(-12.3), $False,"$SubTestName - tests negativ float - false");
    is($TypeTests->isString('12.3'), $False,"$SubTestName - tests float - false");
    is($TypeTests->isString('-12.3'), $False,"$SubTestName - tests negativ float as string  - false");
    is($TypeTests->isString(-1.12E-34), $False,"$SubTestName - tests negativ float with exponent  - false");
    is($TypeTests->isString({'some' => 'thing'}), $False,"$SubTestName - tests hash pointer - false");
    is($TypeTests->isString(['some' , 'thing']), $False,"$SubTestName - tests array pointer - false");
    is($TypeTests->isString(bless({},'object')), $False, "$SubTestName - tests object pointer - false");

    return;
}

__PACKAGE__->RunTest();
