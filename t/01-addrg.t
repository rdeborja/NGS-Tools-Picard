use Test::More tests => 2;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use File::Path qw(remove_tree);
use Data::Dumper;
use Data::UUID;

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
	{ class_basename => 'Test' }
	);

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::AddOrReplaceReadGroups');
my $tempdir = 'tmp';

# setup a few variables
my $input = 'test.bam';

# instantiate the test class based on the given role
my $picard;
lives_ok
	{
		$picard = $test_class->new();
		}
	'Class instantiated';

# create a read group
my $rg = $picard->create_rg(
	sample => 'test_sample',
	library => 'test_library',
	id => '1234'
	);

# create the Picard read group command using the read group generated avove
my $picard_addrg = $picard->AddOrReplaceReadGroups(
	input => $input,
	sample => $rg,
	picard => '/hpf/tools/centos/picard-tools/1.103',
	java => '/hpf/tools/centos/java/1.6.0/bin/java',
	tmpdir => $tempdir
	);
my $expected_cmd = join(' ',
	'/hpf/tools/centos/java/1.6.0/bin/java',
	'-Xmx4g',
	'-Djava.io.tmpdir=tmp',
	'-jar /hpf/tools/centos/picard-tools/1.103/AddOrReplaceReadGroups.jar',
	'INPUT=test.bam',
	'OUTPUT=test.picard.rg.bam',
	'VALIDATION_STRINGENCY=LENIENT',
	'SORT_ORDER=coordinate',
	'CREATE_INDEX=true',
	'RGCN=tcag.ca',
	'RGID=1234',
	'RGLB=test_library',
	'RGPL=ILLUMINA',
	'RGPU=none',
	'RGSM=test_sample'
	);

# compare the generated and expected commands
is($picard_addrg->{'cmd'}, $expected_cmd, 'command matches expected');
print Dumper($picard_addrg);

# cleanup
remove_tree($tempdir);
