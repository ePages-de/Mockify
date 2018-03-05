package t::TestDummies::DummyImportToolsUser_Static;
use strict;
use warnings;
use FindBin;
use lib ($FindBin::Bin.'/..');
use t::TestDummies::DummyImportTools qw (Doubler);

sub useDummyImportTools {
    my ($Value) = @_;
    my $Doubled = Doubler($Value);
    return "In useDummyImportTools, result Doubler call: \"$Doubled\"";
}
sub OverrideDummyFunctionUser {
    my ($Value) = @_;
    return '('._OverrideDummyFunction($Value)." with '$Value')";
}

sub _OverrideDummyFunction {
    my ($Value) = @_;
    return "(_OverrideDummyFunction: '$Value')";
}
1;