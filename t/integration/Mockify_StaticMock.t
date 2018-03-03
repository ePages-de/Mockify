package Mockify_StaticMock;
use strict;
use FindBin;
use lib ($FindBin::Bin.'/..'); # point to test base
use lib ($FindBin::Bin.'/../..'); # point to project base
use parent 'TestBase';
use Test::More;
use Test::Mockify;
use Test::Mockify::Matcher qw (
        Number
    );
use t::TestDummies::DummyStaticToolsUser;
use Test::Mockify::Verify qw (GetParametersFromMockifyCall GetCallCount);
#----------------------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->test_InjectionOfStaticedMethod_scopes();
    $self->test_InjectionOfStaticedMethod_scopes_spy();
    $self->test_InjectionOfStaticedMethod_SetMockifyToUndef();
    $self->test_InjectionOfStaticedMethod_Verify();
#    $self->test_InjectionOfStaticedMethod_Verify_spy();
}

#----------------------------------------------------------------------------------------
sub test_InjectionOfStaticedMethod_scopes {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    is(
        t::TestDummies::DummyStaticToolsUser->new()->useDummyStaticTools(2),
        'In useDummyStaticTools, result Tripler call: "6"',
        "$SubTestName - prove the unmocked Result"
    );
    {#beginn scope
        my $Mockify = Test::Mockify->new('t::TestDummies::DummyStaticToolsUser',[]);
        $Mockify->mockStatic('t::TestDummies::DummyStaticTools::Tripler')->when(Number(2))->thenReturn('InjectedReturnValueOfTripler');
        my $DummyStaticToolsUser = $Mockify->getMockObject();
        is(
            $DummyStaticToolsUser->useDummyStaticTools(2),
            'In useDummyStaticTools, result Tripler call: "InjectedReturnValueOfTripler"',
            "$SubTestName - Prove that the injection works out"
        );
    } # end scope
    is(
        t::TestDummies::DummyStaticToolsUser->new()->useDummyStaticTools(2),
        'In useDummyStaticTools, result Tripler call: "6"',
        "$SubTestName - prove the unmocked Result"
    );
}
#----------------------------------------------------------------------------------------
sub test_InjectionOfStaticedMethod_scopes_spy {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    is(
        t::TestDummies::DummyStaticToolsUser->new()->useDummyStaticTools(2),
        'In useDummyStaticTools, result Tripler call: "6"',
        "$SubTestName - prove the unmocked Result"
    );
    {#beginn scope
        my $Mockify = Test::Mockify->new('t::TestDummies::DummyStaticToolsUser',[]);
        $Mockify->spyStatic('t::TestDummies::DummyStaticTools::Tripler')->when(Number(2));
        my $DummyStaticToolsUser = $Mockify->getMockObject();
        is(
            $DummyStaticToolsUser->useDummyStaticTools(2),
            'In useDummyStaticTools, result Tripler call: "6"',
            "$SubTestName - Prove that the injection works out"
        );
    } # end scope
    is(
        t::TestDummies::DummyStaticToolsUser->new()->useDummyStaticTools(2),
        'In useDummyStaticTools, result Tripler call: "6"',
        "$SubTestName - prove the unmocked Result"
    );
}
#----------------------------------------------------------------------------------------
sub test_InjectionOfStaticedMethod_SetMockifyToUndef {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    is(
        t::TestDummies::DummyStaticToolsUser->new()->useDummyStaticTools(2),
        'In useDummyStaticTools, result Tripler call: "6"',
        "$SubTestName - prove the unmocked Result"
    );
    my $Mockify = Test::Mockify->new('t::TestDummies::DummyStaticToolsUser',[]);
    $Mockify->mockStatic('t::TestDummies::DummyStaticTools::Tripler')->when(Number(2))->thenReturn('InjectedReturnValueOfTripler');
    my $DummyStaticToolsUser = $Mockify->getMockObject();
    is(
        $DummyStaticToolsUser->useDummyStaticTools(2),
        'In useDummyStaticTools, result Tripler call: "InjectedReturnValueOfTripler"',
        "$SubTestName - Prove that the injection works out"
    );
    $Mockify = undef;
    $DummyStaticToolsUser = undef;
    is(
        t::TestDummies::DummyStaticToolsUser->new()->useDummyStaticTools(2),
        'In useDummyStaticTools, result Tripler call: "6"',
        "$SubTestName - prove the unmocked Result"
    );
}
#----------------------------------------------------------------------------------------
sub test_InjectionOfStaticedMethod_Verify {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $Mockify = Test::Mockify->new('t::TestDummies::DummyStaticToolsUser',[]);
    $Mockify->mockStatic('t::TestDummies::DummyStaticTools::Tripler')->when(Number(2))->thenReturn('InjectedReturnValueOfTripler');
    my $DummyStaticToolsUser = $Mockify->getMockObject();
    is(
        $DummyStaticToolsUser->useDummyStaticTools(2),
        'In useDummyStaticTools, result Tripler call: "InjectedReturnValueOfTripler"',
        "$SubTestName - Prove that the injection works out"
    );
    my $aParams =  GetParametersFromMockifyCall($DummyStaticToolsUser, 't::TestDummies::DummyStaticTools::Tripler');
    is(scalar @$aParams ,1 , "$SubTestName - prove amount of parameters");
    is($aParams->[0] ,2 , "$SubTestName - get parameter of first call");
    is(  GetCallCount($DummyStaticToolsUser, 't::TestDummies::DummyStaticTools::Tripler'), 1, "$SubTestName - prove that the the Tripler only get called once.");

}
#----------------------------------------------------------------------------------------
sub test_InjectionOfStaticedMethod_Verify_spy {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $Mockify = Test::Mockify->new('t::TestDummies::DummyStaticToolsUser',[]);
    $Mockify->spyStaticed('t::TestDummies::DummyStaticTools', 'Tripler')->when(Number(2));
    my $DummyStaticToolsUser = $Mockify->getMockObject();
    is(
        $DummyStaticToolsUser->useDummyStaticTools(2),
        'In useDummyStaticTools, result Tripler call: "4"',
        "$SubTestName - Prove that the injection works out"
    );
    my $aParams =  GetParametersFromMockifyCall($DummyStaticToolsUser, 'Tripler');
    is(scalar @$aParams ,1 , "$SubTestName - prove amount of parameters");
    is($aParams->[0] ,2 , "$SubTestName - get parameter of first call");
    is(  GetCallCount($DummyStaticToolsUser, 'Tripler'), 1, "$SubTestName - prove that the the Tripler only get called once.");

}
__PACKAGE__->RunTest();
1;