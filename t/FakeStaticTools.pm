package FakeStaticTools;
use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw (
        ReturnHelloWorld
    );
    
sub ReturnHelloWorld {
    #this method could, for example, access the database
    return 'Hallo Welt';
}