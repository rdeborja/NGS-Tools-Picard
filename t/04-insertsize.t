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

my $input = 'test.bam';
my $picard_insertsize_run = $picard->CollectInsertSizeMetrics(
	input => $input
	);
my $expected_command = join(' ',
	'java -Xmx4g',
	'-jar ${PICARDROOT}/CollectInsertSizeMetrics.jar',
	'INPUT=test.bam',
	'OUTPUT=test.insertsizemetrics.txt',
 	'HISTOGRAM_FILE=test.insertsizemetrics.histogram.pdf',
 	'VALIDATION_STRINGENCY=LENIENT'
	);
is($picard_insertsize_run->{'cmd'}, $expected_command, 'Picard command matches expected');
