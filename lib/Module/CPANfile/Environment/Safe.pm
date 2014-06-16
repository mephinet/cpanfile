package Module::CPANfile::Environment::Safe;

use parent 'Module::CPANfile::Environment';
use Carp;
use warnings;
use strict;
use v5.10;

#use re 'debug';

my $statement_re = qr/
(?&TOP_LEVEL)+

(?(DEFINE)
 (?<QUOTE> ['"])

 (?<MODULE_NAME> ((?&QUOTE)) ( [A-Za-z0-9_:]++ ) \g{-2} (?{#say '--> MODULE_NAME ', $^N}))
 (?<VERSION> (v?[0-9]++\.[0-9_.]++) (?{#say '--> VERSION ', $^N}) )
 (?<OPERATOR> (< | <= | > | >= | == | != ) (?{say '--> OPERATOR ', $^N}))
 (?<VERSION_REQ> (?&OPERATOR)? \s* (?&VERSION) )
 (?<MULTI_VERSION_REQ> ((?&QUOTE)?) (?&VERSION_REQ) (?: \s*,\s* (?&VERSION_REQ) )* \g{-1})

 (?<MODULE_VERSION_REQ>
  ((?&MODULE_NAME) (?: \s*,\s* (?&MULTI_VERSION_REQ) )?
  )
  (?{say '--> MODULE_VERSION_REQ ', $^N })
 )

 (?<NORMAL_REQ>
  \s* ( (requires | recommends | suggests | conflicts) \s+ (?&MODULE_VERSION_REQ) \s* ;)
  (?{ say '--> NORMAL_REQ ', $^N})
 )

 (?<PHASE_REQ>
  \s* ( (?:configure | build | test | author )_requires \s+ (?&MODULE_VERSION_REQ) \s* ;)
  (?{ say '--> PHASE_REQ ', $^N})
 )

 (?<PHASE>
  ((?&QUOTE)) ( configure | build | test | runtime | develop ) \g{-2} (?{ say '--> PHASE ', $^N})
 )

 (?<PHASE_REQ_BLOCK>
  \s* ( on \s+ (?&PHASE) \s* => \s* sub \s* { \s* ( (?&NORMAL_REQ) | (?&PHASE_REQ) )*  \s* } \s*;)
  (?{ say '--> PHASE_REQ_BLOCK ', $^N })
 )

 # XXX missing: feature

 (?<TOP_LEVEL> ( (?&NORMAL_REQ) | (?&PHASE_REQ) | (?&PHASE_REQ_BLOCK) ) )
)
/xm;

sub parse {
    my ( $self, $code ) = @_;

    print STDERR "parsing: $code\n";
    while ( $code =~ /$statement_re/gc ) {
        1;
    }
    return 1;
}

sub _evaluate {
    croak("No eval in Safe mode!\n");
}

1;
