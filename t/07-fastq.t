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
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::SamToFastq');

# instantiate the test class based on the given role
my $picard;
lives_ok
	{
		$picard = $test_class->new();
		}
	'Class instantiated';

my $test_bam = 'test.bam';

my $picard_fastq = $picard->SamToFastq(
	input => $test_bam,
	readgroup => 'true'
	);
my $expected_cmd = join(' ',
	"java -Xmx4g",
	'-jar ${PICARDROOT}/SamToFastq.jar',
	"INPUT=test.bam",
	"VALIDATION_STRINGENCY=LENIENT",
	"INCLUDE_NON_PF_READS=true",
	"OUTPUT_PER_RG=true"
	);
is($picard_fastq->{'cmd'}, $expected_cmd, 'command matches expected with readgroups');
my $picard_fastq = $picard->SamToFastq(
	input => $test_bam,
	readgroup => 'false'
	);
$expected_cmd = join(' ',
	"java -Xmx4g",
	'-jar ${PICARDROOT}/SamToFastq.jar',
	"INPUT=test.bam",
	"FASTQ=test.read1.fastq.gz",
	"VALIDATION_STRINGENCY=LENIENT",
	"INCLUDE_NON_PF_READS=true",
	"SECOND_END_FASTQ=test.read2.fastq.gz"
	);
is($picard_fastq->{'cmd'}, $expected_cmd, 'command matches expected without readgroups');

