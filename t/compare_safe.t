use Test::More;
use FindBin;
use Module::CPANfile;

use warnings;
use strict;

sub compare_file {
    my $fn = shift;
    my $c1 = Module::CPANfile->load($fn);
    my $c2 = Module::CPANfile->new($fn, safe => 1);
    is($c2->to_string, $c1->to_string, 'identical output for '. $fn);
}

my @testfiles = glob $FindBin::Bin . '/files/*.cpanfile';

foreach my $f (@testfiles) {
    compare_file($f);
}

done_testing;
