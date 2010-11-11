#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use FindBin;

use_ok('Bootylicious::UrlBuilder');

my $builder;

$builder = Bootylicious::UrlBuilder->new;
is $builder->home => '/';

$builder = Bootylicious::UrlBuilder->new(prefix => '/prefix');
is $builder->home => '/prefix/';

$builder = Bootylicious::UrlBuilder->new(base => 'http://example.com');
is $builder->home->to_abs => 'http://example.com/';
