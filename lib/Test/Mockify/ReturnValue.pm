package Test::Mockify::ReturnValue;
sub new {
    my $class = shift;
    my $self  = bless {
    }, $class;
    return $self;
}
sub thenReturn {
    my $self = shift;
    my ($Value) = @_;
    $self->{'value'} = $Value;
}
sub thenReturnUndef {
    my $self = shift;
    $self->{'value'} = undef;
}
sub thenThrowError {
    my $self = shift;
    my ($ErrorType) = @_;
    $self->{'ErrorType'} = $ErrorType;
    return;
}
sub call {
    my $self = shift;
    if($self->{'ErrorType'}){
        die($self->{'ErrorType'});
    }else{
        return $self->{'value'};
    }
}
1;