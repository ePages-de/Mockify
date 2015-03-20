package Tools;
use Module::Load;
use strict;
use Data::Dumper;
use Scalar::Util qw( blessed );
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

    die('Path or Object is needed') unless defined $PathOrObject;
    die('Method name is needed') unless defined $MethodName;
    if( not $PathOrObject->can( $MethodName ) ){
        if( IsValid( ref( $PathOrObject ) ) ){
            $PathOrObject = ref( $PathOrObject );
        }
        die( $PathOrObject." donsn't have a method like: $MethodName" );
    }

    return 1;
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

    my ($package, $filename, $line) = caller(5);
    
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Pair = '=';
    local $Data::Dumper::Quotekeys = 0;
    my $MockedMethod = delete $hData->{'Method'} if defined $hData->{'Method'};

    my $DumpedData = Dumper($hData);
    die("$Message:$DumpedData\nMockedMethod=$MockedMethod\nat $filename line $line \n");
    return;
}   

1;
