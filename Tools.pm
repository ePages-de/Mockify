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
        #exclude empty hash
        if( ref($Value) eq 'HASH' ){
            if( scalar keys %{$Value} == 0 ){
                $IsValid = 0;
            }
            my %CompareHash = undef; 
            if ($self->_compareComplexType($Value, \%CompareHash)){
                $IsValid = 0;
            }
        } 
        #exclude empty array
        if( ref($Value) eq 'ARRAY'){
            if(scalar @{$Value} == 0){
                $IsValid = 0;
            }
            my @CompareArray = undef; 
            if ($self->_compareComplexType($Value, \@CompareArray)){
                $IsValid = 0;
            }
        }
    }
	return $IsValid;
}

#------------------------------------------------------------------------
sub _compareComplexType {
    my $self = shift;
    my ( $ValueA, $ValueB  ) = @_;

    my $IsTheSame = 0;
    my $SerializedHashA = Dumper($ValueA);
    my $SerializedHashB = Dumper($ValueB);

    if ( $SerializedHashA eq $SerializedHashB ){
        $IsTheSame = 1;
    }

    return $IsTheSame;
}

1;
