package Test::Mockify::Sut;
use strict;
use warnings;
use parent 'Test::Mockify';

use Test::Mockify::Tools qw (Error);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}

sub mock {
    Error('It is not possible to mock a method of your SUT. Don\'t mock the code you like to test.');
}

sub getVerificationObject{
    my $self = shift;
    return $self->getMockObject();
}

1;