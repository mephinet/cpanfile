#! /usr/bin/perl

use Data::Dumper;
use Search::Elasticsearch;
use File::Spec::Functions qw(catfile updir);
use FindBin;
use LWP::UserAgent;

use warnings;
use strict;

my $target_dir = catfile( $FindBin::RealBin, updir, 't', 'files' );

my $es = Search::Elasticsearch->new(
    nodes    => 'api.metacpan.org',
    cxn_pool => 'Static::NoPing'
);

my $res = $es->search(
    index => 'v0',
    type  => 'file',
    body  => {
        filter => {
            and => [
                { term => { path     => "cpanfile" } },
                { term => { status   => "latest" } },
                { term => { maturity => "released" } }
            ]
        },
        fields => [qw(author release path release)]
    },
    size => 5000
);

my $ua = LWP::UserAgent->new( keep_alive => 5 );

foreach my $match ( @{ $res->{hits}->{hits} } ) {
    my $f    = $match->{fields};
    my $path = join '/', map { $f->{$_} } qw(author release path);
    my $url  = "https://metacpan.org/raw/$path?download=1";

    my $cleaned_path = $path;
    $cleaned_path =~ tr/a-zA-Z0-9./\-/cs;
    $cleaned_path = catfile( $target_dir, $cleaned_path );

    next if -f $cleaned_path;
    print "$url\n";
    my $res = $ua->get($url);
    unless ( $res->is_success ) {
        warn "Download failed: ", $res->status_line;
        next;
    }
    open my $fh, '>', $cleaned_path
        or die "Failed opening $cleaned_path: $!\n";
    $fh->print( $res->decoded_content );
    $fh->close();
}
