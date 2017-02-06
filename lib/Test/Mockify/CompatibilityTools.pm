package Test::Mockify::CompatibilityTools;
use base qw ( Exporter );
use strict;
use warnings;
use Test::Mockify::Matcher qw (SupportedTypes);
use Test::Mockify::TypeTests qw ( IsString );

our @EXPORT_OK = qw (
    IntAndFloat2Number
    MigrateMatcherFormat
);
#---------------------------------------------------------------------------------------------------
sub MigrateMatcherFormat {
    my ( $Parameter ) = @_;

    if( ref($Parameter) ne 'HASH') {
        if(IsString($Parameter) && $Parameter ~~ SupportedTypes()){
            $Parameter = { $Parameter => 'NoExpectedParameter'};
        }else{
            die("Found unsupported type, '$Parameter'. Use Test::Mockify:Matcher to define nice parameter types.");
        }
    }

    return $Parameter;
}
#---------------------------------------------------------------------------------------------------
sub IntAndFloat2Number {
    my ( $aParameterTypes ) = @_;

    my @NewParams;
    for(my $i = 0; $i < scalar @{$aParameterTypes}; $i++){
        if(ref($aParameterTypes->[$i]) eq 'HASH'){
            my $ExpectedValue;
            if($aParameterTypes->[$i]->{'int'}){
                $ExpectedValue = {'number' => $aParameterTypes->[$i]->{'int'}};
            }elsif($aParameterTypes->[$i]->{'float'}){
                $ExpectedValue = {'number' => $aParameterTypes->[$i]->{'float'}};
            }else{
                $ExpectedValue = $aParameterTypes->[$i];
            }
            $NewParams[$i] = $ExpectedValue;
        }else{
            if( $aParameterTypes->[$i] ~~ ['int', 'float']){
                $NewParams[$i] = 'number';
            } else{
                $NewParams[$i] = $aParameterTypes->[$i];
            }
        }
    }
    return \@NewParams;
}
1;