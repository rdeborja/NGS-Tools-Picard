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
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::SortSam');

# instantiate the test class based on the given role
my $picard;
lives_ok
	{
		$picard = $test_class->new();
		}
	'Class instantiated';

my $input = 'test.bam';
my $picard_sort = $picard->SortSam(
	input => $input,
	picard => '/hpf/tools/centos/picard-tools/1.103',
	java => '/hpf/tools/centos/java/1.6.0/bin/java'
	);
my $expected_command = join(' ',
	'/hpf/tools/centos/java/1.6.0/bin/java',
	'-Xmx4g',
	'-jar',
	'/hpf/tools/centos/picard-tools/1.103/SortSam.jar',
	'INPUT=test.bam',
	'OUTPUT=test.sorted.bam',
	'VALIDATION_STRINGENCY=LENIENT',
	'SORT_ORDER=coordinate',
	'CREATE_INDEX=true'
	);
is($picard_sort->{'cmd'}, $expected_command, 'Sort command matches expected.');
