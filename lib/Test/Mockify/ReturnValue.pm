=pod

=head1 ReturnValue

Test::Mockify::ReturnValue - To define return values

=head1 DESCRIPTION

Use L<Test::Modify::ReturnValue> to define different types of return values. See method description for more details.

=head1 METHODS

=cut
package Test::Mockify::ReturnValue;
use strict;
use warnings;
=pod

=head2 new

  my $ReturnValue = Test::Mockify::ReturnValue->new();

=head3 Options

The C<new> method creates a new return value object.

=cut
sub new {
    my $class = shift;
    my $self  = bless {
    }, $class;
    return $self;
}
=pod

=head2 thenReturn

  my $ReturnValue = Test::Mockify::ReturnValue->new();
  $ReturnValue->thenReturn('Hello World');
  my $Result = $ReturnValue->call();
  is($Result, 'Hello World');
=head3 Options

The C<thenReturn> method set the return value of C<call>.

=cut
sub thenReturn {
    my $self = shift;
    my ($Value) = @_;
    die('Return value undefined. Use "thenReturnUndef" if you need to return undef.') unless($Value);
    $self->{'Value'} = $Value;
}
=pod

=head2 thenReturnArray

  my $ReturnValue = Test::Mockify::ReturnValue->new();
  $ReturnValue->thenReturnArray([1,23]);
  my @Result = $ReturnValue->call();
  is_deeply(\@Result, [1,23]);
=head3 Options

The C<thenReturnArray> method sets the return value of C<call> in the way that it will return an Array.

=cut
sub thenReturnArray {
    my $self = shift;
    my ($Value) = @_;
    die('NoAnArrayRef') unless(ref($Value) eq 'ARRAY');
    $self->{'ArrayValue'} = $Value;
}
=pod

=head2 thenReturnHash

  my $ReturnValue = Test::Mockify::ReturnValue->new();
  $ReturnValue->thenReturnHash({1 => 23});
  my %Result = $ReturnValue->call();
  is_deeply(\%Result, {1 => 23});
=head3 Options

The C<thenReturnArray> method sets the return value of C<call> in the way that it will return a Hash.

=cut
sub thenReturnHash {
    my $self = shift;
    my ($Value) = @_;
    die('NoAHashRef') unless(ref($Value) eq 'HASH');
    $self->{'HashValue'} = $Value;
}
=pod

=head2 thenReturnUndef

  my $ReturnValue = Test::Mockify::ReturnValue->new();
  $ReturnValue->thenReturnUndef();
  my $Result = $ReturnValue->call();
  is($Result, undef);
=head3 Options

The C<thenReturnArray> method sets the return value of C<call> in the way that it will return undef.

=cut
sub thenReturnUndef {
    my $self = shift;
    $self->{'UndefValue'} = 1;
}
=pod

=head2 thenThrowError

  my $ReturnValue = Test::Mockify::ReturnValue->new();
  $ReturnValue->thenThrowError('ErrorType');
  throws_ok( sub { $ReturnValue->call() }, qr/ErrorType/, );
=head3 Options

The C<thenReturnArray> method sets the return value of C<call> in the way that it will create an error.

=cut
sub thenThrowError {
    my $self = shift;
    my ($ErrorCode) = @_;
    die('NoErrorCode') unless($ErrorCode);
    $self->{'ErrorType'} = $ErrorCode;
    return;
}
=pod

=head2 thenCall

  my $ReturnValue = Test::Mockify::ReturnValue->new();
  $ReturnValue->thenCall(sub{return join('-', @_);});
  my $Result = $ReturnValue->call('hello','world');
  is($Result, 'hello-world');
=head3 Options

The C<thenCall> method change the C<call> Function in a way that it will trigger the function and pass in the parameters.

=cut
sub thenCall{
    my $self = shift;
    my ($FunctionPointer) = @_;
    die('NoAnCodeRef') unless(ref($FunctionPointer) eq 'CODE');
    $self->{'FunctionPointer'} = $FunctionPointer;
    return;
}
=pod

=head2 call

  my $ReturnValue = Test::Mockify::ReturnValue->new();
  $ReturnValue->thenReturn('Hello World');
  my $Result = $ReturnValue->call();
  is($Result, 'Hello World');
=head3 Options

The C<call> method will return the return value which was set with one of the setter methods likeC<thenReturn>.
In case of C<thenCall> it will also forward the parameters.
It will throw an error if one of the setter methods was not called at least once.

=cut
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
__END__

=head1 LICENSE

Copyright (C) 2017 ePages GmbH

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Christian Breitkreutz E<lt>cbreitkreutz@epages.comE<gt>

=cut
