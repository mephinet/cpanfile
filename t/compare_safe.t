use Test::More;
use FindBin;
use Module::CPANfile;

use warnings;
use strict;

sub compare_file {
    my $fn = shift;
    return if $fn =~ /TAP-Parser-SourceHandler-Validator-W3C-HTML/;

    my $c1;
  SKIP: {
      eval {
        $c1 = Module::CPANfile->load($fn)
      } or do {
          skip "Module::CPANfile fails to parse $fn", 1;
  };
      my $c2 = Module::CPANfile->new($fn, safe => 1);
    is($c2->to_string, $c1->to_string, 'identical output for '. $fn);
    }
}

my @testfiles = glob($FindBin::Bin . '/files/*');
foreach my $f (@testfiles) {
    compare_file($f);
}

done_testing;
