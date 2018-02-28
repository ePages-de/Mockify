package test_KidsShow_TimberBeam;
use strict;
use FindBin;
use lib ("$FindBin::Bin/../.."); #Path to test base
use lib ("$FindBin::Bin/../../.."); #Path to example project
use parent 'TestBase';
use Test::More;
use Test::Mockify;
use Test::Mockify::Matcher qw (Number);
use t::ExampleProject::KidsShow::TimberBeam;
#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;

    # To find the right numbers in order to have predictiable results for the 'clown-classes' is not the scope of this class
    # This test takes care of the right behavior of the seesaw class
    my $Mockify = Test::Mockify->new('t::ExampleProject::KidsShow::TimberBeam');
    $Mockify->mockImported('t::ExampleProject::KidsShow::NewClown','ShowOfWeight')->when(Number(10))->thenReturn(10);
    $Mockify->mockImported('t::ExampleProject::KidsShow::NewClown','ShowOfWeight')->when(Number(20))->thenReturn(20);
    $Mockify->mockStatic('t::ExampleProject::KidsShow::OldClown::BeHavy')->when(Number(10))->thenReturn(10);
    $Mockify->mockStatic('t::ExampleProject::KidsShow::OldClown::BeHavy')->when(Number(20))->thenReturn(20);

    is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(10, 10), 'balanced', 'prove if the seesaw can be balanced');
    is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(10, 20),'Old clown wins', 'prove if the seesaw can toss to the right');
    is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(20, 10),'New clown wins', 'prove if the seesaw can toss to the left');

    $Mockify = undef; #The mock is active aslong the Mockify is defined / in scope
    is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(10, 10), 'New clown wins', 'prove that the mock is active aslong the Mockify is defined / in scope');
    return;
}

__PACKAGE__->RunTest();
1;