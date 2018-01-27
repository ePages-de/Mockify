package FakeModulStaticInjection;

use strict;
use FakeStaticTools qw ( ReturnHelloWorld HelloSpy);

sub overrideMethod {
    my $self = shift;
    return 'original Value';
}
sub overrideMethod_spy {
    my $self = shift;
    return 'original Value';
}
sub overrideMethod_addMock {
    my $self = shift;
    return 'original Value';
}

sub useStaticFunctionSpy {
    my $self = shift;
    my ($PreFix) = @_;
    return $PreFix . ': '.FakeStaticTools::HelloSpy(@_);
}
sub useImportedStaticFunctionSpy {
    my $self = shift;
    my ($PreFix) = @_;
    return $PreFix . ': '.HelloSpy(@_);
}

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