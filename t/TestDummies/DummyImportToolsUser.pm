package t::TestDummies::DummyImportToolsUser;
use strict;
use warnings;
use FindBin;
use lib ($FindBin::Bin.'/..');
use t::TestDummies::DummyImportTools qw (Doubler);
sub new {
    return bless({},$_[0]);
}

sub useDummyImportTools {
    my $self = shift;
    my ($Value) = @_;
    return 'In useDummyImportTools, result Doubler call: "'.Doubler($Value).'"';
}
1;