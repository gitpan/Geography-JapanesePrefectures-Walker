use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Geography::JapanesePrefectures::Walker',
    AUTHOR              => 'Atsushi Kobayashi <nekokak@gmail.com>',
    VERSION_FROM        => 'lib/Geography/JapanesePrefectures/Walker.pm',
    ABSTRACT_FROM       => 'lib/Geography/JapanesePrefectures/Walker.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Test::Class' => 0,
        'Geography::JapanesePrefectures' => 0,
        'Scalar::Util' => 0,
        'Encode' => 0,
        'List::MoreUtils' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Geography-JapanesePrefectures-Walker-*' },
);
