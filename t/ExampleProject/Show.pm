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
    my ($Arguments) = @_;
    my $Magician = t::ExampleProject::Magician->new();
    my $Rabbit = $Magician->pullRabbit();
    my $Say = 'Magician: Tada!';
    if($Rabbit->isSnappyToday()){
        return $Say.' ouch';
    }
    return $Say;
}
1;