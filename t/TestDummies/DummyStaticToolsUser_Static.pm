package t::TestDummies::DummyStaticToolsUser_Static;
use strict;
use warnings;
use FindBin;
use lib ($FindBin::Bin.'/..');
use t::TestDummies::DummyStaticTools;


sub useDummyStaticTools {
    my ($Value) = @_;
    return 'In useDummyStaticTools, result Tripler call: "'.t::TestDummies::DummyStaticTools::Tripler($Value).'"';
}
1;