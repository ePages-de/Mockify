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
use Test::Mockify::CompatibilityTools qw (MigrateOldMatchers);
use Data::Dumper;
use Scalar::Util qw( blessed );
use Data::Compare;

use experimental 'switch';

use strict;

our $VERSION = '0.9.4';

sub new {
    my $class = shift;
    my ( $FakeModulePath, $aFakeParams ) = @_;

    my $self = bless {}, $class;

    LoadPackage( $FakeModulePath );
    my $FakeClass = $FakeModulePath->new( @{$aFakeParams} );
    $self->_mockedModulPath($FakeModulePath);
    $self->_mockedSelf(Test::MockObject::Extends->new( $FakeClass ));
    $self->_initMockedModule();

    return $self;

}
#----------------------------------------------------------------------------------------
sub _mockedModulPath {
    my $self = shift;
    my ($ModulPath) = @_;
    return $self->{'__MockedModulePath'} unless ($ModulPath);
    $self->{'__MockedModulePath'} = $ModulPath;
}
#----------------------------------------------------------------------------------------
sub _mockedSelf {
    my $self = shift;
    my ($MockedSelf) = @_;
    return $self->{'__MockedModule'} unless ($MockedSelf);
    $self->{'__MockedModule'} = $MockedSelf;
}
#----------------------------------------------------------------------------------------
sub _initMockedModule {
    my $self = shift;

    $self->_mockedSelf()->{'__MethodCallCounter'} = Test::Mockify::MethodCallCounter->new();
    $self->_mockedSelf()->{'__isMockified'} = 1;
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
    return $self->_mockedSelf();
}

#----------------------------------------------------------------------------------------=
=pod

=head2 mock

This is place where the mocked methods are defined. The method also proves that the method you like to mock actually exists.

=head3 synopsis

This method takes one parameter, which is the name of the method you like to mock.
Because you need to specify more detailed the behaviour of this mock you have to chain the method signature (when) and the expected return value (then...). 

For example, the next line will create a mocked version of the method log, but only if this method is called with any string and the number 123. In this case it will return the String 'Hello World'. Mockify will throw an error if this method is called somehow else.

  my $MockObjectBuilder = Test::Mockify->new( 'Sample::Logger', [] );
  $MockObjectBuilder->mock('log')->when(String(), Number(123))->thenReturn('Hello World');
  my $SampleLogger = $MockObjectBuilder->getMockObject();
  is($SampleLogger->log('abc',123), 'Hello World');


=head4 when

To define the signatur in the needed structure you should use the L<< Test::Mockify::Matchers >>.

=head4 whenAny

If you don't want to specify the method signatur at all, you can use whenAny.
It is not possible to mix C<whenAny> and C<when> for the same method.

=head4 then ...

For possible return types please look in L<Test::Mockify::ReturnValue>

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

With this method it is possible to observe a method. That means, you keep the original functionality but you can get meta data from the mockify-framework.

  $MockObjectBuilder->addMethodSpy('myMethodName');

=cut
sub addMethodSpy {
    my $self = shift;
    my ( $MethodName ) = @_;
    my $PointerOriginalMethod = \&{$self->_mockedModulPath().'::'.$MethodName};
    $self->_addMethod($MethodName)->whenAny()->thenCall(sub {
        return $PointerOriginalMethod->($self->_mockedSelf(), @_);
    });
    return;
}
#----------------------------------------------------------------------------------------
=pod

=head2 addMethodSpyWithParameterCheck

With this method it is possible to observe a method and check the parameters. That means, you keep the original functionality, but you can get meta data from the mockify- framework and use the parameter check, like B<addMockWithReturnValueAndParameterCheck>.

  my $aParameterTypes = [String(),String(abcd)];
  $MockObjectBuilder->addMethodSpyWithParameterCheck('myMethodName', $aParameterTypes);

To define in a nice way the signatur you should use the L<< Test::Mockify::Matchers; >>.

=cut
sub addMethodSpyWithParameterCheck {
    my $self = shift;
    my ( $MethodName, $aParameterTypes ) = @_;

    my $PointerOriginalMethod = \&{$self->_mockedModulPath().'::'.$MethodName};
    $aParameterTypes = MigrateOldMatchers($aParameterTypes);
    $self->_addMethod($MethodName)->when(@{$aParameterTypes})->thenCall(sub {
        return $PointerOriginalMethod->($self->_mockedSelf(), @_);
    });
    return;
}
#----------------------------------------------------------------------------------------
=pod

