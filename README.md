# Documentaion #

Here in a nutshell the options:

## getMockObject ##
gives you the actual mocked object which you can use in the test.
```
my $aParameterList = ['SomeValueForConstructor'];
my $MockifyObject = Mockify->new( 'My::Module', $aParameterList );
my $MyModuleObject = $MockifyObject->getMockObject();
```
## addMock ##

This is the simplest case. It is like the mock-method from Test::MockObject.

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

In the following example, two strings will be expected and the second one has to have the value "abcd".
```
my $aParameterTypes = ['string',{'string' => 'abcd'}];
$MockObject->addMockWithReturnValueAndParameterCheck('myMethodName','the return value',$aParameterTypes);
```
### Options ###
pure Types
```
['string', 'int', 'float', 'hashref', 'arrayref', 'object', 'undef', 'any']
```
or Types with expected values
```
[{'string'=>'abcdef'}, {'int' => 123}, {'float' => 1.23}, {'hashref' => {'key'=>'value'}}, {'arrayref'=>['one', 'two']}, {'object'=> 'PAth::to:Obejct}]
```
If you use **any** you must prove this value explicitly in the test, see **GetParametersFromMockifyCall**

## addMethodSpy ##
With this method it is possible to observe a method. So you keep the original functionality but, you can get meta data from the mockify- framework.
```
$MockObject->addMethodSpy('myMethodName');
```

##addMethodSpyWithParameterCheck ##
With this method it is possible to observer a method and check the parameters. So you keep the original functionality but, you can get meta data from the mockify- framework and use the ParameterCheck, like "addMockWithReturnValueAndParameterCheck"
```
my $aParameterTypes = ['string',{'string' => 'abcd'}];
$MockObject->addMethodSpyWithParameterCheck('myMethodName','the return value',$aParameterTypes);
```

### Options ###
pure Types
```
['string', 'int', 'hashref', 'arrayref', 'object', 'undef', 'any']
```
or Types with expected values
```
[{'string'=>'abcdef'}, {'int' => 123}, {'hashref' => {'key'=>'value'}}, {'arrayref'=>['one', 'two']}, {'object'=> 'PAth::to:Obejct}]
```
If you use *any* you *must* prove this value explicitly in the test, see **GetParametersFromMockifyCall**

## mock ##
This is a shortcut for *addMock*, *addMockWithReturnValue* and *addMockWithReturnValueAndParameterCheck*. *mock* detects with the Parameters the needed Method.

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
With this Function it is possible to get all the Parameters after the Mockified-modul was used. If the test calls the method multiple times, the "$OptionalPosition" can be used to get the specific call, default is "0".
Returns an array ref with the parameters of the specific method call.
*(Note: the calls are counted starting from zero. You will get the parameters from the first call with 0, the ones from the second call with 1, and so on)*

### GetCallCount ###
```
my $AmountOfCalls = GetCallCount($MockifiedObject, 'nameOfMethod');
```
With this Function it is possible to get the amount of calls after the Mockified-modul was used. *If the method was not called it will return "0"*

### WasCalled ###
```
my $WasCalled = WasCalled($MockifiedObject, 'nameOfMethod');

```
With this Function it is possible to get the information if the method was called when the Mockified-modul was used.

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