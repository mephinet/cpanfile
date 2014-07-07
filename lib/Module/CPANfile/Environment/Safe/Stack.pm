package Module::CPANfile::Environment::Safe::Stack;

use Module::CPANfile::Requirement;

use warnings;
use strict;

sub _clean_underscores {
    my ( $self, $s ) = @_;
    $s =~ s/_//g if $s;
    return $s;
}

sub set_module {
    my ( $self, $m ) = @_;
    $self->{module} = $m;
    return $self;
}

sub set_feature_name {
    my ( $self, $f ) = @_;
    $self->{feature_name} = $f;
    return $self;
}

sub set_feature_desc {
    my ( $self, $d ) = @_;
    $self->{feature_desc} = $d;
    return $self;
}

sub clear_feature {
    my $self = shift;
    delete $self->{feature_name};
    delete $self->{feature_desc};
    return $self;
}

sub set_phase {
    my ( $self, $phase ) = @_;
    $self->{phase} = $phase;
    return $self;
}

sub clear_phase {
    my $self = shift;
    undef $self->{phase};
    return $self;
}

sub set_version {
    my ( $self, $v, $clean ) = @_;
    $v = $self->_clean_underscores($v) if $clean;
    $self->{version} = $v;
    return $self;
}

sub add_requirement {
    my ( $self, %args ) = @_;
    my $entry = {
        phase => ( $args{phase} || $self->{phase} || 'runtime' ),
        feature => $self->{feature_name},
        module  => delete $self->{module},
        version => delete $self->{version},
        type    => ( $args{type} || 'requires' )
    };
    push @{ $self->{requirements} }, $entry;
    return $self;
}

sub add_feature {
    my $self = shift;
    push @{ $self->{features} },
        { name => $self->{feature_name}, desc => $self->{feature_desc} };
    return $self;
}

sub register_features {
    my ( $self, $prereqs ) = @_;
    foreach my $f ( @{ $self->{features} } ) {
        $prereqs->add_feature( $f->{name}, $f->{desc} );
    }
    return;
}

sub register_requirements {
    my ( $self, $prereqs ) = @_;

    foreach my $req ( @{ $self->{requirements} } ) {
        $prereqs->add_prereq(
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
    return;
}

sub new {
    my ($class) = @_;
    my $self = {
        module       => undef,
        feature_name => undef,
        feature_desc => undef,
        version      => undef,
        phase        => undef,
        feature      => undef,
        requirements => [],
        features     => []
    };
    bless $self, $class;
    return $self;
}

1;
