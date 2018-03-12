package test_KidsShow_TimberBeam;
## no critic (ProhibitMagicNumbers)
use strict;
use FindBin;
use lib ("$FindBin::Bin/../.."); #Path to test base
use lib ("$FindBin::Bin/../../.."); #Path to example project
use parent 'TestBase';
use Test::More;
use Test::Mockify;
use Test::Mockify::Matcher qw (Number);
use t::ExampleProject::KidsShow::TimberBeam;
use Test::Mockify::Verify qw (WasCalled GetCallCount);
#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;

    $self->test_OverrideMockifyToRemoveStaticMocks();
    $self->test_LeaveScopeToRemoveStaticMocks();

    return;
}
sub test_OverrideMockifyToRemoveStaticMocks {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $Mockify = Test::Mockify->new('t::ExampleProject::KidsShow::TimberBeam');
    $Mockify->mockImported('t::ExampleProject::KidsShow::NewClown','ShowOfWeight')->when(Number(10))->thenReturn(10);
    $Mockify->mockImported('t::ExampleProject::KidsShow::NewClown','ShowOfWeight')->when(Number(20))->thenReturn(20);
    $Mockify->mockStatic('t::ExampleProject::KidsShow::OldClown::BeHeavy')->when(Number(10))->thenReturn(10);
    $Mockify->mockStatic('t::ExampleProject::KidsShow::OldClown::BeHeavy')->when(Number(20))->thenReturn(20);
    $Mockify->mock('_GetAge')->when()->thenReturn(7);

    is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(10, 10), 'balanced', " $SubTestName - prove if the TimberBeam can be balanced");
    is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(10, 20),'Old clown wins', " $SubTestName - prove if the TimberBeam can toss to the right");
    is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(20, 10),'New clown wins', " $SubTestName - prove if the TimberBeam can toss to the left");
    is(t::ExampleProject::KidsShow::TimberBeam::GetSecurityLevel(),'The TimberBeam is 70% ok', " $SubTestName - prove the Security level");

    my $TimberBeam = $Mockify->getMockObject(); #This is only needed for verification
    $Mockify = undef; #The mock is active as long as the Mockify is defined / in scope

    is(GetCallCount($TimberBeam, 'ShowOfWeight'), 3,"$SubTestName - Prove that imported ShowOfWeight was triggerd three times");
    is(GetCallCount($TimberBeam, 't::ExampleProject::KidsShow::OldClown::BeHeavy'), 3, "$SubTestName - Prove that static injected Functions BeHeavy was triggerd three times");
    ok(WasCalled($TimberBeam, '_GetAge'),"$SubTestName - Prove that _GetAge was triggerd");
    is(t::ExampleProject::KidsShow::TimberBeam::GetSecurityLevel(),'The TimberBeam is 50% ok', " $SubTestName - prove the Security level (out of scope)");
    is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(1, 1_000_000), 'balanced', " $SubTestName - prove that the mock is active as long as the Mockify is defined / in scope");

}
#----------------------------------------------------------------------------------------
sub test_LeaveScopeToRemoveStaticMocks {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $TimberBeam;
    { # create scope
        my $Mockify = Test::Mockify->new('t::ExampleProject::KidsShow::TimberBeam');
        $Mockify->mockImported('t::ExampleProject::KidsShow::NewClown','ShowOfWeight')->when(Number(10))->thenReturn(10);
        $Mockify->mockImported('t::ExampleProject::KidsShow::NewClown','ShowOfWeight')->when(Number(20))->thenReturn(20);
        $Mockify->mockStatic('t::ExampleProject::KidsShow::OldClown::BeHeavy')->when(Number(10))->thenReturn(10);
        $Mockify->mockStatic('t::ExampleProject::KidsShow::OldClown::BeHeavy')->when(Number(20))->thenReturn(20);
        $Mockify->mock('_GetAge')->when()->thenReturn(7);

        is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(10, 10), 'balanced', " $SubTestName - prove if the TimberBeam can be balanced");
        is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(10, 20),'Old clown wins', " $SubTestName - prove if the TimberBeam can toss to the right");
        is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(20, 10),'New clown wins', " $SubTestName - prove if the TimberBeam can toss to the left");
        is(t::ExampleProject::KidsShow::TimberBeam::GetSecurityLevel(),'The TimberBeam is 70% ok', " $SubTestName - prove the Security level");
        $TimberBeam = $Mockify->getMockObject(); #This is only needed for verification
    } # leave scope

    is(GetCallCount($TimberBeam, 'ShowOfWeight'), 3,"$SubTestName - Prove that imported ShowOfWeight was triggerd three times");
    is(GetCallCount($TimberBeam, 't::ExampleProject::KidsShow::OldClown::BeHeavy'), 3, "$SubTestName - Prove that static injected Functions BeHeavy was triggerd three times");
    ok(WasCalled($TimberBeam, '_GetAge'),"$SubTestName - Prove that _GetAge was triggerd");
    is(t::ExampleProject::KidsShow::TimberBeam::GetSecurityLevel(),'The TimberBeam is 50% ok', " $SubTestName - prove the Security level (out of scope)");
    is(t::ExampleProject::KidsShow::TimberBeam::UpAndDown(1, 1_000_000), 'balanced', " $SubTestName -prove that the mock is active as long as the Mockify is defined / in scope");
}
__PACKAGE__->RunTest();
1;