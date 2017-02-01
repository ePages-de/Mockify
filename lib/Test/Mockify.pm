=pod

=head1 NAME

Test::Mockify - minimal mocking framework for perl

=head1 SYNOPSIS

  use Test::Mockify;
  use Test::Mockify::Verify qw ( WasCalled );
  use Test::Mockify::Matcher qw ( String );

  # build a new mocked object
  my $MockObjectBuilder = Test::Mockify->new('SampleLogger', []);
  $MockObjectBuilder->mock('log')->when(String())->thenReturnUndef();
  my $MockedLogger = $MockLoggerBuilder->getMockObject();

  # inject mocked object into the code you want to test
  my $App = SampleApp->new('logger'=> $MockedLogger);
  $App->do_something();

  # verify that the mock object was called
  ok(WasCalled($MockedLogger, 'log'), 'log was called');
  done_testing();

=head1 DESCRIPTION

Use L<Test::Mockify> to create and configure mock objects. Use L<Test::Mockify::Verify> to
verify the interactions with your mocks.

=head1 METHODS

=cut

package Test::Mockify;
use Test::Mockify::Tools qw ( Error ExistsMethod IsValid LoadPackage Isa );
use Test::Mockify::TypeTests qw ( IsInteger IsFloat IsString IsArrayReference IsHashReference IsObjectReference );
use Test::Mockify::MethodCallCounter;
use Test::Mockify::Method;
use Test::MockObject::Extends;
use Data::Dumper;
use Scalar::Util qw( blessed );
use Data::Compare;

use experimental 'switch';

use strict;

our $VERSION = '0.9.3';

#----------------------------------------------------------------------------------------
=pod

=head2 new

  my $MockObjectBuilder = Test::Mockify->new('Module::To::Mock', ['Constructor Parameters']);

=head3 Options

The C<new> method creates a new mock object builder. Use C<getMockObject> to obtain the final mock object.

=cut
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

    $self->{'__MockedModule'}->{'__MethodCallCounter'} = Test::Mockify::MethodCallCounter->new();
    $self->{'__MockedModule'}->{'__isMockified'} = 1;
    $self->_addGetParameterFromMockifyCall();

    return;
}

#----------------------------------------------------------------------------------------
=pod

=head2 getMockObject

Provides the actual mock object, which you can use in the test.

  my $aParameterList = ['SomeValueForConstructor'];
  my $MockObjectBuilder = Test::Mockify->new( 'My::Module', $aParameterList );
  my $MyModuleObject = $MockObjectBuilder->getMockObject();

=cut
sub getMockObject {
    my $self = shift;
    return $self->{'__MockedModule'};
}

#----------------------------------------------------------------------------------------=
=pod

