package Module::CPANfile::Environment::Safe;

use parent 'Module::CPANfile::Environment';
use Module::CPANfile::Prereqs;
use Module::CPANfile::Requirement;
use Carp;
use warnings;
use strict;
use v5.10;

#use re 'debug';

my @_requirements;

my $_statement_re = qr/
(?&TOP_LEVEL)+
(?{ push @_requirements, @{$^R->{requirements}} })

(?(DEFINE)
 (?<QUOTE> ['"])

 # save module_name and module_version in the hash
 (?<MODULE_NAME> ((?&QUOTE)) ( [A-Za-z0-9_:]++ ) \g{-2}
   (?{ {module => $^N, %{$^R}} }) )
 (?<VERSION> (v?[0-9_.]++) )
 (?<OPERATOR> (< | <= | > | >= | == | != ) )
 (?<VERSION_REQ> (?&OPERATOR)? \s* (?&VERSION) )
 (?<MULTI_VERSION_REQ> ((?&QUOTE)?) ( (?&VERSION_REQ) (?: \s*,\s* (?&VERSION_REQ) )* ) \g{-2}
   (?{ {version => $^N, %{$^R}} }))

 (?<MODULE_VERSION_REQ>
  ((?&MODULE_NAME) (?: \s* (?: , | => ) \s* (?&MULTI_VERSION_REQ) )?
  )
 )

 # pop module and version from hash, add new requirement entry
 (?<NORMAL_REQ>
  \s* (requires | recommends | suggests | conflicts) \s+ (?&MODULE_VERSION_REQ) \s* ;
  (?{ my $entry = { phase => $^R->{phase} || 'runtime', type => $^N, module => delete $^R->{module}, version => delete $^R->{version}};
      push @{$^R->{requirements}}, $entry; $^R; })
 )
 (?<PHASE_REQ>
  \s*  ((?:configure | build | test | author ))_requires \s+ (?&MODULE_VERSION_REQ) \s* ;
  (?{ my $entry = { phase => ($^N eq 'author' ? 'develop' : $^N), type => 'requires', module => delete $^R->{module}, version => delete $^R->{version}};
      push @{$^R->{requirements}}, $entry; $^R; })
 )

 # save phase in the hash
 (?<PHASE>
  ((?&QUOTE)?) ( configure | build | test | runtime | develop ) \g{-2}
  (?{ {phase => $^N, %{$^R} } })
 )

 # after phase requirement block is processed, remove phase from hash
 (?<PHASE_REQ_BLOCK>
  \s* on \s+ (?&PHASE) \s* => \s* sub \s* { \s*+ ( (?&NORMAL_REQ) )*  \s* } \s*;
  (?{ delete $^R->{phase}; $^R })
 )

 # XXX missing: feature

 (?<TOP_LEVEL> ( (?&NORMAL_REQ) | (?&PHASE_REQ) | (?&PHASE_REQ_BLOCK) ) )
)
/xm;

sub parse {
    my ( $self, $code ) = @_;

    local $^R = {};
    @_requirements = ();

    while ($code =~ /$_statement_re/gc) {
        1;
    }

    foreach my $req (@_requirements) {
        $self->prereqs->add_prereq(
            phase       => $req->{phase},
            type        => $req->{type},
            module      => $req->{module},
            requirement => Module::CPANfile::Requirement->new(
                name    => $req->{module},
                version => $req->{version}
            )
        );
    }
    return 1;
}

sub _evaluate {
    croak("No eval in Safe mode!\n");
}

1;
