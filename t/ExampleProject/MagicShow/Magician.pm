package t::ExampleProject::MagicShow::Magician;

sub new {
    my $class = shift;
    my ($Rabbit) = @_;
    my $self  = bless ({
        'Rabbit' => $Rabbit ? $Rabbit : t::ExampleProject::MagicShow::Rabbit->new(),
    }, $class);
    return $self;
}

sub pullRabbit {
    my $self = shift;
    return $self->{'Rabbit'};
}

1;