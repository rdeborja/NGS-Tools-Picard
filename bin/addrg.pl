#!/usr/bin/env perl

### addrg.pl ######################################################################################
# Add a RG (read group) tag to the BAM file

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-06-22      rdeborja            initial development

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use NGS::Tools::Picard;
use YAML qw(LoadFile);
use File::ShareDir ':ALL';

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
	input => undef,
	picard => '${PICARDROOT}',
	java => "/hpf/tools/centos/java/1.6.0/bin/java",
	config => undef,
	tmpdir => './tmp',
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
        "input|i=s",
        "picard|p=s",
        "java|j:s",
        "config|c=s",
        "tmpdir|t:s",,
        "memory|m:i"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument \n";
            pod2usage(128);
            }
        }

    # load the config file containing sample information
    my $sample = YAML::LoadFile($opts{'config'});
    my $picard = NGS::Tools::Picard->new();
    my $rg = $picard->AddOrReplaceReadGroups(
    	input => $opts{'input'},
    	sample => $sample,
    	java => $opts{'java'},
    	picard => $opts{'picard'},
    	memory => $opts{'memory'},
    	tmpdir => $opts{'tmpdir'}
    	);
    my $template_dir = join('/',
        dist_dir('HPF'),
        'templates'
        );
    my $template = 'submit_to_sge.template';
    my @hold_for = ();
    $picard->create_cluster_shell_script(
    	command => $rg->{'cmd'},
    	memory => $opts{'memory'} * 2,
    	jobname => join('_', 'rg'),
    	template_dir => $template_dir,
    	template => $template,
    	hold_for => \@hold_for
    	);

    return 0;
    }


__END__


=head1 NAME

addrg.pl

=head1 SYNOPSIS

B<addrg.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --input         input SAM/BAM file (required)
    --config        configuration file with sample information in YAML format (required)
    --picard        full path to the Picard suite of tools (default: ${PICARDROOT})
    --java          full path to the Java program 
    --tmpdir        temporary directory (default: ./tmp)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--input>

Input SAM/BAM file (required)

=item B<--config>

Configuration file in YAML format (required)

=item B<--picard>

Full path to the Picard suite of tools (default: ${PICARDROOT})

=item B<--java>

Full path to the Java program



=back

=head1 DESCRIPTION

B<addrg.pl> Add a RG (read group) tag to the BAM file

=head1 EXAMPLE

addrg.pl --input file.bam --config sample.yaml --picard /usr/bin/picard --java /usr/bin/java --tmpdir tmp

=head1 AUTHOR

Richard de Borja -- Molecular Genetics

The Hospital for Sick Children

=head1 SEE ALSO

=cut

