package t::TypeTests_testString;
use base t::TestBase;
use strict;
use TypeTests;
use Test::More;

#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->testString_positivPath();
    $self->testString_negativPath();
    return;
}

#------------------------------------------------------------------------
sub testString_positivPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();

    ok($TypeTests->testString('abc'), "$SubTestName - tests string - true");
    ok($TypeTests->testString("a\tbc\n"), "$SubTestName - tests string with tabulator and return - true");
    ok($TypeTests->testString('123abc'), "$SubTestName - tests string with leading numbers - true");
    ok($TypeTests->testString('abc12.3'), "$SubTestName - tests string with float in the end- true");
    ok($TypeTests->testString('123 abc'), "$SubTestName - tests string with space and with leading numbers - true");
    ok($TypeTests->testString('abc 123'), "$SubTestName - tests string with space and numbers in the end- true");
    ok($TypeTests->testString(' '), "$SubTestName - tests white space - true");
    ok($TypeTests->testString('  '), "$SubTestName - tests multiple white spaces - true");
    ok($TypeTests->testString(' abc'), "$SubTestName - tests string leading white space - true");
    ok($TypeTests->testString('abc '), "$SubTestName - tests string trailing white space - true");
    ok($TypeTests->testString('-+;,.:#"\'!§%&()/öäüß€@'), "$SubTestName - tests special characters - true");

    return;
}

#------------------------------------------------------------------------
sub testString_negativPath {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TypeTests = TypeTests->new();
    my $False = 0;

    is($TypeTests->testString(), $False,"$SubTestName - tests empty parameter - false");
    is($TypeTests->testString(''), $False,"$SubTestName - tests empty string - false");
    is($TypeTests->testString("\n"), $False,"$SubTestName - tests only linux line break - false");
    is($TypeTests->testString("\r"), $False,"$SubTestName - tests only CR - false");
    is($TypeTests->testString("\t"), $False,"$SubTestName - tests only tabulator - false");
    is($TypeTests->testString("\n\r\t"), $False,"$SubTestName - tests only multiple controllers - false");
    is($TypeTests->testString(123), $False,"$SubTestName - tests integer - false");
    is($TypeTests->testString(-123), $False,"$SubTestName - tests negativ integer - false");
    is($TypeTests->testString('123'), $False,"$SubTestName - tests integer as string - false");
    is($TypeTests->testString('-123'), $False,"$SubTestName - tests negativ integer as string - false");
    is($TypeTests->testString(1234.56789), $False,"$SubTestName - tests float - false");
    is($TypeTests->testString(-12.3), $False,"$SubTestName - tests negativ float - false");
    is($TypeTests->testString('12.3'), $False,"$SubTestName - tests float - false");
    is($TypeTests->testString('-12.3'), $False,"$SubTestName - tests negativ float as string  - false");
    is($TypeTests->testString({'some' => 'thing'}), $False,"$SubTestName - tests hash pointer - false");
    is($TypeTests->testString(['some' , 'thing']), $False,"$SubTestName - tests array pointer - false");
    is($TypeTests->testString(bless({},'object')), $False, "$SubTestName - tests object pointer - false");

    return;
}

__PACKAGE__->RunTest();
