package Tools;
use Module::Load;
use strict;
use Data::Dumper;

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
#------------------------------------------------------------------------
sub isValid {
	my $self = shift;
    my ($Value) = @_;

    my $IsValid = 0;
    if( defined($Value) && $Value ne '' ){
        $IsValid = 1;
    }
	return $IsValid;
}

1;
