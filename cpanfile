requires "App::Cmd::Setup" => "0.309";
requires "Carp" => "0";
requires "Class::Load" => "0";
requires "Clone" => "0";
requires "Data::Dump" => "0";
requires "Digest::MD5" => "0";
requires "Exporter" => "0";
requires "List::Util" => "0";
requires "Log::Any" => "0";
requires "Log::Any::Adapter" => "0";
requires "Module::Pluggable" => "0";
requires "Moo" => "0";
requires "Moo::Role" => "0";
requires "MooX::Types::MooseLike::Base" => "0";
requires "Package::Stash" => "0";
requires "Path::Class" => "0";
requires "Safe::Isa" => "0";
requires "Sereal::Decoder" => "0";
requires "Sereal::Encoder" => "0";
requires "Try::Tiny" => "0";
requires "YAML::XS" => "0.35";
requires "namespace::clean" => "0";
requires "parent" => "0";
requires "perl" => "5.012";
requires "strict" => "0";
requires "warnings" => "0";

on 'build' => sub {
  requires "Module::Build" => "0.3601";
};

on 'test' => sub {
  requires "File::Temp" => "0";
  requires "IPC::System::Simple" => "0";
  requires "Test::Compile" => "0";
  requires "Test::Modern" => "0";
  requires "Test::More" => "0.88";
  requires "autodie" => "0";
};

on 'configure' => sub {
  requires "Module::Build" => "0.3601";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Meta" => "0";
  requires "Test::CleanNamespaces" => ">= 0.04, != 0.06";
  requires "Test::Kwalitee" => "1.12";
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "version" => "0.9901";
};
