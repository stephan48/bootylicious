package Bootylicious::Config;

use strict;
use warnings;

our $AUTOLOAD;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

    my $self = {%{$class->_defaults}, @_};
    bless $self, $class;

    return $self;
}

sub _defaults {
    {   author      => 'whoami',
        email       => '',
        title       => 'Just another blog',
        about       => 'Perl hacker',
        description => 'I do not know if I need this',

        cuttag    => '[cut]',
        cuttext   => 'Keep reading',
        pagelimit => 10,
        datefmt   => '%a, %d %b %Y',

        menu => [
            index   => '/',
            tags    => '/tags.html',
            archive => '/articles.html'
        ],
        footer =>
          'Powered by <a href="http://getbootylicious.org">Bootylicious</a>',
        theme => '',

        comments_enabled => 1,

        meta => [],

        articles_directory => 'articles',
        pages_directory    => 'pages',
        drafts_directory   => 'drafts',
        public_directory   => 'public'
    };
}

sub AUTOLOAD {
    my $self = shift;

    my $method = $AUTOLOAD;

    return if $method =~ /^[A-Z]+?$/;
    return if $method =~ /^_/;
    return if $method =~ /(?:\:*?)DESTROY$/;

    $method = (split '::' => $method)[-1];

    return $self->{$method};
}

1;
