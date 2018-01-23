=pod

=head1 NAME

Test::Mockify::Injector - To inject mock implementations in place of the real functionality

=head1 SYNOPSIS

  use Test::Mockify;
  use Test::Mockify::Verify qw ( WasCalled );
  use Test::Mockify::Matcher qw ( String );
  use Test::Mockify::Injector;

  # build a new mocked object
  my $MockObjectBuilder = Test::Mockify->new('SampleLogger');
  $MockObjectBuilder->mock('log')->when(String())->thenReturn('Hello, World!');

  # create injector
  my $Injector = Test::Mockify::Injector->new();

  # inject the builder
  $Injector->inject($MockObjectBuilder);

  # exercise the system under test
  my $App = SampleApp->new();
  $App->log_message();

  # when $App->log_message() calls SampleLogger::log(), it will return 'Hello, World!'

  # the mock object allows you to verify interactions as before
  my $MockedLogger = $MockLoggerBuilder->getMockObject();
  ok(WasCalled($MockedLogger, 'log'), 'log was called');

  done_testing();

=head1 DESCRIPTION

Use L<Test::Mockify::Injector> to inject all of the mocks and spies defined on a
L<Test::Mockify> instance in place of the real methods. This allows you to test
systems that have hard-coded dependencies or call static methods.

=head1 METHODS

=cut

package Test::Mockify::Injector;
use Test::Mockify::Tools qw ( Error );
use Sub::Override;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self  = bless {}, $class;
    $self->{'override'} = Sub::Override->new();
    return $self;
}

#----------------------------------------------------------------------------------------
=pod

=head2 inject

This method takes a parameter of the type L<Test::Mockify>. It loops through all of the
mocks and spies defined on it, and replaces the real methods with their mocked or spied
counterparts. When the injector goes out of scope, the original functionality is restored.

  # build a new mocked object
  my $MockObjectBuilder = Test::Mockify->new('My::Module');
  $MockObjectBuilder->mock('hello')->whenAny()->thenReturn('Hey');

  {
    # create injector
    my $Injector = Test::Mockify::Injector->new();

    # inject the builder
    $Injector->inject($MockObjectBuilder);

    print My::Module::hello(); # outputs 'Hey'
  }

  print My::Module::hello(); # outputs 'Hello'

=cut
sub inject {
    my ($self, $mockBuilder) = @_;
    Error('Object must be an instance of Test::Mockify') unless $mockBuilder->isa('Test::Mockify');
    foreach my $method (keys %{$mockBuilder->{'MethodStore'}}) {
        my $target = $mockBuilder->_mockedModulePath().'::'.$method;
        my $mockedSelf = $mockBuilder->_mockedSelf();
        my $mockRef = sub {
            shift;
            return $mockedSelf->$method(@_);
        };
        $self->{'override'}->replace($target, $mockRef);
    }
    return;
}

1;