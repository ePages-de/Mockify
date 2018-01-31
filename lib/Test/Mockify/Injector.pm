package Test::Mockify::Injector;
use parent 'Test::Mockify::Base';

use strict;
use warnings;

use Test::Mockify::Tools qw ( LoadPackage ExistsMethod );
use Sub::Override;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{'override'} = Sub::Override->new();
    return $self;
}

sub _getFakeClass {
    return undef;
}

sub _addMock {
    my $self = shift;
    my ( $MethodName, $Method) = @_;

    ExistsMethod( $self->_mockedModulePath(), $MethodName );
    $self->_mockedSelf()->{'__MethodCallCounter'}->addMethod( $MethodName );
    if(not $self->{'MethodStore'}{$MethodName}){
        $self->{'MethodStore'}{$MethodName} //= $Method;
        my $MockedMethodBody = sub {
            $self->_mockedSelf()->{'__MethodCallCounter'}->increment( $MethodName );
            my @MockedParameters = @_;
            $self->_storeParameters( $MethodName, $self->_mockedSelf(), \@MockedParameters );
            return $self->{'MethodStore'}{$MethodName}->call(@MockedParameters);
        };
        $self->{'override'}->replace($self->_mockedModulePath().'::'.$MethodName, $MockedMethodBody);
    }
    return $self->{'MethodStore'}{$MethodName};
}

1;

=pod

=head1 NAME

Test::Mockify::Injector - use L<Test::Mockify>'s robust API to override real functionality with mock implementations

=head2 mock

Sometimes it is not possible to inject test dependencies into your system under test (SUT).
This could be the case for a variety of reasons, namely the SUT instantiates a new object instance, calls
a static method, or imports a function from another module. L<Test::Mockify::Injector> allows you to redefine the behavior
of those dependencies for which you can't provide a test double.

  package SUT;
  use Magic::Tools qw ( Rabbit ); # Rabbit could use a webservice
  sub pullCylinder {
      shift;
      if(Rabbit('white') && not Magic::Tools::Rabbit('black')){ # imported && full path
          return 1;
      }else{
          return 0;
      }
  }
  1;

In the Test it can be mocked

  package Test_SUT;
  my $MockObjectBuilder = Test::Mockify->new( 'SUT', [] );
  $MockObjectBuilder->mockStatic('Magic::Tools::Rabbit')->when(String('white'))->thenReturn(1);
  $MockObjectBuilder->mockStatic('Magic::Tools::Rabbit')->when(String('black'))->thenReturn(0);

  my $SUT = $MockObjectBuilder->getMockObject();
  is($SUT->pullCylinder(), 1);
  1;


It can be mixed with normal C<spy> and C<mock>

=head4 Thx

to @dbucky for this amazing idea

=head2 spy

Provides the possibility to spy static functions inside the mock/sut.

  package SUT;
  use Magic::Tools qw ( Rabbit ); # Rabbit could use a webservice
  sub pullCylinder {
      shift;
      if(Rabbit('white') && not Magic::Tools::Rabbit('black')){ # imported && full path
          return 1;
      }else{
          return 0;
      }
  }
  1;

In the Test it can be mocked

  package Test_SUT;
  my $MockObjectBuilder = Test::Mockify->new( 'SUT', [] );
  $MockObjectBuilder->spyStatic('Magic::Tools::Rabbit')->whenAny();
  my $SUT = $MockObjectBuilder->getMockObject();

  $SUT->pullCylinder();
  is(GetCallCount($SUT, 'pullCylinder), 1);

  1;

It can be mixed with normal C<spy> and C<mock>. For more options see, C<mockStatic>

=head1 AUTHOR

Dustin Buckenmeyer E<lt>dustin.buckenmeyer@gmail.comE<gt>
Thanks to L<ECS Tuning|https://www.ecstuning.com/> for allowing me to pursue this idea and ultimately give it back to the community!

=cut