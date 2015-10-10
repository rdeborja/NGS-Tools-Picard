package NGS::Tools::Picard::MarkDuplicates;
use Moose::Role;
use MooseX::Params::Validate;

with 'NGS::Tools::Picard::Roles::Core';

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Basename;
use File::Path qw(make_path remove_tree);

=head1 NAME

NGS::Tools::Picard::MarkDuplicates

=head1 SYNOPSIS

A Perl Moose Role to wrap Picard's MarkDuplicates.jar tool

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->MarkDuplicates()

A method that wraps the MarkDulicates.jar tool

=head3 Arguments:

=over 2

=item * input: Input BAM/SAM file for processing (required).

=item * output: Name of output BAM/SAM file with duplicates marked.

=item * rmdup: Flag to remove any duplicate reads from the BAM file (default: false).

=item * sorted: Flag to identify BAM file is sorted (default: false).

=item * java: Full path to Java program (default: java).

=item * picard: Full directory path to Picard tools (default: ${PICARDROOT}).

=item * memory: Amount of memory to allocate to the Java engine (default: 4).

=item * createindex: Flag to force Picard to create a BAM index file (default: true).

=item * stringency: Validation verbosity when running any Picard tool (default: LENIENT).

=back

=cut

sub MarkDuplicates {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		input => {
			isa         => 'Str',
			required    => 1
			},
		output => {
			isa			=> 'Str',
			required	=> 0,
			default		=> ''
			},
		rmdup => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'false'
			},
		sorted => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'false'
			},
		java => {
			isa			=> 'Str',
			required	=> 0,
			default		=> $self->get_java()
			},
		picard => {
			isa			=> 'Str',
			required	=> 0,
			default		=> $self->get_picard()
			},
		memory => {
			isa			=> 'Int',
			required	=> 0,
			default		=> 4
			},
		createindex => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'true'
			},
		stringency => {
			isa			=> 'Str',
			required	=> 0,
			default		=> $self->get_validation_stringency()
			},
		tmpdir => {
			isa			=> 'Str',
			required	=> 0,
			default		=> $self->get_tmpdir()
			}
		);

	my $output;
	if ('' eq $args{'output'}) {
		$output = join('.',
			File::Basename::basename($args{'input'}, qw( .bam .sam )),
			'markdup',
			'bam'
			);
		}
	else {
		$output = $args{'output'};
		}

	my $metrics;
	if ('' ne $args{'output'}) {
		$metrics = join('.',
			File::Basename::basename($args{'output'}, qw( .bam .sam )),
			'metrics',
			'txt'
			);
		}
	else {
		$metrics = join('.',
			File::Basename::basename($args{'input'}, qw( .bam .sam )),
			'markdup',
			'metrics',
			'txt'
			);
		}

	my $memory = join('',
		$args{'memory'},
		'g'
		);

	my $picard_jar = join('/',
		$args{'picard'},
		'MarkDuplicates.jar'
		);
	my $program = join(' ',
		$args{'java'},
		'-Xmx' . $memory,
		);

	# create a tmpdir and use it in the java command
	if ($args{'tmpdir'} ne '') {
		$program = join(' ',
			$program,
			'-Djava.io.tmpdir=' . $args{'tmpdir'}
			);
		}
    $program = join(' ',
    	$program,
    	'-jar',
    	$picard_jar
    	);

	# setup the options for Picard
	my $options = join(' ',
		'INPUT=' . $args{'input'},
		'OUTPUT=' . $output,
		'METRICS_FILE=' . $metrics,
		'VALIDATION_STRINGENCY=' . $args{'stringency'},
		'CREATE_INDEX=' . $args{'createindex'},
		'REMOVE_DUPLICATES=' . $args{'rmdup'},
		'ASSUME_SORTED=' . $args{'sorted'}
		);

	my $cmd = join(' ',
		$program,
		$options
		);

	my %return_values = (
		cmd => $cmd,
		output => $output,
		metrics => $metrics
		);

	return(\%return_values);
	}

=head2 $obj->get_percent_duplication()

From the output metrics of MarkDuplicates, get the 

=head3 Arguments:

=over 2

=item * input: Metrics output file from MarkDuplicates.jar

=back

=cut

sub get_percent_duplication {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		input => {
			isa         => 'Str',
			required    => 1
			}
		);

	my $percent_duplication;
	my $sample;
	open(my $ifh, '<', $args{'input'});
	while(my $line = <$ifh>) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		next if ($line =~ m/^#/);

		# look for the header that stats with LIBRARY
		if ($line =~ m/^LIBRARY/) {
			# get the next line which will contain the data of interest
			$line = <$ifh>;
			$line =~ s/^\s+//;
			$line =~ s/\s+$//;
			my @input_line = split(/\t/, $line);
			$sample = $input_line[0];
			$percent_duplication = $input_line[7] * 100;
			}
		}
	close($ifh);

	my %return_values = (
		sample => $sample,
		percent_duplication => $percent_duplication
		);

	return(\%return_values);
	}
=head1 AUTHOR

Richard de Borja, C<< <richard.deborja at sickkids.ca> >>

=head1 ACKNOWLEDGEMENT

Dr. Adam Shlien, PI -- The Hospital for Sick Children

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-test at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=test-test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc NGS::Tools::Picard::MarkDuplicates

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=test-test>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/test-test>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/test-test>

=item * Search CPAN

L<http://search.cpan.org/dist/test-test/>

=back

=head1 ACKNOWLEDGEMENTS

Dr. Adam Shlien, PI - The Hospital for Sick Children

Dr. Roland Arnold - The Hospital for Sick Children

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Richard de Borja.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

no Moose::Role;

1; # End of NGS::Tools::Picard::MarkDuplicates
