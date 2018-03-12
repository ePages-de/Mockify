package Mockify_Sut;
use strict;
use FindBin;
## no critic (ProhibitComplexRegexes)
use lib ($FindBin::Bin.'/..'); # point to test base
use lib ($FindBin::Bin.'/../..'); # point to project base
use parent 'TestBase';
use Test::More;
use Test::Mockify::Sut;
use Test::Exception;
use Test::Mockify::Matcher qw (
        Number
    );
use t::TestDummies::DummyImportToolsUser_Static;
use Test::Mockify::Verify qw (GetParametersFromMockifyCall GetCallCount);
use t::TestDummies::DummyImportTools qw (Doubler);
#----------------------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->test_InjectionOfImportedMethod();
    $self->test_InjectionOfStaticMethod();
    $self->test_ErrorOnMockSutMethod();
}

#----------------------------------------------------------------------------------------
sub test_InjectionOfImportedMethod {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

        my $Mockify = Test::Mockify::Sut->new('t::TestDummies::DummyImportToolsUser_Static');
        $Mockify->mockImported('t::TestDummies::DummyImportTools', 'Doubler')->when(Number(2))->thenReturn('InjectedReturnValueOfDoubler');
        my $VerificationObject = $Mockify->getVerificationObject();
        is(
            t::TestDummies::DummyImportToolsUser_Static::useDummyImportTools(2),
            'In useDummyImportTools, result Doubler call: "InjectedReturnValueOfDoubler"',
            "$SubTestName - Prove that the injection works out"
        );
        is(GetCallCount($VerificationObject, 'Doubler'),1,"$SubTestName - prove the verify output");
        is($VerificationObject, $Mockify->getMockObject(), "$SubTestName - prove that both returning the same");
}
#----------------------------------------------------------------------------------------
sub test_InjectionOfStaticMethod {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

        my $Mockify = Test::Mockify::Sut->new('t::TestDummies::DummyStaticToolsUser_Static');
        $Mockify->mockStatic('t::TestDummies::DummyStaticTools::Tripler')->when(Number(2))->thenReturn('InjectedReturnValueOfTripler');
        my $VerificationObject = $Mockify->getVerificationObject();
        is(
            t::TestDummies::DummyStaticToolsUser_Static::useDummyStaticTools(2),
            'In useDummyStaticTools, result Tripler call: "InjectedReturnValueOfTripler"',
            "$SubTestName - Prove that the injection works out"
        );
        is(GetCallCount($VerificationObject, 't::TestDummies::DummyStaticTools::Tripler'),1,"$SubTestName - prove the verify output");
        is($VerificationObject, $Mockify->getMockObject(), "$SubTestName - prove that both returning the same");
}
#----------------------------------------------------------------------------------------
sub test_ErrorOnMockSutMethod {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

        my $Mockify = Test::Mockify::Sut->new('t::TestDummies::DummyImportToolsUser_Static');
        throws_ok( sub { $Mockify->mock('OverrideDummyFunctionUser') },
                       qr/It is not possible to mock a method of your SUT. Don't mock the code you like to test./sm,
                       "$SubTestName - Prove the error when try to mock a method of the SUT"
             );
        ;
}
__PACKAGE__->RunTest();
1;