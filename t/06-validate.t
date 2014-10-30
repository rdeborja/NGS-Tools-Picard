use Test::More tests => 1;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
	{ class_basename => 'Test' }
	);

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::ValidateSamFile');

# instantiate the test class based on the given role
my $picard;
lives_ok
	{
		$picard = $test_class->new();
		}
	'Class instantiated';
my $input = '/tmp/test/test.bam';
my $picard_validate = $picard->ValidateSamFile(
	input => $input
	);
print Dumper($picard_validate);
