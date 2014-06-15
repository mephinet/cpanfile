package Module::CPANfile::Environment::Safe;

use parent 'Module::CPANfile::Environment';
use Carp;
use warnings;
use strict;

my $module_re = qr/['"] [A-Za-z:]+ ['"]/x;
my $version_re = qr/v?[0-9]+\.[0-9_.]+/x;
my $operator_re = qr/(?: < | <= | > | >= | == | != )/x;
my $version_requirement_re = qr/['"]? $operator_re? $version_re ['"]?/x;
my $multiple_version_requirement_re = qr/ $version_requirement_re (?: \s* , \s* $version_requirement_re )* /x;
my $requirement_re = qr/(?: requires|recommends|suggests|conflicts) \s+ $module_re (?: \s*,\s* $multiple_version_requirement_re)? /x;

my $phase_re = qr/['"] (?: configure | build | test | runtime | develop ) ['"] /x;
my $on_re = qr/on \s+ $phase_re \s* => \s* sub \s* { $requirement_re* } \s* /x;

my $feature_re = qr/xxxxxxxxxxxxx/x; ### XXX

my $phase_requires_re = qr/ (?: configure | build | test | author )_requires \s+ $module_re (?: \s*,\s* $multiple_version_requirement_re)?/x;

my $statement_re = qr/^ \s* ($requirement_re|$on_re|$feature_re|phase_requires_re) \s*; \s* $/mx;

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
