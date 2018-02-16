package Test::Mockify::Base;
use strict;
use warnings;

use Test::Mockify::TypeTests qw ( IsString IsArrayReference );
use Test::Mockify::Tools qw ( LoadPackage ExistsMethod Error );
use Test::Mockify::MethodCallCounter;
use Test::Mockify::Method;
use Test::Mockify::MethodSpy;
use Test::Mockify::CompatibilityTools qw ( MigrateOldMatchers );

use Scalar::Util qw( blessed );
use Test::MockObject::Extends;

sub new {
    my ($class, $FakeModulePath, $aFakeParams) = @_;

    LoadPackage($FakeModulePath);

    my $self = bless {}, $class;
    my $FakeClass = $self->_getFakeClass($FakeModulePath, $aFakeParams);
    $self->_mockedModulePath($FakeModulePath);
    $self->_mockedSelf(Test::MockObject::Extends->new($FakeClass));
    $self->_initMockedModule();

    return $self;
}

sub mock {
    my $self = shift;
    my @Parameters = @_;

    my $ParameterAmount = scalar @Parameters;
    if($ParameterAmount == 1 && IsString($Parameters[0]) ){
        return $self->_addMockWithMethod($Parameters[0]);
    }
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

sub spy {
    my $self = shift;
    my ($MethodName) = @_;
    my $PointerOriginalMethod = \&{$self->_mockedModulePath().'::'.$MethodName};
    my $mockedSelf = $self->_mockedSelf();
    #In order to have the current object available in the parameter list, it has to be injected here.
    return $self->_addMockWithMethodSpy($MethodName, sub {
            return $PointerOriginalMethod->($mockedSelf, @_);
        });
}

sub getVerifier {
    my $self = shift;
    return $self->_mockedSelf();
}

### DEPRECATED >>>
sub addMock {
    my $self = shift;
    my ( $MethodName, $rSub ) = @_;
    if (warnings::enabled("deprecated")) {
        warnings::warn('deprecated', "addMock is deprecated, use mock('name')->whenAny()->thenCall(sub{})");
    }
    my $mockedSelf = $self->_mockedSelf();
    $self->_addMockWithMethod($MethodName)->whenAny()->thenCall(sub {
        return $rSub->($mockedSelf, @_);
    });

    return;
}

sub addMockWithReturnValue {
    my $self = shift;
    my ( $MethodName, $ReturnValue ) = @_;
    if (warnings::enabled("deprecated")) {
        warnings::warn('deprecated', "addMockWithReturnValue is deprecated, use mock('name')->when()->thenReturn('Value')");
    }
    if($ReturnValue){
        $self->_addMockWithMethod($MethodName)->when()->thenReturn($ReturnValue);
    }else {
        $self->_addMockWithMethod($MethodName)->when()->thenReturnUndef();
    }

    return;
}

sub addMockWithReturnValueAndParameterCheck {
    my $self = shift;
    my ( $MethodName, $ReturnValue, $aParameterTypes ) = @_;
    if (warnings::enabled("deprecated")) {
        warnings::warn('deprecated', "addMockWithReturnValue is deprecated, use mock('name')->when(String('abc'))->thenReturn('Value')");
    }
    if ( not IsArrayReference( $aParameterTypes ) ){
        Error( 'ParameterTypesNotProvided', {
                'Method' => $self->_mockedModulePath()."->$MethodName",
                'ParameterList' => $aParameterTypes,
            } );
    }
    $aParameterTypes = MigrateOldMatchers($aParameterTypes);

    if($ReturnValue){
        $self->_addMockWithMethod($MethodName)->when(@{$aParameterTypes})->thenReturn($ReturnValue);
    }else {
        $self->_addMockWithMethod($MethodName)->when(@{$aParameterTypes})->thenReturnUndef();
    }

    return;
}

sub addMethodSpy {
    my $self = shift;
    my ( $MethodName ) = @_;
    if (warnings::enabled("deprecated")) {
        warnings::warn('deprecated', "addMethodSpy is deprecated, use spy('name')->whenAny()");
    }
    $self->spy($MethodName)->whenAny();
    return;
}

sub addMethodSpyWithParameterCheck {
    my $self = shift;
    my ( $MethodName, $aParameterTypes ) = @_;
    if (warnings::enabled("deprecated")) {
        warnings::warn('deprecated', "addMethodSpyWithParameterCheck is deprecated, use spy('name')->when(String('abc'))");
    }
    my $aMigratedMatchers = MigrateOldMatchers($aParameterTypes);
    $self->spy($MethodName)->when(@{$aMigratedMatchers});
    return;
}
### DEPRECATED <<<

sub _getFakeClass {
    my $self = shift;
    my ( $FakeModulePath, $aFakeParams ) = @_;

    return $FakeModulePath->can('new')
        ? $FakeModulePath->new( @{$aFakeParams} )
        : $FakeModulePath;
}

sub _mockedModulePath {
    my $self = shift;
    my ($ModulePath) = @_;
    return $self->{'MockedModulePath'} unless ($ModulePath);
    $self->{'MockedModulePath'} = $ModulePath;
}

sub _mockedSelf {
    my $self = shift;
    my ($MockedSelf) = @_;
    return $self->{'MockedModule'} unless ($MockedSelf);
    $self->{'MockedModule'} = $MockedSelf;
}

sub _initMockedModule {
    my $self = shift;
    $self->_mockedSelf()->{'__MethodCallCounter'} = Test::Mockify::MethodCallCounter->new();
    $self->_mockedSelf()->{'__isMockified'} = 1;
    $self->_addGetParameterFromMockifyCall();
    return;
}

sub _addMockWithMethod {
    my $self = shift;
    my ( $MethodName ) = @_;
    $self->_testMockTypeUsage($MethodName);
    return $self->_addMock($MethodName, Test::Mockify::Method->new());
}

sub _addMockWithMethodSpy {
    my $self = shift;
    my ( $MethodName, $PointerOriginalMethod ) = @_;
    $self->_testMockTypeUsage($MethodName);
    return $self->_addMock($MethodName, Test::Mockify::MethodSpy->new($PointerOriginalMethod));
}

sub _addMock {
    my $self = shift;
    my ($MethodName, $Method) = @_;

    ExistsMethod( $self->_mockedModulePath(), $MethodName );
    $self->_mockedSelf()->{'__MethodCallCounter'}->addMethod( $MethodName );
    if(not $self->{'MethodStore'}{$MethodName}){
        $self->{'MethodStore'}{$MethodName} //= $Method;
        $self->_mockedSelf()->mock($MethodName, sub {
                my $MockedSelf = shift;
                my @MockedParameters = @_;
                $MockedSelf->{'__MethodCallCounter'}->increment( $MethodName );
                push @{$MockedSelf->{$MethodName.'_MockifyParams'}}, \@MockedParameters;
                return $Method->call(@MockedParameters);
            });
    }
    return $self->{'MethodStore'}{$MethodName};
}

sub _addGetParameterFromMockifyCall {
    my $self = shift;

    $self->_mockedSelf()->mock('__getParametersFromMockifyCall',
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

sub _testMockTypeUsage {
    my $self = shift;
    my ($MethodName) = @_;
    my $PositionInCallerStack = 2;
    my $MethodMockType = (caller($PositionInCallerStack))[3]; # autodetect mock type (spy or mock)
    if($self->{'MethodMockType'}{$MethodName} && $self->{'MethodMockType'}{$MethodName} ne $MethodMockType){
        die('It is not possible to mix spy and mock');
    }else{
        $self->{'MethodMockType'}{$MethodName} = $MethodMockType;
    }
    return;
}

1;
