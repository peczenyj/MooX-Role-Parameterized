use strict;
use warnings;

use ExtUtils::MakeMaker;

# Build the META 'provides' map from the modules shipped in lib/, taking each
# version straight from its source file so it stays in sync with VERSION_FROM.
my %provides;
for my $file (
    'lib/MooX/Role/Parameterized.pm',
    'lib/MooX/Role/Parameterized/Cookbook.pm',
    'lib/MooX/Role/Parameterized/Mop.pm',
    'lib/MooX/Role/Parameterized/With.pm',
) {
    ( my $module = $file ) =~ s{^lib/|\.pm$}{}g;
    $module =~ s{/}{::}g;
    $provides{$module} = {
        file    => $file,
        version => MM->parse_version($file),
    };
}

WriteMakefile(
    NAME               => 'MooX::Role::Parameterized',
    DISTNAME           => "MooX-Role-Parameterized",
    AUTHOR             => 'Tiago Peczenyj <tiago.peczenyj+cpan@gmail.com>',
    LICENSE            => "mit",
    ABSTRACT_FROM      => 'lib/MooX/Role/Parameterized.pm',
    VERSION_FROM       => 'lib/MooX/Role/Parameterized.pm',
    MIN_PERL_VERSION   => 5.012,
    CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => 0 },
    PREREQ_PM          => {
        'Carp'             => 0,
        'Module::Runtime'  => 0,
        'Moo'              => 2,
        'MooX::BuildClass' => 0.213360,
    },
    TEST_REQUIRES => {
        'Role::Tiny'      => '2.000000',
        'Test::Exception' => 0.43,
        'Test::More'      => 0.94,
        'Test::Pod'       => 0,
    },
    (   eval { ExtUtils::MakeMaker->VERSION(6.46) }
        ? ( META_MERGE => {
                'meta-spec'    => { version => 2 },
                dynamic_config => 0,
                provides       => \%provides,
                prereqs        => {
                    develop => {
                        requires => {
                            'Test::Perl::Critic' => 0,
                            'Test::PerlTidy'     => 0,
                            'Type::Tiny'         => 0,
                            'Perl::Critic::Policy::Documentation::RequirePodLinksIncludeText'
                              => 0,
                            'Perl::Critic::Policy::Miscellanea::RequireRcsKeywords'
                              => 0,
                        },
                    },
                },
                resources      => {
                    homepage =>
                      'https://github.com/peczenyj/MooX-Role-Parameterized',
                    repository => {
                        type => 'git',
                        url  =>
                          'https://github.com/peczenyj/MooX-Role-Parameterized.git',
                        web =>
                          'https://github.com/peczenyj/MooX-Role-Parameterized',
                    },
                    bugtracker => {
                        web =>
                          'https://github.com/peczenyj/MooX-Role-Parameterized/issues'
                    },
                },
                x_authority => 'cpan:PACMAN',
            }
          )
        : ()
    ),
);
