#!/usr/bin/env perl

### generate_insert_size_metrics.pl ###############################################################
# Generate the insert size metrics using Picard's CollectInsertSizeMetrics.jar package

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-04-01      rdeborja            initial development
# 0.02          2015-01-02      rdeborja            removed HPF dependency, executing command with
#                                                   the system() command.
# 0.03          2015-06-12      rdeborja            reimplemented with HPF::PBS to submit to
#                                                   cluster
### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use NGS::Tools::Picard;
use File::ShareDir ':ALL';
use HPF::PBS;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
  bam => undef,
  java => '/hpf/tools/centos6/java/1.7.0/bin/java',
  picard => '/hpf/tools/centos6/picard-tools/1.108',
  memory => 8,
  submit => 'true',
  number_of_reads_to_process => 100000
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
        "submit:s",
        "number_of_reads_to_process:i"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument \n";
            pod2usage(128);
            }
        }

    my $picard = NGS::Tools::Picard->new();
    my $insertsize = $picard->CollectInsertSizeMetrics(
      input => $opts{'bam'},
      java => $opts{'java'},
      picard => $opts{'picard'},
      number_of_reads_to_process => $opts{'number_of_reads_to_process'}
      );
    my $template_dir = join('/', dist_dir('HPF'), 'templates');
    my $template = 'submit_to_pbs.template';
    my $pbs = HPF::PBS->new();
    my $pbs_run = $pbs->create_cluster_shell_script(
      jobname => 'insertsize',
      command => $insertsize->{'cmd'},
      template => $template,
      memory => $opts{'memory'} + 8,
      template_dir => $template_dir,
      modules_to_load => ['R/3.1.1', 'perl', 'picard-tools/1.108'],
      submit => $opts{'submit'}
      );

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
    --java          full path to Java program (default: /hpf/tools/centos6/java/1.7.0/bin/java)
    --picard        full path to Picard suite of programs (default: )
    --memory        memory to use for Java engine (default: 4)
    --submit        submit job to cluster (default: true)
    --number_of_reads_to_process
                    number of reads to calculate insert size distribution (default: 100000)

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

=item B<--submit>

A boolean to determine whether to submit job to PBS (default: true)

=item B<--number_of_reads_to_process>

Number of reads to analyze to determine insert size distribution (default: 100000)

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