=head2 mock

  This is place where the mocked methods are defined.

  This return types are supported.
  $MockObjectBuilder->mock('MethodName')->when(String())->thenReturn('Hello World');
  $MockObjectBuilder->mock('MethodName')->when(String())->thenReturnUndef();
  $MockObjectBuilder->mock('MethodName')->when(String())->thenReturnArray(['Hello', 'World']);
  $MockObjectBuilder->mock('MethodName')->when(String())->thenReturnHash({'Hello' => 'World'});
  $MockObjectBuilder->mock('MethodName')->when(String())->thenThrowError('ErrorType');
  $MockObjectBuilder->mock('MethodName')->when(String())->thenCall(sub{return 'Hello World'});

  This Matchers are supported:
  String(), Number(), HashRef(), ArrayRef(), Object(), Function(), Undef(), Any()
  $MockObjectBuilder->mock('MethodName')->when(String(), Number(), HashRef(), ArrayRef(), Object(), Function(), Undef(), Any())->thenReturnUndef();

  If you don't care at all about the parameters you can use whenAny()
  $MockObjectBuilder->mock('MethodName')->whenAny()->thenReturn('Hello World);

=cut
sub mock {
    my $self = shift;
    my @Parameters = @_;
    my $ParameterAmount = scalar @Parameters;
    if($ParameterAmount == 1 && IsString($Parameters[0]) ){
        return $self->_addMethod($Parameters[0]);
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
#----------------------------------------------------------------------------------------
=pod

=head2 addMethodSpy

With this method it is possible to observe a method. That means, you keep the original functionality, but you can get meta data from the mockify- framework.

  $MockObjectBuilder->addMethodSpy('myMethodName');

=cut
sub addMethodSpy {
    my $self = shift;
    my ( $MethodName ) = @_;
    my $PointerOriginalMethod = \&{$self->{'__MockedModulePath'}.'::'.$MethodName};
    $self->_addMethod($MethodName)->whenAny()->thenCall(sub {
        return $PointerOriginalMethod->($self->{'__MockedModule'}, @_);
    });
    return;
}
#----------------------------------------------------------------------------------------
=pod

=head2 addMethodSpyWithParameterCheck

With this method it is possible to observe a method and check the parameters. That means, you keep the original functionality, but you can get meta data from the mockify- framework and use the parameter check, like *addMockWithReturnValueAndParameterCheck*.

  my $aParameterTypes = ['string',{'string' => 'abcd'}];
  $MockObjectBuilder->addMethodSpyWithParameterCheck('myMethodName', $aParameterTypes);

=head3 Options

Pure types

  ['string', 'int', 'hashref', 'float', 'arrayref', 'object', 'undef', 'any']

or types with expected values

  [{'string'=>'abcdef'}, {'int' => 123}, {'float' => 1.23}, {'hashref' => {'key'=>'value'}}, {'arrayref'=>['one', 'two']}, {'object'=> 'PAth::to:Obejct}]

If you use *any*, you have to verify this value explicitly in the test, see **GetParametersFromMockifyCall** in L<Test::Mockify::Verify>.

=cut
sub addMethodSpyWithParameterCheck {
    my $self = shift;
    my ( $MethodName, $aParameterTypes ) = @_;

    my $PointerOriginalMethod = \&{$self->{'__MockedModulePath'}.'::'.$MethodName};
    my $NewParams = $self->_migrateIntAndFloatToNumber($aParameterTypes);
    $self->_addMethod($MethodName)->when(@{$NewParams})->thenCall(sub {
        return $PointerOriginalMethod->($self->{'__MockedModule'}, @_);
    });
    return;
}
#----------------------------------------------------------------------------------------
=pod

=head2 addMock

This is the simplest case. It works like the mock-method from Test::MockObject.

Only handover the **name** and a **method pointer**. Mockify will automatically check if the method exists in the original object.

  $MockObjectBuilder->addMock('myMethodName', sub {
                                    # Your implementation
                                 }
  );

=cut
sub addMock {
    my $self = shift;
    my ( $MethodName, $rSub ) = @_;

    $self->_addMethod($MethodName)->whenAny()->thenCall(sub {
        return $rSub->($self->{'__MockedModule'}, @_);
    });

    return;
}
#-------------------------------------------------------------------------------------
sub _addMethod {
    my $self = shift;
    my ( $MethodName ) = @_;

    ExistsMethod( $self->{'__MockedModulePath'}, $MethodName );
    $self->{'__MockedModule'}->{'__MethodCallCounter'}->addMethod( $MethodName );
    if(not $self->{'MethodStore'}{$MethodName}){
        $self->{'MethodStore'}{$MethodName} //= Test::Mockify::Method->new();
        $self->{'__MockedModule'}->mock($MethodName, sub {
            $self->{'__MockedModule'}->{'__MethodCallCounter'}->increment( $MethodName );
            my $MockedSelf = shift;
            my @MockedParameters = @_;
            $self->_storeParameters( $MethodName, $MockedSelf, \@MockedParameters );
            return $self->{'MethodStore'}{$MethodName}->call(@MockedParameters);
        });
    }
    return $self->{'MethodStore'}{$MethodName};
}
#-------------------------------------------------------------------------------------
sub _migrateIntAndFloatToNumber{
    my $self = shift;
    my ( $aParameterTypes ) = @_;
    #for backwards compatibility i need to transfer "int" and "float" to "number"
    my @NewParams;
    for(my $i = 0; $i < scalar @{$aParameterTypes}; $i++){
        if(ref($aParameterTypes->[$i]) eq 'HASH'){
            my $ExpectedValue;
            if($aParameterTypes->[$i]->{'int'}){
                $ExpectedValue = {'number' => $aParameterTypes->[$i]->{'int'}};
            }elsif($aParameterTypes->[$i]->{'float'}){
                $ExpectedValue = {'number' => $aParameterTypes->[$i]->{'float'}};
            }else{
                $ExpectedValue = $aParameterTypes->[$i];
            }
            $NewParams[$i] = $ExpectedValue;
        }else{
            if( $aParameterTypes->[$i] ~~ ['int', 'float']){
                $NewParams[$i] = 'number';
            } else{
                $NewParams[$i] = $aParameterTypes->[$i];
            }
        }
    }
    return \@NewParams;
}
#----------------------------------------------------------------------------------------
=pod

=head2  addMockWithReturnValue

Does the same as C<addMock>, but here you can handover a **value** which will be returned if you call the mocked method.

  $MockObjectBuilder->addMockWithReturnValue('myMethodName','the return value');

=cut
sub addMockWithReturnValue {
    my $self = shift;
    my ( $MethodName, $ReturnValue ) = @_;

    if($ReturnValue){
        $self->_addMethod($MethodName)->when()->thenReturn($ReturnValue);
    }else {
        $self->_addMethod($MethodName)->when()->thenReturnUndef();
    }

    return;
}
#----------------------------------------------------------------------------------------
=pod

=head2 addMockWithReturnValueAndParameterCheck

This method is an extension of *addMockWithReturnValue*. Here you can also check the parameters which will be passed.

You can check if they have a specific **data type** or even check if they have a given **value**.

In the following example two strings will be expected, and the second one has to have the value "abcd".

  my $aParameterTypes = ['string',{'string' => 'abcd'}];
  $MockObjectBuilder->addMockWithReturnValueAndParameterCheck('myMethodName','the return value',$aParameterTypes);

=head3 Options

Pure types

  ['string', 'int', 'float', 'hashref', 'arrayref', 'object', 'undef', 'any']

or types with expected values

  [{'string'=>'abcdef'}, {'int' => 123}, {'float' => 1.23}, {'hashref' => {'key'=>'value'}}, {'arrayref'=>['one', 'two']}, {'object'=> 'PAth::to:Obejct}]

If you use **any**, you have to verify this value explicitly in the test, see +*GetParametersFromMockifyCall** in L<Test::Mockify::Verify>.

=cut
sub addMockWithReturnValueAndParameterCheck {
    my $self = shift;
    my ( $MethodName, $ReturnValue, $aParameterTypes ) = @_;

    if ( not IsArrayReference( $aParameterTypes ) ){
        Error( 'ParameterTypesNotProvided', {
            'Method' => $self->{'__MockedModulePath'}."->$MethodName",
            'ParameterList' => $aParameterTypes,
        } );
    }
    my $NewParams = $self->_migrateIntAndFloatToNumber($aParameterTypes);

    if($ReturnValue){
        $self->_addMethod($MethodName)->when(@{$NewParams})->thenReturn($ReturnValue);
    }else {
        $self->_addMethod($MethodName)->when(@{$NewParams})->thenReturnUndef();
    }

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

1;

__END__

=head1 LICENSE

Copyright (C) 2017 ePages GmbH

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Christian Breitkreutz E<lt>cbreitkreutz@epages.comE<gt>

=cut

