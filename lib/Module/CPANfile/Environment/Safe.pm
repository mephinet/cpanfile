package Module::CPANfile::Environment::Safe;

use parent 'Module::CPANfile::Environment';
use Carp;
use warnings;
use strict;

#use re 'debug';

my $module_re = qr/['"] [A-Za-z:]+ ['"]/x;
my $version_re = qr/v?[0-9]+\.[0-9_.]+/x;
my $operator_re = qr/(?: < | <= | > | >= | == | != )/x;
my $version_requirement_re = qr/$operator_re? \s* $version_re/x;
my $multiple_version_requirement_re = qr/['"]? \s* $version_requirement_re (?: \s* , \s* $version_requirement_re )*  \s* ['"]?/x;
my $module_version_requirement_re = qr/$module_re (?: \s*,\s* $multiple_version_requirement_re)?/x;
my $requirement_re = qr/\s* (?: requires|recommends|suggests|conflicts) \s+ $module_version_requirement_re  \s*; \s* $/mx;

my $phase_re = qr/['"] (?: configure | build | test | runtime | develop ) ['"] /x;
my $on_re = qr/\s* on \s+ $phase_re \s* => \s* sub \s* { \s* $requirement_re* \s* }  \s*; \s* $/mx;

my $feature_re = qr/xxxxxxxxxxxxx/x; ### XXX

my $phase_requires_re = qr/\s* (?: configure | build | test | author )_requires \s+ $module_version_requirement_re  \s*; \s* $/mx;

my $statement_re = qr/^ \s* ($requirement_re|$on_re|$feature_re|$phase_requires_re)/mx;

sub parse {
    my ($self, $code) =  @_;

    print STDERR "parsing: $code\n";
    my @statements = $code =~ /$statement_re/gc;
    foreach my $statement (@statements) {
        print STDERR "--> $statement\n" if $statement;
    }
    return 1;
}

sub _evaluate {
    croak("No eval in Safe mode!\n");
}

1;
