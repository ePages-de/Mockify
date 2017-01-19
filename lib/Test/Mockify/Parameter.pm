package Test::Mockify::Parameter;
use Test::Mockify::ReturnValue;
use Data::Compare;
use Test::Mockify::TypeTests qw ( IsString );
use strict;
use warnings;
#---------------------------------------------------------------------
sub new {
    my $class = shift;
    my ($aExpectedParams) = @_;
    my $self  = bless {
    	'ExpectedParams' => $aExpectedParams,
    }, $class;
    return $self;
}
#---------------------------------------------------------------------
sub call {
	my $self = shift;
	return $self->{'ReturnValue'}->call();
}
#---------------------------------------------------------------------
sub buildReturn {
	my $self = shift;
	$self->{'ReturnValue'} = Test::Mockify::ReturnValue->new();
	return $self->{'ReturnValue'};	
}
#---------------------------------------------------------------------
sub compareExpectedParameters {
	my $self = shift;
	my ($Parameters) = @_;
	return unless (scalar @{$Parameters} == scalar @{$self->{'ExpectedParams'}});
	return Data::Compare->new()->Cmp($Parameters, $self->{'ExpectedParams'});
}
#---------------------------------------------------------------------
sub matchWithExpectedParameters {
	my $self = shift;
	my @Params = @_;
	return unless (scalar @Params == scalar @{$self->{'ExpectedParams'}});
	for(my $i=0; $i < scalar @Params; $i++){		
		if(IsString($self->{'ExpectedParams'}->[$i]) && $self->{'ExpectedParams'}->[$i] eq 'NoExpectedParameter'){
		    next;			
		}elsif(ref($Params[$i]) eq $self->{'ExpectedParams'}->[$i]){# map classname
			next;
		}elsif(Data::Compare->new()->Cmp($Params[$i], $self->{'ExpectedParams'}->[$i])){
		    next;
		} else{
			return 0;
		}
	}
	return 1;
}

1;