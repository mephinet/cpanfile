package Module::CPANfile::Environment::Safe;

use parent 'Module::CPANfile::Environment';
use Module::CPANfile::Environment::Safe::Stack;

use warnings;
use strict;
use v5.10;

#use Data::Dumper;
#use re 'debugcolor';

my $_statement_re = qr/
(?&TOP_LEVEL)

(?(DEFINE)
 (?<QUOTE> ['"])
 (?<NONQUOTE> [^'"])
 (?<COMMENT> \#.* $ )

 (?<EOL> \s* [;,]? \s* (?&COMMENT)? $ )

 # save module_name and module_version in the hash
 (?<MODULE_NAME> ((?&QUOTE)?) ( [A-Za-z0-9_:]++ ) \g{-2}
   (?{ $^R->set_module($^N); })
 )
 (?<VERSION> (v?[0-9_.]++) )
 (?<UNQUOTED_VERSION> ([0-9_.]+?)\.?0*+ (?{ $^R->set_version($^N, 1) }) )
 (?<OPERATOR> ( <= | < | >= | > | == | != ) )
 (?<VERSION_REQ> (?&OPERATOR)?+ \s* (?&VERSION))

 (?<MULTI_VERSION_REQ>
   (?: ( (?&UNQUOTED_VERSION) )
   | (?: ((?&QUOTE)?) ( (?&VERSION_REQ) (?: \s*,\s* (?&VERSION_REQ) )*+ ) \g{-2}
       (?{ $^R->set_version($^N) })
     )
   ))


 (?<MODULE_VERSION_REQ>
  ((?&MODULE_NAME) (?: \s* (?: , | => ) \s* (?: (?&MULTI_VERSION_REQ) | undef | '' | "") )?
  )
 )

 # pop module and version from hash, add new requirement entry
 (?<NORMAL_REQ>
  ^\s* (requires | recommends | suggests | conflicts) \s+ (?&MODULE_VERSION_REQ) (?&EOL)
  (?{ $^R->add_requirement(type => $^N) })
 )
 (?<PHASE_REQ>
  ^\s* ((?:configure | build | test | author ))_requires \s+ (?&MODULE_VERSION_REQ) \s*+ (?&EOL)
  (?{ $^R->add_requirement(phase => ($^N eq 'author' ? 'develop' : $^N)) })
 )

 # save phase in the hash
 (?<PHASE>
  ((?&QUOTE)?) ( configure | build | test | runtime | develop ) \g{-2}
  (?{ $^R->set_phase($^N) })
 )

 # after phase requirement block is processed, remove phase from hash
 (?<PHASE_REQ_BLOCK>
  ^\s* on \s+ (?&PHASE) \s* (?: => | , ) \s* sub \s* \{  ( \s* (?&NORMAL_REQ)  \s* | \s* (?&COMMENT) )* \} (?&EOL)
  (?{ $^R->clear_phase() })
 )

 (?<FEATURE_NAME> ((?&QUOTE)) ((?&NONQUOTE)++) \g{-2}
  (?{ $^R->set_feature_name($^N) })
 )
 (?<FEATURE_DESC> ((?&QUOTE)) ((?&NONQUOTE)++) \g{-2}
  (?{ $^R->set_feature_desc($^N) })
 )

 (?<FEATURE>
   ^\s* feature \s+ (?&FEATURE_NAME)
   ( \s* (?: => | , ) \s* (?&FEATURE_DESC) )? \s*
   (?: => | ,) \s* sub \s* \{

   (?{ $^R->add_feature() })

   ( \s* (?&NORMAL_REQ) \s* | \s* (?&PHASE_REQ) \s* | \s* (?&PHASE_REQ_BLOCK) \s*  | \s* (?&COMMENT) )*
   \} (?&EOL)
   (?{ $^R->clear_feature() })
 )

 (?<TOP_LEVEL> ( (?&NORMAL_REQ) | (?&PHASE_REQ) | (?&PHASE_REQ_BLOCK) | (?&FEATURE) ))
)
/xm;

sub parse {
    my ( $self, $code ) = @_;

    local $^R = Module::CPANfile::Environment::Safe::Stack->new();

    while ( $code =~ /$_statement_re/gc ) {
        1;
    }

    $^R->register_features( $self->prereqs );
    $^R->register_requirements( $self->prereqs );

    return 1;
}

sub _evaluate {
    croak("No eval in Safe mode!\n");
}

1;
