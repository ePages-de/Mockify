package Test::Mockify::Injector;
use Test::Mockify::Tools qw ( Error );
use parent 'Test::Mockify';
use Sub::Override;
use strict;
use warnings;
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
#----------------------------------------------------------------------------------------
sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{'override'} = Sub::Override->new();
    $self->{'IsStaticMockStore'} = undef;
    return $self;
}
#----------------------------------------------------------------------------------------
sub mockStatic {
    my $self = shift;
    my @Parameters = @_;

    my $ParameterAmount = scalar @Parameters;
    if($ParameterAmount == 1 && IsString($Parameters[0])){
        if( $Parameters[0] =~ /.*::.*/x ){
            $self->{'IsStaticMockStore'}{$Parameters[0]} = 1;
            return $self->_addMockWithMethod($Parameters[0]);
        }else{
            Error("The function name needs to be with full path. e.g. 'Path::To::Your::$Parameters[0]' instead of only '$Parameters[0]'");
        }
    }else{
        Error('The Parameter needs to be defined and a String. e.g. Path::To::Your::Function');
    }

}
#----------------------------------------------------------------------------------------
sub spyStatic {
    my $self = shift;
    my ($MethodName) = @_;
    if( $MethodName =~ /.*::.*/x ){
        $self->{'IsStaticMockStore'}{$MethodName} = 1;
            my $PointerOriginalMethod = \&{$MethodName};
            #In order to have the current object available in the parameter list, it has to be injected here.
            return $self->_addMockWithMethodSpy($MethodName, sub {
                return $PointerOriginalMethod->($self->_mockedSelf(), @_);
            });
    }else{
        Error("The function name needs to be with full path. e.g. 'Path::To::Your::$MethodName' instead of only '$MethodName'");
    }
}
#----------------------------------------------------------------------------------------
sub _addMockWithMethod {
    my $self = shift;
    my ( $MethodName ) = @_;
    $self->_testMockTypeUsage($MethodName);
    if($self->{'IsStaticMockStore'}{$MethodName}){
        return $self->_addMock($MethodName, Test::Mockify::Method->new());
    }else{
        return $self->SUPER::_addMock($MethodName, Test::Mockify::Method->new());
    }
}
#----------------------------------------------------------------------------------------
sub _addMockWithMethodSpy {
    my $self = shift;
    my ( $MethodName, $PointerOriginalMethod ) = @_;
    $self->_testMockTypeUsage($MethodName);
    if($self->{'IsStaticMockStore'}{$MethodName}){
        return $self->_addMock($MethodName, Test::Mockify::MethodSpy->new($PointerOriginalMethod));
    }else{
        return $self->SUPER::_addMock($MethodName, Test::Mockify::MethodSpy->new($PointerOriginalMethod));
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
        my $MockedMethodBody = sub {
            $self->_mockedSelf()->{'__MethodCallCounter'}->increment( $MethodName );
            my @MockedParameters = @_;
            $self->_storeParameters( $MethodName, $self->_mockedSelf(), \@MockedParameters );
            return $self->{'MethodStore'}{$MethodName}->call(@MockedParameters);
        };
        # mock with full path
        $self->{'override'}->replace($MethodName, $MockedMethodBody);
        my ($FunctionName) = $MethodName =~ /.*::([^:]+$)/x;
        # mock for imported method(it will complain if you did't imported it)
        $self->{'override'}->replace($self->_mockedModulePath().'::'.$FunctionName, $MockedMethodBody);
    }
    return $self->{'MethodStore'}{$MethodName};
}
#----------------------------------------------------------------------------------------
sub getSystemUnderTest {
    my $self = shift;
    return $self->getMockObject(@_);
}
1;