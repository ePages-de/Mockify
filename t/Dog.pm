package Dog;
use strict;
use warnings;

sub new {
    my ($class, $breed) = @_;
    my $self = bless { breed => $breed }, $class;
    return $self;
}

sub breed {
    my $self = shift;
    return $self->{'breed'};
}

1;