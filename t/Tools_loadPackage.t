package Tools_loadPackage;
use strict;

use FindBin;
use lib ($FindBin::Bin);

use parent 't::TestBase';
use Test::More;
use Devel::Mockify::Tools qw ( LoadPackage );

#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;

    $self->LoadFakeModuleForMockifyTest();
    $self->LoadAllreadyLoadedModule();

    return;
}

#------------------------------------------------------------------------
sub LoadFakeModuleForMockifyTest {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    my $ModulePath = 't/FakeModuleForMockifyTest.pm';
    is($INC{$ModulePath}, undef ,"$SubTestName - check if the module is not loaded now - undef");
    LoadPackage('t::FakeModuleForMockifyTest');
    ok( $INC{$ModulePath}, "$SubTestName - the module: $ModulePath is loaded");
    delete $INC{$ModulePath};# rollback
    is($INC{$ModulePath}, undef ,"$SubTestName - check if the module is not loaded now (rollback was fine)- undef");

    return;
}

#------------------------------------------------------------------------
sub LoadAllreadyLoadedModule {
    my $self = shift;
    my $SubTestName = (caller(0))[3];

    use Devel::Mockify::TypeTests;
    my $ModulePath = 'Devel/Mockify/TypeTests.pm';
    ok( $INC{$ModulePath}, "$SubTestName - the module: $ModulePath is already loaded");
    LoadPackage('Devel::Mockify::TypeTests');
    ok( $INC{$ModulePath}, "$SubTestName - the module: $ModulePath is still loaded");

    return;
}

__PACKAGE__->RunTest();
1;
