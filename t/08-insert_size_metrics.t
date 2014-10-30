use Test::More tests => 4;
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
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::MetricsParser');

# instantiate the test class based on the given role
my $picard;
lives_ok
	{
		$picard = $test_class->new();
		}
	'Class instantiated';
my $file = "$Bin/example/sample.insertsizemetrics.txt";
my $insert_size_summary = $picard->get_insert_size_summary_statistics(
	file => $file
	);

is($insert_size_summary->{'MEDIAN_INSERT_SIZE'}, '190', 'median insert size');
is($insert_size_summary->{'MEAN_INSERT_SIZE'}, '201.124261', 'mean insert size');
is($insert_size_summary->{'STANDARD_DEVIATION'}, '54.48157', 'standard deviation');