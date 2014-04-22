
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.07

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'bin/mistress',
    'lib/Mistress.pm',
    'lib/Mistress/App.pm',
    'lib/Mistress/App/Command.pm',
    'lib/Mistress/App/Command/consider.pm',
    'lib/Mistress/App/Command/lol.pm',
    'lib/Mistress/App/Command/report.pm',
    'lib/Mistress/App/Command/smoke.pm',
    'lib/Mistress/Env.pm',
    'lib/Mistress/Env/Config.pm',
    'lib/Mistress/Env/Config/File.pm',
    'lib/Mistress/Env/Config/Hash.pm',
    'lib/Mistress/Env/Fs.pm',
    'lib/Mistress/Env/Fs/Disk.pm',
    'lib/Mistress/Obj/Dist.pm',
    'lib/Mistress/Obj/DistSet.pm',
    'lib/Mistress/Obj/PerlInterpreter.pm',
    'lib/Mistress/Obj/PerlLib.pm',
    'lib/Mistress/Obj/Report.pm',
    'lib/Mistress/Plugin/UploadGatherer.pm',
    'lib/Mistress/Role/DistGatherer.pm',
    'lib/Mistress/Role/HasPlugins.pm',
    'lib/Mistress/Util.pm',
    't/000-report-versions-tiny.t',
    't/00_compile.t',
    't/00_versions.t',
    't/01_mistress_std.t',
    't/02_mistress_god.t',
    't/author-critic.t',
    't/author-pod-spell.t',
    't/files/example_config.yml',
    't/mistress/00_util.t',
    't/mistress/01_env/config.t',
    't/mistress/01_env/config/file.t',
    't/mistress/01_env/config/hash.t',
    't/mistress/01_env/fs/disk.t',
    't/mistress/obj/dist.t',
    't/mistress/obj/distset.t',
    't/release-changes_has_content.t',
    't/release-clean-namespaces.t',
    't/release-distmeta.t',
    't/release-eol.t',
    't/release-kwalitee.t',
    't/release-minimum-version.t',
    't/release-mojibake.t',
    't/release-no-tabs.t',
    't/release-pod-coverage.t',
    't/release-pod-syntax.t',
    't/release-portability.t',
    't/release-test-version.t',
    't/release-unused-vars.t'
);

notabs_ok($_) foreach @files;
done_testing;
