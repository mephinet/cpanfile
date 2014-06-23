requires 'Deeme';
requires 'Deeme::Utils';
requires 'Meerkat';
requires 'Meerkat::Role::Document';
requires 'Mojo::Base';
requires 'Moose';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
    requires 'perl', '5.008005';
};

on test => sub {
    requires 'MongoDB::Connection';
    requires 'Test::More';
};
