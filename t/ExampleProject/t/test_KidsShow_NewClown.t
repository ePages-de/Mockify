package test_KidsShow_NewClown;
use strict;
use FindBin;
use lib ($FindBin::Bin);
use parent 'TestBase';
use Test::More;
use t::ExampleProject::MagicShow::Rabbit;
use t::ExampleProject::KidsShow::NewClown qw ( ShowOfWeight );
#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;

    my $LitersOfWater = 10;
    is(ShowOfWeight($LitersOfWater), 10000, 'Prove new clown weight calculation');
}

__PACKAGE__->RunTest();
1;