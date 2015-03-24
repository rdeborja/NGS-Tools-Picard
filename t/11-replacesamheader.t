use Test::More tests => 2;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;
use HPF::PBS;
use File::ShareDir ':ALL';

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
    { class_basename => 'Test' }
    );

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::ReplaceSamHeader');

# instantiate the test class based on the given role
my $picard;
my $input = 'input.bam';
my $header_file = 'test.header.sam';
my $tempdir = '/tmp';
lives_ok
    {
        $picard = $test_class->new();
        }
    'Class instantiated';

my $replacesamheader = $picard->replace_sam_header(
    input => $input,
    header_file => $header_file,
    tmpdir => $tempdir
    );

my $expected_cmd = join(' ',
    'java',
    '-Xmx8g',
    '-Djava.io.tmpdir=/tmp',
    '-jar ${PICARDROOT}/ReplaceSamHeader.jar',
    'INPUT=input.bam',
    'OUTPUT=input.rg.bam',
    'HEADER=test.header.sam',
    'VALIDATION_STRINGENCY=LENIENT',
    'CREATE_INDEX=true'
    );
is($replacesamheader->{'cmd'}, $expected_cmd, "Command matches expected");

my $template_dir = join('/', dist_dir('HPF'), 'templates');
my $template = 'submit_to_pbs.template';
my $pbs = HPF::PBS->new();
my $pbs_job = $pbs->create_cluster_shell_script(
    jobname => 'test_script',
    command => $replacesamheader->{'cmd'},
    template => $template,
    template_dir => $template_dir,
    submit => 'false',
    root_directory => '.'
    );