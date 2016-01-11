#========================================================================================
# §package      t::FakeModuleForMockifyTest
# §state        public
#----------------------------------------------------------------------------------------
# §description  Fake Module For Mockify Test framework unit test
#========================================================================================
package t::FakeModuleForMockifyTest;

use strict;

#========================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       new( );
#----------------------------------------------------------------------------------------
# §description  constructor
#----------------------------------------------------------------------------------------
# §input        @ParameterList | Parameter list | array
# §return       $self | self | t::FakeModuleForMockifyTest
#========================================================================================
sub new {
    my $class = shift;
    my @ParameterList = @_;
    my $self  = bless {
        'ParameterListNew' => \@ParameterList
    }, $class;
    return $self;
}

#========================================================================================
# §function     DummmyMethodForTestOverriding
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       DummmyMethodForTestOverriding( );
#----------------------------------------------------------------------------------------
# §description  dummmy method for test overriding
#----------------------------------------------------------------------------------------
# §return       a test string | String
#========================================================================================
sub DummmyMethodForTestOverriding {
    my $self = shift;
    return 'A dummmy method';
}

#========================================================================================
# §function     secondDummmyMethodForTestOverriding
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       secondDummmyMethodForTestOverriding( );
#----------------------------------------------------------------------------------------
# §description  dummmy method for test overriding
#----------------------------------------------------------------------------------------
# §return       a test string | String
#========================================================================================
sub secondDummmyMethodForTestOverriding {
    my $self = shift;
    return 'A second dummmy method';
}

#========================================================================================
# §function     dummmyMethodWithParameterReturn
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       dummmyMethodWithParameterReturn( $Parameter );
#----------------------------------------------------------------------------------------
# §description  dummmy method for test overriding
#----------------------------------------------------------------------------------------
# §input        $Parameter | a parameter | String
# §return       $Parameter | a parameter | String
#========================================================================================
sub dummmyMethodWithParameterReturn {
    my $self = shift;
    my ( $Parameter ) = @_;
    return $Parameter;
}

#========================================================================================
# §function     returnParameterListNew
# §state        public
#----------------------------------------------------------------------------------------
# §syntax       returnParameterListNew( );
#----------------------------------------------------------------------------------------
# §description  returns the parameter list from constructor
#----------------------------------------------------------------------------------------
# §return       ParameterListNew | refarray
#========================================================================================
sub returnParameterListNew {
    my $self = shift;
    return $self->{'ParameterListNew'};
}

1;