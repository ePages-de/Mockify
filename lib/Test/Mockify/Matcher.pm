=pod

=head1 Matcher

Test::Mockify::Matcher - To define parameter matchers

=head1 DESCRIPTION

Use L<Test::Mockify::Matcher> to define different types of expected parameters. See method description for more details.

=head1 METHODS

=cut
package Test::Mockify::Matcher;
use strict;
use warnings;
use Test::Mockify::TypeTests qw (
        IsFloat
        IsString
        IsArrayReference
        IsHashReference
        IsCodeReference
    );
use base qw( Exporter );
our @EXPORT_OK = qw (
        SupportedTypes
        String
        Number
        HashRef
        ArrayRef
        Object
        Function
        Undef
        Any
    );
=pod

=head2 SupportedTypes

  SupportedTypes();

=head3 Options

The C<SupportedTypes> will return all supported matcher types as an array ref.

=cut
sub SupportedTypes{
    return [ 
        'string',
        'number',
        'hashref',
        'arrayref',
        'object',
        'sub',
        'undef',
        'any',
    ];
}
=pod

=head2 String

  String();
  String('abc');

=head3 Options

The C<String> method will create the matcher in the needed structure to match a string.
If called with parameter, it will be proved that this value is actually a string. If not, it will create an error.

=cut
sub String(;$) {
    my ($Value) = @_;
    die('NotAString') if $Value && !IsString($Value);
    return _Type('string',$Value);
}
=pod

=head2 Number

  Number();
  Number(123);

=head3 Options

The C<Number> method will create the matcher in the needed structure to match a number.
If called with parameter, it will be proved that this value is actually a number. If not, it will create an error.

=cut
sub Number(;$) {
    my ($Value) = @_;
    die('NotANumber') if $Value && !IsFloat($Value);
    return _Type('number',$Value);
}
=pod

=head2 HashRef

  HashRef();
  HashRef({1 => 23});

=head3 Options

The C<HashRef> method will create the matcher in the needed structure  to match a hash reference.
If called with parameter, it will be proved that this value is actually a hash reference. If not, it will create an error.

=cut
sub HashRef(;$) {
    my ($Value) = @_;
    die('NotAHashReference') if $Value && !IsHashReference($Value);
    return _Type('hashref',$Value);
}
=pod

=head2 ArrayRef

  ArrayRef();
  ArrayRef([1,23]);

=head3 Options

The C<ArrayRef> method will create the matcher in the needed structure to match an array reference.
If called with parameter, it will be proved that this value is actually an array reference. If not, it will create an error.

=cut
sub ArrayRef(;$) {
    my ($Value) = @_;
    die('NotAnArrayReference') if $Value && !IsArrayReference($Value);
    return _Type('arrayref',$Value);
}
=pod

=head2 Object

  Object();
  Object('Path::To::Object');

=head3 Options

The C<Object> method will create the matcher in the needed structure to match an object.
If called with parameter, it will be proved that this value is actually an string of the object path. If not, it will create an error.

=cut
sub Object(;$) {
    my ($Value) = @_;
    die('NotAnModulPath') if $Value && !($Value =~ /^\w+(::\w+)*$/);
    return _Type('object',$Value);
}
=pod

=head2 Function

  Function();

=head3 Options

The C<Function> method will create the matcher in the needed structure to match a function pointer.

=cut
sub Function(;$) {
    return _Type('sub',undef);
}
=pod

=head2 Undef

  Undef();

=head3 Options

The C<Undef> method will create the matcher in the needed structure to match an undefined value.

=cut
sub Undef() {
    return _Type('undef', undef);
}
#####=pod

=head2 Any

  Any();

=head3 Options

The C<Any> method will create the matcher in the needed structure to match any type of parameter.

=cut
sub Any() {
    return _Type('any', undef);
}

sub _Type($;$){
    my ($Type, $Value) = @_;
    if($Value){
        return {$Type => $Value};
    }else{
        return {$Type => 'NoExpectedParameter'};
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

