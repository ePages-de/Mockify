# Documentaion #

Here in a nutshell the options:

## getMockObject ##
gives you the actual mocked object which you can use in the test
```
my $aParameterList = ['SomeValueForConstuctor'];
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
This method is an extension of *addMockWithReturnValue+. Here you also can check the parameters which will be passed

You can check if they have a specific **datatype** or even check if they have a given **value**.

In the following example, two strings will be expected and the second one has to have the value "abcd".
```
my $aParameterTypes = ['string',{'string' => 'abcd'}];
$MockObject->addMockWithReturnValueAndParameterCheck('myMethodName','the return value',$aParameterTypes);
```
### Options ###
pure Types
```
['string', 'int', 'hashref', 'arrayref', 'object', 'undef']
```
or Types with expected values
```
[{'string'=>'abcdef'}, {'int' => 123}, {'hashref' => {'key'=>'value'}}, {'arrayref'=>['one', 'two']}, {'object'=> 'PAth::to:Obejct}]
```
## mock ##
This is a shortcut for *addMock*, *addMockWithReturnValue* and *addMockWithReturnValueAndParameterCheck*. *mock* detects with the Parameters the needed Method.

| Parameter in *mock*  | actually used method |
| ------------- | ------------- |
| mock('MethodName', sub{})  | *addMock*  |
| mock('MethodName', 'someValue')  | *addMockWithReturnValue*  |
| mock('MethodName', 'someValue', ['string',{'string' => 'abcd'}])  | *addMockWithReturnValueAndParameterCheck*  |
## GetParametersFromMockifyCall ##

# Documentaion #

Here in a nutshell the options:

## getMockObject ##
gives you the actual mocked object which you can use in the test
```
my $aParameterList = ['SomeValueForConstuctor'];
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
This method is an extension of *addMockWithReturnValue+. Here you also can check the parameters which will be passed

You can check if they have a specific **datatype** or even check if they have a given **value**.

In the following example, two strings will be expected and the second one has to have the value "abcd".
```
my $aParameterTypes = ['string',{'string' => 'abcd'}];
$MockObject->addMockWithReturnValueAndParameterCheck('myMethodName','the return value',$aParameterTypes);
```
### Options ###
pure Types
```
['string', 'int', 'hashref', 'arrayref', 'object', 'undef']
```
or Types with expected values
```
[{'string'=>'abcdef'}, {'int' => 123}, {'hashref' => {'key'=>'value'}}, {'arrayref'=>['one', 'two']}, {'object'=> 'PAth::to:Obejct}]
```
## mock ##
This is a shortcut for *addMock*, *addMockWithReturnValue* and *addMockWithReturnValueAndParameterCheck*. *mock* detects with the Parameters the needed Method.

| Parameter in *mock*  | actually used method |
| ------------- | ------------- |
| mock('MethodName', sub{})  | *addMock*  |
| mock('MethodName', 'someValue')  | *addMockWithReturnValue*  |
| mock('MethodName', 'someValue', ['string',{'string' => 'abcd'}])  | *addMockWithReturnValueAndParameterCheck*  |
## GetParametersFromMockifyCall ##

