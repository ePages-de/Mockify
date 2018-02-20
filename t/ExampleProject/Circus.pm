package t::ExampleProject::Circus;
use t::ExampleProject::Show;
sub new {
    return bless({},$_[0]);
}

sub getShow {
    my $self = shift;
    my $Show = t::ExampleProject::Show();
    return $Show;
}
1;