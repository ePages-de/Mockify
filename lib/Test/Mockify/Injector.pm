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
    my ($MethodName, $Method) = @_;

    ExistsMethod( $self->_mockedModulePath(), $MethodName );
    my $mockedSelf = $self->_mockedSelf();
    $mockedSelf->{'__MethodCallCounter'}->addMethod( $MethodName );
    if(not $self->{'MethodStore'}{$MethodName}){
        $self->{'MethodStore'}{$MethodName} //= $Method;
        my $MockedMethodBody = sub {
            my @MockedParameters = @_;
            $mockedSelf->{'__MethodCallCounter'}->increment( $MethodName );
            push @{$mockedSelf->{$MethodName.'_MockifyParams'}}, \@MockedParameters;
            return $Method->call(@MockedParameters);
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
    use Mailer;

    sub sendMessage {
        my ($self, $recipient, $message) = @_;
        if (Mailer::send($recipient, $message)) {
            print 'Message sent successfully';
        } else {
            print 'Message failed to send';
        }
    }

    1;

Example usage

    package Test_SUT;

    my $injector = Test::Mockify::Injector->new('Mailer');
    $injector->mock('send')->when(String('this@will.fail'), String("You're invited!"))->thenReturn(0);
    $injector->mock('send')->when(String('this@will.succeed'), String("You're invited!"))->thenReturn(1);

    SUT->sendMessage('this@will.fail', "You're invited!"); # prints 'Message failed to send'
    SUT->sendMessage('this@will.succeed', "You're invited!"); # prints 'Message sent successfully'

    1;

=head2 spy

Spies allow you to observe interactions with classes and objects, rather than redefine their behavior.
NOTE: Mocks have the same verification capabilities as spies.

    package SUT;
    use Mailer;

    sub sendMessage {
        my ($self, $recipient, $message) = @_;
        if (Mailer::send($recipient, $message)) {
            print 'Message sent successfully';
        } else {
            print 'Message failed to send';
        }
    }

    1;

Example usage

    package Test_SUT;

    my $injector = Test::Mockify::Injector->new('Mailer');
    $injector->spy('send')->whenAny();

    SUT->sendMessage('a@b.c', 'Happy birthday!');
    SUT->sendMessage('x@y.z', 'Happy Holidays!');

    my $verifier = $injector->getVerifier();
    ok(WasCalled($verifier, 'send'), 'The mailer's send method was called');
    is(GetCallCount($verifier, 'send'), 2, 'The mailer's send method was called twice');

    1;

=head1 AUTHOR

Dustin Buckenmeyer E<lt>dustin.buckenmeyer@gmail.comE<gt>
Thanks to L<ECS Tuning|https://www.ecstuning.com/> for allowing me to pursue this idea and ultimately give it back to the community!

=cut
