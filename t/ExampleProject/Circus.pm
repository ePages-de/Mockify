package ExampleProject::Circus;
use strict;

use t::ExampleProject::MagicShow::Magician;
use t::ExampleProject::KidsShow::TimberBeam;
use t::ExampleProject::KidsShow::SeeSaw;

sub new {
    my $class = shift;
    my ($Magician)  = @_;
    my $self  = bless {
        'Magician' => $Magician ? $Magician :  t::ExampleProject::MagicShow::Magician->new(),
    }, $class;
    return $self;
}
#----------------------------------------------------------------------------------------
sub getLineUp {
    my $self = shift;
    my $aLineUpList = [];

    # Usecase: Lazy constructor injection and method call
    push(@{$aLineUpList}, $self->{'Magician'}->getLineUpName());

    # Usecase: Static fully qualified path function call
    push(@{$aLineUpList}, t::ExampleProject::KidsShow::TimberBeam::GetLineUpName());

    # Usecase: create instance and method call
    push(@{$aLineUpList}, t::ExampleProject::KidsShow::SeeSaw->new()->getLineUpName() );

    return $aLineUpList;
}

1;