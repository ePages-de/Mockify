package Devel::Mockify;
use base qw ( Exporter );
use Devel::Mockify::Tools qw ( Error ExistsMethod IsValid LoadPackage Isa );
use Devel::Mockify::TypeTests qw ( IsInteger IsFloat IsString IsArrayReference IsHashReference IsObjectReference );
use Devel::Mockify::MethodCallCounter;
use Test::MockObject::Extends;
use Data::Dumper;
use feature qw ( switch );
use Scalar::Util qw( blessed );
use Test::More;
use Data::Compare;

use v5.14;
use strict;
no warnings 'experimental';

our @EXPORT_OK = qw (
    GetParametersFromMockifyCall
    WasCalled
    GetCallCount
);

our $VERSION = '0.9';

#----------------------------------------------------------------------------------------
sub new {
    my $class = shift;
    my ( $FakeModulePath, $aFakeParams ) = @_;

    my $self = bless {}, $class;

    LoadPackage( $FakeModulePath );
    my $FakeClass = $FakeModulePath->new( @{$aFakeParams} );
    $self->{'__MockedModulePath'} = $FakeModulePath;
    $self->{'__MockedModule'} = Test::MockObject::Extends->new( $FakeClass );
    $self->_initMockedModule();

    return $self;
}
#----------------------------------------------------------------------------------------
sub _initMockedModule {
    my $self = shift;

    $self->{'__MockedModule'}->{'__MethodCallCounter'} = Devel::Mockify::MethodCallCounter->new();
    $self->{'__MockedModule'}->{'__isMockified'} = 1;
    $self->_addGetParameterFromMockifyCall();

    return;
}
#----------------------------------------------------------------------------------------=
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
    if( not 
( $Position ) || not IsInteger( $Position )){
        $Position = 0;
    }

    return $MockifiedMockedObject->__getParametersFromMockifyCall( $MethodName, $Position );
}
#----------------------------------------------------------------------------------------=
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
#----------------------------------------------------------------------------------------=
sub GetCallCount {
    my ( $MockifiedMockedObject, $MethodName ) = @_;

    _TestMockifyObject( $MockifiedMockedObject );
    return $MockifiedMockedObject->{'__MethodCallCounter'}->getAmountOfCalls( $MethodName );
}
#----------------------------------------------------------------------------------------
sub getMockObject {
    my $self = shift;
    return $self->{'__MockedModule'};
}
#----------------------------------------------------------------------------------------
sub _TestMockifyObject {
    my ( $MockifiedMockedObject ) = @_;

    my $ObjectPath = ref( $MockifiedMockedObject );
    if( not IsValid( $ObjectPath ) ){
        Error( 'Object is not defined' );
    }
    if ( $MockifiedMockedObject->{'__isMockified'} != 1){
        Error( "The Object: '$ObjectPath' is not mockified" );
    }

    return;
}
#----------------------------------------------------------------------------------------=
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
#----------------------------------------------------------------------------------------
sub addMethodSpy {
    my $self = shift;
    my ( $MethodName ) = @_;

    my $PointerOriginalMethod = \&{$self->{'__MockedModulePath'}.'::'.$MethodName};
    $self->addMock( $MethodName, sub {
        $PointerOriginalMethod->( @_ );
    } );

    return;
}
#----------------------------------------------------------------------------------------
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

    ExistsMethod( $self->{'__MockedModulePath'}, $MethodName );
    $self->{'__MockedModule'}->{'__MethodCallCounter'}->addMethod( $MethodName );
    $self->{'__MockedModule'}->mock( $MethodName, sub {
        $self->{'__MockedModule'}->{'__MethodCallCounter'}->increment( $MethodName );
        return $rSub->( @_ );
    } );

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
            'Method' => "$self->{'__MockedModulePath'}->$MethodName",
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
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
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
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
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
        when( 'float' ) {
        $self->_testExpectedFloat( $ParameterName,$Value, $TestParameter, $MethodName );
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

    $self->{'__MockedModule'}->mock('__getParametersFromMockifyCall',
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
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
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
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
            'Value' => $Value
        });
    }
    if( IsHashReference( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        if( $Value ne $ExpectedValue ){
            Error( "$Name unexpected value", {
                'Method' => $self->{'__MockedModulePath'}."->$MethodName",
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
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
            'Value' => $Value
            });
    }
    if( IsHashReference( $hTestParameterType ) ){
        my @Values = values %{$hTestParameterType};
        my $ExpectedValue = $Values[0];
        if( $Value != $ExpectedValue ){
            Error( "$Name unexpected value", {
                'Method' => $self->{'__MockedModulePath'}."->$MethodName",
                'ActualValue' => $Value,
                'ExpectedValue' => $ExpectedValue,
            });
        }
    }

    return;
}
#----------------------------------------------------------------------------------------
sub _testExpectedFloat {
    my $self = shift;
    my ( $Name, $Value, $hTestParameterType, $MethodName ) = @_;

    if ( not IsFloat( $Value ) ) {
        Error( "$Name is not an Float", {
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
            'Value' => $Value
            });
    }
    if( IsHashReference( $hTestParameterType ) ){
        my @Values = values %{$hTestParameterType};
        my $ExpectedValue = $Values[0];
        if( $Value != $ExpectedValue ){
            Error( "$Name unexpected value", {
                'Method' => $self->{'__MockedModulePath'}."->$MethodName",
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
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
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
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
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
        'Method' => $self->{'__MockedModulePath'}."->$MethodName",
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
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
            'Value' => $Value
        } );
    }
    if( IsHashReference( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        if( not Isa( $Value, $ExpectedValue ) ){
            Error( "$Name unexpected value", {
                'Method' => $self->{'__MockedModulePath'}."::MethodName",
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
            'Method' => $self->{'__MockedModulePath'}."::MethodName",
        } );
    }

    return;
}

1;