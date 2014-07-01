use Test::More;
use Test::Differences;
use FindBin;
use File::Basename;
use Module::CPANfile;
use Regexp::Assemble;

use warnings;
use strict;

my $blacklist = Regexp::Assemble->new();

# just crazy
$blacklist->add('TAP-Parser-SourceHandler-Validator-W3C-HTML');

# unquoted version with trailing 0
$blacklist->add('Business-CPI', 'Caroline', 'Carton',
    'Catalyst-Action-FromPSGI', 'Config-Simple-Extended',
    'Convos', 'DBIx-Class-DeploymentHandler',
    'DBIx-Class-Helpers', 'DBIx-Class-MaterializedPath',
    'DBIx-Introspector', 'Dist-Zilla-Plugin-LicenseFromModule',
    'Dist-Zilla-Plugin-Prereqs-FromCPANfile', 'Elastijk',
    'Log-Contextual', 'Minilla', 'Net-Async-Ping', 'OrePAN2',
    'Plack-App-File-CaseInsensitive', 'Pod-Weaver-Plugin-Exec',
    'SQL-Abstract-Plugin-InsertMulti', 'Ukigumo-Agent',
    'Ukigumo-Client', 'Win32-ServiceManager', 'carton');

# on recommends, on author, on development - not a phase
$blacklist->add('Text-Sass-XS', 'Cocoa-NetworkChange',
    'Reply-Plugin-ORM', 'Text-Sass-XS', 'AnyEvent-Lingr',
    'NgxQueue', 'GFUJI-Text-Md2Inao');

# missing semicolon
$blacklist->add('Catmandu', 'File-Name-Check',
    'Module-Build-XSUtil', 'Smart-Options', 'Task-Plack',
    'Try-Lite', 'MooseX-CoercePerAttribute',
    'Dancer-Plugin-Catmandu', 'Data-OpeningHours');

# uses _ syntax in float - works but test fails
$blacklist->add('Dist-Milla', 'Furl', 'Minilla', 'Test-TCP');

# uses variables
$blacklist->add('Caroline', 'Minilla', 'Spellunker-Perl', 'Skype-Any',
'App-dropboxapi');

my $blacklist_re = $blacklist->re;

sub compare_file {
    my $fn = shift;
    my $bn = basename($fn);

    my $c1;
  SKIP: {
      skip "$bn is blacklisted", 1 if $bn =~ $blacklist_re;

      eval {
        $c1 = Module::CPANfile->load($fn)
      } or do {
          skip "Module::CPANfile fails to parse $fn", 1;
  };
      my $c2 = Module::CPANfile->new($fn, safe => 1);
    eq_or_diff($c2->to_string, $c1->to_string, 'identical output for '. $bn);
    }
}

my @testfiles = @ARGV ? @ARGV : glob($FindBin::Bin . '/files/*');
foreach my $f (@testfiles) {
    compare_file($f);
}

done_testing;
