package Test::Mockify::Injector;
use Test::Mockify::Tools qw ( Error );
use parent 'Test::Mockify';
use Sub::Override;
use strict;
use warnings;
use Test::Mockify::Tools qw ( ExistsMethod );
use Test::Mockify::Tools qw ( Error ExistsMethod IsValid LoadPackage Isa );
use Test::Mockify::TypeTests qw ( IsInteger IsFloat IsString IsArrayReference IsHashReference IsObjectReference );
use Test::Mockify::MethodCallCounter;
use Test::Mockify::Method;
use Test::Mockify::MethodSpy;
use Test::MockObject::Extends;
use Test::Mockify::CompatibilityTools qw (MigrateOldMatchers);
use Data::Dumper;
use Scalar::Util qw( blessed );
use Data::Compare;
sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{'override'} = Sub::Override->new();
    return $self;
}
#----------------------------------------------------------------------------------------
sub staticFunctionOverride {
    my $self = shift;
    my @Parameters = @_;

    my $ParameterAmount = scalar @Parameters;
    if($ParameterAmount == 1 && IsString($Parameters[0]) ){
        return $self->_addMockWithMethod($Parameters[0]);
    }else{
        Error('no no no');
    }
}
#-------------------------------------------------------------------------------------
sub _addMock {
    my $self = shift;
    my ( $MethodName, $Method) = @_;

    ExistsMethod( $self->_mockedModulePath(), $MethodName );
    $self->_mockedSelf()->{'__MethodCallCounter'}->addMethod( $MethodName );
    if(not $self->{'MethodStore'}{$MethodName}){
        $self->{'MethodStore'}{$MethodName} //= $Method;
        $self->{'override'}->replace($MethodName, sub {
            $self->_mockedSelf()->{'__MethodCallCounter'}->increment( $MethodName );
            my @MockedParameters = @_;
            $self->_storeParameters( $MethodName, $self->_mockedSelf(), \@MockedParameters );
            return $self->{'MethodStore'}{$MethodName}->call(@MockedParameters);
        });
    }
    return $self->{'MethodStore'}{$MethodName};
}
sub getSystemUnderTest {
    my $self = shift;
    my ($Arguments) = @_;
    return $self->getMockObject();
}
1;