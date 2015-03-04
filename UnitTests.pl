#!/usr/bin/perl
package UnitTests;
use strict;
print("\n" x 4);
print("#" x 80,"\n");
print("# Call Mockify Unit tests in t folder!\n");
print("#" x 80,"\n");
print("\n");
my $TestDirectory = 't';
my @UnitTestsModules = glob("$TestDirectory/*.t");

foreach my $UnitTestModul (@UnitTestsModules){
    system('perl', ($UnitTestModul));
}

1;
