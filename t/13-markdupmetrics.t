use Test::More tests => 3;
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

# instantiate the test class based on the given role
my $picard;
lives_ok
    {
        $picard = $test_class->new();
        }
    'Class instantiated';

my $input = "$Bin/example/sample.markdupmetrics.txt";
my $picard_markdup = $picard->get_percent_duplication(
    input => $input
    );
my $expected_percent_duplication = '53.0852';
my $expected_sample = '2187_sh';
is(
    $picard_markdup->{'sample'},
    $expected_sample,
    "Sample name matches expected"
    );
is(
    $picard_markdup->{'percent_duplication'},
    $expected_percent_duplication,
    "Percent duplication matches expected"
    );
