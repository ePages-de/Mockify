[![Build Status](https://travis-ci.org/ChristianBreitkreutz/Mockify.svg?branch=master)](https://travis-ci.org/ChristianBreitkreutz/Mockify) [![MetaCPAN Release](https://badge.fury.io/pl/Test-Mockify.svg)](https://metacpan.org/release/Test-Mockify)
# NAME

Test::Mockify - minimal mocking framework for perl

# SYNOPSIS

    use Test::Mockify;
    use Test::Mockify::Verify qw ( WasCalled );
    use Test::Mockify::Matcher qw ( String );

    # build a new mocked object
    my $MockObjectBuilder = Test::Mockify->new('SampleLogger', []);
    $MockObjectBuilder->mock('log')->when(String())->thenReturnUndef();
    my $MockedLogger = $MockLoggerBuilder->getMockObject();

    # inject mocked object into the code you want to test
    my $App = SampleApp->new('logger'=> $MockedLogger);
    $App->do_something();

    # verify that the mocked method was called
    ok(WasCalled($MockedLogger, 'log'), 'log was called');
    done_testing();

# DESCRIPTION

Use [Test::Mockify](https://metacpan.org/pod/Test::Mockify) to create and configure mock objects. Use [Test::Mockify::Verify](https://metacpan.org/pod/Test::Mockify::Verify) to
verify the interactions with your mocks. Use [Test::Mockify::Sut](https://metacpan.org/pod/Test::Mockify::Sut) to inject dependencies into your Sut.

You can find a Example Project in [ExampleProject](https://github.com/ChristianBreitkreutz/Mockify/tree/master/t/ExampleProject)

# METHODS

## getMockObject

Provides the actual mock object, which you can use in the test.

    my $aParameterList = ['SomeValueForConstructor'];
    my $MockObjectBuilder = Test::Mockify->new( 'My::Module', $aParameterList );
    my $MyModuleObject = $MockObjectBuilder->getMockObject();

## mock

This is the place where the mocked methods are defined. The method also proves that the method you like to mock actually exists.

### synopsis

This method takes one parameter, which is the name of the method you like to mock.
Because you need to specify more detailed the behaviour of this mock you have to chain the method signature (when) and the expected return value (then...). 

For example, the next line will create a mocked version of the method log, but only if this method is called with any string and the number 123. In this case it will return the String 'Hello World'. Mockify will throw an error if this method is called somehow else.

    my $MockObjectBuilder = Test::Mockify->new( 'Sample::Logger', [] );
    $MockObjectBuilder->mock('log')->when(String(), Number(123))->thenReturn('Hello World');
    my $SampleLogger = $MockObjectBuilder->getMockObject();
    is($SampleLogger->log('abc',123), 'Hello World');

#### when

To define the signature in the needed structure you must use the [Test::Mockify::Matcher](https://metacpan.org/pod/Test::Mockify::Matcher).

#### whenAny

If you don't want to specify the method signature at all, you can use whenAny.
It is not possible to mix `whenAny` and `when` for the same method.

#### then ...

For possible return types please look in [Test::Mockify::ReturnValue](https://metacpan.org/pod/Test::Mockify::ReturnValue)

## mockStatic

Sometimes it is not possible to inject the dependencies from the outside.
`mockStatic` provides the possibility to mock static functions inside the mock.

Attention: The mocked function is valid as long as the $Mockify is defined. If You leave the scope or set the $Mockify to undef the injected method will be released.

    package Show::Magician;
    use Magic::Tools;
    sub pullCylinder {
        shift;
        if(Magic::Tools::Rabbit('black')){
            return 1;
        }else{
            return 0;
        }
    }
    1;

In the Test it can be mocked like:

    package Test_Magician;
    { # start scope
        my $Mockify = Test::Mockify->new( 'Show::Magician', [] );
        $Mockify->mockStatic('Magic::Tools::Rabbit')->when(String('black'))->thenReturn(1);
        $Mockify->spy('log')->when(String());
        my $Magician = $Mockify->getMockObject();

        is($Magician->pullCylinder('black'), 1);
        is(Magic::Tools::Rabbit('black'), 1); 
    } # end scope
    is(Magic::Tools::Rabbit('black'), 'someValue'); # The orignal method in in place again

It can be mixed with normal `spy` and `mock`

#### ACKNOWLEDGEMENTS
Thanks to @dbucky for this amazing idea

## mockImported

Sometimes it is not possible to inject the dependencies from the outside. This is especially the case when the package uses imports of static functions.
`mockImported` provides the possibility to mock imported functions inside the mock.

Unlike `mockStatic` is the injection with `mockImported` only in the mock valid.

    package Show::Magician;
    use Magic::Tools qw ( Rabbit );
    sub pullCylinder {
        shift;
        if(Rabbit('white')){
            return 1;
        }else{
            return 0;
        }
    }
    1;

In the Test it can be mocked

    package Test_Magician;
    use Magic::Tools qw ( Rabbit );
    my $Mockify = Test::Mockify->new( 'Show::Magician', [] );
    $Mockify->mockImported('Magic::Tools','Rabbit')->when(String('white'))->thenReturn(1);

    my $Magician = $Mockify->getMockObject();
    is($Magician ->pullCylinder(), 1);
    Rabbit('white');# return original result
    1;

It can be mixed with normal `spy` and `mock`

## spyImported

`spyImported` provides the possibility to spy imported functions inside the mock.

Unlike `spyStatic` is the injection with `spyImported` only in the mock valid.

    package Show::Magician;
    use Magic::Tools qw ( Rabbit );
    sub pullCylinder {
        shift;
        if(Rabbit('white')){
            return 1;
        }else{
            return 0;
        }
    }
    1;

In the Test it can be mocked

    package Test_Magician;
    use Magic::Tools qw ( Rabbit );
    my $Mockify = Test::Mockify->new( 'Show::Magician', [] );
    $Mockify->spyImported('Magic::Tools','Rabbit')->when(String());

    my $Magician = $Mockify->getMockObject();
    is($Magician->pullCylinder(), 'SomeValue');
    is(GetCallCount($Magician, 'Rabbit'), 1);
    1;

It can be mixed with normal `spy` and `mock`

## spy

Use spy if you want to observe a method. You can use the [Test::Mockify::Verify](https://metacpan.org/pod/Test::Mockify::Verify) to ensure that the method was called with the expected parameters.

### synopsis

This method takes one parameter, which is the name of the method you like to spy.
Because you need to specify more detailed the behaviour of this spy you have to define the method signature with `when`

For example, the next line will create a method spy of the method log, but only if this method is called with any string and the number 123. Mockify will throw an error if this method is called in another way.

    my $MockObjectBuilder = Test::Mockify->new( 'Sample::Logger', [] );
    $MockObjectBuilder->spy('log')->when(String(), Number(123));
    my $SampleLogger = $MockObjectBuilder->getMockObject();

    # call spied method
    $SampleLogger->log('abc', 123);

    # verify that the spied method was called
    is_deeply(GetParametersFromMockifyCall($MockedLogger, 'log'),['abc', 123], 'Check parameters of first call');

#### when

To define the signature in the needed structure you must use the [Test::Mockify::Matcher](https://metacpan.org/pod/Test::Mockify::Matcher).

#### whenAny

If you don't want to specify the method signature at all, you can use whenAny.
It is not possible to mix `whenAny` and `when` for the same method.

## spyStatic

Provides the possibility to spy static functions around the mock.

    package Show::Magician;
    sub pullCylinder {
        shift;
        if(Magic::Tools::Rabbit('black')){
            return 1;
        }else{
            return 0;
        }
    }
    1;

In the Test it can be mocked

    package Test_Magician;
    use Magic::Tools;
    my $Mockify = Test::Mockify->new( 'Show::Magician', [] );
    $Mockify->spyStatic('Magic::Tools::Rabbit')->whenAny();
    my $Magician = $Mockify->getMockObject();

    $Magician->pullCylinder();
    Magic::Tools::Rabbit('black');
    is(GetCallCount($Magician, 'Magic::Tools::Rabbit'), 2); # count as long as $Mockify is valid

    1;

It can be mixed with normal `spy` and `mock`. For more options see, `mockStatic`

# LICENSE

Copyright (C) 2017 ePages GmbH

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Christian Breitkreutz <christianbreitkreutz@gmx.de>

# ACKNOWLEDGEMENTS

Thanks to Dustin Buckenmeyer <dustin.buckenmeyer@gmail.com> and [ECS Tuning](https://www.ecstuning.com/) for giving Dustin the opportunity to pursue this idea and ultimately give it back to the community!
