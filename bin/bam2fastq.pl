#!/usr/bin/env perl

### bam2fastq.pl ##############################################################################
# Convert a BAM file to a FASTQ file using Picard's SamToFastq.jar program.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-04-15		rdeborja            Initial development.
# 0.02          2014-06-26      rdeborja            added temporary directory 

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use NGS::Tools::Picard;
use File::ShareDir ':ALL';

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
	bam => undef,
	java => '/hpf/tools/centos/java/1.7.0/bin/java',
	picard => '/hpf/tools/centos/picard-tools/1.103',
	memory => 8,
    tmp => './tmp'
    );

### MAIN CALLER ###################################################################################
my $result = main();
exit($result);

### FUNCTIONS #####################################################################################

### main ##########################################################################################
# Description:
#   Main subroutine for program
# Input Variables:
#   %opts = command line arguments
# Output Variables:
#   N/A

sub main {
    # get the command line arguments
    GetOptions(
        \%opts,
        "help|?",
        "man",
        "bam|b=s",
        "java|j:s",
        "picard|p:s",
        "memory|m:i",
        "tmp|t:s"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument \n";
            pod2usage(128);
            }
        }

    my $template_dir = join('/',
    	dist_dir('HPF'),
    	'templates'
    	);
    my $template = 'submit_to_sge.template';
    my $memory = $opts{'memory'} * 2;
    my $picard = NGS::Tools::Picard->new();
    my $picard_fastq = $picard->SamToFastq(
    	input => $opts{'bam'},
    	java => $opts{'java'},
    	picard => $opts{'picard'},
    	memory => $opts{'memory'},
        tmpdir => $opts{'tmp'}
    	);
    my @hold_for = ();
    my $picard_script = $picard->create_cluster_shell_script(
    	command => $picard_fastq->{'cmd'},
    	jobname => join('_', 'picard', 'fastq'),
    	template_dir => $template_dir,
    	template => $template,
    	memory => $memory,
    	hold_for => \@hold_for,
        queue => 'long.q'
    	);

    return 0;
    }


__END__


=head1 NAME

bam2fastq.pl

=head1 SYNOPSIS

B<bam2fastq.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --bam           name of BAM file to process (required)
    --java          full path to Java program (default: /hpf/tools/centos/java/1.7.0/bin/java)
    --picard        full path to directory containing Picard jar files (default: /hpf/tools/centos/picard-tools/1.103)
    --memory        memory to use with the Java engine in GB (default: 8)
    --tmp           directory that holds generated temp files (default: ./tmp)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--bam>

Name of BAM file to process.

=item B<--java>

Full path to the Java program.

=item B<--picard>

Full path to the Picard suite of Jar files.

=item B<--memory>

Amount of memory to allocate (in GB) for the Java engine. 

=item B<--tmp>

Directory for generating temporary files.

=back

=head1 DESCRIPTION

B<bam2fastq.pl> Convert a BAM file to a FASTQ file using Picard's SamToFastq.jar program.

=head1 EXAMPLE

bam2fastq.pl --bam test.bam --memory 4 --java java --picard /hpf/tools/centos/picard-tools/1.103 --memory 8 --tmp ./tmp

=head1 AUTHOR

Richard de Borja -- Moledular Genetics

The Hospital for Sick Children

=cut

