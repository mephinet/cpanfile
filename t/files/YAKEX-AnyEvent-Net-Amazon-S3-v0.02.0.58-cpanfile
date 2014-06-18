requires "AnyEvent" => "0";
requires "AnyEvent::HTTP::LWP::UserAgent" => "0.10";
requires "AnyEvent::HTTP::LWP::UserAgent::Determined" => "0";
requires "Carp" => "0";
requires "Data::Stream::Bulk::AnyEvent" => "0";
requires "Digest::MD5" => "0";
requires "File::Find::Rule" => "0";
requires "Getopt::Long" => "0";
requires "MIME::Types" => "0";
requires "Module::AnyEvent::Helper" => "0";
requires "Module::AnyEvent::Helper::Filter" => "0";
requires "Module::AnyEvent::Helper::PPI::Transform" => "0";
requires "Net::Amazon::S3" => "0.58";
requires "PPI::Transform::PackageName" => "0";
requires "Path::Class" => "0";
requires "Pod::Usage" => "0";
requires "Term::Encoding" => "0";
requires "Term::ProgressBar::Simple" => "0";
requires "parent" => "0";
requires "perl" => "5.006";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "Digest::MD5::File" => "0";
  requires "File::Find" => "0";
  requires "File::Temp" => "0";
  requires "File::stat" => "0";
  requires "LWP::Simple" => "0";
  requires "Test::Exception" => "0";
  requires "Test::More" => "0";
  requires "vars" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Meta" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};
