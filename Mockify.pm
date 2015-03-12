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
        TestInteger( 'Position', $Position );
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
$self->_testExistsMethod( $self->{'MockedModule'},$MethodName );
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
'Method' => "$self->{'MockedModulePath'}->$MethodName(???)",
'ParameterList' => "(@_)",
'AmountOfUnexpectedParameters' => $ParameterListSize,
} );
}
return $ReturnValue;
} );
return;
}

#----------------------------------------------------------------------------------------
sub addMockWithReturnValueAndParameterCheck {
my $self = shift;
my ( $MethodName, $ReturnValue, $aParameterTypes ) = @_;
$self->_checkParameterTypesForMethod( $MethodName , $aParameterTypes );
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
for ( my $i = 0; $i < $MockedParametersSize; $i++ ) { ## no critic ( ProhibitCStyleForLoops )
my $TypeTestResult = $self->_testParameterType("Parameter[$i]", $MockedParameters[$i], $TestParameters[$i], $MethodName );
if ( ! $TypeTestResult ){
Error( 'UnknownParametertype', {
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
$self->{'MockedModule'}->mock('__getParametersFromMockifyCall',sub{
my $MockedSelf = shift;
my ( $MethodName, $Position ) = @_;
my $aParametersFromAllCalls = $MockedSelf->{$MethodName.'_MockifyParams'};
if( ref $aParametersFromAllCalls ne 'ARRAY' ){
Error( "$MethodName was not called" );
}
if( scalar @{$aParametersFromAllCalls} < $Position ) {
Error( "$MethodName was not called ".( $Position+1 ).' times',{
'Method' => "$MethodName(???)",
'Postion' => $Position,
} );
}
else {
my $ParameterFromMockifyCall = $MockedSelf->{$MethodName.'_MockifyParams'}[$Position];
return $ParameterFromMockifyCall;
}
} # END of sub ref
);
return;
}
#----------------------------------------------------------------------------------------
sub _getParameterType {
my $self = shift;
my ( $TestParameter ) = @_;
my $TestParameterType = undef;
if( $self->_isHash( $TestParameter ) ){
my @Keys = keys %{$TestParameter};
$TestParameterType = $Keys[0];
} else {
$TestParameterType = $TestParameter;
}
return $TestParameterType;
}

#----------------------------------------------------------------------------------------
sub _isHash {
my $self = shift;
my ( $TestValue ) = @_;
if( ref( $TestValue ) eq 'HASH' ){
return 1;
}else{
return 0;
}
}

#----------------------------------------------------------------------------------------
sub _testParameterAmount {
my $self = shift;
my ( $MethodName , $aExpectedParameterTypes, $aActualInputParameters ) = @_;
my $AmountExpectedParameterTypes = scalar @{$aExpectedParameterTypes};
my $AmountActualInputParameters = scalar @{$aActualInputParameters};
if( $AmountActualInputParameters < $AmountExpectedParameterTypes ){
Error( 'WrongAmountOfParameters', {
'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
'ExpectedAmount' => $AmountExpectedParameterTypes,
'ActualAmount' => $AmountActualInputParameters,
} );
}
return;
}

#----------------------------------------------------------------------------------------
sub _testString {
my $self = shift;
my ( $Name, $Value, $MethodName ) = @_;
return if ( $Value eq '' ); #empty string is ok
eval {
TestString( $Name, $Value );
};
if ( ExistsError() ) {
Error( "$Name is not a String", {
'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
'Value' => $Value
} );
}
return;
}

#----------------------------------------------------------------------------------------
sub _testExpectedString {
my $self = shift;
my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;
$self->_testString( $Name, $Value, $MethodName );
if( $self->_isHash( $TestParameterType ) ){
my @Values = values %{$TestParameterType};
my $ExpectedValue = $Values[0];
if( $Value ne $ExpectedValue ){
Error( "$Name unexpected value", {
'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
'Value' => $Value,
'ExpectedValue' => $ExpectedValue,
} );
}
}
return;
}

#----------------------------------------------------------------------------------------
sub _testInteger {
my $self = shift;
my ( $Name, $Value, $MethodName ) = @_;
eval {
TestInteger( $Name, $Value );
};
if ( ExistsError() ) {
Error( "$Name is not a Integer", {
'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
'Value' => $Value
} );
}
return;
}
#========================================================================================
# §function _testExpectedInt
# §state private
#----------------------------------------------------------------------------------------
# §syntax _testExpectedInt( $Name, $Value, $TestParameterType, $MethodName );
#----------------------------------------------------------------------------------------
# §description tests if Value is an Integer and as expected
#----------------------------------------------------------------------------------------
# §input $Name | name of variable | String
# §input $Value | value which will be checked | Integer
# §input $TestParameterType | value which will be checked | Integer refhash
# §input $MethodName | name of method | String
#========================================================================================
sub _testExpectedInt {
my $self = shift;
my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;
$self->_testInteger( $Name, $Value, $MethodName );
if( $self->_isHash( $TestParameterType ) ){
my @Values = values %{$TestParameterType};
my $ExpectedValue = $Values[0];
if( $Value != $ExpectedValue ){
Error( "$Name unexpected value", {
'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
'Value' => $Value,
'ExpectedValue' => $ExpectedValue,
} );
}
}
return;
}
#========================================================================================
# §function _testUndefind
# §state private
#----------------------------------------------------------------------------------------
# §syntax _testUndefind( $Name, $Value, $MethodName );
#----------------------------------------------------------------------------------------
# §description throws an error if $Value is not undefined
#----------------------------------------------------------------------------------------
# §input $Name | name of variable | String
# §input $Value | value which will be checked | integer String object refhash refarray
# §input $MethodName | name of method | String
#========================================================================================
sub _testUndefind {
my $self = shift;
my ( $Name, $Value, $MethodName ) = @_;
if ( isValid( $Value ) ) {
Error( "$Name is not undefined", {
'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
'Value' => $Value
});
}
return;
}
#========================================================================================
# §function _testHashRef
# §state private
#----------------------------------------------------------------------------------------
# §syntax _testHashRef( $Name, $Value, $MethodName );
#----------------------------------------------------------------------------------------
# §description throws an error if $Value is not a hash reference
#----------------------------------------------------------------------------------------
# §input $Name | name of variable | String
# §input $Value | value which will be checked | refhash
# §input $MethodName | name of method | String
#========================================================================================
sub _testHashRef {
my $self = shift;
my ( $Name, $Value, $MethodName ) = @_;
eval {
TestHash( $Name, $Value );
};
if ( ExistsError() ) {
Error( "$Name is not a HashRef", {
'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
'Value' => $Value
});
}
return;
}
#========================================================================================
# §function _testExpectedHashRef
# §state private
#----------------------------------------------------------------------------------------
# §syntax _testExpectedHashRef( $Name, $Value, $TestParameterType, $MethodName );
#----------------------------------------------------------------------------------------
# §description tests if Value is an hash reference and as expected
#----------------------------------------------------------------------------------------
# §input $Name | name of variable | String
# §input $Value | value which will be checked | refhash
# §input $TestParameterType | value which is expected | refhash
# §input $MethodName | name of method | String
#========================================================================================
sub _testExpectedHashRef {
my $self = shift;
my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;
$self->_testHashRef( $Name, $Value, $MethodName );
if( $self->_isHash( $TestParameterType ) ){
my @Values = values %{$TestParameterType};
my $ExpectedValue = $Values[0];
my $DumpedValue = Dumper( $Value );
my $DumpedExpected = Dumper( $ExpectedValue );
if( $DumpedValue ne $DumpedExpected ){
Error( "$Name unexpected value", {
'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
'got value' => $DumpedValue,
'expected value' => $DumpedExpected,
} );
}
}
return;
}
#========================================================================================
# §function _testArrayRef
# §state private
#----------------------------------------------------------------------------------------
# §syntax _testArrayRef( $Name, $Value, $MethodName );
#----------------------------------------------------------------------------------------
# §description throws an error if $Value is not an array reference
#----------------------------------------------------------------------------------------
# §input $Name | name of variable | String
# §input $Value | value which will be checked | refarray
# §input $MethodName | name of method | String
#========================================================================================
sub _testArrayRef {
my $self = shift;
my ( $Name, $Value, $MethodName ) = @_;
eval {
TestArray( $Name, $Value );
};
if ( ExistsError() ) {
Error( "$Name is not a ArrayRef", {
'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
'Value' => $Value
} );
}
return;
}
#========================================================================================
# §function _testExpectedArrayRef
# §state private
#----------------------------------------------------------------------------------------
# §syntax _testExpectedArrayRef( $Name, $Value, $TestParameterType, $MethodName );
#----------------------------------------------------------------------------------------
# §description tests if Value is an array reference and as expected
#----------------------------------------------------------------------------------------
# §input $Name | name of variable | String
# §input $Value | value which will be checked | refarray
# §input $TestParameterType | value which will be checked | refarray refhash
# §input $MethodName | name of method | String
#========================================================================================
sub _testExpectedArrayRef {
my $self = shift;
my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;
$self->_testArrayRef( $Name, $Value, $MethodName );
if( $self->_isHash( $TestParameterType ) ){
my @Values = values %{$TestParameterType};
my $ExpectedValue = $Values[0];
my $DumpedValue = Dumper( $Value );
my $DumpedExpected = Dumper( $ExpectedValue );
if( $DumpedValue ne $DumpedExpected ){
Error( "$Name unexpected value", {
'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
'got value' => $DumpedValue,
'expected value' => $DumpedExpected,
} );
}
}
return;
}
#========================================================================================
# §function _testObject
# §state private
#----------------------------------------------------------------------------------------
# §syntax _testObject( $Name, $Value, $MethodName );
#----------------------------------------------------------------------------------------
# §description throws an error if $Value is not an object
#----------------------------------------------------------------------------------------
# §input $Name | name of variable | String
# §input $Value | value which will be checked | integer String object refhash refarray
# §input $MethodName | name of method | String
#========================================================================================
sub _testObject {
my $self = shift;
my ( $Name, $Value, $MethodName ) = @_;
eval {
TestObject( $Name, $Value );
};
if ( ExistsError() ) {
Error( "$Name is not a Object", {
'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
'Value' => $Value
} );
}
return;
}
#========================================================================================
# §function _testExpectedObject
# §state private
#----------------------------------------------------------------------------------------
# §syntax _testExpectedObject( $Name, $Value, $TestParameterType, $MethodName );
#----------------------------------------------------------------------------------------
# §description tests if Value is an object reference and as expected
#----------------------------------------------------------------------------------------
# §input $Name | name of variable | String
# §input $Value | value which will be checked | Object
# §input $TestParameterType | value which will be checked | Object refhash
# §input $MethodName | name of method | String
#========================================================================================
sub _testExpectedObject {
my $self = shift;
my ( $Name, $Value, $TestParameterType, $MethodName ) = @_;
$self->_testObject( $Name, $Value, $MethodName );
if( $self->_isHash( $TestParameterType ) ){
my @Values = values %{$TestParameterType};
my $ExpectedValue = $Values[0];
if( !IsA( $Value, $ExpectedValue ) ){
Error( "$Name unexpected value", {
'Method' => $self->{'MockedModulePath'}."->$MethodName(???)",
'Value' => $Value,
'ExpectedObjectType' => $ExpectedValue,
} );
}
}
return;
}
#========================================================================================
# §function _checkParameterTypesForMethod
# §state private
#----------------------------------------------------------------------------------------
# §syntax _checkParameterTypesForMethod( $MethodName, $aParameterTypes );
#----------------------------------------------------------------------------------------
# §description check if $aParameterTypes is defined or is not an Array
#----------------------------------------------------------------------------------------
# §input $MethodName | name of method | String
# §input $aParameterTypes | differnd parameter types | refarray
#========================================================================================
sub _checkParameterTypesForMethod {
my $self = shift;
my ( $MethodName, $aParameterTypes ) = @_;
if ( not ( defined $aParameterTypes ) or ref( $aParameterTypes ) ne 'ARRAY' ){
Error( 'ParameterTypesNotProvided', {
'Method' => $self->{'MockedModulePath'}."->.$MethodName.(???)",
} );
}
return;
}
#========================================================================================
# §function _testExistsMethod
# §state private
#----------------------------------------------------------------------------------------
# §syntax _testExistsMethod( $ModulePath, $MethodName );
#----------------------------------------------------------------------------------------
# §description throws an error if the Module don´t have the expected Method
#----------------------------------------------------------------------------------------
# §input $ModulePath | path to a module | String
# §input $MethodName | name of method | String
#========================================================================================
sub _testExistsMethod {
my $self = shift;
my ( $ModulePath, $MethodName ) = @_;
if( not $ModulePath->can( $MethodName ) ){
Error( $self->{'MockedModulePath'}." don't have a method like: $MethodName" );
}
return;
}
1;