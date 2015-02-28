=head1
# template for yourTest.t
package t::yourTest;
use base t::TestBase;
use strict;
use Test::More;

sub testPlan{
	my $self = shift;	
	$self->testSomething();
	return;
}

sub testSomething {
	my $self = shift;
	my $SubTestName = (caller(0))[3];
	ok(1,"$SubTestName - tests if ...");
	return;
}

__PACKAGE__->RunTest();
1;
=cut
package t::TestBase;
use strict;
use Test::More;
sub new {
	my $class = shift;
	my $self = bless({},$class);
	return $self;
}

sub RunTest {
	my $Package = shift;
	note("Unit test for: $Package ######");
	my $UnitTest = $Package->new();
	
	$UnitTest->testPlan();
	done_testing();
}

1;
