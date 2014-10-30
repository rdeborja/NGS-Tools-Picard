use Test::More tests => 2;
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
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::CollectInsertSizeMetrics');

# instantiate the test class based on the given role
my $picard;
lives_ok
	{
		$picard = $test_class->new();
		}
	'Class instantiated';

my $input = "$Bin/example/sample.insertsizemetrics.txt";
my $picard_insertsize = $picard->get_mean_insert_size(
	input => $input
	);

my $expected_mean_insert_size = 201.124261;
is($picard_insertsize->{'mean_insert_size'}, $expected_mean_insert_size, 'Mean insert size matches expected');
