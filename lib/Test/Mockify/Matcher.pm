package Test::Mockify::Matcher;
use strict;
use warnings;

use base qw( Exporter );
our @EXPORT_OK = qw (
        SupportedTypes
        String
        Number
    );
#------------------------------------------------------------------------
sub SupportedTypes{
	return [ 
		'string',
		'number',
	];	
}
sub String(;$) {
	my ($Value) = @_;
	_Type('string',$Value);
}
sub Number(;$) {
	my ($Value) = @_;
	_Type('number',$Value);
}
sub _Type($;$){
	my ($Type, $Value) = @_;
	if($Value){
		return {$Type => $Value};
		
	}else{
		return $Type;
	}
}
1;

