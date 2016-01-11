#========================================================================================
# §package      DE_EPAGES::Test::Mock::Mockify::MethodCallCounter
# §state        public
#----------------------------------------------------------------------------------------
# §description  encapsulate the Call Counter for Mockify
#========================================================================================
package DE_EPAGES::Test::Mock::Mockify::MethodCallCounter;

use DE_EPAGES::Core::API::Error qw ( Error );

use strict;
#========================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       new( );
#----------------------------------------------------------------------------------------
# §description  constructor
#----------------------------------------------------------------------------------------
# §return       $self | self | DE_EPAGES::Test::Mock::MethodCallCounter
#========================================================================================
sub new {
    my $class = shift;
    my $self  = bless {}, $class;
    return $self;
}
#========================================================================================
# §function     addMethod
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       addMethod( $MethodName );
#----------------------------------------------------------------------------------------
# §description  add the Method '$MethodName' to the counter
#----------------------------------------------------------------------------------------
# §input        $MethodName | name of method | string
#========================================================================================
sub addMethod {
    my $self = shift;
    my ( $MethodName ) = @_;

    $self->{$MethodName} = 0;

    return;
}
#========================================================================================
# §function     increment
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       increment( $MethodName );
#----------------------------------------------------------------------------------------
# §description  increment the the counter for the Method '$MethodName'
#----------------------------------------------------------------------------------------
# §input        $MethodName | name of method | string
#========================================================================================
sub increment {
    my $self = shift;
    my ( $MethodName ) = @_;

    $self->_testIfMethodWasAdded( $MethodName );
    $self->{$MethodName} += 1;

    return;
}
#========================================================================================
# §function     getAmountOfCalls
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       getAmountOfCalls( $MethodName );
#----------------------------------------------------------------------------------------
# §description  returns the amount of calls for the method '$MethodName'
#               throws error if the method was not added to Mockify
#----------------------------------------------------------------------------------------
# §input        $MethodName | name of method | string
# §return       $AmountOfCalls | Amount of calles | integer
#========================================================================================
sub getAmountOfCalls {
    my $self = shift;
    my ( $MethodName ) = @_;

    $self->_testIfMethodWasAdded( $MethodName );
    my $AmountOfCalls = $self->{ $MethodName };

    return $AmountOfCalls;
}
#========================================================================================
# §function     _testIfMethodWasAdded
# §state        private
#----------------------------------------------------------------------------------------
# §syntax       _testIfMethodWasAdded( $MethodName );
#----------------------------------------------------------------------------------------
# §description  tests if the method was added
#               Dies if the method was not added to mockify
#----------------------------------------------------------------------------------------
# §input        $MethodName | name of method | string
#========================================================================================
sub _testIfMethodWasAdded {
    my $self = shift;
    my ( $MethodName ) = @_;

    if( not exists $self->{ $MethodName } ){
        Error( "The Method: '$MethodName' was not added to Mockify" );
    }
}
1;