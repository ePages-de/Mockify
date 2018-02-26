package t::ExampleProject::Show;
use t::ExampleProject::MagicShow::Magician;
use t::ExampleProject::MagicShow::Rabbit;

sub new {
    return bless({},$_[0]);
}
sub watch {
    my $self = shift;
    my @ShowResult = ();
    push(@ShowResult, $self->_watchMagician());
    return \@ShowResult;
}
sub _watchMagician {
    my $self = shift;
    my $Magician = t::ExampleProject::Magician->new();
    return 'Magician said: '. $Magician->pullRabbit();
}
1;