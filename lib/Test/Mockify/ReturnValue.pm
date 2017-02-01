package Test::Mockify::ReturnValue;
use strict;
use warnings;
#------------------------------------------------------------
sub new {
    my $class = shift;
    my $self  = bless {
    }, $class;
    return $self;
}
#------------------------------------------------------------
sub thenReturn {
    my $self = shift;
    my ($Value) = @_;
    die('Return value undefined. Use "thenReturnUndef" if you need to return undef.') unless($Value);
    $self->{'Value'} = $Value;
}
#------------------------------------------------------------
sub thenReturnArray {
    my $self = shift;
    my ($Value) = @_;
    die('NoAnArrayRef') unless(ref($Value) eq 'ARRAY');
    $self->{'ArrayValue'} = $Value;
}
#------------------------------------------------------------
sub thenReturnHash {
    my $self = shift;
    my ($Value) = @_;
    die('NoAHashRef') unless(ref($Value) eq 'HASH');
    $self->{'HashValue'} = $Value;
}
#------------------------------------------------------------
sub thenReturnUndef {
    my $self = shift;
    $self->{'UndefValue'} = 1;
}
#------------------------------------------------------------
sub thenThrowError {
    my $self = shift;
    my ($ErrorCode) = @_;
    die('NoErrorCode') unless($ErrorCode);
    $self->{'ErrorType'} = $ErrorCode;
    return;
}
#------------------------------------------------------------
sub thenCall{
    my $self = shift;
    my ($FunctionPointer) = @_;
    die('NoAnCodeRef') unless(ref($FunctionPointer) eq 'CODE');
    $self->{'FunctionPointer'} = $FunctionPointer;
    return;
}
#------------------------------------------------------------
sub call {
    my $self = shift;
    my @Params = @_;
    if($self->{'ErrorType'}){
        die($self->{'ErrorType'});
    }elsif($self->{'ArrayValue'}){
        return @{$self->{'ArrayValue'}};
    }elsif($self->{'HashValue'}){
        return %{$self->{'HashValue'}};
    }elsif($self->{'UndefValue'}){
        return;
    }elsif($self->{'FunctionPointer'}){
        return $self->{'FunctionPointer'}->(@Params);
    }elsif($self->{'Value'}){
        return $self->{'Value'};
    }else{
        die('NoReturnValue');
    }
}
1;