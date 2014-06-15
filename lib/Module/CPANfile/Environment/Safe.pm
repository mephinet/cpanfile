package Module::CPANfile::Environment::Safe;

use parent 'Module::CPANfile::Environment';
use Carp;
use warnings;
use strict;

sub parse {
    my ($self, $code) =  @_;

    # parse code goes here...
}

sub _evaluate {
    croak("No eval in Safe mode!\n");
}

1;
