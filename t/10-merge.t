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
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::MergeSamFiles');

# instantiate the test class based on the given role
my $picard;
lives_ok
    {
        $picard = $test_class->new();
        }
    'Class instantiated';

my $bam_files = [
    '1.bam',
    '2.bam',
    '3.bam'
    ];
my $merge_run = $picard->merge_sam_files(
    input => $bam_files,
    sample => 'sample'
    );

my $expected_command = join(' ',
    'java -Xmx4g',
    '-jar ${PICARDROOT}/MergeSamFiles.jar',
    'INPUT=1.bam INPUT=2.bam INPUT=3.bam',
    'OUTPUT=sample.merged.bam',
    'VALIDATION_STRINGENCY=LENIENT',
    'SORT_ORDER=coordinate',
    'CREATE_INDEX=true',
    'USE_THREADING=true'
    );

is($merge_run->{'cmd'}, $expected_command, 'Command matches expected');
