package Tools;
use Module::Load;
use strict;
use Data::Dumper;
use base qw( Exporter );
our @EXPORT_OK = qw (
        Error
        ExistsMethod
        IsValid
        LoadPackage
        Isa
    );

#------------------------------------------------------------------------
sub LoadPackage {
    my ($Package) = @_;

    my $PackageFileName = join( '/', split /::/, $Package ) . '.pm';
    load($PackageFileName);
    return;
}
#------------------------------------------------------------------------
sub IsValid {
    my ($Value) = @_;

    my $IsValid = 0;
    if( defined($Value) && $Value ne '' ){
        $IsValid = 1;
    }
    return $IsValid;
}
#------------------------------------------------------------------------
sub ExistsMethod {
    my ( $PathOrObject, $MethodName ) = @_;

    if( not $PathOrObject->can( $MethodName ) ){
        if( IsValid( ref( $PathOrObject ) ) ){
            Error( ref( $PathOrObject )." donsn't have a method like: $MethodName" );
        }else{
            Error( $PathOrObject." donsn't have a method like: $MethodName" );
        }
    }

    return;
}
#------------------------------------------------------------------------
sub Isa {
    my ($Object, $ClassName) = @_;
    return 0 unless blessed( $Object );
    return $Object->isa( $ClassName );
}

#------------------------------------------------------------------------
sub Error {
    my ($Message, $hData) = @_;

    my ($package, $filename, $line) = caller(3);
    local $Data::Dumper::Terse = 1;
    my $DumpedData = Dumper($hData);
    die("$Message: $DumpedData $filename at line $line \n");
    return;
}

1;
