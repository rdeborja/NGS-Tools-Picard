package NGS::Tools::Picard::CollectMultipleMetrics;
use Moose::Role;
use MooseX::Params::Validate;

with 'NGS::Tools::Picard::Roles::Core';

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Path qw(make_path);
use Log::Log4perl qw(:easy);

=head1 NAME

NGS::Tools::Picard::CollectMultipleMetrics

=head1 SYNOPSIS

Package synopsis

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->CollectMultipleMetrics()

A method that wraps Picard's CollectMultipleMetrics.jar program.

=head3 Arguments:

=over 2

=item * input: Input BAM/SAM file for processing (required).

=item * output: Output filename prefix, suffix will be added based on metric output.

=item * sorted: Boolean to identify whether the BAM/SAM file should be assumed to be sorted (default: false)

=item * java: Full path to the Java program (default: assumes java is in the path)

=item * picard: Full path to the directory containing the Picard suite of tools (default: $PiCARDROOT)

=item * memory: Amount of memory in GB to allocate to the Java engine (default: 4)

=item * stringency: Level of stringency for the Picard program, controlled list (default: LENIENT)

=item * tmpdir: Name of temp directory to be used by the Java engine

=back

=cut

sub CollectMultipleMetrics {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        input => {
            isa         => 'Str',
            required    => 1
            },
        output => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            },
        sorted => {
            isa         => 'Str',
            required    => 0,
            default     => 'false'
            },
        java => {
            isa         => 'Str',
            required    => 0,
            default     => $self->get_java()
            },
        picard => {
            isa         => 'Str',
            required    => 0,
            default     => $self->get_picard()
            },
        memory => {
            isa         => 'Int',
            required    => 0,
            default     => 4
            },
        stringency => {
            isa         => 'Str',
            required    => 0,
            default     => $self->get_validation_stringency()
            },
        tmpdir => {
            isa         => 'Str',
            required    => 0,
            default     => $self->get_tmpdir()
            },
        number_of_reads_to_process => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            }
        );

    my $output;
    if ('' eq $args{'output'}) {
        $output = join('.',
            File::Basename::basename($args{'input'}, qw( .bam .sam )),
            'multimetrics'
            );
        }
    else {
        $output = $args{'output'};
        }
    my $memory = join('',
        $args{'memory'},
        'g'
        );
    my $picard_jar = join('/',
        $args{'picard'},
        'CollectMultipleMetrics.jar'
        );
    my $program = join(' ',
        $args{'java'},
        '-Xmx' . $memory
        );
    if ($args{'tmpdir'} ne '') {
        if (! -d $args{'tmpdir'}) {
            make_path($args{'tmpdir'}, {verbose => 1, mode => 0770});
            }
        $program = join(' ',
            $program,
            "-Djava.io.tmpdir=$args{'tmpdir'}"
            );
        }
    $program = join(' ',
        $program,
        '-jar',
        $picard_jar
        );
    # setup the Picard options
    my $options = join(' ',
        'INPUT=' . $args{'input'},
        'OUTPUT=' . $output,
        'ASSUME_SORTED=' . $args{'sorted'},
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
        cmd => $cmd
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

    perldoc NGS::Tools::Picard::CollectMultipleMetrics

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

1; # End of NGS::Tools::Picard::CollectMultipleMetrics
