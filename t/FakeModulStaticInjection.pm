package FakeModulStaticInjection;

use strict;
use FakeStaticTools qw ( ReturnHelloWorld );

sub useStaticFunction {
    my $self = shift;
    my ($PreFix) = @_;
    return $PreFix . ': '.FakeStaticTools::ReturnHelloWorld($PreFix);
}

sub useImportedStaticFunction {
    my $self = shift;
    my ($PreFix) = @_;
    return $PreFix . ': '.ReturnHelloWorld($PreFix);

}
1;