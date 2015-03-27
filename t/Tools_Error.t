package t::Tools_Error;
use base t::TestBase;
use strict;
use Test::Exception;
use Tools qw (Error);
use Test::More;
#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    $self->test_ErrorWithoutMessage();
    $self->test_ErrorWithoutMockedMethod();
    $self->test_ErrorWithoutMockedMethodAndDataBlock();
    $self->test_ErrorWithMockedMethod();

    return;
}
#------------------------------------------------------------------------
sub test_ErrorWithoutMessage {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $RegEx = $self->_getErrorRegEx_ErrorWithoutMockedMethod();
    throws_ok( sub{Error()},
        qr/^Message is needed at Tools.pm line \d+.$/,
        "$SubTestName - tests if Error works well"
    );
    ;

    return;
}
#------------------------------------------------------------------------
sub test_ErrorWithoutMockedMethod {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $RegEx = $self->_getErrorRegEx_ErrorWithoutMockedMethod();
    throws_ok( sub{Error('AnErrorMessage')},
        qr/^$RegEx$/,
        "$SubTestName - tests if Error works well"
    );
    ;

    return;
}
#------------------------------------------------------------------------
sub test_ErrorWithMockedMethod {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $RegEx = $self->_getErrorRegEx_ErrorWithMockedMethod();
    throws_ok( sub{Error('AnErrorMessage',{'Method'=>'aMockedMethod'})},
        qr/^$RegEx$/,
        "$SubTestName - tests if Error works well"
    );
    ;

    return;
}
#------------------------------------------------------------------------
sub test_ErrorWithoutMockedMethodAndDataBlock {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $RegEx = $self->_getErrorRegEx_ErrorWithoutMockedMethodAndDataBlock();
    throws_ok( sub{Error('AnErrorMessage',{'key'=>'value'})},
        qr/^$RegEx$/,
        "$SubTestName - tests if Error works well"
    );
    ;

    return;
}

#------------------------------------------------------------------------
# helpers
#------------------------------------------------------------------------
sub _getErrorRegEx_ErrorWithoutMockedMethod {
    return <<'END_REGEX';
AnErrorMessage:
MockedMethod: -not set-
Data:{}
Test::Exception::throws_ok,t/Tools_Error.t\(line \d+\)
t::Tools_Error::test_ErrorWithoutMockedMethod,t/Tools_Error.t\(line \d+\)
t::Tools_Error::testPlan,t/TestBase.pm\(line \d+\)
t::TestBase::RunTest,t/Tools_Error.t\(line \d+\)
END_REGEX
END;
}
#------------------------------------------------------------------------
sub _getErrorRegEx_ErrorWithMockedMethod {
    return <<'END_REGEX';
AnErrorMessage:
MockedMethod: aMockedMethod
Data:{}
Test::Exception::throws_ok,t/Tools_Error.t\(line \d+\)
t::Tools_Error::test_ErrorWithMockedMethod,t/Tools_Error.t\(line \d+\)
t::Tools_Error::testPlan,t/TestBase.pm\(line \d+\)
t::TestBase::RunTest,t/Tools_Error.t\(line \d+\)
END_REGEX
END;
}
#------------------------------------------------------------------------
sub _getErrorRegEx_ErrorWithoutMockedMethodAndDataBlock {
    return <<'END_REGEX';
AnErrorMessage:
MockedMethod: -not set-
Data:{key='value'}
Test::Exception::throws_ok,t/Tools_Error.t\(line \d+\)
t::Tools_Error::test_ErrorWithoutMockedMethodAndDataBlock,t/Tools_Error.t\(line \d+\)
t::Tools_Error::testPlan,t/TestBase.pm\(line \d+\)
t::TestBase::RunTest,t/Tools_Error.t\(line \d+\)
END_REGEX
END;
}
__PACKAGE__->RunTest();
1;