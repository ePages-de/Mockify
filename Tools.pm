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
#------------------------------------------------------------------------
sub existsMethod {
    my $self = shift;
    my ( $PathOrObject, $MethodName ) = @_;

    if( not $PathOrObject->can( $MethodName ) ){
        if( $self->isValid( ref( $PathOrObject ) ) ){
            die( ref( $PathOrObject )." donsn't have a method like: $MethodName" );
        }else{
            die( $PathOrObject." donsn't have a method like: $MethodName" );
        }
    }

    return;
}
#------------------------------------------------------------------------
sub checkIsa {
    my $self = shift;
    my ($Object, $ClassName) = @_;
    return 0 unless blessed( $Object );
    return $Object->isa( $ClassName );
}
1;
