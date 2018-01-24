package Mockify_Injector;

use FindBin;
use lib ($FindBin::Bin);

use parent 'TestBase';
use Test::Exception;
use Test::Mockify;
use Test::Mockify::Injector;
use Test::Mockify::Verify qw (WasCalled GetCallCount);
use Test::More;
use warnings;
use Data::Dumper;

use strict;
no warnings 'deprecated';

use FakeModuleForMockifyTest;
use FakeModuleWithoutNew;

sub testPlan {
    my $self = shift;
    $self->mocked_method_is_injected();
    $self->mocked_methods_are_injected();
    $self->injected_mock_method_reverts_when_injector_goes_out_of_scope();
    $self->injector_throws_error_when_incorrect_type_received();
    $self->injected_spy_method_receives_expected_parameters();
    $self->injected_methods_affect_call_metadata();
    $self->useMethodWhichUsesStaticFunction();
    $self->useMethodWhichUsesStaticFunction_withHelperMethod();
}
#----------------------------------------------------------------------------------------
sub mocked_method_is_injected {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    note($SubTestName);

    is(FakeModuleForMockifyTest::DummyMethodForTestOverriding(), 'A dummy method',
        'FakeModuleForMockifyTest::DummyMethodForTestOverriding returns original value');

    my $mockBuilder = Test::Mockify->new('FakeModuleForMockifyTest');
    my $injector = Test::Mockify::Injector->new();

    $mockBuilder->mock('DummyMethodForTestOverriding')->when()->thenReturn('A mock dummy method');
    $injector->inject($mockBuilder);

    is(FakeModuleForMockifyTest::DummyMethodForTestOverriding(), 'A mock dummy method',
        'FakeModuleForMockifyTest::DummyMethodForTestOverriding returns mock value after injection');
}
#----------------------------------------------------------------------------------------
sub mocked_methods_are_injected {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    note($SubTestName);

    is(FakeModuleForMockifyTest::DummyMethodForTestOverriding(), 'A dummy method',
        'FakeModuleForMockifyTest::DummyMethodForTestOverriding returns original value');
    is(FakeModuleForMockifyTest::secondDummyMethodForTestOverriding(), 'A second dummy method',
        'FakeModuleForMockifyTest::secondDummyMethodForTestOverriding returns original value');
    is(FakeModuleWithoutNew::DummyMethodForTestOverriding(), 'A dummy method',
        'FakeModuleWithoutNew::DummyMethodForTestOverriding returns original value');

    my $mockBuilder1 = Test::Mockify->new('FakeModuleForMockifyTest');
    my $mockBuilder2 = Test::Mockify->new('FakeModuleWithoutNew');
    my $injector = Test::Mockify::Injector->new();

    $mockBuilder1->mock('DummyMethodForTestOverriding')->when()->thenReturn('A mock dummy method');
    $mockBuilder1->mock('secondDummyMethodForTestOverriding')->when()->thenReturn('A second mock dummy method');
    $mockBuilder2->mock('DummyMethodForTestOverriding')->when()->thenReturn('A third mock dummy method');
    $injector->inject($mockBuilder1);
    $injector->inject($mockBuilder2);

    is(FakeModuleForMockifyTest::DummyMethodForTestOverriding(), 'A mock dummy method',
        'FakeModuleForMockifyTest::DummyMethodForTestOverriding returns mock value after injection');
    is(FakeModuleForMockifyTest::secondDummyMethodForTestOverriding(), 'A second mock dummy method',
        'FakeModuleForMockifyTest::secondDummyMethodForTestOverriding returns mock value after injection');
    is(FakeModuleWithoutNew::DummyMethodForTestOverriding(), 'A third mock dummy method',
        'FakeModuleWithoutNew::DummyMethodForTestOverriding returns mock value after injection');
}
#----------------------------------------------------------------------------------------
sub injected_mock_method_reverts_when_injector_goes_out_of_scope {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    note($SubTestName);

    my $originalValue = FakeModuleForMockifyTest::DummyMethodForTestOverriding();
    my $mockValue = 'A mock dummy method';

    my $mockBuilder = Test::Mockify->new('FakeModuleForMockifyTest');
    $mockBuilder->mock('DummyMethodForTestOverriding')->when()->thenReturn($mockValue);

    {
        my $injector = Test::Mockify::Injector->new();
        $injector->inject($mockBuilder);

        is(FakeModuleForMockifyTest::DummyMethodForTestOverriding(), $mockValue,
            'FakeModuleForMockifyTest::DummyMethodForTestOverriding returns mock value after injection');
    }

    is(FakeModuleForMockifyTest::DummyMethodForTestOverriding(), $originalValue,
        'FakeModuleForMockifyTest::DummyMethodForTestOverriding returns original value after injector goes out of scope');
}
#----------------------------------------------------------------------------------------
sub injector_throws_error_when_incorrect_type_received {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    note($SubTestName);

    my $mockBuilder = Test::Mockify->new('FakeModuleForMockifyTest');
    my $injector = Test::Mockify::Injector->new();

    my $RegEx = $self->_getErrorRegEx_ErrorInjectorReceivesIncorrectType();
    throws_ok(
        sub { $injector->inject($mockBuilder->getMockObject()); },
        qr/^$RegEx$/,
        "Incorrect type received by injector"
    );
    return;
}
#----------------------------------------------------------------------------------------
sub injected_spy_method_receives_expected_parameters {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    note($SubTestName);

    my $mockBuilder = Test::Mockify->new('FakeModuleWithoutNew');
    $mockBuilder->spy('dummyMethodWithParameterReturn')->whenAny();

    my $functionValue = FakeModuleWithoutNew::dummyMethodWithParameterReturn('Argument1', 'Argument2');
    my $methodValue = FakeModuleWithoutNew->dummyMethodWithParameterReturn('Argument1', 'Argument2');

    my $injector = Test::Mockify::Injector->new();
    $injector->inject($mockBuilder);

    is(FakeModuleWithoutNew::dummyMethodWithParameterReturn('Argument1', 'Argument2'), $functionValue,
        'Return value of Function call is identical before and after spy injection');
    is(FakeModuleWithoutNew->dummyMethodWithParameterReturn('Argument1', 'Argument2'), $methodValue,
        'Return value of Method call is identical before and after spy injection');
}
#----------------------------------------------------------------------------------------
sub injected_methods_affect_call_metadata {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    note($SubTestName);

    my $mockBuilder = Test::Mockify->new('FakeModuleWithoutNew');
    $mockBuilder->spy('DummyMethodForTestOverriding')->when();

    my $mockObject = $mockBuilder->getMockObject();

    is(GetCallCount($mockObject, 'DummyMethodForTestOverriding'), 0, 'Call count is 0 prior to calling $mockObject->DummyMethodForTestOverriding');

    $mockObject->DummyMethodForTestOverriding();

    is(GetCallCount($mockObject, 'DummyMethodForTestOverriding'), 1, 'Call count is 1 after calling $mockObject->DummyMethodForTestOverriding');

    my $injector = Test::Mockify::Injector->new();
    $injector->inject($mockBuilder);

    FakeModuleWithoutNew::DummyMethodForTestOverriding();

    is(GetCallCount($mockObject, 'DummyMethodForTestOverriding'), 2, 'Call count is 2 after calling the injected FakeModuleWithoutNew::DummyMethodForTestOverriding');
}
#----------------------------------------------------------------------------------------
sub useMethodWhichUsesStaticFunction {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $SUT = FakeModuleForMockifyTest->new();
    is($SUT->useStaticFunction('Pre'), 'Pre Hallo Welt',"$SubTestName - test the not mocked version of ReturnHelloWorld ");

    my $Mockify = Test::Mockify->new('FakeStaticTools');
    $Mockify->mock('ReturnHelloWorld')->whenAny()->thenReturn('Saluton mondon');
    {
        my $injector = Test::Mockify::Injector->new();
        $injector->inject($Mockify);

        is($SUT->useStaticFunction('Pre'), 'Pre Saluton mondon',"$SubTestName - proves the internal call with FakeStaticTools::ReturnHelloWorld");
        is($SUT->useImportedStaticFunction('Pre'), 'Pre Saluton mondon',"$SubTestName - proves the internal call with imported ReturnHelloWorld ");
    }
    is($SUT->useStaticFunction('Pre'), 'Pre Hallo Welt',"$SubTestName - test the not mocked version of ReturnHelloWorld ");
}
#----------------------------------------------------------------------------------------
sub useMethodWhichUsesStaticFunction_withHelperMethod {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $SUT = FakeModuleForMockifyTest->new();
    is($SUT->useStaticFunction('Pre'), 'Pre Hallo Welt',"$SubTestName - test the not mocked version of ReturnHelloWorld ");

    my $Mockify = Test::Mockify->new('FakeStaticTools');
    $Mockify->mock('ReturnHelloWorld')->whenAny()->thenReturn('Saluton mondon');
    {
        #The var $injector needs to be here in this scope, this is a bit unexpected (magic)
        my $injector = $self->_helperMethodForInjection($Mockify);

        is($SUT->useStaticFunction('Pre'), 'Pre Saluton mondon',"$SubTestName - proves the internal call with FakeStaticTools::ReturnHelloWorld");
        is($SUT->useImportedStaticFunction('Pre'), 'Pre Saluton mondon',"$SubTestName - proves the internal call with imported ReturnHelloWorld ");
    }
    is($SUT->useStaticFunction('Pre'), 'Pre Hallo Welt',"$SubTestName - test the not mocked version of ReturnHelloWorld ");
}

#------------------------------------------------------------------------
sub _helperMethodForInjection {
    my $self = shift;
    my ($Mockify) = @_;
    my $injector = Test::Mockify::Injector->new();
        $injector->inject($Mockify);
    return $injector;
}
#------------------------------------------------------------------------
sub _getErrorRegEx_ErrorInjectorReceivesIncorrectType {
    return <<'END_REGEX';
Object must be an instance of Test::Mockify:
MockedMethod: -not set-
Data:\{\}
Test::Mockify::Injector::inject,.*t[/\\]Mockify_Injector.t\(line \d+\)
Test::Exception::throws_ok,.*t[/\\]Mockify_Injector.t\(line \d+\)
Mockify_Injector::injector_throws_error_when_incorrect_type_received,.*t[/\\]Mockify_Injector.t\(line \d+\)
Mockify_Injector::testPlan,.*t[/\\]TestBase.pm\(line \d+\)
TestBase::RunTest,.*t[/\\]Mockify_Injector.t\(line \d+\)
END_REGEX
END;
}

__PACKAGE__->RunTest();