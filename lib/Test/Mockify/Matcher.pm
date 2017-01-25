package Test::Mockify::Matcher;
use strict;
use warnings;
use Test::Mockify::TypeTests qw (
        IsFloat
        IsString
        IsArrayReference
        IsHashReference
        IsObjectReference
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
#------------------------------------------------------------------------
sub SupportedTypes{
    return [ 
        'string',
        'number',
        'hashref',
        'arrayref',
        'object',
        'undef',
        'sub',
        'any',
    ];
}
#------------------------------------------------------------------------
sub String(;$) {
    my ($Value) = @_;
    die('NotAString') if $Value && !IsString($Value);
    return _Type('string',$Value);
}
#------------------------------------------------------------------------
sub Number(;$) {
    my ($Value) = @_;
    die('NotANumber') if $Value && !IsFloat($Value);
    return _Type('number',$Value);
}
#------------------------------------------------------------------------
sub HashRef(;$) {
    my ($Value) = @_;
    die('NotAHashReference') if $Value && !IsHashReference($Value);
    return _Type('hashref',$Value);
}
#------------------------------------------------------------------------
sub ArrayRef(;$) {
    my ($Value) = @_;
    die('NotAnArrayReference') if $Value && !IsArrayReference($Value);
    return _Type('arrayref',$Value);
}
#------------------------------------------------------------------------
sub Object(;$) {
    my ($Value) = @_;
    die('NotAnModulPath') if $Value && !($Value =~ /^\w+(::\w+)*$/);
    return _Type('object',$Value);
}
#------------------------------------------------------------------------
sub Function(;$) {
    my ($Value) = @_;
    die('NotAFunctionReference') if $Value && !IsCodeReference($Value);
    return _Type('sub',$Value);
}
#------------------------------------------------------------------------
sub Undef() {
    return _Type('undef', undef);
}
#------------------------------------------------------------------------
sub Any() {
    return _Type('any', undef);
}
#------------------------------------------------------------------------
sub _Type($;$){
    my ($Type, $Value) = @_;
    if($Value){
        return {$Type => $Value};
    }else{
        return $Type;
    }
}
1;

