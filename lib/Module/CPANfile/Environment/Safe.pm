package Module::CPANfile::Environment::Safe;

use parent 'Module::CPANfile::Environment';
use Module::CPANfile::Prereqs;
use Module::CPANfile::Requirement;
use Carp;
use warnings;
use strict;
use v5.10;

#use Data::Dumper;
#use re 'debugcolor';

my @_requirements;
my @_features;

sub clean_underscores {
    my $s = shift;
    $s =~ s/_//g if $s;
    return $s;
}

my $_statement_re = qr/
(?&TOP_LEVEL)

(?(DEFINE)
 (?<QUOTE> ['"])
 (?<NONQUOTE> [^'"])
 (?<COMMENT> \#.* $ )

 (?<EOL> \s* [;,]? \s* (?&COMMENT)? $ )

 # save module_name and module_version in the hash
 (?<MODULE_NAME> ((?&QUOTE)?) ( [A-Za-z0-9_:]++ ) \g{-2}
   (?{ die "overwriting module" if $^R->{module}; {module => $^N, %{$^R}} })
 )
 (?<VERSION> (v?[0-9_.]++) )
 (?<UNQUOTED_VERSION> ([0-9_.]+?)\.?0*+ (?{ my $v = $^N; {version => clean_underscores($v), %{$^R}} }) )
 (?<OPERATOR> ( <= | < | >= | > | == | != ) )
 (?<VERSION_REQ> (?&OPERATOR)?+ \s* (?&VERSION))

 (?<MULTI_VERSION_REQ>
   (?: ( (?&UNQUOTED_VERSION) )
   | (?: ((?&QUOTE)?) ( (?&VERSION_REQ) (?: \s*,\s* (?&VERSION_REQ) )*+ ) \g{-2}
       (?{ {version => $^N, %{$^R}} })
     )
   ))


 (?<MODULE_VERSION_REQ>
  ((?&MODULE_NAME) (?: \s* (?: , | => ) \s* (?: (?&MULTI_VERSION_REQ) | undef | '' | "") )?
  )
 )

 # pop module and version from hash, add new requirement entry
 (?<NORMAL_REQ>
  ^\s* (requires | recommends | suggests | conflicts) \s+ (?&MODULE_VERSION_REQ) (?&EOL)
  (?{ my $entry = { phase => $^R->{phase} || 'runtime', feature => $^R->{feature}, type => $^N, module => delete $^R->{module}, version => delete $^R->{version}};
      #say 'adding normal requirement:', Dumper($entry);
      push @_requirements, $entry; $^R; })
 )
 (?<PHASE_REQ>
  ^\s* ((?:configure | build | test | author ))_requires \s+ (?&MODULE_VERSION_REQ) \s*+ (?&EOL)
  (?{ my $entry = { phase => ($^N eq 'author' ? 'develop' : $^N), feature => $^R->{feature}, type => 'requires', module => delete $^R->{module}, version => delete $^R->{version}};
      #say 'adding phase requirement:', Dumper($entry);
      push @_requirements, $entry; $^R; })
 )

 # save phase in the hash
 (?<PHASE>
  ((?&QUOTE)?) ( configure | build | test | runtime | develop ) \g{-2}
  (?{ {phase => $^N, %{$^R} } })
 )

 # after phase requirement block is processed, remove phase from hash
 (?<PHASE_REQ_BLOCK>
  ^\s* on \s+ (?&PHASE) \s* (?: => | , ) \s* sub \s* \{  ( \s* (?&NORMAL_REQ)  \s* | \s* (?&COMMENT) )* \} (?&EOL)
  (?{ delete $^R->{phase}; $^R })
 )

 (?<FEATURE_NAME> ((?&QUOTE)) ((?&NONQUOTE)++) \g{-2}
  (?{ { feature => $^N, %{$^R} } })
 )
 (?<FEATURE_DESC> ((?&QUOTE)) ((?&NONQUOTE)++) \g{-2}
  (?{ { feature_desc => $^N, %{$^R} } })
 )

 (?<FEATURE>
   ^\s* feature \s+ (?&FEATURE_NAME)
   ( \s* (?: => | , ) \s* (?&FEATURE_DESC) )? \s*
   (?: => | ,) \s* sub \s* \{
   (?{ push @_features, {name => $^R->{feature}, desc => $^R->{feature_desc} }; $^R })
   ( \s* (?&NORMAL_REQ) \s* | \s* (?&PHASE_REQ) \s* | \s* (?&PHASE_REQ_BLOCK) \s*  | \s* (?&COMMENT) )*
   \} (?&EOL)
   (?{ delete $^R->{feature}; delete $^R->{feature_desc} })
 )

 (?<TOP_LEVEL> ( (?&NORMAL_REQ) | (?&PHASE_REQ) | (?&PHASE_REQ_BLOCK) | (?&FEATURE) ))
)
/xm;

sub parse {
    my ( $self, $code ) = @_;

    local $^R = {};
    @_requirements = ();
    @_features     = ();

    while ( $code =~ /$_statement_re/gc ) {
        1;
    }

    foreach my $f (@_features) {
        $self->prereqs->add_feature( $f->{name}, $f->{desc} );
    }

    foreach my $req (@_requirements) {
        $self->prereqs->add_prereq(
            feature     => $req->{feature},
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
