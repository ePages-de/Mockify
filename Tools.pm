package Tools;
use Module::Load;
use strict;

#------------------------------------------------------------------------
sub new {
    my $Class = shift;
    my $self = bless({},$Class);
    return $self;
}

#------------------------------------------------------------------------
sub loadPackage {
    my $self = shift;
    my ($Package) = @_;

    my $PackageFileName = join( '/', split /::/, $Package ) . '.pm';
    load($PackageFileName);
    return;
}

1;
