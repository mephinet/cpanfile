requires 'HTML::Escape';
requires 'HTML::Lint';
requires 'Plack::Middleware';
requires 'Plack::Util';
requires 'Plack::Util::Accessor';
requires 'constant';
requires 'parent';
requires 'perl', '5.009_004';

on configure => sub {
    requires 'Module::Build::Pluggable', '0.04';
    requires 'Module::Build::Pluggable::ReadmeMarkdownFromPod', '0.04';
    requires 'Module::Build::Pluggable::Repository', '0.01';
};

on build => sub {
    requires 'Module::Build::Pluggable::ReadmeMarkdownFromPod', '0.04';
    requires 'Module::Build::Pluggable::Repository', '0.01';
    requires 'Pod::Markdown';
};

on test => sub {
    requires 'HTTP::Request';
    requires 'Plack::Builder';
    requires 'Plack::Test';
    requires 'Test::More', '0.88';
    requires 'Test::Requires', '0.06';
};
