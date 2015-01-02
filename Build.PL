use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'NGS::Tools::Picard',
    license             => 'Artistic_2_0',
    dist_author         => q{Richard de Borja <richard.deborja@sickkids.ca>},
    dist_version_from   => 'lib/NGS/Tools/Picard.pm',
    dist_abstract       => 'NGS::Tools::Picard Perl package for Picard suite of tools',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
        'Moose'             => 0,
        'Moose::Role'       => 0,
        'Carp'              => 0
    },
    add_to_cleanup     => [ 'NGS-Tools-Picard-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
