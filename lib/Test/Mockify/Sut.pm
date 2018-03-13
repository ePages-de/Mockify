package Test::Mockify::Sut;
use strict;
use warnings;
use parent 'Test::Mockify';
use Test::Mockify::Matcher qw (String);
use Test::Mockify::Tools qw (Error);
use Test::Mockify::TypeTests qw ( IsString );

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
sub overrideConstructor {
    my $self = shift;
    my ($PackageName, $Object, $ConstructorName) = @_;
    $ConstructorName //= 'new';
    if($PackageName && IsString($PackageName)){
            $self->mockStatic( sprintf('%s::%s', $PackageName, $ConstructorName) )
                ->whenAny()
                ->thenReturn($Object);
    }else{
        Error('Wrong or missing parameter list. Please use it like: $Mockify->overridePackageConstruction(\'Path::To::Package\', $Object)'); ## no critic (RequireInterpolationOfMetachars)
    }
}
#----------------------------------------------------------------------------------------
sub getVerificationObject{
    my $self = shift;
    return $self->getMockObject();
}

1;