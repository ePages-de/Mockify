package FakeStaticTools;
use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw (
        ReturnHelloWorld
        HelloSpy
    );
    
sub ReturnHelloWorld {
    #this method could, for example, access the database
    return 'Hello World';
}

sub HelloSpy {
    return 'Bond, James Bond!';
}