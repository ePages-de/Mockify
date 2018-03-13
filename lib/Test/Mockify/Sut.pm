=pod

=head1 NAME

Test::Mockify::Sut - injection options for your System under test (Sut) based on Mockify

=head1 SYNOPSIS

  use Test::Mockify::Sut;
  use Test::Mockify::Verify qw ( WasCalled );
  use Test::Mockify::Matcher qw ( String );

  # build a new system under text
  my $MockifySut = Test::Mockify::Sut->new('Package::I::Like::To::Test', []);
  $MockifySut->mockImported('Package::Name', 'ImportedFunctionName')->when(String())->thenReturn('Hello');
  $MockifySut->mockStatic('Fully::Qualified::FunctionName')->when(String())->thenReturn('Hello');
  $MockifySut->overrideConstructor('Package::Name', $Object);#  hint: build this object also with Mockify
  my $PackageILikeToTest = $MockifySut->getMockObject();

  $PackageILikeToTest->do_something();# all injections are used here

  # verify that the mocked method were called
  ok(WasCalled($PackageILikeToTest, 'ImportedFunctionName'), 'ImportedFunctionName was called');
  done_testing();

=head1 DESCRIPTION

Use L<Test::Mockify::Sut|Test::Mockify::Sut> to create and configure Sut objects. Use L<Test::Mockify::Verify|Test::Mockify::Verify> to
verify the interactions with your mocks.

You can find a Example Project in L<ExampleProject|https://github.com/ChristianBreitkreutz/Mockify/tree/master/t/ExampleProject>

=head1 METHODS

=cut

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
#=pod

=head2 mock

To mock methods or functions of your Sut is a really bad idea. Therefore this method throws a Error when used.


=cut
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
=pod

=head2 overrideConstructor

Sometimes it is not possible to inject the dependencies from the outside. This method gives you the posibility to override the constructor of a package where your Sut depends on.


Attention: The mocked constructor is valid as long as the Mockify object is defined. If You leave the scope or set the Mockify object to undef the injected constructor will be released.

  package Path::To::SUT;
  use Path::To::Package;
  sub callToAction {
      shift;
      return Path::To::Package->new()->doAction();
  }
  1;

In the Test it can be mocked like:

  package Test_SUT;
  { # start scope
      my $MockifySut = Test::Mockify::Sut->new( 'Path::To::SUT', [] );
      $MockifySut->overrideConstructor('Path::To::Package', $self->_createPathToPackage());
      my $Test_SUT = $MockifySut->getMockObject();

      is($Test_SUT->callToAction(), 'hello');
  } # end scope

  sub _createPathToPackage{
      my $self = shift;
      my $Mockify = Test::Mockify->new( 'Path::To::Package', [] );
      $Mockify->mock('doAction')->when()->thenReturn('hello');
      return $Mockify->getMockObject();
  }

It can be mixed with normal C<spy> and C<mock>

=cut
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
=pod

=head2 getVerificationObject

Provides the actual mock object, which you can use for verification.

  my $Mockify = Test::Mockify::Sut->new( 'My::Module', [] );
  my $VerificationObject = $Mockify->getVerificationObject();
  ok(WasCalled($VerificationObject, 'FunctionName'));
=cut
sub getVerificationObject{
    my $self = shift;
    return $self->getMockObject();
}

1;