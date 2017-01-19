package Test::Mockify::Method;
use Test::Mockify::Parameter;
use Data::Dumper;
use Test::Mockify::TypeTests qw (
        IsInteger
        IsFloat
        IsString
        IsArrayReference
        IsHashReference
        IsObjectReference
);
use Test::Mockify::Matcher qw (SupportedTypes);
use Scalar::Util qw( blessed );
use strict;
use warnings;

#---------------------------------------------------------------------
sub new {
    my $class = shift;
    my ($name) = @_;
    my $self  = bless {
    	'name' => $name,
    	'TypeStore'=> undef,
    	'MatcherStore'=> undef,
    }, $class;
    foreach my $Type (SupportedTypes()){
    	$self->{'MatcherStore'}{$Type} = [];
    }
    return $self;
}
#---------------------------------------------------------------------
sub when {
	my $self = shift;
	my @Parameters = @_;
	my @Signature;
	my @ParameterValues ;
	foreach my $hParameter ( @Parameters ){
		 if( ref($hParameter) eq 'HASH') {
			push(@Signature, $self->_getParameterKey($hParameter));
			push(@ParameterValues, $self->_getParameterValue($hParameter));
		 }elsif(IsString($hParameter) && $hParameter ~~ SupportedTypes()){
			push(@Signature, $hParameter);
			push(@ParameterValues, 'NoExpectedParameter');
		 }else{
		 	die("Found unsupportd type 'NotSuportedType'. Use Test::Mockify:Matcher to define nice parameter types.");
		 }
	}
	$self->_checkExpectedParameters(\@Signature, \@ParameterValues);
	return $self->_addToTypeStore(\@Signature, \@ParameterValues);
}
#---------------------------------------------------------------------
sub _getParameterKey {
	my $self = shift;
	my ($hParameter) = @_;
	my @Keys =  keys %{$hParameter};
	return $Keys[0];
}
#---------------------------------------------------------------------
sub _getParameterValue {
	my $self = shift;
	my ($hParameter) = @_;
	my @Values = values %{$hParameter};
	return $Values[0];
}

#---------------------------------------------------------------------
sub _checkExpectedParameters{
	my $self = shift;
	my ($Signatur, $NewExpectedParameters) = @_;
	
	for(my $i = 0; $i < scalar @$NewExpectedParameters; $i++){
		my $Type = $Signatur->[$i];
		if($NewExpectedParameters->[$i] eq 'NoExpectedParameter'){
			if($self->{'MatcherStore'}{$Type}->[$i] && $self->{'MatcherStore'}{$Type}->[$i] ne 'NoExpectedParameter'){
				die('It is not possibel to mix "any parameter" with previously set "expected parameter".');					
			}
		} else {
			if($self->{'MatcherStore'}{$Type}->[$i] and $self->{'MatcherStore'}{$Type}->[$i] eq 'NoExpectedParameter'){
				die('It is not possibel to mix "expected parameter" with previously set "any parameter".');					
			}
		}
		$self->{'MatcherStore'}{$Type}->[$i] = $NewExpectedParameters->[$i];
	}
	my $SignaturKey = join('',@$Signatur);
	foreach my $ExistingParameter (@{$self->{'TypeStore'}{$SignaturKey}}){
		if($ExistingParameter->compareExpectedParameters($NewExpectedParameters)){
			die('It is not possible two add two times the same method signatur.');
		}
	}
}
#---------------------------------------------------------------------
sub _addToTypeStore {
	my $self = shift;
	my ($Signatur, $NewExpectedParameters) = @_;
	my $SignaturKey = join('',@$Signatur);
	my $Parameter = Test::Mockify::Parameter->new($NewExpectedParameters);
	push(@{$self->{'TypeStore'}{$SignaturKey}}, $Parameter );	
	return $Parameter->buildReturn();
}
#---------------------------------------------------------------------
sub call {
	my $self = shift;
	my @Params = @_;
	my $SignaturKey;
	foreach my $Param (@Params){
		$SignaturKey .= $self->_getType($Param);
	}
	foreach my $ExistingParameter (@{$self->{'TypeStore'}{$SignaturKey}}){
		if($ExistingParameter->matchWithExpectedParameters(@Params)){
			return $ExistingParameter->call();
		}
	}
#	use Error;
	die ("No matching found for $SignaturKey -> ".Dumper(\@Params));
}
#---------------------------------------------------------------------
sub _getType{
    my $self = shift;
    my ($Parameter) = @_;
    return 'arrayref' if(IsArrayReference($Parameter));
    return 'hashref' if(IsHashReference($Parameter));
    return 'object' if(IsObjectReference($Parameter));
    return 'number' if(IsFloat($Parameter));
    return 'string' if(IsString($Parameter));
    die("UnexpectedParameterType for: '$Parameter'");
}

1;