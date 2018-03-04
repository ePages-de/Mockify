package t::ExampleProject::KidsShow::OldClown;
use strict;

sub BeHavy {
    my ($KilocaloriesForBreakfast) = @_;
    return $KilocaloriesForBreakfast / 1000; ## no critic (ProhibitMagicNumbers)
}
1;