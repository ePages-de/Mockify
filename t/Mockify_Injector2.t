package Mockify_Injector;

use FindBin;
use lib ($FindBin::Bin);

use parent 'TestBase';
use Test::Exception;
use Test::Mockify;
use Test::Mockify::Injector;
use Test::Mockify::Verify qw (WasCalled);
use Test::More;
use Test::Mockify::Matcher qw (String);
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
        $Injector->staticFunctionOverride('FakeStaticTools::ReturnHelloWorld')->when(String('Esperanto++'))->thenReturn('Saluton mondon');
        $Injector->staticFunctionOverride('FakeStaticTools::ReturnHelloWorld')->when(String('Spanish++'))->thenReturn('Hola Mundo');
        $SUT = $Injector->getSystemUnderTest();

        is($SUT->useStaticFunction('Esperanto'), 'Esperanto Saluton mondon',"$SubTestName - proves the internal call with FakeStaticTools::ReturnHelloWorld with matcher");
        is($SUT->useStaticFunction('Spanish'), 'Spanish Hola Mundo',"$SubTestName - proves the internal call with FakeStaticTools::ReturnHelloWorld with matcher");
        is($SUT->useImportedStaticFunction('Esperanto'), 'Esperanto Saluton mondon',"$SubTestName - proves the internal call with imported ReturnHelloWorld  with matcher");
    }
    # With this approach it also is not binded anymore to the scope. The Override stays with the mocked object
    is($SUT->useStaticFunction('Esperanto'), 'Esperanto Saluton mondon',"$SubTestName - test the not mocked version of ReturnHelloWorld  with matcher");

    ok( WasCalled($SUT, 'FakeStaticTools::ReturnHelloWorld'), "$SubTestName - prove verify ");
}

__PACKAGE__->RunTest();