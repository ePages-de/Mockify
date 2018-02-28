package t::ExampleProject::KidsShow::SeeSaw;
use t::ExampleProject::KidsShow::OldClown;
use t::ExampleProject::KidsShow::NewClown qw ( ShowOfWeight );
use strict;

sub new {
    return bless({},$_[0]);
}

sub upAndDown {
    my $self = shift;
    my ($Number1, $Number2) = @_;

    my $WeightNewClown = ShowOfWeight($Number1);
    my $WeightOldClown = t::ExampleProject::KidsShow::OldClown::BeHavy($Number2);
    if($WeightNewClown > $WeightOldClown){
        return 'New clown wins';
    }elsif($WeightNewClown == $WeightOldClown){
        return 'balanced';
    }else{
        return 'Old clown wins';
    }
    return;
}

1;