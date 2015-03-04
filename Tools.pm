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
#------------------------------------------------------------------------
sub isValid {
	my $self = shift;
    my ($Value) = @_;

    my $IsValid = 0;
    if( defined($Value) && $Value ne '' ){
        $IsValid = 1;
        #exclude empty hash
        if( ref($Value) eq 'HASH' ){
            if( scalar keys %{$Value} == 0 ){
                $IsValid = 0;
            }
            # do compare with { '' => undef } ???
            use Data::Dumper;
            print Dumper values $Value;
        } 
        #exclude empty array
        if( ref($Value) eq 'ARRAY' && (scalar @{$Value}) == 0){
            $IsValid = 0;
        }
    }
	return $IsValid;
}
1;
