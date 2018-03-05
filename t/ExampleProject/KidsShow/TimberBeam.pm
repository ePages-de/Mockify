package t::ExampleProject::KidsShow::TimberBeam;
use t::ExampleProject::KidsShow::OldClown;
use t::ExampleProject::KidsShow::NewClown qw ( ShowOfWeight );
use strict;

sub UpAndDown {
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

sub GetSecurityLevel {
    my $Procent = _GetAge() * 10;## no critic (ProhibitMagicNumbers)
    return "The TimberBeam is $Procent% ok";
}

sub _GetAge {
    return 5;
}


1;