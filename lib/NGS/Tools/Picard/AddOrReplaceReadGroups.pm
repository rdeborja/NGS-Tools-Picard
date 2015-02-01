package NGS::Tools::Picard::AddOrReplaceReadGroups;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Basename;
use File::Path qw(make_path);

=head1 NAME

NGS::Tools::Picard::AddOrReplaceReadGroups

=head1 SYNOPSIS

A Perl Moose Role to wrap Picard's AddOrReplaceReadGroups.jar tool.

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->AddOrReplaceReadGroups()

A method that wraps the AddOrReplaceReadGroups.jar tool.

=head3 Arguments:

=over 2

=item * input: Input BAM/SAM file for processing (required).

=item * output: Name of output BAM/SAM file with read groups and sorted (default: input prefix with .bam appended).

=item * sample: hash reference containing the read groups information (RGID, RGLB, RGPL, RGPU, RGSM, RGCN, RGDS, RGDT, RGPI) (required).

=item * stringency: stringency setting for SAM/BAM file validation (default: LENIENT)

=item * java: full path to Java program (default: java).

=item * picard: full directory path of Picard tools

=item * sortorder: The order for sorting the final BAM file (default: coordinate).

=item * memory: Amount of memory to allocate to the Java engine (default: 4).

=item * createindex: Flag to force Picard to create a BAM index file (default: true).

=back

=cut

sub AddOrReplaceReadGroups {
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
        sample => {
            isa         => 'HashRef',
            required    => 0,
            default     => {}
            },
        stringency => {
            isa         => 'Str',
            required    => 0,
            default     => 'LENIENT'
            },
        java => {
            isa         => 'Str',
            required    => 0,
            default     => 'java'
            },
        picard => {
            isa         => 'Str',
            required    => 0,
            default     => '${PICARDROOT}'
            },
        memory => {
            isa         => 'Int',
            required    => 0,
            default     => 4
            },
        sortorder => {
            isa         => 'Str',
            required    => 0,
            default     => 'coordinate'
            },
        createindex => {
            isa         => 'Str',
            required    => 0,
            default     => 'true'
            },
        tmpdir => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            }
        );

    my $sample_info = $args{'sample'};
    my $output;
    if ('' eq $args{'output'}) {
        $output = join('.',
            File::Basename::basename($args{'input'}, qw( .bam .sam )),
            'picard',
            'rg',
            'bam'
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
        'AddOrReplaceReadGroups.jar'
        );
    my $program = join(' ',
        $args{'java'},
        "-Xmx" . $memory,
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

    # setup the options for Picard
    my $options = join(' ',
        'INPUT=' . $args{'input'},
        'OUTPUT=' . $output,
        'VALIDATION_STRINGENCY=' . $args{'stringency'},
        'SORT_ORDER=' . $args{'sortorder'},
        'CREATE_INDEX=' . $args{'createindex'}
        );

    # create a string containing the read group elements including the RGID
    # from above, at minimum the required read group parameters include:
    # RDID (obtained above), RGSM, RGPL, RGPU, RGLB
    my @params;
    foreach my $read_group_param (keys(%$sample_info)) {
        if ('' ne $sample_info->{$read_group_param}) {
            push(@params, join('=', $read_group_param, $sample_info->{$read_group_param}));
            }
        }
    my $param_string = join(' ',
        sort(@params)
        );
    my $cmd = join(' ',
        $program,
        $options,
        $param_string
        );

    my %return_values = (
        cmd => $cmd,
        output => $output
        );

    return(\%return_values);
    }

=head2 $obj->create_rg()

Create a Read Group (RG) file for use with the method AddOrReplaceReadGroups.

=head3 Arguments:

=over 2

=item * id: unique identifier, this should be left blank as the method will autogenerate a unique identifier

=item * sample: name of sample

=item * library: name of library

=item * platform: name of platform sequencing was performed on (default: ILLUMINA)

=item * platform_unit: flowcell ID (default: none)

=item * center: name of sequencing center (default: tcag.ca)

=back

=header3 Return Values:

=over 2

=item * Returns a hash reference containing the following keys: RGSM

=back

=cut

sub create_rg {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        id => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            },
        sample => {
            isa         => 'Str',
            required    => 1
            },
        library => {
            isa         => 'Str',
            required    => 1
            },
        platform => {
            isa         => 'Str',
            required    => 0,
            default     => 'ILLUMINA'
            },
        platform_unit => {
            isa         => 'Str',
            required    => 0,
            default     => 'none'
            },
        center => {
            isa         => 'Str',
            required    => 0,
            default     => 'tcag.ca'
            },
        description => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            }
        );

    my %_sample_rg = (
        RGSM        => $args{'sample'},
        RGLB        => $args{'library'},
        RGPL        => $args{'platform'},
        RGPU        => $args{'platform_unit'},
        RGCN        => $args{'center'}
        );

    # create a unique identifier for the read group ID
    my $uuid_object = Data::UUID->new();
    my $uuid = $uuid_object->create();
    my $uuid_string = $uuid_object->to_string($uuid);
    if ($args{'id'} eq '') {
        $_sample_rg{'RGID'} = $uuid_string;
        }
    else {
        $_sample_rg{'RGID'} = $args{'id'};
        }

    # add optional parameters if defined by the caller
    if ($args{'description'} ne '') {
        $_sample_rg{'RGDS'} = $args{'description'}
        }

    return(\%_sample_rg);
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

    perldoc NGS::Tools::Picard::AddOrReplaceReadGroups

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

1; # End of NGS::Tools::Picard::AddOrReplaceReadGroups
