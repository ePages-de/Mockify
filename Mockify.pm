package DE_EPAGES::Test::Mock::Mockify;
use base qw ( Exporter );
use DE_EPAGES::Core::API::Error qw ( Error ExistsError );
use Tools;
use TypeTests; 
use Test::MockObject::Extends;
use Data::Dumper;
use feature qw ( switch );
use strict;
our @EXPORT_OK = qw ( GetParametersFromMockifyCall );

#----------------------------------------------------------------------------------------
sub new {
    my $class = shift;
    my ( $FakeModulePath, $aFakeParams ) = @_;

    my $self = bless {}, $class;
    $self->{'Tools'} = Tools->new();
    $self->{'TestTypes'} = TestTypes->new();

    $self->{'Tools'}->loadPackage( $FakeModulePath );
    my $FakeClass = $FakeModulePath->new( @{$aFakeParams} );
    $self->{'MockedModulePath'} = $FakeModulePath;
    $self->{'MockedModule'} = Test::MockObject::Extends->new( $FakeClass );
    $self->_addGetParameterFromMockifyCall();

    return $self;
}

#----------------------------------------------------------------------------------------
sub GetParametersFromMockifyCall {
    my ( $MockifiedMockedObject, $MethodName, $Position ) = @_;

    $self->{'Tools'}->existsMethod( $MockifiedMockedObject, '__getParametersFromMockifyCall' );
    if( not $self->{'Tools'}->isValid( $Position ) ){
        $Position = 0;
    } else {
        die( 'jajagenau' ) if( not $self->{'TestTypes'}->isInteger( $Position );
    }

    return $MockifiedMockedObject->__getParametersFromMockifyCall( $MethodName, $Position );
}

#----------------------------------------------------------------------------------------
sub getMockObject {
    my $self = shift;
    return $self->{'MockedModule'};
}

#----------------------------------------------------------------------------------------
sub addMock {
    my $self = shift;
    my ( $MethodName, $rSub ) = @_;

    $self->{'Tools'}->existsMethod( $self->{'MockedModule'}, $MethodName );
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
            die('UnexpectedParameter',{
            'Method' => "$self->{'MockedModulePath'}->$MethodName(???)",
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

    if ( $self->{'TestTypes'}->isArrayReference( $aParameterTypes ) ){
        die( 'ParameterTypesNotProvided', {
            'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
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
            die( 'UnknownParametertype', {
            'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
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
                die( "$MethodName was not called" );
            }
            if( scalar @{$aParametersFromAllCalls} < $Position ) {
                die( "$MethodName was not called ".( $Position+1 ).' times',{
                'Method' => "$MethodName(???)",
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
    if( $self->{'TestTypes'}->isHashReference( $TestParameter ) ){
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
        die( 'WrongAmountOfParameters', {
            'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
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

    if ( $self->{'TestTypes'}->isString( $Value ) ) {
        die( "$Name is not a String", {
            'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
            'Value' => $Value
        });
    }
    if( $self->{'TestTypes'}->isHashReference( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        if( $Value ne $ExpectedValue ){
            die( "$Name unexpected value", {
                'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
                'Value' => $Value,
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

    if ( $self->{'TestTypes'}->isInteger( $Value ) ) {
        die( "$Name is not a Integer", {
            'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
            'Value' => $Value
            });
    }
    if( $self->{'TestTypes'}->isHashReference( $hTestParameterType ) ){
        my @Values = values %{$hTestParameterType};
        my $ExpectedValue = $Values[0];
        if( $Value != $ExpectedValue ){
            die( "$Name unexpected value", {
                'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
                'Value' => $Value,
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

    if ( $self->{'Tools'}->isValid( $Value ) ) {
        die( "$Name is not undefined", {
            'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
            'Value' => $Value
        });
    }

    return;
}

#----------------------------------------------------------------------------------------
sub _testExpectedHashRef {
    my $self = shift;
    my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;

    if ( $self->{'TestTypes'}->isHashReference( $Value ) ) {
        die( "$Name is not a HashRef", {
            'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
            'Value' => $Value
        });
    }
    if( $self->{'TestTypes'}->isHashReference( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        my $DumpedValue = Dumper( $Value ); # todo complexCompare
        my $DumpedExpected = Dumper( $ExpectedValue );
        if( $DumpedValue ne $DumpedExpected ){
            die( "$Name unexpected value", {
                'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
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

    if ( $self->{'TestTypes'}->isArrayReference( $Value ) ) {
        die( "$Name is not a ArrayRef", {
        'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
        'Value' => $Value
        } );
    }
    if( $self->{'TestTypes'}->isHashReference( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        my $DumpedValue = Dumper( $Value );
        my $DumpedExpected = Dumper( $ExpectedValue );# todo complexCompare
        if( $DumpedValue ne $DumpedExpected ){
            die( "$Name unexpected value", {
                'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
                'got value' => $DumpedValue,
                'expected value' => $DumpedExpected,
            });
        }
    }

    return;
}


#----------------------------------------------------------------------------------------
sub _testExpectedObject {
    my $self = shift;
    my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;

    if ( $self->{'TestTypes'}->isObjectReference($Value) ) {
        die( "$Name is not a Object", {
            'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
            'Value' => $Value
        } );
    }
    if( $self->_isHash( $TestParameterType ) ){
        my @Values = values %{$TestParameterType};
        my $ExpectedValue = $Values[0];
        if( !IsA( $Value, $ExpectedValue ) ){ #todo build isa test ??
            die( "$Name unexpected value", {
                'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
                'Value' => $Value,
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

    if ( not ( defined $aParameterTypes ) or $self->{'TestTypes'}->isArrayReference( $aParameterTypes )){
        die( 'ParameterTypesNotProvided', {
            'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
        } );
    }

    return;
}

1;