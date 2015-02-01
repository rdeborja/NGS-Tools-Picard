#!/usr/bin/env perl

### markdups.pl ###################################################################################
# Execute Picard's MarkDuplicates.jar program  to mark duplicate reads due to PCR.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-05-05      rdeborja            initial development
# 0.02          2015-01-02      rdeborja            removed HPF dependency, executing command with
#                                                   system() function
# 0.03          2015-01-30      added 
### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use NGS::Tools::Picard;
use File::ShareDir ':ALL';
use HPF::PBS;
use IPC::Run3;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
    bam => undef,
    memory => 8,
    java => '/hpf/tools/centos/java/1.6.0/bin/java',
    picard => '/hpf/tools/centos/picard-tools/1.103',
    tmpdir => './tmp'
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
        "memory|m:i",
        "java:s",
        "picard:s",
        "tmpdir|t:s"
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
    my $markdup_run = $picard->MarkDuplicates(
    	input => $opts{'bam'},
    	memory => $opts{'memory'},
    	java => $opts{'java'},
    	picard => $opts{'picard'},
        tmpdir => $opts{'tmpdir'}
    	);

    my $picard_status = system($markdown_run->{'cmd'});
    print "\nPicard complete: exit status $picard_status\n\n";

    return $picard_status;
    }


__END__


=head1 NAME

markdups.pl

=head1 SYNOPSIS

B<markdups.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --bam           BAM file to process (required)
    --memory        memory to allocate for Java engine (required)
    --java          full path to Java engine (optional)
    --picard        full path to the Picard suite of tools (optional)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--bam>

BAM file to process.

=item B<--memory>

Memory to allocate for the Java engine.

=item B<--java>

Full path to the Java engine (default: /hpf/tools/centos/java/1.6.0/bin/java)

=item B<--picard>

Full path to the directory containing the Picard suite of tools (default: /hpf/tools/centos/picard-tools/1.103)

=back

=head1 DESCRIPTION

B<markdups.pl> Execute Picard's MarkDuplicates.jar program to mark duplicate reads due to PCR.

=head1 EXAMPLE

markdups.pl  --bam test.bam --memory 8

=head1 AUTHOR

Richard de Borja -- Molecular Genetics

The Hospital for Sick Children

=head1 SEE ALSO

=cut

