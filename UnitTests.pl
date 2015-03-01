#!/usr/bin/perl
package UnitTests;
use strict;
print(".: Call Mockify Unit tests :.\n");
my $TestDirectory = 't';
my @UnitTestsModules = glob("$TestDirectory/*.t");

foreach my $UnitTestModul (@UnitTestsModules){
    system('perl', ($UnitTestModul));
}

1;
