use Test::More tests => 1;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use File::Path qw(make_path remove_tree);
use Data::Dumper;

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
    { class_basename => 'Test' }
    );

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::Picard::CollectMultipleMetrics');

# instantiate the test class based on the given role
my $metrics;
lives_ok
    {
        $metrics = $test_class->new();
        }
    'Class instantiated';

my $tmpdir = "tempdir";
my $multi_metrics = $metrics->CollectMultipleMetrics(
    input => 'test.bam',
    number_of_reads_to_process => '100000000',
    tmpdir => $tmpdir
    );
print Dumper($multi_metrics);
remove_tree($tmpdir);
