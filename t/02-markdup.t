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
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::MarkDuplicates');

my $input = 'input.bam';

# instantiate the test class based on the given role
my $picard;
lives_ok
	{
		$picard = $test_class->new();
		}
	'Class instantiated';

my $picard_markdup = $picard->MarkDuplicates(
	picard => '/hpf/tools/centos6/picard-tools/1.108',
	java => '/hpf/tools/centos6/java/1.7.0/bin/java',
	input => $input,
	tmpdir => './tmp'
	);

my $expected_cmd = join(' ',
	"/hpf/tools/centos6/java/1.7.0/bin/java -Xmx4g -Djava.io.tmpdir=./tmp",
	"-jar /hpf/tools/centos6/picard-tools/1.108/MarkDuplicates.jar",
	"INPUT=input.bam",
	"OUTPUT=input.markdup.bam",
	"METRICS_FILE=input.markdup.metrics.txt",
	"VALIDATION_STRINGENCY=LENIENT",
	"CREATE_INDEX=true",
	"REMOVE_DUPLICATES=false",
	"ASSUME_SORTED=false"
	);
is($picard_markdup->{'cmd'}, $expected_cmd, "command matches expected");
