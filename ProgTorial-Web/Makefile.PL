#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'ProgTorial-Web';
all_from 'lib/ProgTorial/Web.pm';

# requires 'Acme::HalfOfCPAN';
requires 'Catalyst::Runtime' => '5.80025';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::Credential::OpenID' => '0.16';
requires 'Catalyst::Plugin::ConfigLoader' => '0.28';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Authentication' => '0.10016';
requires 'Catalyst::Plugin::Session' => '0.3';
requires 'Catalyst::Plugin::Session::Store::File' => '0.18';
requires 'Catalyst::Plugin::Session::State::Cookie' => '0.17';
requires 'Catalyst::Plugin::Static::Simple' => '0.29';
requires 'Catalyst::View::TT' => '0.34';
requires 'Catalyst::Model::DBIC::Schema' => '0.43';
requires 'CatalystX::SimpleLogin' => '0.12';
requires 'Template::Plugin::Markdown' => '0.02';
requires 'Path::Class' => '0.19';
requires 'Moose';
requires 'MooseX::Role::WithOverloading' => '0.08';
requires 'MooseX::MethodAttributes' => '0.24';
requires 'MooseX::StrictConstructor' => '0.11';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
