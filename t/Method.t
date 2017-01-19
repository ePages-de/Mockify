package Method;
use Test::Mockify::Matcher qw (String Number);
use strict;

use FindBin;
use lib ($FindBin::Bin);

use parent 'TestBase';
use Test::Exception;
use Test::Mockify::Method;
use Test::More;
#------------------------------------------------------------------------
sub testPlan{
    my $self = shift;
    
    $self->_SignaturWithAnyMatcherAndExpectedMatcher();
    $self->_MultipleAnyMatcher();
    $self->_SingleExepctedMatcher();
    $self->_MixedExepctedMatcherAndAnyMatcher_Error();
    $self->_MixedAnyMatcherWithDifferntTypes();
    $self->_DefineSignatureTwice_Error();
    $self->_UndefinedSignatur_Error();
    $self->_UndefinedType_Error();
    return;
}
#---------------------------------------------------------------------------------
sub _SignaturWithAnyMatcherAndExpectedMatcher {
    my $self = shift;
    my $Method = Test::Mockify::Method->new();
    $Method->when(String('hello'), String() )->thenReturn('World');    
    is($Method->call('hello','abcd'), 'World', 'first expected, second any');
    is($Method->call('hello','world'), 'World', 'first expected, second any');

    $Method = Test::Mockify::Method->new();
    $Method->when(String(), String('World') )->thenReturn('Hello');    
    is($Method->call('jaja','World'), 'Hello', 'first any, second expected');
    is($Method->call('something','World'), 'Hello', 'first expected, second any');
}
#---------------------------------------------------------------------------------
sub _MultipleAnyMatcher {
    my $self = shift;
    my $Method = Test::Mockify::Method->new();
    $Method->when( String(), Number() )->thenReturn('Hello World');    
    is($Method->call('abc',123), 'Hello World', 'mixed parameters');
}
#---------------------------------------------------------------------------------
sub _SingleExepctedMatcher {
    my $self = shift;
    my $Method = Test::Mockify::Method->new();
    $Method->when(String('OneString'))->thenReturn('Result for one string.');
    $Method->when(Number(123))->thenReturn('Result for one number.');

    is($Method->call('OneString'), 'Result for one string.', 'single expected parameter type string');	
    is($Method->call(123), 'Result for one number.', 'single expected parameter type number');	
}
#---------------------------------------------------------------------------------
sub _SingleAnyParameter {
    my $self = shift;
    my $Method = Test::Mockify::Method->new();
    $Method->when(String())->thenReturn('Result for one string.');
    $Method->when(Number())->thenReturn('Result for one number.');

    is($Method->call('OneString'), 'Result for one string.', 'single any parameter type string');	
    is($Method->call(123), 'Result for one number.', 'single any parameter type number');	
}
#---------------------------------------------------------------------------------
sub _MixedExepctedMatcherAndAnyMatcher_Error {
    my $self = shift;    
    
    my $Method = Test::Mockify::Method->new();
    $Method->when(String('OneString'))->thenReturn('Result for one string.');
    throws_ok( sub { $Method->when( String() )->thenReturn('Hello World'); },
               qr/It is not possibel to mix "any parameter" with previously set "expected parameter"./,
               'error if use of any and expected matcher in first parameter'
     );

    $Method = Test::Mockify::Method->new();
    $Method->when(String())->thenReturn('Result for two strings.');
    throws_ok( sub { $Method->when( String('OneString') )->thenReturn('Hello World'); },
               qr/It is not possibel to mix "expected parameter" with previously set "any parameter"./,
               'error if use of any and expected matcher - single parameter'
     );
} 
#---------------------------------------------------------------------------------
sub _MixedAnyMatcherWithDifferntTypes {
    my $self = shift;    
    
    my $Method = Test::Mockify::Method->new();
    $Method->when( String() )->thenReturn('ResultString');
    $Method->when( Number(123) )->thenReturn('ResultNumber');
    
    is($Method->call(123), 'ResultNumber', 'correct result for expected matcher number -> 123');
    is($Method->call("lalal"), 'ResultString', 'correct result for any matcher sting');

} 
#---------------------------------------------------------------------------------
#---------------------------------------------------------------------------------
sub _DefineSignatureTwice_Error{
    my $self = shift;
    
    my $Method = Test::Mockify::Method->new();
    $Method->when(String('FirstString'))->thenReturn('Result for two strings.');
    throws_ok( sub { $Method->when( String('FirstString') )->thenReturn('Hello World'); },
               qr/It is not possible two add two times the same method signatur./,
               'define signatur twice - expected matcher'
     );
    $Method = Test::Mockify::Method->new();
    $Method->when(String())->thenReturn('Result for two strings.');
    throws_ok( sub { $Method->when( String() )->thenReturn('Hello World'); },
               qr/It is not possible two add two times the same method signatur./,
               'define signatur twice - any matcher'
     );
}
#---------------------------------------------------------------------------------
sub _UndefinedSignatur_Error {
    my $self = shift;
    my $Method = Test::Mockify::Method->new();
    $Method->when(String())->thenReturn('Hello World');
    throws_ok( sub { $Method->call('not','mocked Signatur') },
    	qr/No matching found for stringstring/,
               'unsupported amount of parameters'
     );
}
#---------------------------------------------------------------------------------
sub _UndefinedType_Error {
    my $self = shift;
    my $Method = Test::Mockify::Method->new();
    throws_ok( sub { $Method->when('NotSuportedType')->thenReturn('Result for two strings.'); },
               qr/Found unsupportd type 'NotSuportedType'. Use Test::Mockify:Matcher to define nice parameter types./,
               'unsuported type, not like string or number'
     );
}

__PACKAGE__->RunTest();
1;