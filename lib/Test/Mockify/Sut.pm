package Test::Mockify::Sut;
use strict;
use warnings;
use parent 'Test::Mockify';
use Test::Mockify::Matcher qw (String);
use Test::Mockify::Tools qw (Error);
use Test::Mockify::TypeTests qw ( IsString IsArrayReference);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}
#----------------------------------------------------------------------------------------
sub mock {
    my $self = shift;
    my ($MethodName) = @_;
    Error('It is not possible to mock a method of your SUT. Don\'t mock the code you like to test.',
        {
            'Method' => $MethodName,
            'Sut' => $self->_mockedModulePath(),
        }
    );
}
#----------------------------------------------------------------------------------------
sub overridePackageContruction {
    my $self = shift;
    my ($Object, $PackageName, $ParameterList) = @_;
    if($PackageName && IsString($PackageName)){
            if($ParameterList && !IsArrayReference($ParameterList)){
                Error('The parameter list must be passed as an arrar reference.');
            }
            $self->mockStatic( $PackageName.'::new' )
                ->whenAny()
                ->thenReturn($Object);
    }else{
        Error('Wrong or missing parameter list. Please call it like: $Mockify->overridePackageContruction($Obejct,\'Path::To::Package\',[])'); ## no critic (CriticPolicy)
    }
}
#----------------------------------------------------------------------------------------
sub getVerificationObject{
    my $self = shift;
    return $self->getMockObject();
}

1;