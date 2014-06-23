requires 'Deeme';
requires 'Deeme::Utils';
requires 'Mango';
requires 'Mojo::Base';
requires 'feature';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
    requires 'perl', '5.008005';
};

on test => sub {
    requires 'Carp::Always';
    requires 'MongoDB::Connection';
    requires 'Test::More';
};
