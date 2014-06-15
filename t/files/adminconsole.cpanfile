# info : needed in core perl

# Set Env ORACLE_HOME, LD_LIBRARY_PATH for install
requires 'DBD::Oracle' => '>= 1.66';

requires 'Cache::FastMmap';
requires 'LWP::UserAgent';
requires 'Bread::Board';
requires 'CHI';
requires 'CHI::Driver::FastMmap';
requires 'Class::Load';
requires 'DBI';
requires 'DBIx::Class' => '>= 0.08260';
requires 'Data::Dumper::Simple';
requires 'Data::Visitor';
requires 'DateTime::Format::Oracle';
requires 'DateTime::Format::Strptime';
requires 'DateTime::Format::XSD';
requires 'Elasticsearch' => '>= 1.0';
requires 'Email::Find';
requires 'HTML::FormHandler';
requires 'IO::Interactive';
requires 'IO::String';
requires 'JSON::Any';
requires 'JSON::XS';
requires 'Log::Any';
requires 'Module::Runtime';
requires 'Moose';
requires 'MooseX::NonMoose' => '>= 0.26';
requires 'MooseX::Storage';
requires 'MooseX::StrictConstructor';
requires 'OX';
requires 'Path::Class';
requires 'Plack::Middleware::AddDefaultCharset';
requires 'Plack::Middleware::Static';
requires 'Plack::Session::State::Cookie';
requires 'Plack::Session::Store::Cache';
requires 'Regexp::Assemble';
requires 'Sys::Hostname::FQDN';
requires 'Term::ProgressBar';
requires 'aliased';
requires 'local::lib';

# plack handler
requires 'Plack::Handler::Starman';

# schema dump
requires 'DBIx::Class::Schema::Loader' => '>= 0.07039';
requires 'Math::Base36';
requires 'MooseX::MarkAsMethods';

on 'test' => sub {
    requires 'Test::Class::Moose';
    requires 'Test::Harness';
    requires 'Devel::Cover';
    requires 'Test::Perl::Critic';
};
