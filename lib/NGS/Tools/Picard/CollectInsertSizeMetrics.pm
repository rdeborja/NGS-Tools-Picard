package NGS::Tools::Picard::CollectInsertSizeMetrics;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Basename;

=head1 NAME

NGS::Tools::Picard::InsertSizeMetrics

=head1 SYNOPSIS

A Perl Moose role wrapper for Picard's CollectInsertSizeMetrics.jar program.

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->CollectInsertSizeMetrics()

Moose method for insert size metrics.

=head3 Arguments:

=over 2

=item * input: name of SAM/BAM file to process (required)

=item * output: name of output file prefix, insert size metrics file will have insertsizemetrics.txt appended and the histogram will have histogram.txt appended (default: the input filename)

=item * stringency: stringency level for Picard walker (defaault: LENIENT)

=item * java: full path to the Java engine (default: java)

=item * picard: full path to the Picard suite of JAR files (default: $PICARDROOT)

=item * memory: max amount of memory to allocate to the Java engine (default: 4)

=item * tmpdir: temporary directory to write intermediate output to (optional);

=item * number_of_reads_to_process: number of reads to process when calculating statistics, by defaul this processes all reads (optional)

=back

=cut

sub CollectInsertSizeMetrics {
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
		stringency => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'LENIENT'
			},
		java => {
			isa			=> 'Str',
			required	=> 0,
			default		=> 'java'
			},
		picard => {
			isa			=> 'Str',
			required	=> 0,
			default		=> '${PICARDROOT}'
			},
		memory => {
			isa			=> 'Int',
			required	=> 0,
			default		=> 4
			},
		tmpdir => {
			isa			=> 'Str',
			required	=> 0,
			default		=> ''
			},
		number_of_reads_to_process => {
			isa			=> 'Str',
			required	=> 0,
			default		=> ''
			}
		);

	my $memory = join('',
		$args{'memory'},
		'g'
		);

	my $output;
	my $histogram;
	if ('' eq $args{'output'}) {
		$output = join('.',
			File::Basename::basename($args{'input'}, qw( .bam .sam )),
			'insertsizemetrics',
			'txt'
			);
		$histogram = join('.',
			File::Basename::basename($output, qw( .txt )),
			'histogram',
			'pdf'
			);
		}
	my $picard_jar = join('/',
		$args{'picard'},
		'CollectInsertSizeMetrics.jar'
		);
	my $program = join(' ',
		$args{'java'},
		'-Xmx' . $memory,
		);

	# create a tmpdir and use it in the java command
	if ($args{'tmpdir'} ne '') {
		if (! -d $args{'tmpdir'}) {
			make_path($args{'tmpdir'});
			}
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

	my $options = join(' ',
		'INPUT=' . $args{'input'},
		'OUTPUT=' . $output,
		'HISTOGRAM_FILE=' . $histogram,
		'VALIDATION_STRINGENCY=' . $args{'stringency'}
		);

	if ($args{'number_of_reads_to_process'} ne '') {
		$options = join(' ',
			$options,
			'STOP_AFTER=' . $args{'number_of_reads_to_process'}
			);
		}

	my $cmd = join(' ',
		$program,
		$options
		);

	my %return_values = (
		cmd => $cmd,
		output => $output,
		histogram => $histogram
		);

	return(\%return_values);
	}


=head2 $obj->get_mean_insert_size()

Get the mean insert size from the report.

=head3 Arguments:

=over 2

=item * input: Picard CollectInsertSizeMetrics.jar output file.

=back

=cut

sub get_mean_insert_size {
	my $self = shift;
	my %args = validated_hash(
		\@_,
		input => {
			isa         => 'Str',
			required    => 1
			}
		);
	my $mean_insert_size;
	open(my $input_fh, '<', $args{'input'});
	while(my $line = <$input_fh>) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		next if ($line =~ m/^#/);

		# the header will start with "MEDIAN_INSERT_SIZE"
		if ($line =~ m/^MEDIAN_INSERT_SIZE/) {
			# get the next line which will contain the data of interest
			$line = <$input_fh>;
			$line =~ s/^\s+//;
			$line =~ s/\s+$//;
			my @input_line = split(/\t/, $line);
			$mean_insert_size = $input_line[4];
			}
		}
	close($input_fh);

	my %return_values = (
		mean_insert_size => $mean_insert_size
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

    perldoc NGS::Tools::Picard::InsertSizeMetrics

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

1; # End of NGS::Tools::Picard::InsertSizeMetrics
