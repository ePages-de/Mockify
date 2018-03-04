package t::TestDummies::DummyImportToolsUser_Static;
use strict;
use warnings;
use FindBin;
use lib ($FindBin::Bin.'/..');
use t::TestDummies::DummyImportTools qw (Doubler);

sub useDummyImportTools {
    my ($Value) = @_;
    return 'In useDummyImportTools, result Doubler call: "'.Doubler($Value).'"';
}
1;