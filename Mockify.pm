package Mockify;
use base qw ( Exporter );
use Tools qw ( Error ExistsMethod IsValid LoadPackage Isa );
use TypeTests qw ( IsInteger IsFloat IsString IsArrayReference IsHashReference IsObjectReference );
use Test::MockObject::Extends;
use DE_EPAGES::Test::Mock::Mockify::MethodCallCounter;
use Data::Dumper;
use feature qw ( switch );
use strict;
our @EXPORT_OK = qw ( GetParametersFromMockifyCall );
use Scalar::Util qw( blessed );
use Test::More;
use Data::Compare;
#----------------------------------------------------------------------------------------
sub new {
    my $class = shift;
    my ( $FakeModulePath, $aFakeParams ) = @_;

    my $self = bless {}, $class;

    LoadPackage( $FakeModulePath );
    my $FakeClass = $FakeModulePath->new( @{$aFakeParams} );
    $self->{'MockedModulePath'} = $FakeModulePath;
    $self->{'MockedModule'} = Test::MockObject::Extends->new( $FakeClass );
    $self->_initMockedModule();

    return $self;
}
#----------------------------------------------------------------------------------------
sub _initMockedModule {
    my $self = shift;

    $self->{'__MockedModule'}->{'__MethodCallCounter'} = DE_EPAGES::Test::Mock::Mockify::MethodCallCounter->new();
    $self->{'__MockedModule'}->{'__isMockified'} = 1;
    $self->_addGetParameterFromMockifyCall();

    return;
}
#========================================================================================
# §function     GetParametersFromMockifyCall
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       GetParametersFromMockifyCall( );
#----------------------------------------------------------------------------------------
# §description  After mocking a method with Mockify framework and using the method,
#               you can use this function to retrive you the Parameters that were 
#               given to the mocked method.
#               If the Mocked Method was called mutiple times you can assess the parameters
#               from a specific call.
#               If Position is not defined it tocks the parameters from the first call.
#               The position acts like an Array so first Element you will get with 0, the second with 1, and so on.
#----------------------------------------------------------------------------------------
# §input        $MockifiedMockedObject | MockifiedMockedObject which was build with Mockify | object
# §input        $MethodName | name of method | string
# §input        $Position |  | Input1Type_boolean_integer_String_object_ref_hash_refarray
# §return       Array with the parameters that were given to the mocked method | array
#========================================================================================
sub GetParametersFromMockifyCall {
    my ( $MockifiedMockedObject, $MethodName, $Position ) = @_;

    if( not blessed $MockifiedMockedObject){
        Error('The first argument must be blessed');
    }
    my $PackageName = ref($MockifiedMockedObject);
    if( not IsValid( $MethodName )){
        Error('Method name must be specified', {'Position'=>$Position, 'Package' => $PackageName});
    }
    if ( not $MockifiedMockedObject->can('__getParametersFromMockifyCall') ){
        Error("$PackageName was not mockified", { 'Position'=>$Position, 'Method' => $MethodName});
    }
    if( not IsValid( $Position ) || not IsInteger( $Position )){
        $Position = 0;
    }

    return $MockifiedMockedObject->__getParametersFromMockifyCall( $MethodName, $Position );
}
#========================================================================================
# §function     WasCalled
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       WasCalled( $MockifiedMockedObject, $MethodName );
#----------------------------------------------------------------------------------------
# §description  returns true if the Method was called
#----------------------------------------------------------------------------------------
# §input        $MockifiedMockedObject | MockifiedMockedObject which was build with Mockify | object
# §input        $MethodName | name of method | string
# §return       $WasCalled | was called | boolean
#========================================================================================
sub WasCalled {
    my ( $MockifiedMockedObject, $MethodName ) = @_;

    my $WasCalled;
    my $AmountOfCalles = GetCallCount( $MockifiedMockedObject, $MethodName );
    if($AmountOfCalles > 0){
        $WasCalled = 1;
    }else{
        $WasCalled = 0;
    }

    return $WasCalled;
}
#========================================================================================
# §function     GetCallCount
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       GetCallCount( $MockifiedMockedObject, $MethodName );
#----------------------------------------------------------------------------------------
# §description  Return a number with the amount of calls, this mockified method was called.
#               Dies if the requested method was not Mockified.
#----------------------------------------------------------------------------------------
# §input        $MockifiedMockedObject | MockifiedMockedObject which was build with Mockify | object
# §input        $MethodName | name of method | string
# §return       Amount Of Calls | integer
#========================================================================================
sub GetCallCount {
    my ( $MockifiedMockedObject, $MethodName ) = @_;

    _TestMockifyObject( $MockifiedMockedObject );
    return $MockifiedMockedObject->{'__MethodCallCounter'}->getAmountOfCalls( $MethodName );
}
#----------------------------------------------------------------------------------------
sub getMockObject {
    my $self = shift;
    return $self->{'MockedModule'};
}
#----------------------------------------------------------------------------------------
sub _TestMockifyObject {
    my ( $MockifiedMockedObject ) = @_;

    my $ObjectPath = ref( $MockifiedMockedObject );
    if( not isValid( $ObjectPath ) ){
        Error( 'Object is not defined' );
    }
    if ( $MockifiedMockedObject->{'__isMockified'} != 1){
        Error( "The Object: '$ObjectPath' is not mockified" );
    }

    return;
}
#========================================================================================
# §function     mock
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       mock( $MethodName, $ReturnValue, $aParameterTypes );
#----------------------------------------------------------------------------------------
# §description  Based on the type and amout of parameters this is a shortcut for:
#               addMock                                 | mock('name', sub {})
#               addMockWithReturnValuemock              | mock('name', 'returnValue')
#               addMockWithReturnValueAndParameterCheck | mock('name', 'returnValue', [{'string'=>'jajaGenau'}])
#----------------------------------------------------------------------------------------
# §input        $MethodName | name of method | String
# §input        $ReturnValue | value which will be returned by the mocked method | integer String object refhash refarray
# §input        $aParameterTypes | differnd parameter types | refarray
#========================================================================================
sub mock {
    my $self = shift;
    my @Parameters = @_;
    my $ParameterAmount = scalar @Parameters;
    if($ParameterAmount == 2){
        my ( $MethodName, $ReturnValueOrFunctionPointer ) = @Parameters;
        if( ref($ReturnValueOrFunctionPointer) eq 'CODE' ){
            $self->addMock($MethodName, $ReturnValueOrFunctionPointer);
        }else{
            $self->addMockWithReturnValue($MethodName, $ReturnValueOrFunctionPointer);
        }
    }
    if($ParameterAmount == 3){
        my ( $MethodName, $ReturnValue, $aParameterTypes ) = @_;
        $self->addMockWithReturnValueAndParameterCheck($MethodName, $ReturnValue, $aParameterTypes);
    }
    return;
}
#========================================================================================
# §function     addMethodSpy
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       addMethodSpy( $MethodName );
#----------------------------------------------------------------------------------------
# §description  Give option to observe a Method while keeping the original functionality.
#----------------------------------------------------------------------------------------
# §input        $MethodName | $MethodName | string
#========================================================================================
sub addMethodSpy {
    my $self = shift;
    my ( $MethodName ) = @_;

    my $PointerOriginalMethod = \&{$self->{'__MockedModulePath'}.'::'.$MethodName};
    $self->addMock( $MethodName, sub {
        $PointerOriginalMethod->( @_ );
    } );

    return;
}
#========================================================================================
# §function     addMethodSpyWithParameterCheck
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       addMethodSpyWithParameterCheck( $MethodName, $aParameterTypes );
#----------------------------------------------------------------------------------------
# §description  Give option to observe a Method while keeping the original functionality.
#               but also check the parameters
#               check, based on the $aParameterTypes if it was called with the correct parameters
#
#               my $aParameterTypes = ['string',{'string' => 'ABCD'}];
#               $Mockify->addMockWithReturnValueAndParameterCheck('myMethod','the return value',$aParameterTypes);
#               my $MyFakeObject = $MockObject->getMockObject();
#               ok( $MyModuleObject->myMethod('Hello','ABCD') ),
#
#               possible parameters types are:
#                   ['string', 'int', 'hashref', 'arrayref', 'object', 'undef', 'any']
#               or with more detail:
#                   [{'string'=>'abcdef'}, {'int' => 123}, {'hashref' => {'key'=>'value'}}, {'arrayref'=>['one', 'two']}, {'object'=> 'PAth::to:Obejct}]
#----------------------------------------------------------------------------------------
# §input        $MethodName | name of method | String
# §input        $aParameterTypes | differnd parameter types | refarray
#========================================================================================
sub addMethodSpyWithParameterCheck {
    my $self = shift;
    my ( $MethodName, $aParameterTypes ) = @_;

    $self->_checkParameterTypesForMethod( $MethodName , $aParameterTypes );
    my $PointerOriginalMethod = \&{$self->{'__MockedModulePath'}.'::'.$MethodName};
     $self->addMock( $MethodName, sub {
            my $MockedSelf = shift;
            my @MockedParameters = @_;
            $self->_storeParameters( $MethodName, $MockedSelf, \@MockedParameters );
            $self->_testParameterTypes( $MethodName , $aParameterTypes, \@MockedParameters );
            $self->_testParameterAmount( $MethodName , $aParameterTypes, \@MockedParameters );
            $PointerOriginalMethod->($MockedSelf, @MockedParameters);
    } );
    return;
}
#----------------------------------------------------------------------------------------
sub addMock {
    my $self = shift;
    my ( $MethodName, $rSub ) = @_;

    ExistsMethod( $self->{'MockedModulePath'}, $MethodName );
    $self->{'MockedModule'}->mock( $MethodName, $rSub );

    return;
}
#----------------------------------------------------------------------------------------
sub addMockWithReturnValue {
    my $self = shift;
    my ( $MethodName, $ReturnValue ) = @_;

    $self->addMock($MethodName, sub {
        my $MockedSelf = shift;
        my $ParameterListSize = scalar @_;

        if ( $ParameterListSize > 0 ){
            Error('UnexpectedParameter',{
            'Method' => "$self->{'MockedModulePath'}::$MethodName",
            'ParameterList' => "(@_)",
            'AmountOfUnexpectedParameters' => $ParameterListSize,
            } );
        }

        return $ReturnValue; #return of inner sub
        } );

    return;
}
#----------------------------------------------------------------------------------------
sub addMockWithReturnValueAndParameterCheck {
    my $self = shift;
    my ( $MethodName, $ReturnValue, $aParameterTypes ) = @_;

    if ( not IsArrayReference( $aParameterTypes ) ){
        Error( 'ParameterTypesNotProvided', {
            'Method' => $self->{'MockedModulePath'}."::$MethodName",
            'ParameterList' => $aParameterTypes,
        } );
    }

    $self->addMock(
        $MethodName,
        sub{
            my $MockedSelf = shift;
            my @MockedParameters = @_;

            $self->_storeParameters( $MethodName, $MockedSelf, \@MockedParameters );
            $self->_testParameterAmount( $MethodName , $aParameterTypes, \@MockedParameters );
            $self->_testParameterTypes( $MethodName , $aParameterTypes, \@MockedParameters );

            return $ReturnValue;
        }
    );

    return;
}
#----------------------------------------------------------------------------------------
sub _storeParameters {
my $self = shift;

    my ( $MethodName, $MockedSelf, $aMockedParameters ) = @_;
    push( @{$MockedSelf->{$MethodName.'_MockifyParams'}}, $aMockedParameters );

    return;
}
#----------------------------------------------------------------------------------------
sub _testParameterTypes {
    my $self = shift;
    my ( $MethodName, $aExpectedParameterTypes, $aActualInputParameters ) = @_;

    my @TestParameters = @{$aExpectedParameterTypes};
    my @MockedParameters = @{$aActualInputParameters};
    my $MockedParametersSize = scalar @MockedParameters;
    for ( my $i = 0; $i < $MockedParametersSize; $i++ ) {
        my $TypeTestResult = $self->_testParameterType("Parameter[$i]", $MockedParameters[$i], $TestParameters[$i], $MethodName );
        if ( ! $TypeTestResult ){
            Error( 'UnknownParametertype', {
            'Method' => $self->{'MockedModulePath'}."::$MethodName",
            'UnknownParameterType' => $self->_getParameterType( $TestParameters[$i] ),
            'ParameterNumber'=> $i,
            } );
        }
    }

    return;
}
#----------------------------------------------------------------------------------------
sub _testParameterType {
    my $self = shift;
    my ( $ParameterName, $Value, $TestParameter, $MethodName ) = @_;

    my $TestParameterType = $self->_getParameterType( $TestParameter );
    given ( $TestParameterType ) {
        when( 'string' ) {
        $self->_testExpectedString( $ParameterName,$Value, $TestParameter ,$MethodName );
        }
        when( 'int' ) {
        $self->_testExpectedInt( $ParameterName,$Value, $TestParameter, $MethodName );
        }
        when( 'hashref' ) {
        $self->_testExpectedHashRef( $ParameterName,$Value, $TestParameter, $MethodName );
        }
        when( 'arrayref' ) {
        $self->_testExpectedArrayRef( $ParameterName,$Value, $TestParameter, $MethodName );
        }
        when( 'object' ) {
        $self->_testExpectedObject( $ParameterName,$Value, $TestParameter,$MethodName );
        }
        when( 'undef' ) {
        $self->_testUndefind( $ParameterName,$Value,$MethodName );
        }
        when( 'any' ) {
            return 1;
        }
        default {
        return 0;
        }
    }

    return 1;
}
#----------------------------------------------------------------------------------------
sub _addGetParameterFromMockifyCall {
    my $self = shift;

    $self->{'MockedModule'}->mock('__getParametersFromMockifyCall',
        sub{
            my $MockedSelf = shift;
            my ( $MethodName, $Position ) = @_;

            my $aParametersFromAllCalls = $MockedSelf->{$MethodName.'_MockifyParams'};
            if( ref $aParametersFromAllCalls ne 'ARRAY' ){
                Error( "$MethodName was not called" );
            }
            if( scalar @{$aParametersFromAllCalls} < $Position ) {
                Error( "$MethodName was not called ".( $Position+1 ).' times',{
                'Method' => "$MethodName",
                'Postion' => $Position,
                } );
            }
            else {
                my $ParameterFromMockifyCall = $MockedSelf->{$MethodName.'_MockifyParams'}[$Position];
                return $ParameterFromMockifyCall;
            }
            return;
        }
    );

    return;
}
#----------------------------------------------------------------------------------------
sub _getParameterType {
    my $self = shift;
    my ( $TestParameter ) = @_;

    my $TestParameterType = undef;
    if( IsHashReference( $TestParameter ) ){
        my @Keys = keys %{$TestParameter};
        $TestParameterType = $Keys[0];
    } else {
        $TestParameterType = $TestParameter;
    }

    return $TestParameterType;
}
#----------------------------------------------------------------------------------------
sub _testParameterAmount {
    my $self = shift;
    my ( $MethodName , $aExpectedParameterTypes, $aActualInputParameters ) = @_;

    my $AmountExpectedParameterTypes = scalar @{$aExpectedParameterTypes};
    my $AmountActualInputParameters = scalar @{$aActualInputParameters};
    if( $AmountActualInputParameters != $AmountExpectedParameterTypes ){
        Error( 'WrongAmountOfParameters', {
            'Method' => $self->{'MockedModulePath'}."::$MethodName",
            'ExpectedAmount' => $AmountExpectedParameterTypes,
            'ActualAmount' => $AmountActualInputParameters,
        } );
    }

    return;
}
#----------------------------------------------------------------------------------------
sub _testExpectedString {
    my $self = shift;
    my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;

    if ( not IsString( $Value ) ) {
        Error( "$Name is not a String", {
            'Method' => $self->{'MockedModulePath'}."::$MethodName",
            'Value' => $Value
        });
    }
    if( IsHashReference( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        if( $Value ne $ExpectedValue ){
            Error( "$Name unexpected value", {
                'Method' => $self->{'MockedModulePath'}."::$MethodName",
                'ActualValue' => $Value,
                'ExpectedValue' => $ExpectedValue,
            });
        }
    }

    return;
}
#----------------------------------------------------------------------------------------
sub _testExpectedInt {
    my $self = shift;
    my ( $Name, $Value, $hTestParameterType, $MethodName ) = @_;

    if ( not IsInteger( $Value ) ) {
        Error( "$Name is not an Integer", {
            'Method' => $self->{'MockedModulePath'}."::$MethodName",
            'Value' => $Value
            });
    }
    if( IsHashReference( $hTestParameterType ) ){
        my @Values = values %{$hTestParameterType};
        my $ExpectedValue = $Values[0];
        if( $Value != $ExpectedValue ){
            Error( "$Name unexpected value", {
                'Method' => $self->{'MockedModulePath'}."::$MethodName",
                'ActualValue' => $Value,
                'ExpectedValue' => $ExpectedValue,
            });
        }
    }

    return;
}
#----------------------------------------------------------------------------------------
sub _testUndefind {
    my $self = shift;
    my ( $Name, $Value, $MethodName ) = @_;

    if ( IsValid( $Value ) ) {
        Error( "$Name is not undefined", {
            'Method' => $self->{'MockedModulePath'}."::$MethodName",
            'Value' => $Value
        });
    }

    return;
}
#----------------------------------------------------------------------------------------
sub _testExpectedHashRef {
    my $self = shift;
    my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;

    if ( not IsHashReference( $Value ) ) {
        Error( "$Name is not a HashRef", {
            'Method' => $self->{'MockedModulePath'}."::$MethodName",
            'Value' => $Value
        });
    }
    if( IsHashReference( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        my $Compare = Data::Compare->new();
        if( not $Compare->Cmp($Value,$ExpectedValue) ){
        my $DumpedValue = Dumper( $Value );
        my $DumpedExpected = Dumper( $ExpectedValue );
            Error( "$Name unexpected value", {
                'Method' => $self->{'__MockedModulePath'}."->$MethodName(???)",
                'got value' => $DumpedValue,
                'expected value' => $DumpedExpected,
            } );
        }
    }

    return;
}
#----------------------------------------------------------------------------------------
sub _testExpectedArrayRef {
    my $self = shift;
    my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;

    if ( not IsArrayReference( $Value ) ) {
        Error( "$Name is not an ArrayRef", {
        'Method' => $self->{'MockedModulePath'}."::$MethodName",
        'Value' => $Value
        } );
    }
    if( IsHashReference( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        my $Compare = Data::Compare->new();
        if( not $Compare->Cmp($Value,$ExpectedValue) ){
        my $DumpedValue = Dumper( $Value );
        my $DumpedExpected = Dumper( $ExpectedValue );
            Error( "$Name unexpected value", {
                'Method' => $self->{'__MockedModulePath'}."->$MethodName(???)",
                'got value' => $DumpedValue,
                'expected value' => $DumpedExpected,
            } );
        }
    }

    return;
}
#----------------------------------------------------------------------------------------
sub _testExpectedObject {
    my $self = shift;
    my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;

    if ( not IsObjectReference($Value) ) {
        Error( "$Name is not a Object", {
            'Method' => $self->{'MockedModulePath'}."::$MethodName",
            'Value' => $Value
        } );
    }
    if( IsHashReference( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        if( not Isa( $Value, $ExpectedValue ) ){
            Error( "$Name unexpected value", {
                'Method' => $self->{'MockedModulePath'}."::MethodName",
                'ActualObjectType' => blessed($Value),
                'ExpectedObjectType' => $ExpectedValue,
            });
        }
    }

    return;
}
#----------------------------------------------------------------------------------------
sub _checkParameterTypesForMethod {
    my $self = shift;
    my ( $MethodName, $aParameterTypes ) = @_;

    if ( not ( defined $aParameterTypes ) or not IsArrayReference( $aParameterTypes )){
        Error( 'ParameterTypesNotProvided', {
            'Method' => $self->{'MockedModulePath'}."::MethodName",
        } );
    }

    return;
}

1;