=head2 addMock I<(deprecated)>

This is the simplest case. It works like the mock-method from L<Test::MockObject>.

Only handover the B<name> and a B<method pointer>. Mockify will automatically check if the method exists in the original object.

  $MockObjectBuilder->addMock('myMethodName', sub {
                                    # Your implementation
                                 }
  );

=cut
sub addMock {
    my $self = shift;
    my ( $MethodName, $rSub ) = @_;
    if (warnings::enabled("deprecated")) {
        warnings::warn('deprecated', "addMock is deprecated, use mock('name')->whenAny()->thenCall(sub{})");
    }
    $self->_addMethod($MethodName)->whenAny()->thenCall(sub {
        return $rSub->($self->_mockedSelf(), @_);
    });

    return;
}
#-------------------------------------------------------------------------------------
sub _addMethod {
    my $self = shift;
    my ( $MethodName ) = @_;

    ExistsMethod( $self->_mockedModulPath(), $MethodName );
    $self->_mockedSelf()->{'__MethodCallCounter'}->addMethod( $MethodName );
    if(not $self->{'MethodStore'}{$MethodName}){
        $self->{'MethodStore'}{$MethodName} //= Test::Mockify::Method->new();
        $self->_mockedSelf()->mock($MethodName, sub {
            $self->_mockedSelf()->{'__MethodCallCounter'}->increment( $MethodName );
            my $MockedSelf = shift;
            my @MockedParameters = @_;
            $self->_storeParameters( $MethodName, $MockedSelf, \@MockedParameters );
            return $self->{'MethodStore'}{$MethodName}->call(@MockedParameters);
        });
    }
    return $self->{'MethodStore'}{$MethodName};
}
#----------------------------------------------------------------------------------------
=pod

=head2 addMockWithReturnValue I<(deprecated)>

Does the same as C<addMock>, but here you can handover a B<value> which will be returned if you call the mocked method.

  $MockObjectBuilder->addMockWithReturnValue('myMethodName','the return value');

=cut
sub addMockWithReturnValue {
    my $self = shift;
    my ( $MethodName, $ReturnValue ) = @_;
    if (warnings::enabled("deprecated")) {
        warnings::warn('deprecated', "addMockWithReturnValue is deprecated, use mock('name')->when()->thenReturn('Value')");
    }
    if($ReturnValue){
        $self->_addMethod($MethodName)->when()->thenReturn($ReturnValue);
    }else {
        $self->_addMethod($MethodName)->when()->thenReturnUndef();
    }

    return;
}
#----------------------------------------------------------------------------------------
=pod

=head2 addMockWithReturnValueAndParameterCheck I<(deprecated)>

This method is an extension of B<addMockWithReturnValue>. Here you can also check the parameters which will be passed.

You can check if they have a specific B<data type> or even check if they have a given B<value>.

In the following example two strings will be expected, and the second one has to have the value "abcd".

  my $aParameterTypes = [String(),String('abcd')];
  $MockObjectBuilder->addMockWithReturnValueAndParameterCheck('myMethodName','the return value',$aParameterTypes);

To define in a nice way the signatur you should use the L<< Test::Mockify::Matchers; >>.

=cut
sub addMockWithReturnValueAndParameterCheck {
    my $self = shift;
    my ( $MethodName, $ReturnValue, $aParameterTypes ) = @_;
    if (warnings::enabled("deprecated")) {
        warnings::warn('deprecated', "addMockWithReturnValue is deprecated, use mock('name')->when(String('abc'))->thenReturn('Value')");
    }
    if ( not IsArrayReference( $aParameterTypes ) ){
        Error( 'ParameterTypesNotProvided', {
            'Method' => $self->_mockedModulPath()."->$MethodName",
            'ParameterList' => $aParameterTypes,
        } );
    }
    $aParameterTypes = MigrateOldMatchers($aParameterTypes);

    if($ReturnValue){
        $self->_addMethod($MethodName)->when(@{$aParameterTypes})->thenReturn($ReturnValue);
    }else {
        $self->_addMethod($MethodName)->when(@{$aParameterTypes})->thenReturnUndef();
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

1;

__END__

=head1 LICENSE

Copyright (C) 2017 ePages GmbH

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Christian Breitkreutz E<lt>christianbreitkreutz@gmx.deE<gt>

=cut

