# Documentaion #

Here the options in a nutshell:

## getMockObject ##
gives you the actual mocked object which you can use in the test.
```
my $aParameterList = ['SomeValueForConstructor'];
my $MockifyObject = Mockify->new( 'My::Module', $aParameterList );
my $MyModuleObject = $MockifyObject->getMockObject();
```
## addMock ##

This is the simplest case. It works like the mock-method from Test::MockObject.

Only handover the **name** and a **method pointer**. Mockify will automatically check if the method exists in the original object.
```
$MockObject->addMock('myMethodName', sub {
                                    # Your implementation
                                 }
 );
```
## addMockWithReturnValue ##
Does the same as *addMock*, but here you can handover a **value** which will be returned if you call the mocked method.
```
$MockObject->addMockWithReturnValue('myMethodName','the return value');
```
## addMockWithReturnValueAndParameterCheck ##
This method is an extension of *addMockWithReturnValue*. Here you also can check the parameters which will be passed.

You can check if they have a specific **datatype** or even check if they have a given **value**.

In the following example two strings will be expected, and the second one has to have the value "abcd".
```
my $aParameterTypes = ['string',{'string' => 'abcd'}];
$MockObject->addMockWithReturnValueAndParameterCheck('myMethodName','the return value',$aParameterTypes);
```
### Options ###
pure types
```
['string', 'int', 'float', 'hashref', 'arrayref', 'object', 'undef', 'any']
```
or types with expected values
```
[{'string'=>'abcdef'}, {'int' => 123}, {'float' => 1.23}, {'hashref' => {'key'=>'value'}}, {'arrayref'=>['one', 'two']}, {'object'=> 'PAth::to:Obejct}]
```
If you use **any** you must verify this value explicitly in the test, see **GetParametersFromMockifyCall**

## addMethodSpy ##
With this method it is possible to observe a method. So you keep the original functionality, but you can get meta data from the mockify- framework.
```
$MockObject->addMethodSpy('myMethodName');
```

##addMethodSpyWithParameterCheck ##
With this method it is possible to observe a method and check the parameters. So you keep the original functionality, but you can get meta data from the mockify- framework and use the ParameterCheck, like "addMockWithReturnValueAndParameterCheck"
```
my $aParameterTypes = ['string',{'string' => 'abcd'}];
$MockObject->addMethodSpyWithParameterCheck('myMethodName','the return value',$aParameterTypes);
```

### Options ###
pure types
```
['string', 'int', 'hashref', 'arrayref', 'object', 'undef', 'any']
```
or types with expected values
```
[{'string'=>'abcdef'}, {'int' => 123}, {'hashref' => {'key'=>'value'}}, {'arrayref'=>['one', 'two']}, {'object'=> 'PAth::to:Obejct}]
```
If you use *any* you *must* verify this value explicitly in the test, see **GetParametersFromMockifyCall**

## mock ##
This is a shortcut for *addMock*, *addMockWithReturnValue* and *addMockWithReturnValueAndParameterCheck*. *mock* detects the needed method with given parameters.

| Parameter in *mock*  | actually used method |
| ------------- | ------------- |
| mock('MethodName', sub{})  | *addMock*  |
| mock('MethodName', 'someValue')  | *addMockWithReturnValue*  |
| mock('MethodName', 'someValue', ['string',{'string' => 'abcd'}])  | *addMockWithReturnValueAndParameterCheck*  |

## Additional meta data functions ##
or, get meta data from calls

### GetParametersFromMockifyCall ###
```
my $aParameters = GetParametersFromMockifyCall($MockifiedObject, 'nameOfMethod', $OptionalPosition);
```
This function returns all the parameters after the *mockified* module was used. If the test calls the method multiple times, the "$OptionalPosition" can be used to get the specific call, default is "0".
Returns an array ref with the parameters of the specific method call.
*(Note: The calls are counted starting from zero. You will get the parameters from the first call with 0, the ones from the second call with 1, and so on)*

### GetCallCount ###
```
my $AmountOfCalls = GetCallCount($MockifiedObject, 'nameOfMethod');
```
This function returns the information how often the method was called on the *mockified* module. *If the method was not called it will return "0"*

### WasCalled ###
```
my $WasCalled = WasCalled($MockifiedObject, 'nameOfMethod');

```
This function returns the information if the method was called on the *mockified* module.

## addtional needed cpan modules ##
```
cpan Module::Load
```
```
cpan Test::MockObject::Extends
```
```
cpan Data::Compare
```
