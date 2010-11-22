use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Simple::Perl::Demo',
    AUTHOR              => q{Jess Robinson <castaway@desert-island.me.uk>},
    VERSION             => '0.01',
    ABSTRACT            => 'Demo',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Simple-Perl-Demo-*' },
);
