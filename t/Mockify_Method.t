package Mockify_Method;
use strict;
use FindBin;
use lib ($FindBin::Bin);
use parent 'TestBase';
use Test::More;
use Test::Exception;
use Test::Mockify;
use Test::Mockify::Matcher qw (String);
use Test::Mockify::Verify qw (GetParametersFromMockifyCall WasCalled GetCallCount);
#------------------------------------------------------------------------
sub testPlan{
    test_SomeThing();
    return;
}
#------------------------------------------------------------------------
sub test_SomeThing {
    my $self = shift;

    my $Mockify = Test::Mockify->new('FakeModuleForMockifyTest', []);
    $Mockify->mock('DummmyMethodForTestOverriding')->when(String('Parameter'))->thenCall(sub{return $_[0].'_test';});
    $Mockify->mock('DummmyMethodForTestOverriding')->when(String('SomeParameter'))->thenReturn('SomeReturnValue');
    $Mockify->mock('secondDummmyMethodForTestOverriding')->when(String('SomeParameter'))->thenReturn('SecondReturnValue');
    my $FakeModule = $Mockify->getMockObject();

    is($FakeModule->DummmyMethodForTestOverriding('Parameter'),'Parameter_test' , 'proves that the parameters will be passed');
    is($FakeModule->DummmyMethodForTestOverriding('SomeParameter'),'SomeReturnValue' , 'proves that defining mulitiple return types are supported');
    is($FakeModule->secondDummmyMethodForTestOverriding('SomeParameter'),'SecondReturnValue' , 'proves that defining an other method with the same parameter works fine');
    is(GetCallCount($FakeModule,'DummmyMethodForTestOverriding'),2 , 'proves that the get call count works fine');
    is(WasCalled($FakeModule,'secondDummmyMethodForTestOverriding'),1 , 'proves that the verifyer for wasCalled works fine');
    is(GetParametersFromMockifyCall($FakeModule,'secondDummmyMethodForTestOverriding')->[0],'SomeParameter' , 'proves that the verifyer for getparams... works fine');
}
__PACKAGE__->RunTest();
1;