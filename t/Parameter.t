package Parameter;
use strict;
use FindBin;
use lib ($FindBin::Bin);
use parent 'TestBase';
use Test::More;
use Test::Exception;
use Test::Mockify::Parameter;
#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->test_call_and_buildReturn();
    $self->test_compareExpectedParameters();
    $self->matchWithExpectedParameters();
    return;
}

#------------------------------------------------------------------------
sub test_call_and_buildReturn {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $Parameter = Test::Mockify::Parameter->new();
    $Parameter->buildReturn()->thenCall(sub{return join('-', @_);});
    is($Parameter->call('a','b'),'a-b', 'proves that the parameter has passed');

    $Parameter = Test::Mockify::Parameter->new();
    throws_ok( sub { $Parameter->call() },
       qr/NoReturnValueDefined/,
       'proves that mockify throws an error if the return is nott defined.'
    );

    return;
}

#------------------------------------------------------------------------
sub test_compareExpectedParameters {
    my $self = shift;

    my $Parameter = Test::Mockify::Parameter->new(['abc','def']);
    is($Parameter->compareExpectedParameters(['abc']), 0, 'proves that wrong amount of parameters will return false');

    $Parameter = Test::Mockify::Parameter->new(['def']);
    is($Parameter->compareExpectedParameters(['abc']), 0, 'proves that to less parameter will return false');

    $Parameter = Test::Mockify::Parameter->new(['abc']);
    is($Parameter->compareExpectedParameters(['abc','def','xyz']), 0, 'proves that to many parameter will return false');

    $Parameter = Test::Mockify::Parameter->new();
    is($Parameter->compareExpectedParameters(), 1, 'proves that an undefined parameter list will be checked positiv');

    $Parameter = Test::Mockify::Parameter->new();
    is($Parameter->compareExpectedParameters([]), 1, 'proves that an empty parameter list will be checked positiv');

    $Parameter = Test::Mockify::Parameter->new();
    is($Parameter->compareExpectedParameters(['abc']), 0, 'proves that an empty parameter list will be checked negativ');

    $Parameter = Test::Mockify::Parameter->new(['abc', 123]);
    is($Parameter->compareExpectedParameters(['abc', 123]), 1, 'proves that muiltple parameter of type scalar are supported');

    $Parameter = Test::Mockify::Parameter->new([{'hash'=>'value'},['one',{'two'=>'zwei'}]]);
    is($Parameter->compareExpectedParameters([{'hash'=>'value'},['one',{'two'=>'zwei'}]]), 1, 'proves that muiltple parameter of depply nested arrays and hashs are supported -  matches');
    is($Parameter->compareExpectedParameters([{'hash'=>'value'},['one','else']]), 0, 'proves that muiltple parameter of depply nested arrays and hashs are supported - matches not');

}
#------------------------------------------------------------------------
sub matchWithExpectedParameters {
    my $self = shift;
    # no expected parameter
    my $Parameter = Test::Mockify::Parameter->new(['expectedValue','NoExpectedParameter','NoExpectedParameter']);
    is($Parameter->matchWithExpectedParameters('expectedValue','somevalue',123456),1, 'proves that expected and not checked values are checked. matches.');
    is($Parameter->matchWithExpectedParameters('unexpectedValue','somevalue',123456),0, 'proves that expected and not checked values are checked. matches not.');
    # check parameter amount
    $Parameter = Test::Mockify::Parameter->new(['somevalue','othervalue']);
    is($Parameter->matchWithExpectedParameters('somevalue','othervalue' ), 1, 'proves that the correct amount is matches.');
    is($Parameter->matchWithExpectedParameters('somevalue','othervalue',123456), 0, 'proves that too many values are not matching');
    is($Parameter->matchWithExpectedParameters('somevalue'), 0, 'proves that too less values are not matching');
    is($Parameter->matchWithExpectedParameters(), 0, , 'proves that no values are not matching');
    # check package name
    $Parameter = Test::Mockify::Parameter->new(['abc','Package::One','Package::Two']);
    is($Parameter->matchWithExpectedParameters('abc',bless({},'Package::One'),bless({},'Package::Two')), 1, 'proves that the package check is working well. matches.');
    is($Parameter->matchWithExpectedParameters('abc',bless({},'Package::One')), 0, 'proves that the package check is working well. matches not');

    $Parameter = Test::Mockify::Parameter->new();
    is($Parameter->matchWithExpectedParameters(), 1, 'proves that an empty parameter list will be checked positiv');

    $Parameter = Test::Mockify::Parameter->new();
    is($Parameter->matchWithExpectedParameters('abc'), 0, 'proves that an empty parameter list will not be matched');

    $Parameter = Test::Mockify::Parameter->new(['abc', 123]);
    is($Parameter->matchWithExpectedParameters('abc', 123), 1, 'proves that muiltple parameter of type scalar are supported');

    $Parameter = Test::Mockify::Parameter->new([{'hash'=>'value'},['one',{'two'=>'zwei'}]]);
    is($Parameter->matchWithExpectedParameters({'hash'=>'value'},['one',{'two'=>'zwei'}]), 1, 'proves that muiltple parameter of depply nested arrays and hashs are supported -  matches');
    is($Parameter->matchWithExpectedParameters({'hash'=>'value'},['one','else']), 0, 'proves that muiltple parameter of depply nested arrays and hashs are supported - matches not');
}
__PACKAGE__->RunTest();
1;