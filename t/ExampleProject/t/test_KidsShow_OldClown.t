package test_KidsShow_OldClown;
use strict;
use FindBin;
use lib ($FindBin::Bin);
use parent 'TestBase';
use Test::More;
use t::ExampleProject::MagicShow::Rabbit;
use t::ExampleProject::KidsShow::OldClown;
#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;

    my $KilocaloriesForBreakfast = 30000;
    is(t::ExampleProject::KidsShow::OldClown::BeHavy($KilocaloriesForBreakfast), 30, 'Prove old clown weight calculation');
}

__PACKAGE__->RunTest();
1;