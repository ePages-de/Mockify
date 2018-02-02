package Mockify_StaticInjection;

use FindBin;
use lib ($FindBin::Bin);

use parent 'TestBase';
use Test::Exception;
use Test::Mockify;
use Test::Mockify::Injector;
use Test::Mockify::Verify qw (WasCalled GetCallCount GetParametersFromMockifyCall);
use Test::More;
use Test::Mockify::Matcher qw (String Number);
use Test::MockModule;

use strict;
use warnings;
no warnings 'deprecated';

use FakeModuleForMockifyTest;
use FakeModuleWithoutNew;
use FakeModuleStaticInjection;
use Dog;

sub testPlan {
    my $self = shift;

    $self->test_mockStatic();
    $self->test_verify_with_mockAndSpy();
    $self->test_MethodAndImportedFunctionHaveTheSameName();
#    $self->test_someSelectedMockifyFeatures();
    $self->test_mockRevertsWhenInjectorGoesOutOfScope();
    $self->test_thisTestIsNotAffectedByPrevious();
    $self->test_mockDogOriginalApproach();
    $self->test_mockDogStaticApproach();
    $self->test_newNotCalled();
}
#----------------------------------------------------------------------------------------
sub test_mockStatic {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $injector = Test::Mockify::Injector->new('FakeStaticTools');
    $injector->mock('ReturnHelloWorld')->when(String('German'))->thenReturn('Hallo Welt');
    $injector->mock('ReturnHelloWorld')->when(String('Spanish'))->thenReturn('Hola Mundo');
    $injector->mock('ReturnHelloWorld')->when(String('Esperanto'))->thenReturn('Saluton mondon');

    is(FakeModuleStaticInjection->useStaticFunction('German'), 'German: Hallo Welt',"$SubTestName - prove full path call- german");
    is(FakeModuleStaticInjection->useStaticFunction('Spanish'), 'Spanish: Hola Mundo',"$SubTestName - prove full path call - spanish");
    is(FakeModuleStaticInjection->useStaticFunction('Esperanto'), 'Esperanto: Saluton mondon',"$SubTestName - prove full path call, scope independent- german");

    my $injectorImported = Test::Mockify::Injector->new('FakeModuleStaticInjection');
    $injectorImported->mock('ReturnHelloWorld')->when(String('German'))->thenReturn('Hallo Welt');
    $injectorImported->mock('ReturnHelloWorld')->when(String('Spanish'))->thenReturn('Hola Mundo');
    $injectorImported->mock('ReturnHelloWorld')->when(String('Esperanto'))->thenReturn('Saluton mondon');

    is(FakeModuleStaticInjection->useImportedStaticFunction('German'), 'German: Hallo Welt',"$SubTestName - prove that the same mock can handle also the imported call - german");
    is(FakeModuleStaticInjection->useImportedStaticFunction('Spanish'), 'Spanish: Hola Mundo',"$SubTestName - prove imported call - spanish");
    is(FakeModuleStaticInjection->useImportedStaticFunction('Esperanto'), 'Esperanto: Saluton mondon',"$SubTestName - prove that the same mock can handle also the imported call, scope independent - german");
}
#----------------------------------------------------------------------------------------
sub test_verify_with_mockAndSpy{
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $injector = Test::Mockify::Injector->new('FakeStaticTools');
    $injector->mock('ReturnHelloWorld')->when(String('German'))->thenReturn('Hallo Welt');
    $injector->spy('HelloSpy')->when(String('And you are?'));

    is(FakeModuleStaticInjection->useStaticFunction('German'), 'German: Hallo Welt',"$SubTestName - prove full path call- german");
    is(FakeModuleStaticInjection->useStaticFunctionSpy('And you are?'), 'And you are?: Bond, James Bond!', "$SubTestName - prove static spy Works");

    my $injectorImported = Test::Mockify::Injector->new('FakeModuleStaticInjection');
    $injectorImported->mock('ReturnHelloWorld')->when(String('German'))->thenReturn('Hallo Welt');
    $injectorImported->spy('HelloSpy')->when(String('And you are?'));

    is(FakeModuleStaticInjection->useImportedStaticFunction('German'), 'German: Hallo Welt',"$SubTestName - prove that the same mock can handle also the imported call - german");
    is(FakeModuleStaticInjection->useImportedStaticFunctionSpy('And you are?'), 'And you are?: Bond, James Bond!', "$SubTestName - prove static spy Works.");

    ok( WasCalled($injector->getVerifier(), 'ReturnHelloWorld'), "$SubTestName - prove verify, independent of scope and call type");
    # TODO: Experiment with incorporating the imported and non-imported version into one Test::Mockify::Injector instance to let this work
#    is( GetCallCount($injector->getVerifier(), 'ReturnHelloWorld'),  2,"$SubTestName - prove that 'ReturnHelloWorld' was called 2 times, independent of call type");

    my $aParamsCall1 = GetParametersFromMockifyCall($injector->getVerifier(), 'ReturnHelloWorld', 0);
    is(scalar @{$aParamsCall1}, 1 , "$SubTestName - prove amount of parameters");
    is($aParamsCall1->[0], 'German' , "$SubTestName - prove that the value of parameter 1 is 'German'");
#
    ok( WasCalled($injector->getVerifier(), 'HelloSpy'), "$SubTestName - prove verify, independent of scope and call type");
#    is(GetCallCount($injector->getVerifier(),'HelloSpy'), 2,"$SubTestName - prove verify works for spy");
    my $aParamsCallHelloSpy = GetParametersFromMockifyCall($injector->getVerifier(), 'HelloSpy', 0);
    is(scalar @{$aParamsCallHelloSpy}, 1 , "$SubTestName - prove amount of parameters for 'HelloSpy'");
    is($aParamsCallHelloSpy->[0], 'And you are?' , "$SubTestName - prove that the value of parameter 1 of helloSpy is 'And you are?'");
}
#----------------------------------------------------------------------------------------
sub test_MethodAndImportedFunctionHaveTheSameName {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $injector = Test::Mockify::Injector->new('FakeStaticTools');
    my $injectorImported = Test::Mockify::Injector->new('FakeModuleStaticInjection');

    # Perl can't differ between imported and actual methods of a package.
    # Since this package implements a method which is also imported as static function,
    #    the implemented method will override the imported one since the own implementaion is loaded later in time.
    #    (the perl interpreter complains too)
    is(FakeModuleStaticInjection->methodImportedHappyOverride(), 'original in FakeModuleStaticInjection', "$SubTestName - prove return value before mocking!! it is not 'original in FakeStaticTools' as you would expect.");
    is(FakeModuleStaticInjection->methodStaticHappyOverride(), 'original in FakeStaticTools', "$SubTestName - Prove the static call behaves normal");
    
    $injector->mock('HappyOverride')->whenAny()->thenReturn('i am mocked'); # This will override the method and the imported Function
    $injectorImported->mock('HappyOverride')->whenAny()->thenReturn('i am mocked'); # This will override the method and the imported Function
#
    is(FakeModuleStaticInjection->methodImportedHappyOverride(), 'i am mocked', "$SubTestName - prove now it returns always the mock and will hide the perl 'Bug'");
    is(FakeModuleStaticInjection->methodStaticHappyOverride(), 'i am mocked', "$SubTestName - Prove will be mocked as expected");
}
#----------------------------------------------------------------------------------------
sub test_someSelectedMockifyFeatures {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $injector = Test::Mockify::Injector->new('FakeStaticTools');
    $injector->mock('ReturnHelloWorld')->when(String('Error'))->thenThrowError('TestError');
    $injector->mock('ReturnHelloWorld')->when(String('caller'))->thenCall(sub{return 'returnValue'});
    $injector->mock('ReturnHelloWorld')->when(String('undef'), String('abc'))->thenReturnUndef();

    my $injector2 = Test::Mockify::Injector->new('FakeModuleStaticInjection');
    $injector2->mock('overrideMethod')->when(String('override'))->thenReturn('overridden Value');
    $injector2->spy('overrideMethod_spy')->when(String('spyme'));

    #Error
    throws_ok( sub{FakeModuleStaticInjection->useStaticFunction('Error') },
                   qr/TestError/,
                   "$SubTestName - prove if thenThrowError will fail"
    );
    # anonymous function pointer mock
    is(FakeModuleStaticInjection->useStaticFunction('caller'), 'caller: returnValue', "$SubTestName - prove thenCall");
    # undef
    is(FakeModuleStaticInjection->useStaticFunction('undef', 'abc'), 'undef: ', "$SubTestName - prove thenReturnUndef");

    # TODO: Fix. For some reason it starts failing here.
    # normal mock
    is(FakeModuleStaticInjection->overrideMethod('override'), 'overridden Value', "$SubTestName - prove mock Works");
    # normal spy
    FakeModuleStaticInjection->overrideMethod_spy('spyme'); #1
    FakeModuleStaticInjection->overrideMethod_spy('spyme'); #2
    is(GetCallCount($injector2->getVerifier(), 'overrideMethod_spy'), 2, "$SubTestName - prove verify works for override");
}
#----------------------------------------------------------------------------------------
sub test_mockRevertsWhenInjectorGoesOutOfScope {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $originalValue = FakeModuleForMockifyTest::DummyMethodForTestOverriding();
    my $originalValue2 = FakeModuleForMockifyTest::secondDummyMethodForTestOverriding();
    my $mockValue = 'A mock dummy method';
    my $mockValue2 = 'A second mock dummy method';

    {
        my $injector = Test::Mockify::Injector->new('FakeModuleForMockifyTest');
        $injector->mock('DummyMethodForTestOverriding')->when()->thenReturn($mockValue);
        $injector->addMock('secondDummyMethodForTestOverriding', sub { $mockValue2 });

        is(FakeModuleForMockifyTest::DummyMethodForTestOverriding(), $mockValue, "$SubTestName - prove mock is injected");
        is(FakeModuleForMockifyTest::secondDummyMethodForTestOverriding(), $mockValue2, "$SubTestName - prove second mock is injected");

        # make sure GetParametersFromMockifyCall doesn't interfere with releasing the $injector when it goes out of scope
        GetParametersFromMockifyCall($injector->getVerifier(), 'DummyMethodForTestOverriding');
    }

    is(FakeModuleForMockifyTest::DummyMethodForTestOverriding(), $originalValue, "$SubTestName - prove mock is reverted");
    is(FakeModuleForMockifyTest::secondDummyMethodForTestOverriding(), $originalValue2, "$SubTestName - prove second mock is reverted");
}
#----------------------------------------------------------------------------------------
sub test_thisTestIsNotAffectedByPrevious {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    is(FakeModuleForMockifyTest::DummyMethodForTestOverriding(), 'A dummy method', "$SubTestName - prove SUT is not still mocked from previous");
}
#----------------------------------------------------------------------------------------
sub test_mockDogOriginalApproach {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $dog = Dog->new('Dalmatian');
    is($dog->breed(), 'Dalmatian', "$SubTestName - Original is a Dalmatian");

    my $mockify = Test::Mockify->new('Dog', ['Dalmatian']);
    $mockify->mock('breed')->whenAny()->thenReturn('Great Dane');
    my $mockObject = $mockify->getMockObject();

    is($mockObject->breed(), 'Great Dane', "$SubTestName - Mock is a Great Dane");
    is($dog->breed(), 'Dalmatian', "$SubTestName - Original is a Dalmatian");

    ok(WasCalled($mockObject, 'breed'), "$SubTestName - Mocked breed method was called");
}
#----------------------------------------------------------------------------------------
sub test_mockDogStaticApproach {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $dog = Dog->new('Dalmatian');
    is($dog->breed(), 'Dalmatian', "$SubTestName - Original is a Dalmatian");

    my $injector = Test::Mockify::Injector->new('Dog'); # should not call Dog->new() or need constructor parameters
    $injector->mock('breed')->whenAny()->thenReturn('Great Dane');

    is(Dog->breed(), 'Great Dane', "$SubTestName - Mock is a Great Dane");
    is($dog->breed(), 'Great Dane', "$SubTestName - Original is now a Great Dane");

    ok(WasCalled($injector->getVerifier(), 'breed'), "$SubTestName - Mocked breed method was called");
    is(GetCallCount($injector->getVerifier(), 'breed'), 2, "$SubTestName - Called twice");
}
#----------------------------------------------------------------------------------------
sub test_newNotCalled() {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $mockify = Test::Mockify->new('Dog', ['Dalmatian']);
    ok($mockify->getMockObject()->isa('Dog'), "$SubTestName - mock object isa Dog");

    my $injector = Test::Mockify::Injector->new('Dog');
    ok(!$injector->getVerifier()->isa('Dog'), "$SubTestName - verifier isnota Dog");
}


__PACKAGE__->RunTest();