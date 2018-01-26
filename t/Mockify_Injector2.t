package Mockify_Injector;

use FindBin;
use lib ($FindBin::Bin);

use parent 'TestBase';
use Test::Exception;
use Test::Mockify;
use Test::Mockify::Injector;
use Test::Mockify::Verify qw (WasCalled GetCallCount);
use Test::More;
use Test::Mockify::Matcher qw (Object String);
use warnings;
use Data::Dumper;


use strict;
no warnings 'deprecated';

use FakeModuleForMockifyTest;
use FakeModuleWithoutNew;

sub testPlan {
    my $self = shift;

    $self->useMethodWhichUsesStaticFunction();
}
#----------------------------------------------------------------------------------------
sub useMethodWhichUsesStaticFunction {
    my $self = shift;
    my $SubTestName = (caller(0))[3];
    my $SUT;
    {
        my $Injector = Test::Mockify::Injector->new('FakeModuleForMockifyTest');
        $Injector->staticFunctionOverride('Test::Mockify::Tools::Isa')->when(Object(),String('eins'))->thenReturn('one');
        $Injector->staticFunctionOverride('Test::Mockify::Tools::Isa')->when(Object(),String('zwei'))->thenReturn('two');
        $SUT = $Injector->getSystemUnderTest();

        is($SUT->useStaticFunction('eins'), 'one',"$SubTestName - bla 1");
        is($SUT->useStaticFunction('zwei'), 'two',"$SubTestName - bla 2");
        is($SUT->useImportedStaticFunction('zwei'), 'two',"$SubTestName - static use");
    }
    # With this approach it also is not binded anymore to the scope. The Override stays with the mocked object
    is($SUT->useStaticFunction('zwei'), 'two',"$SubTestName - bla 4");
    is($SUT->useImportedStaticFunction('eins'), 'one',"$SubTestName - bla 5");

    ok( WasCalled($SUT, 'Test::Mockify::Tools::Isa'), "$SubTestName - prove verify ");
    is( GetCallCount($SUT, 'Test::Mockify::Tools::Isa'),  5,"$SubTestName - prove verify called  5 times");
    
}

__PACKAGE__->RunTest();