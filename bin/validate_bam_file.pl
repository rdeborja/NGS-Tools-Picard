#!/usr/bin/env perl

### validate_bam_file.pl ##########################################################################
# Run Picard's ValidateSamFile.jar on a BAM file.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-04-01      rdeborja            Initial development.
# 0.02          2015-01-02      rdeborja            removed HPF dependency, executes command using
#                                                   the system() function
# 0.03          2015-10-16      rdeborja            Updated sh-bang statement to use
#                                                   /usr/bin/env perl instead of /usr/bin/perl
#
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
	mode => 'SUMMARY',
	java => '/hpf/tools/centos/java/1.6.0/bin/java',
	picard => '/hpf/tools/centos/picard-tools/1.103',
	memory => 4
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
        "mode|m:s",
        "java|j:s",
        "picard|p:s",
        "memory:i"
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
    my $picard_validate = $picard->ValidateSamFile(
    	input => $opts{'bam'},
    	mode => $opts{'mode'},
    	java => $opts{'java'},
    	picard => $opts{'picard'},
    	memory => $opts{'memory'}
    	);

    my $picard_status = system($picard_validate->{'cmd'});
    print "\nPicard complete: exit status $picard_status\n\n";

    return $picard_status;
    }


__END__


=head1 NAME

validate_bam_file.pl

=head1 SYNOPSIS

B<validate_bam_file.pl> [options]

    Options:
    --help          brief help message
    --man           full documentation
    --bam           BAM file to validate (required)
    --mode          validation mode (default: SUMMARY)
    --java          full path to Java program (default: /hpf/tools/centos/java/1.6.0/bin/java)
    --picard        full path to Picard suite of tools (default: /hpf/tools/centos/picard-tools/1.103)
    --memory        memory (default: 4)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--bam>

BAM file to validate (required)

=item B<--mode>

Validation mode to use, can be either VERBOSE or SUMMARY (default: SUMMARY)

=item B<--java>

Full path to the Java program (default: /hpf/tools/centos/java/1.6.0/bin/java)

=item B<--picard>

Full path to the Picard suite of tools (default: /hpf/tools/centos/picard-tools/1.103)

=item B<--memory>

Memory allocated to the Java engine (default: 4)

=back

=head1 DESCRIPTION

B<validate_bam_file.pl> Run Picard's ValidateSamFile.jar on a BAM file.

=head1 EXAMPLE

validate_bam_file.pl  --bam test.bam --mode SUMMARY --memory 4

=head1 AUTHOR

Richard de Borja -- Molecular Genetics

The Hospital for Sick Children

=head1 SEE ALSO

=cut

