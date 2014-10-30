#!/usr/bin/env perl

### generate_insert_size_metrics.pl ###############################################################
# Generate the insert size metrics using Picard's CollectInsertSizeMetrics.jar package

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-04-01      rdeborja            initial development

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
	java => '/hpf/tools/centos/java/1.6.0/bin/java',
	picard => '/hpf/tools/centos/picard-tools/1.103',
	memory => 8,
    cluster => 'FALSE'
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
        "cluster|c:s"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument \n";
            pod2usage(128);
            }
        }

    # where are the HPF::SGE templates located to create shell scripts
    my $template_dir = join('/',
        dist_dir('HPF'),
        'templates'
        );
    my $template = 'submit_to_sge.template';
    my $memory = $opts{'memory'} * 2;
    my $picard = NGS::Tools::Picard->new();
    my $insertsize = $picard->CollectInsertSizeMetrics(
    	input => $opts{'bam'},
        java => $opts{'java'},
        picard => $opts{'picard'}
    	);
    my @hold_for = ();
    my $picard_script = $picard->create_sge_shell_scripts(
        command => $insertsize->{'cmd'},
        jobname => join('_', 'tumour', 'picard', 'insertsize'),
        template_dir => $template_dir,
        template => $template,
        memory => $memory,
        hold_for => \@hold_for
        );

    if ($opts{'cluster'} eq 'FALSE') {
        my $submit_command = join(' ',
            'bash -c',
            $picard_script->{'output'}
            );
        system($picard_script->{'output'});
        }
    elsif ($opts{'cluster'} eq 'TRUE') {
        my $submit_command = join(' ',
            'qsub',
            $picard_script->{'output'}
            );
        }
    else {
        croak("Invalid cluster option");
        }
    return 0;
    }


__END__


=head1 NAME

generate_insert_size_metrics.pl

=head1 SYNOPSIS

B<generate_insert_size_metrics.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --bam           name of BAM file to process
    --java          full path to Java program
    --picard        full path to Picard suite of programs
    --memory        memory to use for Java engine (default: 4)
    --cluster       flag to determine whether to submit to a cluster (default: FALSE)

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

Full path to the directory containing the Picard JAR files

=item B<--memory>

Memory to allocate to the Java engine (default: 4)

=item B<--cluster>

Flag to identify whether to submit the command to a cluster using qsub or to execuate
at the command line using BASH

=back

=head1 DESCRIPTION

B<generate_insert_size_metrics.pl> Generate the insert size metrics using Picard's CollectInsertSizeMetrics.jar package

=head1 EXAMPLE

generate_insert_size_metrics.pl

=head1 AUTHOR

Richard de Borja -- Molecular Genetics

The Hospital for Sick Children

=head1 SEE ALSO

=cut

