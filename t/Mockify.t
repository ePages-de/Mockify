package t::Mockify;
use base t::TestBase;
use Mockify qw (GetParametersFromMockifyCall);
use Test::More;
use Test::Exception;
use strict;

sub testPlan {
    my $self = shift;
    $self->test_MockModule();
    $self->test_MockModule_withParameter();
    $self->test_MockModule_addMock();
    $self->test_MockModule_addMock_overrideNotExistingMethod();
    $self->test_MockModule_AddMockWithReturnValue();
    $self->test_MockModule_AddMockWithReturnValue_UnexpectedParameterInCall();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedString();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedInteger();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedHash();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedArray();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedObject();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_EmptyString();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongAmountOfParameters();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_Int();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_String();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_HashRef();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_ArrayRef();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_Object();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_Undef();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_withoutParameterTypes();
    $self->test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongParameterName();
    $self->test_MockModule_GetParametersFromMockifyCall();
    $self->test_MockModule_GetParametersFromMockifyCall_Multicalls_PositionBiggerThenRealCalls();
    $self->test_MockModule_GetParametersFromMockifyCall_Multicalls_PositionNotInteger();
    $self->test_MockModule_GetParametersFromMockifyCall_MultiParams();
    $self->test_MockModule_GetParametersFromMockifyCall_Multicalls_MultiParams();
    $self->test_MockModule_GetParametersFromMockifyCall_WithoutCallingTheMethod();
    $self->test_MockModule_GetParametersFromMockifyCall_ForNotMockifyObject();

}
#----------------------------------------------------------------------------------------
sub test_MockModule {
    my $self = shift;
    my $SubTestName = (caller(0))[3];
    
    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $MockedFakeModule = $MockObject->getMockObject();
    is($MockedFakeModule->DummmyMethodForTestOverriding(),'A dummmy method',"$SubTestName - test if the loaded module still have the unmocked methods");

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_withParameter {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = ['one', 'two'];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $MockedFakeModule = $MockObject->getMockObject();
    is_deeply($MockedFakeModule->returnParameterListNew(), $aParameterList, "$SubTestName - test if the parameter for the constuctor are handover correctly");

    return;    
}
#----------------------------------------------------------------------------------------
sub test_MockModule_addMock {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $TestMethodPointer = sub {
        return 'return value of overridden Method';
    };
    $MockObject->addMock('DummmyMethodForTestOverriding', $TestMethodPointer );
    my $MockedFakeModule = $MockObject->getMockObject();
    is($MockedFakeModule->DummmyMethodForTestOverriding(),'return value of overridden Method',"$SubTestName - test if the loaded module can be overridden and the return value will be returned");

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_addMock_overrideNotExistingMethod {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    throws_ok(
        sub { $MockObject->addMockWithReturnValue('aNotExistingMethod', sub {}); },
        qr/t::FakeModuleForMockifyTest donsn't have a method like: aNotExistingMethod/,
        "$SubTestName - test if the mocked method throw an Error if the method don't exists in the module"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValue {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    $MockObject->addMockWithReturnValue('DummmyMethodForTestOverriding', 'This is a return value');
    my $MockedFakeModule = $MockObject->getMockObject();
    is($MockedFakeModule->DummmyMethodForTestOverriding(),'This is a return value',"$SubTestName - test if the loaded module can be overridden and the return value will be returned");

    return
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValue_UnexpectedParameterInCall {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    $MockObject->addMockWithReturnValue('DummmyMethodForTestOverriding', 'SomeReturnValue');
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding('anUnexpectedParameter') },
        qr/UnexpectedParameter:{ParameterList='\(anUnexpectedParameter\)',AmountOfUnexpectedParameters=1}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test if the mocked method was called with the wrong amount of parameters"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $aParameterCheckList = ['string','int','undef','hashref', 'arrayref', 'object',];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $aParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    my $TestObject = bless({}, 'Test::Object');
    my @Parameters = ('Hello', 12389, undef, {}, [], $TestObject); ## no critic (ProhibitMagicNumbers RequireNumberSeparators)
    is(
        $MockedFakeModule->DummmyMethodForTestOverriding( @Parameters ),
        'This is a return value',"$SubTestName - tests if the parameter list check is working"
    );
    is_deeply(
        GetParametersFromMockifyCall($MockedFakeModule,'DummmyMethodForTestOverriding'),
        \@Parameters,
        "$SubTestName - tests if the parameter is stored correct in the mock object"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedString {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = [{'string'=>'ABC123'}];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    is(
        $MockedFakeModule->DummmyMethodForTestOverriding( 'ABC123' ),
        'This is a return value',"$SubTestName - tests if the parameter list check for string is working"
    );
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding( 'wrong String' ) },
        qr/Parameter\[0\] unexpected value:{ExpectedValue='ABC123',ActualValue='wrong String'}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test if a wrong value will be found."
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedInteger {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = [{'int'=>666}];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    is(
        $MockedFakeModule->DummmyMethodForTestOverriding( 666 ),
        'This is a return value',"$SubTestName - tests if the parameter list check for integer is working"
    );
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding( 123456 ) },
        qr/Parameter\[0\] unexpected value:{ExpectedValue=666,ActualValue=123456}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test if a wrong value will be found."
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedHash {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = [{'hashref'=>{'eins'=>'value'}}];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    my $hCorrectParameter = {'eins'=>'value'};
    is(
        $MockedFakeModule->DummmyMethodForTestOverriding( $hCorrectParameter ),
        'This is a return value',"$SubTestName - tests if the parameter list check for hash is working"
    );
    my $hWrongParameter = {'zwei'=>'value'};
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding( $hWrongParameter ) },
        qr/Parameter\[0\] unexpected value:{'expected value/,## no critic (ProhibitComplexRegexes)
        "$SubTestName - test if a wrong value will be found."
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedArray {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = [{'arrayref'=>['eins','zwei']}];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    my $aCorrectParameter = ['eins','zwei'];
    is(
        $MockedFakeModule->DummmyMethodForTestOverriding( $aCorrectParameter ),
        'This is a return value',"$SubTestName - tests if the parameter list check is working");
    my $aWrongParameter = ['eins'];
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding( $aWrongParameter ) },
        qr/Parameter\[0\] unexpected value:{ExpectedValue=/,
        "$SubTestName - test if a wrong value will be found."
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_ExpectedObject {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = [{'object'=>'Test::Object'}];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    my $TestObject = bless({},'Test::Object');
    is(
        $MockedFakeModule->DummmyMethodForTestOverriding( $TestObject ),
        'This is a return value',"$SubTestName - tests if the parameter list check is working"
    );
    my $WrongTestObject = bless({},'Wrong::Test::Object');
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding( $WrongTestObject ) },
        qr/Parameter\[0\] unexpected value:{ExpectedObjectType='Test::Object',ActualObjectType='Wrong::Test::Object'}\nMockedMethod=t::FakeModuleForMockifyTest::MethodName/,
        "$SubTestName - test if a wrong value will be found."
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_EmptyString {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = ['string'];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    is(
        $MockedFakeModule->DummmyMethodForTestOverriding( '' ),
        'This is a return value',"$SubTestName - tests if the parameter list check is working"
    );
    my ( $FirstParam ) = @{GetParametersFromMockifyCall($MockedFakeModule,'DummmyMethodForTestOverriding')};
    is( $FirstParam, '', "$SubTestName - tests if a empty string is an allowed value");

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongAmountOfParameters {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = ['string','string'];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding('Hello') },
        qr/WrongAmountOfParameters:{ActualAmount=1,ExpectedAmount=2}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test the Error if the Dummy Method don't get enough parameters"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_Int {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = ['int'];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding('123NotANumber321') },
        qr/Parameter\[0\] is not an Integer:{Value='123NotANumber321'}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test the Error if method is called with wrong type"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_String {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = ['string'];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding(['Not','aString']) },
        qr/Parameter\[0\] is not a String:{Value=\['Not','aString'\]}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test the Error if method is called with wrong type"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_HashRef {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = ['hashref'];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding('NotAHashRef') },
        qr/Parameter\[0\] is not a HashRef:{Value='NotAHashRef'}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test the Error if method is called with wrong type"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_ArrayRef {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = ['arrayref'];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding('NotAnArrayRef') },
        qr/Parameter\[0\] is not an ArrayRef:{Value='NotAnArrayRef'}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test the Error if method is called with wrong type"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_Object {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = ['object'];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding('NotAObject') },
        qr/Parameter\[0\] is not a Object:{Value='NotAObject'}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test the Error if method is called with wrong type"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongDataTypeFor_Undef {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = ['undef'];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding('NotUndef') },
        qr/Parameter\[0\] is not undefined:{Value='NotUndef'}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test the Error if method is called with wrong type"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_withoutParameterTypes {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    throws_ok( sub {
        $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value'); },
        qr/ParameterTypesNotProvided:{ParameterList=undef}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test if the mocked method was called with the wrong amount of parameters"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_AddMockWithReturnValueAndParameterCheck_WrongParameterName {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    my $ParameterCheckList = ['WrongType'];
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', 'This is a return value', $ParameterCheckList);
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { $MockedFakeModule->DummmyMethodForTestOverriding('NotUndef') },
        qr/UnknownParametertype:{UnknownParameterType='WrongType',ParameterNumber=0}\nMockedMethod=t::FakeModuleForMockifyTest::DummmyMethodForTestOverriding/,
        "$SubTestName - test the Error if method is called with wrong type"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_GetParametersFromMockifyCall {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', undef, [{'string' => 'InputValueToBeCheckAfterwords'}]);
    my $MockedFakeModule = $MockObject->getMockObject();
    $MockedFakeModule->DummmyMethodForTestOverriding('InputValueToBeCheckAfterwords');
    my ($Parameter_DummmyMethodForTestOverriding) = @ {GetParametersFromMockifyCall($MockedFakeModule,'DummmyMethodForTestOverriding')};
    is(
        $Parameter_DummmyMethodForTestOverriding,
        'InputValueToBeCheckAfterwords',
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_GetParametersFromMockifyCall_Multicalls_PositionBiggerThenRealCalls {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', undef, [{'string' => 'InputValueToBeCheckAfterwords'}]);
    my $MockedFakeModule = $MockObject->getMockObject();
    $MockedFakeModule->DummmyMethodForTestOverriding('InputValueToBeCheckAfterwords');
    throws_ok(
        sub { GetParametersFromMockifyCall($MockedFakeModule,'DummmyMethodForTestOverriding', 3) },
        qr/DummmyMethodForTestOverriding was not called 4 times/,
        "$SubTestName - test the Error if function was call and we didn't use the mocked method before"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_GetParametersFromMockifyCall_Multicalls_PositionNotInteger {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', undef, [{'string' => 'InputValueToBeCheckAfterwords'}]);
    my $MockedFakeModule = $MockObject->getMockObject();
    $MockedFakeModule->DummmyMethodForTestOverriding('InputValueToBeCheckAfterwords');
    throws_ok(
        sub { GetParametersFromMockifyCall($MockedFakeModule,'DummmyMethodForTestOverriding', 'NotANumber') },
        qr/Position must be an integer:{Position='NotANumber'}/,
        "$SubTestName - test the Error if function was call and we didn't use the mocked method before"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_GetParametersFromMockifyCall_MultiParams {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', undef, ['string','undef',{'object' => 'Test::Object'}]);
    my $MockedFakeModule = $MockObject->getMockObject();
    my $TestObject = bless({},'Test::Object');
    $MockedFakeModule->DummmyMethodForTestOverriding('FirstInput', undef, $TestObject);
    my ($Parameter_String, $Parameter_Undef, $Parameter_Object, $Parameter_NotDefined) = @ {GetParametersFromMockifyCall($MockedFakeModule,'DummmyMethodForTestOverriding')};
    is(
        $Parameter_String,
        'FirstInput',
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params (first element)"
    );
    is(
        $Parameter_Undef,
        undef,
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params (second element)"
    );
    is(
        $Parameter_Object,
        $TestObject,
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params (third element)"
    );
    is(
        $Parameter_NotDefined,
        undef,
        "$SubTestName - test the if the GetParametersFromMockifyCall does not return a 4th param (fourth element)"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_GetParametersFromMockifyCall_Multicalls_MultiParams {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', undef, ['string','undef',{'object' => 'Test::Object'}]);
    my $MockedFakeModule = $MockObject->getMockObject();
    my $TestObject = bless({},'Test::Object');
    $MockedFakeModule->DummmyMethodForTestOverriding('FirstInput', undef, $TestObject);
    my $TestObjectSecondCall = bless({'Something' => 'Inside'},'Test::Object');
    $MockedFakeModule->DummmyMethodForTestOverriding('SecondCall_FirstInput', undef, $TestObjectSecondCall);
    my ($Parameter_String, $Parameter_Undef, $Parameter_Object) = @ {GetParametersFromMockifyCall($MockedFakeModule,'DummmyMethodForTestOverriding', 0)};
    is(
        $Parameter_String,
        'FirstInput',
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params (first element)"
    );
    is(
        $Parameter_Undef,
        undef,
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params (second element)"
    );
    is(
        $Parameter_Object,
        $TestObject,
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params (third element)"
    );
    my ($Parameter_String_Second, $Parameter_Undef_Second, $Parameter_Object_Second) = @ {GetParametersFromMockifyCall($MockedFakeModule,'DummmyMethodForTestOverriding',1)};
    is(
        $Parameter_String_Second,
        'SecondCall_FirstInput',
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params for second call (first element)"
    );
    is(
        $Parameter_Undef_Second,
        undef,
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params for second call (second element)"
    );
    is_deeply(
        $Parameter_Object_Second,
        $TestObjectSecondCall,
        "$SubTestName - test the if the GetParametersFromMockifyCall return the right params for second call (third element)"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_GetParametersFromMockifyCall_WithoutCallingTheMethod {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $aParameterList = [];
    my $MockObject = $self->_createMockObject($aParameterList);
    $MockObject->addMockWithReturnValueAndParameterCheck('DummmyMethodForTestOverriding', undef, ['string']);
    my $MockedFakeModule = $MockObject->getMockObject();
    throws_ok(
        sub { GetParametersFromMockifyCall($MockedFakeModule,'DummmyMethodForTestOverriding') },
        qr/DummmyMethodForTestOverriding was not called/,
        "$SubTestName - test the Error if function was call and we didn't use the mocked method before"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub test_MockModule_GetParametersFromMockifyCall_ForNotMockifyObject {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $NotMockifyObject = t::FakeModuleForMockifyTest->new();
    throws_ok(
        sub { GetParametersFromMockifyCall($NotMockifyObject,'DummmyMethodForTestOverriding') },
        qr/t::FakeModuleForMockifyTest donsn't have a method like: __getParametersFromMockifyCall:{}/,
        "$SubTestName - test the Error if function was call and we didn't use the mocked method before"
    );

    return;
}
#----------------------------------------------------------------------------------------
sub _createMockObject {
    my $self = shift;
    my ($aParameterList) = @_;

    my $MockObject = Mockify->new( 't::FakeModuleForMockifyTest', $aParameterList );

    return $MockObject;
}
__PACKAGE__->RunTest();