package FakeModulStaticInjection;

use strict;
use FakeStaticTools qw ( ReturnHelloWorld );

sub useStaticFunction {
    my $self = shift;
    my ($PreFix) = @_;
    return $PreFix . ': '.FakeStaticTools::ReturnHelloWorld(@_);
}

sub useImportedStaticFunction {
    my $self = shift;
    my ($PreFix) = @_;
    return $PreFix . ': '.ReturnHelloWorld(@_);

}
1;