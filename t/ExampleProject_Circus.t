package ExampleProject_Circus;
use strict;
use FindBin;
use lib ($FindBin::Bin);
use parent 'TestBase';
use Test::More;
use t::ExampleProject::Circus;
#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->test_Circus();
    return;
}

#------------------------------------------------------------------------
sub test_Circus {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $Circus = t::ExampleProject::Circus->new();
    
    return;
}

__PACKAGE__->RunTest();
1;