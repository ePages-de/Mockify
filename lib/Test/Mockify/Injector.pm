package Test::Mockify::Injector;
use strict;
use warnings;

use parent 'Test::Mockify';

use Test::Mockify::Tools qw ( ExistsMethod LoadPackage );

sub new {
    my ($class, $FakeModulePath) = @_;
    my $self = bless {}, $class;

    LoadPackage( $FakeModulePath );
    $self->_mockedModulePath($FakeModulePath);
    $self->_mockedSelf(Test::MockObject::Extends->new());
    $self->_initMockedModule();

    return $self;
}
#----------------------------------------------------------------------------------------
=pod

=head2 mock

Sometimes it is not possible to inject the dependencies from the outside. This is especially the case when the package uses imports of static functions.
C<mockStatic> provides the possibility to mock static functions inside the mock/sut.

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

=cut
sub mock {
    my $self = shift;
    $self->SUPER::mock(@_);
}
#----------------------------------------------------------------------------------------
=pod

=head2 spyStatic

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

=cut
sub spy {
    my $self = shift;
    $self->SUPER::spy(@_);
}
#----------------------------------------------------------------------------------------
sub _initMockedModule {
    my $self = shift;
    $self->SUPER::_initMockedModule();
    $self->{'override'} = Sub::Override->new();
    return;
}
#----------------------------------------------------------------------------------------
sub _addMockWithMethod {
    my $self = shift;
    my ( $MethodName ) = @_;
    $self->_testMockTypeUsage($MethodName);
    return $self->_addStaticMock($MethodName, Test::Mockify::Method->new());
}
#----------------------------------------------------------------------------------------
sub _addMockWithMethodSpy {
    my $self = shift;
    my ( $MethodName, $PointerOriginalMethod ) = @_;
    $self->_testMockTypeUsage($MethodName);
    return $self->_addStaticMock($MethodName, Test::Mockify::MethodSpy->new($PointerOriginalMethod));
}
#----------------------------------------------------------------------------------------
sub _addStaticMock {
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
#----------------------------------------------------------------------------------------
sub getVerifier {
    my $self = shift;
    return $self->_mockedSelf();
}

1;