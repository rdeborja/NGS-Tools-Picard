#!/usr/bin/perl

### sortsam.pl ####################################################################################
# Sort a SAM/BAM file.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-04-15      rdeborja            Initial development.
# 0.02          2015-01-02      rdeborja            removed HPF dependency, executing command with
#                                                   system() function

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
	order => 'coordinate'
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
        "order|o:s"
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
    my $picard_fastq = $picard->SortSam(
    	input => $opts{'bam'},
    	java => $opts{'java'},
    	picard => $opts{'picard'},
    	memory => $opts{'memory'},
    	sortorder => $opts{'order'},
        tmpdir => './tmp'
    	);

    my $picard_status = system($picard_fastq->{'cmd'});
    print "\nPicard completed: exit status $picard_stats\n\n";

    return $picard_status;
    }


__END__


=head1 NAME

sortsam.pl

=head1 SYNOPSIS

B<sortsam.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --bam           name of BAM file to process
    --java          full path to Java program
    --picard        full path to directory containing Picard jar files
    --memory        memory to use with the Java engine
    --order			sort order of BAM File

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

=item B<--order>

Sort order for BAM file.

=back

=head1 DESCRIPTION

B<sortsam.pl> Sort a SAM/BAM file.

=head1 EXAMPLE

sortsam.pl  --bam test.bam --memory 4 --order query

=head1 AUTHOR

Richard de Borja -- Shlien Lab

The Hospital for Sick Children

=head1 SEE ALSO

=cut

